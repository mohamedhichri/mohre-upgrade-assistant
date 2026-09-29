# MOHRE DSS Upgrade Assistant

Step-by-step runbook for upgrading the MOHRE Dataiku DSS environment to
version `15.0.2`.

The repository is split into four phases:

1. [`1-pre-upgrade/tasks.sh`](1-pre-upgrade/tasks.sh): download release artifacts,
	 stop DSS, and create backups.
2. [`2-upgrade/tasks.sh`](2-upgrade/tasks.sh): install DSS `15.0.2` into the
	 existing data directory.
3. [`3-post-upgrade-1/tasks.sh`](3-post-upgrade-1/tasks.sh): reinstall R,
	 graphics export, Hadoop/Spark integrations, reinstall User Isolation (UIF),
	 and rebuild the container base images (including MOHRE-specific images
	 pushed to the Harbor registry).
4. [`4-post-upgrade-2/tasks.sh`](4-post-upgrade-2/tasks.sh): start DSS, rebuild
	 code environment images and Code Studios, and hand off model retraining.

## Assumptions

- The DSS data directory is `/data/dataiku/dss_data`.
- The DSS service account is `dss`.
- The PostgreSQL service is managed by the `postgres` operating-system user.
- The host has network access to `downloads.dataiku.com` and enough free disk
	space for the release archives and backups.
- The Hadoop/Spark setup uses generic Hadoop 3 and Spark `4.1.2`.
- User Isolation (UIF) is enabled, with `dss` as the DSS service account.
- Container images are pushed to the Harbor registry
	`harbor.mohre.gov.ae/lmis_dataiku`, and the host running DSS design (prod)
	is logged in to it.
- The following base-image build inputs exist on the DSS host:
	- `/home/dss/oracle-instantclient-basic-23.8.0.25.04-1.el9.x86_64.rpm`
	- `/home/dss/geos-devel-3.13.1-1.el9.x86_64.rpm`
	- `/home/dss/docker-pretend.txt`, `/home/dss/docker-pretend.txt.1` and
		`/home/dss/docker-pretend.txt.sql_server_issue` (Dockerfile fragments
		prepended to the image builds)
	- `/etc/crypto-policies/back-ends/java.config`

Confirm these assumptions with the platform administrator before starting. The
upgrade is disruptive and should be performed during an approved maintenance
window.

## Before you start

1. Confirm that DSS `15.0.2` is compatible with the current DSS version,
	 operating system, Java, Python, R, PostgreSQL, Hadoop, Spark, Kubernetes,
	 and container runtime configuration.
2. Confirm that no jobs, scenarios, deployments, or users are active.
3. Record the current DSS configuration and verify that the PostgreSQL backup
	 destination has sufficient space.
4. Ensure that `wget`, `tar`, `sudo`, and PostgreSQL client tools are installed.
5. Run the commands below with an account that can become `dss` and
	 `postgres` and can use `sudo`.

## Upgrade procedure

### 1. Download release artifacts and back up DSS

Run as an administrator, switching to `dss` for DSS-owned files:

```bash
export DSS_VERSION=15.0.2
export DATA_DIR=/data/dataiku/dss_data
export BACKUP_DIR=/data/dataiku/dss_data_backup_$(date +%F)

sudo -iu dss
cd /data
wget "https://downloads.dataiku.com/public/studio/${DSS_VERSION}/dataiku-dss-${DSS_VERSION}.tar.gz"
wget "https://downloads.dataiku.com/public/studio/${DSS_VERSION}/dataiku-dss-hadoop-standalone-libs-generic-hadoop3-${DSS_VERSION}.tar.gz"
wget "https://downloads.dataiku.com/public/studio/${DSS_VERSION}/dataiku-dss-spark-standalone-${DSS_VERSION}-4.1.2-generic-hadoop3.tar.gz"
exit

sudo -iu dss /data/dataiku/dss_data/bin/dss stop
sudo cp -a /data/dataiku/dss_data "${BACKUP_DIR}"
sudo -iu postgres pg_dumpall > "/data/postgresql-dump-$(date +%F).sql"
```

Verify that the DSS backup directory and PostgreSQL dump exist before
continuing. Keep the release archives and backups until the upgrade has been
accepted.

### 2. Install DSS `15.0.2`

```bash
export DSS_VERSION=15.0.2
export DATA_DIR=/data/dataiku/dss_data

sudo -iu dss tar xzf "/data/dataiku-dss-${DSS_VERSION}.tar.gz" -C /data
sudo -iu dss \
	"/data/dataiku-dss-${DSS_VERSION}/installer.sh" -d "${DATA_DIR}" -u
```

If the installer reports missing operating-system dependencies, review the
installer output and run the requested dependency installer as root, then
rerun the DSS installer:

```bash
sudo -i "/home/dataiku/dataiku-dss-${DSS_VERSION}/scripts/install/install-deps.sh"
```

Do not continue until the installer completes successfully.

### 3. Reinstall integrations, UIF, and rebuild base images

Run after installation, before starting DSS:

```bash
export DATA_DIR=/data/dataiku/dss_data
export DSS_VERSION=15.0.2

sudo -iu dss "${DATA_DIR}/bin/dssadmin" install-R-integration
sudo -iu dss "${DATA_DIR}/bin/dssadmin" install-graphics-export
sudo -iu dss "${DATA_DIR}/bin/dssadmin" install-hadoop-integration \
	-standaloneArchive "/data/dataiku-dss-hadoop-standalone-libs-generic-hadoop3-${DSS_VERSION}.tar.gz"
sudo -iu dss "${DATA_DIR}/bin/dssadmin" install-spark-integration \
	-standaloneArchive "/data/dataiku-dss-spark-standalone-${DSS_VERSION}-4.1.2-generic-hadoop3.tar.gz" \
	-forK8S
```

#### Reinstall User Isolation (UIF)

Run as root:

```bash
sudo -i "${DATA_DIR}/bin/dssadmin" install-impersonation dss
```

Then check the security configuration in
`/etc/dataiku-security/<INSTALL_ID>/security-config.ini`.

#### Rebuild base images (DSS design prod)

Run as `dss` from the data directory. Build the standard base images without R:

```bash
sudo -iu dss
cd /data/dataiku/dss_data
for image_type in container-exec spark api-deployer cde; do
	./bin/dssadmin build-base-image --type "${image_type}" --without-r
done

# Container execution image with additional Python versions
./bin/dssadmin build-base-image --type container-exec --without-r \
	--with-py310 --with-py311 --with-py312
```

Build the MOHRE-specific images. The API Deployer image embeds the Oracle
Instant Client and is pushed to Harbor:

```bash
./bin/dssadmin build-base-image --type api-deployer --without-r --with-py311 \
	--copy-to-buildenv /home/dss/oracle-instantclient-basic-23.8.0.25.04-1.el9.x86_64.rpm oracle-instantclient-basic-23.8.0.25.04-1.el9.x86_64.rpm \
	--dockerfile-prepend /home/dss/docker-pretend.txt \
	--target-registry harbor.mohre.gov.ae/lmis_dataiku
```

The container execution image embeds GEOS and the host Java crypto policy
(`java.config`, required to fix SQL Server connectivity), and is built and
pushed to Harbor:

```bash
./bin/dssadmin build-base-image --type container-exec --without-r --with-py311 \
	--copy-to-buildenv /home/dss/geos-devel-3.13.1-1.el9.x86_64.rpm geos-devel-3.13.1-1.el9.x86_64.rpm \
	--dockerfile-prepend /home/dss/docker-pretend.txt.1

./bin/dssadmin build-base-image --type container-exec --mode build-push \
	--target-registry harbor.mohre.gov.ae/lmis_dataiku --without-r --with-py311 \
	--copy-to-buildenv /etc/crypto-policies/back-ends/java.config java.config \
	--dockerfile-prepend /home/dss/docker-pretend.txt.sql_server_issue
```

Alternatively, to use the Dataiku-provided prebuilt base images instead of
building them locally, use `--mode use`:

```bash
for image_type in container-exec spark cde api-deployer; do
	./bin/dssadmin build-base-image --type "${image_type}" --mode use
done
```

[`3-post-upgrade-1/tasks.sh`](3-post-upgrade-1/tasks.sh) lists every variant
that was run, including intermediate builds. Confirm with the platform
administrator which image variants are required before running them.

### 4. Start DSS and rebuild runtime artifacts

```bash
export DATA_DIR=/data/dataiku/dss_data

sudo -iu dss "${DATA_DIR}/bin/dss" start
sudo -iu dss "${DATA_DIR}/bin/dssadmin" build-container-exec-code-env-images --all
sudo -iu dss "${DATA_DIR}/bin/dsscli" code-studio-templates-build
```

Then validate the DSS URL, projects, connections (including Oracle and SQL
Server), user isolation, scenarios, code environments, containerized execution,
Spark, API Deployer, and any Kubernetes deployments. Data scientists must
retrain and validate machine-learning models as required by the upgrade process.

In **Administration > Settings > Containerized execution > Container image
build**, verify whether **Enable automatic rebuild** should be enabled for this
environment.

## Rollback and recovery

Do not delete `/data/dataiku/dss_data_backup_<date>` or the PostgreSQL dump until the
validation period is complete. If the upgrade must be rolled back, stop DSS,
follow the organization's tested DSS rollback procedure using the data
directory backup and PostgreSQL dump, and involve the platform/database
administrator. The backup commands here are safeguards, not a complete tested
rollback procedure.

## Notes about the task scripts

The `tasks.sh` files are reference snippets rather than fully unattended
scripts. Run them phase by phase and verify each command. In particular, shell
assignments must use `NAME=value` (without spaces), and `sudo su dss`
opens a subshell; it does not change the user of subsequent commands in the
parent shell. The commands in this README use explicit `sudo -iu` invocation to
make the execution user clear.
# mohre-upgrade-assistant

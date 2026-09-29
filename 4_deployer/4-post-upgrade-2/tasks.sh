DATA_DIR=/data/dataiku/dss_data
DSS_VERSION=15.0.2

# Start DSS
${DATA_DIR}/bin/dss start

## Rebuild code envs
# Code environments disabled for this node.
# ${DATA_DIR}/bin/dssadmin build-container-exec-code-env-images --all

## Rebuild code studio templates
# Code studio templates disabled for this node.
# ${DATA_DIR}/bin/dsscli code-studio-templates-build

## Retrain machine learning models
## to be done by data scientists.

## Automatic image rebuild
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type container-exec --without-r
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type api-deployer --without-r
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type spark --without-r
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type cde --without-r

Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type api-deployer --without-r --with-py311
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type api-deployer --without-r --with-py311 --copy-to-buildenv /home/dss/oracle-instantclient-basic-23.8.0.25.04-1.el9.x86_64.rpm oracle-instantclient-basic-23.8.0.25.04-1.el9.x86_64.rpm --dockerfile-prepend /home/dss/docker-pretend.txt

Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type container-exec --mode use
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type spark --mode use
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type cde --mode use
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type api-deployer --mode use

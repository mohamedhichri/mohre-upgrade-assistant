# Post-upgrade tasks (before startup)
DATA_DIR=/data/dataiku/dss_data
DSS_VERSION=15.0.2

## Update R installation
${DATA_DIR}/bin/dssadmin install-R-integration

## Reinstall graphics exports
${DATA_DIR}/bin/dssadmin install-graphics-export

## Reinstall standalone Hadoop and Spark
${DATA_DIR}/bin/dssadmin install-hadoop-integration -standaloneArchive /data/dataiku-dss-hadoop-standalone-libs-generic-hadoop3-${DSS_VERSION}.tar.gz
${DATA_DIR}/bin/dssadmin install-spark-integration -standaloneArchive /data/dataiku-dss-spark-standalone-${DSS_VERSION}-4.1.2-generic-hadoop3.tar.gz -forK8S

## UIF (as root)
sudo su -
./bin/dssadmin install-impersonation dss
# check config /etc/dataiku-security/INSTALL_ID/security-config.ini

## Rebuild base images
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type container-exec --mode use
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type spark --mode use
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type cde --mode use
Command line: /data/dataiku/dss_data/bin/dssadmin build-base-image --type api-deployer --mode use
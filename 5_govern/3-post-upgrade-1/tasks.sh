# Post-upgrade tasks (before startup)
DATA_DIR=/data/dataiku/dss_data
DSS_VERSION=15.0.2

## Update R installation
# R integration not applicable to this node.
# ${DATA_DIR}/bin/dssadmin install-R-integration

## Reinstall graphics exports
# Graphics export not applicable to this node.
# ${DATA_DIR}/bin/dssadmin install-graphics-export

## Reinstall standalone Hadoop and Spark
# Hadoop integration not applicable to this node.
# ${DATA_DIR}/bin/dssadmin install-hadoop-integration -standaloneArchive /data/dataiku-dss-hadoop-standalone-libs-generic-hadoop3-${DSS_VERSION}.tar.gz
# Spark integration not applicable to this node.
# ${DATA_DIR}/bin/dssadmin install-spark-integration -standaloneArchive /data/dataiku-dss-spark-standalone-${DSS_VERSION}-4.1.2-generic-hadoop3.tar.gz -forK8S

## UIF (as root)
# UIF not applicable to this node.
# sudo su -
# ./bin/dssadmin install-impersonation dss
# check config /etc/dataiku-security/INSTALL_ID/security-config.ini

## Rebuild base images
# Base-image commands are specific to the design (prd) reference node; not applicable to this node.

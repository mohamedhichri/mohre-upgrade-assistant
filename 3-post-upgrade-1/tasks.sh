# Post-upgrade tasks (before startup)
DATA_DIR = /data/data_dir
DSS_VERSION=15.0.1

## Update R installation
${DATA_DIR}/bin/dssadmin install-R-integration

## Reinstall graphics exports
${DATA_DIR}/bin/dssadmin install-graphics-export

## Reinstall standalone Hadoop and Spark
${DATA_DIR}/bin/dssadmin install-hadoop-integration -standalone generic-hadoop3 -standaloneArchive /data/dataiku-dss-hadoop-standalone-libs-generic-hadoop3-${DSS_VERSION}.tar.gz

${DATA_DIR}/bin/dssadmin install-spark-integration -standaloneArchive /data/dataiku-dss-spark-standalone-${DSS_VERSION}-4.1.2-generic-hadoop3.tar.gz -forK8S

## Rebuild base images
${DATA_DIR}/bin/dssadmin build-base-image --type container-exec
${DATA_DIR}/bin/dssadmin build-base-image --type spark
${DATA_DIR}/bin/dssadmin build-base-image --type cde
${DATA_DIR}/bin/dssadmin build-base-image --type api-deployer

# Post-upgrade tasks (before startup)
DATA_DIR=/data/data_dir
DSS_VERSION=15.0.2

## Update R installation
${DATA_DIR}/bin/dssadmin install-R-integration

## Reinstall graphics exports
${DATA_DIR}/bin/dssadmin install-graphics-export

## Reinstall standalone Hadoop and Spark
${DATA_DIR}/bin/dssadmin install-hadoop-integration -standaloneArchive /data/dataiku-dss-hadoop-standalone-libs-generic-hadoop3-${DSS_VERSION}.tar.gz

${DATA_DIR}/bin/dssadmin install-spark-integration -standaloneArchive /data/dataiku-dss-spark-standalone-${DSS_VERSION}-4.1.2-generic-hadoop3.tar.gz -forK8S

## Rebuild base images
cd ${DATA_DIR}
# built image locally and then transfered to customer 
# ./bin/dssadmin build-base-image --type container-exec --without-r --with-py36 --with-py39 --with-py311  --with-py312   --with-py313  --without-cuda
# docker save dku-apideployer-apinode-base:dss-15.0.2 | gzip > dku-apideployer-apinode-base-15.0.2.tar.gz

# TMPDIR=/mnt/data/tmp docker load -i /path/to/dku-apideployer-apinode-base-15.0.2.tar.gz
/data/data_dir/bin/dssadmin build-base-image --type container-exec --mode use --with-py39 --without-py37 --without-r --source-image dataiku-dss-container-exec-base:dss-13.1.4-almalinux8-r4-py3.9

# ./bin/dssadmin build-base-image --type spark --without-r --with-py36 --with-py39 --with-py311  --with-py312   --with-py313  --without-cuda
/data/data_dir/bin/dssadmin build-base-image --type spark --mode use --with-py311  --with-py312 --without-py37 --without-r --source-image dataiku-dss-spark-exec-base:dss-13.1.4-almalinux8-r4-py3.9

# ./bin/dssadmin build-base-image --type cde --without-r --with-py36 --with-py39 --with-py311  --with-py312   --with-py313  --without-cuda
/data/data_dir/bin/dssadmin build-base-image --type cde --mode use --with-py39 --with-py311  --with-py312  --without-py37 --without-r --source-image dataiku-dss-cde-base:dss-13.1.4-almalinux8-r4-py3.9

# ./bin/dssadmin build-base-image --type api-deployer --without-r --with-py36 --with-py39 --with-py311  --with-py312   --with-py313  --without-cuda
/data/data_dir/bin/dssadmin build-base-image --type api-deployer --mode use --with-py39 --with-py311  --with-py312  --without-py37 --without-r --source-image dataiku-dss-apideployer-base:dss-13.1.4-almalinux8-r4-py3.9
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
#check config /etc/dataiku-security/INSTALL_ID/security-config.ini

## Rebuild base images
## on DSS design prod
cd ${DATA_DIR}
/data/dataiku/dss_data/bin/dssadmin build-base-image --type container-exec --without-r
/data/dataiku/dss_data/bin/dssadmin build-base-image --type spark --without-r
/data/dataiku/dss_data/bin/dssadmin build-base-image --type api-deployer --without-r
/data/dataiku/dss_data/bin/dssadmin build-base-image --type cde --without-r

/data/dataiku/dss_data/bin/dssadmin build-base-image --type container-exec --without-r --with-py310 --with-py311 --with-py312

/data/dataiku/dss_data/bin/dssadmin build-base-image --type api-deployer --without-r --with-py311 --copy-to-buildenv /home/dss/oracle-instantclient-basic-23.8.0.25.04-1.el9.x86_64.rpm oracle-instantclient-basic-23.8.0.25.04-1.el9.x86_64.rpm --dockerfile-prepend /home/dss/docker-pretend.txt
/data/dataiku/dss_data/bin/dssadmin build-base-image --type api-deployer --without-r --with-py311

/data/dataiku/dss_data/bin/dssadmin build-base-image --type container-exec --mode use
/data/dataiku/dss_data/bin/dssadmin build-base-image --type spark --mode use
/data/dataiku/dss_data/bin/dssadmin build-base-image --type cde --mode use
/data/dataiku/dss_data/bin/dssadmin build-base-image --type api-deployer --mode use

/data/dataiku/dss_data/bin/dssadmin build-base-image --type api-deployer --without-r --with-py311 --copy-to-buildenv /home/dss/oracle-instantclient-basic-23.8.0.25.04-1.el9.x86_64.rpm oracle-instantclient-basic-23.8.0.25.04-1.el9.x86_64.rpm --dockerfile-prepend /home/dss/docker-pretend.txt --target-registry harbor.mohre.gov.ae/lmis_dataiku

/data/dataiku/dss_data/bin/dssadmin build-base-image --type container-exec --without-r --with-py311 --copy-to-buildenv /home/dss/geos-devel-3.13.1-1.el9.x86_64.rpm geos-devel-3.13.1-1.el9.x86_64.rpm --dockerfile-prepend /home/dss/docker-pretend.txt.1
/data/dataiku/dss_data/bin/dssadmin build-base-image --type container-exec --without-r --with-py311 --copy-to-buildenv /etc/crypto-policies/back-ends/java.config java.config --dockerfile-prepend /home/dss/docker-pretend.txt.sql_server_issue
/data/dataiku/dss_data/bin/dssadmin build-base-image --type container-exec --mode build-push --target-registry harbor.mohre.gov.ae/lmis_dataiku --without-r --with-py311 --copy-to-buildenv /etc/crypto-policies/back-ends/java.config java.config --dockerfile-prepend /home/dss/docker-pretend.txt.sql_server_issue

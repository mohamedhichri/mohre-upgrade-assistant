DSS_VERSION=15.0.2
DATA_DIR=/data/dataiku/dss_data

sudo su dss
cd /data
tar xzf dataiku-dss-${DSS_VERSION}.tar.gz
dataiku-dss-${DSS_VERSION}/installer.sh -d ${DATA_DIR} -u

# might fail and ask to run the below command :
# sudo -i "/home/dataiku/dataiku-dss-${DSS_VERSION}/scripts/install/install-deps.sh"

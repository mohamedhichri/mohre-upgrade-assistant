DSS_VERSION=15.0.2
DATA_DIR=/data/data_dir

sudo su dss

cd /data

tar xzf dataiku-dss-${DSS_VERSION}.tar.gz

JAVA_HOME=/usr/lib/jvm/java-17-openjdk-17.0.20.0.8-1.1.el8.x86_64 dataiku-dss-${DSS_VERSION}/installer.sh -d ${DATA_DIR} -u

# might fail and ask to run the below command : 
# sudo -i "/home/dataiku/dataiku-dss-${DSS_VERSION}/scripts/install/install-deps.sh"
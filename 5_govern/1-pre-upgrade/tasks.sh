# download the new version of DSS and the required libraries
DSS_VERSION=15.0.2
sudo su dss

cd /data
wget https://downloads.dataiku.com/public/studio/{DSS_VERSION}/dataiku-dss-{DSS_VERSION}.tar.gz
# Hadoop integration not applicable to this node.
# wget https://downloads.dataiku.com/public/studio/{DSS_VERSION}/dataiku-dss-hadoop-standalone-libs-generic-hadoop3-{DSS_VERSION}.tar.gz
# Spark integration not applicable to this node.
# wget https://downloads.dataiku.com/public/studio/{DSS_VERSION}/dataiku-dss-spark-standalone-{DSS_VERSION}-4.1.2-generic-hadoop3.tar.gz

# stop dataiku
sudo su dss
cd /data/dataiku/dss_data
./bin/dss stop

# backup data directory and runtime db
cd /data/dataiku/dss_data
cp -r /data/dataiku/dss_data /data/dataiku/dss_data_backup_$(date +%F)

# optional : backup runtime db
sudo su
su - postgres
pg_dumpall > /data/postgresql-dump-$(date +%F).sql

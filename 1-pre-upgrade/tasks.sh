# download the new version of DSS and the required libraries
DSS_VERSION=15.0.1
sudo su dataiku_user

cd /data

wget https://downloads.dataiku.com/public/studio/{DSS_VERSION}/dataiku-dss-{DSS_VERSION}.tar.gz

wget https://downloads.dataiku.com/public/studio/{DSS_VERSION}/dataiku-dss-hadoop-standalone-libs-generic-hadoop3-{DSS_VERSION}.tar.gz

wget https://downloads.dataiku.com/public/studio/{DSS_VERSION}/dataiku-dss-spark-standalone-{DSS_VERSION}-4.1.2-generic-hadoop3.tar.gz

# stop dataiku
sudo su dataiku_user

cd /data/data_dir

./bin/dss stop

# backup data directory and runtime db
cd /data/data_dir

cp -r /data/data_dir /data/data_dir_backup_$(date +%F)

# optional : backup runtime db
sudo su
su - postgres
pg_dumpall > /data/postgresql-dump-$(date +%F).sql
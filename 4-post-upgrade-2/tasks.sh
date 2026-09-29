DATA_DIR = /data/data_dir
DSS_VERSION=15.0.2

# Start DSS
${DATA_DIR}/bin/dss start

## Rebuild code envs
${DATA_DIR}/bin/dssadmin build-container-exec-code-env-images --all

## Rebuild code studio templates
${DATA_DIR}/bin/dsscli code-studio-templates-build

## Retrain machine learning models
## to be done by data scientists.

## Automatic image rebuild
## check Administration > Settings > Containerized execution > Container image build > Enable automatic rebuild.
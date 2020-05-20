# Docker Kibana to S3 Backup

## How to use
The container is configured via a set of environment variables:
- AWS_ACCESS_KEY: Get this from amazon IAM
- AWS_SECRET_ACCESS_KEY: Get this from amazon IAM, **you should keep this a secret**
- S3_BUCKET_URL: in most cases this should be s3://name-of-your-bucket/
- AWS_DEFAULT_REGION: The AWS region your bucket resides in
- CRON_SCHEDULE: Check out [crontab.guru](https://crontab.guru/) for some examples. **Do not wrap this value in quotes**
- BACKUP_NAME: A name to identify your backup among the other files in your bucket, it will be postfixed with the current timestamp (date and time)
- KIBANA_SCHEME: The scheme to use to connect to Kibana (i.e. 'http' or 'https')
- KIBANA_HOST: The host where the Kibana instance resides
- KIBANA_PORT: The port that Kibana listens on
- KIBANA_USER: A Kibana user with sufficient privileges to read any saved objects
- KIBANA_PASSWORD: The password for said user
- KIBANA_VERSION: The Kibana version string used in the `kbn-version` header, e.g. `7.2.0`
- TZ: The timezone to be used inside the container

All environment variables prefixed with 'AWS_' are directly used by [awscli](https://aws.amazon.com/cli/) that this image heavily relies on.

```
# docker-compose.yml
version: '3.7'

services:
  kibana-backup:
    image: brathis/kibana-s3-backup
    environment:
      - AWS_ACCESS_KEY_ID=SOME8AWS3ACCESS9KEY
      - AWS_SECRET_ACCESS_KEY=sUp3rS3cr3tK3y0fgr34ts3cr3cy
      - S3_BUCKET_URL=s3://name-of-your-bucket/
      - AWS_DEFAULT_REGION=eu-central-1
      - CRON_SCHEDULE=0 15 * * *
      - BACKUP_NAME=kibana
      - KIBANA_SCHEME=http
      - KIBANA_HOST=localhost
      - KIBANA_PORT=5601
      - KIBANA_USER=kibana-backup-user
      - KIBANA_PASSWORD=sEcReTkIbAnApAsSw0rD
      - KIBANA_VERSION=7.2.0
      - TZ=Europe/Zurich
    restart: always
```

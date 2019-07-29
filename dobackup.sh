#!/bin/sh
echo "creating Kibana backup"
curl -XGET "http://$KIBANA_HOST:$KIBANA_PORT/api/saved_objects/_find?per_page=200&page=1&type=index-pattern&type=visualization&type=dashboard&type=search&sort_field=type" \
    -H 'Accept: application/json' \
    -H "kbn-version: $KIBANA_VERSION" \
    -u $KIBANA_USER:$KIBANA_PASSWORD | jq '.saved_objects' | jq 'del(.[].updated_at)' | jq -c 'sort_by(.type, .id)' | jq . > /tmp/kibana-bulk-export-saved-objects.json
echo "creating archive"
tar -zcvf /tmp/$BACKUP_NAME-`date "+%Y-%m-%d_%H-%M-%S"`.tar.gz /tmp/*.json
echo "uploading archive to S3"
aws s3 cp /tmp/*.tar.gz $S3_BUCKET_URL
echo "removing local archive"
rm /tmp/*.tar.gz
echo "done"

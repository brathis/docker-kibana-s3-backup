#!/bin/sh
echo "creating Kibana backup"

if [[ -z $KIBANA_SPACES ]]; then
  KIBANA_SPACES="default"
fi

IFS=',' read -a SPACES <<<"$KIBANA_SPACES"
for SPACE in "${SPACES[@]}"; do
  echo "exporting space '$SPACE'"

  # https://www.elastic.co/guide/en/kibana/master/saved-objects-api-find.html
  if [[ "$SPACE" == "default" ]]; then
    URL="$KIBANA_SCHEME://$KIBANA_HOST:$KIBANA_PORT/api/saved_objects/_find?per_page=200&page=1&type=index-pattern&type=visualization&type=dashboard&type=search&sort_field=type"
  else
    URL="$KIBANA_SCHEME://$KIBANA_HOST:$KIBANA_PORT/s/$SPACE/api/saved_objects/_find?per_page=200&page=1&type=index-pattern&type=visualization&type=dashboard&type=search&sort_field=type"
  fi

  echo "requesting URL $URL"

  curl -XGET "$URL" \
  -H 'Accept: application/json' \
  -H "kbn-version: $KIBANA_VERSION" \
  -u $KIBANA_USER:$KIBANA_PASSWORD | jq '.saved_objects' | jq 'del(.[].updated_at)' | jq -c 'sort_by(.type, .id)' | jq . >"/tmp/kibana-bulk-export-saved-objects--${SPACE}.json"
done

echo "creating archive"
tar -zcvf /tmp/$BACKUP_NAME-$(date "+%Y-%m-%d_%H-%M-%S").tar.gz /tmp/*.json

echo "uploading archive to S3"
aws s3 cp /tmp/*.tar.gz $S3_BUCKET_URL

echo "cleaning up"
rm /tmp/*.json
rm /tmp/*.tar.gz

echo "done"

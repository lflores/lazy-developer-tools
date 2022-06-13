#!/bin/bash
ENVIRONMENT="POC"
LIGHT_GREEN='\033[1;32m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

compare_environment_data() {
    echo -e "Comparing ${GREEN}BCPR-$1-$3${NC} with ${GREEN}BCPR-$2-$3${NC}" 

    TABLE_ORIGIN=$(aws dynamodb scan --table-name BCPR-$1-$3)
    TABLE_DESTINATION=$(aws dynamodb scan --table-name BCPR-$2-$3)

    JSON_ORIGIN=$(jq -r '.Items' <<<$TABLE_ORIGIN)
    JSON_DESTINATION=$(jq -r '.Items' <<<$TABLE_DESTINATION)

    diff <(jq --sort-keys . <<<$JSON_ORIGIN) <(jq --sort-keys . <<<$JSON_DESTINATION)

    #compare_json_data $JSON_ORIGIN $JSON_DESTINATION
}

compare_json_data() {
    diff <(jq --sort-keys . <<<$1) <(jq --sort-keys . <<<$2)
}

if [[ -n $3 ]]; then
   TABLES=$(cat tables-data.json | jq -c ".[] | select( .name | contains(\"$3\"))")
    #echo $USER
    compare_environment_data \
        $1 \
        $2 \
        $3
    exit 0
fi

TABLES=$(cat tables-data.json | jq -c -r '.[]')

for TABLE in $TABLES; do
  compare_environment_data \
    $1 \
    $2 \
    $(jq -r '.name' <<<$TABLE)
done

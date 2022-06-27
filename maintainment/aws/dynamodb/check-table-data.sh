#!/bin/bash
ENVIRONMENT="POC"
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

compare_environment_data() {
    TABLE_ORIGIN=$(aws dynamodb scan --table-name BCPR-$1-$3)
    TABLE_DESTINATION=$(aws dynamodb scan --table-name BCPR-$2-$3)

    JSON_ORIGIN=$(jq -r '.Items' <<<$TABLE_ORIGIN)
    JSON_DESTINATION=$(jq -r '.Items' <<<$TABLE_DESTINATION)

    DIFF=$(diff <(jq --sort-keys . <<<$JSON_ORIGIN) <(jq --sort-keys . <<<$JSON_DESTINATION))
    if [ "$DIFF" != "" ]; then
        echo -e "${YELLOW}BCPR-$1-$3 and BCPR-$2-$3 are distinct ${NC}"
        echo -e "${YELLOW}$DIFF${NC}"
    else
        echo -e "${LIGHT_GREEN}BCPR-$1-$3 and BCPR-$2-$3 are equals ${NC}"
    fi
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

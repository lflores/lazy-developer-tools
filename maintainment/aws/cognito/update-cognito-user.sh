#!/bin/bash
ENV=""

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

REGION="us-east-1"
if [ $# -eq 0 ]; then
  echo "You must to provide the environment as first parameter such as POC, DEV or TST values and optional username"
  exit 1
else
  ENV="$1"
fi

update_user() {

  #SECRET_HASH="$(python3 secret_hash.py $1 $3 $4)"

  #echo -e "\n${GREEN}Secret Hash \"$1\":${NC} ${LIGHT_GREEN}$SECRET_HASH${NC}"
  lastName=$(jq -r '.lastname' <<<$1)
  name=$(jq -r '.name' <<<$1)
  customerId=$(jq -r '.ssn' <<<$1)
  customerType=$(jq -r '.customerType' <<<$1)
  echo "$customerType"

  aws cognito-idp admin-update-user-attributes \
    --user-pool-id $(jq -r '.USERPOOL_ID' <<<$2) \
    --username $(jq -r '.username' <<<$1) \
    --user-attributes Name="family_name",Value="$lastName" Name="given_name",Value="$name" Name="custom:customerType",Value="$customerType" 
}

$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:ecs")).ResourceARN' <<<"$RESOURCES")

ENVIRONMENT=$(cat environment-data.json | jq -c ".[] | select( .environment | contains(\"$ENV\"))")
echo $ENVIRONMENT

if [[ -n $2 ]]; then
  USER=$(cat users-data.json | jq -c ".[] | select( .username | contains(\"$2\"))")
  echo $USER
  update_user \
    $USER \
    $ENVIRONMENT
  exit 0
fi

# Get users from file
USERS=$(cat users-data.json | jq -c -r '.[]')
for USER in $USERS; do
  update_user \
    $USER \
    $ENVIRONMENT
done

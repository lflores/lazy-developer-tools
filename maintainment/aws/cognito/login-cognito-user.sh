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

login_user() {

  SECRET_HASH="$(python3 secret_hash.py $1 $3 $4)"

  echo -e "\n${GREEN}Secret Hash \"$1\":${NC} ${LIGHT_GREEN}$SECRET_HASH${NC}"

  aws cognito-idp initiate-auth \
    --auth-flow USER_PASSWORD_AUTH \
    --auth-parameters USERNAME=$1,PASSWORD=$2 \
    --client-id $3
}
$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:ecs")).ResourceARN' <<<"$RESOURCES")

ENVIRONMENT=$(cat environment-data.json | jq -c ".[] | select( .environment | contains(\"$ENV\"))")
echo $ENVIRONMENT

if [[ -n $2 ]]; then
  USER=$(cat users-data.json | jq -c ".[] | select( .username | contains(\"$2\"))")
  echo $USER
  login_user \
    $(jq -r '.username' <<<$USER) \
    $(jq -r '.password' <<<$USER) \
    $(jq -r '.APP_CLIENT_ID' <<<$ENVIRONMENT) \
    $(jq -r '.APP_CLIENT_SECRET' <<<$ENVIRONMENT)
  exit 0
fi

# Get users from file
USERS=$(cat users-data.json | jq -c -r '.[]')

for USER in $USERS; do
  login_user \
    $(jq -r '.username' <<<$USER) \
    $(jq -r '.password' <<<$USER) \
    $(jq -r '.APP_CLIENT_ID' <<<$ENVIRONMENT) \
    $(jq -r '.APP_CLIENT_SECRET' <<<$ENVIRONMENT)
done

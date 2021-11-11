#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

# ==============
# Delete user from params
# ==============

delete_user() {
  echo -e "${GREEN}Deleting User${NC} user ${LIGHT_GREEN}$(jq -r '.username' <<<$1) ${NC}"
  aws cognito-idp admin-delete-user \
    --user-pool-id $(jq -r '.USERPOOL_ID' <<<$2) \
    --username $(jq -r '.username' <<<$1)
}

log_environment_data() {
  echo -e "Region:${LIGHT_GREEN}$(jq -r '.REGION' <<<$1)${NC}"
  echo -e "UserPoolId:${LIGHT_GREEN}$(jq -r '.USERPOOL_ID' <<<$1)${NC}"
  echo -e "ClientId:${LIGHT_GREEN}$(jq -r '.APP_CLIENT_ID' <<<$1)${NC}"
  echo -e "ClientSecret:${LIGHT_GREEN}$(jq -r '.APP_CLIENT_SECRET' <<<$1)${NC}\n\n"
}

# Load environment configuration
ENV=""

if [ $# -eq 0 ]
  then
    echo "You must to provide the environment as first parameter such as POC, DEV or TST values"
    exit 1
  else 
    ENV="$1"  
fi

# Get Environment Config
ENVIRONMENT=$(cat environment-data.json | jq -c ".[] | select( .environment | contains(\"$ENV\"))")
log_environment_data $ENVIRONMENT

# Get users from file
USERS=$(cat users-data.json | jq -c -r '.[]')

if [[ -n $2 ]]; then
  USER=$(cat users-data.json | jq -c ".[] | select( .username | contains(\"$2\"))")
  echo $USER
  delete_user \
    $USER \
    $ENVIRONMENT
  exit 0
fi

for USER in $USERS; do
  delete_user \
    $USER \
    $ENVIRONMENT
done

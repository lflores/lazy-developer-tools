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
# Create user from params
# ==============
create_user() {
  #SECRET_HASH="$(python3 secret_hash.py $USERNAME $APP_CLIENT_ID $APP_CLIENT_SECRET)";
  #SECRET_HASH="$(python3 secret_hash.py $(jq -r '.username' <<<$1) $(jq -r '.APP_CLIENT_ID' <<<$2) $(jq -r '.APP_CLIENT_SECRET' <<<$2))"
  #echo $SECRET_HASH

  aws cognito-idp sign-up \
    --region $(jq -r '.REGION' <<<$2) \
    --client-id $(jq -r '.APP_CLIENT_ID' <<<$2) \
    --username $(jq -r '.username' <<<$1) \
    --password $(jq -r '.password' <<<$1) \
    --user-attributes \
    Name="given_name",Value="$(jq -r '.name' <<<$1)" \
    Name="family_name",Value="$(jq -r '.lastname' <<<$1)" \
    Name="phone_number",Value="$(jq -r '.phone' <<<$1)" \
    Name="email",Value="$(jq -r '.email' <<<$1)" \
    Name="custom:ssn",Value="$(jq -r '.ssn' <<<$1)" \
    Name="custom:customerType",Value="$(jq -r '.customerType' <<<$1)"
}

#--secret-hash $SECRET_HASH \

# ==============
# Confirm user by username
# ==============
confirm_signup() {
  echo -e "${GREEN}Confirming${NC}${LIGHT_GREEN} $(jq -r '.username' <<<$1)${NC}"
  aws cognito-idp admin-confirm-sign-up \
    --region $(jq -r '.REGION' <<<$2) \
    --user-pool-id $(jq -r '.USERPOOL_ID' <<<$2) \
    --username $(jq -r '.username' <<<$1)
}

assign_group() {
  echo -e "${GREEN}Assign group${NC} ${LIGHT_GREEN}$(jq -r '.group' <<<$1)${NC} to user ${LIGHT_GREEN}$(jq -r '.username' <<<$1) ${NC}"
  aws cognito-idp admin-add-user-to-group \
    --user-pool-id $(jq -r '.USERPOOL_ID' <<<$2) \
    --username $(jq -r '.username' <<<$1) \
    --group-name $(jq -r '.group' <<<$1)
}

enable_user() {
  echo -e "${GREEN}Enable user${NC} ${LIGHT_GREEN}$(jq -r '.username' <<<$1)${NC}"
  aws cognito-idp admin-enable-user \
    --user-pool-id $(jq -r '.USERPOOL_ID' <<<$2) \
    --username $(jq -r '.username' <<<$1)
}

enable_phone_email_settings() {
  echo -e "${GREEN}Enable Phone verification for user ${NC} ${LIGHT_GREEN}$(jq -r '.username' <<<$1)${NC}"
  aws cognito-idp admin-update-user-attributes \
    --user-pool-id $(jq -r '.USERPOOL_ID' <<<$2) \
    --username $(jq -r '.username' <<<$1) \
    --user-attributes Name="email_verified",Value="false" Name="phone_number_verified",Value="true"
}

log_environment_data() {
  echo -e "Region:${LIGHT_GREEN}$(jq -r '.REGION' <<<$1)${NC}"
  echo -e "UserPoolId:${LIGHT_GREEN}$(jq -r '.USERPOOL_ID' <<<$1)${NC}"
  echo -e "ClientId:${LIGHT_GREEN}$(jq -r '.APP_CLIENT_ID' <<<$1)${NC}"
  #echo -e "ClientSecret:${LIGHT_GREEN}$(jq -r '.APP_CLIENT_SECRET' <<<$1)${NC}\n\n"
}

# Load environment configuration
ENV=""

if [ $# -eq 0 ]; then
  echo "You must to provide the environment as first parameter such as POC, DEV or TST values"
  exit 1
else
  ENV="$1"
fi

# Get Environment Config
ENVIRONMENT=$(cat environment-data.json | jq -c ".[] | select( .environment | contains(\"$ENV\"))")
log_environment_data $ENVIRONMENT

# Get users from file
USERS=$(cat users-data-uat.json | jq -c -r '.[]')

if [[ -n $2 ]]; then
  USER=$(cat users-data-uat.json | jq -c ".[] | select( .username | contains(\"$2\"))")
  echo $USER
  create_user \
    $USER \
    $ENVIRONMENT

  confirm_signup \
    $USER \
    $ENVIRONMENT
  assign_group \
    $USER \
    $ENVIRONMENT

  enable_user \
    $USER \
    $ENVIRONMENT

  enable_phone_email_settings \
    $USER \
    $ENVIRONMENT
  exit 0
fi

for USER in $USERS; do
  create_user \
    $USER \
    $ENVIRONMENT

  confirm_signup \
    $USER \
    $ENVIRONMENT
  assign_group \
    $USER \
    $ENVIRONMENT

  enable_user \
    $USER \
    $ENVIRONMENT

  enable_phone_email_settings \
    $USER \
    $ENVIRONMENT
done

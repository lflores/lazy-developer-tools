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
  echo "You must to provide the cooperatives file path"
  exit 1
else
  ENV="$1"
fi

# Get users from file
# COOPERATIVES=$(cat $1 | jq -c -r '.[]')
# for COOPERATIVE in $COOPERATIVES; do
# echo $COOPERATIVE
# $(jq -r '.institutionId' <<<$COOPERATIVE)
# done
# CREATE TABLE IF NOT EXISTS systemConfiguration.cooperatives(
#     id INT NOT NULL AUTO_INCREMENT,
#     organization INT NOT NULL UNIQUE,
#     cooperative VARCHAR(100) NOT NULL,
#     phone_number VARCHAR(100) NOT NULL,
#     postal_address VARCHAR(150) NOT NULL,
#     physical_address VARCHAR(150) NOT NULL,
#     officer_email VARCHAR(150) NOT NULL,
#     is_active BOOLEAN
#     PRIMARY KEY (id)
# );

cat $1 | awk -F';' '{ printf "INSERT INTO systemConfiguration.cooperatives (organization,cooperative,phone_number,postal_address,physical_address,officer_email,is_active) VALUES (%d,\x27%s\x27,\x27%s\x27,\x27%s\x27,\x27%s\x27,\x27%s\x27",$1,$2,$3,$4,$5,$6;print ",true);"}'
#!/bin/bash

# ========================
# By Triad for Cooperativo Team
# Version 1.1
# ========================
FILENAME_ARN_MFA=".arn-mfa"
DEFAULT_FILENAME_ARN_MFA=".arn-mfa"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color


# =======================================
# get file name concatenating with profile
# =======================================
get_file_name() {
    # if the profile is void
    if [ -z "$profile" ]; then
        FILENAME_ARN_MFA="$DEFAULT_FILENAME_ARN_MFA"        
    else
        FILENAME_ARN_MFA="$DEFAULT_FILENAME_ARN_MFA-$profile"        
    fi
}

# =======================================
# function to read the arn-mfa from file
# =======================================
read_arn_mfa_from_file() {
    while IFS= read -r line; do
        # echo "$line"
        ARN_MFA_VIRTUAL=$line
    done <"$FILENAME_ARN_MFA"
}

# =============================================
# function that automatically check .gitignore
# =============================================
update_arn_mfa_gitignore() {
    is_in_ignore=$(cat .gitignore | grep $DEFAULT_FILENAME_ARN_MFA)
    if [ -z "$is_in_ignore" ]; then
        echo "The file $FILENAME_ARN_MFA is not in .gitignore, I'll add it"
        command echo $DEFAULT_FILENAME_ARN_MFA\* >>.gitignore
    else
        echo "The file $FILENAME_ARN_MFA is in .gitignore"
    fi
}

# =============================================
# function that write arn to file
# =============================================
write_arn_mfa() {
    echo $1 >>$FILENAME_ARN_MFA
}

#check if aws command exists
has_aws=$(aws help)
if [ $? -ne 0 ]; then
    echo -e "${LIGHT_RED}'aws cli' tool is required please install using 'sudo apt install awscli'${NC}\n${YELLOW}Or follow next url for more info https://docs.aws.amazon.com/cli/latest/userguide/install-linux-al2017.html${NC}"
    exit
fi

#check if jq command exists
has_jq=$(jq --help)
if [ $? -ne 0 ]; then
    echo -e "${LIGHT_RED}'jq' tool is required please install using 'sudo apt install jq'${NC}"
    exit
fi

# Based on documentation of https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

#Build profile parameter
echo -e "${YELLOW}Please enter aws profile (aws configure [profile]). Void to ignore it${NC}"
read profile

# Configure your own MFA ARN Virtual
# Read arn_mfa from file
ARN_MFA_VIRTUAL=""
get_file_name
if [ -f "$FILENAME_ARN_MFA" ]; then
    read_arn_mfa_from_file
    echo -e "\n${YELLOW}Loading arn from $FILENAME_ARN_MFA${NC}"
fi
# Check if the ARN is empty
if [ -z "$ARN_MFA_VIRTUAL" ]; then
    echo -e "\n${RED}ARN_MFA_VIRTUAL is empty${NC}"
    echo -e "\n${YELLOW}Please insert ARN_MFA_VIRTUAL${NC}"
    read ARN_MFA_VIRTUAL
    write_arn_mfa $ARN_MFA_VIRTUAL
    update_arn_mfa_gitignore
fi
echo -e "\n${LIGHT_GREEN}ARN_MFA_VIRTUAL is $ARN_MFA_VIRTUAL${NC}"

#Put the MFA Token
echo -e "\n${YELLOW}Enter the MFA token:${NC}"
read MFA_TOKEN

if [ -n "$profile" ]; then
    echo -e "\n${YELLOW}Running command:\n${NC}${LIGHT_GREEN}aws sts --profile $profile get-session-token --serial-number $ARN_MFA_VIRTUAL --token-code $MFA_TOKEN${NC}"
    credentials=$(aws sts --profile $profile get-session-token --serial-number $ARN_MFA_VIRTUAL --token-code $MFA_TOKEN)
else
    echo -e "\n${YELLOW}Running command:\n${NC}${LIGHT_GREEN}aws sts get-session-token --serial-number $ARN_MFA_VIRTUAL --token-code $MFA_TOKEN${NC}"
    credentials=$(aws sts get-session-token --serial-number $ARN_MFA_VIRTUAL --token-code $MFA_TOKEN)
fi

if [ $? -ne 0 ]; then
    echo -e "${LIGHT_RED}An error has ocurred obtaining the session token, exiting${NC}" 1>&2
else
    echo -e "\n${GREEN}Result${NC}:\n${CYAN}$credentials${NC}"

    ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' <<<"$credentials")
    AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' <<<"$credentials")
    AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' <<<"$credentials")

    export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

    echo -e "\n${LIGHT_BLUE}Variables exported!!!${NC}"
    echo -e "\n======================================================================"
    echo -e "export ${GREEN}AWS_ACCESS_KEY_ID${NC}=${LIGHT_GREEN}$AWS_ACCESS_KEY_ID${NC}"
    echo -e "export ${GREEN}AWS_SECRET_ACCESS_KEY${NC}=${LIGHT_GREEN}$AWS_SECRET_ACCESS_KEY${NC}"
    echo -e "export ${GREEN}AWS_SESSION_TOKEN${NC}=${LIGHT_GREEN}$AWS_SESSION_TOKEN${NC}"
    token="$(aws codeartifact get-authorization-token --domain dev-bcpr --domain-owner 362470093612 --query authorizationToken --output text)"
    echo -e "defined token: ${token}"
    echo "======================================================================"  


    package_lock_file="package-lock.json"

    if [ -f "$package_lock_file" ] ; then
    rm "$package_lock_file"
    echo -e "deleted: ${package_lock_file} file in case that you use the ${GREEN}npm install command"
    fi

    sed -i '' -e "s/^\/\/dev-bcpr-362470093612.d.codeartifact.us-east-1.amazonaws.com\/npm\/bcpr\/:_authToken=.*$/\/\/dev-bcpr-362470093612.d.codeartifact.us-east-1.amazonaws.com\/npm\/bcpr\/:_authToken=$token/g" .npmrc

fi

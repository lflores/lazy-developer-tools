#!/bin/bash
ENVIRONMENT="POC"
LIGHT_GREEN='\033[1;32m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

get_role() {
    echo $ENVIRONMENT
    aws iam get-role --role-name "MobileUsers${ENVIRONMENT}Role"
}

if [ $# -eq 0 ]; then
    echo "You must to provide the environment as first parameter such as POC, DEV or TST values"
    exit 1
else
    ENVIRONMENT="$1"
fi

get_role

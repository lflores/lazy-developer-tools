#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

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
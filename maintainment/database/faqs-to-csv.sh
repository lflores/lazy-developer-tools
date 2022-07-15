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

cat $1| jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv'
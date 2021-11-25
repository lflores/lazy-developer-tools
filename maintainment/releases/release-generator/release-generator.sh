#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

release_module() {
    cd ../$1
    if [ $2 == "maven" ]; then
        VERSION=$(get_maven_version)
    elif [ $2 == "pubspec" ]; then
        VERSION=$(get_flutter_version)
    else
        VERSION=$(get_package_version)
    fi
    echo -e "|  ├──${LIGHT_GREEN}$1:$VERSION${NC}"
}

search_parent() {
    BASE=$(basename $PWD)
    COUNTER=0
    while [[ $BASE != $1 ]]; do
        cd ../
        COUNTER+=1
        if [ -d "./$1" ]; then
            cd ./$1
        fi
        BASE=$(basename $PWD)
        #echo -e $BASE
        #if [$COUNTER -gt 10]; then
        #    echo "I search by 10 parents and never found"
        #    break
        #fi
    done
}

get_maven_version() {
    MVN_VERSION=$(grep -oPm1 "(?<=<version>)[^<]+" "pom.xml")
    echo $MVN_VERSION
}

get_package_version() {
    VERSION=$(cat package.json | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')
    echo $VERSION
}

get_flutter_version() {
    #set -e
    #file=$(cat pubspec.yaml)
    #BUILD_NAME=$(echo $file | sed -ne 's/[^#]version: \(\([0-9]\.\)\{0,4\}[0-9][^.]\).*/\1/p')
    #BUILD_NAME=$(echo $file|grep -E '^version:[\s]+(.*)$')
    # BUILD_NAME=$(echo $file | grep -oPml '^version:[\s]+(.*)$')
    #BUILD_NAME=$(echo $file|grep -oPml "version:")
    # BUILD_NUMBER=$(git rev-list HEAD --count)
    # BUILD_NUMBER = $(echo $file | sed -ne 's/^version: (\d+\.?\d+\.?\*|.+)/p')
    VERSION=$(grep -E 'version:\s([0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}.+)' pubspec.yaml)
    # echo ${VERSION}
    #export BUILD_NAME="$BUILD_NAME"
    #export BUILD_NUMBER="$BUILD_NUMBER"
    echo $VERSION
}

if [[ -n $1 ]]; then
    MODULE=$(cat modules-data.json | jq -c ".[] | select( .name | contains(\"$1\"))")
    echo $MODULE
    cd ../
    ROOT_FOLDER=$(jq -r '.parentFolder' <<<$MODULE)
    if [ -z "$ROOT_FOLDER" ]; then
        release_module \
            $(jq -r '.name' <<<$MODULE) \
            $(jq -r '.versionType' <<<$MODULE)
    else
        search_parent $ROOT_FOLDER
        cd $(jq -r '.name' <<<$MODULE)
        release_module \
            $(jq -r '.name' <<<$MODULE) \
            $(jq -r '.versionType' <<<$MODULE)
    fi
    exit 0
fi

print_modules() {
    PREV=$(pwd)
    MODULES=$(cat modules-data.json | jq -c ".[] | select( .layer | contains(\"$1\"))")
    cd ~/workspace/evertec/banco-cooperativo/infra/
    echo -e "Cantidad de modulos: ${#MODULES[@]}"
    for MODULE in $MODULES; do
        ROOT_FOLDER=$(jq -r '.parentFolder' <<<$MODULE)
        if [ -z "$ROOT_FOLDER" ]; then
            release_module \
                $(jq -r '.name' <<<$MODULE) \
                $(jq -r '.versionType' <<<$MODULE)
        else
            search_parent $ROOT_FOLDER
            cd $(jq -r '.name' <<<$MODULE)
            release_module \
                $(jq -r '.name' <<<$MODULE) \
                $(jq -r '.versionType' <<<$MODULE)
        fi
    done
    cd $PREV
    #echo ${PWD}
}

echo -e "\n${LIGHT_GREEN}All${NC}"
print_modules "all"

echo -e "\n${LIGHT_GREEN}Frontend${NC}"
print_modules "frontend"
# echo $(pwd)

echo -e "\n${LIGHT_GREEN}Backend${NC}"
print_modules "backend"
#echo $(pwd)

echo -e "\n${LIGHT_GREEN}QA${NC}"
print_modules "qa"
#echo $(pwd)

echo -e "\n${LIGHT_GREEN}Cloud${NC}"
print_modules "cloud"

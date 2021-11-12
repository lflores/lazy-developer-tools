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

    echo -e "├──${GREEN}${NC}${LIGHT_GREEN}$1:$VERSION${NC}"

    # npm run build
    # git checkout develop && git pull
    # git checkout release && git pull
    # git merge develop && git commit -m "Merge with develop"
    # git push
    # git checkout develop
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
        echo $BASE
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
    set -e
    file=$(cat pubspec.yaml)
    # BUILD_NAME=$(echo $file | sed -ne 's/[^0-9]*\(\([0-9]\.\)\{0,4\}[0-9][^.]\).*/\1/p')
    # BUILD_NUMBER=$(git rev-list HEAD --count)
    BUILD_NUMBER = $(echo $file | sed -ne 's/^version: (\d+\.?\d+\.?\*|.+)/p')
    echo "Building version ${BUILD_NAME} ${BUILD_NUMBER}"
    export BUILD_NAME="$BUILD_NAME"
    export BUILD_NUMBER="$BUILD_NUMBER"
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
    #MODULES=$(cat modules-data.json | jq -c ".[] | select( .layer | contains(\"$1\"))")
    cd ../
    for MODULE in $1; do
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
    search_parent "backend"
    cd bcpr-documentation/releases
}

#echo $(cat modules-data.json | jq -c ".[] | select( .layer | contains(\"cloud\"))")

#MODULES=$(cat modules-data.json | jq -c -r '.[]')
MODULES=$(cat modules-data.json | jq -c ".[] | select( .layer | contains(\"frontend\"))")
cd ~/workspace/evertec/banco-cooperativo/infra/bcpr-cloud-cdk-application
echo -e "\nAll"
print_modules $MODULES
# echo $(pwd)

#echo -e "\nBackend"
#print_modules "backend"
#echo $(pwd)

#echo -e "\nQA"
#print_modules "qa"
#echo $(pwd)

#echo -e "\nCloud"
#print_modules "cloud"

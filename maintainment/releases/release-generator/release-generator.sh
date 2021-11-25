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
    if [ $3 == true ]; then
        echo -e "│  └── ${LIGHT_BLUE}$1${NC}: ${LIGHT_GREEN}$VERSION${NC}"
    else
        echo -e "│  ├── ${LIGHT_BLUE}$1${NC}: ${LIGHT_GREEN}$VERSION${NC}"
    fi
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
    VERSION=$(grep -oEi 'version:\s([0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}.+)' pubspec.yaml)
    #echo $?
    echo ${VERSION//version:}
}

if [[ -n $1 ]]; then
    MODULE=$(cat modules-data.json | jq -c ".[] | select( .name | contains(\"$1\"))")
    echo $MODULE
    cd ~/workspace/evertec/banco-cooperativo/infra/
    ROOT_FOLDER=$(jq -r '.parentFolder' <<<$MODULE)
    if [ -z "$ROOT_FOLDER" ]; then
        release_module \
            $(jq -r '.name' <<<$MODULE) \
            $(jq -r '.versionType' <<<$MODULE) \
            false
    else
        search_parent $ROOT_FOLDER
        cd $(jq -r '.name' <<<$MODULE)
        release_module \
            $(jq -r '.name' <<<$MODULE) \ 
            $(jq -r '.versionType' <<<$MODULE) \
            false
    fi
    exit 0
fi

print_modules() {
    PREV=$(pwd)
    MODULES=$(cat modules-data.json | jq -c "map(select(.layer | contains(\"$1\")))")
    COUNT=$(echo $MODULES | jq -s '.[] | length')
    cd ~/workspace/evertec/banco-cooperativo/infra/

    LAST=$(jq -rs '.[][-1].name' <<<$MODULES)

    for MODULE_NAME in $(echo $MODULES | jq -r '.[] | .name'); do
        IS_LAST=false
        if [ $MODULE_NAME == $LAST ]; then
            IS_LAST=true
        fi
        MODULE=$(echo $MODULES | jq -r ".[] | select(.name | contains(\"$MODULE_NAME\"))")
        ROOT_FOLDER=$(jq -r '.parentFolder' <<<$MODULE)
        if [ -z "$ROOT_FOLDER" ]; then
            release_module \
                $(jq -r '.name' <<<$MODULE) \
                $(jq -r '.versionType' <<<$MODULE) \
                $IS_LAST
        else
            search_parent $ROOT_FOLDER
            cd $(jq -r '.name' <<<$MODULE)
            release_module \
                $(jq -r '.name' <<<$MODULE) \
                $(jq -r '.versionType' <<<$MODULE) \
                $IS_LAST
        fi
    done
    cd $PREV
    #echo ${PWD}
}

echo -e "\n${LIGHT_GREEN}BCPR Mobile${NC}\n"

echo -e "├─ All"
print_modules "all"

echo -e "├─ Frontend"
print_modules "frontend"
# echo $(pwd)

echo -e "├─ Backend"
print_modules "backend"
#echo $(pwd)

echo -e "├─ QA"
print_modules "qa"
#echo $(pwd)

echo -e "├─ Cloud"
print_modules "cloud"

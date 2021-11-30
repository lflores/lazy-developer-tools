#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

PACKAGE_VERSION=0.3.0
RELEASE_FOLDER=~/workspace/evertec/banco-cooperativo/backend/bcpr-documentation/releases/$PACKAGE_VERSION
RELEASE_FILE=~/workspace/evertec/banco-cooperativo/backend/bcpr-documentation/releases/Release-$PACKAGE_VERSION.md

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
        LINE=$(echo -e "│  └── $1: $VERSION")
        LINE_SCREEN=$(echo -e "│  └── ${LIGHT_BLUE}$1${NC}: ${LIGHT_GREEN}$VERSION${NC}")
    else
        LINE=$(echo -e "│  ├── $1: $VERSION")
        LINE_SCREEN=$(echo -e "│  ├── ${LIGHT_BLUE}$1${NC}: ${LIGHT_GREEN}$VERSION${NC}")
    fi
    echo $LINE_SCREEN
    echo $LINE >>$RELEASE_FILE
    make_release_document $1 $VERSION
}

make_release_document() {
    if [[ ! -d $RELEASE_FOLDER ]]; then
        mkdir $RELEASE_FOLDER
    fi
    cp ./CHANGELOG.md $RELEASE_FOLDER/$1-$2.md
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
    echo ${VERSION//version:/}
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

print_tree() {
    echo "\`\`\`javascript" >> $RELEASE_FILE
    echo -e "\n${LIGHT_GREEN}BCPR Mobile${NC}"
    echo "├─ All" >>$RELEASE_FILE
    print_modules "all"
    echo "├─ Frontend" >>$RELEASE_FILE
    print_modules "frontend"
    # echo $(pwd)
    echo "├─ Backend" >>$RELEASE_FILE
    print_modules "backend"
    #echo $(pwd)
    echo "├─ QA" >>$RELEASE_FILE
    print_modules "qa"
    #echo $(pwd)
    echo "├─ Cloud" >>$RELEASE_FILE
    print_modules "cloud"
    echo "\`\`\`" >>$RELEASE_FILE
}

echo "# Release $PACKAGE_VERSION" > $RELEASE_FILE

echo -e "\n# Versions tree" >> $RELEASE_FILE
print_tree
echo -e "\n# Changelogs" >> $RELEASE_FILE
for file in $RELEASE_FOLDER/*
do
echo $file
    if [[ -f $file ]]; then
        #copy stuff ....
        echo -e "## $(basename $file)" >> $RELEASE_FILE
        echo -e "[$(basename $file)](./$PACKAGE_VERSION/$(basename $file))" >> $RELEASE_FILE
    fi
done
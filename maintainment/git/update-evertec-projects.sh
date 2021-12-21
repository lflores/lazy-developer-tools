#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

update_module() {
    NAME=$(jq -r '.name' <<<$MODULE)
    DESTINATION=$(jq -r '.destination' <<<$MODULE)
    cd ../$NAME
    VERSION=$(cat package.json | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')
    echo -e "${GREEN}Releasing: ${NC}${LIGHT_GREEN}$1:$VERSION${NC}"
    # npm run build
    git checkout develop && git pull
    rsync -av --progress ./ ../$DESTINATION/ \
        --exclude .git \
        --exclude .npmrc_codebuild \
        --exclude config \
        --exclude maintainment \
        --exclude load-session-token.sh \
        --exclude bin \
        --exclude cdk.out

    #--exclude lib/**/*.d.ts \
    #cp lib/**/*.ts "../$DESTINATION/lib"
}

search_parent() {
    echo "Searching... '$ROOT_FOLDER' folder"
    BASE=$(basename $PWD)
    COUNTER=0
    while [[ $BASE != $1 ]]; do
        cd ../
        COUNTER+=1
        if [ -d "./$1" ]; then
            cd ./$1
        fi
        BASE=$(basename $PWD)
        #echo $BASE
        #if [$COUNTER -gt 10]; then
        #    echo "I search by 10 parents and never found"
        #    break
        #fi
    done
    echo "I found it in $PWD"
}

if [[ -n $1 ]]; then
    MODULE=$(cat modules-data.json | jq -c ".[] | select( .name | contains(\"$1\"))")
    echo $MODULE
    cd ~/workspace/evertec/banco-cooperativo/infra
    ROOT_FOLDER=$(jq -r '.rootFolder' <<<$MODULE)
    if [ -z "$ROOT_FOLDER" ]; then
        update_module \
            $(jq -r '.name' <<<$MODULE)
    else
        search_parent $ROOT_FOLDER
        cd $(jq -r '.name' <<<$MODULE)
        update_module \
            $MODULE
    fi
    exit 0
fi

MODULES=$(cat modules-data.json | jq -c -r '.[]')

cd ~/workspace/evertec/banco-cooperativo/infra
for MODULE in $MODULES; do
    ROOT_FOLDER=$(jq -r '.rootFolder' <<<$MODULE)
    if [ -z "$ROOT_FOLDER" ]; then
        update_module \
            $(jq -r '.name' <<<$MODULE)
    else
        search_parent $ROOT_FOLDER
        cd $(jq -r '.name' <<<$MODULE)
        update_module \
            $(jq -r '.name' <<<$MODULE)
    fi
done

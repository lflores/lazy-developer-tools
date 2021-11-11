#!/bin/bash
ENVIRONMENT="DEV"
LIGHT_GREEN='\033[1;32m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Este script busca los recursos que no tienen el tag de evt:application-module
# que puede ser un candidato a ser creado en la consola manualmente

UNKNOWN_RESOURCES=$(aws resourcegroupstaggingapi get-resources | jq -r '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "evt:application-module"}]}) | not).ResourceARN')

#ECS=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:ecs")).ResourceARN' <<<"$UNKNOWN_RESOURCES")
#EC2=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:ec2")).ResourceARN' <<<"$UNKNOWN_RESOURCES")
#CLOUD_FORMATION=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:cloudformation")).ResourceARN' <<<"$UNKNOWN_RESOURCES")
CLOUD_WATCH=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:cloudwatch")).ResourceARN' <<<"$UNKNOWN_RESOURCES")
#CODE_BUILD=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:codebuild")).ResourceARN' <<<"$UNKNOWN_RESOURCES")
#CODE_PIPELINE=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:codepipeline")).ResourceARN' <<<"$UNKNOWN_RESOURCES")
#ELASTIC_LB=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:elasticloadbalancing")).ResourceARN' <<<"$UNKNOWN_RESOURCES")

echo -e "\n${GREEN}===== ECS - ${ENVIRONMENT} ======${NC}"
for instance in $UNKNOWN_RESOURCES; do
    echo $instance
done

# echo -e "\n${GREEN}===== ECS - ${ENVIRONMENT} ======${NC}"
# for instance in $ECS; do
#     echo $instance
# done
#echo -e "\n${GREEN}===== EC2 - ${ENVIRONMENT} ======${NC}"
#for instance in $EC2; do
#    echo $instance
#done
# echo -e "\n${GREEN}===== CLOUD FORMATION - ${ENVIRONMENT} ======${NC}"
# for instance in $CLOUD_FORMATION; do
#     echo $instance
# done
echo -e "\n${GREEN}===== CLOUD WATCH - ${ENVIRONMENT} ======${NC}"
for instance in $CLOUD_WATCH; do
    echo $instance
done
# echo -e "\n${GREEN}===== CODE BUILD - ${ENVIRONMENT} ======${NC}"
# for instance in $CODE_BUILD; do
#     echo $instance
# done
# echo -e "\n${GREEN}===== CODE PIPELINE - ${ENVIRONMENT} ======${NC}"
# for instance in $CODE_PIPELINE; do
#     echo $instance
# done
# echo -e "\n${GREEN}===== ELASTIC LB - ${ENVIRONMENT} ======${NC}"
# for instance in $ELASTIC_LB; do
#     echo $instance
# done

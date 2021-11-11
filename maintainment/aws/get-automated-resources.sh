#!/bin/bash
ENVIRONMENT="POC"
LIGHT_GREEN='\033[1;32m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

RESOURCES=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=evt:application-module Key=evt:env,Values=$ENVIRONMENT --tags-per-page 100)
ECS=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:ecs")).ResourceARN' <<<"$RESOURCES")
EC2=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:ec2")).ResourceARN' <<<"$RESOURCES")
CLOUD_FORMATION=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:cloudformation")).ResourceARN' <<<"$RESOURCES")
CODE_BUILD=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:codebuild")).ResourceARN' <<<"$RESOURCES")
CODE_PIPELINE=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:codepipeline")).ResourceARN' <<<"$RESOURCES")
ELASTIC_LB=$(jq -r '.ResourceTagMappingList[]|select(.ResourceARN | startswith("arn:aws:elasticloadbalancing")).ResourceARN' <<<"$RESOURCES")

echo -e "\n${GREEN}===== ECS - ${ENVIRONMENT} ======${NC}"
for instance in $ECS; do
    echo $instance
done
echo -e "\n${GREEN}===== EC2 - ${ENVIRONMENT} ======${NC}"
for instance in $EC2; do
    echo $instance
done
echo -e "\n${GREEN}===== CLOUD FORMATION - ${ENVIRONMENT} ======${NC}"
for instance in $CLOUD_FORMATION; do
    echo $instance
done
echo -e "\n${GREEN}===== CODE BUILD - ${ENVIRONMENT} ======${NC}"
for instance in $CODE_BUILD; do
    echo $instance
done
echo -e "\n${GREEN}===== CODE PIPELINE - ${ENVIRONMENT} ======${NC}"
for instance in $CODE_PIPELINE; do
    echo $instance
done
echo -e "\n${GREEN}===== ELASTIC LB - ${ENVIRONMENT} ======${NC}"
for instance in $ELASTIC_LB; do
    echo $instance
done




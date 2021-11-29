#!/bin/bash
REGION="us-east-1"
ACCOUNT="362470093612"
ENVIRONMENT="POC"
MICROSERVICES_LISTENER_ARN="arn:aws:elasticloadbalancing:us-east-1:362470093612:listener/app/BCPR-POC-microservices-lb/279846a32ba655fe/32b21ae25b9b5efa"
TARGET_GROUP_ARN="arn:aws:elasticloadbalancing:$REGION:$ACCOUNT:targetgroup/BCPR-POC-middleware-service-tg/b8c4b986f647cbed"

aws elbv2 create-rule \
    --listener-arn  $MICROSERVICES_LISTENER_ARN\
    --priority 1 \
    --conditions Field=path-pattern,Values='/health'\
    --actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

aws elbv2 create-rule \
    --listener-arn  $MICROSERVICES_LISTENER_ARN\
    --priority 2 \
    --conditions Field=path-pattern,Values='/*/institutions*'\
    --actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN
aws elbv2 create-rule \
    --listener-arn  $MICROSERVICES_LISTENER_ARN\
    --priority 3 \
    --conditions Field=path-pattern,Values='/v1/accounts/reward'\
    --actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN
aws elbv2 create-rule \
    --listener-arn  $MICROSERVICES_LISTENER_ARN\
    --priority 4 \
    --conditions Field=path-pattern,Values='/*/cards/deactivation'\
    --actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN
aws elbv2 create-rule \
    --listener-arn  $MICROSERVICES_LISTENER_ARN\
    --priority 5 \
    --conditions Field=path-pattern,Values='/*/cards/activation'\
    --actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN
aws elbv2 create-rule \
    --listener-arn  $MICROSERVICES_LISTENER_ARN\
    --priority 6 \
    --conditions Field=path-pattern,Values='/*/cards/switchCard'\
    --actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN
aws elbv2 create-rule \
    --listener-arn  $MICROSERVICES_LISTENER_ARN\
    --priority 7 \
    --conditions Field=path-pattern,Values='/*/enrollment/getCustomerInformation'\
    --actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

# aws elbv2 modify-rule \
#     --actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:$REGION:$ACCOUNT:targetgroup/BCPR-POC-middleware-service-tg/b8c4b986f647cbed \
#     --conditions Field=path-pattern,Values='/images/*'\
#     --rule-arn arn:aws:elasticloadbalancing:us-east-1:362470093612:listener-rule/app/BCPR-POC-microservices-lb/279846a32ba655fe/32b21ae25b9b5efa/2c982818c9e05521

#arn:aws:elasticloadbalancing:us-east-1:362470093612:targetgroup/BCPR-POC-middleware-service-tg/b8c4b986f647cbed
#arn:aws:elasticloadbalancing:us-east-1:362470093612:listener/app/BCPR-POC-microservices-lb/279846a32ba655fe/32b21ae25b9b5efa


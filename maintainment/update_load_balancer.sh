#!/bin/bash

#BCPRDEVInfrastructurebcprclusteraccountserviceTaskCountTargetCpuScaling6BBCE555
ecsClusterName="bcpr-microservices-cluster"
nameService="account-service"
nameTaskDefinition="ACCOUNT"
version="25"
desiredCount="4"

echo aws ecs update-service \
--cluster ${ecsClusterName} \
--service ${nameService} \
--task-definition ${nameTaskDefinition}:${version} \
--desired-count ${desiredCount} --force-new-deployment

aws ecs update-service \
--cluster ${ecsClusterName} \
--service ${nameService} \
--task-definition ${nameTaskDefinition}:${version} \
--desired-count ${desiredCount} --force-new-deployment
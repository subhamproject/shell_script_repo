#!/usr/bin/env bash
#Script to check if image is present in given repo in respective account

REGION="$AWS_REGION"
BACKEND="$RCX_BACKEND"
TENANT="$RCX_TENANT"
PROFILE="$AWS_PROFILE"

ENV_NAME="$BACKEND"
ENV_NAME+="-$TENANT"

if [[ -z $REGION ]] || [[ -z $BACKEND ]] || [[ -z $TENANT ]] || [[ -z $PROFILE ]];then
echo "Please export all env's details  for the env you wish to connect ? and try again..!" && exit 1
fi


RED="\033[0;31m"
GREEN="\033[0;32m"
CLEAR='\033[0m'

if [[ $# -lt 2 ]]; then
    echo "Usage: $( basename $0 ) <repository-name> <image-tag>"
    exit 1
fi

REGISTRY="$(aws sts --region $REGION --profile $PROFILE get-caller-identity --query 'Account' --output text).dkr.ecr.${REGION}.amazonaws.com"

IMAGE_META="$(aws ecr --region $REGION --profile $PROFILE describe-images --repository-name=$1 --image-ids=imageTag=$2 2> /dev/null )"

if [[ $? == 0 ]]; then
    IMAGE_TAGS="$(jq '.imageDetails[0].imageTags[0]' -r <<< ${IMAGE_META})"
    printf "${GREEN}Image --> $REGISTRY/$1:$2 present in Account: $ENV_NAME ${CLEAR}\n"
else
    printf "${RED}Image -->$REGISTRY/$1:$2 Not present in Account $ENV_NAME ${CLEAR}\n"
    exit 1
fi

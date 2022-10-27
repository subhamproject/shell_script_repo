#!/bin/bash

Help() {
cat << EOF
Usage: $0 -s <source profile> -d <destination profile>
Configure ECR Cross Region Replication  for New Account

-h, -help,          --help                  Display help

-s, -source-profile,  --source-profile      Please provide Source Profile(254/Dev7 Profile)

-d, -dest-profile,    --dest-profile        Please provide Dest Profile(New Account Profile name - You wish to configure replicatoin for?)
EOF
}

options=$(getopt -l "help,source-profile:,dest-profile:" -o "hs:d:" -a -- "$@")

if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi

eval set -- "$options"

while [ "$#" -ge 1 ]; do
case "$1" in
-h|--help)
    Help
    exit 0
    ;;
-s|--source-profile)
    SOURCE_PROFILE=$2
    shift
    ;;
-d|--dest-profile)
    DEST_PROFILE=$2
    shift
    ;;
--)
    shift
    break;;
*) echo "unknown option: $1" ; exit 1 ;;
esac
shift
done

[ -v $SOURCE_PROFILE ] || [ -v $DEST_PROFILE ] && { echo -e "Please provide source or destination profile details and - Try Again..! \n\n$(Help)" ; exit 1 ;}

command -v jq >/dev/null 2>&1 || { echo >&2 "jq is not installed - Please install and try again - Aborting.."; exit 1; }

DEST_ACT_ID=$(aws sts --profile $DEST_PROFILE get-caller-identity --query 'Account' --output text)
DEST_REGION=$(aws configure get region --profile $DEST_PROFILE)

CURRENT_RULE="current_rule.json"
NEW_RULE="new_rule.json"

docker run --rm -v ~/.aws:/root/.aws -v /tmp:/tmp -w /tmp amazon/aws-cli --profile $SOURCE_PROFILE --region us-west-2 ecr describe-registry|jq -r '.replicationConfiguration' > $CURRENT_RULE
cat $CURRENT_RULE |jq --arg REGION "$DEST_REGION" --arg ACNT "$DEST_ACT_ID" '.rules[].destinations += [{"region": $REGION,"registryId": $ACNT}]' > $NEW_RULE


: '
if [ -f $NEW_RULE ];then
docker run --rm -v ~/.aws:/root/.aws -v /tmp:/tmp -w /tmp amazon/aws-cli --profile $SOURCE_PROFILE --region us-west-2 ecr put-replication-configuration --replication-configuration file://$NEW_RULE
fi
'

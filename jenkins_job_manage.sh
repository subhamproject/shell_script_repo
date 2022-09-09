#!/bin/bash

shopt -s xpg_echo

function usage(){
  echo "Usage: $0 -f|--folder -r|--repo -c|--config -b|--branch -a|--add -d|--delete
        -f|--folder:   Please provide folder name you wish to configure new job in.
        -r|--repo:     Please provide job name.
        -c|--config:   Please provide Jenkinsfile name for this job(eg:- Jenkinsfile.java , Jenkins.python).
        -b|--branch:   Please provide branch name to add to Multibranch pipeline job.
        -a|--add:      Default value is True.
        -d|--delete:   Default value is True."
  exit 1
}

[ $# -lt 1 ] && usage || true

: ${TEMP_XML:=$(mktemp)}
: ${USER_NAME:=administrator}
: ${TOKEN:=11267xxxxxxxxx8be8379}
: ${URL:=http://18.16.19.28:8080}
: ${DEFAULT_XML:=config.xml}

function clean (){
rm -rf $TEMP_XML $DOWNLOAD_XML ${DOWNLOAD_XML}.$$
}

trap clean EXIT

function create_folder() {
local FOLDER_NAME="$1"
curl -s -XPOST "${URL:-https://jenkins.devops.com}/createItem?name=${FOLDER_NAME/ /%20}&mode=com.cloudbees.hudson.plugins.folder.Folder&from=&json=%7B%22name%22%3A%22FolderName%22%2C%22mode%22%3A%22com.cloudbees.hudson.plugins.folder.Folder%22%2C%22from%22%3A%22%22%2C%22Submit%22%3A%22OK%22%7D&Submit=OK" --user ${USER_NAME}:${TOKEN} -H "Content-Type:application/x-www-form-urlencoded"
[ $? -eq 0 ] && echo "Folder: \"${FOLDER_NAME/ /%20}\" created successfully." || echo "Folder: \"${FOLDER_NAME/ /%20}\" already exist"
}

function create_job() {
local JOB_NAME="$1"
local FOLDER_NAME="$2"
local XML="$3"
STATUS=$(curl -s -XGET "${URL:-https://jenkins.devops.com}/job/${FOLDER_NAME/ /%20}/checkJobName?value=${JOB_NAME}" --user ${USER_NAME}:${TOKEN})
if [[ $(echo $STATUS|grep exists|wc -l) -eq 0 ]];then
curl -s -XPOST "${URL:-https://jenkins.devops.com}/job/${FOLDER_NAME/ /%20}/createItem?name=${JOB_NAME}" --data-binary @${XML} -H "Content-Type:text/xml" --user ${USER_NAME}:${TOKEN}
[ $? -eq 0 ] && echo "Jenkins Job: \"${JOB_NAME}\" created successfully."
else
echo "Jenkins Job: \"${JOB_NAME}\" already exist."
exit 1
fi
}


function create_xml(){
local JOB_NAME="$1"
local CONFIG="$2"
sed "s|sample-java-app|${JOB_NAME}|; s|Jenkinsfile|${CONFIG}|g" $DEFAULT_XML > $TEMP_XML
}

function add_branch(){
local MAIN_BRANCH="$1"
local FOLDER_NAME="$2"
local JOB_NAME="$3"
DOWNLOAD_XML="/tmp/${JOB_NAME}_config.xml"
FILE=${DOWNLOAD_XML}
set -- $(echo $MAIN_BRANCH|sed s'|,| |g')
for BRANCH in "$@"
do
unset NEW_REGEX
curl -s -XGET ${URL:-https://jenkins.devops.com}/job/${FOLDER_NAME/ /%20}/job/${JOB_NAME}/config.xml -o ${DOWNLOAD_XML} --user ${USER_NAME}:${TOKEN}
REGEX="$(cat $FILE |grep regex|cut -d'[' -f1|cut -d'(' -f2|sed 's|PR.*||')"
NEW_REGEX="$REGEX"
NEW_REGEX+="$BRANCH|"
if [[ "$(cat $FILE |grep -w "$BRANCH" |wc -l)" -eq "1" ]];then
echo "Branch \"${BRANCH}\" already added for \"${JOB_NAME}\" job,skipping..!"
else
cat $FILE|sed "s;${REGEX};${NEW_REGEX};" > ${DOWNLOAD_XML}.$$
[ $? -eq 0 ] && \
curl -s -XPOST ${URL:-https://jenkins.devops.com}/job/${FOLDER_NAME/ /%20}/job/${JOB_NAME}/config.xml --data-binary "@${DOWNLOAD_XML}.$$" --user ${USER_NAME}:${TOKEN}
[ $? -eq 0 ] && echo "Branch \"${BRANCH}\" branch added successfuly in \"${JOB_NAME}\" job." || echo "Branch \"${BRANCH}\" wasn't added,There is some issue,Please check."
fi
done
}

function remove_branch(){
local MAIN_BRANCH="$1"
local FOLDER_NAME="$2"
local JOB_NAME="$3"
DOWNLOAD_XML="/tmp/${JOB_NAME}_config.xml"
FILE=${DOWNLOAD_XML}
set -- $(echo $MAIN_BRANCH|sed s'|,| |g')
for BRANCH in "$@"
do
unset NEW_REGEX
curl -s -XGET ${URL:-https://jenkins.devops.com}/job/${FOLDER_NAME/ /%20}/job/${JOB_NAME}/config.xml -o ${DOWNLOAD_XML} --user ${USER_NAME}:${TOKEN}
NEW_REGEX+="|$BRANCH"
if [[ "$(cat $FILE |grep -w "$BRANCH" |wc -l)" -eq "1" ]];then
echo "Branch \"${BRANCH}\" present in \"${JOB_NAME}\" job removing it."
cat $FILE|sed "s;${NEW_REGEX};;" > ${DOWNLOAD_XML}.$$
[ $? -eq 0 ] && \
curl -s -XPOST ${URL:-https://jenkins.devops.com}/job/${FOLDER_NAME/ /%20}/job/${JOB_NAME}/config.xml --data-binary "@${DOWNLOAD_XML}.$$" --user ${USER_NAME}:${TOKEN}
[ $? -eq 0 ] && echo "Branch \"${BRANCH}\" removed successfuly from \"${JOB_NAME}\" job." || echo "Brach \"${BRANCH}\" wasn't deleted,There is some issue,Please check."
else
echo "No such branch \"${BRANCH}\" present in \"${JOB_NAME}\" job,skipping..!"
fi
done
}


#Parsing Args
while [[ $1 ]];do
 case $1 in
   -f|--folder)
          FOLDER=$2
    ;;
   -r|--repo)
          JOB=$2
          shift
    ;;
   -c|--config)
          CONFIG=$2
          shift
    ;;
   -b|--branch)
          BRANCH=$2
          shift
    ;;
   -a|--add)
          ADD=True
    ;;
   -d|--delete)
          REMOVE=True
    ;;
esac
shift
done

if [[ -n "${FOLDER}" ]] && [[ -z "${JOB}" ]] && [[ -z "${CONFIG}" ]];then
create_folder "$FOLDER"
elif [[ -n "${FOLDER}" ]] && [[ -n "${JOB}" ]] && [[ -n "${CONFIG}" ]];then
create_xml "$JOB" "$CONFIG"
[ $? -eq 0 ] && create_job "$JOB" "$FOLDER" "$TEMP_XML"
elif [[ -n "${ADD}" ]] && [[ -n "${BRANCH}" ]] && [[ -n "${FOLDER}" ]] && [[ -n "${JOB}" ]];then
add_branch "$BRANCH" "$FOLDER" "$JOB"
elif [[ -n "${REMOVE}" ]] && [[ -n "${BRANCH}" ]] && [[ -n "${FOLDER}" ]] && [[ -n "${JOB}" ]];then
remove_branch "$BRANCH" "$FOLDER" "$JOB"
fi

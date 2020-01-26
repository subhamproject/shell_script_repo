#!/bin/bash

CONSOLE_RED="\033[2;31m"
CONSOLE_GREEN="\033[2;32m"
CONSOLE_CLEAR="\033[0m"

JENKINS_SERVER=http://my_jenkins_server
JOB=$1
JOB_QUERY=/job/${JOB}

BUILD_STATUS_QUERY=/lastBuild/api/json
JOB_STATUS_JSON=`curl --silent ${JENKINS_SERVER}${JOB_QUERY}${BUILD_STATUS_QUERY}`

CURRENT_BUILD_NUMBER_QUERY=/lastBuild/buildNumber
CURRENT_BUILD_JSON=`curl --silent ${JENKINS_SERVER}${JOB_QUERY}${CURRENT_BUILD_NUMBER_QUERY}`

LAST_STABLE_BUILD_NUMBER_QUERY=/lastStableBuild/buildNumber
LAST_STABLE_BUILD_JSON=`curl --silent ${JENKINS_SERVER}${JOB_QUERY}${LAST_STABLE_BUILD_NUMBER_QUERY}`

check_build()
{
    GOOD_BUILD="${GREEN}Last build successful. "
    BAD_BUILD="${RED}Last build failed. "
    CLEAR_COLOURS=${CLEAR}
    RESULT=`echo "${JOB_STATUS_JSON}" | sed -n 's/.*"result":\([\"A-Za-z]*\),.*/\1/p'`
    CURRENT_BUILD_NUMBER=${CURRENT_BUILD_JSON}
    LAST_STABLE_BUILD_NUMBER=${LAST_STABLE_BUILD_JSON}
    LAST_BUILD_STATUS=${GOOD_BUILD}
    echo "${LAST_STABLE_BUILD_NUMBER}" | grep "is not available" > /dev/null
    GREP_RETURN_CODE=$?
    if [ ${GREP_RETURN_CODE} -ne 0 ]
    then
        if [ `expr ${CURRENT_BUILD_NUMBER} - 1` -gt ${LAST_STABLE_BUILD_NUMBER} ]
        then
            LAST_BUILD_STATUS=${BAD_BUILD}
        fi
    fi

    if [ "${RESULT}" = "null" ]
    then
        echo "${LAST_BUILD_STATUS}Building ${JOB} ${CURRENT_BUILD_NUMBER}... last stable was ${LAST_STABLE_BUILD_NUMBER}${CLEAR_COLOURS}"
    elif [ "${RESULT}" = "\"SUCCESS\"" ]
    then
        echo "${LAST_BUILD_STATUS}${JOB} ${CURRENT_BUILD_NUMBER} completed successfully.${CLEAR_COLOURS}"
    elif [ "${RESULT}" = "\"FAILURE\"" ]
    then
        LAST_BUILD_STATUS=${BAD_BUILD}
        echo "${LAST_BUILD_STATUS}${JOB} ${CURRENT_BUILD_NUMBER} failed${CLEAR_COLOURS}"
    else
        LAST_BUILD_STATUS=${BAD_BUILD}
        echo "${LAST_BUILD_STATUS}${JOB} ${CURRENT_BUILD_NUMBER} status unknown - '${RESULT}'${CLEAR_COLOURS}"
    fi
}

if [ "$2" = "tmux" ]
then
    GREEN="#[bg=blue fg=white]"
    RED="#[bg=red fg=white]"
    CLEAR=
    check_build
else
#    GREEN=${CONSOLE_GREEN}
#    RED=${CONSOLE_RED}
#    CLEAR=${CONSOLE_CLEAR}
    GREEN=
    RED=
    CLEAR=
    QUERY_TIMEOUT_SECONDS=30
    while [ true ]
    do
        check_build
        sleep ${QUERY_TIMEOUT_SECONDS}
    done
fi

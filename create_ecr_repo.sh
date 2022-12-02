#!/bin/bash

aws ecr describe-repositories --repository-names $1 2>&1 > /dev/null
status=$?
if [[ ! "${status}" -eq 0 ]]; then
    aws ecr create-repository --repository-name $1
fi


aws ecr describe-repositories --repository-names subham-prods > /dev/null 2>&1 || aws ecr create-repository --repository-name subham-prods > /dev/null 2>&1

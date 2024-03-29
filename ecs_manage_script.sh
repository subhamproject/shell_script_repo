#!/bin/bash
# https://github.com/cpcwood/ecs-rollback-hello-world/blob/main/bin/lib/aws_ecs_rollback

#https://engineering.resolvergroup.com/2021/10/rolling-back-aws-elastic-container-service-ecs-deployments/


#!/usr/bin/env bash

# AWS ECS Rollback
#   Description: Rollback AWS ECS Service Task Definitions
#   Usage: 
#     - source ./aws_ecs_rollback
#     - aws_ecs_rollback <ecs_service_to_project_dir>
#   Dependencies:
#     - dialog (https://command-not-found.com/dialog)
#     - bash v4+
#   Args:
#     - ecs_service_to_project_dir (function) (required if GIT_COMMENTS = true)
#   Variables:
#     - BACK_TITLE (var) (optional)
#     - SCRIPT_NAME (var) (optional)
#     - NUM_OF_TASK_DEFINITIONS (var) (optional)
#     - GIT_COMMENTS (var) (optional default true)

# Script Process
#   - cluster_selection
#   - service_selection
#   - task_definition_selection
#     - fetch git commit comments
#   - confirm_changes
#   - update services

function aws_ecs_rollback() {
  ecs_service_to_project_dir=$1

  if [[ ! $(dialog --version) =~ 'Version: 1' ]]; then
    echo "ERROR: dialog must be installed (https://command-not-found.com/dialog)"
    exit 1
  fi

  # Dialog config
  DIALOG_OK=0
  DIALOG_CANCEL=1
  DIALOG_ESC=1

  # Optional Vars
  : ${BACK_TITLE='AWS ECS Devops'}
  : ${SCRIPT_NAME="Deployment Rollback"}
  : ${NUM_OF_TASK_DEFINITIONS=3}
  : ${GIT_COMMENTS=true}

  # functions
  function process_dialog_exit() {
    # args <dialog_exit_status>
    if [[ $1 != "$DIALOG_OK" ]]; then
      echo "$SCRIPT_NAME - Dialog cancelled"
      exit 1
    fi
  }

  function remove_quotes() {
    echo "$1" | tr -d '"'
  }

  # Cluster selection
  # ------------------------------------------------
  echo "Loading clusters..."
  clusters=()
  while read -r arn; do clusters+=("$(remove_quotes "$arn")"); done < <(
    aws ecs list-clusters --query clusterArns | jq '.[]'
  )

  cluster_menu_options=()
  for i in "${!clusters[@]}"; do
    cluster_menu_options+=("$i" "${clusters[$i]}")
  done

  menu_action='Select AWS ECS Cluster'
  exec 3>&1
  dialog_menu_result=$(
    dialog --title "$SCRIPT_NAME" \
           --backtitle "$BACK_TITLE" \
           --clear  \
           --cancel-label Cancel \
           --menu "$menu_action:" 0 0 5 "${cluster_menu_options[@]}" \
           2>&1 1>&3
  )
  dialog_exit_status=$?; clear; exec 3>&-
  process_dialog_exit "$dialog_exit_status"
  selected_cluster="${clusters[$dialog_menu_result]}"


  # Service selection
  # ------------------------------------------------
  echo "Loading services..."
  services=()
  while read -r arn; do services+=("$(remove_quotes "$arn")"); done < <(
    aws ecs list-services --cluster "$selected_cluster" \
                          --query serviceArns \
      | jq '.[]'
  )

  service_menu_options=()
  for i in "${!services[@]}"; do
    service_menu_options+=("$i" "${services[$i]}" "off")
  done

  menu_action='Select AWS ECS Service (spacebar to select)'
  exec 3>&1
  dialog_menu_result=$(
    dialog --title "$SCRIPT_NAME" \
           --backtitle "$BACK_TITLE" \
           --clear  \
           --cancel-label Cancel \
           --checklist "$menu_action:" 0 0 5 "${service_menu_options[@]}" \
           2>&1 1>&3
  )
  dialog_exit_status=$?; clear; exec 3>&-
  process_dialog_exit "$dialog_exit_status"

  selected_services=()
  for result in ${dialog_menu_result}; do
    selected_services+=("${services[$result]}")
  done


  # Task definition selection for each selected service
  # ------------------------------------------------
  echo "Loading task definitions..."
  declare -A selected_task_definitions
  declare -A selected_task_definition_descriptions

  for selected_service in "${selected_services[@]}"; do
    service_task_definition=$(
      aws ecs describe-services --cluster "$selected_cluster" \
                                --services "$selected_service" \
                                --query 'services[0].taskDefinition' \
                                --output text
    )
    task_defintion_family=$(
      aws ecs describe-task-definition --task-definition "$service_task_definition" \
                                       --query 'taskDefinition.family' \
                                       --output text
    )
    
    task_definition_arns=()
    declare -A task_definition_revisions
    declare -A task_definition_revisions_to_arns
    declare -A task_definition_images
    declare -A task_definition_image_tags
    declare -A task_definition_commit_comments

    # fetch arns
    while read -r arn; do task_definition_arns+=("$(remove_quotes "$arn")"); done < <(
      aws ecs list-task-definitions --family-prefix "$task_defintion_family" \
                                    --max-items "$NUM_OF_TASK_DEFINITIONS" \
                                    --query taskDefinitionArns \
                                    --sort DESC \
        | jq '.[]'
    )
    
    # fetch revisions and images
    for task_definition_arn in "${task_definition_arns[@]}"; do
      task_definition_description=$(
        aws ecs describe-task-definition --task-definition "$task_definition_arn" \
                                         --query '{ image: taskDefinition.containerDefinitions[0].image,
                                                    revision: taskDefinition.revision }'
      )

      image=$(echo "$task_definition_description" | jq .image | tr -d '"')
      revision=$(echo "$task_definition_description" | jq .revision | tr -d '"')
      image_tag_regex=':([[:alnum:]]+)$'
      image_tag=$([[ $image =~ $image_tag_regex ]] && echo "${BASH_REMATCH[1]}")

      task_definition_images["$task_definition_arn"]=$image
      task_definition_revisions["$task_definition_arn"]=$revision
      task_definition_revisions_to_arns["$revision"]=$task_definition_arn
      task_definition_image_tags["$task_definition_arn"]=$image_tag
    done

    # get git commit comments
    if [[ $GIT_COMMENTS == true ]]; then
      echo "Loading git commit comments..."
      if ! cd "$(ecs_service_to_project_dir "$selected_service" "$selected_cluster")" ; then 
        echo "ERROR: failed to get $selected_service directory"
        exit 1
      fi

      for task_definition_arn in "${task_definition_arns[@]}"; do
        image_tag="${task_definition_image_tags["$task_definition_arn"]}"
        git_commit_comment="$(git log --format=%B -n 1 "$image_tag" 2>/dev/null | head -n 1)"

        task_definition_commit_comments["$task_definition_arn"]=$git_commit_comment
      done
    
      if ! cd - >>/dev/null ; then 
        echo "ERROR: failed to change directory"
        exit 1
      fi
    fi

    # generate menu options
    task_definition_menu_options=()
    for task_definition_arn in "${task_definition_arns[@]}"; do
      revision_number="${task_definition_revisions[$task_definition_arn]}"
      image_tag="Image Tag: ${task_definition_image_tags[$task_definition_arn]}"
      commit_comment=$([[ -n $GIT_COMMENTS ]] && echo " - Commit: ${task_definition_commit_comments[$task_definition_arn]}")

      task_definition_menu_options+=("$revision_number" "$image_tag$commit_comment")      
    done

    # display menu
    menu_action="Service: $selected_service\\nSelect Task Definition Revision to Rollback to"
    exec 3>&1
    dialog_menu_result=$(
      dialog --title "$SCRIPT_NAME" \
             --backtitle "$BACK_TITLE" \
             --clear  \
             --cancel-label "Cancel" \
             --menu "$menu_action:" 0 0 5 "${task_definition_menu_options[@]}" \
             2>&1 1>&3
    )
    dialog_exit_status=$?; clear; exec 3>&-
    process_dialog_exit "$dialog_exit_status"

    # save result
    selected_task_definition_arn="${task_definition_revisions_to_arns["$dialog_menu_result"]}"
    description="
    Service: $selected_service
    New task definition: $selected_task_definition_arn
      - revision: ${task_definition_revisions[$selected_task_definition_arn]}
      - image: ${task_definition_images[$selected_task_definition_arn]}
      - commit comment: ${task_definition_commit_comments[$selected_task_definition_arn]}
    "

    selected_task_definitions["$selected_service"]=$selected_task_definition_arn
    selected_task_definition_descriptions["$selected_service"]=$description
  done


  # Confirm Changes
  # ------------------------------------------------
  menu_action="Are you sure you want to apply the selected rollbacks?\\n\\n"
  for selected_service in "${!selected_task_definitions[@]}"; do
    menu_action+="${selected_task_definition_descriptions[$selected_service]}"
  done
  menu_action+="\\nRemeber to rollback related data migrations!"

  menu_height=$((7 + "${#selected_task_definitions[@]}" * 6))

  exec 3>&1
  dialog_menu_result=$(
    dialog --title "$SCRIPT_NAME" \
           --backtitle "$BACK_TITLE" \
           --clear  \
           --yes-label 'Rollback' \
           --no-label 'Cancel' \
           --cancel-label "Cancel" \
           --cr-wrap \
           --yesno "$menu_action" $menu_height 160 \
           2>&1 1>&3
  )
  dialog_exit_status=$?; clear; exec 3>&-
  process_dialog_exit "$dialog_exit_status"

  function log {
    echo "[$(date +"%T")] $@"
  }

  echo '############################################################'
  echo 'AWS ECS Rollback'
  echo '############################################################'
  log "Cluster: $selected_cluster"
  for selected_service in "${!selected_task_definitions[@]}"; do
    log
    log 'Rolling back service...'
    log "${selected_task_definition_descriptions[$selected_service]}"
    aws ecs update-service --cluster "$selected_cluster" \
                           --service "$selected_service" \
                           --task-definition "${selected_task_definitions[$selected_service]}" \
                           >/dev/null
    
    log 'Service task definition updated'
  done

  echo
  echo '############################################################'
  echo 'Rollback Complete'
  echo '############################################################'
}

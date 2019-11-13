#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

default_interval_in_seconds=10;
default_hooks_file="$script_dir""/git-repo-watcher-hooks"

print_usage() {
    echo ""
    echo "NAME"
    echo "    git-repo-watcher -- keeps a git repository in sync with its origin"
    echo "SYNOPSIS"
    echo "    git-repo-watcher -d <directory> [-h <hooks-file>] [-i <interval>]"
    echo "DESCRIPTION"
    echo "    The following options are available:"
    echo "    -d    The path to the git repository"
    echo "    -i    Watch interval time in seconds (defaults to 10 seconds)"
    echo "    -h    Custom hooks file"
    echo ""
    exit 1;
}

while getopts ":d:i:h:" options; do
    case "${options}" in
        d)
            git_repository_dir=${OPTARG};
            ;;
        h)
            hooks_file=${OPTARG};
            ;;
        i)
            interval_in_seconds=${OPTARG};
            ;;
        *)
            print_usage;
            ;;
    esac
done
shift $((OPTIND-1))

# Validating given git directory

if [[ -z "${git_repository_dir}" ]]; then
    echo -e "\nERROR: Git directory (-d) not given!" >&2;
    print_usage
fi

if [[ ! -d "${git_repository_dir}/.git" ]] || [[ ! -r "${git_repository_dir}/.git" ]]; then
    echo "ERROR: Git directory (-d) not found: '$git_repository_dir/.git'!" >&2
    print_usage
fi

if [[ ! -w "${git_repository_dir}" ]]; then
    echo "ERROR: Missing write permissions for the git directory (-d): '$git_repository_dir/.git'!" >&2
    print_usage
fi

# Validating given hook file

[[ -z "${hooks_file}" ]] && hooks_file="$default_hooks_file"

if [[ -f "${hooks_file}" ]] && [[ -r "${hooks_file}" ]]; then
    source "${hooks_file}"
else
    echo "ERROR: Hooks (-h) file not found: '$hooks_file'" >&2
    print_usage
fi

# Validating given interval

if [[ -z "$interval_in_seconds" ]]; then
    interval_in_seconds="$default_interval_in_seconds"
fi

if [[ ! "$interval_in_seconds" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]]; then
    echo "ERROR: Interval (-i) is not a valid number: '$interval_in_seconds'" >&2
    print_usage
fi

if (( $(echo "$interval_in_seconds < 0.1" | bc -l) )); then
    echo "ERROR: Interval (-i) should be greater than '0.1'" >&2
    print_usage
fi

# Executes user hooks
#
# $1    - Hook name
# $2-$4 - Hook arguments
hook() {
    hook_name="$1"
    if [[ "$(type -t "$hook_name")" = "function" ]]; then
        eval "$hook_name '$2' '$3' '$4'"
    fi
}

# Pulls commit from remote git repository
#
# $1 - Git repository name
# $2 - Branch name
pull_change() {
    git pull
    exit_code=$?

    commit_message=$(git log -1 --pretty=format:"%h | %an | %ad | %s" | sed "s/\"/'/g" | sed "s/\`/'/g")

    if [ $exit_code -eq 1 ]; then
        hook "pull_failed" "$1" "$2" "$commit_message"
    else
        hook "change_pulled" "$1" "$2" "$commit_message"
    fi
}

while [[ true ]]; do

    cd "$git_repository_dir"

    if [[ -f ".git/index.lock" ]]; then
        echo "ERROR: Git repository is locked, waiting to unlock" >&2
        sleep $interval_in_seconds
        continue
    fi

    git fetch

    repo_name=$(basename -s .git `git config --get remote.origin.url`)

    previous_branch="$branch"
    branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

    if [[ -z $branch ]]; then
        echo "ERROR: Unable to get branch" >&2
        exit 1
    fi

    if [[ ! -z $previous_branch ]] && [[ "$previous_branch" != "$branch" ]]; then
        hook "branch_changed" "$repo_name" "$branch" "$previous_branch"
    fi

    upstream="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)"

    # upstream was not configured
    if [[ -z "$upstream" ]]; then
        hook "upstream_not_set" "$repo_name" "$branch"
        sleep $interval_in_seconds
        continue
    fi

    git_local=$(git rev-parse @)
    git_remote=$(git rev-parse "$upstream")
    git_base=$(git merge-base @ "$upstream")

    if [[ -z $started ]]; then
        started=true;
        hook "startup" "$repo_name" "$branch"
    fi

    if [[ "$git_local" = "$git_remote" ]]; then
        hook "no_changes" "$repo_name" "$branch"
    elif [[ "$git_local" = "$git_base" ]]; then
        hook "pull_change" "$repo_name" "$branch"
    elif [[ "$git_remote" = "$git_base" ]]; then
        hook "local_change" "$repo_name" "$branch"
    else
        hook "diverged" "$repo_name" "$branch"
    fi

    sleep $interval_in_seconds

done

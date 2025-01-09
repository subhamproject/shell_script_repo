#!/bin/bash

# Function to configure an AWS SSO profile
configure_aws_sso_profile() {
    local profile_name="$1"
    local sso_start_url="$2"
    local sso_region="$3"
    local sso_account_id="$4"
    local sso_role_name="$5"

    aws configure set profile.${profile_name}.sso_start_url "${sso_start_url}"
    aws configure set profile.${profile_name}.sso_region "${sso_region}"
    aws configure set profile.${profile_name}.sso_account_id "${sso_account_id}"
    aws configure set profile.${profile_name}.sso_role_name "${sso_role_name}"
    aws configure set profile.${profile_name}.region "${sso_region}"

    echo "Configured AWS SSO profile: ${profile_name}"
}

# Example SSO configuration for multiple accounts
configure_aws_sso_profile "account1" "https://your-sso-start-url.awsapps.com/start" "us-west-2" "123456789012" "AWSAdministratorAccess"
configure_aws_sso_profile "account2" "https://your-sso-start-url.awsapps.com/start" "us-west-2" "210987654321" "PowerUserAccess"

echo "AWS SSO profiles configured successfully."















#!/bin/bash

# Function to list and activate AWS SSO profiles
activate_aws_sso_profiles() {
    echo "Available AWS SSO profiles:"
    aws configure list-profiles | grep -E '^account[0-9]+' # List profiles matching the pattern

    echo "Please enter the profile name to activate (or type 'exit' to quit):"
    while read -r profile_name; do
        if [[ "$profile_name" == "exit" ]]; then
            echo "Exiting."
            break
        fi

        if aws configure list-profiles | grep -q "^${profile_name}$"; then
            echo "Activating AWS SSO profile: ${profile_name}"
            aws sso login --profile "${profile_name}"
            echo "Profile ${profile_name} activated."
        else
            echo "Profile ${profile_name} not found. Please try again."
        fi
        echo "Enter another profile name to activate (or type 'exit' to quit):"
    done
}

# Activate profiles
activate_aws_sso_profiles

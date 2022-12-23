#https://gist.github.com/kgmoore431/886aa60cd7fdc9a43bc5c05f9e956adf
#!/bin/bash

user_name="$1"

echo "Removing user: ${user_name}"

echo "Deleting Access Keys:"
keys=("$(aws iam list-access-keys --user-name "${user_name}" | jq -r '.AccessKeyMetadata[] | .AccessKeyId')")
if [[ "${#keys}" -gt "0" ]]; then
    # shellcheck disable=SC2068
    for key in ${keys[@]}; do
        echo -e "\tDeleting access key ${key}"
        aws iam delete-access-key --user-name "${user_name}" --access-key-id "${key}"
    done
fi

echo "Deleting Signing Certificates:"
certs=("$(aws iam list-signing-certificates --user-name "${user_name}" | jq -r '.Certificates[] | .CertificateId')")
if [[ "${#certs}" -gt "0" ]]; then
    # shellcheck disable=SC2068
    for cert in ${certs[@]}; do
        echo -e "\tDeleting cert ${cert}"
        aws iam delete-signing-certificate --user-name "${user_name}"  --certificate-id "$cert"
    done
fi

echo "Deleting Login Profile"
# shellcheck disable=SC2091
if $(aws iam get-login-profile --user-name "${user_name}" &>/dev/null); then
    aws iam delete-login-profile --user-name "${user_name}"
fi

echo "Deleting User's 2FA Devices:"
devs=("$(aws iam list-mfa-devices --user-name "${user_name}" | jq -r '.MFADevices[] | .SerialNumber')")
if [[ "${#devs}" -gt "0" ]]; then
    # shellcheck disable=SC2068
    for mfa_dev in ${devs[@]}; do
        echo -e "\tDeleting MFA ${mfa_dev}"
        aws iam deactivate-mfa-device --user-name "${user_name}"  --serial-number "${mfa_dev}"
    done
fi

echo "Removing Attached User Policies:"
pols=("$(aws iam list-attached-user-policies --user-name "${user_name}" | jq -r '.AttachedPolicies[] | .PolicyArn')")
if [[ "${#pols}" -gt "0" ]]; then
    # shellcheck disable=SC2068
    for policy in ${pols[@]}; do
        echo -e "\tDetaching user policy $(basename "${policy}")"
        aws iam detach-user-policy \
        --user-name "${user_name}" \
        --policy-arn "${policy}"
    done
fi

echo "Deleting Inline Policies:"
inline_policies=("$(aws iam list-user-policies --user-name "${user_name}" | jq -r '.PolicyNames[]')")

# shellcheck disable=SC2068
for inline_policy in ${inline_policies[@]}; do
    echo -e "\tDeleting inline policy ${inline_policy}"
    aws iam delete-user-policy \
        --user-name "${user_name}" \
        --policy-name "${inline_policy}"
done

echo "Removing Group Memberships:"
groups=("$(aws iam list-groups-for-user --user-name "${user_name}" | jq -r '.Groups[] | .GroupName')")
# shellcheck disable=SC2068
for group in ${groups[@]}; do
    echo -e "\tRemoving user from group ${group}"
    aws iam remove-user-from-group \
        --group-name "${group}" \
        --user-name "${user_name}"
done

echo "Deleting User"
 aws iam delete-user --user-name "${user_name}"

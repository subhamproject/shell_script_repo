#!/bin/bash

echo -e "Please enter your password: \c"
read pass
readonly re_digit='[[:digit:]]'
readonly re_lower='[[:lower:]]'
readonly re_punct='[[:punct:]]'
readonly re_space='[[:space:]]'
readonly re_upper='[[:upper:]]'

for re in "$re_digit" "$re_lower" "$re_punct" "$re_upper" "8"
do
[[ ${pass} =~ $re ]] || [[ ${#pass} =~ $re ]]
done
[ $? -eq 0 ] && echo "Met all requirement" || echo "not met all the requirement"


===============================================================================================================

#!/bin/bash
echo -e "please enter password: \c"
read pass
count=`echo ${#pass}`
if [[ $count -ne 12 ]];then
echo "Password length should be 8 charactore"
exit 1;
fi

echo $pass | grep "[A-Z]" | grep "[a-z]" | grep "[0-9]" | grep "[@#$%^&*]" >> /dev/null
if [[ $? -ne 0 ]];then
echo "Password Must contain upparcase ,lowecase,number and special charactor"
exit 2;
else
echo "Password met requirement"
fi





#! /bin/bash -
input=${*:-'RaamKuumabbbb'}

tmp=$input
arr=()
maxlen=0
maxchar=''
while ((${#tmp})); do
    firstchar=${tmp:0:1}
    next=${tmp//"$firstchar"}
    len=$((${#tmp}-${#next}))
    arr+=("$firstchar: $len")
    if ((maxlen<len)); then
    maxlen=$len
    maxchar=$firstchar
    fi
    tmp=$next
done

printf '%s\n' "${arr[@]}" 
echo "The char \"$maxchar\" appear $maxlen times in \"$input\""

#https://www.unix.com/shell-programming-and-scripting/174734-reading-arguments-shell-script-file.html
while read x y
do
    ./shscript $x $y
done < parameters.txt

$ cat parameters.txt
env1 value1
env1 value2
env2 value3
env3 value4
env1 value5
env3 value6
env2 value7

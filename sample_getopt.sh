!/bin/bash 

while getopts "h-:" opt; do 
if [ "$opt" == "-" ]; then opt=$OPTARG; fi; 
case $opt in 
h|help) 
echo "You need help I am not trained or licensed to provide." 
exit 0 
;; 
*) 
echo "Invalid option" 
exit 1 
;; 
esac 
done

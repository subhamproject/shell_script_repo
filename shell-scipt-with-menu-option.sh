#!/bin/bash
#Menu options
options[0]="df -h"
options[1]="ls -l"
options[2]="df"
options[3]="ls -ltr"
options[4]="cat /etc/passwd"
options[5]="df -h;ls -l;df;cat /etc/passwd"

#Actions to take based on selection
function ACTIONS {
    if [[ ${choices[0]} ]]; then
        eval "${options[0]}"
    fi
    if [[ ${choices[1]} ]]; then
       eval "${options[1]}"
    fi
    if [[ ${choices[2]} ]]; then
       eval "${options[2]}"
    fi
    if [[ ${choices[3]} ]]; then
       eval "${options[3]}"
    fi
    if [[ ${choices[4]} ]]; then
       eval "${options[4]}"
    fi
    if [[ ${choices[5]} ]]; then
       eval "${options[5]}"
    fi
}

#Variables
ERROR=" "

#Clear screen for menu
clear

#Menu function
function MENU {
    echo "Menu Options"
    for NUM in ${!options[@]}; do
        echo "[""${choices[NUM]:- }""]" $(( NUM+1 ))") ${options[NUM]}"
    done
    echo "$ERROR"
}

#Menu loop
while MENU && read -e -p "Select the desired options using their number (again to uncheck, ENTER when done): " -n1 SELECTION && [[ -n "$SELECTION" ]]; do
    clear
    if [[ "$SELECTION" == *[[:digit:]]* && $SELECTION -ge 1 && $SELECTION -le ${#options[@]} ]]; then
        (( SELECTION-- ))
        if [[ "${choices[SELECTION]}" == "+" ]]; then
            choices[SELECTION]=""
        else
            choices[SELECTION]="+"
        fi
            ERROR=" "
    else
        ERROR="Invalid option: $SELECTION"
    fi
done

ACTIONS

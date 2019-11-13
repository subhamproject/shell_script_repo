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

=============================================================================

#!/bin/ksh
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-fb] [-B n] [-F[name]] files ...
#%
#% DESCRIPTION
#%    This is a script example
#%    to show how to use getopts with long options.
#%
#% OPTIONS
#%    -f, --foo                  set foo setting (default)
#%    -b, --bar                  set bar setting
#%    -B n, --barfoo=n           set barfoo to number n (default=2)
#%    -F [name], --foobar=[name] set foobar and foobar_name
#%    -h, --help                 print this help
#-
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} (www.uxora.com) 0.0.2
#-    author          Michel VONGVILAY
#-    copyright       Copyright (c) http://www.uxora.com
#-    license         GNU General Public License
#================================================================

  #== general functions ==#
usage() { printf "Usage: "; head -50 ${0} | grep "^#+" | sed -e "s/^#+[ ]*//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ; }
usagefull() { head -50 ${0} | grep -e "^#[%+-]" | sed -e "s/^#[%+-]//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ; }

#============================
#  SET VARIABLES
#============================
unset SCRIPT_NAME SCRIPT_OPTS ARRAY_OPTS

  #== general variables ==#
SCRIPT_NAME="$(basename ${0})"
OptFull=$@
OptNum=$#

  #== program variables ==#
foo=1 bar=0
barfoo=2 foobar=0
foobar_name=

#============================
#  OPTIONS WITH GETOPTS
#============================

  #== set short options ==#
SCRIPT_OPTS=':fbF:B:-:h'
  #== set long options associated with short one ==#
typeset -A ARRAY_OPTS
ARRAY_OPTS=(
	[foo]=f
	[bar]=b
	[foobar]=F
	[barfoo]=B
	[help]=h
	[man]=h
)

  #== parse options ==#
while getopts ${SCRIPT_OPTS} OPTION ; do
	#== translate long options to short ==#
	if [[ "x$OPTION" == "x-" ]]; then
		LONG_OPTION=$OPTARG
		LONG_OPTARG=$(echo $LONG_OPTION | grep "=" | cut -d'=' -f2)
		LONG_OPTIND=-1
		[[ "x$LONG_OPTARG" = "x" ]] && LONG_OPTIND=$OPTIND || LONG_OPTION=$(echo $OPTARG | cut -d'=' -f1)
		[[ $LONG_OPTIND -ne -1 ]] && eval LONG_OPTARG="\$$LONG_OPTIND"
		OPTION=${ARRAY_OPTS[$LONG_OPTION]}
		[[ "x$OPTION" = "x" ]] &&  OPTION="?" OPTARG="-$LONG_OPTION"
		
		if [[ $( echo "${SCRIPT_OPTS}" | grep -c "${OPTION}:" ) -eq 1 ]]; then
			if [[ "x${LONG_OPTARG}" = "x" ]] || [[ "${LONG_OPTARG}" = -* ]]; then 
				OPTION=":" OPTARG="-$LONG_OPTION"
			else
				OPTARG="$LONG_OPTARG";
				if [[ $LONG_OPTIND -ne -1 ]]; then
					[[ $OPTIND -le $Optnum ]] && OPTIND=$(( $OPTIND+1 ))
					shift $OPTIND
					OPTIND=1
				fi
			fi
		fi
	fi

	#== options follow by another option instead of argument ==#
	if [[ "x${OPTION}" != "x:" ]] && [[ "x${OPTION}" != "x?" ]] && [[ "${OPTARG}" = -* ]]; then 
		OPTARG="$OPTION" OPTION=":"
	fi
  
	#== manage options ==#
	case "$OPTION" in
		f  ) foo=1 bar=0                    ;;
		b  ) foo=0 bar=1                    ;;
		B  ) barfoo=${OPTARG}               ;;
		F  ) foobar=1 && foobar_name=${OPTARG} ;;
		h ) usagefull && exit 0 ;;
		: ) echo "${SCRIPT_NAME}: -$OPTARG: option requires an argument" >&2 && usage >&2 && exit 99 ;;
		? ) echo "${SCRIPT_NAME}: -$OPTARG: unknown option" >&2 && usage >&2 && exit 99 ;;
	esac
done
shift $((${OPTIND} - 1))

#============================
#  MAIN SCRIPT
#============================

  #== print variables ==#
echo foo=$foo bar=$bar
echo barfoo=$barfoo
echo foobar=$foobar foobar_name=$foobar_name
echo files=$@

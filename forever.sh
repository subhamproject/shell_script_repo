#!/bin/bash
# This is an example of a (bash) shell script that uses the forever module ([1])
# to start and stop a CoffeeScript application as if it were a service.
#
# [1] <https://github.com/nodejitsu/forever>


# ASSUMPTIONS
################################################################################
# 1) You've got a CoffeeScript program you want to run via `forever`.
#    To use plain Node.js/SSJS, remove the bits about `COFFEE_EXE`
#    and change the `forever` command within the `start()` routine.
#   
#
# 2) You've got a configuration file at `config/NODE_ENV.json` (where
#    `NODE_ENV` is the value of the corresponding environment variable).
#    If you don't care about this, remove the bits about checking
#    for `NODE_ENV` and `config/NODE_ENV.json`.
#
# 3) `coffee` is already in your path or lives at `./node_modules/.bin`.
#
# 4) `forever` is already in your path or lives at `./node_modules/.bin`.
#
# 5) The CoffeeScript file you want to run is located at 
#    `./lib/APP-NAME.coffee`, where `APP-NAME` is the name of this file.



# CONFIGURATION
################################################################################

APP="lib/${0}"
CONFIG_DIR="./config"
LOGFILE="forever-`basename $0`.log"
OUTFILE="forever-`basename $0`.out"
ERRFILE="forever-`basename $0`.err"

## DISCOVER COFFEE EXE
if command -v coffee >/dev/null 2>&1; then
  COFFEE_EXE="coffee"
else
  COFFEE_EXE="./node_modules/.bin/coffee"
fi

## DISCOVER FOREVER EXE
if command -v forever >/dev/null 2>&1 ; then
  FOREVER_EXE="forever"
else
  FOREVER_EXE="./node_modules/.bin/forever"
fi

# ROUTINES
################################################################################

usage() {
  echo "Usage: `basename $0` {start|stop|restart|status|checkenv}" >&2;
}

start() {
  # check for NODE_ENV before launching (but launch anyway)
  if [[ -z "${NODE_ENV}" ]]; then
    echo -e "\n!WARNING! You probably want to set the NODE_ENV environment variable.\n"
  fi
  ${FOREVER_EXE} start -a -l ${LOGFILE} -o ${OUTFILE} -e ${ERRFILE} -c ${COFFEE_EXE} ${APP};
}

stop() { ${FOREVER_EXE} stop ${APP}; }

status() { ${FOREVER_EXE} list; }

checkenv() {
  STATUS=0
  echo -e "\nChecking prerequisites.\n"

  # check for NODE_ENV
  if [[ ! -z "${NODE_ENV}" ]]; then
    echo -e "NODE_ENV: SET - ${NODE_ENV}\n"
  else
    echo -e "NODE_ENV: NOT SET\n"
    echo -e "!WARNING! You probably want to set the NODE_ENV environment variable.\n"
  fi

  # check for config/NODE_ENV.json
  if [[ -e "${CONFIG_DIR}/${NODE_ENV}.json" ]]; then
    echo -e "  CONFIG: FOUND - ${CONFIG_DIR}/${NODE_ENV}.json\n"
  else
    echo -e "  CONFIG: NOT FOUND - ${CONFIG_DIR}/${NODE_ENV}.json"
    echo -e "!WARNING! You probably want to ensure that the file ${CONFIG_DIR}/[NODE_ENV].json exists.\n"
    STATUS=3
  fi

  # check for coffee
  if command -v ${COFFEE_EXE} >/dev/null 2>&1; then
    echo -e "  COFFEE: FOUND - ${COFFEE_EXE}\n"
  else
    echo "  COFFEE: NOT FOUND - ${COFFEE_EXE}"
    echo -e "!WARNING! The coffee executable could not be found. Is it in your PATH?\n"
    STATUS=4
  fi

  # check for forever
  if command -v ${FOREVER_EXE} >/dev/null 2>&1; then
    echo -e " FOREVER: FOUND - ${FOREVER_EXE}\n"
  else
    echo " FOREVER: NOT FOUND - ${FOREVER_EXE}"
    echo -e "!WARNING! The forever executable could not be found. Is it in your PATH?\n"
    STATUS=5
  fi

  # report status
  if [ $STATUS -ne 0 ]; then
    echo -e "!WARNING! Required files or programs not found.\n          The application may not work properly.\n"
  else
    echo -e "Everything seems to check out OK.\n"
  fi
  exit $STATUS
}


# MAIN LOOP
################################################################################

if [[ -z "${1}" ]]; then
  usage
  exit 1
else
  case "$1" in
    start)
      start;
      ;;
    restart)
      stop; sleep 1; start;
      ;;
    stop)
      stop
      ;;
    status)
      status
      ;;
    checkenv)
      checkenv $1
      ;;
    *)
      usage
      exit 6
      ;;
  esac

  exit 0
fi

################################################################################
# (eof)

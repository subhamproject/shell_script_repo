#!/bin/bash

function1 ()
{
  echo "January"
}

function2 ()
{
  case $1 in
    January) echo "Dzisiaj mamy styczen" ;;
    *      ) ;;
  esac
}

main ()
{
  Month=$( function2 $(function1) )
  echo "$Month"
}

main

exit 0 
# finis

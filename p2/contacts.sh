#!/bin/bash

leArgs="$@"
fileName="contactlist.txt"
sortField="2,2"

# exit functions
function firstErr() { echo  "ERROR: Provide a first name using -f." >&2; exit 1;}
function lastErr()  { echo  "ERROR: Provide a last name using -l." >&2; exit 2;}
function emailErr() { echo  "ERROR: Provide an valid email address using -e." >&2;}
function phoneErr() { echo  "ERROR: Provide a valid phone number using -n." >&2;}
function usage() { echo -e "\nERROR: Please specify:\n- first name\t -f <name>\n- last name\t\
 -l <name>\n- email address\t -e <email>\n- phone number\t -n <phone number>" >&2; exit 7;}

# Parse optional flags
function optionals() {
  while getopts ":k:c:" optional; do
    case $optional in
    'k')
      if [[ $OPTARG =~ [1-4] ]]; then
        sortField="$OPTARG,$OPTARG"
      else
        exit 6
      fi
      ;;
    'c')
      if [ -n "$OPTARG" ]; then
        fileName=$OPTARG
      else
        echo "Give a filename."
        exit 5
      fi
      ;;
    esac
  done
} 

function body() {
      IFS= read -r header
          printf '%s\n' "$header"
              "$@"
}

# function to add an entry because why not make it a function
function addEntry(){
  echo $firstName":"$lastName":"$emailAddr":"$phoneNum >> $fileName
}

# arg parsing function to give more specific error codes
function parseArgs () {
  local hasF=0
  local hasL=0
  local hasE=0
  local hasN=0

  while getopts 'f:l:e:n:c:k:' opt "$@"; do
    case $opt in
    'f')
        if [ -n "$OPTARG" ]; then
          firstName="$OPTARG"
          hasF=1
        fi;;
    'l')
        if [ -n "$OPTARG" ]; then
          lastName="$OPTARG"
          hasL=1
        fi;;
    'e')
        # ugly email regex incoming...
        if [ -n "$OPTARG" ]; then
          regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
          if [[ "$OPTARG" =~ $regex ]]; then
            emailAddr="$OPTARG"
            hasE=1
          else
            hasE=2
          fi
        fi;;
    'n')
        #  ugly phone regex incoming...
        if [ -n "$OPTARG" ]; then
          if [[ $OPTARG =~ ^([0-9]( |-)?)?(\(?[0-9]{3}\)?|[0-9]{3})( |-)?([0-9]{3}(
            |-)?[0-9]{4}|[a-zA-Z0-9]{7}) ]]; then
            phoneNum="$OPTARG"
            hasN=1
          else
            hasN=2
          fi
        fi;; 
    'k')
      if [[ $OPTARG =~ [1-4] ]]; then
        sortField="$OPTARG,$OPTARG"
      else
        exit 6
      fi
      ;;
    'c')
      if [ -n "$OPTARG" ]; then
        fileName=$OPTARG
      else
        echo "Give a filename."
        exit 5
      fi
      ;;
    esac
  done

  # I used ":" to continue since the if's used to have echo statements for debugging
  if [ $hasF -ne 0 ]; then
    :
  else
    firstErr
  fi
  if [ $hasL -ne 0 ]; then
    : 
  else
    lastErr
  fi
  if [ $hasE -eq 1 ]; then
    : 
  elif [ $hasE -eq 2 ]; then
    emailErr
    exit 9
  else
    emailErr
    exit 3
  fi
  if [ $hasN -eq 1 ]; then
    : 
  elif [ $hasN -eq 2 ]; then
    phoneErr
    exit 10
  else
    phoneErr
    exit 4
  fi
}


function printTable(){
  optionals $leArgs
  awk ' BEGIN { FS=":"; OFS = "\t"; print "FIRST", "LAST", "EMAIL", "PHONE\n" } 
  { printf("%.18s %.18s %.30s %.15s\n", $1, $2, $3, $4)}' $fileName | column -t | body sort -k$sortField
}

# Insert an exit!!! :wq
function findEm(){
  optionals $leArgs
  egrep $2 $fileName > search.txt || echo "No results." 
  fileName="search.txt"
  printTable
}

# listen for options -i -p -s -k or -c
# the preceding colon puts getopts in silent error reporting mode
while getopts ":k:c:ips:" opt; do
  case $opt in 
    i)
      parseArgs $leArgs
      addEntry;;
    p)
      printTable 
      ;; 
    s)
      findEm $leArgs
      ;;
    k)
      if [[ $OPTARG =~ [1-4] ]]; then
        sortField="$OPTARG,$OPTARG"
      else
        exit 6
      fi
      ;;
    c)
      if [ -n "$OPTARG" ]; then
        fileName=$OPTARG
      else
        echo "Give a filename."
        exit 5
      fi
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 7
      ;;
    :)
      echo "Option -$OPTARG requires a file to be specified." >&2
      exit 5
      ;;
  esac
done
exit 0

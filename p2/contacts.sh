#!/bin/bash

leArgs="$@"
echo $leArgs " these are all arguments"

# exit functions
function firstErr() { echo  "ERROR: Provide a first name using -f." >&2; exit 1;}
function lastErr()  { echo  "ERROR: Provide a last name using -l." >&2; exit 2;}
function emailErr() { echo  "ERROR: Provide an valid email address using -e." >&2; exit 3;}
function phoneErr() { echo  "ERROR: Provide a valid phone number using -n." >&2; exit 4;}
function usage() { echo -e "\nERROR: Please specify:\n- first name\t -f <name>\n- last name\t\
 -l <name>\n- email address\t -e <email>\n- phone number\t -n <phone number>" >&2; exit 7;}

# function to add an entry because why not make it a function
function addEntry(){
  echo $firstName":"$lastName":"$emailAddr":"$phoneNum >> contactlist.txt
}

# arg parsing function to give more specific error codes
function parseArgs () {
  local hasF=0
  local hasL=0
  local hasE=0
  local hasN=0

  while getopts 'f:l:e:n:' opt "$@"; do
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
        if [ -n "$OPTARG" ]; then
          regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
          if [[ "$OPTARG" =~ $regex ]]; then
            emailAddr="$OPTARG"
            hasE=1
          fi
        fi;;
    'n')
        if [ -n "$OPTARG" ]; then
          if [[ $OPTARG =~ ^([0-9]( |-)?)?(\(?[0-9]{3}\)?|[0-9]{3})( |-)?([0-9]{3}(
            |-)?[0-9]{4}|[a-zA-Z0-9]{7}) ]]; then
            phoneNum="$OPTARG"
            hasN=1
          fi
        fi;;
    esac
  done

  if [ $hasF -ne 0 ]; then
    echo "First name acquired."
  else
    firstErr
  fi
  if [ $hasL -ne 0 ]; then
    echo "Last name acquired."
  else
    lastErr
  fi
  if [ $hasE -ne 0 ]; then
    echo "Email acquired."
  else
    emailErr
  fi
  if [ $hasN -ne 0 ]; then
    echo "Phone acquired."
  else
    phoneErr
  fi
}


# !!! Need to figure out how to preserve newlines so that AWK works right
function printTable(){
#  echo -e "FIRST\t:LAST\t:EMAIL\t:PHONE\n$@" > /tmp/list.txt
#  column -t -c 4 -s : /tmp/list.txt
  awk ' BEGIN { FS=":"; OFS = "\t"; print "FIRST", "LAST", "EMAIL", "PHONE\n" } 
  { printf("%.18s %.18s %.30s %.15s\n", $1, $2, $3, $4)}' contactlist.txt | column -t
}

function findEm(){
  echo $@ "is all args"
  results=`egrep $@ contactlist.txt`
  printTable $results
}

# listen for options -i -p -s -k or -c
# the preceding colon puts getopts in silent error reporting mode
while getopts ":ipskc:" opt; do
  case $opt in
    i)
      echo "-i was triggered" >&2
      parseArgs $leArgs
      addEntry;;
    p)
      echo "-p was triggered" >&2
      printTable 
      ;; 
    s)
      echo "-s was triggered" >&2
      findEm $2
      ;;
    k)
      echo "-k was triggered, Parameter: $OPTARG" >&2
      ;;
    c)
      echo "-c was triggered, Parameter: $OPTARG" >&2
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

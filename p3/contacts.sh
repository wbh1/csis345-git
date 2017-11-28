#!/bin/bash
leArgs="$@"
fileName="contactlist.txt"
sortField="2,2"
searchField="0"
editNum="0"

# exit functions
function firstErr() { echo  "ERROR: Provide a first name using -f." >&2; exit 1;}
function lastErr()  { echo  "ERROR: Provide a last name using -l." >&2; exit 2;}
function emailErr() { echo  "ERROR: Provide an valid email address using -e." >&2; exit 3;}
function phoneErr() { echo  "ERROR: Provide a valid phone number using -n." >&2; exit 4;}
function catErr() { echo "ERROR: Provide a valid category using -t." >&2; exit 11;}
function usage() { echo -e "\nERROR: Please specify:\n- first name\t -f <name>\n- last name\t\
 -l <name>\n- email address\t -e <email>\n- phone number\t -n <phone number>" >&2; exit 7;}


# Parse optional flags
function optionals() {
  while getopts ":k:c:LS:N:" optional; do
    case $optional in
    'k')
      if [[ $OPTARG =~ [1-5] ]]; then
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
    'L')
      printFull
      exit 0
      ;;
    'S')
      if [[ $OPTARG =~ [1-5] ]]; then
        searchField="$OPTARG"
      else
        echo "ERROR: Invalid field number"
        exit 6
      fi
      ;;
    'N')
      editNum=$OPTARG
    esac
  done
}

function body() {
      IFS= read -r header
          printf '%s\n' "$header"
              "$@"
}

function numGen() {
  num=`wc -l contactlist.txt 2>/dev/null | awk '{ print $1 }'`
  let "conNum=$num+1"
}

# function to add an entry because why not make it a function
function addEntry(){
  numGen
  echo $firstName":"$lastName":"$emailAddr":"$phoneNum":"$catGore":"$conNum >> $fileName
}

# arg parsing function to give more specific error codes
function parseArgs () {
  local hasF=0
  local hasL=0
  local hasE=0
  local hasN=0
  local hasC=0

  while getopts 'f:l:e:n:t:c:k:' opt "$@"; do
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
    't')
      if [ -n "$OPTARG" ]; then
        catGore="$OPTARG"
        hasC=1
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
  if [ $hasC -ne 0 ]; then
    :
  else
    catErr
  fi
}

function whoPrints(){
  optionals $leArgs
  printTable
}

function printTable(){
  optionals $leArgs
  awk ' BEGIN { FS=":"; OFS = "\t"; print "FIRST", "LAST", "EMAIL", "PHONE", "CATEGORY\n" }
  { printf("%.18s %.18s %.30s %.15s %.10s\n", $1, $2, $3, $4, $5)}' $fileName | column -t | body sort -k$sortField
}


function printFull(){
  optionals $leArgs
  awk ' BEGIN { FS=":"; OFS = "\t"; print "#", "FIRST", "LAST", "EMAIL", "PHONE", "CATEGORY\n" }
  { printf("%s %.18s %.18s %.30s %.15s %.10s\n", $6, $1, $2, $3, $4, $5)}' $fileName | column -t | body sort -k$sortField
}

function findEm(){
  optionals $leArgs
  if awk -v field="$searchField" ' BEGIN { FS=":"; } { print $field, $6 }' $fileName | egrep $searchText > search.txt
  then
    matches=(`awk '{ print $2 }' search.txt`)
    for i in "${matches[@]}"; do
      awk -F: -v i="$i" '$6 == i' $fileName >> result.txt
    done
    fileName="result.txt"
  else
    echo "ERROR: No results"
    exit 9
  fi
}

function editTime(){
  optionals $leArgs
  if [ $editNum -eq 0 ]; then
    findEm
  else
    awk -F: -v i="$editNum" '$6 == i' $fileName > result.txt
  fi

  lines=`wc -l result.txt | awk ' { print $1 } '`
  if [ $lines -gt 1 ]; then
    printFull
    rm -f $fileName search.txt
    echo "ERROR: Too many results. Try using the -N option with the #"
    exit 12
  fi
  # WHY DO I NEED THIS?!?!?!?!?!
  let "OPTIND=$OPTIND-1"
  while getopts 'f:l:e:n:t:' dumb "$@"; do
    case $dumb in
      f)
        if [ -n "$OPTARG" ]; then
          new="$OPTARG"
          old=`awk -F: '{ print $1 }' result.txt`
          sed -i '' "s/$old/$new/" contactlist.txt
        fi;;
    'l')
        if [ -n "$OPTARG" ]; then
          new="$OPTARG"
          old=`awk -F: '{ print $2 }' result.txt`
          sed -i '' "s/$old/$new/" contactlist.txt
        fi;;
    'e')
        # ugly email regex incoming...
        if [ -n "$OPTARG" ]; then
          regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
          if [[ "$OPTARG" =~ $regex ]]; then
            new="$OPTARG"
            old=`awk -F: '{ print $3 }' result.txt`
            sed -i '' "s/$old/$new/" contactlist.txt
          else
            emailErr
            exit 9
          fi
        fi;;
    'n')
        #  ugly phone regex incoming...
        if [ -n "$OPTARG" ]; then
          if [[ $OPTARG =~ ^([0-9]( |-)?)?(\(?[0-9]{3}\)?|[0-9]{3})( |-)?([0-9]{3}(
            |-)?[0-9]{4}|[a-zA-Z0-9]{7}) ]]; then
            new="$OPTARG"
            old=`awk -F: '{ print $4 }' result.txt`
            sed -i '' "s/$old/$new/" contactlist.txt
          else
            phoneErr
            exit 10
          fi
        fi;;
    't')
      if [ -n "$OPTARG" ]; then
        new="$OPTARG"
        old=`awk -F: '{ print $5 }' result.txt`
        sed -i '' "s/$old/$new/" contactlist.txt
      fi;;
    esac
  done

#  replaced=`awk '{ print $6 }' temp.txt`
#  awk -F: -v i="$replaced" '$6 == i' $fileName
  rm -f search.txt result.txt
}

# listen for options -i -p -s -k or -c
# the preceding colon puts getopts in silent error reporting mode
while getopts ":k:c:ips:S:E:O:" opt; do
  case $opt in
    i)
      parseArgs $leArgs
      addEntry;;
    p)
      whoPrints $leArgs
      ;;
    s)
      searchText="$OPTARG"
      findEm
      printTable
      rm search.txt result.txt
      ;;
    k)
      if [[ $OPTARG =~ [1-5] ]]; then
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
    S)
      # Could I fix this to run in whatever order? Sure.
      # Will I? No. It's a feature.
      echo "Don't use -S without -s or -E preceeding it."
      exit 14;;
    E)
      searchText="$OPTARG"
      editTime $leArgs;;
    O)
      echo "ERROR: 404 -- Function not found. Ran out of time."
      exit 1337;;

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

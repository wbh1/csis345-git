#!/bin/bash

while [[ $# -gt 0 ]] && [[ ."$1" = .-* ]] ;
do
  opt="$1";
  shift;          # moves to next argument
  case "$opt" in
    "-i") 
      echo "-i was triggered" >&2
      case "$opt" in
        "-f") firstName="$1"; echo "First: $firstName"; shift;;
        "-l") lastName="$1"; echo "Last: $lastName"; shift;;
        "-e") emailAddr="$1"; echo "Email: $emailAddr"; shift;;
        "-n") phoneNum="$1"; echo "Phone: $phoneNum"; shift;;
      esac
      ;;
   "-p")
      echo "-p was triggered" >&2
      ;; 
   "-s")
      echo "-s was triggered" >&2
      ;;
   "-k")
      echo "-k was triggered, Parameter: $OPTARG" >&2
      ;; 
   "-c")
      echo "-c was triggered, Parameter: $OPTARG" >&2
      ;;
      *)
      echo "Invalid option: $opt" >&2
      exit 7
      ;;
  esac
done

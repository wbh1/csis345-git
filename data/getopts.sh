#!/bin/bash

adams="Samuel"
bread="butter"
carrots="no"
insert="no"
while getopts :if:l:a:b:c flag; do
  case $flag in
		  i)
				insert="yes"
				;;
	    a)
			 adams=$OPTARG
       ;;
	    b)
			 bread=$OPTARG
		    ;;
	    c)
			 carrots="yes"
	      ;;
	    ?)
	      exit;
        ;;
	esac
done

echo "Adams = $adams"
echo "bread=$bread"
if [ $carrots == "yes" ] 
then
  echo "Let's have carrots"
else 
	echo "Carrots are nasty"
fi

if [ $insert == "yes" ]
then
 echo We are inserting a contact. Make sure the other options are specified
fi


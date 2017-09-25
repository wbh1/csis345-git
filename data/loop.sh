#!/bin/bash

i=0
while [[ $i -lt 100 ]]
do
  echo loop:$i
  i=$(($i+1))
  sleep 2
done

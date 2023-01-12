#!/bin/bash

ark_file=$1
echo "Using arks from $ark_file"

exportdir=$2
echo "Exporting to $exportdir "

num=1
for ark in `cat $ark_file`; do
  echo "EXPORT $ark\t$exportdir\t $num"
  /dspace/bin/dspace export -d $exportdir -i $ark -n $num -t ITEM
  ((num=num+1))
  echo ""
done
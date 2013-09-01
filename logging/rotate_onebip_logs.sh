#!/bin/bash

historyLogRoot="/mnt/datas/logs/history"
matchPattern=$(date --date="$retention day ago" '+%Y-%m-%d')


function UsageHowTo() {
echo "2 parameters needed: Usage $0 project(onebip|front|rest|apache2|phplog) retentionDate(number)" && exit $1
}


function checkIfProjectExist() {
[ ! -d $LogRoot ] && echo "the directory $LogRoot was not found" && exit 4
}


function checkRetentionOccurencies() {
if [ $(ls $LogRoot| grep $matchPattern|wc -l) -eq 0 ]
then
	echo "no files founded with this retention, check history log \"$historyLogRoot\" according to the project \"$project\" for already rotated tgz log"
	exit 5
fi
}

[ -z $1 ] || [ -z $2 ] && UsageHowTo 1 

if [[ $2 =~ ^-?[0-9]+$ ]]
then
  echo "ok $2 is a number,searching files with this retention" 
else
echo "the second parameter is not a number ($2), please provide valid field" && exit 2
fi


case $1 in
onebip)
	project=$1
	LogRoot="/mnt/datas/logs/onebip/onebip"
	checkIfProjectExist
	retention=$2
	historyCurrentDir="$historyLogRoot/$1/$matchPattern"
	checkRetentionOccurencies
	mkdir -p $historyCurrentDir
	
;;
front)
	project=$1
	LogRoot="/mnt/datas/logs/onebip/$project"
	checkIfProjectExist
	retention=$2
	historyCurrentDir="$historyLogRoot/$1/$matchPattern"
	checkRetentionOccurencies
	mkdir -p $historyCurrentDir
;;
rest)
	project=$1
	LogRoot="/mnt/datas/logs/onebip/$project"
	checkIfProjectExist
	retention=$2
	historyCurrentDir="$historyLogRoot/$1/$matchPattern"
	checkRetentionOccurencies
	mkdir -p $historyCurrentDir
;;
apache2)
	project=$1
	LogRoot="/mnt/datas/logs/$project"
	checkIfProjectExist
	retention=$2
	historyCurrentDir="$historyLogRoot/$1/$matchPattern"
	checkRetentionOccurencies
	mkdir -p $historyCurrentDir
;;
phplog)
	project=$1
	LogRoot="/mnt/datas/logs/$project"
	checkIfProjectExist
	retention=$2
	historyCurrentDir="$historyLogRoot/$1/$matchPattern"
	checkRetentionOccurencies
	mkdir -p $historyCurrentDir
;;
*)
UsageHowTo 3
esac



for file in $(find $LogRoot -iname "*$(echo $matchPattern).log")
do
   cd $LogRoot
   tar -czf $file.tgz $file && mv $file.tgz $historyCurrentDir &&  rm -f $file
done


#!/bin/bash

Help () {
	echo "gitvalidator.sh"
	echo "Usage:"
	echo "gitvalidator.sh -d [testsuite directory] -r -p -t"
	echo "-r .robot validate line length less than 150"
	echo "-p .py validate line length less than 120"
	echo "-t dos2unix execution"
	exit
};

robotfile=0
pythonfile=0
translate=0
directoryname=null

while getopts d:rpth flag
do
    case "${flag}" in
        d) directoryname=${OPTARG};;
        r) robotfile=1;;
        p) pythonfile=1;;
	t) translate=1;;
	h) Help
    esac
done

if [ -d $directoryname ]; then
	search_dir=$directoryname
else
	echo "Path not Directory"
	Help
fi

echo ""
echo "Using directory"
echo $directoryname
echo ""

if [ $robotfile -eq 1 ]; then
	echo "Validate *.robot line lengts are less 150"
	for entry in "$search_dir"/*.robot
	do
		echo $entry		
		grep -En '.{150}' $entry
		echo ""
	done
fi

if [ $pythonfile -eq 1 ]; then
	echo "Validate *.py line lengts are less 120"
	for entry in "$search_dir"/*.py
	do
		echo $entry
		grep -En '.{120}' $entry
		echo ""
	done
fi

if [ $translate -eq 1 ]; then
	echo "dos to unix translation"
	for entry in "$search_dir"/*
	do
  		if [ -f $entry ]; then
    			echo $entry
    			tr -d '\r' < $entry > $entry.out
    			mv $entry.out $entry
  		fi
	done
fi


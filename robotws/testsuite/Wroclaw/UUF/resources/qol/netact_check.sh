#!/bin/bash
#check netact script
if [[ -z $2 ]]
then
   labnumber=$(>&2 echo -n "Enter lab number: "; read val; echo $val)
   mplane=$(>&2 echo -n "Enter m-plane: "; read val; echo $val)
else
   labnumber=$1
   mplane=$2
fi

if [[ $labnumber == "2001" ]]
then
    password="Gamazda!20"
else
    password="Medsql!_1893"
fi

ipnode=$(host srnclab${labnumber}node01.srnblr.nsn-rdnet.net | awk '/has address/ {print $4}')
echo "checking if m-plane:$mplane is accessible from srnclab$labnumber ($ipnode)"
result=$(sshpass -p $password ssh -tt -q omc@$ipnode timeout 10 wget http://${mplane}:8080/NE3S/1.0/NE3SRegistrationService)

if [[ $3 == "-v" ]]
then
   echo "Raw result:"
   echo $result
fi
if [[ $result == *"ERROR 405:"* ]]
then
   echo "Result:"
   tput setaf 2
   echo "PASSED"
   tput sgr0
else
   echo "Result:"
   tput setaf 1
   echo "FAILED"
   tput sgr0
fi

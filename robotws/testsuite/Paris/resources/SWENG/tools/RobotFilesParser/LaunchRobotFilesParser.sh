#!/bin/bash

# Script purpose: 
# This script must be put with executable right into the Jenkins directory:
# - VM Espoo: 10.183.36.191 
# - log/pwd : ca_psci5g/Welcome123
# - Directory: /home/ca_psci5g/CrtUteCiScripts_2/
#
# Action done by script:
# - step1: create a directory and clone in it the Master branch
# - step2: launch the RobotFilesParser.py tool
# - step3: csv and xlsx files are generated

# No input parameters for the moment. Following will be added one day:
# REPOSITORY_ID=$1
# PATTERN_ID=$2
# FILENAME_ID=$3

# Read JENKINS parameters set by user:
REMOVE_ROBOTWS=${REMOVE_ROBOTWS}

# Some needed variables:
LOCAL_DIR="/ebs/ca_psci5g/RobotFilesParser"
ROBOT_DIR="${LOCAL_DIR}/robotws"
TOOLS_DIR="${ROBOT_DIR}/testsuite/Paris/resources/SWENG/tools/RobotFilesParser"
VENV3_DIR="/ebs/ca_psci5g/VirtualEnv3/bin/activate"
echo ${TOOLS_DIR}
echo "Set the Python3 environment (need to be launched on SQ31-01 or SQ31-02 VM)"
source $VENV3_DIR
pip3 install pandas
pip3 install openpyxl
echo "... DONE !"
echo "REMOVE_ROBOTWS=${REMOVE_ROBOTWS}"

# Remove the robotws directory if requested by user:
if [ "${REMOVE_ROBOTWS}" == "true" ] && [ -d $ROBOT_DIR ]
then
    echo "The Robotws directory is removed as requested..."
    rm -rf $ROBOT_DIR
    echo "... DONE !"
fi

echo "Create Tool directory..."
mkdir $WORKSPACE/archive
mkdir -p /ebs/ca_psci5g/RobotFilesParser/Tools
echo "... DONE !"

# clone or update the robotws:
if [ ! -d $ROBOT_DIR ]
then
    echo "Git Clone Robotws in progress..."
    cd $LOCAL_DIR
    git clone --recursive git@wrgitlab.ext.net.nokia.com:RAN/robotws.git
else
    echo "Git Pull in progress..."
    cd $ROBOT_DIR
    git status
    git pull
fi
echo "... DONE !"

echo "Get then install the tool files"
cd $LOCAL_DIR
cp $TOOLS_DIR/RobotFilesParser.py ./Tools/. 
cp $TOOLS_DIR/RobotFilesParser.ini ./Tools/. 
cp $TOOLS_DIR/RobotFilesParser_config.py ./Tools/. 
echo "... DONE !"

echo "Launch the RobotFileParser tool..."
cd ./Tools
python3  ./RobotFilesParser.py 
echo "... DONE !"

echo "Give access to csv, xlsx and zip Files..."
cp *.csv $WORKSPACE/archive/. 
cp *.xlsx $WORKSPACE/archive/.
cp *.zip $WORKSPACE/archive/.
rm *.csv *.xlsx *.zip
echo "... DONE !"


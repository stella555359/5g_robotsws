#!/bin/bash
#======================================================================================#
#   DESCRIPTION: This script is responsible for updating the gnbMirroring.sh script    #
#                in robotws repo.                                                      #
#                It is being run daily on jenkins to check if the version of           #
#                gnbMirroring script on robotws repo differs from the latest           #
#                version of gnbMirroring script on Tools repo and if it does the       #
#                script performs an update.                                            #
#                                                                                      #
#        AUTHOR:  Damian Zak, damian.zak@nokia.com                                     #
#       VERSION:  1.2                                                                  #
#       CREATED:  23/12/2021                                                           #
#      REVISION:  21/03/2022                                                           #
#======================================================================================#

#Gitlab Personal Access Tokens
TOKEN_ROBOTWS=$1
TOKEN_TOOLS=$2

#Download existing gnbMirroring.sh from robotws repo
bip_script_robotws_path="testsuite%2FKrakow%2FRRM%2FMN_RAN_L2%2Fresources%2FRobot%2FBIP_scripts%2FgnbMirroring.sh"
curl --header "PRIVATE-TOKEN: $TOKEN_ROBOTWS" "https://wrgitlab.ext.net.nokia.com/api/v4/projects/12805/repository/files/${bip_script_robotws_path}?ref=master" > bip_script_robotws_encoded.json

#Exctract the encoded gnbMirroring.sh script from .json file, decode it and redirect to bip_script_robotws_decoded
jq -r '.content' bip_script_robotws_encoded.json | base64 --decode > bip_script_robotws_decoded

# #Get the latest version of gnbMirroring.sh script from tools repo
curl --header "PRIVATE-TOKEN: $TOKEN_TOOLS" "https://gitlabe2.ext.net.nokia.com/api/v4/projects/15911/repository/files/gnbMirroring%2FgnbMirroring.sh?ref=master" > bip_script_tools_encoded.json

#Exctract the encoded gnbMirroring.sh script from .json file, decode it and redirect to bip_script_tools_decoded
jq -r '.content' bip_script_tools_encoded.json | base64 --decode > bip_script_tools_decoded

#Exctract lastest version of the script
lastest_version="$(cat bip_script_tools_decoded | grep -P "V\d+'" | cut -d"'" -f 2)"

#Check if gnbMirroring.sh script on robotws repo differs from the latest gnbMirroring.sh verion tools repo
diff bip_script_tools_decoded bip_script_robotws_decoded

#Get the diff procces exit code[ 1 or 0 ]
diff_process_exit_code=$?

#Update the gnbMirroring.sh script [commit & merge request] only if the file differs from the script that is already on robotws repo 
if [ $diff_process_exit_code == '1' ] 
then
    curl --request POST \
     --form "start_branch=master" \
     --form "branch=other/gnb_mirroring_update" \
     --form "commit_message=Update gnbMirroring script to version: ${lastest_version}" \
     --form "author_email=damian.zak@nokia.com" \
     --form "author_name=Zak Damian" \
     --form "actions[][action]=update" \
     --form "actions[][file_path]=testsuite/Krakow/RRM/MN_RAN_L2/resources/Robot/BIP_scripts/gnbMirroring.sh" \
     --form "actions[][content]=<bip_script_tools_decoded" \
     --form "actions[][execute_filemode]=True" \
     --header "PRIVATE-TOKEN: $TOKEN_ROBOTWS" \
     "https://wrgitlab.ext.net.nokia.com/api/v4/projects/12805/repository/commits"

    curl --request POST  \
     --form "source_branch=other/gnb_mirroring_update" \
     --form "target_branch=master" \
     --form "title=Update gnbMirroring script to version: ${lastest_version}" \
     --form "assignee_id=9618" \
     --form "description='Merge branch other/gnb_mirroring_update into master. Assign: @pajor, @dpiaseck'" \
     --form "remove_source_branch=True" \
     --header "PRIVATE-TOKEN: $TOKEN_ROBOTWS" \
     "https://wrgitlab.ext.net.nokia.com/api/v4/projects/12805/merge_requests"
fi

#Remove bip_script_decoded & bip_script_encoded.json files
rm bip_script_*

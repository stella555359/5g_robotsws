*** Settings ***
Documentation     author: Xiaofei Li
...               contact: xiaofei.li@nokia-sbell.com
...               Remove TAF Log Code and Package case.
Resource           Resource/common.robot
Resource    Resource/upgrade_rollback.robot
Library     Scripts/gnb_handler.py
Variables   Resource/UUF_vars.py
Variables   ../libraries/global_vars.py

Force Tags    SG_08    CA_5G_OAM    AUTHOR_xiaofei.li@nokia-sbell.com
...    PY36

*** Variables ***
${Source_Package}

*** Test Cases ***
Remove TAF Log Code and Package
     [Setup]    csn.connect_to    hostname=${TESTPC_ADDR}    username=${TESTPC_user}    password=${TESTPC_pwd}    alias=taf
     Remove Code and Log from TAF
     Remove Pacakge Except Source Package from TAF
     [Teardown]   csn.disconnect    connection=taf

*** Keywords ***
Remove Code and Log from TAF
    run keyword and ignore error   csn.Execute
    ...   command=find /opt/transformers.dynamic.nsn-net.net/workspace/UUF/Master/Manual/ -mtime +1 -exec rm -rf \{\} \\;  connection=taf
    run keyword and ignore error   csn.Execute
    ...   command=find /opt/transformers.dynamic.nsn-net.net/workspace/CIT/Master/Manual/ -mtime +1 -exec rm -rf \{\} \\;  connection=taf
    run keyword and ignore error   csn.Execute
    ...   command=find /ephemeral/jenkins/workspace/UUF/Master/Manual/ -mtime +1 -exec rm -rf \{\} \\;  connection=taf
    run keyword and ignore error   csn.Execute
    ...   command=find /opt/transformers.dynamic.nsn-net.net/workspace/UUF/Master/Pre-Check_Environment*/ -mtime +1 -exec rm -rf \{\} \\;
    ...   connection=taf
    run keyword and ignore error   csn.Execute
    ...   command=find /opt/uuf_slave_workspace/workspace/UUF/Master/Manual/ -mtime +1 -exec rm -rf \{\} \\;
    ...   connection=taf

Remove Pacakge Except Source Package from TAF
     ${Grep_Command}   set variable   | grep 'AirScale\\|SBTS'
     @{Remove_Version}    Split String   ${Source_Package}   ,
     FOR   ${Delete_version}   IN   @{Remove_Version}
        ${if_common}   run keyword and return status   should contain   ${Delete_version}   SBTS
        ${Single_Grep_Command}    Set Variable if
        ...    ${if_common}    | grep -v "${Delete_version}"
        ...    ${if_common}==${False}    | grep -v "AirScale-${Delete_version}"
        set suite variable    ${Grep_Command}   ${Grep_Command}${Single_Grep_Command}
     END
     ${Package}   csn.Execute
     ...   command=cd /home/ute/;ls ${Grep_Command}
     ...   connection=taf
     ${Remove_Package}   Replace String    ${Package}    \r\n   ${SPACE}
     csn.Execute    command=cd /home/ute/;rm -rf ${Remove_Package}   connection=taf

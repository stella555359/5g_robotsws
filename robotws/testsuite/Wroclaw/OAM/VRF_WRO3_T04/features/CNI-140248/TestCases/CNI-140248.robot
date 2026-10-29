*** Settings ***
Documentation   Keywords for CNI-140240 that trigger soc reset.
...
...  author:  Julia Wijas
...  contact: julia.wijas@nokia.com

Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/alarms/alarm.robot

Library     SSHLibrary

*** Variables ***
${fault_ID_1}=                2087
${fault_ID_2}=                6450
${entity_logs_path}           ${CURDIR}

*** Keywords ***
Triger_SOC_reset
    [Documentation]    Description:     This keyword trigger soc reset by crashing l1 process.
    Change Multiple Parameters on BTS      dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...                                    actForceUnitAutoReset=true
    ...                                    actCategoryAlarms=true
    ...                                    actForceAutoReset=true
    Change Parameter on BTS             dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1
    ...                                 param_name=allowBbPoolRecoveryReset
    ...                                 param_value=true
    SSHLibrary.Open Connection          host=${LMP_IP}
    SSHLibrary.Login                    username=${SSH_USERNAME}      password=${SSH_PASSWORD}
    Log      Getting the right command             console=true
    ${command}=     SSHLIbrary.Execute Command     chk bshsys topo | grep 'slave' | head -n 1 | awk -F'[()]' '{print $2}'
    Sleep    20                          Wait for commend execute
    FOR         ${i}        IN RANGE    3
        SSHLibrary.Write                    ssh ${SSH_USERNAME}@${command}
        ${continue}=                        Run keyword and return status
        ...                                 SSHLibrary.Read Until               expected=(yes/no/[fingerprint])?
        Run keyword if   ${continue}        SSHLibrary.Write                    text=yes
        ...              ELSE               SSHLibrary.Write                    text=wrong_password
        Sleep            20s                reason=Waiting for password prompt...
        SSHLibrary.Read Until               expected=password:
        SSHLibrary.Write                    text=${SSH_PASSWORD}
        Log      Getting number of process to kill     console=true
        SSHLibrary.Write                 ps aux | grep l1 | grep '_nrt'
        Sleep    20                      Wait for commend execute
        ${output}=                       SSHLibrary.Read
        ${output}=                       Get Line    ${output}    -2
        ${output}=                       Get Regexp Matches        ${output}    \\d+
        ${number}=                       Get From List     ${output}     0
        SSHLibrary.Write                 kill -11 ${number}
        Log      Start killing process ${number}   console=true
        Run Keyword If                   ${i}==0       Sleep    120
        Run Keyword If                   ${i}==1       Sleep    120
        Log      Process ${number} is killed  console=true
    END
    Wait Until Keyword Succeeds  5min  60sec    Alarm Should be Active In BTS               fault_id=${fault_ID_1}
    Wait Until Keyword Succeeds  5min  60sec    Alarm Should be Active In BTS               fault_id=${fault_ID_2}
    Collect Snapshot From BTS
    Wait Until Keyword Succeeds    5 min    20 sec    Alarm Should Not Be Active In BTS    fault_id=${fault_ID_1}
    Wait Until Keyword Succeeds    5 min    20 sec    Alarm Should Not Be Active In BTS    fault_id=${fault_ID_2}
    [Teardown]       SSHLibrary.Close Connection


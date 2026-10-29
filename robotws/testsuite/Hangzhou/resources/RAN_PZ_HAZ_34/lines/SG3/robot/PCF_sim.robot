*** Settings ***
Documentation
...    author: Xu Min
...    contact: maxine.xu@nokia-sbell.com
...    squad group: SG_03

Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/ssh_pcf.py
Library    ssh_pcf.pcf   WITH NAME    PCF
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot

** Variables ***


*** Keywords ***
Connect to PCF server
    [Arguments]    ${alias}=${ALIAS_PCF}
    csn.Connect to    hostname=${PCF_IP}
    ...    username=${PCF_username}
    ...    password=${PCF_password}
    ...    alias=${alias}
    [Return]    ${alias}

Exit the PCF service
    Connect to PCF server
    csn.send command  ps -ef | grep sim | grep -v grep | grep 5g | awk '{print $2}' | xargs kill -2    connection=${ALIAS_PCF}
    sleep    5S

Start PCF service
    [Arguments]    ${ims}    ${ip}
    PCF.pcf_connect    ip=${PCF_IP}    username=${PCF_username}    password=${PCF_password}
    PCF.pcf_start    ims=${ims}    ip=${ip}

Configure and commit the QoS
    [Arguments]    ${five_qi}    ${priorityLevel}    ${server_ip}
    PCF.pcf_add_one_QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel}    server_ip=${server_ip}

Configure and commit the QoS with 2 5QI1
    [Arguments]    ${five_qi}    ${priorityLevel1}    ${priorityLevel2}    ${server_ip1}    ${server_ip2}
    PCF.pcf_add_two_5QI1    five_qi=${five_qi}    priorityLevel1=${priorityLevel1}
    ...    priorityLevel2=${priorityLevel2}    server_ip1=${server_ip1}    server_ip2=${server_ip2}
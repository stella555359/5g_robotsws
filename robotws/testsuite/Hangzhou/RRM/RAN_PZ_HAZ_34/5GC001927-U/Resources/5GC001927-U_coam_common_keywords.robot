*** Settings ***
Library     DateTime
#Library     L3Call.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    ./../../5GC001927-T/Resources/5GC001927-T_coam_common_keywords.robot
Variables    ./../../5GC001927-T/Resources/886_variables.py

Documentation
...   author: Shi Ming
...   contact: ming.shi@nokia-sbell.com
...   squad group: SG_03
...   feature : 5GC0001927-U



*** Variables ***
${Bearers_num}    numOfBearers 2


*** Keywords ***
Start capture wireshark log on eNB
    [Arguments]    ${enb_path}    ${filename}     ${interface}=br1    ${connection}=enb
    RUN KEYWORD AND IGNORE ERROR    enb connections
    csn.send command    command=tcpdump -i ${interface} -w ${enb_path}${filename}   connection=${connection}
    sleep    3s

Stop and Save classical Logs on eNB
    [Arguments]    ${enb_path}    ${filename}    ${epc_log_path}    ${connection}=enb
    enb connections
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${enb_path}${filename}   local_path=${epc_log_path}${filename}   connection=${connection}
    sleep    3
    csn.disconnect      connection=${connection}

Caculate the wireshark timevalue
    [Arguments]    ${input_value}    ${index}
    ${list} =    Evaluate    ${input_value}[${index}].split(' ')
    ${list_0} =    Evaluate    ${list}[-2].split(':')
    ${msg_time_sec} =    EVALUATE  float(${list_0}[0])*0+float(${list_0}[1])*60+float(${list_0}[2])*1
    [Return]    ${msg_time_sec}

Sum list value
    [Arguments]    ${counter_result}
    ${length}    Get Length    ${counter_result}
    ${sum_result}    set variable    ${0}
    FOR    ${i}    IN RANGE    ${length}
        ${sum_result}    Evaluate    ${sum_result} + ${counter_result[${i}]}
    END
    [Return]      ${sum_result}

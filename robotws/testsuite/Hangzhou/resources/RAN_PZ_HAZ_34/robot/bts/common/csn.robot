*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    DateTime
Library    taf.transport.ssh    WITH NAME    csn

*** Variables ***

*** Keywords ***
clear vm pid before run case
    log to console    clear vm pid before run case
    csn.connect to    hostname=${vm_addr}    username=${vm_username}    password=${vm_password}   alias=test_pc
    sleep    2s
    csn.Send command    command=sudo ps -ef|grep firefox|grep -v grep|awk '{print "kill -9 " $2}' |sh    connection=test_pc
    sleep    2s
    csn.Send command    command=sudo ps -ef|grep firefox|grep -v grep|awk '{print "kill -9 " $3}' |sh    connection=test_pc
    sleep    2s
    csn.Send command    command=sudo ps -ef|grep btslog|grep -v grep|awk '{print "kill -9 " $2}' |sh    connection=test_pc
    sleep    2s
    [Teardown]   csn.disconnect    connection=test_pc

Create file in BBMOD
    [Arguments]  ${log_name}=123.txt
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}   alias=alias_bbmod
    sleep  2
    csn.execute     touch ${log_name}    connection=alias_bbmod
    sleep  2
    ${output}    csn.execute    command=ls -l ${log_name}    connection=alias_bbmod
    sleep  2
    Should Not Contain      ${output}      No such file or directory
    [Teardown]   csn.disconnect    connection=alias_bbmod

Check and Delete file Exist in BBMOD
    [Arguments]  ${log_name}=123.txt
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}   alias=alias_bbmod
    sleep  2
    ${output}    csn.execute    command=ls -l ${log_name}    connection=alias_bbmod
    sleep  2
    Should Not Contain      ${output}      No such file or directory
    sleep  2
    csn.execute     rm ${log_name}    connection=alias_bbmod
    sleep  2
    ${output}    csn.execute    command=ls -l ${log_name}    connection=alias_bbmod
    sleep  2
    Should Contain      ${output}      No such file or directory
    [Teardown]   csn.disconnect    connection=alias_bbmod

ssh to switch and operation interface
    [Documentation]     This keyword applies only to NOKIA 1830 TPS switch
    [Arguments]    ${switch_ip}=10.101.51.171    ${operation}=down    ${sw_name}=t24ps1    ${sw_interface}=1/3/c2
    log to console    \n ssh to switch and ${operation} interface ${sw_interface}
    csn.connect to    hostname=${vm_addr}    username=${vm_username}    password=${vm_password}   alias=test_pc
    ${connection}    csn.get_connection_by_alias    alias=test_pc
    ${channel}    Call Method    ${connection}    invoke_shell
    Sleep  2
    Call Method    ${channel}    send    ssh cli@${switch_ip}\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    send    admin\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    send    Admin@1830\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    send    Y\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    send    config interface ${sw_name} ${sw_interface} state ${operation}\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    send    show int ${sw_name} ${sw_interface}\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    close
    [Teardown]   csn.disconnect    connection=test_pc

Download software to VM
    [Arguments]        ${sw_name}    ${sw_full_url}     ${package_store_path}=${SAVE LOG DIRECTORY}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    run keyword if      ${status}    remove file    ${package_store_path}/${sw_name}
    ${sw_url}          Catenate    sudo wget --no-check-certificate ${sw_full_url} -nv -P ${package_store_path}
    ${res}             Run         ${sw_url}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    should be true    ${status}
    [Return]    ${sw_name}

Change swconfig with corresponding flag
    [Arguments]    ${flag_code}=0x4F0214    ${flag_value}=0    ${operate}=add
    log to console    ${operate} flag:${flag_code}=${flag_value}
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}   alias=alias_bbmod
    csn.execute    command=chmod 777 /ffs/run/swconfig.txt    connection=alias_bbmod
    ${swconfig_output}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=alias_bbmod
    ${cmd}=    Set Variable If
    ...     '${operate}'=='add'        /0x10041=5/a ${flag_code}=${flag_value}
    ...     '${operate}'=='del'        /${flag_code}=${flag_value}/d
    ...     undefined
    csn.execute    command=sed -i '${cmd}' /ffs/run/swconfig.txt    connection=alias_bbmod
    ${swconfig_output}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=alias_bbmod
    log to console    \n after ${operate} flag:${swconfig_output}
    csn.execute    command=crasign /ffs/run/swconfig.txt    connection=alias_bbmod
    [Teardown]   csn.disconnect    connection=alias_bbmod

Get time from bbmod
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}   alias=alias_bbmod
    csn.send command    command=date +%F-%T    connection=alias_bbmod
    ${date_time}    csn.read output    connection=alias_bbmod
    ${date_time}    Strip String   ${date_time}
    [Return]    ${date_time}
    [Teardown]   csn.disconnect    connection=alias_bbmod

Check Alarm Exist in RawAlarmHistory for LTE
    [Arguments]    ${alarm_filter}
    csn.Connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=ASIK
    csn.send_command    command=cat /tmp/RawAlarmHistory.txt | grep ${alarm_filter}    connection=ASIK
    sleep    2s
    ${alarms_string}    csn.read output    connection=ASIK
    csn.disconnect    connection=ASIK
    Should Contain    ${alarms_string}    ${alarm_filter}

Check ECPRI RU Beamforming Enhance
    [Arguments]    ${ru_alais}    ${get_count}=${False}
    ${bf_output}    csn.execute    command=sudo bfcali -stat    connection=${ru_alais}
    ${bf_output}    evaluate    "" if $bf_output is None else $bf_output
    ${matchs}    Get Regexp Matches    ${bf_output}    Calibration statistics are stored for (\\d+) carriers    1
    ${match_len}    Get Length    ${matchs}
    ${match_0}    set variable if    ${match_len}==0    ${0}    ${matchs[0]}
    ${cell_num}    Evaluate    int(${match_0}/${2})
    ${matchs_1}    Get Regexp Matches    ${bf_output}    Calibration attempts: (\\d+)    1
    ${matchs_2}    Get Regexp Matches    ${bf_output}    Successful calibrations: (\\d+)    1
    ${matchs_time}    Get Regexp Matches    ${bf_output}    Latest calibration: (.*)    1
    ${matchs_time}    set variable    ${matchs_time[::2]}
    ${rx_matchs_1}    set variable    ${matchs_1[::2]}
    ${tx_matchs_1}    set variable    ${matchs_1[1::2]}
    ${rx_matchs_2}    set variable    ${matchs_2[::2]}
    ${tx_matchs_2}    set variable    ${matchs_2[1::2]}
    ${all_status}    set variable    ${True}
    FOR    ${index}    IN RANGE    0    ${cell_num}
        ${tx_num}   set variable if    ${tx_matchs_1[${index}]}==${tx_matchs_2[${index}]}    ${tx_matchs_1[${index}]}
        ${rx_num}   set variable if    ${rx_matchs_1[${index}]}==${rx_matchs_2[${index}]}    ${rx_matchs_1[${index}]}
        ${all_status}    set variable if    ${tx_num} and ${rx_num} and ${tx_num}==${rx_num}   ${True}    ${False}
        exit for loop if    ${all_status}==${False}
    END
    sort list    ${rx_matchs_2}
    sort list    ${tx_matchs_2}
    return from keyword if    ${get_count}    ${tx_matchs_2[0]}    ${rx_matchs_2[0]}    ${matchs_time[0]}
    run keyword and continue on failure    should be true    ${all_status}
    [Return]    ${all_status}

*** Settings ***
Documentation
...   author: lixia tang
...   contact: lixia.tang@nokia-sbell.com
...   squad group: PZ3_SG3
...   Feature CB013125 in 5G25R2 program

Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Library     SSHLibrary

*** Variables ***
${connection}    COAM
${ALLOWED_ALARMS}    '61524', '61652', '4654', '4655', '49', '50', '4592', '4614', '61649', '7319', '7300', '6327',
...    '61510', '23', '7107', '16', '4420'
${TEST_LOG_DIRECTORY}    /home/ute/Case_Logs
${TESTLINEID}    ${tl.gnbs[0].global_bts_id}
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}     ${tl.test_pc.default_ssh_connection_details.password}
${DU_OAM_IP}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${Exception_string}    fatality|SW_FAILURE|Spurious warm reset|coreDumpEnabled=true|Runtime overload detected
${SCF_Path}    /home/ute/Case_Logs/SCF_backup.xml
${CB013125_SCF_RESTORE_PATH}    ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G402T2070/SCF_SBTS00.xml
@{nr_ca_cell_list}      173342721    173342723
@{nr_sa_cell_list}      173342722
@{b16_nr_call_cell_list}    173342721
${SSH_PASSWORD}     f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=

*** Keywords ***
Test Case setup
    Run Keyword And Ignore Error    robot_common_operations.Common case setup    fail_with_alarms=False
    Check Testline Status after Upgrade

Test Case teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    CI_interface.Common Case Teardown

Restore CB013125 Testline SCF
    Connect to gnb coam via ssl    connection=${connection}
    coam.perform_commissioning
    ...   scf_file=${CB013125_SCF_RESTORE_PATH}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${900}
    ...   connection=${connection}
    ${status}    Check Cells Onair And No Unexpected Alarm    Check_timer=10min    connection=${connection}
    Should Be Equal    ${status}    pass
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Run B_16 Service Verification
    log to console    "B_16 initial NSA call on NRCELL-501 (nrCellId 173342721)"
    ${tput_status}   run keyword and return status   Make a L3 Call and Check Tput
    ...    multiue_config=${TLCommonConfig2["MultiUECFG_NSA"]}     log_time=120s   ul_cell_list=${b16_nr_call_cell_list}
    ...    actCarrierAggregation=${False}   dl_cell_list=${b16_nr_call_cell_list}    exp_ul_tp=50    exp_dl_tp=500
    ...    avg_percent=0.9   min_percent=0
    Run Keyword And Ignore Error    Stop Traffic And Detach UE
    Connect to gnb coam via ssl    connection=${connection}
    log to console    "Delete NRCELL-502 and retry NSA call on NRCELL-501"
    Perform Delta Plan Activation   delta_file=${CURDIR}/delta_delete_cell_502.json
    ${bts_status}    Check BTS Status And Return Result
    ${retry_tput_status}   run keyword and return status   Make a L3 Call and Check Tput
    ...    multiue_config=${TLCommonConfig2["MultiUECFG_NSA"]}     log_time=120s   ul_cell_list=${b16_nr_call_cell_list}
    ...    actCarrierAggregation=${False}   dl_cell_list=${b16_nr_call_cell_list}    exp_ul_tp=50    exp_dl_tp=500
    ...    avg_percent=0.9   min_percent=0
    ${status}    Evaluate   ${tput_status} and ${bts_status} and ${retry_tput_status}
    Should Be True    ${status}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    ...    AND    Run Keyword And Ignore Error    Stop Traffic And Detach UE

Check Testline Status after Upgrade
    log to console     \n Check Testline Status after Upgrade
    Connect to gnb coam via ssl    connection=${connection}
    ${status}    Check Cells Onair And No Unexpected Alarm    Check_timer=30s    connection=${connection}
    Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
    ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
    ...     connection=${connection}
    [teardown]    COAM Teardown gnb connections    connection=${connection}

Check Cells Onair And No Unexpected Alarm
    [Arguments]    ${Check_timer}=5min    ${Interval}=10s    ${Check_Degraded}=True    ${connection}=${connection}
    log to console     Check Cells Onair And No Unexpected Alarm
    ${run_status}    run keyword and return status    Wait Until Keyword Succeeds
    ...              ${Check_timer}   ${Interval}   COAM Check BTS All Cells Onair
    ...              Check_Degraded=${Check_Degraded}    connection=${connection}
    Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check BTS All Cells Status    connection=${connection}
    Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check BTS All RU Status    connection=${connection}
    ${alarm_status}    run keyword and return status    Check No Unexpected Active Alarm    connection=${connection}
    ${history_alarm_status}  run keyword and return status    Check No Unexpected History Alarm    connection=${connection}
    ${alarm_status}    Evaluate    ${alarm_status} and ${history_alarm_status}
    ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    Run keyword and continue on failure    Should Be Equal    ${status}    pass
    [Return]    ${status}

COAM Check BTS All Cells Onair
    [Arguments]   ${connection}=${connection}    ${Check_Degraded}=True
    log to console     Check all cells onair
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${len_lte}    Get Length    ${bts_info['cells']['lte']}
    ${len_nr}    Get Length    ${bts_info['cells']['nr']}
    Run Keyword If    ${len_lte} > 0    Get All Cells Onair Status   cell_list=${bts_info['cells']['lte']}
    ...    Check_Degraded=${Check_Degraded}
    Run Keyword If    ${len_nr} > 0    Get All Cells Onair Status    cell_list=${bts_info['cells']['nr']}
    ...    Check_Degraded=${Check_Degraded}

Get All Cells Onair Status
    [Arguments]    ${cell_list}    ${Check_Degraded}=True
    FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        ${output}    convert to string    ${status}
        Run Keywords
        ...      Should Be Equal   ${status['blockingState']}   Unblocked   AND
        ...      Should Be Equal   ${status['operationalState']}   enabled
        Run Keyword If    ${Check_Degraded}==True    should not contain    ${output.lower()}    degraded
    END

Check Specific Cell Status as Expected
    [Arguments]    ${RAT_type}    ${target_cell_id}=LNCEL-401    ${expected_status}=disabled
    ...    ${connection}=${connection}
    ${target_state}    Set Variable    ${None}
    ${bts_info}       coam.get_bts_info    connection=${connection}    timeout=10
    ${cell_list}      Run Keyword If    '${RAT_type}' == 'LTE' and ${bts_info['cells']['lte']}
    ...    Set Variable    ${bts_info['cells']['lte']}
    ...    ELSE IF    '${RAT_type}' == 'NR' and ${bts_info['cells']['nr']}
    ...    Set Variable    ${bts_info['cells']['nr']}
    ...    ELSE
    ...    Create List
    FOR    ${cell}    IN    @{cell_list}
        ${cell_id}    Set Variable    ${cell['id']['configuration']}
        ${cell_id_contains}    Run Keyword And Return Status
        ...    Should Contain    ${cell_id}    ${target_cell_id}
        Run Keyword If    ${cell_id_contains}
        ...    Set Test Variable    ${target_state}    ${cell['status']['operationalState']}
        Exit For Loop If    ${cell_id_contains}
    END
    Should Be Equal As Strings    ${target_state}    ${expected_status}
    ...    msg=${target_cell_id} status should be ${expected_status}, actually is ${target_state}

COAM Check BTS All Cells Status
    [Arguments]   ${connection}=${connection}
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${len_lte}    Get Length    ${bts_info['cells']['lte']}
    ${len_nr}    Get Length    ${bts_info['cells']['nr']}
    Run Keyword If    ${len_lte} > 0    Get All Cells Current Status   cell_list=${bts_info['cells']['lte']}
    Run Keyword If    ${len_nr} > 0    Get All Cells Current Status    cell_list=${bts_info['cells']['nr']}

Get All Cells Current Status
    [Arguments]    ${cell_list}
    @{cell_status_list}    create list
    FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        run keyword and ignore error    Set variable    ${status['operationalState']}
        run keyword and ignore error    Append To List    ${cell_status_list}    ${status['operationalState']}
    END

COAM Check BTS All RU Status
    [Arguments]   ${connection}=${connection}
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    @{ru_status_list}    create list
    FOR  ${ru}  IN  @{list_RUs}
        ${status}   Set Variable   ${ru['status']}
        run keyword and ignore error    Set variable    ${status['operationalState']}
        run keyword and ignore error    Append To List    ${ru_status_list}    ${status['operationalState']}
    END

Collect snapshot logs
    [Arguments]    ${snapshot_path}=${TEST_LOG_DIRECTORY}    ${TESTLINEID}=${TESTLINEID}
    ...    ${Active_FaultID}=None   ${History_FaultID}=None    ${connection}=${connection}
    log to console    Collect snapshot logs
    log to console    TESTLINEID is ${TESTLINEID}
    ${sw_version} =     coam.get_sw_version    connection=${connection}
    ${date}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${TESTLINE}=   Catenate    SEPARATOR=    7_5_UTE5G402T    ${TESTLINEID}
    ${snapshot_path}=    Catenate    SEPARATOR=/    ${snapshot_path}    ${TESTLINE}
    ${dirctory_status}  Run Keyword and Return Status  OperatingSystem.Directory Should Exist  ${snapshot_path}
    Run Keyword If  '${dirctory_status}' == 'False'  Create Directory  ${snapshot_path}
    ${snapshot_file_path}    Set variable
    ...    ${snapshot_path}/Snapshot_${sw_version}_${date}_Fault_${Active_FaultID}-${History_FaultID}.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${connection}

Check No Unexpected Active Alarm
    [Arguments]    ${connection}=${connection}
    log to console    Check No Unexpected Active Alarm
    @{alarm info}    coam.get_alarms   timeout=60    connection=${connection}
    ...    detailed_output=False
    FOR    ${alarm}  IN      @{alarm info}
        Set Suite Variable    ${Active_FaultID}    ${alarm['faultId']}
        Should contain    ${ALLOWED_ALARMS}    '${alarm['faultId']}'
    END

Check No Unexpected History Alarm
    [Arguments]    ${connection}=${connection}
    log to console    Check No Unexpected History Alarm
    @{alarm info}    coam.get_historic_alarms   timeout=180    load_history=True
    ...    connection=${connection}
    FOR    ${alarm}  IN      @{alarm info}
        Set Suite Variable    ${History_FaultID}    ${alarm['faultId']}
        Should contain    ${ALLOWED_ALARMS}    '${alarm['faultId']}'
    END

Execute BTS Site Reset
    log to console    Execute BTS Site Reset
    Connect to gnb coam via ssl    connection=${connection}
    wait until keyword succeeds   3min   2s    COAM Reset Site
    ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
    ...    connection=${connection}
    Run Keyword If    '${onair_status}'=='fail'    Run Keyword And Ignore Error    Collect snapshot logs
    ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
    ...     connection=${connection}
    [teardown]    COAM Teardown gnb connections    connection=${connection}

Check Exception in Syslog
    [Arguments]    ${log_file}    ${filter_string}    ${connection}=syslog
    Connect to gnb coam via ssl    connection=${connection}
    ${status}    set variable    pass
    ${syslog_file}    set variable    ${log_file.strip('./')}
    ${date}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${output}    OperatingSystem.Run
    ...    command=cat /tmp/btslog2/${syslog_file} | grep -E '${filter_string}'
    ${length}    Get Length    ${output}
    ${status}    set variable if    ${length}>0    fail    pass
    Run Keyword If    ${length}>0    log to console    -----Attention:There are ${filter_string} logs: ${length}
    ${TESTLINE}=   Catenate    SEPARATOR=    7_5_UTE5G402T    ${TESTLINEID}
    ${crashLog_path}=    Catenate    SEPARATOR=/    ${TEST_LOG_DIRECTORY}    ${TESTLINE}
    ${dirctory_status}  Run Keyword and Return Status  OperatingSystem.Directory Should Exist  ${crashLog_path}
    Run Keyword If  '${dirctory_status}' == 'False'  Create Directory  ${crashLog_path}
    Run Keyword If    ${length}>0    OperatingSystem.Run
    ...    command=cp /tmp/btslog2/${syslog_file} ${crashLog_path}/SYSLOG_Crash_${date}.LOG
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
    ###collect logs if there is trs-vpp crash in syslog
    ${trsvpp_output}    OperatingSystem.Run
    ...    command=cat /tmp/btslog2/${syslog_file} | grep 'SW_FAILURE' | grep 'trs-vpp'
    ${length}    Get Length    ${trsvpp_output}
    Run Keyword If    ${length}>0    Run Keyword And Ignore Error    Execute VPPOPG Command and Download Result Files
    [Return]    ${status}
    [teardown]    COAM Teardown gnb connections    connection=${connection}

Save Checking Error Warning Syslog
    [Arguments]    ${log_file}    ${save_log_path}=${TEST_LOG_DIRECTORY}
    ${syslog_file}    set variable    ${log_file.strip('./')}
    ${date}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${TESTLINE}=   Catenate    SEPARATOR=    7_5_UTE5G402T    ${TESTLINEID}
    ${err_wrn_log_path}=    Catenate    SEPARATOR=/    ${save_log_path}    ${TESTLINE}
    ${dirctory_status}  Run Keyword and Return Status  OperatingSystem.Directory Should Exist  ${err_wrn_log_path}
    Run Keyword If  '${dirctory_status}' == 'False'  Create Directory  ${err_wrn_log_path}
    OperatingSystem.Run    command=cp /tmp/btslog2/${syslog_file} ${err_wrn_log_path}/SYSLOG_${date}.LOG

Execute VPPOPG Command and Download Result Files
    csn.Connect to    hostname=${DU_OAM_IP}    username=toor4nsn    password=oZPS0POrRieRtu    alias=bts
    csn.Upload File    local_path=/home/ute/CIENV/vppopg.sh    remote_path=/user/toor4nsn/vppopg.sh    connection=bts
    csn.execute    command=chmod 777 /user/toor4nsn/vppopg.sh    connection=bts
    csn.execute    command=rm /tmp/vppopg_console_ouput.log    connection=bts
    csn.execute    command=sh /user/toor4nsn/vppopg.sh    connection=bts
    ${date}    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    csn.download_file    remote_path=/tmp/vppopg_console_ouput.log
    ...    local_path=${TEST_LOG_DIRECTORY}/${TESTLINE}/vppopg_console_ouput_${date}.log   connection=bts
    sleep    2s
    csn.download_file    remote_path=/tmp/vpp_opg.log    local_path=${TEST_LOG_DIRECTORY}/${TESTLINE}/vpp_opg_${date}.log    connection=bts
    sleep    2s
    [Teardown]    csn.disconnect    connection=bts

Get RU IPAddress
    log to console    Get RU IPAddress
    SSHLibrary.Open Connection          host=${DU_OAM_IP}
    SSHLibrary.Login                    username=toor4nsn       password=oZPS0POrRieRtu
    ${command}    Set Variable
    ...    cat /rom/config/FRIps.txt | grep -oE '\\b([0-9]{1,3}\\.){3}[0-9]{1,3}\\b'
    SSHLibrary.Write    text=${command}
    ${result}=    SSHLibrary.Read
    ${ru_ipAddress}=    Get Line    ${result}  0
    log to console    ru ip is: ${ru_ipAddress}
    [Return]    ${ru_ipAddress}
    [Teardown]    SSHLibrary.Close Connection

Capture SM Tcpdump Log
    log to console    Capture SM Tcpdump Log
    SSHLibrary.Open Connection          host=${DU_OAM_IP}
    SSHLibrary.Login                    username=toor4nsn       password=oZPS0POrRieRtu
    SSHLibrary.Write                    text=cd /user/toor4nsn
    SSHLibrary.Write                    text=rm -f /user/toor4nsn/smod.pcap
    SSHLibrary.Write                    text=chmod 777 nohup.out
    SSHLibrary.Write                    text=timeout 180 nohup tcpdump -i rlan0 -w /user/toor4nsn/smod.pcap&
    SSHLibrary.Read Until               expected='nohup.out'
    [Teardown]    SSHLibrary.Close Connection

Capture RM Tcpdump Log
    log to console    Capture RM Tcpdump Log
    ${ru_ipAddress}=    Get RU IPAddress
    SSHLibrary.Open Connection          host=${DU_OAM_IP}
    SSHLibrary.Login                    username=toor4nsn       password=oZPS0POrRieRtu
    SSHLibrary.Write                    text=lxc-attach -n 0x1018
    SSHLibrary.Read Until               expected=root@FHNET00:~ >
    SSHLibrary.Write                    text=ssh -o StrictHostKeyChecking=no rfsw@${ru_ipAddress}
    Sleep    time_=2s       reason=Waiting for password prompt...
    SSHLibrary.Read Until               expected=password:
    SSHLibrary.Write                    text=${SSH_PASSWORD}
    Sleep    time_=2s       reason=Waiting for login in radio...
    #SSHLibrary.Read Until               expected=$
    SSHLibrary.Write                    text=sudo su
    SSHLibrary.Read Until               expected=$
    SSHLibrary.Write                    text=cd /mnt/runtime
    SSHLibrary.Read Until               expected=$
    SSHLibrary.Write                    text=rm -f rmod.pcap
    SSHLibrary.Read Until               expected=$
    SSHLibrary.Write                    text=chmod 777 nohup.out
    SSHLibrary.Read Until               expected=$
    SSHLibrary.Write
    ...    text=timeout 180 nohup tcpdump -i any -w rmod.pcap "udp port 13100 or 13001"&
    Sleep    time_=190s       reason=Waiting for tcpdump done...
    SSHLibrary.Read Until               expected='nohup.out'
    SSHLibrary.Write                    text=ls -l
    SSHLibrary.Read Until               expected=$
    SSHLibrary.Write                    text=chmod 644 rmod.pcap
    [Teardown]    SSHLibrary.Close Connection

Check NFT Table on RF
    log to console    Check NFT Table on RF
    ${ru_ipAddress}=    Get RU IPAddress
    ${date}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    SSHLibrary.Open Connection          host=${DU_OAM_IP}
    SSHLibrary.Login                    username=toor4nsn       password=oZPS0POrRieRtu
    SSHLibrary.Write                    text=lxc-attach -n 0x1018
    SSHLibrary.Read Until               expected=root@FHNET00:~ >
    SSHLibrary.Write                    text=ssh -o StrictHostKeyChecking=no rfsw@${ru_ipAddress}
    Sleep    time_=2s       reason=Waiting for password prompt...
    SSHLibrary.Read Until               expected=password:
    SSHLibrary.Write                    text=${SSH_PASSWORD}
    Sleep    time_=2s       reason=Waiting for login in radio...
    #SSHLibrary.Read Until               expected=$
    SSHLibrary.Write                    text=sudo su
    SSHLibrary.Read Until               expected=$
    SSHLibrary.Write                    text=cd /mnt/runtime
    SSHLibrary.Read Until               expected=$
    SSHLibrary.Write
    ...    text=echo "${date}: nft list ruleset" >> nft.txt && nft list ruleset >> nft.txt
    SSHLibrary.Read Until               expected=$
    SSHLibrary.Write                    text=ssh rfsw@192.168.100.17
    SSHLibrary.Read Until               expected=password:
    SSHLibrary.Write                    text=${SSH_PASSWORD}
    Sleep    time_=2s       reason=Waiting for login in radio...
    SSHLibrary.Write                    text=sudo su
    SSHLibrary.Read Until               expected=$
    SSHLibrary.Write
    ...    text=echo "${date}: nft list ruleset" >> nft_thor.txt && nft list ruleset >> nft_thor.txt
    SSHLibrary.Read Until               expected=$
    [Teardown]    SSHLibrary.Close Connection

BBMOD Reset ${num} Times
    log to console    BBMOD Reset ${num} Times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    \n BBMOD Reset loop ${i}
        ${fbb_info}=    coam.Get fbb info    connection=${connection}
        FOR    ${fbb}    IN    @{fbb_info}
#            Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
            Run Keyword And Ignore error    coam.Reset Unit    ${fbb['id']['internal']}
            ...    reset_type=Warm    timeout=${300}    connection=${connection}
            ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=5min
        ...    connection=${connection}
#            Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
#            ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
            ${status}    Set Variable If    "${onair_status}"=="pass"    pass    fail
            RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
            Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
            ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
            ...     connection=${connection}
            Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s
            ...    COAM Check BTS All Cells Onair    connection=${connection}
            BuiltIn.Exit For Loop If     '${status}'=='fail'
        END
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    COAM Teardown gnb connections    connection=${connection}

Site Reset ${num} Times
    log to console    Site Reset ${num} Times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    \n Site Reset loop ${i}
#        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        Run Keyword And Ignore error    wait until keyword succeeds   3min   2s    COAM Reset Site
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        ...    connection=${connection}
#        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
#        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}
#        ...    filter_string=${Exception_string}
        ${status}    Set Variable If
        ...    "${onair_status}"=="pass"    pass    fail
#        ${status}    Set Variable If    "${onair_status}"=="pass"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
        ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
        ...     connection=${connection}
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s
        ...    COAM Check BTS All Cells Onair    connection=${connection}
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    COAM Teardown gnb connections    connection=${connection}

${RAT_Type} RAT Reset ${num} times
    log to console    ${RAT_Type} reset ${num} times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RAT Reset loop ${i}
#        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        Run Keyword And Ignore error    coam.rat_reset    rat_type=${RAT_Type}    timeout=${240}
        ...    connection=${connection}
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        ...    connection=${connection}
#        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
#        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
#        ${status}    Set Variable If    "${onair_status}"=="pass" and "${syslog_status}"=="pass"    pass    fail
        ${status}    Set Variable If    "${onair_status}"=="pass"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
        ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
        ...     connection=${connection}
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s
        ...    COAM Check BTS All Cells Onair    connection=${connection}
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]   COAM Teardown gnb connections    connection=${connection}

SCF Commission ${num} times
    log to console    SCF Commission ${num} times
    Connect to gnb coam via ssl    connection=${connection}
    coam.get_current_scf_file   local_dir_path=${TEST_LOG_DIRECTORY}   file_name=SCF_backup.xml
    ...    connection=${connection}   timeout=30
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    SCF Commission loop ${i}
#        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        Run Keyword And Ignore error    coam.perform_commissioning    scf_file=${SCF_Path}
        ...   skip_parameter_relation_errors=True   timeout=600   connection=${connection}
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=15min
        ...    connection=${connection}
#        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
#        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}
#        ...    filter_string=${Exception_string}
        ${status}    Set Variable If
        ...    "${onair_status}"=="pass"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
#        Run Keyword If    '${status}'=='fail'    Save Checking Error Warning Syslog    log_file=${syslog_file}
        Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
        ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
        ...     connection=${connection}
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s
        ...    COAM Check BTS All Cells Onair    connection=${connection}
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]   COAM Teardown gnb connections    connection=${connection}

Reset Site without HWF ${num} Times
    log to console    Reset Site without HWF ${num} Times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    \n Reset Site without HWF loop ${i}
    #    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        Run Keyword And Ignore error    wait until keyword succeeds   3min   2s    coam.reset_site
        ...    connection=${connection}    reset_without_ru=${True}
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        ...    connection=${connection}
    #    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #    ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}
    #    ...    filter_string=${Exception_string}
        ${status}    Set Variable If
        ...    "${onair_status}"=="pass"    pass    fail
#        ${status}    Set Variable If    "${onair_status}"=="pass"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
        ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
        ...     connection=${connection}
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s
        ...    COAM Check BTS All Cells Onair    connection=${connection}
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    COAM Teardown gnb connections    connection=${connection}

RU Reset ${num} times
    log to console    RU reset ${num} times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU Reset loop ${i}
#        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        ${run_status}    run keyword and return status       run keyword and ignore error    All RUs Reset
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        ...    connection=${connection}
#        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
#        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
        ${status}    Set Variable If    "${onair_status}"=="pass"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
#        Run Keyword If    '${status}'=='fail'    Save Checking Error Warning Syslog    log_file=${syslog_file}
        Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
        ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
        ...     connection=${connection}
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s
        ...    COAM Check BTS All Cells Onair    connection=${connection}
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
     [teardown]    COAM Teardown gnb connections    connection=${connection}

All RUs Reset
    log to console    All RUs Reset
    ${rmods}   coam.get_frm   connection=${connection}
    ${rf_num}   Get Length   ${rmods}
    FOR   ${index}    IN RANGE    ${rf_num}
        ${dist_name}   Set Variable   ${rmods[${index}]['id']['configuration']}
        log to console    Reset RU
        run keyword and ignore error    COAM Reset RMOD    dist_name=${dist_name}
    END

RU Lock Unlock for ${num} times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU Lock Unlock loop ${i}
#        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        ${run_status}    run keyword and return status    run keyword and ignore error    RU Lock Unlock loop
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        ...    connection=${connection}
#        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
#        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
        ${status}    Set Variable If    "${onair_status}"=="pass"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Save Checking Error Warning Syslog    log_file=${syslog_file}
        Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
        ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
        ...     connection=${connection}
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s
        ...    COAM Check BTS All Cells Onair    connection=${connection}
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    COAM Teardown gnb connections    connection=${connection}

RU Lock Unlock loop
    ${rmods}   coam.get_frm   connection=${connection}
    ${rf_num}   Get Length   ${rmods}
    FOR   ${index}    IN RANGE    ${rf_num}
        ${dist_name}   Set Variable   ${rmods[${index}]['id']['configuration']}
        log to console    Lock RU
        COAM Lock RU    dist_name=${dist_name}
        sleep   20s
        log to console    Unlock RU
        COAM Unlock RU    dist_name=${dist_name}
        sleep   20s
    END

Cell Block Unblock for ${num} times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    Cell Block Unblock loop ${i}
        ${run_status}    run keyword and return status    run keyword and ignore error    Block Unblock All Cells
        ${status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        ...    connection=${connection}
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
        ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
        ...     connection=${connection}
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s
        ...    COAM Check BTS All Cells Onair    connection=${connection}
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=1
    END
    [teardown]    COAM Teardown gnb connections    connection=${connection}

Block Unblock All Cells
    [Arguments]   ${connection}=${connection}
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${len_lte}    Get Length    ${bts_info['cells']['lte']}
    ${len_nr}    Get Length    ${bts_info['cells']['nr']}
    Run Keyword If    ${len_lte} > 0    coam.Block All Cells    rat=LTE    connection=${connection}
    Run Keyword If    ${len_lte} > 0    coam.Unblock All Cells    rat=LTE    connection=${connection}
    Run Keyword If    ${len_nr} > 0    coam.Block All Cells    rat=NR    connection=${connection}
    Run Keyword If    ${len_nr} > 0    coam.Unblock All Cells    rat=NR    connection=${connection}

Cell Reset for ${num} times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    Cell Reset loop ${i}
        ${run_status}    run keyword and return status    run keyword and ignore error    Reset All Cells
        ${status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        ...    connection=${connection}
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
        ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
        ...     connection=${connection}
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s
        ...    COAM Check BTS All Cells Onair    connection=${connection}
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=1
    END
    [teardown]    COAM Teardown gnb connections    connection=${connection}

Reset All Cells
    [Arguments]   ${connection}=${connection}
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${len_lte}    Get Length    ${bts_info['cells']['lte']}
    ${len_nr}    Get Length    ${bts_info['cells']['nr']}
    Run Keyword If    ${len_lte} > 0    coam.Reset All Cells    technology=LTE    connection=${connection}
    Run Keyword If    ${len_nr} > 0    coam.Reset All Cells    technology=NR    connection=${connection}

Cell Delete and Add for ${num} times
    log to console    Cell Delete and Add for ${num} times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
#        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        log to console    Cell Delete loop ${i}
        Perform Delta Plan Activation   delta_file=${CURDIR}/delta_delete_cell_502.json
        ${delete_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        ...    connection=${connection}
        Run Keyword If    '${delete_status}'=='fail'    Run Keyword And Ignore error
        ...    Collect snapshot logs    Active_FaultID=${Active_FaultID}
        ...    History_FaultID=${History_FaultID}    connection=${connection}
        log to console    Cell Add loop ${i}
        Perform Delta Plan Activation   delta_file=${CURDIR}/delta_add_cell_502.json
        ${add_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        ...    connection=${connection}
        Run Keyword If    '${add_status}'=='fail'    Run Keyword And Ignore error
        ...    Collect snapshot logs    Active_FaultID=${Active_FaultID}
        ...    History_FaultID=${History_FaultID}    connection=${connection}
#        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
#        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
        ${status}    Set Variable If
        ...    "${delete_status}"=="pass" and "${add_status}"=="pass"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
#        Run Keyword If    '${status}'=='fail'    Save Checking Error Warning Syslog    log_file=${syslog_file}
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=1
    END
    [teardown]   COAM Teardown gnb connections    connection=${connection}

Perform BTS Parameter Recommission
    [Arguments]    ${dist_name}   ${parameter}   ${operation}   ${value}
    ...    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}
    ...    ${timeout}=300   ${connection}=${connection}
    coam.perform_parameter_recommissioning
    ...                    dist_name=${dist_name}
    ...                    parameter=${parameter}
    ...                    operation=${operation}
    ...                    value=${value}
    ...                    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                    should_activate=${should_activate}
    ...                    timeout=${timeout}
    ...                    connection=${connection}

Perform Delta Plan Activation
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=${True}
    ...            ${should_activate}=${True}
    ...            ${timeout}=300
    ...            ${connection}=${connection}
    coam.Perform Delta Recommissioning
    ...                                        delta_file=${delta_file}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                        should_activate=${should_activate}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}

Check BTS Status And Return Result
    [Arguments]    ${connection}=${connection}
    log to console      "Check BTS Status And Return Result"
    Connect to gnb coam via ssl    connection=${connection}
    ${result}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min    connection=${connection}
    ${status}    Set Variable If    "${result}"=="pass"    True    False
    [Return]   ${status}
    [Teardown]   COAM Teardown gnb connections    connection=${connection}

###spark UE
Check LTE TPut From Spark UE
    [Arguments]    ${ue_alias}=spark_UE
    log to console      "Check LTE TPut From Spark UE"
    ${status}   sparkMultiUE_yiyuan.check_lte_throughput_on_ue    ue_alias=${ue_alias}

Check Case Status and Stop UE Traffic
    [Arguments]    ${status}=True
    Run Keyword If    '${status}'=='False'   Run Keywords
    ...    Connect to gnb coam via ssl   connection=${connection}
    ...    AND  run keyword and ignore error   Collect snapshot logs
    ...    Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
    ...    AND  COAM Teardown gnb connections   connection=${connection}
    Run Keyword And Ignore Error    Stop Traffic And Detach UE

Check UE Tput From Aasyslog
    [Arguments]    ${log_time}    ${ul_list}    ${dl_list}   ${actCarrierAggregation}
    ...    ${exp_ul_tp}   ${exp_dl_tp}    ${target_avg_percent}    ${min_percent}
    ...    ${if_ul}=${True}    ${if_dl}=${True}
    ${log_path}    power_ue.Collect Tput   ue_type=samsung    duration=${log_time}    ignore_time=10s
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}
    ...    power_ue.Check Tput    ue_type=samsung    direction=UL    log=${log_path}
    ...    cells=${ul_list}    target_throughput=${exp_ul_tp}
    ...    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    min_percent=${min_percent}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}
    ...    power_ue.Check Tput    ue_type=samsung    direction=DL    log=${log_path}
    ...    cells=${dl_list}    target_throughput=${exp_dl_tp}
    ...    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    min_percent=${min_percent}

Make a L3 Call and Check Tput
    [Arguments]    ${multiue_config}    ${log_time}    ${ul_cell_list}    ${dl_cell_list}   ${actCarrierAggregation}
    ...            ${exp_ul_tp}    ${exp_dl_tp}    ${avg_percent}    ${min_percent}
    log to console    "Make a L3 Call"
    Prepare MultiUE And Attach    multiue_config_direction=${multiue_config}
    MultiUE Start UDP Traffic    ul_port_list=${port_list}   ul_tp_list=${ul_traffic_list}    ul_duration=${traffic_duration}
    sleep   10s
    log to console    "Check throughput"
    Check UE Tput From Aasyslog   log_time=${log_time}   ul_list=${ul_cell_list}   dl_list=${dl_cell_list}
    ...   actCarrierAggregation=${actCarrierAggregation}   exp_ul_tp=${exp_ul_tp}   exp_dl_tp=${exp_dl_tp}
    ...   target_avg_percent=${avg_percent}   min_percent=${min_percent}

###power saving *** keywords ***
Get RU Real Time Power Measurement
    [Arguments]    ${connection}=${connection}   ${ru_index}=1
    log to console    "Get RU Real Time Power Measurement"
    @{rt_measures}=     coam.get_measurements    measurement_type=realTime    timeout=${60}
    ...    connection=${connection}
    FOR  ${measurement}  IN  @{rt_measures}
        ${object}    Get Dictionary Keys   ${measurement}
        ${object}    Set Variable   ${object[0]}
        ${is_rmod}    Run Keyword And Return Status    Should Match Regexp    '${object}'
        ...    ENERGY_EFFICIENCY/RMOD/RMOD_R-${ru_index}
        ${power}    Set Variable If    ${is_rmod}    ${measurement['${object}']['power']}
        Exit For Loop If    ${is_rmod}
    END
    [Return]   ${power}

Check Power Saving Status When LTE uDTX Enabled
    log to console    "Check Power Saving Status When LTE uDTX Enabled"
    Connect to gnb coam via ssl    connection=${connection}
    ${uDTX_disabled_power}=    Get RU Real Time Power Measurement
    Perform BTS Parameter Recommission
    ...                    dist_name=MRBTS-10580/LNBTS-10580/LNCEL-401
    ...                    parameter=actMicroDtx
    ...                    operation=update
    ...                    value=true
    sleep   120s
    ${uDTX_enabled_power}=    Get RU Real Time Power Measurement
    should be true   ${uDTX_disabled_power} > ${uDTX_enabled_power}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Make SA L3 Call and Return Status
    ${status}   run keyword and return status   Make a L3 Call and Check Tput
    ...    multiue_config=${TLCommonConfig4["MultiUECFG_SA"]}     log_time=10s   ul_cell_list=${nr_ca_cell_list}
    ...    actCarrierAggregation=${True}   dl_cell_list=${nr_ca_cell_list}    exp_ul_tp=14    exp_dl_tp=118
    ...    avg_percent=0.9   min_percent=0
    [Return]   ${status}

Modify Pmax and msg1FrequencyStart Parameter
    log to console    "Modify Pmax and msg1FrequencyStart Parameter"
    Connect to gnb coam via ssl    connection=${connection}
    Perform BTS Parameter Recommission    dist_name=MRBTS-10580/NRBTS-10580/NRCELL-501
    ...     parameter=pMax   operation=update   value=270
    sleep   20s
    Perform BTS Parameter Recommission    dist_name=MRBTS-10580/NRBTS-10580/NRCELL-501
    ...     parameter=msg1FrequencyStart   operation=update   value=36
    sleep   20s
    Perform BTS Parameter Recommission    dist_name=MRBTS-10580/NRBTS-10580/NRCELL-501
    ...     parameter=msg1FrequencyStart   operation=update   value=34
    sleep   20s
    Perform BTS Parameter Recommission    dist_name=MRBTS-10580/NRBTS-10580/NRCELL-501
    ...     parameter=pMax   operation=update   value=250
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Calculate LTE Power Saving Week And Time
    [Documentation]    calculate load based power saving test time: current time + 2minutes
    ...    Return：
    ...    ${weekday_name} - Sun    Mon    Tue    Wed    Thu    Fri    Sat
    ...    ${hour} - 0-23
    ...    ${minute} - 0-59
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ${current_time}    robot.libraries.DateTime.Get Current Date    result_format=%H:%M
    ${hour_minute}     Split String        ${current_time}    :
    ${temp_hour}    Convert To Integer  ${hour_minute[0]}
    ${is_ute_env}    Set Variable    ${False}
    ${is_ute_env}    Run Keyword If    '${var_status}' == 'PASS'
    ...    Evaluate    $ci_var_dict.get('ute_env', False)
    ...    ELSE    Set Variable    ${False}
    ${current_hour}    Set Variable If    ${is_ute_env}    ${temp_hour + 8}    ${temp_hour}
    ${current_minute}  Convert To Integer  ${hour_minute[1]}

    ${new_minute}      Evaluate            (${current_minute} + 2) % 60
    ${hour_carry}      Evaluate            1 if (${current_minute} + 2) >= 60 else 0
    ${new_hour}        Evaluate            (${current_hour} + ${hour_carry}) % 24

    ${current_weekday}   robot.libraries.DateTime.Get Current Date    result_format=%w
    ${weekday_carry}     Evaluate            1 if (${current_hour} + ${hour_carry}) >= 24 else 0
    ${weekday_num}       Evaluate            (int(${current_weekday}) + ${weekday_carry}) % 7
    ${weekday_names}     Create List         Sun    Mon    Tue    Wed    Thu    Fri    Sat
    ${weekday_name}      Get From List       ${weekday_names}    ${weekday_num}
    [Return]    ${weekday_name}    ${new_hour}    ${new_minute}

Replace Variables In Delta File
    [Arguments]    ${delta_file_path}    ${weekday}    ${hour}    ${minute}
    ${json_content}=    OperatingSystem.Get File    ${delta_file_path}
    ${json_object}=    Evaluate    json.loads('''${json_content}''')    json

    FOR    ${item}    IN    @{json_object}
        ${dist_name} =    Set Variable    ${item["distName"]}
        IF    "${dist_name}" == "MRBTS-10580/LNBTS-10580/PSGRP-1"
            ${parameters} =    Get From Dictionary    ${item}    parameters
            FOR    ${param}    IN    @{parameters}
                ${param_name} =    Set Variable    ${param["parameterName"]}
                IF    "${param_name}" == "lbpsPeriodList"
                    ${value_list} =    Get From Dictionary    ${param}    value
                    ${first_entry} =    Set Variable    ${value_list[0]}
                    Set To Dictionary    ${first_entry}    lbpsDayOfWeek    ${weekday}
                    Set To Dictionary    ${first_entry}    lbpsStartTimeHour    ${hour}
                    Set To Dictionary    ${first_entry}    lbpsStartTimeMinute    ${minute}
                    Exit For Loop
                END
            END
            Exit For Loop
        END
    END

    ${updated_json} =    Evaluate    json.dumps(${json_object}, indent=4)    json
    Create File    ${delta_file_path}    ${updated_json}

Check Radio Deep Sleep State
    [Arguments]    ${expected_state}    ${target_rmod_id}    ${connection}=${connection}
    ${target_state}    Set Variable    ${None}
    ${rmod_list}=  coam.get_frm  connection=${connection}    timeout=10
    FOR    ${rmod}    IN    @{rmod_list}
        ${rmod_id}    Set Variable    ${rmod['id']['configuration']}
        ${rmod_id_contains}    Run Keyword And Return Status
        ...    Should Contain    ${rmod_id}    ${target_rmod_id}
        Run Keyword If    ${rmod_id_contains}
        ...    Set Test Variable    ${target_state}    ${rmod['status']['powerState']}
        Exit For Loop If    ${rmod_id_contains}
    END
    ${state_upper}    Convert To Upper Case    ${target_state}
    ${expected_upper}    Convert To Upper Case    ${expected_state}
    Should Contain    ${state_upper}    ${expected_upper}
    ...    msg=${target_rmod_id} status should contain ${expected_state}, actually is ${target_state}

Test LTE Load Based Power Saving Function
    log to console    "get current week and time, then replace week and time value in delta file"
    ${lbpsStart_Weekday}   ${lbpsStart_Hour}   ${lbpsStart_Minute}    Calculate LTE Power Saving Week And Time
    Replace Variables In Delta File    delta_file_path=${CURDIR}/case16_delta_file1.json
    ...   weekday=${lbpsStart_Weekday}   hour=${lbpsStart_Hour}   minute=${lbpsStart_Minute}

    log to console    "test load based power saving function"
    Connect to gnb coam via ssl    connection=${connection}
    Perform Delta Plan Activation   delta_file=${CURDIR}/case16_delta_file1.json
    wait until keyword succeeds    5min   10s   Check Specific Cell Status as Expected
    ...    RAT_type=LTE   target_cell_id=LNCEL-401   expected_status=disabled
    ...    connection=${connection}

    log to console    "test N41 cell SA call is ok after lte cell entering power saving state"
    ${call_status}   Make SA L3 Call and Return Status
    Should Be True    ${call_status}

    log to console    "check LTE status is enabled after exiting power saving"
    wait until keyword succeeds    5min   10s    Check Specific Cell Status as Expected
    ...    RAT_type=LTE   target_cell_id=LNCEL-401   expected_status=enabled
    ...    connection=${connection}
    [Teardown]    Run Keywords    COAM Teardown gnb connections    connection=${connection}    AND
    ...    Run Keyword And Ignore Error    Stop Traffic And Detach UE

Test Extreme Deep Sleep Support on Habrok Radio
    Connect to gnb coam via ssl    connection=${connection}
    Perform BTS Parameter Recommission
    ...                    dist_name=MRBTS-10580/EQM-1/APEQM-1/RMOD-1
    ...                    parameter=energySavingMode
    ...                    operation=update
    ...                    value=DEEPSLEEP_EXTREME_SFP
    ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min    connection=${connection}
    Run Keyword If    '${onair_status}'!='pass'    Fail    BTS status check failed after parameter change

    log to console    "block all cells to make radio entering extreme deep sleep"
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${len_lte}    Get Length    ${bts_info['cells']['lte']}
    ${len_nr}    Get Length    ${bts_info['cells']['nr']}
    Run Keyword If    ${len_nr} > 0    coam.Block All Cells    rat=NR    connection=${connection}
    Run Keyword If    ${len_lte} > 0    coam.Block All Cells    rat=LTE    connection=${connection}

    log to console    "Check radio entering extreme deep sleep mode"
    wait until keyword succeeds    6min   10s   Check Radio Deep Sleep State
    ...    expected_state=SLEEP    target_rmod_id=MRBTS-10580/EQM-1/APEQM-1/RMOD-1
    ...    connection=${connection}

    log to console    "unblock all cells to make radio exiting extreme deep sleep"
    Run Keyword If    ${len_nr} > 0    coam.Unblock All Cells    rat=NR    connection=${connection}

    log to console    "Check radio exiting extreme deep sleep mode and all cells can be onair"
    wait until keyword succeeds    6min   10s   Check Radio Deep Sleep State   expected_state=AWAKE
    ...    target_rmod_id=MRBTS-10580/EQM-1/APEQM-1/RMOD-1
    ...    connection=${connection}

    Run Keyword If    ${len_lte} > 0    coam.Unblock All Cells    rat=LTE    connection=${connection}
    ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min    connection=${connection}
    Run Keyword If    '${onair_status}'!='pass'    Fail    BTS status check failed after unblocking cells

    log to console    "Check NSA call is ok after exiting deep sleep mode"
    ${tput_status}   run keyword and return status   Make a L3 Call and Check Tput
    ...    multiue_config=${TLCommonConfig2["MultiUECFG_NSA"]}     log_time=30s
    ...    ul_cell_list=${nr_ca_cell_list}    actCarrierAggregation=${True}
    ...    dl_cell_list=${nr_ca_cell_list}    exp_ul_tp=66    exp_dl_tp=1024
    ...    avg_percent=0.5   min_percent=0
    Should Be True    ${tput_status}
    [Teardown]    Run Keywords    COAM Teardown gnb connections    connection=${connection}    AND
    ...    Run Keyword And Ignore Error    Stop Traffic And Detach UE

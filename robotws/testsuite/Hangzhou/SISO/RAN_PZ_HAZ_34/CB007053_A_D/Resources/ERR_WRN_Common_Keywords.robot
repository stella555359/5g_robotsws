*** Settings ***
Documentation
...   author: lixia tang
...   contact: lixia.tang@nokia-sbell.com
...   squad group: PZ3_SG3
...   Feature CB013125 in 5G25R2 program

Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${connection}    COAM
${ALLOWED_ALARMS}    '61524', '61652', '4654', '4655', '49', '4003', '50', '4592', '4614', '61649', '7319', '7300', '16', '6327', '4681'
${TEST_LOG_DIRECTORY}    /home/ute/Case_Logs
${TESTLINE}    7_5_UTE5G402T712
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}     ${tl.test_pc.default_ssh_connection_details.password}
${DU_OAM_IP}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${Exception_string}    fatality|SW_FAILURE|Spurious warm reset|coreDumpEnabled=true

*** Keywords ***
Test Case setup
    Run Keyword And Ignore Error    robot_common_operations.Common case setup    fail_with_alarms=False
#    Check Testline Status after Upgrade

Test Case teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown

Check Testline Status after Upgrade
    log to console     \n Check Testline Status after Upgrade
    Connect to gnb coam via ssl    connection=${connection}
    ${status}    Check Cells Onair And No Unexpected Alarm    Check_timer=30s
    Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
    [teardown]    COAM Teardown gnb connections    connection=${connection}

Check Cells Onair And No Unexpected Alarm
    [Arguments]    ${Check_timer}=5min    ${Interval}=10s
    log to console     Check Cells Onair And No Unexpected Alarm
    ${run_status}    run keyword and return status    Wait Until Keyword Succeeds
    ...              ${Check_timer}   ${Interval}   COAM Check BTS All Cells Onair
    Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check BTS All Cells Status
    Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check BTS All RU Status
    ${alarm_status}    run keyword and return status    Check No Unexpected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No Unexpected History Alarm
    ${alarm_status}    Evaluate    ${alarm_status} and ${history_alarm_status}
    ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    Run keyword and continue on failure    Should Be Equal    ${status}    pass
    [Return]    ${status}

COAM Check BTS All Cells Onair
    [Arguments]   ${connection}=${connection}
    log to console     Check all cells onair
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${len_lte}    Get Length    ${bts_info['cells']['lte']}
    ${len_nr}    Get Length    ${bts_info['cells']['nr']}
    Run Keyword If    ${len_lte} > 0    Get All Cells Onair Status   cell_list=${bts_info['cells']['lte']}
    Run Keyword If    ${len_nr} > 0    Get All Cells Onair Status    cell_list=${bts_info['cells']['nr']}

Get All Cells Onair Status
    [Arguments]    ${cell_list}
    FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        ${output}    convert to string    ${status}
        Run Keywords
        ...      Should Be Equal   ${status['blockingState']}   Unblocked   AND
        ...      should not contain    ${output.lower()}    degraded    AND
        ...      Should Be Equal   ${status['operationalState']}   enabled
    END

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

#Collect snapshot logs
#    [Arguments]    ${snapshot_path}=${TEST_LOG_DIRECTORY}
#    log to console    Collect snapshot logs
#    ${sw_version} =     coam.get_sw_version    connection=${connection}
#    ${date}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
#    ${snapshot_file_path}    Set variable
#    ...    ${snapshot_path}/${TESTLINE}/Snapshot_${sw_version}_${date}_Fault_${Active_FaultID}-${History_FaultID}.zip
#    admin_cli.collect_snapshot    target_file_name=${snapshot_file_path}    timeout=4800    connection=${connection}

Check No Unexpected Active Alarm
    log to console    Check No Unexpected Active Alarm
    @{alarm info}    coam.get_alarms   timeout=60    connection=${connection}    detailed_output=False
    FOR    ${alarm}  IN      @{alarm info}
        Set Suite Variable    ${Active_FaultID}    ${alarm['faultId']}
        Should contain    ${ALLOWED_ALARMS}    '${alarm['faultId']}'
    END

Check No Unexpected History Alarm
    log to console    Check No Unexpected History Alarm
    @{alarm info}    coam.get_historic_alarms   timeout=60    load_history=True    connection=${connection}
    FOR    ${alarm}  IN      @{alarm info}
        Set Suite Variable    ${History_FaultID}    ${alarm['faultId']}
        Should contain    ${ALLOWED_ALARMS}    '${alarm['faultId']}'
    END

Execute BTS Site Reset
    log to console    Execute BTS Site Reset
    Connect to gnb coam via ssl    connection=${connection}
    wait until keyword succeeds   3min   2s    COAM Reset Site
    ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
    Run Keyword If    '${onair_status}'=='fail'    Run Keyword And Ignore Error    Collect snapshot logs
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
    Run Keyword If    ${length}>0    OperatingSystem.Run
    ...    command=cp /tmp/btslog2/${syslog_file} ${TEST_LOG_DIRECTORY}/${TESTLINE}/SYSLOG_Crash_${date}.LOG
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
    OperatingSystem.Run    command=cp /tmp/btslog2/${syslog_file} ${save_log_path}/${TESTLINE}/SYSLOG_${date}.LOG

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

BBMOD Reset ${num} Times
    log to console    BBMOD Reset ${num} Times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    \n BBMOD Reset loop ${i}
        ${fbb_info}=    coam.Get fbb info    connection=${connection}
        FOR    ${fbb}    IN    @{fbb_info}
            Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
            Run Keyword And Ignore error    coam.Reset Unit    ${fbb['id']['internal']}
            ...    reset_type=Warm    timeout=${300}    connection=${connection}
            ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=5min
            Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
            ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
            ${status}    Set Variable If    "${onair_status}"=="pass" and "${syslog_status}"=="pass"    pass    fail
            RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
            Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
            Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s   COAM Check BTS All Cells Onair
        END
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=2
    END
    [teardown]    COAM Teardown gnb connections    connection=${connection}

Site Reset ${num} Times
    log to console    Site Reset ${num} Times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    \n Site Reset loop ${i}
        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        Run Keyword And Ignore error    wait until keyword succeeds   3min   2s    COAM Reset Site
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
        ${status}    Set Variable If    "${onair_status}"=="pass" and "${syslog_status}"=="pass"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s   COAM Check BTS All Cells Onair
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]    COAM Teardown gnb connections    connection=${connection}

${RAT_Type} RAT Reset ${num} times
    log to console    RAT reset ${num} times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RAT Reset loop ${i}
        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        Run Keyword And Ignore error    coam.rat_reset    rat_type=${RAT_Type}    timeout=${240}    connection=${connection}
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
        ${status}    Set Variable If    "${onair_status}"=="pass" and "${syslog_status}"=="pass"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s   COAM Check BTS All Cells Onair
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
    END
    [teardown]   COAM Teardown gnb connections    connection=${connection}

RU Reset ${num} times
    log to console    RU reset ${num} times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU Reset loop ${i}
        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        ${run_status}    run keyword and return status       run keyword and ignore error    All RUs Reset
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
        ${status}    Set Variable If    "${onair_status}"=="pass" and "${syslog_status}"=="pass"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
        Run Keyword And Ignore error    Wait Until Keyword Succeeds   5min   30s   COAM Check BTS All Cells Onair
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

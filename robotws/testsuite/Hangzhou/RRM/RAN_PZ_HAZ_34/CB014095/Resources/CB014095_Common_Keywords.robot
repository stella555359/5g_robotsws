*** Settings ***
Documentation
...   author: Fu Hongye
...   contact: hongye.fu@nokia-sbell.com
...   squad group: PZ3_SG3
...   Feature CB013125 in 5G25R2 program

Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Library     SSHLibrary
Library     DateTime
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/sigspark.py
Library     sigspark.sparkxml    WITH NAME    spark
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011116/lib/CB011116.py
Library     ./CB014095_Spark_Helper.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/energy_efficiency.robot
Variables   ../TestData/variables.py
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.sbts.oam.coam.admin   WITH NAME   coam


*** Variables ***
${connection}    COAM
${ALLOWED_ALARMS}    '61524', '61652', '4654', '4655', '49', '50', '4592', '4614', '61649', '7319', '7300', '6327',
...    '61510', '23', '7107', '16', '4420', '62003', '7311', '7331'
${TEST_LOG_DIRECTORY}    /home/ute/Case_Logs
${TESTLINEID}    ${tl.gnbs[0].global_bts_id}
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}     ${tl.test_pc.default_ssh_connection_details.password}
${DU_OAM_IP}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_IP_GNB1}   ${tl.gnbs[1].dus[0].f1_m_ip_addr}    # Secondary gNB (10.71.209.77)
${Exception_string}    fatality|SW_FAILURE|Spurious warm reset|coreDumpEnabled=true|Runtime overload detected
${testline_name}    7_5_UTE5G402T845
${SCF_Path}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00.xml
${SCF_backup_path}    /home/ute/Case_Logs/SCF_backup.xml
@{nr_ca_cell_list}      173342721    173342723
@{nr_sa_cell_list}      173342721
${SSH_PASSWORD}     f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=

${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${TS_CASE_LOG_PATH}    /home/ute/Case_Logs
${scf_file_path}    ${commissionings_path}HGZ/${testline_name}

*** Keywords ***
Test Case setup
    Run Keyword And Ignore Error    robot_common_operations.Common case setup    fail_with_alarms=False
    Check Testline Status after Upgrade

Test Case teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    CI_interface.Common Case Teardown

Check Testline Status after Upgrade
    log to console     \n Check Testline Status after Upgrade
    Wait Until Keyword Succeeds    3min    30s    Connect to gnb coam via ssl    connection=${connection}
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
    Run Keyword If    "${run_status}"=="False"
    ...    Run Keyword And Ignore Error
    ...    COAM Check BTS All Cells Status    connection=${connection}
    Run Keyword If    "${run_status}"=="False"
    ...    Run Keyword And Ignore Error
    ...    COAM Check BTS All RU Status    connection=${connection}
    ${alarm_status}    run keyword and return status
    ...    Check No Unexpected Active Alarm    connection=${connection}
    ${history_alarm_status}  run keyword and return status
    ...    Check No Unexpected History Alarm    connection=${connection}
    ${alarm_status}    Evaluate    ${alarm_status} and ${history_alarm_status}
    ${status}    Set Variable If
    ...    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
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
    csn.download_file
    ...    remote_path=/tmp/vpp_opg.log
    ...    local_path=${TEST_LOG_DIRECTORY}/${TESTLINE}/vpp_opg_${date}.log
    ...    connection=bts
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

Capture RM Tcpdump on RF
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
        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        Run Keyword And Ignore error    wait until keyword succeeds   3min   2s    COAM Reset Site
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        ...    connection=${connection}
        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}
        ...    filter_string=${Exception_string}
        ${status}    Set Variable If
        ...    "${onair_status}"=="pass" and "${syslog_status}"=="pass"    pass    fail
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
        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        Run Keyword And Ignore error    coam.perform_commissioning    scf_file=${SCF_Path}
        ...   skip_parameter_relation_errors=True   timeout=600   connection=${connection}
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=15min
        ...    connection=${connection}
        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}
        ...    filter_string=${Exception_string}
        ${status}    Set Variable If
        ...    "${onair_status}"=="pass" and "${syslog_status}"=="pass"    pass    fail
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
    [teardown]   COAM Teardown gnb connections    connection=${connection}

Reset Site without HWF ${num} Times
    log to console    Reset Site without HWF ${num} Times
    Connect to gnb coam via ssl    connection=${connection}
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    \n Reset Site without HWF loop ${i}
        Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
        Run Keyword And Ignore error    wait until keyword succeeds   3min   2s    coam.reset_site
        ...    connection=${connection}    reset_without_ru=${True}
        ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=7min
        ...    connection=${connection}
        Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
        ${syslog_status}    Check Exception in Syslog    log_file=${syslog_file}
        ...    filter_string=${Exception_string}
        ${status}    Set Variable If
        ...    "${onair_status}"=="pass" and "${syslog_status}"=="pass"    pass    fail
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
        Run Keyword If    '${status}'=='fail'    Save Checking Error Warning Syslog    log_file=${syslog_file}
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
    MultiUE Start UDP Traffic
    ...    ul_port_list=${port_list}
    ...    ul_tp_list=${ul_traffic_list}
    ...    ul_duration=${traffic_duration}
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
    Perform BTS Parameter Recommission    dist_name=MRBTS-10580/NRBTS-10580/NRCELL-503
    ...     parameter=pMax   operation=update   value=270
    sleep   20s
    Perform BTS Parameter Recommission    dist_name=MRBTS-10580/NRBTS-10580/NRCELL-503
    ...     parameter=msg1FrequencyStart   operation=update   value=7
    sleep   20s
    Perform BTS Parameter Recommission    dist_name=MRBTS-10580/NRBTS-10580/NRCELL-503
    ...     parameter=msg1FrequencyStart   operation=update   value=5
    sleep   20s
    Perform BTS Parameter Recommission    dist_name=MRBTS-10580/NRBTS-10580/NRCELL-503
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
    [Teardown]    Run Keywords    COAM Teardown gnb connections    connection=${connection}    AND
    ...    Run Keyword And Ignore Error    Stop Traffic And Detach UE

Check SCell Release In RRC Reconfiguration
    [Documentation]    Check if SCell is released by parsing Spark MultiUE RRC messages
    [Arguments]    ${ue_alias}=spark_UE

    log to console    Stop Spark UE log and export RRC messages
    Run Keyword And Ignore Error    sparkMultiUE_yiyuan.stop_log    ue_alias=${ue_alias}
    sleep    2s

    log to console    Export Spark L3 message log to XML format
    ${spark_log_file}    Download And Check Spark L3 Log    ue_alias=${ue_alias}

    log to console    Parse Spark MultiUE RRC messages for SCell release
    ${found_scell_release}    Check Spark Log For SCell Release    ${spark_log_file}

    Run Keyword If    ${found_scell_release}
    ...    Log To Console    ✓ PASS: RRC Reconfiguration with sCellToReleaseList found - SCell was released
    ...    ELSE
    ...    Fail    ✗ FAIL: No RRC Reconfiguration message with sCellToReleaseList found in Spark log

Set parameter
    [Arguments]    ${key}    ${value}    ${dict_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CELL_ID}
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=${connection}



Conect to DU COAM
    [Arguments]    ${connection}=${connection}
    coam.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}


Check TX muting Status
    [Arguments]    ${connection}=COAM
    sleep    60s
    Conect to DU COAM
    @{MOs_NRCELL_R}    coam.get_managed_objects    class_name=NRCELL_R   connection=${connection}
    &{dict_energySavingState}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${NRBTS_ID}/NRCELL_R-${CELL_ID}
    ...    pattern=energySavingState    connection=${connection}
    should be equal as strings    ${dict_energySavingState['energySavingState']}    reducedEnergySaving    msg=cell is TX muting status
    ...    ignore_case=${True}


Check CB014095 status
    [Arguments]    ${json_name}=CP_beamSet_2_4294967208_68719475340.json
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=GNB_OAM
    ${CP_beamSet_output}    csn.execute    command=cat /ffs/run/config/AEHC-475124B/${json_name} |grep beamset_type    connection=GNB_OAM
    ${result1}    run keyword and return status    should Contain    ${CP_beamSet_output}    dynamicmuted
    ${result2}    run keyword and return status    should Contain    ${CP_beamSet_output}    dftnormalmuted
    ${result}    Evaluate  ${result1} and ${result2}
    ${status}    Set Variable If    "${result}"=="True"   pass    fail
    Should Be Equal    ${status}    pass
    [Teardown]    csn.Disconnect    connection=GNB_OAM


Add Test Flags To Swconfig
    [Documentation]    Adds test flags to the swconfig file
    ...                This is used to trigger fault conditions for testing
    Log To Console    \nAdding test flags to swconfig file
    # Step 1: Modify swconfig file to add test flags
    Backup and Modify swconfig file    is_called_in_test_case_level=${True}    swconfig_modify=${test_flags}
    # Step 2: Restart BTS to activate flags
    Perform BTS Site Reset And Wait Onair    connection=${connection}

Remove Test Flags From Swconfig
    [Documentation]    Removes test flags from the swconfig file
    ...                This is used to cancel fault conditions
    Log To Console    \nRemoving test flags from swconfig file
    # Step 1: Modify swconfig file to remove test flags
    Restore Swconfig File
    # Step 2: Restart BTS to cancel the fault condition
    Perform BTS Site Reset And Wait Onair    connection=${connection}

Perform BTS Site Reset And Wait Onair
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}     ${timeout}=15min
    log    ${timeout}
    Connect to gnb coam via ssl    connection=${connection}   gnb_index=${gnb_index}
    ${run_status1}    run keyword and return status     coam.reset_site    connection=${connection}    timeout=${timeout}
    sleep    30s
    ${run_status2}    run keyword and return status
    ...    COAM Wait gnb And Cells ready    gnb_index=${gnb_index}    timeout=${timeout}    connection=${connection}
    ${run_status}  Evaluate  ${run_status1} and ${run_status2}
    ${alarm_status}    run keyword and return status    Check No Unexpected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No Unexpected History Alarm
    ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
    ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    ${snapshot_file}    Run Keyword If    '${status}'=='fail'
    ...    Run Keyword And Ignore error    Collect snapshot logs
    Should Be Equal    ${status}    pass
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


L3 call setup for CB014095
    [Arguments]    ${UE_TYPE}=qct_dx50
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Start Traffic DL for CB014095
    [Arguments]    ${ue_type}=qct_dx50    ${ue_index}=${0}    ${dl_tp}=100M    ${duration}=${300}    ${iperf_port}=default
    log to console    \n ###Start DL traffic
    ${traffic_duration}  evaluate  ${duration}*10+100
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}
    ...    duration=${traffic_duration}    iperf_port=${iperf_port}    iperf_type=via_command


Check power ue Tput for CB014095
    [Arguments]     ${time}=30s    ${dl_throughput}=${None}    ${target_avg_percent}=0.8    ${min_percent}=0.6
    ...    ${cell1}=${183233}
    Log To Console    \n ### Check TP ###
    ${cells1}    create list    ${cell1}
    ${log_path}    power_ue.Collect Tput     ue_type=samsung    duration=${time}    ignore_time=10s
    ${output_dl}    run keyword and return status    power_ue.Check Tput    ue_type=qct_dx50    direction=dl    target_throughput=${dl_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cells=${cells1}    log=${log_path}


Update LbpsPeriodList With Current Time
    Log To Console    \n ### Update LbpsPeriodList With Current Time ###
    ${lbps_period_list}   Update Parameter LbpsPeriodList With Current Time    NRPGRP_index=111    lbpsDuration=60
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${lbps_period_list}  connection=COAM
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    timeout=120    connection=COAM


Scf commission and wait on-air
    [Arguments]   ${scf_name}   ${connection}=${connection}
    log to console    \n scf commission and wait for on-air
    Conect to DU COAM
    coam.perform_commissioning
    ...   scf_file=${scf_file_path}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
	sleep    60s
    ${run_status}    run keyword and return status     Wait Until Keyword Succeeds   10m   1m   COAM Check BTS All Cells Onair
    ${alarm_status}    run keyword and return status    Check No Unexpected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No Unexpected History Alarm
    ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
    ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    ${snapshot_file}    Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
    Should Be Equal    ${status}    pass
    [teardown]    Run Keyword And Ignore error    COAM Logout

Download And Check Spark L3 Log
    [Documentation]    Export Spark .saf log to XML and check for SCell release in RRC Reconfiguration
    [Arguments]    ${ue_alias}=spark_UE

    ${date}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S

    # Create log directory if it doesn't exist
    ${dir_exists}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${TEST_LOG_DIRECTORY}
    Run Keyword Unless    ${dir_exists}    OperatingSystem.Create Directory    ${TEST_LOG_DIRECTORY}

    ${local_xml}    Set Variable    ${TEST_LOG_DIRECTORY}/spark_l3msg_${date}.xml

    # Spark saves binary .saf logs in Data/Tmp directory during test execution
    # We need to manually export .saf to XML and download it

    log to console    Exporting Spark L3 message detail from .saf to XML format...

    # Get Spark UE configuration using helper library
    ${ue_host}    CB014095_Spark_Helper.Get Spark UE Config    ${ue_alias}    host
    ${ue_user}    CB014095_Spark_Helper.Get Spark UE Config    ${ue_alias}    username
    ${ue_pass}    CB014095_Spark_Helper.Get Spark UE Config    ${ue_alias}    password
    ${spark_exe}    CB014095_Spark_Helper.Get Spark UE Config    ${ue_alias}    apppath

    # Get Spark log path from library's client store
    ${spark_log_path}    CB014095_Spark_Helper.Get Spark Log Config    ${ue_host}    logpath
    ${spark_log_name}    CB014095_Spark_Helper.Get Spark Log Config    ${ue_host}    logname
    log to console    Spark PC Host: ${ue_host}
    log to console    Spark exe: ${spark_exe}
    log to console    Spark log path: ${spark_log_path}
    log to console    Spark log name: ${spark_log_name}

    # Use the actual log path from start_log
    # Based on user confirmation: C:\tmp\uelog\AUTO\1770283400 contains TA_LOG-1.saf format
    ${spark_actual_path}    Set Variable    ${spark_log_path}

    log to console    Spark actual log path: ${spark_actual_path}

    # Get UE index from Spark library
    # Note: ueindex structure differs between libraries:
    # - sparkMultiUE_yiyuan: dictionary like {1: 2}
    # - sigspark_mmw3: may be direct integer like 2
    ${spark_obj}    CB014095_Spark_Helper.Get Spark UE Object    ${ue_alias}
    ${ueindex_dict}    Set Variable    ${spark_obj.ueindex}
    ${ueindex}    Run Keyword If    '${ueindex_dict.__class__.__name__}' == 'dict'
    ...    Evaluate    list(${ueindex_dict}.values())[0]
    ...    ELSE    Set Variable    ${ueindex_dict}

    log to console    UE index: ${ueindex}

    # Build the .saf filename based on Spark naming convention: {logname}-{ueindex}.saf
    ${saf_filename}    Set Variable    ${spark_log_name}-${ueindex}.saf
    ${full_saf_path}    Set Variable    ${spark_actual_path}/${saf_filename}

    # Generate XML filename
    ${xml_filename}    Set Variable    spark_l3msg_${date}.xml
    ${full_xml_path}    Set Variable    ${spark_actual_path}/${xml_filename}

    log to console    SAF file: ${full_saf_path}
    log to console    XML file: ${full_xml_path}

    # Send ExportMessageDetail command to Spark via socket API
    log to console    Sending ExportMessageDetail command to Spark...

    ${export_success}    CB014095_Spark_Helper.Export Spark Message Detail
    ...    ${ue_alias}    ${full_xml_path}    ${full_saf_path}

    log to console    Export command sent
    Sleep    2s    reason=Wait for command to be processed

    ${response}    CB014095_Spark_Helper.Get Spark Message Response
    ...    ${ue_alias}    ExportMessageDetail

    log to console    Export command response: ${response}

    Sleep    5s    reason=Wait for XML export to complete

    # Connect via SSH and download the XML file
    ${ssh_alias}    Set Variable    spark_download
    csn.Connect to    hostname=${ue_host}    username=${ue_user}    password=${ue_pass}    alias=${ssh_alias}

    log to console    Downloading ${full_xml_path} to ${local_xml}...
    csn.download_file    remote_path=${full_xml_path}    local_path=${local_xml}    connection=${ssh_alias}

    csn.disconnect    connection=${ssh_alias}

    log to console    Export completed, checking file existence...

    # Verify file was downloaded
    OperatingSystem.File Should Exist    ${local_xml}    msg=Failed to download XML file from Spark PC

    log to console    Spark L3 message log exported and downloaded to: ${local_xml}

    # Parse the XML and check for SCell release
    log to console    Parse Spark log to find RRC Reconfiguration with sCellToReleaseList
    ${found_scell_release}    Check Spark Log For SCell Release    spark_log=${local_xml}

    Run Keyword If    ${found_scell_release}
    ...    Log To Console    ✓ PASS: RRC Reconfiguration with sCellToReleaseList found - SCell was released
    ...    ELSE
    ...    Fail    ✗ FAIL: No RRC Reconfiguration message with sCellToReleaseList found in Spark log

    [Return]    ${local_xml}

Download Spark L3 Message Log
    [Documentation]    DEPRECATED - sparkMultiUE_yiyuan.stop_log now handles download directly. Kept for reference.
    #[Arguments]    ${ue_alias}=spark_UE

    Log To Console    This keyword is deprecated. Use sparkMultiUE_yiyuan.stop_log directly with target path.
    Fail    This keyword should not be called. Use sparkMultiUE_yiyuan.stop_log(ue_alias, logname=path) instead.

Check Spark Log For SCell Release
    [Documentation]    Parse Spark L3 message log to check for sCellToReleaseList in RRC Reconfiguration
    [Arguments]    ${spark_log}

    log to console    Checking Spark L3 message log: ${spark_log}

    # Verify file exists
    OperatingSystem.File Should Exist    ${spark_log}    msg=Spark log file not found: ${spark_log}

    # Read XML content and search for sCellToReleaseList
    ${xml_content}    OperatingSystem.Get File    ${spark_log}

    log to console    XML file size: ${xml_content.__len__()} bytes

    # Check if sCellToReleaseList exists in the XML
    ${scell_release_found}    Run Keyword And Return Status
    ...    Should Contain    ${xml_content}    sCellToReleaseList

    # Also check for RRCReconfiguration message
    ${rrc_reconfig_found}    Run Keyword And Return Status
    ...    Should Contain    ${xml_content}    RRCReconfiguration

    Run Keyword If    ${rrc_reconfig_found}
    ...    Log To Console    ✓ Found RRCReconfiguration message in log
    ...    ELSE
    ...    Log To Console    ✗ No RRCReconfiguration message found

    Run Keyword If    ${scell_release_found}
    ...    Log To Console    ✓ Found sCellToReleaseList in RRC Reconfiguration message
    ...    ELSE
    ...    Log To Console    ✗ No sCellToReleaseList found in Spark log

    [Return]    ${scell_release_found}

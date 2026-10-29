*** Settings ***
Documentation
...   author: shushu huang
...   contact: shushu.huang@nokia-sbell.com
...   squad group: PZ3_SG3
...   Feature CB013388 KPI

Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Library    SSHLibrary
Library    OperatingSystem
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library    sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.transport.ssh    WITH NAME    csn
Library    DateTime


*** Variables ***
${connection}    COAM
${ALLOWED_ALARMS}    '61524', '61652', '4654', '4655', '49', '50', '4592', '4614', '61649', '7319', '7300', '6327',
...    '61510', '23', '7107'
${UE_ALIAS}    SPARK_UE
@{UE_INDEX}    0    1    2    3    4    5
${local_path}    /home/ute/Case_Logs/ipconfig.txt
${ute_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}     ${tl.test_pc.default_ssh_connection_details.password}
@{ul_traffic_list}    25   25   25   25    25   25
@{port_list}    43371   43373   43375   43377    43379    43381
${traffic_duration}   1200
@{nr_TDD_cell_list}      171409410
@{nr_FDD_cell_list}      171409409

*** Keywords ***
Test Case setup
    Run Keyword And Ignore Error    robot_common_operations.Common case setup    fail_with_alarms=False
    Check Testline Status after Upgrade

Check Testline Status after Upgrade
    log to console     \n Check Testline Status after Upgrade
    Connect to gnb coam via ssl    connection=${connection}
    ${status}    Check Cells Onair And No Unexpected Alarm    Check_timer=30s
    Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
    ...     Active_FaultID=${Active_FaultID}  History_FaultID=${History_FaultID}
    [teardown]    COAM Teardown gnb connections    connection=${connection}

Collect snapshot logs
    [Arguments]    ${snapshot_path}=${TEST_LOG_DIRECTORY}    ${TESTLINEID}=${TESTLINEID}   ${Active_FaultID}=None   ${History_FaultID}=None
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

Check Cells Onair And No Unexpected Alarm
    [Arguments]    ${Check_timer}=5min    ${Interval}=10s    ${Check_Degraded}=True
    log to console     Check Cells Onair And No Unexpected Alarm
    ${run_status}    run keyword and return status    Wait Until Keyword Succeeds
    ...              ${Check_timer}   ${Interval}   COAM Check BTS All Cells Onair    Check_Degraded=${Check_Degraded}
    Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check BTS All Cells Status
    Run Keyword If    "${run_status}"=="False"    Run Keyword And Ignore Error    COAM Check BTS All RU Status
    ${alarm_status}    run keyword and return status    Check No Unexpected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No Unexpected History Alarm
    ${alarm_status}    Evaluate    ${alarm_status} and ${history_alarm_status}
    ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    Run keyword and continue on failure    Should Be Equal    ${status}    pass
    [Return]    ${status}

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

COAM Check BTS All Cells Onair
    [Arguments]   ${connection}=${connection}    ${Check_Degraded}=True
    log to console     Check all cells onair
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${len_lte}    Get Length    ${bts_info['cells']['lte']}
    ${len_nr}    Get Length    ${bts_info['cells']['nr']}
    Run Keyword If    ${len_lte} > 0    Get All Cells Onair Status   cell_list=${bts_info['cells']['lte']}    Check_Degraded=${Check_Degraded}
    Run Keyword If    ${len_nr} > 0    Get All Cells Onair Status    cell_list=${bts_info['cells']['nr']}    Check_Degraded=${Check_Degraded}

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

Test Case teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown


UE attach to cell1 ${num} times
    log to console    \n*****UEs handover ${num} times*****
    FOR   ${i}   IN RANGE   ${num}
        Step1: Prepare MultiUE And Attach
        Step2: MultiUE Detach
    END


UE attach to cell2 ${num} times
    log to console    \n*****UEs handover ${num} times*****
    FOR   ${i}   IN RANGE   ${num}
        Step1: Prepare MultiUE And Attach
        Step2: MultiUE Detach
    END


UE handover ${num} times
    log to console    \n*****UEs handover ${num} times*****
    FOR   ${i}   IN RANGE   ${num}
        Set PA prepare handover to cell1
        sleep    5s
        Set PA prepare handover to cell2
        sleep    5s
    END


Step1: Prepare MultiUE And Attach
    Log to console    \n*****UEs attach*****
    Prepare MultiUE And Attach    restart_ue=False   multiue_config_direction=${TLCommonConfig["MultiUECFG_SA"]}
    sleep    2s

Step2: Start UDP Traffic
   MultiUE Start UDP Traffic    ul_port_list=${port_list}   ul_tp_list=${ul_traffic_list}    ul_duration=${traffic_duration}
    sleep    2s

Step3: Check TP for FDD
    log to console    "Check throughput"
    Check UE Tput From Aasyslog   log_time=600s   ul_list=${nr_FDD_cell_list}   dl_list=${nr_FDD_cell_list}
    ...   actCarrierAggregation=${False}   exp_ul_tp=50   exp_dl_tp=100
    ...   target_avg_percent=0.5   min_percent=0

Step3: Check TP for TDD
    log to console    "Check throughput"
    Check UE Tput From Aasyslog   log_time=15s   ul_list=${nr_TDD_cell_list}   dl_list=${nr_TDD_cell_list}
    ...   actCarrierAggregation=${False}   exp_ul_tp=60   exp_dl_tp=400
    ...   target_avg_percent=0.5   min_percent=0


Check UE Tput From Aasyslog
    [Arguments]    ${log_time}    ${ul_list}    ${dl_list}   ${actCarrierAggregation}   ${exp_ul_tp}   ${exp_dl_tp}
    ...    ${target_avg_percent}    ${min_percent}   ${if_ul}=${True}    ${if_dl}=${True}
    ${log_path}    power_ue.Collect Tput   ue_type=samsung    duration=${log_time}    ignore_time=10s
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    min_percent=${min_percent}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    min_percent=${min_percent}


Set PA prepare for cell2
    @{channels}=    create list    1    2    3    4
    Modify HBTE Channel Vaules    channels=${channels}    value=60    ru_id=0    gnb_id=0
    sleep    2s
    @{channels}=    create list    5    6    7    8
    Modify HBTE Channel Vaules    channels=${channels}    value=15    ru_id=1    gnb_id=0
    sleep    2s

Set PA prepare for cell1
    @{channels}=    create list    1    2    3    4
    Modify HBTE Channel Vaules    channels=${channels}    value=0    ru_id=0    gnb_id=0
    sleep    2s
    @{channels}=    create list    5    6    7    8
    Modify HBTE Channel Vaules    channels=${channels}    value=60    ru_id=1    gnb_id=0
    sleep    2s

Set PA prepare handover to cell1
    @{channels}=    create list    1    2    3    4
    Modify HBTE Channel Vaules    channels=${channels}    value=0    ru_id=0    gnb_id=0
    sleep    2s
    @{channels}=    create list    5    6    7    8
    Modify HBTE Channel Vaules    channels=${channels}    value=30    ru_id=1    gnb_id=0
    sleep    2s

Set PA prepare handover to cell2
    @{channels}=    create list    5    6    7    8
    Modify HBTE Channel Vaules    channels=${channels}    value=15    ru_id=1    gnb_id=0
    sleep    2s
    @{channels}=    create list    1    2    3    4
    Modify HBTE Channel Vaules    channels=${channels}    value=30    ru_id=0    gnb_id=0
    sleep    2s

Step2: MultiUE Detach
    MultiUE Detach
    sleep    2s

Modify HBTE Channel Vaules
    [Arguments]    ${channels}    ${value}=63    ${ru_id}=0    ${gnb_id}=0
    #${channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${ru_id}    gnb_id=${gnb_id}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=HBTE
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value}
    END
    Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}


set CB01338 to True
    log to console    set CB01338 to True
    Conect to DU COAM
    ${actAdaptiveSr}    Create Dictionary    parameterName=actAdaptiveSr    value=true   operation=update
    ${actServiceAwareConfig}    Create Dictionary    parameterName=actServiceAwareConfig    value=true    operation=update
    ${actUlCgType2}    Create Dictionary    parameterName=actUlCgType2    value=true   operation=update
    @{CB013388_true}    Create List    ${actAdaptiveSr}    ${actServiceAwareConfig}    ${actUlCgType2}
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10462/NRBTS-10462/NRCELL-1    parameter=${CB013388_true}
    ...    operation=update    connection=COAM
    sleep    5s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10462/NRBTS-10462/NRCELL-2    parameter=${CB013388_true}
    ...    operation=update    connection=COAM
    sleep    5s
    [teardown]    Run Keyword And Ignore error    COAM Logout

set CB01338 to False
    log to console    set CB01338 to False
    Conect to DU COAM
    ${actAdaptiveSr}    Create Dictionary    parameterName=actAdaptiveSr    value=false   operation=update
    ${actServiceAwareConfig}    Create Dictionary    parameterName=actServiceAwareConfig    value=false    operation=update
    ${actUlCgType2}    Create Dictionary    parameterName=actUlCgType2    value=false   operation=update
    @{CB013388_false}    Create List    ${actAdaptiveSr}    ${actServiceAwareConfig}    ${actUlCgType2}
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10462/NRBTS-10462/NRCELL-1    parameter=${CB013388_false}
    ...    operation=update    connection=COAM
    sleep    5s
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-10462/NRBTS-10462/NRCELL-2    parameter=${CB013388_false}
    ...    operation=update    connection=COAM
    sleep    5s
    [teardown]    Run Keyword And Ignore error    COAM Logout

Conect to DU COAM
    [Arguments]    ${connection}=${connection}
    coam.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}



Wait for one counter period
    [Arguments]    ${interval_time}=5min
    ${wait_time}    Get wait value minutes    interval=${interval_time}
    log to console      .....wait ${wait_time}mins+${interval_time}....
    sleep    ${wait_time}min
    sleep    ${interval_time}

Get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${wait_time}
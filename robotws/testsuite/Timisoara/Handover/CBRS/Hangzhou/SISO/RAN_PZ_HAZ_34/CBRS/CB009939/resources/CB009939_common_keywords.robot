*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB009939

Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    ../../resources/cbrs_common_keywords.robot
Library    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/CB009939_variables.py

*** Variables ***
${CB009939_json_path}    ${CURDIR}/json
${disable_actcbrs_actnrcbrs_953}    ${CB009939_json_path}/disable_actcbrs_actnrcbrs_953.json
${disable_actcbrs_actnrcbrs_1001}    ${CB009939_json_path}/disable_actcbrs_actnrcbrs_1001.json
${enable_actcbrs_actnrcbrs_953}    ${CB009939_json_path}/enable_actcbrs_actnrcbrs_953.json
${enable_actcbrs_actnrcbrs_1001}    ${CB009939_json_path}/enable_actcbrs_actnrcbrs_1001.json
${change_redundancyCbrsCellPair_1001}    ${CB009939_json_path}/change_redundancyCbrsCellPair_1001.json
${change_redundancyCbrsCellPair_953}    ${CB009939_json_path}/change_redundancyCbrsCellPair_953.json
${disable_actcbrs_1001}    ${CB009939_json_path}/disable_actcbrs_1001.json
${disable_actnrcbrs_953}    ${CB009939_json_path}/disable_actnrcbrs_953.json
${CB009939_conf_path}    ${CURDIR}/conf
${CB009939_cc_7_conf}    ${CB009939_conf_path}/CB009939_cc_7.conf


*** Keywords ***
CB009939 CBRS Suite Setup
    Download Sas Server
    log to console    \n***CB009939 CBRS Suite Setup***
    set suite variable    ${test_teardown_fail}    ${True}
    robot_common_operations.CommonSuiteSetup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    check and power on or off enb    powerStatus=off
    Sleep    100s
    COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}    connection=GNB_OAM    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    Connect to eNB via ssl
    ${SCF_1001}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_1001_
    COAM Commission with scf file    scf_file_path=${SCF_1001}    connection=enblte    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    Check RU Onair
    Check RU Onair    connection=enblte
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${SCF_1001}
    log to console  ENB_MRBTS_ID:${mrbtsID_enb}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID_enb}
    set suite variable  ${lnbtsID}
    &{fault_7312}     Create Dictionary     faultId=${7312}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    &{fault_6826}     Create Dictionary     faultId=${6826}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7312}    ${fault_7313}    ${fault_6826}
    set suite variable  ${ALLOWED_FAULT}
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    add allowed cbrs history fault to the allowed history fault list
    delete_icmp_policy
    Run Keyword And Ignore Error    kill SAS server started by manual

CB009939 CBRS Test Setup
    log to console    \n***CB009939 CBRS Test Setup***
    robot_common_operations.CommonCaseSetup    allowed_faults_ids=6832,4739,1815,16
    AlarmWatchdog.add_allow_alarms    fault_id=6832
    AlarmWatchdog.add_allow_alarms    fault_id=4739
    AlarmWatchdog.add_allow_alarms    fault_id=6831
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=16
    log to console    Active_SW_version:${Active_SW_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5min    30s    Connect to eNB via ssl
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[1]    ${False}
    Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    ${scf_path_9939}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    set test variable    ${scf_path_9939}
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser

CB009939 CBRS Test Teardown
    log to console    \n***CB009365-C CBRS Test Teardown***
    save_sas_log    dstFile=${TS_CASE_LOG_PATH}/SAS_Sim.log
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    robot_common_operations.CommonCaseTeardown
    set suite variable    ${test_teardown_fail}    ${False}
    kill process for SAS server
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${alarm_status_1001}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    ...    connection=enblte
    should be true    ${alarm_status_1001}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    ${history_alarm_status_1001}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=enblte
    should be true    ${history_alarm_status_1001}
    run keyword if test failed     Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    run keyword if test failed     Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=enblte
    COAM Teardown gnb connections
    Enblte close down
    CI_interface.Common Case Teardown

CB009939 CBRS Suite Teardown
    log to console    \n***CBRS Suite Teardown***
    robot_common_operations.CommonSuiteTeardown
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5min    30s    Connect to eNB via ssl
    run keyword if    ${test_teardown_fail}    run keywords
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=enblte    AND
    ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    ...    ELSE
    ...    log to console    don't collect snapshot in suite teardown!!!
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

CB009939 Modify the parameter
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=${connection}

CB009939 CBRS NR And LTE CPE Call
    [Arguments]    ${tput_expect}    ${cell_id1}=${1}    ${duration}=${300}    ${tput_from}=tool    ${target_avg}=0.98    ${min_percent}=0.85
    ...    ${ue_index_LTE}=${0}    ${throughput_dl_LTE}=350    ${throughput_ul_LTE}=50    ${target_throughput_dl_LTE}=280
    ...    ${target_throughput_ul_LTE}=12.3
    ${tput_expect}    get_self_define_tput_by_release    tput_info=${tput_expect}
    ${tput_info_total}    create dictionary
    ${tput_cell1}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool    cell_id=${cell_id1}    target_avg_percent=${target_avg}
    ...    min_percent=${min_percent}    duration=${duration}    ue_index=${1}    connection=GNB_OAM
    ...    ELSE    set variable    ${tput_expect[${cell_id1}]}
    set to dictionary    ${tput_info_total}    ${cell_id1}    ${tput_cell1}
    log to console    tput info for cell ${cell_id1} is: ${tput_cell1}
    ${ue_index1}    set variable    ${tput_expect[${cell_id1}]['ue_index']}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${ue_index1}
    make_call    tput_info=${tput_cell1}    ue_index=${ue_index1}    process_num_ul=5
    ${tput_log1}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_id1}    ue_index=${ue_index1}    tput_log=${tput_log1}
    ...    target_avg_percent=${target_avg}    min_percent=${min_percent}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    ${ue_type_4G}    translate_power_ue_type_from_testline    ue_index=${ue_index_LTE}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${ue_index_LTE}
    Sleep    300s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_LTE}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${ue_index_LTE}    duration=${duration}    target_avg_percent=${target_avg}
    ...    min_percent=${min_percent}    ignore_time=60
    log to console    LTE tput check pass
    [Teardown]    Run Keywords    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}    AND
    ...    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_LTE}

CB008923-C_26_data_transfer_conducted_peak_throughput_NR_40MHz_LTE_20MHz
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=16
    AlarmWatchdog.add_allow_alarms    fault_id=10
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_8923}    value=${25}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_1149}    value=${39}
    ${SCF_8923_tl953}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_8923_tl953_
    COAM Commission with scf file    scf_file_path=${SCF_8923_tl953}    connection=GNB_OAM    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    ${SCF_8923_tl1001}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_8923_tl1001_
    COAM Commission with scf file    scf_file_path=${SCF_8923_tl1001}    connection=enblte    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=enblte
    Sleep    300s
    ${gNb_CuType}   Get gNB CU type
    set test variable    ${gNb_CuType}
    CB009939 CBRS NR And LTE CPE Call    tput_expect=${tput_define_nr40_lte20}    cell_id1=${1}    throughput_dl_LTE=300
    ...    target_throughput_dl_LTE=107
    [Teardown]    CB008923-C_26 recovery ENV

CB008923-C_26 recovery ENV
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_1001}    connection=enblte
    Sleep    30s
    coam.perform_delta_recommissioning    delta_file=${disable_actnrcbrs_953}    connection=GNB_OAM
    Sleep    120s

CB009939-SR-C_7_online_change_Redundancy_Cell_Pair_list
    &{fault_4739}     Create Dictionary     faultId=${4739}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4739}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    Check all the Cell status    connection=GNB_OAM    operationalState=disabled    usageState=idle
    Check all the Cell status    connection=enblte    operationalState=disabled    usageState=idle
    start SAS server    config_name=${CB009939_cc_7_conf}    path=${sas_3}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs_1001}    connection=enblte
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs_953}    connection=GNB_OAM
    Sleep    60s
    Check all the Cell status    connection=GNB_OAM    operationalState=disabled    usageState=idle
    Check all the Cell status    connection=enblte    operationalState=disabled    usageState=idle
    Sleep    10s
    CB009939 Modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=active    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair    connection=GNB_OAM
    Wait until keyword succeeds    5min    30s    verify cell status not degrade or disable by cellid    cellid=294
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    5min    30s    verify cell status not degrade or disable by cellid    cellid=293
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=10
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=12
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte
    ${nrcell1_grantid_953}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell2_grantid_953}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=2
    ${ltecell11_grantid_953}    Get CBSDCEL_R value via COAM    cellID=46630    pattern=grantId
    ${ltecell12_grantid_953}    Get CBSDCEL_R value via COAM    cellID=46631    pattern=grantId
    CB009939 Modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=standby    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    30s    Check all the Cell status    connection=GNB_OAM    operationalState=disabled
    ...    usageState=idle
    CB009939 Modify the parameter    dist_name=MRBTS-${mrbtsID_enb}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=active    connection=enblte
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair    connection=enblte
    Wait until keyword succeeds    5min    30s    verify cell status not degrade or disable by cellid    cellid=193
    ...    administrative=Unlocked    operationalState=enabled    connection=enblte
    Wait until keyword succeeds    5min    30s    verify cell status not degrade or disable by cellid    cellid=194
    ...    administrative=Unlocked    operationalState=enabled    connection=enblte
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=20
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte    connection=enblte
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=21
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte    connection=enblte
    ${nrcell1_grantid_1001}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=11    connection=enblte
    ${nrcell2_grantid_1001}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=22    connection=enblte
    ${ltecell11_grantid_1001}    Get CBSDCEL_R value via COAM    cellID=46370    pattern=grantId    connection=enblte
    ${ltecell12_grantid_1001}    Get CBSDCEL_R value via COAM    cellID=46371    pattern=grantId    connection=enblte
    Should be True    '${nrcell1_grantid_953}'=='${nrcell1_grantid_1001}'
    Should be True    '${nrcell2_grantid_953}'=='${nrcell2_grantid_1001}'
    Should be True    '${ltecell11_grantid_953}'=='${ltecell11_grantid_1001}'
    Should be True    '${ltecell12_grantid_953}'=='${ltecell12_grantid_1001}'
    Check CB009939-SR-CC_7 SAS log by cbsdid    cbsdid=1108_Nokia_DH214200205.NR
    Check CB009939-SR-CC_7 SAS log by cbsdid    cbsdid=nokia_100_1M184800058
    coam.perform_delta_recommissioning    delta_file=${change_redundancyCbrsCellPair_953}    connection=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${change_redundancyCbrsCellPair_1001}    connection=enblte
    Sleep    30s
    Wait Until Keyword Succeeds    3min    30s    Check all cells info should be onair    connection=enblte
    Wait until keyword succeeds    3min    30s    verify cell status not degrade or disable by cellid    cellid=193
    ...    administrative=Unlocked    operationalState=enabled    connection=enblte
    Wait until keyword succeeds    3min    30s    verify cell status not degrade or disable by cellid    cellid=194
    ...    administrative=Unlocked    operationalState=enabled    connection=enblte
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=20
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte    connection=enblte
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=21
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte    connection=enblte
    ${nrcell1_grantid_1001}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=11    connection=enblte
    ${nrcell2_grantid_1001}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=22    connection=enblte
    ${ltecell11_grantid_1001}    Get CBSDCEL_R value via COAM    cellID=46370    pattern=grantId    connection=enblte
    ${ltecell12_grantid_1001}    Get CBSDCEL_R value via COAM    cellID=46371    pattern=grantId    connection=enblte
    CB009939 Modify the parameter    dist_name=MRBTS-${mrbtsID_enb}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=standby    connection=enblte
    Wait Until Keyword Succeeds    10min    30s    Check all the Cell status    connection=enblte    operationalState=disabled
    ...    usageState=idle
    CB009939 Modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=active    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair    connection=GNB_OAM
    Wait until keyword succeeds    5min    30s    verify cell status not degrade or disable by cellid    cellid=294
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    5min    30s    verify cell status not degrade or disable by cellid    cellid=293
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=10
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=12
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte
    ${nrcell1_grantid_953}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell2_grantid_953}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=2
    ${ltecell11_grantid_953}    Get CBSDCEL_R value via COAM    cellID=46630    pattern=grantId
    ${ltecell12_grantid_953}    Get CBSDCEL_R value via COAM    cellID=46631    pattern=grantId
    Should be True    '${nrcell1_grantid_953}'=='${nrcell2_grantid_1001}'
    Should be True    '${nrcell2_grantid_953}'=='${nrcell1_grantid_1001}'
    Should be True    '${ltecell11_grantid_953}'=='${ltecell12_grantid_1001}'
    Should be True    '${ltecell12_grantid_953}'=='${ltecell11_grantid_1001}'
    [Teardown]    CB009939-SR-CC_7 recovery ENV

Check CB009939-SR-CC_7 no registrationRequest
    prepare_to_check_message_from_start
    Check if message is not found in saslog    tag={\"registrationRequest\":.*
    [Teardown]    end_to_check

Check CB009939-SR-CC_7 SAS log by cbsdid
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*\"grantRenew\":true.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB009939-SR-CC_7 recovery ENV
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_actnrcbrs_1001}    connection=enblte
    Sleep    30s
    CB009939 Modify the parameter    dist_name=MRBTS-${mrbtsID_enb}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=standby    connection=enblte
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_actnrcbrs_953}    connection=GNB_OAM
    Sleep    30s
    CB009939 Modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=standby    connection=GNB_OAM
    Sleep    120s

CB009939-SR-CC_7_Do_controlled_switchover_concurrent
    &{fault_4739}     Create Dictionary     faultId=${4739}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_4739}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    Sleep    120s
    Check all the Cell status    connection=GNB_OAM    operationalState=disabled    usageState=idle
    Check all the Cell status    connection=enblte    operationalState=disabled    usageState=idle
    start SAS server    config_name=${CB009939_cc_7_conf}    path=${sas_3}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs_1001}    connection=enblte
    Sleep    120s
    Check CB009939-SR-CC_7 no registrationRequest
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs_953}    connection=GNB_OAM
    Sleep    30s
    CB009939 Modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=active    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair    connection=GNB_OAM
    Wait until keyword succeeds    5min    30s    verify cell status not degrade or disable by cellid    cellid=294
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    5min    30s    verify cell status not degrade or disable by cellid    cellid=293
    ...    administrative=Unlocked    operationalState=enabled
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=10
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=12
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte
    ${nrcell1_grantid_953}    Get subGrantInfo Item by Coam    pattern=grantIdSub
    ${nrcell2_grantid_953}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=2
    ${ltecell11_grantid_953}    Get CBSDCEL_R value via COAM    cellID=46630    pattern=grantId
    ${ltecell12_grantid_953}    Get CBSDCEL_R value via COAM    cellID=46631    pattern=grantId
    CB009939 Modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=standby    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    30s    Check all the Cell status    connection=GNB_OAM    operationalState=disabled
    ...    usageState=idle
    CB009939 Modify the parameter    dist_name=MRBTS-${mrbtsID_enb}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=active    connection=enblte
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair    connection=enblte
    Wait until keyword succeeds    5min    30s    verify cell status not degrade or disable by cellid    cellid=193
    ...    administrative=Unlocked    operationalState=enabled    connection=enblte
    Wait until keyword succeeds    5min    30s    verify cell status not degrade or disable by cellid    cellid=194
    ...    administrative=Unlocked    operationalState=enabled    connection=enblte
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=20
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte    connection=enblte
    Wait until keyword succeeds    2min    30s    verify cell status not degrade or disable by cellid    cellid=21
    ...    administrative=unlocked    operationalState=enabled    cell_type=lte    connection=enblte
    ${nrcell1_grantid_1001}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=11    connection=enblte
    ${nrcell2_grantid_1001}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=22    connection=enblte
    ${ltecell11_grantid_1001}    Get CBSDCEL_R value via COAM    cellID=46370    pattern=grantId    connection=enblte
    ${ltecell12_grantid_1001}    Get CBSDCEL_R value via COAM    cellID=46371    pattern=grantId    connection=enblte
    Should be True    '${nrcell1_grantid_953}'=='${nrcell1_grantid_1001}'
    Should be True    '${nrcell2_grantid_953}'=='${nrcell2_grantid_1001}'
    Should be True    '${ltecell11_grantid_953}'=='${ltecell11_grantid_1001}'
    Should be True    '${ltecell12_grantid_953}'=='${ltecell12_grantid_1001}'
    Check CB009939-SR-CC_7 SAS log by cbsdid    cbsdid=1108_Nokia_DH214200205.NR
    Check CB009939-SR-CC_7 SAS log by cbsdid    cbsdid=nokia_100_1M184800058
    [Teardown]    CB009939-SR-CC_7 recovery ENV

CB005763-BA_Dying_Gasp_alarm_check_cpri_RFS_on_primary_BTS_AZNA
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${unit_index}=${0}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    &{fault_4739}     Create Dictionary     faultId=${4739}
    &{fault_4220}     Create Dictionary     faultId=${4220}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}    ${fault_4739}    ${fault_4220}
    set test variable  ${ALLOWED_HISTORY_FAULT}
    ${SCF_8923_tl953}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_8923_tl953_
    COAM Commission with scf file    scf_file_path=${SCF_8923_tl953}    connection=GNB_OAM    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    ${SCF_8923_tl1001}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_8923_tl1001_
    COAM Commission with scf file    scf_file_path=${SCF_8923_tl1001}    connection=enblte    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=enblte
    ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[3].pdu_port.pdu.__class__.__name__}
    ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[3].pdu_port.pdu.addr}
    ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[3].pdu_port.port_no}
    log to console    model is ${model}, pb ip is ${address}, pb port is ${port}
    pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_4
    pdu.power off    port=${port}    pdu_device=pdu_ru_4
    Wait Until Keyword Succeeds    5 min    10 sec    Check Specific Alarm in Alarm List    type=Active
    ...    faultId=10    Supplementary=RU connection was lost in runtime;RU power loss
    pdu.power on    port=${port}    pdu_device=pdu_ru_4
    Wait Until Keyword Succeeds    15 min    10 sec    Verify all cells should be onair
    ${gnb_model}    set variable
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    ${gnb_pdu_ip}    set variable
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${gnb_pdu_port}    set variable
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.port_no}
    log to console    model is ${gnb_model}, gnb_pdu_ip is ${gnb_pdu_ip}, gnb_pdu_port is ${gnb_pdu_port}
    pdu.Setup Pdu    model=${gnb_model}   host=${gnb_pdu_ip}    alias=gnb_pdu
    pdu.power off    port=${gnb_pdu_port}    pdu_device=gnb_pdu
    Wait Until Keyword Succeeds    10min    5 sec    Check one Alarm in Alarm List    type=Active
    ...    faultId=4220    connection=enblte
    Wait until keyword succeeds    5 min    30 sec    Verify all lte cells should be onair    connection=enblte
    pdu.power off    port=${port}    pdu_device=pdu_ru_4
    Wait Until Keyword Succeeds    5 min    10 sec    Check Specific Alarm in Alarm List    type=Active
	...    faultId=10    Supplementary=RU connection was lost in runtime;RU power loss    connection=enblte
    pdu.power on    port=${port}    pdu_device=pdu_ru_4
    [Teardown]    Run Keywords    run keyword and ignore error    pdu.power on    port=${gnb_pdu_port}    pdu_device=gnb_pdu    AND
    ...    run keyword and ignore error    Perform RU Power On    ru_index=${4}    AND
    ...    Wait until keyword succeeds    20min    30s    verify all cells should be onair

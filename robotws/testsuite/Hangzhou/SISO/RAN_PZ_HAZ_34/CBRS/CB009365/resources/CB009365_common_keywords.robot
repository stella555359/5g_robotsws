*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB009365

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../resources/cbrs_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/CB009365_variables.py

*** Variables ***
${CB009365_json_path}    ${CURDIR}/json
${attach_cell1}    ${CB009365_json_path}/attach_cell1.json
${attach_cell2}    ${CB009365_json_path}/attach_cell2.json
${attach_cell3}    ${CB009365_json_path}/attach_cell3.json
${attach_cell4}    ${CB009365_json_path}/attach_cell4.json
${attach_cell11}    ${CB009365_json_path}/attach_cell11.json
${attach_cell12}    ${CB009365_json_path}/attach_cell12.json
${attach_cell13}    ${CB009365_json_path}/attach_cell13.json
${attach_cell14}    ${CB009365_json_path}/attach_cell14.json
${disable_actcbrs}    ${CB009365_json_path}/disable_actcbrs.json
${enable_actcbrs}    ${CB009365_json_path}/enable_actcbrs.json
${disable_actcbrs_2165}    ${CB009365_json_path}/disable_actcbrs_2165.json
${enable_actcbrs_2165}    ${CB009365_json_path}/enable_actcbrs_2165.json
${disable_actcbrs_TL25_2cbsd}    ${CB009365_json_path}/disable_actcbrs_TL25_2cbsd.json
${enable_actcbrs_TL25_2cbsd}    ${CB009365_json_path}/enable_actcbrs_TL25_2cbsd.json
${disable_actcbrs_actnrcbrs_TL25}    ${CB009365_json_path}/disable_actcbrs_actnrcbrs_TL25.json
${enable_actcbrs_actnrcbrs_TL25}    ${CB009365_json_path}/enable_actcbrs_actnrcbrs_TL25.json
${disable_actcbrs_actnrcbrs_split}    ${CB009365_json_path}/disable_actcbrs_actnrcbrs_split.json
${enable_actcbrs_actnrcbrs_split}    ${CB009365_json_path}/enable_actcbrs_actnrcbrs_split.json
${attach_NRcell1_LTEcell11}    ${CB009365_json_path}/attach_NRcell1_LTEcell11.json
${attach_NRcell2_LTEcell12}    ${CB009365_json_path}/attach_NRcell2_LTEcell12.json
${attach_NRcell3_LTEcell13}    ${CB009365_json_path}/attach_NRcell3_LTEcell13.json
${attach_LTEcell14_TL25}    ${CB009365_json_path}/attach_LTEcell14_TL25.json
${attach_LTEcell11_TL2156}    ${CB009365_json_path}/attach_LTEcell11_TL2156.json
${attach_LTEcell12_TL2156}    ${CB009365_json_path}/attach_LTEcell12_TL2156.json
${attach_LTEcell13_TL2156}    ${CB009365_json_path}/attach_LTEcell13_TL2156.json
${attach_LTEcell14_TL2156}    ${CB009365_json_path}/attach_LTEcell14_TL2156.json
${9509_3cc_attach_cell1}    ${CB009365_json_path}/9509_3cc_attach_cell1.json
${9509_3cc_attach_cell2}    ${CB009365_json_path}/9509_3cc_attach_cell2.json
${9509_3cc_attach_cell3}    ${CB009365_json_path}/9509_3cc_attach_cell3.json
${disable_actcbrs_actnrcbrs_9509}    ${CB009365_json_path}/disable_actcbrs_actnrcbrs_9509.json
${enable_actcbrs_actnrcbrs_9509}    ${CB009365_json_path}/enable_actcbrs_actnrcbrs_9509.json
${conf_path}    ${CURDIR}/conf
${CB009365_A_1_2_conf}    ${conf_path}/CB009365_A_1_2.conf
${CB009365_A_4_conf}    ${conf_path}/CB009365_A_4.conf
${CB009365_C_1516_conf}    ${conf_path}/CB009365_C_1516.conf
${CB009365_C_5_conf}    ${conf_path}/CB009365_C_5.conf
${CB009509_60_40_80_conf}    ${conf_path}/CB009509_60_40_80.conf
${CB009365_C_030464_conf}    ${conf_path}/CB009365_C_030464.conf
@{cell_id_16}    ${1}
@{cell_id_40M}    ${2}
${SASServerip}    ${tl.test_pc.default_ssh_connection_details.addr}

*** Keywords ***
CB009365-C CBRS Suite Setup
    Download Sas Server
    log to console    \n***CB009365-C CBRS Suite Setup***
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
#    check and power on or off enb    powerStatus=off
    sleep    10
    run keyword if    '${if_commissioning}'=='True'
    ...    Commissioning SCF And Check RU On Air    scf_file_path=${Golden_SCF_Path}
    &{fault_7312}     Create Dictionary     faultId=${7312}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    &{fault_6826}     Create Dictionary     faultId=${6826}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7312}    ${fault_7313}    ${fault_6826}
    set suite variable  ${ALLOWED_FAULT}
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    add allowed cbrs history fault to the allowed history fault list
    delete_icmp_policy
    Run Keyword And Ignore Error    kill SAS server started by manual

CB009365-C CBRS Test Setup
    log to console    \n***CB009365-C CBRS Test Setup***
    robot_common_operations.CommonCaseSetup
    AlarmWatchdog.add_allow_alarms    fault_id=6832
    AlarmWatchdog.add_allow_alarms    fault_id=4614
    log to console    Active_SW_version:${Active_SW_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[1]    ${False}
    Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    ${scf_path_1}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    set test variable    ${scf_path_1}
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser

CB009365-C CBRS Test Teardown
    log to console    \n***CB009365-C CBRS Test Teardown***
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
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    run keyword if test failed     Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

Disable actcbrs and save SAS log
    [Arguments]    ${delta_file}
    save_sas_log    dstFile=${TS_CASE_LOG_PATH}/SAS_Sim.log
    coam.perform_delta_recommissioning    delta_file=${delta_file}    connection=GNB_OAM
    sleep    120

Disable actnrcbrs and save SAS log
    [Arguments]    ${actCbrsEnhMeas}=${False}
    save_sas_log    dstFile=${TS_CASE_LOG_PATH}/SAS_Sim.log
    Deactivate feature CBRS By Coam    actCbrsEnhMeas=${actCbrsEnhMeas}
    sleep    120

Disable actnrcbrs and actcbrs and save SAS log
    [Arguments]    ${delta_file}    ${actCbrsEnhMeas}=${False}
    save_sas_log    dstFile=${TS_CASE_LOG_PATH}/SAS_Sim.log
    Deactivate feature CBRS By Coam    actCbrsEnhMeas=${actCbrsEnhMeas}
    coam.perform_delta_recommissioning    delta_file=${delta_file}    connection=enblte
    sleep    120
    Enblte close down

Get CBSD value via COAM
    [Arguments]   ${cbsdID}=1    ${class_name}=CBSD_R    ${pattern}=assignedCbsdId
    ${MO}    coam.get_managed_objects    class_name=${class_name}    connection=GNB_OAM
    ${distname_tmp}    Set variable    ${MO[0]['distName']}
    ${distname}    generate_correct_cbsd_distname    distname_before=${distname_tmp}    cbsdid=${cbsdID}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=GNB_OAM
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Check No relinquishmentRequest in ENB
    [Arguments]     ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is not found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    [Teardown]    end_to_check

Check No relinquishmentRequest in GNB
    [Arguments]     ${cbsdid}    ${grantId}
    prepare_to_check_message_from_start
    Check if message is not found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*\"grantId\":\"${grantId}\".*
    [Teardown]    end_to_check

CB009365-C_64_online_add_and_delete_NR_cell_under_inter_BTS_split_mode
    ${SCF_CB009365_C_030464NR}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365_C_030464NR_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009365_C_030464NR}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${SCF_CB009365_C_030464NR}
    set test variable    ${mrbtsID}
    set test variable    ${nrbtsID}
    check and power on or off enb    powerStatus=on
    sleep    360
    Connect to eNB via ssl
    ${SCF_CB009365_C_030464LTE}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365_C_030464LTE_
    COAM Commission with scf file    scf_file_path=${SCF_CB009365_C_030464LTE}    connection=enblte    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${SCF_CB009365_C_030464LTE}
    log to console  ENB_MRBTS_ID:${mrbtsID_enb}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID_enb}
    set suite variable  ${lnbtsID}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_2165}    connection=enblte
    start SAS server    config_name=${CB009365_C_030464_conf}
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=enblte
    Verify all cells should be disabled
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_2165}    connection=enblte
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be disabled    connection=enblte
    Activate feature CBRS By Coam
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Verify all lte cells should be disabled    connection=enblte
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_2165}    connection=enblte
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=enblte
    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam    NRCBSDID=2
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2    NRCBSDID=2
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3    NRCBSDID=2
    Should be True    '${grant_info_cell1}[grantChannelType]'=='GAA'
    Should be True    '${grant_info_cell2}[grantChannelType]'=='GAA'
    Should be True    '${grant_info_cell3}[grantChannelType]'=='PAL'
    ${grantChannelType_cell11}    Get CBSDCEL_R value via COAM    cellID=11    pattern=grantChannelType    connection=enblte
    Should be True    '${grantChannelType_cell11}'=='PAL'
    ${grantChannelType_cell12}    Get CBSDCEL_R value via COAM    cellID=12    pattern=grantChannelType    connection=enblte
    Should be True    '${grantChannelType_cell12}'=='GAA'
    ${grantChannelType_cell13}    Get CBSDCEL_R value via COAM    cellID=13    pattern=grantChannelType    connection=enblte
    Should be True    '${grantChannelType_cell13}'=='GAA'
    ${grantChannelType_cell14}    Get CBSDCEL_R value via COAM    cellID=14    pattern=grantChannelType    connection=enblte
    Should be True    '${grantChannelType_cell14}'=='GAA'
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Online Cell deletion    deletion_cell=3    deletion_cellgrp=2
    Sleep    240s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check No relinquishmentRequest in ENB    cbsdid=${ltecbsdid}
    Check No relinquishmentRequest in GNB    cbsdid=${nrcbsdid}    grantId=${grant_info_cell2}[grantId]
    ${grant_info_cell1}    Get Grant Parameters By Coam    NRCBSDID=2
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2    NRCBSDID=2
    Should be True    '${grant_info_cell1}[grantChannelType]'=='PAL'
    Should be True    '${grant_info_cell2}[grantChannelType]'=='GAA'
    csn.reset_cache
    Sleep    10s
    Online Cell addition    file_path=${SCF_CB009365_C_030464NR}    addition_cell=3    addition_cellgrp=2
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2    NRCBSDID=2
    Should be True    '${grant_info_cell2}[grantChannelType]'=='GAA'
    Sleep    600s
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam    NRCBSDID=2
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2    NRCBSDID=2
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3    NRCBSDID=2
    Should be True    '${grant_info_cell1}[grantChannelType]'=='GAA'
    Should be True    '${grant_info_cell2}[grantChannelType]'=='GAA'
    Should be True    '${grant_info_cell3}[grantChannelType]'=='PAL'
    Check No relinquishmentRequest in ENB    cbsdid=${ltecbsdid}
    Check No relinquishmentRequest in GNB    cbsdid=${nrcbsdid}    grantId=${grant_info_cell2}[grantId]
    csn.reset_cache
    [Teardown]    Disable actnrcbrs and actcbrs and save SAS log    delta_file=${disable_actcbrs_2165}

CB009365-C_11_Frequency Selection Algorithm of one BTSes in 2x2T2R split mode with overlaping
#    Check LTE whether need power off
    ${SCF_CB009365_C_11495375}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365_C_11495375_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009365_C_11495375}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs_split}    connection=GNB_OAM
    start SAS server
    sleep    20
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    3min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=1
    Should be True    '${chBw_cell1}'=='40MHz'
    ${chBw_cell2}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=2
    Should be True    '${chBw_cell2}'=='20MHz'
    ${chBw_cell3}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=3
    Should be True    '${chBw_cell3}'=='20MHz'
    ${chBw_ltecell11}    Get LNCEL_TDD_A value via COAM    cellID=11
    Should be True    '${chBw_ltecell11}'=='20 MHz'
    ${chBw_ltecell12}    Get LNCEL_TDD_A value via COAM    cellID=12
    Should be True    '${chBw_ltecell12}'=='20 MHz'
    ${chBw_ltecell13}    Get LNCEL_TDD_A value via COAM    cellID=13
    Should be True    '${chBw_ltecell13}'=='20 MHz'
    ${chBw_ltecell14}    Get LNCEL_TDD_A value via COAM    cellID=14
    Should be True    '${chBw_ltecell14}'=='20 MHz'
    ${gNb_CuType}   Get gNB CU type
    set test variable    ${gNb_CuType}
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Set Test Variable    ${cell_type}
    Set Test Variable    ${cell_list_nr}
    Set Test Variable    ${cell_list_lte}
    ${lnbtsID}    run keyword if    '${cell_type}' != 'nr_only'    Get lnbts ID via online SCF
    set test variable    ${lnbtsID}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${SCF_CB009365_C_11495375}
    set test variable    ${mrbtsID}
    set test variable    ${nrbtsID}
    log to console    ++++++++++++++++++++++++++++++++++++ Cell Lcok_Unlcok ++++++++++++++++++++++++++++++++++++
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 lock cells
    log to console    ---------------------------------------------------------------------------------------
    Connect to gnb coam via ssl
    Lock cells and check status via coam
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 2 unlock cells
    log to console    ---------------------------------------------------------------------------------------
    Unlock cells and check status via coam
    csn.reset_cache
    log to console    ++++++++++++++++++++++++++++++++++++ RU lock_unlcok ++++++++++++++++++++++++++++++++++++
    Connect to gnb coam via ssl
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 Lock all RMODs
    log to console    ---------------------------------------------------------------------------------------
    Lock all RMODs SG08
    sleep    20
    Check status after lock all RMODs
    sleep    30
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 2 unLock all RMODs
    log to console    ---------------------------------------------------------------------------------------
    Unlock all RMODs SG08
    sleep    10
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
    log to console    ---------------------------------------------------------------------------------------
    All SMODs BBMODs RMODs and Cells should be onair
    Sleep    30
    csn.reset_cache
    log to console    ++++++++++++++++++++++++++++++++++++ All RAT blcok ++++++++++++++++++++++++++++++++++++
    Connect to gnb coam via ssl
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 Block all rats
    log to console    ---------------------------------------------------------------------------------------
    Block rat SG08
    sleep    10
    Check status after block all rats
    sleep    30
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 2 unBlock all rats
    log to console    ---------------------------------------------------------------------------------------
    UnBlock rat SG08
    sleep    10
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
    log to console    ---------------------------------------------------------------------------------------
    All SMODs BBMODs RMODs and Cells should be onair
    Sleep    30
    csn.reset_cache
    FOR    ${index}    IN RANGE    2
        log to console    +++++++++++++++++++++++++++++++++Radio reset Loop ${index} ++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        Reset all RMOD via coam
        Sleep    30s
        Wait until keyword succeeds    8min    30s    verify all cells should be onair
        Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
        csn.reset_cache
    END
    log to console    ++++++++++++++++++++++++++++++++++++ Lock BB ++++++++++++++++++++++++++++++++++++
    Connect to gnb coam via ssl
    Lock BB and check status via coam
    log to console    ++++++++++++++++++++++++++++++++++++ Unlock BB ++++++++++++++++++++++++++++++++++++
    Unlock BB and check status via coam
    csn.reset_cache
    FOR    ${index}    IN RANGE    3
        log to console    ++++++++++++++++++++++++++++++++++++ BB reset ${index} +++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        BB reset and check status via coam
        csn.reset_cache
    END
#    log to console    ++++++++++++++++++++++++++++++++++++ NR rat reset ++++++++++++++++++++++++++++++++++++
#    Connect to gnb coam via ssl
#    coam.rat_reset       rat_type=NR     timeout=300    connection=GNB_OAM
#    Sleep    180s
#    Wait until keyword succeeds    10min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM

    log to console    ++++++++++++++++++++++++++++++++++++ ALl Rat Reset ++++++++++++++++++++++++++++++++++++
    Connect to gnb coam via ssl
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 Reset all rats
    log to console    ---------------------------------------------------------------------------------------
    Reset rat SG08
    sleep    20
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 2 All SMODs BBMODs RMODs and Cells onair
    log to console    ---------------------------------------------------------------------------------------
    All SMODs BBMODs RMODs and Cells should be onair
    Sleep    10
    csn.reset_cache

    log to console    ++++++++++++++++++++++++++++++++++++ BTS reset ++++++++++++++++++++++++++++++++++++
    AlarmWatchdog.add_allow_alarms    fault_id=6825
    coam.reset_site   connection=GNB_OAM
    Sleep    120s
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Sleep    120s
    [Teardown]    Run keywords    Disable actcbrs and save SAS log    delta_file=${disable_actcbrs_actnrcbrs_split}    AND
    ...    AlarmWatchdog.remove_allow_alarms    fault_id=6825

CB009365-C_5_4T4R 3 NR_4 LTE concurrent mode Frequency Selection Algorithm run more than once in one BTS TS1.2
    AlarmWatchdog.add_allow_alarms    fault_id=6828
    ${SCF_CB009365_C_5}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365_C_5_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009365_C_5}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs_TL25}    connection=GNB_OAM
    sleep    20
    ${stamp_case_start}    Get Timestamp For Current Time
    start SAS server    config_name=${CB009365_C_5_conf}
    sleep    600
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    2min    30s    check cell status by cellid    cellid=11    status=enabled
    Wait until keyword succeeds    2min    30s    check cell status by cellid    cellid=12    status=enabled
    check cell status by cellid    cellid=13    status=disabled
    check cell status by cellid    cellid=14    status=disabled
    Check Alarm in Alarm List    type=Active    faultId=6828
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}
    ${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=1
    Should be True    '${chBw_cell1}'=='20MHz'
    ${chBw_cell2}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=2
    Should be True    '${chBw_cell2}'=='20MHz'
    ${chBw_cell3}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=3
    Should be True    '${chBw_cell3}'=='20MHz'
    ${chBw_ltecell11}    Get LNCEL_TDD_A value via COAM    cellID=11
    Should be True    '${chBw_ltecell11}'=='20 MHz'
    ${chBw_ltecell12}    Get LNCEL_TDD_A value via COAM    cellID=12
    Should be True    '${chBw_ltecell12}'=='20 MHz'
    [Teardown]    Run keywords    Disable actcbrs and save SAS log    delta_file=${disable_actcbrs_actnrcbrs_TL25}    AND
    ...    AlarmWatchdog.remove_allow_alarms    fault_id=6828

CB009365-C_A_16_Online_delete_higher_priority_CBRS_cell_in 2x2T2R split mode
#    Check LTE whether need power off
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_NR_case72}    value=${10}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_NR_case72_value127}    value=${127}
    ${SCF_CB009365_C_A_1516}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365_C_A_1516_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009365_C_A_1516}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${SCF_CB009365_C_A_1516}
    set test variable    ${mrbtsID}
    set test variable    ${nrbtsID}
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB009365_C_1516_conf}
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam    NRCBSDID=2
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2    NRCBSDID=2
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3    NRCBSDID=3
    ${grant_info_cell4}    Get Grant Parameters By Coam    cellID=4    NRCBSDID=3
    ${chBw_cell2}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=2
	${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
    Should be True    '${grant_info_cell1}[grantId]'=='3590000000_3610000000'
    Should be True    '${grant_info_cell1}[grantChannelType]'=='PAL'
    Should be True    '${grant_info_cell3}[grantId]'=='3590000000_3610000000'
    Should be True    '${grant_info_cell3}[grantChannelType]'=='PAL'
    Should be True    '${grant_info_cell2}[grantChannelType]'=='GAA'
    Should be True    '${chBw_cell2}'=='20MHz'
    Should be True    '${grant_info_cell4}[grantChannelType]'=='GAA'
    Should be True    '${chBw_cell4}'=='20MHz'
    FOR    ${index}    IN RANGE    3
        log to console    ++++++++++++++++++++++++++++++++++ Cell del & add ${index} +++++++++++++++++++++++++++++++++
        Online Cell deletion
        ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3    NRCBSDID=3
        ${grant_info_cell4}    Get Grant Parameters By Coam    cellID=4    NRCBSDID=3
	    ${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
        Should be True    '${grant_info_cell3}[grantId]'=='3590000000_3610000000'
        Should be True    '${grant_info_cell3}[grantChannelType]'=='PAL'
        Should be True    '${grant_info_cell4}[grantChannelType]'=='GAA'
        Should be True    '${chBw_cell4}'=='20MHz'
        Sleep    300s
        ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2    NRCBSDID=2
        ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3    NRCBSDID=3
        ${grant_info_cell4}    Get Grant Parameters By Coam    cellID=4    NRCBSDID=3
	    ${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
        Should be True    '${grant_info_cell2}[grantId]'=='3590000000_3610000000'
        Should be True    '${grant_info_cell2}[grantChannelType]'=='PAL'
        Should be True    '${grant_info_cell3}[grantId]'=='3590000000_3610000000'
        Should be True    '${grant_info_cell3}[grantChannelType]'=='PAL'
        Should be True    '${grant_info_cell4}[grantChannelType]'=='GAA'
        Should be True    '${chBw_cell4}'=='20MHz'
        verify all cells should be onair
        csn.reset_cache
        sleep    10s
        Online Cell addition    file_path=${SCF_CB009365_C_A_1516}    addition_cell=1    addition_cellgrp=0
        ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3    NRCBSDID=3
        ${grant_info_cell4}    Get Grant Parameters By Coam    cellID=4    NRCBSDID=3
	    ${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
        Should be True    '${grant_info_cell3}[grantId]'=='3590000000_3610000000'
        Should be True    '${grant_info_cell3}[grantChannelType]'=='PAL'
        Should be True    '${grant_info_cell4}[grantChannelType]'=='GAA'
        Should be True    '${chBw_cell4}'=='20MHz'
        Sleep    300s
        ${grant_info_cell1}    Get Grant Parameters By Coam    NRCBSDID=2
        ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2    NRCBSDID=3
        ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3    NRCBSDID=3
        ${grant_info_cell4}    Get Grant Parameters By Coam    cellID=4    NRCBSDID=3
        ${chBw_cell2}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=2
	    ${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
        Should be True    '${grant_info_cell1}[grantId]'=='3590000000_3610000000'
        Should be True    '${grant_info_cell1}[grantChannelType]'=='PAL'
        Should be True    '${grant_info_cell3}[grantId]'=='3590000000_3610000000'
        Should be True    '${grant_info_cell3}[grantChannelType]'=='PAL'
        Should be True    '${grant_info_cell2}[grantChannelType]'=='GAA'
        Should be True    '${chBw_cell2}'=='20MHz'
        Should be True    '${grant_info_cell4}[grantChannelType]'=='GAA'
        Should be True    '${chBw_cell4}'=='20MHz'
        Wait until keyword succeeds    8min    30s    verify all cells should be onair
    END
    Set qRxLevMin value    value=${-40}    cellid=1
    Set qRxLevMin value    value=${-22}    cellid=2
    ${gNb_CuType}   Get gNB CU type
    set test variable    ${gNb_CuType}
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id_16}   loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85    process_num_ul=5
    csn.reset_cache
    [Teardown]    Disable actnrcbrs and save SAS log

Check Case CB009365-C B 18 CBRS Registration Process
    [Arguments]    ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB009365-C_B_18_2x2T2R split mode LTE CBSD Registration with SAS VERSION TS2.0 is successful
    ${SCF_CB009365_C_B_18}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365_C_B_18_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009365_C_B_18}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_TL25_2cbsd}    connection=GNB_OAM
    sleep    20
    start SAS server    path=${sas_2_0}
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    ${register_lte}    Get Parameter value via COAM    class_name=CBSD_R   pattern=cbsdRegistrationState    connection=GNB_OAM
    Should be True    '${register_lte}' == 'Registered'
    Check TS Version By Coam    expect_version=2.0    class_name=CBRSPR_R
    ${ru_info_1}    COAM get all ru detail info
    &{ru_info}    Set variable    ${ru_info_1['1']}
    ${ru_sn}    Set variable    ${ru_info}[serialNumber]
    ${cbsdid_sector1}    Get CBSD value via COAM    cbsdID=1    class_name=CBSD_R    pattern=assignedCbsdId
    ${fccid_sector1}    Get CBSD value via COAM    cbsdID=1    class_name=CBSD_A    pattern=fccId
    ${userid_sector1}    Get CBSD value via COAM    cbsdID=1    class_name=CBSD_A    pattern=userId
    Should Match Regexp    ${cbsdid_sector1}    ${userid_sector1}_${fccid_sector1}_${ru_sn}sector1
    ${cbsdid_sector2}    Get CBSD value via COAM    cbsdID=2    class_name=CBSD_R    pattern=assignedCbsdId
    ${fccid_sector2}    Get CBSD value via COAM    cbsdID=2    class_name=CBSD_A    pattern=fccId
    ${userid_sector2}    Get CBSD value via COAM    cbsdID=2    class_name=CBSD_A    pattern=userId
    Should Match Regexp    ${cbsdid_sector2}    ${userid_sector2}_${fccid_sector2}_${ru_sn}sector2
    Check Case CB009365-C B 18 CBRS Registration Process    cbsdid=${cbsdid_sector1}
    Check Case CB009365-C B 18 CBRS Registration Process    cbsdid=${cbsdid_sector2}
    [Teardown]    Disable actcbrs and save SAS log    delta_file=${disable_actcbrs_TL25_2cbsd}

CB009365-A_1_4T4R NR 4CC Frequency Selection Algorithm with more than 110Mhz available channels
    ${SCF_CB009365-A_2_1_SBTS00}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365-A_2_1_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009365-A_2_1_SBTS00}
    Run Keyword And Ignore Error    Set primarySasServer value    value=${SASServerip}:4433
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB009365_A_1_2_conf}
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3
    ${grant_info_cell4}    Get Grant Parameters By Coam    cellID=4
    ${chBw_cell3}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=3
	${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
    Should be True    '${grant_info_cell1}[grantId]'=='3550000000_3590000000'
    Should be True    '${grant_info_cell1}[grantChannelType]'=='PAL'
    Should be True    '${grant_info_cell2}[grantId]'=='3600000000_3620000000'
    Should be True    '${grant_info_cell2}[grantChannelType]'=='PAL'
    Should be True    '${grant_info_cell3}[grantChannelType]'=='GAA'
    Should be True    '${chBw_cell3}'=='20MHz'
    Should be True    '${grant_info_cell4}[grantChannelType]'=='GAA'
    Should be True    '${chBw_cell4}'=='10MHz'
    Sleep    30s
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3550_3650}
    Sleep    300s
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    ${grant_info_cell1}    Get Grant Parameters By Coam
    ${grant_info_cell2}    Get Grant Parameters By Coam    cellID=2
    ${grant_info_cell3}    Get Grant Parameters By Coam    cellID=3
    ${grant_info_cell4}    Get Grant Parameters By Coam    cellID=4
    ${chBw_cell2}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=2
	${chBw_cell4}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=4
    Should be True    '${grant_info_cell1}[grantId]'=='3550000000_3590000000'
    Should be True    '${grant_info_cell1}[grantChannelType]'=='PAL'
    Should be True    '${grant_info_cell2}[grantChannelType]'=='GAA'
    Should be True    '${chBw_cell2}'=='30MHz'
    Should be True    '${grant_info_cell3}[grantChannelType]'=='PAL'
    Should be True    '${grant_info_cell3}[grantId]'=='3600000000_3620000000'
    Should be True    '${grant_info_cell4}[grantChannelType]'=='GAA'
    Should be True    '${chBw_cell4}'=='10MHz'

Check Case CB009365-A 4 CBRS Process
    [Arguments]    ${grantId}    ${grantId_new}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": "${grantId}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"grantId\":\"${grantId}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": "${grantId}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"grantId\":\"${grantId}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": "${grantId}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"grantId\":\"${grantId}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": "${grantId}".*\"responseCode\": 500.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": "${grantId_new}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

CB009365-A_4_4T4R gNB CBSD receives HB Response 500 with no operationParam
    ${SCF_CB009365_A_4_SBTS00}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365-A_4_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009365_A_4_SBTS00}
    start SAS server    config_name=${CB009365_A_4_conf}
    Activate feature CBRS By Coam
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Sleep    300s
    Check Case CB009365-A 4 CBRS Process    grantId=3560000000_3600000000    grantId_new=3550000000_3570000000

CB009365-A online change cCaPairCellId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
    ...    filter_param=NRCELL id of the other CBSD cell in the carrier pair requiring contiguous carrier aggregation
    ...    abbr=cCaPairCellId     new_value=3
    selenium_coam.delete_parameter  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2/NRCBSDCELL-0
    ...    filter_param=NRCELL id of the other CBSD cell in the carrier pair requiring contiguous carrier aggregation
    ...    abbr=cCaPairCellId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3/NRCBSDCELL-0
    ...    filter_param=NRCELL id of the other CBSD cell in the carrier pair requiring contiguous carrier aggregation
    ...    abbr=cCaPairCellId     new_value=1
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${600}

CB009365-A_CA_2_online_modify_cCaPairCellId_Intra-gNB_FDD-TDD_CA_4CC
    ${SCF_CB009365_A_CA_SBTS00}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365-A_CA_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009365_A_CA_SBTS00}
    start SAS server
    Activate feature CBRS By Coam
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    ${freq_cell1}    Get cell carrier freq
    ${freq_cell2}    Get cell carrier freq    cell_idx=${2}
    Set channelSpace2020 By webem    channelSpace2020=39300    flitervalue_channelSpace2020=Channel spacing between two cells
    Selenium Logout And Close Browser
    Sleep    180s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    ${freq_cell1_after}    Get cell carrier freq
    ${freq_cell2_after}    Get cell carrier freq    cell_idx=${2}
    Run Keyword If    ${freq_cell1} > ${freq_cell2}    Should be True    ${freq_cell1} > ${freq_cell1_after}
    ...    ELSE    Should be True    ${freq_cell2} > ${freq_cell2_after}
    ${distance}    Get the diff    num1=${freq_cell1_after}    num2=${freq_cell2_after}
    ${diff}    Get the diff    num1=${distance}    num2=${39.3}
    Should be True    ${diff}<0.0001
    Set channelSpace2020 By webem    channelSpace2020=39600    flitervalue_channelSpace2020=Channel spacing between two cells
    Selenium Logout And Close Browser
    Sleep    180s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    ${freq_cell1_after_39600}    Get cell carrier freq
    ${freq_cell2_after_39600}    Get cell carrier freq    cell_idx=${2}
    Run Keyword If    ${freq_cell1} > ${freq_cell2}    Should be True    ${freq_cell1_after_39600} > ${freq_cell1_after}
    ...    ELSE    ${freq_cell2_after_39600} > ${freq_cell2_after}
    ${distance}    Get the diff    num1=${freq_cell1_after_39600}    num2=${freq_cell2_after_39600}
    ${diff}    Get the diff    num1=${distance}    num2=${39.6}
    Should be True    ${diff}<0.0001
    CB009365-A online change cCaPairCellId
    Selenium Logout And Close Browser
    Sleep    300s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Selenium Login And Disable Screen Lock
    ${freq_cell1_after_change_CaPair}    Get cell carrier freq
    ${freq_cell3_after_change_CaPair}    Get cell carrier freq    cell_idx=${3}
    ${distance}    Get the diff    num1=${freq_cell1_after_change_CaPair}    num2=${freq_cell3_after_change_CaPair}
    ${diff}    Get the diff    num1=${distance}    num2=${39.6}
    Should be True    ${diff}<0.0001
    [Teardown]    Selenium Logout And Close Browser

Set LTE channelSpace2020 By webem
    [Arguments]    ${channelSpace2020}    ${CBSDID}=1
    Online Delta Commission  dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBRSPR-${CBSDID}
    ...    filter_param=CBSD Channel Space between contiguous 20MHz Spectrums
    ...    target_value=${channelSpace2020}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

CB009365-B online change cCaPairCellId
    selenium_coam.delete_parameter  dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/LNCEL-11/CBSDCEL-0
    ...    filter_param=LNCEL id of the other CBSD cell in the carrier pair requiring contiguous carrier aggregation
    ...    abbr=cCaPairCellId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/LNCEL-12/CBSDCEL-0
    ...    filter_param=LNCEL id of the other CBSD cell in the carrier pair requiring contiguous carrier aggregation
    ...    abbr=cCaPairCellId     new_value=14
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/LNCEL-14/CBSDCEL-0
    ...    filter_param=LNCEL id of the other CBSD cell in the carrier pair requiring contiguous carrier aggregation
    ...    abbr=cCaPairCellId     new_value=12
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${600}

Check CB009365-B_CA Messgae
    [Arguments]     ${grantId}
    prepare_to_check_message_from_start
    Check if total times of the message in log is matched
    ...    sasMessage='\"relinquishmentRequest\":.*\"grantId\":\"${grantId}\"'
    ...    totalTimes=${1}
    [Teardown]    end_to_check

CB009365-B_CA_3_online_modify_cCaPairCellId_Intra-eNB_FDD-TDD_CA_4CC_channel_change
    ${SCF_CB009365_B_CA_SBTS00}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365-B_CA_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009365_B_CA_SBTS00}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs}    connection=GNB_OAM
    sleep    20
    start SAS server
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Selenium Login And Disable Screen Lock
    ${freq_cell11}    Get cell carrier freq    cell_idx=${11}    technology=LTE
    ${freq_cell12}    Get cell carrier freq    cell_idx=${12}    technology=LTE
    Set LTE channelSpace2020 By webem    channelSpace2020=19.2
    Selenium Logout And Close Browser
    sleep    180
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Selenium Login And Disable Screen Lock
    ${freq_cell11_19_2}    Get cell carrier freq    cell_idx=${11}    technology=LTE
    ${freq_cell12_19_2}    Get cell carrier freq    cell_idx=${12}    technology=LTE
    Run Keyword If    ${freq_cell11} > ${freq_cell12}    Should be True    ${freq_cell11} > ${freq_cell11_19_2}
    ...    ELSE    Should be True    ${freq_cell12} > ${freq_cell12_19_2}
    ${distance}    Get the diff    num1=${freq_cell11_19_2}    num2=${freq_cell12_19_2}
    ${diff}    Get the diff    num1=${distance}    num2=${19.2}
    Should be True    ${diff}<0.0001
    Set LTE channelSpace2020 By webem    channelSpace2020=19.5
    Selenium Logout And Close Browser
    sleep    180
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Selenium Login And Disable Screen Lock
    ${freq_cell11_19_5}    Get cell carrier freq    cell_idx=${11}    technology=LTE
    ${freq_cell12_19_5}    Get cell carrier freq    cell_idx=${12}    technology=LTE
    Run Keyword If    ${freq_cell11} > ${freq_cell12}    Should be True    ${freq_cell11_19_5} > ${freq_cell11_19_2}
    ...    ELSE    Should be True    ${freq_cell12_19_5} > ${freq_cell12_19_2}
    ${distance}    Get the diff    num1=${freq_cell11_19_5}    num2=${freq_cell12_19_5}
    ${diff}    Get the diff    num1=${distance}    num2=${19.5}
    Should be True    ${diff}<0.0001
    CB009365-B online change cCaPairCellId
    Selenium Logout And Close Browser
    Sleep    300s
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    Selenium Login And Disable Screen Lock
    ${freq_cell11_CA_pair}    Get cell carrier freq    cell_idx=${12}    technology=LTE
    ${freq_cell12_CA_pair}    Get cell carrier freq    cell_idx=${14}    technology=LTE
    ${distance}    Get the diff    num1=${freq_cell11_CA_pair}    num2=${freq_cell12_CA_pair}
    ${diff}    Get the diff    num1=${distance}    num2=${19.5}
    Should be True    ${diff}<0.0001
    ${grantid11}    Get CBSDCEL_R value via COAM    cellID=11    pattern=grantId
    Check CB009365-B_CA Messgae    grantId=${grantid11}
    ${grantid12}    Get CBSDCEL_R value via COAM    cellID=12    pattern=grantId
    Check CB009365-B_CA Messgae    grantId=${grantid12}
    ${grantid13}    Get CBSDCEL_R value via COAM    cellID=13    pattern=grantId
    Check CB009365-B_CA Messgae    grantId=${grantid13}
    ${grantid14}    Get CBSDCEL_R value via COAM    cellID=14    pattern=grantId
    Check CB009365-B_CA Messgae    grantId=${grantid14}
    [Teardown]    Selenium Logout And Close Browser

CB009365_LTE_call
    [Arguments]    ${ue_index}=${0}    ${throughput_dl}=350    ${throughput_ul}=50    ${target_throughput_dl}=280
    ...    ${target_throughput_ul}=11.8
    ${ue_type_4G}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800
    ...    ue_index=${ue_index}
    sleep    300s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${ue_index}    duration=5m    min_percent=0.1    ignore_time=60
    [Teardown]    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index}

CB009365-B_2_data transfer conducted peak throughput on LTE only 4T4R radio 20+20+20+20MHz
    ${SCF_9365_20M_20M_20M_20M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365_20M_20M_20M_20M_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_9365_20M_20M_20M_20M}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs}    connection=GNB_OAM
    sleep    20
    start SAS server
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${attach_cell11}    connection=GNB_OAM
    sleep    20
    CB009365_LTE_call
    coam.perform_delta_recommissioning    delta_file=${attach_cell12}    connection=GNB_OAM
    sleep    90
    CB009365_LTE_call
    coam.perform_delta_recommissioning    delta_file=${attach_cell13}    connection=GNB_OAM
    sleep    90
    CB009365_LTE_call
    coam.perform_delta_recommissioning    delta_file=${attach_cell14}    connection=GNB_OAM
    sleep    90
    CB009365_LTE_call

CB009365-A_7_data transfer conducted peak throughput on NR only 4T4R radio 40+40+40+30MHz
    ${SCF_9365_30M_40M_40M_40M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365_30M_40M_40M_40M_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_9365_30M_40M_40M_40M}
    Activate feature CBRS By Coam
    Start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    coam.perform_delta_recommissioning    delta_file=${attach_cell2}    connection=GNB_OAM
    sleep  10
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id_40M}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85    process_num_ul=5
    sleep  120
    CB009365 2cc call    cell_id1=${3}    cell_id2=${4}    attach_1=${attach_cell3}    attach_2=${attach_cell4}

CB009365 2cc call
    [Arguments]    ${attach_1}    ${attach_2}    ${duration}=${300}    ${tput_from}=tool    ${target_avg}=0.98    ${min_percent}=0.85
     ...    ${cell_id1}=${1}    ${cell_id2}=${2}
    ${tput_define}    get_self_define_tput_by_release    tput_info=${tput_define}
    coam.perform_delta_recommissioning    delta_file=${attach_1}    connection=GNB_OAM
    sleep    20
    ${tput_info_total}    create dictionary
    ${tput_cell1}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool    cell_id=${cell_id1}    target_avg_percent=${target_avg}
    ...    min_percent=${min_percent}    duration=${duration}    connection=GNB_OAM    ELSE    set variable    ${tput_define[${cell_id1}]}
    set to dictionary    ${tput_info_total}    ${cell_id1}    ${tput_cell1}
    log to console    tput info for cell ${cell_id1} is: ${tput_cell1}
    ${ue_index1}    set variable    ${tput_define[${cell_id1}]['ue_index']}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${ue_index1}
    make_call    tput_info=${tput_cell1}    ue_index=${ue_index1}    process_num_ul=5
    sleep  10
    coam.perform_delta_recommissioning    delta_file=${attach_2}    connection=GNB_OAM
    sleep  10
    ${tput_cell2}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool    cell_id=${cell_id2}    target_avg_percent=${target_avg}
    ...    min_percent=${min_percent}    ue_index=${1}    duration=${duration}    connection=GNB_OAM    ELSE    set variable
    ...    ${tput_define[${cell_id2}]}
    set to dictionary    ${tput_info_total}    ${cell_id2}    ${tput_cell2}
    log to console    tput info for cell ${cell_id2} is: ${tput_cell2}
    ${ue_index2}    set variable    ${tput_define[${cell_id2}]['ue_index']}
    ${ue_type2}    translate_power_ue_type_from_testline    ue_index=${ue_index2}
    make_call    tput_info=${tput_cell2}    ue_index=${ue_index2}    process_num_ul=5
    ${tput_log1}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    ${tput_log2}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_id1}    ue_index=${ue_index1}    tput_log=${tput_log1}
    ...    target_avg_percent=${target_avg}    min_percent=${min_percent}
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_id2}    ue_index=${ue_index2}    tput_log=${tput_log2}
    ...    target_avg_percent=${target_avg}    min_percent=${min_percent}
    [Teardown]    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

CBRS NR And LTE CPE Call
    [Arguments]    ${tput_expect}    ${cell_id1}=${1}    ${duration}=${180}    ${tput_from}=tool    ${target_avg}=0.95    ${min_percent}=0.85
    ...    ${ue_index_LTE}=${1}    ${throughput_dl_LTE}=350    ${throughput_ul_LTE}=50    ${target_throughput_dl_LTE}=280
    ...    ${target_throughput_ul_LTE}=11
    ${tput_expect}    get_self_define_tput_by_release    tput_info=${tput_expect}
    ${tput_info_total}    create dictionary
    ${tput_cell1}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool    cell_id=${cell_id1}    target_avg_percent=${target_avg}
    ...    min_percent=${min_percent}    duration=${duration}    connection=GNB_OAM    ELSE    set variable    ${tput_expect[${cell_id1}]}
    set to dictionary    ${tput_info_total}    ${cell_id1}    ${tput_cell1}
    log to console    tput info for cell ${cell_id1} is: ${tput_cell1}
    ${ue_index1}    set variable    ${tput_expect[${cell_id1}]['ue_index']}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${ue_index1}
    make_call    tput_info=${tput_cell1}    ue_index=${ue_index1}    process_num_ul=5
    ${ue_type_4G}    translate_power_ue_type_from_testline    ue_index=${ue_index_LTE}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${ue_index_LTE}
    ${tput_log1}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_id1}    ue_index=${ue_index1}    tput_log=${tput_log1}
    ...    target_avg_percent=${target_avg}    min_percent=${min_percent}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_LTE}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${ue_index_LTE}    duration=3m    target_avg_percent=${target_avg}
    ...    min_percent=0.1    ignore_time=60
    [Teardown]    Run Keywords    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}    AND
    ...    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_LTE}

CB009365-C_72_data_transfer_conducted_peak_throughput_NR_40M+30M+20M_LTE_20M+20M+10M+10M_under_inter_BTS_split_mode
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_NR_case72}    value=${13}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_NR_case72_value127}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_LTE_case72}     attenuator_index=${1}    value=${0}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_LTE_case72_value127}     attenuator_index=${1}    value=${127}
    ${SCF_CB009365_C_103372NR}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365_C_103372NR_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009365_C_103372NR}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${SCF_CB009365_C_103372NR}
    set test variable    ${mrbtsID}
    set test variable    ${nrbtsID}
    ${gNb_CuType}   Get gNB CU type
    set test variable    ${gNb_CuType}
    check and power on or off enb    powerStatus=on
    sleep    360
    Connect to eNB via ssl
    ${SCF_CB009365_C_103372LTE}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365_C_103372LTE_
    COAM Commission with scf file    scf_file_path=${SCF_CB009365_C_103372LTE}    connection=enblte    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${SCF_CB009365_C_103372LTE}
    log to console  ENB_MRBTS_ID:${mrbtsID_enb}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID_enb}
    set suite variable  ${lnbtsID}
    Modify the parameter on enblte    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBSD-3
    ...    parameter_name=supportedSpectrumV2    value=${frequency_3550_3610}
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3550_3640}    NRCBSDID=2
    sleep    20
    Activate feature CBRS By Coam
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_2165}    connection=enblte
    start SAS server
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    8min    30s    Verify all lte cells should be onair    connection=enblte
    ${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=1
    Should be True    '${chBw_cell1}'=='30MHz'
    ${chBw_cell2}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=2
    Should be True    '${chBw_cell2}'=='40MHz'
    ${chBw_cell3}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=3
    Should be True    '${chBw_cell3}'=='20MHz'
    ${chBw_ltecell11}    Get LNCEL_TDD_A value via COAM    cellID=11    connection=enblte
    Should be True    '${chBw_ltecell11}'=='20 MHz'
    ${chBw_ltecell12}    Get LNCEL_TDD_A value via COAM    cellID=12    connection=enblte
    Should be True    '${chBw_ltecell12}'=='20 MHz'
    ${chBw_ltecell13}    Get LNCEL_TDD_A value via COAM    cellID=13    connection=enblte
    Should be True    '${chBw_ltecell13}'=='10 MHz'
    ${chBw_ltecell14}    Get LNCEL_TDD_A value via COAM    cellID=14    connection=enblte
    Should be True    '${chBw_ltecell14}'=='10 MHz'
    Perform RU Reset
    Wait Until Keyword Succeeds    5min    30s    RU Should Be Offline
    Sleep    60s
    Wait until keyword succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    Set qRxLevMin value    value=${-40}    cellid=2
    Set qRxLevMin value    value=${-22}    cellid=3
    coam.perform_delta_recommissioning    delta_file=${attach_LTEcell11_TL2156}    connection=enblte
    sleep    20
    CBRS NR And LTE CPE Call    tput_expect=${tput_define_30_40_20}    cell_id1=${2}    throughput_dl_LTE=200
    ...    target_throughput_dl_LTE=137
    Set qRxLevMin value    value=${-22}    cellid=2
    Set qRxLevMin value    value=${-40}    cellid=3
    coam.perform_delta_recommissioning    delta_file=${attach_LTEcell12_TL2156}    connection=enblte
    sleep    20
    CBRS NR And LTE CPE Call    tput_expect=${tput_define_30_40_20}    cell_id1=${3}    throughput_dl_LTE=200
    ...    target_throughput_dl_LTE=137
    coam.perform_delta_recommissioning    delta_file=${attach_LTEcell13_TL2156}    connection=enblte
    sleep    20
	CB009365_LTE_call    ue_index=${1}    throughput_dl=100    target_throughput_dl=70    target_throughput_ul=4.0
    sleep    20
    coam.perform_delta_recommissioning    delta_file=${attach_LTEcell14_TL2156}    connection=enblte
    sleep    20
	CB009365_LTE_call    ue_index=${1}    throughput_dl=100    target_throughput_dl=70    target_throughput_ul=4.0
    [Teardown]    Disable actnrcbrs and actcbrs and save SAS log    delta_file=${disable_actcbrs_2165}

CB009365-C_68_data_transfer_conducted_peak_throughput_NR_40M+20M+10M_LTE_10M+10M+20M+20M_under_concurrent_mode
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_NR}    value=${20}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_LTE}     attenuator_index=${1}    value=${0}
    ${SCF_CB009365_C_68}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009365_C_68_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009365_C_68}
    ${gNb_CuType}   Get gNB CU type
    set test variable    ${gNb_CuType}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs_TL25}    connection=GNB_OAM
    sleep    20
    start SAS server
    sleep    480
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${attach_NRcell1_LTEcell11}    connection=GNB_OAM
    sleep    20
    CBRS NR And LTE CPE Call    tput_expect=${tput_define_40_20_10}    tput_from=self_define
    sleep    20
    coam.perform_delta_recommissioning    delta_file=${attach_NRcell2_LTEcell12}    connection=GNB_OAM
    sleep    20
    CBRS NR And LTE CPE Call    tput_expect=${tput_define_40_20_10}    cell_id1=${2}
    sleep    20
    coam.perform_delta_recommissioning    delta_file=${attach_NRcell3_LTEcell13}    connection=GNB_OAM
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_NR}    value=${10}
    sleep    20
    CBRS NR And LTE CPE Call    tput_expect=${tput_define_40_20_10}    cell_id1=${3}
    ...    target_throughput_dl_LTE=137    target_throughput_ul_LTE=4.8
    sleep    20
    coam.perform_delta_recommissioning    delta_file=${attach_LTEcell14_TL25}    connection=GNB_OAM
    sleep    20
    CB009365_LTE_call    ue_index=${1}    target_throughput_dl=137    target_throughput_ul=4.8
    [Teardown]    Disable actcbrs and save SAS log    delta_file=${disable_actcbrs_actnrcbrs_TL25}

CB009509-B_1_SBTS_RFS_2T2R_Data_Transfer_Conducted_NR60+20+20+LTE10+10+10+10MHz
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_NR_case72}    value=${10}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_NR_case72_value127}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_LTE_case72}     attenuator_index=${1}    value=${0}
    Set PA Value For Pointed Port    PA_Port_List=${PA_OUT_PORTS_LTE_case72_value127}     attenuator_index=${1}    value=${127}
    ${SCF_CB009509_B}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009509_B_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009509_B}
    ${gNb_CuType}   Get gNB CU type
    set test variable    ${gNb_CuType}
    check and power on or off enb    powerStatus=off
    sleep    120
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs_9509}    connection=GNB_OAM
    sleep    20
    start SAS server
    sleep    240
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${attach_NRcell1_LTEcell11}    connection=GNB_OAM
    sleep    20
    CBRS NR And LTE CPE Call    tput_expect=${tput_define_60_20_20}    target_throughput_dl_LTE=70
    ...    target_throughput_ul_LTE=4.0
    sleep    20
    coam.perform_delta_recommissioning    delta_file=${attach_NRcell2_LTEcell12}    connection=GNB_OAM
    sleep    20
    CBRS NR And LTE CPE Call    tput_expect=${tput_define_60_20_20}    cell_id1=${2}    target_throughput_dl_LTE=70
    ...    target_throughput_ul_LTE=4.0
    sleep    20
    coam.perform_delta_recommissioning    delta_file=${attach_NRcell3_LTEcell13}    connection=GNB_OAM
    sleep    20
    CBRS NR And LTE CPE Call    tput_expect=${tput_define_60_20_20}    cell_id1=${3}    target_throughput_dl_LTE=70
    ...    target_throughput_ul_LTE=4.0
    sleep    20
    coam.perform_delta_recommissioning    delta_file=${attach_LTEcell14_TL25}    connection=GNB_OAM
    sleep    20
    CB009365_LTE_call    ue_index=${1}    target_throughput_dl=70    target_throughput_ul=4.0
    [Teardown]    Disable actcbrs and save SAS log    delta_file=${disable_actcbrs_actnrcbrs_9509}

CB009509 check chbw
    [Arguments]   ${chbw}    ${cellID}=1
    ${chBw_cell1}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw    cellID=${cellID}
    Should be True    '${chBw_cell1}'=='${chbw}'

CB009509-BA_6_Verify_Chbw_dynamic_update_40MHz_60MHz_80MHz
    ${SCF_CB009509_80M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009509_80M_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009509_80M}
    Activate feature CBRS By Coam
    start SAS server    config_name=${CB009509_60_40_80_conf}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    sleep    10
    Wait Until Keyword Succeeds    6min    10s    CB009509 check chbw    chbw=40MHz
    Wait Until Keyword Succeeds    6min    10s    CB009509 check chbw    chbw=60MHz
    Wait Until Keyword Succeeds    6min    10s    CB009509 check chbw    chbw=80MHz
    sleep    120
    Wait until keyword succeeds    2min    30s    verify all cells should be onair
	data_transfer_common    tput_self_define=${tput_define_9509_case6}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.85    min_percent=0.8    process_num_ul=5

CB009509-B_11_NR_Only 4T4R_Data_Transfer_Conducted_Peak_TPUT_80+40+20+10MHz
    ${SCF_CB009509_80M_40M_20M_10M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009509_80M_40M_20M_10M_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009509_80M_40M_20M_10M}
    Activate feature CBRS By Coam
    Start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    CBRS make 2cc call    tput_expect=${tput_define_9509_11}    cell_id1=${1}    cell_id2=${2}    attach_1=${attach_cell1}
    ...    attach_2=${attach_cell2}    target_avg=0.85    min_percent=0.8
    sleep  120
    CBRS make 2cc call    tput_expect=${tput_define_9509_11}    cell_id1=${3}    cell_id2=${4}    attach_1=${attach_cell3}
    ...    attach_2=${attach_cell4}    tput_from=self_define    target_avg=0.85    min_percent=0.8

CB009509-BA_1_NR_Only 4T4R_Data_Transfer_Conducted_Peak_TPUT_50+50+50MHz
    ${SCF_CB009509_50M_50M_50M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB009509_50M_50M_50M_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB009509_50M_50M_50M}
    Activate feature CBRS By Coam
    Start SAS server
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    CBRS make 2cc call    tput_expect=${tput_define}    cell_id1=${1}    cell_id2=${2}    attach_1=${9509_3cc_attach_cell1}
    ...    attach_2=${9509_3cc_attach_cell2}    target_avg=0.98    min_percent=0.85
    sleep  120
    CBRS make 2cc call    tput_expect=${tput_define}    cell_id1=${3}    cell_id2=${2}    attach_1=${9509_3cc_attach_cell3}
    ...    attach_2=${9509_3cc_attach_cell2}    target_avg=0.98    min_percent=0.85

*** Settings ***
Documentation
...    author: linjiangjing
...    contact: jiangjing.lin@nokia-sbell.com
...    squad group: SG_08
...    feature : CB013664

Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    ../../resources/cbrs_common_keywords.robot
Library     testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py

*** Variables ***
${CB013664_json_path}    ${CURDIR}/json
${disable_actcbrs_actnrcbrs_953}    ${CB013664_json_path}/disable_actcbrs_actnrcbrs_953.json
${disable_actcbrs_actnrcbrs_1001}    ${CB013664_json_path}/disable_actcbrs_actnrcbrs_1001.json
${enable_actcbrs_actnrcbrs_953}    ${CB013664_json_path}/enable_actcbrs_actnrcbrs_953.json
${enable_actcbrs_actnrcbrs_1001}    ${CB013664_json_path}/enable_actcbrs_actnrcbrs_1001.json
${CB013664_conf_path}    ${CURDIR}/conf
${CB013664_conf}    ${CB013664_conf_path}/CB013664.conf
@{cells_953_NR}    ${51}    ${52}    ${61}
@{cells_953_LTE}    ${55}    ${65}
@{cells_1001}    ${151}    ${152}    ${161}    ${155}    ${165}


*** Keywords ***
CB013664 CBRS Suite Setup
    Download Sas Server
    log to console    \n***CB013664 CBRS Suite Setup***
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
    check and power on or off enb    powerStatus=on
    Sleep    100s
    COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}    connection=GNB_OAM    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    Connect to eNB via ssl
    ${SCF_13664_1001}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_1001_
    COAM Commission with scf file    scf_file_path=${SCF_13664_1001}    connection=enblte    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    Sleep    60s
    Wait Until Keyword Succeeds  10min  5s  Check RU Onair
    Wait Until Keyword Succeeds  10min  5s  Check RU Onair    connection=enblte
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${SCF_13664_1001}
    log to console  ENB_MRBTS_ID:${mrbtsID_enb}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID_enb}
    set suite variable  ${lnbtsID}
    ${lncell_info}    Run    cat ${Golden_SCF_Path} | grep -oE "MRBTS-[0-9]+/LNBTS-[0-9]+" | head -n 1
    ${lnbtsID_953}    Run    echo ${lncell_info}|grep -oE "LNBTS-[0-9]+"| awk -F '-' '{print $2}'
    set suite variable  ${lnbtsID_953}
    &{fault_7312}     Create Dictionary     faultId=${7312}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    &{fault_6826}     Create Dictionary     faultId=${6826}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7312}    ${fault_7313}    ${fault_6826}
    set suite variable  ${ALLOWED_FAULT}
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    add allowed cbrs history fault to the allowed history fault list
    delete_icmp_policy
    Run Keyword And Ignore Error    kill SAS server started by manual

CB013664 CBRS Test Setup
    log to console    \n***CB013664 CBRS Test Setup***
    robot_common_operations.CommonCaseSetup    allowed_faults_ids=6832,4739,1815,16,4038,10,4003,4589
    AlarmWatchdog.add_allow_alarms    fault_id=6832
    AlarmWatchdog.add_allow_alarms    fault_id=4739
    AlarmWatchdog.add_allow_alarms    fault_id=6831
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=16
    AlarmWatchdog.add_allow_alarms    fault_id=4038
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4003
    AlarmWatchdog.add_allow_alarms    fault_id=4589
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
    ${scf_path_13664}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    set test variable    ${scf_path_13664}
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser

CB013664 CBRS Test Teardown
    log to console    \n***CB0013664 CBRS Test Teardown***
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
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
#    ${alarm_status_1001}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
#    ...    connection=enblte
#    should be true    ${alarm_status_1001}
#    ${history_alarm_status_1001}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=enblte
#    should be true    ${history_alarm_status_1001}
    run keyword if test failed     Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    COAM Teardown gnb connections
    Enblte close down
    CI_interface.Common Case Teardown

CB013664 CBRS Suite Teardown
    log to console    \n***CBRS Suite Teardown***
    robot_common_operations.CommonSuiteTeardown
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    run keyword if    ${test_teardown_fail}    run keywords
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    ...    ELSE
    ...    log to console    don't collect snapshot in suite teardown!!!
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

CB013664 Modify the parameter
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=${connection}

Check CB013664 no registrationRequest
    prepare_to_check_message_from_start
    Check if message is not found in saslog    tag={\"registrationRequest\":.*
    [Teardown]    end_to_check

Check CB013664 SAS log by cbsdid
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

CB013664 recovery ENV
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_actnrcbrs_1001}    connection=enblte
    Sleep    30s
    CB013664 Modify the parameter    dist_name=MRBTS-${mrbtsID_enb}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=standby    connection=enblte
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs_actnrcbrs_953}    connection=GNB_OAM
    Sleep    30s
    CB013664 Modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=standby    connection=GNB_OAM
    Sleep    120s

CB013664_E_04_N_type_redundancy_configuration_fiber_broken_SWO
    log to console    *********scf recommission for 953*********
    ${SCF_13664_E_953}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_13664_E_953_
    COAM Commission with scf file    scf_file_path=${SCF_13664_E_953}    connection=GNB_OAM    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    log to console    *********scf recommission for 1001*********
    ${SCF_13664_E_1001}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_13664_1001_
    COAM Commission with scf file    scf_file_path=${SCF_13664_E_1001}    connection=enblte    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    sleep    60s
    Wait Until Keyword Succeeds  5min  5s  Check RU Onair
    Wait Until Keyword Succeeds  5min  5s  Check RU Onair    connection=enblte
    log to console    *********check nr and lte cells on both BTS are disabled*********
    Wait Until Keyword Succeeds    10min    5s    Check all the Cell status    connection=GNB_OAM    operationalState=disabled    usageState=idle
    Wait Until Keyword Succeeds    10min    5s    Check all the Cell status    connection=enblte    operationalState=disabled    usageState=idle
    log to console     *********start sas server and enable cbrs on 1001*********
    start SAS server    config_name=${CB013664_conf}    path=${sas_3}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs_1001}    connection=enblte
    Sleep    120s
    log to console    *********check no CBSD-sas message*********
    Check CB013664 no registrationRequest
    log to console    *********enable cbrs on 953, modify redundancyRole of 953 to active*********
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs_953}    connection=GNB_OAM
    Sleep    30s
    CB013664 Modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=active    connection=GNB_OAM
    log to console    *********check cells on 953 are on air*********
    Wait Until Keyword Succeeds    10min    5s    Check all cells info should be onair    connection=GNB_OAM
    log to console    *********get all grantID for each cels on 953*********
    ${nrcell1_grantid_953}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=51
    ${nrcell2_grantid_953}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=52
    ${nrcell3_grantid_953}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=61
    ${ltecell11_grantid_953}    Get CBSDCEL_R value via COAM    cellID=55    pattern=grantId
    ${ltecell12_grantid_953}    Get CBSDCEL_R value via COAM    cellID=65    pattern=grantId
    log to console    *********lock one AWHQU SFP*********
    lock unlock SFP    operation=Locked
    log to console    *********check cells on 953 are degraded*********
    FOR    ${cell_id}    IN     @{cells_953_NR}
        Wait Until Keyword Succeeds    10min    5s   verify cell status degrade or disable by cellid    cellid=${cell_id}
        ...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
    END
    FOR    ${cell_id}    IN     @{cells_953_LTE}
        Wait Until Keyword Succeeds    10min    5s    verify cell status degrade or disable by cellid    cellid=${cell_id}
        ...    administrative=unlocked    operationalState=enabled    availabilityStatus=degraded
    END
    log to console    *********4003 raised for cells on the 2 AWHQU*********
    FOR    ${cell_id}    IN     @{cells_953_NR}
        Wait Until Keyword Succeeds    10min    5s    Expect Fault Should Present With Absolute Source    faultId=4003
        ...    configObjectName=[${btsName}] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    END
    FOR    ${cell_id}    IN     @{cells_953_LTE}
        Wait Until Keyword Succeeds    10min    5s    Expect Fault Should Present With Absolute Source    faultId=4003
        ...    configObjectName=[${btsName}] MRBTS-${mrbtsID}/LNBTS-${lnbtsID_953}/LNCEL-${cell_id}
    END
    log to console    *********modify redundancyRole of 953 to standby*********
    CB013664 Modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=standby    connection=GNB_OAM
    log to console    *********check cells on 953 are disabled*********
    Wait Until Keyword Succeeds    10min    5s    Check all the Cell status    connection=GNB_OAM    operationalState=disabled
    ...    usageState=idle
    log to console    *********modify redundancyRole of 1001 to active*********
    CB013664 Modify the parameter    dist_name=MRBTS-${mrbtsID_enb}/MNL-1/MNLENT-1/REDUNDANCY-1    parameter_name=redundancyRole
    ...    value=active    connection=enblte
    log to console    *********check cells on 1001 are onair*********
    FOR    ${cell_id}    IN    @{cells_1001}
            Wait until keyword succeeds    5min    5s    verify cell status not degrade or disable by cellid    cellid=${cell_id}
            ...    administrative=Unlocked    operationalState=enabled    connection=enblte
    END
    log to console    *********get all grantID for each cels on 1001*********
    ${nrcell1_grantid_1001}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=151    connection=enblte
    ${nrcell2_grantid_1001}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=152    connection=enblte
    ${nrcell3_grantid_1001}    Get subGrantInfo Item by Coam    pattern=grantIdSub    cellID=161    connection=enblte
    ${ltecell11_grantid_1001}    Get CBSDCEL_R value via COAM    cellID=155    pattern=grantId    connection=enblte
    ${ltecell12_grantid_1001}    Get CBSDCEL_R value via COAM    cellID=165    pattern=grantId    connection=enblte
    log to console    *********check grandID on 1001 now is equal to grandID on 953 before*********
    Should be True    '${nrcell1_grantid_953}'=='${nrcell1_grantid_1001}'
    Should be True    '${nrcell2_grantid_953}'=='${nrcell2_grantid_1001}'
    Should be True    '${nrcell3_grantid_953}'=='${nrcell3_grantid_1001}'
    Should be True    '${ltecell11_grantid_953}'=='${ltecell11_grantid_1001}'
    Should be True    '${ltecell12_grantid_953}'=='${ltecell12_grantid_1001}'
    Check CB013664 SAS log by cbsdid    cbsdid=1108_Nokia_AH242402138.NR
    Check CB013664 SAS log by cbsdid    cbsdid=1108_Nokia_EB2313R0197.NR
    Check CB013664 SAS log by cbsdid    cbsdid=nokia_100_AH242402138
    Check CB013664 SAS log by cbsdid    cbsdid=nokia_100_EB2313R0197
    lock unlock SFP    operation=Unlocked
    sleep    30s
    Wait Until Keyword Succeeds  10min  5s  Check RU Onair
    Wait Until Keyword Succeeds  10min  5s  Check RU Onair    connection=enblte
#    ${alarm_status_1001}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
#    ...    connection=enblte
#    should be true    ${alarm_status_1001}
#    ${history_alarm_status_1001}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=enblte
#    should be true    ${history_alarm_status_1001}
    [Teardown]    Run keywords    lock unlock SFP    operation=Unlocked    AND
    ...     Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=enblte    AND
    ...    CB013664 recovery ENV

Get btsName
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
	${btsName}    selenium_coam.get_bts_name
    Set Suite Variable    ${btsName}
    [Teardown]    Selenium Logout And Close Browser

lock unlock SFP
    [Arguments]    ${operation}=Locked
    Selenium Login And Disable Screen Lock
    selenium_coam.Set Parameter Value    dist_name=MRBTS-${mrbtsId}/EQM-1/APEQM-1/CABINET-1/BBMOD-3/SFP-8/LANE-1
    ...    filter_param=Administrative state    abbr=administrativeState
    ...    new_value=${operation}
    selenium_coam.Validate Plan
    selenium_coam.Activate Plan    activate_plan_despite_errors=${true}    execute=${true}
    run keyword and ignore error    Selenium Logout And Close Browser
    sleep    30s

CB013664_configuration_RU_failure_test_CBRS
    [Arguments]    ${configuration}
    log to console    *********power off tl1001*********
    check and power on or off enb    powerStatus=off
    log to console    *********scf recommission*********
    ${SCF_13664_953}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_13664_${configuration}_953_
    COAM Commission with scf file    scf_file_path=${SCF_13664_953}    connection=GNB_OAM    timeout=600
    ...    is_pdl_checking_needed=${if_pdl_check}
    Sleep    60s
    Wait Until Keyword Succeeds  10min  5s  Check RU Onair
    log to console    *********start SASsim and enable CBRS*********
    start SAS server    config_name=${CB013664_conf}    path=${sas_3}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs_actnrcbrs_953}    connection=GNB_OAM
    Sleep    30s
    log to console    *********check cells on 953 are on air*********
    Wait Until Keyword Succeeds    5min    10s    Check all cells info should be onair    connection=GNB_OAM
    log to console    *********power off one AWHQU*********
    Perform RU Power Off    ru_index=${6}
    sleep    60s
    ${SI_count_before}    OperatingSystem.Run    cat ${CURDIR}/../../resources/SASSim3/SAS_Sim.log |grep spectrumInquiryRequest|wc -l
    log to console    *********check cells on 953 are degraded, 4003 raised for cells on the 2 AWHQU********
    FOR    ${cell_id}    IN     @{cells_953_NR}
        run keyword and ignore error    verify cell status degrade or disable by cellid    cellid=${cell_id}
        ...    administrative=Unlocked    operationalState=enabled    availabilityStatus=degraded
        Expect Fault Should Present With Absolute Source    faultId=4003
        ...    configObjectName=[${btsName}] MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    END
    FOR    ${cell_id}    IN     @{cells_953_LTE}
        verify cell status degrade or disable by cellid    cellid=${cell_id}
        ...    administrative=unlocked    operationalState=enabled    availabilityStatus=degraded
        Expect Fault Should Present With Absolute Source    faultId=4003
        ...    configObjectName=[${btsName}] MRBTS-${mrbtsID}/LNBTS-${lnbtsID_953}/LNCEL-${cell_id}
    END
    log to console    *********wait querySasServerPeriod*2 timer*********
    sleep    360s
    log to console    *********check no SI message during AWHQU power off*********
    ${SI_count_after}    OperatingSystem.Run    cat ${CURDIR}/../../resources/SASSim3/SAS_Sim.log |grep spectrumInquiryRequest|wc -l
    should be equal    ${SI_count_before}    ${SI_count_after}
    log to console    *********power on the AWHQU*********
    Perform RU Power On    ru_index=${6}
    sleep    60s
    log to console    check fault 4003 cancelled for cells on 953
    FOR    ${cell_id}    IN     @{cells_953_NR}
        Wait Until Keyword Succeeds    10min    5s    Expect Fault Should Absent With Absolute Source    faultId=4003
    END
    FOR    ${cell_id}    IN     @{cells_953_LTE}
        Wait Until Keyword Succeeds    10min    5s    Expect Fault Should Absent With Absolute Source    faultId=4003
    END
    log to console    *********wait querySasServerPeriod*2 timer*********
    sleep    360s
    log to console    *********check SI message in saslog
    ${SI_count_last}    OperatingSystem.Run    cat ${CURDIR}/../../resources/SASSim3/SAS_Sim.log |grep spectrumInquiryRequest|wc -l
    should be true    ${SI_count_last} > ${SI_count_after}
    [Teardown]    run keywords    Perform RU Power On    ru_index=${6}    AND    sleep    60s    AND
    ...    Run Keyword    wait until keyword succeeds    10min  5s  Check RU Onair    AND
    ...    check and power on or off enb    powerStatus=on    AND    sleep    60s    AND
    ...    Run Keyword    wait until keyword succeeds    10min  5s  Check RU Onair    connection=enblte

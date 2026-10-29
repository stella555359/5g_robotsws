*** Settings ***
Documentation    Suite description
Resource     ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource     ../../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_CP_Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Library        SSHLibrary    timeout=10s
*** Variables ***
${UE_TYPE}                ${tl.ues[0].capabilities[-1]}
${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}
${FSDURATION}          60min
${FSDURATION_2}          70min
${FSODAYOFWEEK}        everyDay

*** Keywords ***

SuiteSetup
    log to console    \n*** Coam Suite Setup***
    TestSuite.Start
    Import Variables         ${CFGFILE_PATH}/TLConfiguration.py
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    ${sw_version}     coam.get_sw_version    connection=COAM
    ${stream}   ${subversion}    Split String   string=${sw_version}   separator=_     max_split=1
    set suite variable    ${sbts_stream}    ${stream}
    COAM_Admin.Logout
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    gNB.FormatBTSID
#    Run keyword if    '${sbts_stream}'=='SBTS25R1'    gNB.Commission    scf_file=${CFGFILE_PATH}/SBTS25R1_CB012087_SCF.xml    timeout=${600}
#    ...  ELSE IF    '${sbts_stream}'=='SBTS25R2'    gNB.Commission    scf_file=${CFGFILE_PATH}/SBTS25R2_CB012087_SCF.xml    timeout=${600}
#    ...  ELSE    log to console    ${sbts_stream}
    sleep    30s
    wait until keyword succeeds    10min    10s    COAM_Admin.CheckAllCellsOnair
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    log to console    \n***commission gnb***

SuiteTearDown
    robot_common_operations.Common Suite Teardown
    TestSuilt.Stop

CB012087 Test Setup
    log to console    \n***Coam Test Setup***
    log to console    Active_SW_version:${sbts_stream}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
#    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}    Fail    TEST
    Run Keyword And Ignore error     BtsLog.StartBTSlogCollection
    Run Keyword And Ignore Error    selenium.close_browser
    TestCase.Start

CB012087 Test Teardown
    log to console    \n***Coam Test Teardown***
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
#    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
#    should be true    ${alarm_status}
#    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    run keyword if test failed     Collect_snapshot_by_WEBUI
    run keyword and ignore error    KW.ChangeLowVoltagetoDefaultValue
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    TestCase.Stop


Collect_snapshot_by_WEBUI
    [Arguments]    ${loop}=0
    COAM_WebEM.Login    version=${sbts_stream}
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${SAVE LOG DIRECTORY}/snapshot_${filename}_${loop}.zip


TC.CB012087_A_8_5G Cell_switch_on_based_on_configured_time_of_day_successfully
   ${es_hour}    ${es_minute}     KW.gNB.Getgnbtime
   set test variable      ${es_hour}
   set test variable      ${es_minute}
   wait until keyword succeeds   2min    10s    COAM_WebEM.Login    version=${sbts_stream}
   ${fsoStartHour_org}    selenium_coam.get_parameter_value
   ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRFSOPGRP-1     filter_param=Forced switch off start hour    abbr=fsoStartHour
   log to console    ${fsoStartHour_org}hour
   selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRFSOPGRP-1
   ...    filter_param=Forced switch off start hour     new_value=${es_hour}   abbr=fsoStartHour
   selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRFSOPGRP-1
   ...    filter_param=Forced switch off start minute    new_value=${es_minute}   abbr=fsoStartMinute
   selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRFSOPGRP-1
   ...    filter_param=Forced switch off duration    new_value=${FSDURATION}   abbr=fsoDuration
   selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRFSOPGRP-1
   ...    filter_param=Forced switch off day of week    node_index=${0}    new_value=${FSODAYOFWEEK}   abbr=fsoDayOfWeek
   ${res}    run keyword and ignore error    COAM_WebEM.ValidateAndActiveParameters    activate_plan_despite_errors=True
   Run Keyword If   '${res[0]}'!='FAIL'   set suite variable    ${CASE_A3}    PASS
   ...    ELSE    set suite variable    ${CASE_A3}    FAIL

   @{CELL_list}    Create list      301  302
   wait until keyword succeeds    5min    10s     kw.CheckcellinEnergySaving    CELL_list=${CELL_list}
   sleep    1min
   log to console    wait time expire to exist EnergySaving
   wait until keyword succeeds    ${FSDURATION}    60s     kw.CheckcellinnotEnergySaving    CELL_list=${CELL_list}
   run keyword and ignore error    COAM_WebEM.Logout

   set test variable    ${IMSI}    ${tl.ues[0].imsi}
   wait until keyword succeeds    30min    1min     UE.One_UE_Call_with_traffic    ue_type=${UE_TYPE}    cell_idx=301
   ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
   ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
   ...    apn_address=${TLCommonConfig["MultiUECFG"]["0"]["apn"]}

TC.CB012087_A_3_Activation and configuration of 5G Cell Locking based on Time of Day
    run keyword if    '${CASE_A3}'=='PASS'     log     pass
    ...    ELSE    Fail    Case not pass

TC.CB012087_B_1_Cell_unavailability_counters_are_updated_based_on_low_voltage
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login    version=${sbts_stream}
    ${BTSNAME}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}     filter_param=BTS name     abbr=btsName
    set test variable      ${BTSNAME}
    ${CELL301_NAME}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-301     filter_param=Cell name     abbr=cellName
    set test variable      ${CELL301_NAME}
    ${CELL302_NAME}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-302     filter_param=Cell name     abbr=cellName
    set test variable      ${CELL302_NAME}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRFSOPGRP-2
    ...    filter_param=Low voltage cell switch off threshold     new_value=56   abbr=lowVoltageCellSwitchOffThr
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRFSOPGRP-2
    ...    filter_param=Low voltage cell switch on threshold	  new_value=57   abbr=lowVoltageCellSwitchOnThr
     ${res}    run keyword and ignore error   COAM_WebEM.ValidateAndActiveParameters    activate_plan_despite_errors=False
    Run Keyword If   '${res[0]}'!='FAIL'   set suite variable    ${CASE_B3}    PASS
    ...    ELSE    set suite variable    ${CASE_B3}    FAIL
    @{CELL_list}    Create list      301
    wait until keyword succeeds    5min    10s     kw.CheckcellinEnergySaving    CELL_list=${CELL_list}

    log to console    check cell-301 M55601C01002 M55601C00502 M55601C01001 M55601C00501 M55601C00504 is updated
    wait until keyword succeeds   6min    10s     KW.CheckCounterIsUpdate    counter_id=M55601C01002
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL301_NAME}] NRCELL-301/NCAV/NR_CELL_PLAN_UNAVAIL_CHNG_TO
    wait until keyword succeeds   5min    10s     KW.CheckCounterIsUpdate    counter_id=M55601C00502
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL301_NAME}] NRCELL-301/NCAV/CHNG_TO_NR_CELL_POWER_SAVING
    wait until keyword succeeds   5min    10s     KW.CheckCounterIsUpdate    counter_id=M55601C01001
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL301_NAME}] NRCELL-301/NCAV/NR_CELL_PLAN_UNAVAIL_SAMPLES
    wait until keyword succeeds   5min    10s     KW.CheckCounterIsUpdate    counter_id=M55601C00501
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL301_NAME}] NRCELL-301/NCAV/SAMPLES_NR_CELL_POWER_SAVING
    wait until keyword succeeds   5min    10s     KW.CheckCounterIsUpdate    counter_id=M55601C00504
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL301_NAME}] NRCELL-301/NCAV/SAMPLES_NR_CELL_POWER_SAV_L_V

    log to console    check cell-301 M55601C01004 M55601C01003 is not updated
    KW.CheckCounterIsNotUpdate    counter_id=M55601C01004
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL301_NAME}] NRCELL-301/NCAV/NR_CELL_UNPLAN_UNAVAIL_CHNG_TO
    KW.CheckCounterIsNotUpdate    counter_id=M55601C01003
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL301_NAME}] NRCELL-301/NCAV/NR_CELL_UNPLAN_UNAVAIL_SAMPLES

    log to console    check cell-302 counter is not updated
    KW.CheckCounterIsNotUpdate    counter_id=M55601C01004
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL302_NAME}] NRCELL-302/NCAV/NR_CELL_UNPLAN_UNAVAIL_CHNG_TO
    KW.CheckCounterIsNotUpdate    counter_id=M55601C01003
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL302_NAME}] NRCELL-302/NCAV/NR_CELL_UNPLAN_UNAVAIL_SAMPLES
    KW.CheckCounterIsNotUpdate    counter_id=M55601C01002
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL302_NAME}] NRCELL-302/NCAV/NR_CELL_PLAN_UNAVAIL_CHNG_TO
    KW.CheckCounterIsNotUpdate    counter_id=M55601C00502
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL302_NAME}] NRCELL-302/NCAV/CHNG_TO_NR_CELL_POWER_SAVING
    KW.CheckCounterIsNotUpdate    counter_id=M55601C01001
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL302_NAME}] NRCELL-302/NCAV/NR_CELL_PLAN_UNAVAIL_SAMPLES
    KW.CheckCounterIsNotUpdate    counter_id=M55601C00501
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL302_NAME}] NRCELL-302/NCAV/SAMPLES_NR_CELL_POWER_SAVING
    KW.CheckCounterIsNotUpdate    counter_id=M55601C00504
    ...    full_path=[${BTSNAME}] ${MRBTS_ID}/${NRBTS_ID}/[${CELL302_NAME}] NRCELL-302/NCAV/SAMPLES_NR_CELL_POWER_SAV_L_V

    KW.ChangeLowVoltagetoDefaultValue
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login    version=${sbts_stream}
    wait until keyword succeeds    5min    10s     kw.CheckcellinnotEnergySaving    CELL_list=${CELL_list}
    run keyword and ignore error    COAM_WebEM.Logout

TC.CB012087_B_3_Activation and configuration of 5G Cell Locking based on Voltage
    run keyword if    '${CASE_B3}'=='PASS'     log     pass
    ...    ELSE    Fail    Case not pass

TC.CB012087_LTE_Cell_switch_off_and_on_ based_on_configured_low_voltage
    [Documentation]   check CB012087 could work for LTE cells by low voltage
    [Arguments]  ${cell_list}=${CASE_INPUT_CB012087['cell_list']}
    ...          ${radios_sn}=${CASE_INPUT_CB012087['radios_sn']}
    ...          ${objects}=${CASE_INPUT_CB012087['objects']}
    ...          ${technology}=${CASE_INPUT_CB012087['technology']}
    ...          ${path_ids}=${CASE_INPUT_CB012087['path_id']}
    ...          ${dist_name}=${CASE_INPUT_CB012087['dist_name']}
    wait until keyword succeeds   2min    10s    COAM_Admin.commission
    ...      scf_file=${CFGFILE_PATH}${sbts_stream}_CB12087_LTE_SCF.xml
    Sleep  5min
    wait until keyword succeeds    10min    30s    COAM_Admin.CheckAllCellsOnair    type=both
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login
    ${Voltage_l_1}    selenium_coam.get_parameter_value
    ...    dist_name=${dist_name}    filter_param=Low voltage cell switch off threshold
    ...    abbr=lowVoltageCellSwitchOffThr
    ${Voltage_l_2}    Split String    ${Voltage_l_1}    ${SPACE}
    ${Voltage_l_3}    Convert To Integer    ${Voltage_l_2}[0]
    ${Voltage_l_t}=    Evaluate    int(${Voltage_l_3})*1000-1000
    ${Voltage_h_1}    selenium_coam.get_parameter_value
    ...    dist_name=${dist_name}    filter_param=Low voltage cell switch on threshold
    ...    abbr=lowVoltageCellSwitchOnThr
    ${Voltage_h_2}    Split String    ${Voltage_h_1}    ${SPACE}
    ${Voltage_h_3}    Convert To Integer    ${Voltage_h_2}[0]
    ${Voltage_h_t}=    Evaluate    int(${Voltage_h_3})*1000+1000
    run keyword and ignore error    COAM_WebEM.Logout
    log to console    start to trigger low voltage
    ${IPs}    wait until keyword succeeds   2min    30s    KW.Get RUs IP    radios_sn=${radios_sn}
    wait until keyword succeeds   2min    30s    KW.SSH to RU via FH and execute command to set voltage    RU_Ip=${IPs}
    ...       Voltage_T=${Voltage_l_t}
    log to console    start to check RU voltage via WebEM real time measurement
    wait until keyword succeeds   10min    60s    KW.check RU voltage    objects=${objects}    Voltage_T=${Voltage_l_t}
    log to console    start to check LTE cells should go to ESM
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login
    wait until keyword succeeds    10min    30s     kw.CheckcellinEnergySaving    CELL_list=${cell_list}
    ...    technology=${technology}    status=EnergySaving
    Sleep  5min
    log to console    start to check counters
    FOR  ${key}  ${value}  IN  &{path_ids}
        wait until keyword succeeds   30min    5min    COAM_WebEM.CheckCounter    id=${value}   min=1   max=900
        ...     path=${key}
    END
    run keyword and ignore error    COAM_WebEM.Logout
    Log    Counters updated!
    log to console    start to recover RU voltage to exit ESM
    wait until keyword succeeds   2min    30s    KW.SSH to RU via FH and execute command to set voltage    RU_Ip=${IPs}
    ...       Voltage_T=${Voltage_h_t}
    wait until keyword succeeds   10min    60s    KW.check RU voltage    objects=${objects}    Voltage_T=${Voltage_h_t}
    log to console    start to check LTE cells should exit ESM
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login
    wait until keyword succeeds    10min    30s     kw.CheckcellinnotEnergySaving    CELL_list=${cell_list}
    ...    technology=${technology}    status=NotEnergySaving
    wait until keyword succeeds    10min    10s    COAM_Admin.CheckAllCellsOnair    type=both
    run keyword and ignore error    COAM_WebEM.Logout

TC.CB012087_C_5_4G Cell switch off based on configured time of day successfully
    [Documentation]   check CB012087 could work for LTE cells by Time
    [Arguments]  ${cell_list_L}=${CASE_INPUT_CB012087['C_5']['cell_list_L']}
    ...          ${dist_name_L}=${CASE_INPUT_CB012087['C_5']['dist_name_L']}
    ...          ${path_ids_L}=${CASE_INPUT_CB012087['C_5']['path_ids_L']}
    ...          ${cell_list_N}=${CASE_INPUT_CB012087['C_5']['cell_list_N']}
    ...          ${dist_name_N}=${CASE_INPUT_CB012087['C_5']['dist_name_N']}
    ...          ${technology}=${CASE_INPUT_CB012087['technology']}
    wait until keyword succeeds   2min    10s    COAM_Admin.commission
    ...      scf_file=${CFGFILE_PATH}${sbts_stream}_CB12087_LTE_C5_SCF.xml
    Sleep  5min
    wait until keyword succeeds    10min    30s    COAM_Admin.CheckAllCellsOnair    type=both
#    run keyword and ignore error    COAM_WebEM.Logout
#    wait until keyword succeeds    20min    2min    KW.Set configuration and check ESM status for CB012087 by Time
#    ...    dist_name=${dist_name1}    FSDURATION=${FSDURATION}    FSODAYOFWEEK=${FSODAYOFWEEK}    cell=${cell_1}
#    ...    technology=${technology}
#    Sleep  5s
#    wait until keyword succeeds    20min    2min    KW.Set configuration and check ESM status for CB012087 by Time
#    ...    dist_name=${dist_name2}    FSDURATION=${FSDURATION}    FSODAYOFWEEK=${FSODAYOFWEEK}    cell=${cell_2}
#    ...    technology=${technology}
#    log to console    start to check counters for CELL_${cell_1}
    LOG    Trigger LTE cells and NR cells go to ESM by Time
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login
    wait until keyword succeeds    10min    30s    COAM_WebEM.ModifyAndActiveParameters    DistName=${dist_name_L}
    ...    FilterParam=Forced switch off duration    NewValue=1440min
    Sleep  5s
    wait until keyword succeeds    10min    30s    COAM_WebEM.ModifyAndActiveParameters    DistName=${dist_name_N}
    ...    FilterParam=Forced switch off duration    NewValue=1440min
    Sleep  10s
    run keyword and ignore error    COAM_WebEM.Logout
    LOG    Check NR cells and LTE cells status
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login
    wait until keyword succeeds    5min    30s     kw.CheckcellinEnergySaving    CELL_list=${cell_list_L}
    ...    technology=${technology}    status=EnergySaving
    Sleep  5s
    wait until keyword succeeds    5min    30s     kw.CheckcellinEnergySaving    CELL_list=${cell_list_N}
    run keyword and ignore error    COAM_WebEM.Logout
    LOG    Check counters
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login
    FOR  ${key}  ${value}  IN  &{path_ids_L}
        wait until keyword succeeds   30min    5min    COAM_WebEM.CheckCounter    id=${value}   min=1
        ...     path=${key}
    END
    LOG    Trigger LTE cells and NR cells switch on
    wait until keyword succeeds    10min    30s    COAM_WebEM.ModifyAndActiveParameters    DistName=${dist_name_L}
    ...    FilterParam=Forced switch off duration    NewValue=1min
    Sleep  5s
    wait until keyword succeeds    10min    30s    COAM_WebEM.ModifyAndActiveParameters    DistName=${dist_name_N}
    ...    FilterParam=Forced switch off duration    NewValue=1min
    wait until keyword succeeds    10min    1min    COAM_Admin.CheckAllCellsOnair    type=both
    run keyword and ignore error    COAM_WebEM.Logout

TC.CB012087_C_9_Online change time of day parameters during cell is switched off by time of day
    [Arguments]  ${cell_1}=${CASE_INPUT_CB012087['C_9']['cell_1']}
    ...          ${dist_name}=${CASE_INPUT_CB012087['C_9']['dist_name']}
    ...          ${cell_2}=${CASE_INPUT_CB012087['C_9']['cell_2']}
    ...          ${technology}=${CASE_INPUT_CB012087['technology']}
    wait until keyword succeeds   2min    10s    COAM_Admin.commission
    ...      scf_file=${CFGFILE_PATH}${sbts_stream}_CB12087_LTE_C9_SCF.xml
    Sleep  5min
    wait until keyword succeeds    10min    30s    COAM_Admin.CheckAllCellsOnair    type=both
    run keyword and ignore error    COAM_WebEM.Logout
    wait until keyword succeeds    20min    2min    KW.Set configuration and check ESM status for CB012087 by Time
    ...    dist_name=${dist_name}    FSDURATION=${FSDURATION}    FSODAYOFWEEK=${FSODAYOFWEEK}    cell=${cell_1}
    ...    technology=${technology}
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login
    wait until keyword succeeds    10min    30s    COAM_WebEM.ModifyAndActiveParameters    DistName=${dist_name}
    ...    FilterParam=Forced switch off duration    NewValue=${FSDURATION_2}
#    wait until keyword succeeds    10min    30s    COAM_WebEM.ValidateAndActiveParameters
#    ...    activate_plan_despite_errors=True
    run keyword and ignore error    COAM_WebEM.Logout
    Sleep  30s
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login
    wait until keyword succeeds    5min    1min     kw.CheckcellinEnergySaving    CELL_list=${cell_1}
    ...    technology=${technology}    status=EnergySaving
    wait until keyword succeeds    10min    30s    coam.perform_delta_recommissioning
    ...   delta_file=${CFGFILE_PATH}/C9_delta.json     skip_parameter_relation_errors=True    connection=GNB_OAM
    Sleep  30s
    wait until keyword succeeds    5min    1min     kw.CheckcellinEnergySaving    CELL_list=${cell_2}
    ...    technology=${technology}    status=EnergySaving
    wait until keyword succeeds    5min    1min     kw.CheckcellinnotEnergySaving    CELL_list=${cell_1}
    ...    technology=${technology}    status=NotEnergySaving
    wait until keyword succeeds    10min    30s    COAM_WebEM.ModifyAndActiveParameters    DistName=${dist_name}
    ...    FilterParam=Forced switch off duration    NewValue=1min
    run keyword and ignore error    COAM_WebEM.Logout
    wait until keyword succeeds    10min    1min    COAM_Admin.CheckAllCellsOnair    type=both
    Run Keyword And Ignore Error    COAM Teardown gnb connections

TC.CB012087_NR_A8_5G Cell_switch_on_based_on_configured_time_of_day_successfully
    [Arguments]  ${cell_list}=${CASE_INPUT_CB012087['A8']['cell_list']}
    ...          ${dist_name}=${CASE_INPUT_CB012087['A8']['dist_name']}
    ...          ${A8_duration}=${CASE_INPUT_CB012087['A8']['duration']}
    wait until keyword succeeds   5min    30s    COAM_Admin.commission
    ...      scf_file=${CFGFILE_PATH}${sbts_stream}_CB12087_NR_A8_SCF.xml
    Sleep  5min
    wait until keyword succeeds    10min    30s    COAM_Admin.CheckAllCellsOnair    type=both
    ${es_hour}    ${es_minute}     KW.gNB.Getgnbtime
    set test variable      ${es_hour}
    set test variable      ${es_minute}
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login
#   ${fsoStartHour_org}    selenium_coam.get_parameter_value
#   ...    dist_name=${dist_name}     filter_param=Forced switch off start hour    abbr=fsoStartHour
#    log to console    ${fsoStartHour_org}hour
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=Forced switch off start hour     new_value=${es_hour}   abbr=fsoStartHour
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=Forced switch off start minute    new_value=${es_minute}   abbr=fsoStartMinute
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=Forced switch off duration    new_value=${A8_duration}   abbr=fsoDuration
    wait until keyword succeeds   5min    30s    COAM_WebEM.ValidateAndActiveParameters    activate_plan_despite_errors=True
    LOG    start to check: NRCELL should enter to ESM!
    wait until keyword succeeds    5min    30s     kw.CheckcellinEnergySaving    CELL_list=${cell_list}
    LOG    wait NRCELL exit ESM and back to onAir!
    wait until keyword succeeds    10min    30s    COAM_Admin.CheckAllCellsOnair    type=both
    run keyword and ignore error    COAM_WebEM.Logout
#   set test variable    ${IMSI}    ${tl.ues[0].imsi}
#   wait until keyword succeeds    30min    1min     UE.One_UE_Call_with_traffic    ue_type=${UE_TYPE}    cell_idx=301
#   ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
#   ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
#   ...    apn_address=${TLCommonConfig["MultiUECFG"]["0"]["apn"]}

TC.CB012087_NR_B1_Cell_unavailability_counters_are_updated_based_on_low_voltage
    [Arguments]  ${cell_list1}=${CASE_INPUT_CB012087['B1']['cell_list1']}
    ...          ${dist_name}=${CASE_INPUT_CB012087['B1']['dist_name']}
    ...          ${cell_list2}=${CASE_INPUT_CB012087['B1']['cell_list2']}
    ...          ${radios_sn}=${CASE_INPUT_CB012087['B1']['radios_sn']}
    ...          ${objects}=${CASE_INPUT_CB012087['B1']['objects']}
    ...          ${path_ids1}=${CASE_INPUT_CB012087['B1']['path_ids1']}
    ...          ${path_ids2}=${CASE_INPUT_CB012087['B1']['path_ids2']}
    ...          ${path_ids3}=${CASE_INPUT_CB012087['B1']['path_ids3']}
    wait until keyword succeeds   2min    10s    COAM_Admin.commission
    ...      scf_file=${CFGFILE_PATH}${sbts_stream}_CB12087_NR_B1_SCF.xml
    Sleep  5min
    wait until keyword succeeds    10min    30s    COAM_Admin.CheckAllCellsOnair    type=both
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login
    ${Voltage_l_1}    selenium_coam.get_parameter_value
    ...    dist_name=${dist_name}    filter_param=Low voltage cell switch off threshold
    ...    abbr=lowVoltageCellSwitchOffThr
    ${Voltage_l_2}    Split String    ${Voltage_l_1}    ${SPACE}
    ${Voltage_l_3}    Convert To Integer    ${Voltage_l_2}[0]
    ${Voltage_l_t}=    Evaluate    int(${Voltage_l_3})*1000-1000
    ${Voltage_h_1}    selenium_coam.get_parameter_value
    ...    dist_name=${dist_name}    filter_param=Low voltage cell switch on threshold
    ...    abbr=lowVoltageCellSwitchOnThr
    ${Voltage_h_2}    Split String    ${Voltage_h_1}    ${SPACE}
    ${Voltage_h_3}    Convert To Integer    ${Voltage_h_2}[0]
    ${Voltage_h_t}=    Evaluate    int(${Voltage_h_3})*1000+1000
    log to console    start to trigger low voltage
    ${IPs}    wait until keyword succeeds   2min    30s    KW.Get RUs IP    radios_sn=${radios_sn}
    wait until keyword succeeds   2min    30s    KW.SSH to RU via FH and execute command to set voltage    RU_Ip=${IPs}
    ...       Voltage_T=${Voltage_l_t}
    log to console    start to check RU voltage via WebEM real time measurement
    wait until keyword succeeds   10min    60s    KW.check RU voltage    objects=${objects}    Voltage_T=${Voltage_l_t}
    log to console    start to check LTE cells should go to ESM
    wait until keyword succeeds    10min    30s     kw.CheckcellinEnergySaving    CELL_list=${cell_list1}
    log to console    Counters of cells in ${cell_list1} : M55601C01002 M55601C00502 M55601C01001 M55601C00501 M55601C00504 should update!
    FOR  ${key}  ${value}  IN  &{path_ids1}
        wait until keyword succeeds   10min    10s    KW.CB012087.CheckCounter    id=${value}   min=1   max=900
        ...     path=${key}
    END
    log to console    Counters of cells in ${cell_list1}: M55601C01004 M55601C01003 should not update!
    FOR  ${key}  ${value}  IN  &{path_ids2}
        KW.CB012087.CheckCounter    id=${value}   min=0   max=0    path=${key}
    END
    log to console    Counters of cells in ${cell_list2}: All related counters should not update!
    FOR  ${key}  ${value}  IN  &{path_ids3}
        KW.CB012087.CheckCounter    id=${value}   min=0   max=0    path=${key}
    END
    Log    Counters updated as expected
    run keyword and ignore error    COAM_WebEM.Logout
    log to console    start to recover RU voltage to exit ESM
    wait until keyword succeeds   2min    30s    KW.SSH to RU via FH and execute command to set voltage    RU_Ip=${IPs}
    ...       Voltage_T=${Voltage_h_t}
    wait until keyword succeeds   10min    60s    KW.check RU voltage    objects=${objects}    Voltage_T=${Voltage_h_t}
    log to console    start to check cells should exit ESM and back to onAir
    wait until keyword succeeds    10min    30s    COAM_Admin.CheckAllCellsOnair    type=both
    run keyword and ignore error    COAM_WebEM.Logout

KW.Set configuration and check ESM status for CB012087 by Time
    [Arguments]   ${dist_name}=1    ${FSDURATION}=1    ${FSODAYOFWEEK}=everyday    ${cell}=1    ${technology}=NR
    ${es_hour}    ${es_minute}     KW.gNB.Getgnbtime
    set test variable      ${es_hour}
    set test variable      ${es_minute}
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login
#    ${fsoStartHour_org}    selenium_coam.get_parameter_value
#    ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRFSOPGRP-1     filter_param=Forced switch off start hour    abbr=fsoStartHour
#    log to console    ${fsoStartHour_org}hour
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=Forced switch off start hour     new_value=${es_hour}   abbr=fsoStartHour
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=Forced switch off start minute    new_value=${es_minute}   abbr=fsoStartMinute
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=Forced switch off duration    new_value=${FSDURATION}   abbr=fsoDuration
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=Forced switch off day of week    node_index=${0}    new_value=${FSODAYOFWEEK}   abbr=fsoDayOfWeek
    wait until keyword succeeds    10min    30s    COAM_WebEM.ValidateAndActiveParameters    activate_plan_despite_errors=True
    LOG    CB012087_Time configuration for CELL_${cell} done!
    wait until keyword succeeds    5min    10s     kw.CheckcellinEnergySaving    CELL_list=${cell}
    ...    technology=${technology}    status=EnergySaving
    LOG    CELL_${cell} go to ESM!
    run keyword and ignore error    COAM_WebEM.Logout

KW.SSH to Secondary core via Primary core
    [Arguments]    ${hostname_pcore}=fct-0a
    Log to console   ssh to secondary core
    ${container_id_score}    set variable if    '${hostname_pcore}' == 'fct-0a'    0x2018    0x1018
    ${hostname_score}    set variable if    '${hostname_pcore}' == 'fct-0a'    fct4s0icom.local    fct0s0icom.local
    ${prompt_score}    set variable if    '${hostname_pcore}' == 'fct-0a'    root@fct-4a:~ >    root@fct-0a:~ >
    ${prompt_container_score}    set variable if    '${hostname_pcore}' == 'fct-0a'    root@FHNET80:~ >    root@FHNET00:~ >
    SSHLibrary.Set Client Configuration    prompt=${prompt_score}
    SSHLibrary.Write    ssh -o StrictHostKeyChecking=no ${ASIK_USERNAME}@${hostname_score}
    Sleep  3s
    ${output}=    SSHLibrary.Read Until    Password:
    SSHLibrary.Write    ${ASIK_PASSWORD}
    ${output}=    SSHLibrary.Read Until Prompt
    Sleep  3s
    SSHLibrary.Set Client Configuration    prompt=${prompt_container_score}
    SSHLibrary.Write    lxc-attach -n ${container_id_score}
    ${output}=          SSHLibrary.Read Until Prompt
    Sleep  3s
    SSHLibrary.Write    rm .ssh/known_hosts
    Sleep  3s

KW.SSH to RU via FH and execute command to set voltage
    [Arguments]   ${RU_Ip}=[1.1.1.1]    ${Voltage_T}=53000    ${RuLocation}=primary core    ${ru_username}=root
    ...           ${ru_password}=root
    Log to console    ssh to primary
    SSHLibrary.Open Connection    ${PrimaryDefaultIP}
    SSHLibrary.Login    ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    ${hostname_pcore}=    SSHLibrary.Execute Command    hostname
    Sleep  3s
    ${container_id_score}    set variable if    '${hostname_pcore}' == 'fct-0a'    0x1018    0x2018
    SSHLibrary.Write    rm .ssh/known_hosts
    Sleep  3s
    Run Keyword If    '${RuLocation}' == 'primary core'    SSHLibrary.Write    lxc-attach -n ${container_id_score}
    ...    ELSE    KW.SSH to Secondary core via Primary core    hostname_pcore=${hostname_pcore}
    Log to console   SSH to Radio and execute command
    FOR  ${ip}  IN  @{RU_Ip}
        SSHLibrary.Set Client Configuration    prompt=succesfully for domain 17
        SSHLibrary.Write    ssh -o StrictHostKeyChecking=no ${ru_username}@${ip}
        sleep  3s
        ${res}    run keyword and return status    SSHLibrary.Read Until    password:
        run keyword if    '${res}' == 'True'    SSHLibrary.Write    ${ru_password}
        SSHLibrary.Write    rad -mw 0x110032 ${Voltage_T}
        Sleep  1s
        ${output}=    SSHLibrary.Read Until Prompt
        SSHLibrary.Write    exit
    END
    SSHLibrary.Close All Connections
    Log to console    Voltage set complete!

KW.Get RUs IP
    [Arguments]   ${radios_sn}=[SN]
    ${RUs_IP}    Create list
    FOR  ${sn}  IN  @{radios_sn}
        ${ip}    wait until keyword succeeds   2min    30s    Coam Get RU IP via RMOD object    ru_serial_number=${sn}
        Append To List    ${RUs_IP}    ${ip}
        Log    ${RUs_IP}
        Log     RU_${sn} IP is ${ip}
    END
    [Return]     ${RUs_IP}
    Log    Get RUs IP complete!

KW.SSH to RU and execute command to set voltage
    [Arguments]   ${IPs}=1.1.1.1    ${Voltage}=53000
    ${cmd1}   Set Variable   lxc-attach 0x1018
    ${cmd2}   Set Variable   rad -mw 0x110032 ${Voltage}
    wait until keyword succeeds     60s    30s     SSHLibrary.Open Connection
    ...                host=192.168.255.129
    ...                port=22
    wait until keyword succeeds     2min    30s     SSHLibrary.Login
    ...                username=toor4nsn
    ...                password=oZPS0POrRieRtu
    run keyword and ignore error    SSHLibrary.Execute Command    rm -rf .ssh/known_hosts
    run keyword and ignore error    SSHLibrary.Write    ${cmd1}
    FOR  ${ip}  IN  @{ips}
        SSHLibrary.Write    ssh -o StrictHostKeyChecking=no root@${ip}
        Sleep  2s
        SSHLibrary.Write    rad -mw 0x110032 ${Voltage}
        Sleep  2s
        SSHLibrary.Write    exit
        Sleep  2s
    END
    Log   Set RU voltage complete!

KW.check RU voltage
    [Arguments]   ${objects}=[RMOD/RMOD_R-1]    ${Voltage_T}=53000    ${connection}=GNB_OAM
    wait until keyword succeeds   2min    10s    Connect to gnb coam via ssl    connection=${connection}
    ${measurements}    coam.get_measurements    measurement_type=realTime    connection=${connection}
    @{Voltage_list}    Create List
    FOR  ${measurement}  IN  @{measurements}
        ${key}=    Evaluate    list($measurement.keys())[0]
        @{key1}    Create List    ${key}
        ${status}=    Run Keyword And Return Status
        ...    List Should Contain Sub List    ${objects}    ${key1}
        Continue For Loop If    '${status}' == 'False'
        ${measurement_t}=    Set Variable    ${measurement}
        ${voltage}=    Set Variable    ${measurement_t['${key}']['voltage']}
        Log    ${Voltage}
        ${Voltage_tmp}=    Evaluate    ${Voltage}*1000
        Should Be True    ${Voltage_tmp} >= ${Voltage_T}
        Append To List    ${Voltage_list}    ${voltage}
    END
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    ${length_1}    Get Length    ${objects}
    ${length_2}    Get Length    ${Voltage_list}
    Should Be True    ${length_1} == ${length_2}

KW.gNB.Getgnbtime
    [Arguments]     ${alias}=asik
   run keyword and ignore error    ssh.disconnect    connection=ASIK
   run keyword and ignore error    ssh.disconnect    connection=asik
   wait until keyword succeeds     5min    30sec       ssh.Connect to    ${ASIK_IP}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    ...                alias=${alias}
   ${date}    Get Current Date    result_format=datetime
   ${hour}    set variable  ${date.hour}
   ${minute}    set variable  ${date.minute}
   log to console    ${hour}
   log to console    ${minute}
   gNB.Disconnect
   [Return]     ${hour}      ${minute}

kw.CheckcellinEnergySaving
    [Documentation]   check cell is in EnergySaving state
    [Arguments]   ${CELL_list}    ${status}=energySaving     ${technology}=NR
    FOR  ${cell_idx}   IN   @{CELL_list}
        ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}    technology=${technology}
        log to console    ${cell_info}
        should be true    '${cell_info['Energy saving state']}'=='${status}'
    END

kw.CheckcellinnotEnergySaving
    [Documentation]   check cell is in notEnergySaving state
    [Arguments]   ${CELL_list}    ${status}=notEnergySaving     ${technology}=NR
    FOR  ${cell_idx}   IN   @{CELL_list}
        ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}    technology=${technology}
        log to console    ${cell_info}
        should be true    '${cell_info['Energy saving state']}'=='${status}'
    END

KW.ChangeLowVoltagetoDefaultValue
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login    version=${sbts_stream}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRFSOPGRP-2
    ...    filter_param=Low voltage cell switch off threshold     new_value=48   abbr=lowVoltageCellSwitchOffThr
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRFSOPGRP-2
    ...    filter_param=Low voltage cell switch on threshold	  new_value=50   abbr=lowVoltageCellSwitchOnThr
    COAM_WebEM.ValidateAndActiveParameters    activate_plan_despite_errors=False
    run keyword and ignore error    COAM_WebEM.Logout

##################################           PM Counter            ##################
KW.CheckCounterIsUpdate
    [Documentation]   check Counters which caused by low voltage
    [Arguments]    ${counter_id}    ${full_path}=none
        ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}    full_path=${full_path}
        log    ${res}
        ${values}    get dictionary values   ${res}
        log    ${values}
        log  The latest one is: ${values[-1]}
        ${status}    run keyword and continue on failure    should be true    ${values[-1]}>0

KW.CheckCounterIsNotUpdate
    [Documentation]   check Counters which caused by low voltage
    [Arguments]    ${counter_id}    ${full_path}=none
        ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}    full_path=${full_path}
        log    ${res}
        ${values}    get dictionary values   ${res}
        log    ${values}
        log  The latest one is: ${values[-1]}
        ${status}    run keyword and continue on failure    should be true    '${values[-1]}'=='0'

KW.CB012087.CheckCounter
    [Arguments]    ${id}   ${min}=0   ${max}=10000   ${path}=None
    ${date}   Get Current Date   exclude_millis=True
    ${res}    wait until keyword succeeds    3min    10s    selenium_coam.get_bts_counters_info   counter_id=${id}    full_path=${path}
    ${values}    get dictionary values   ${res}
    log  The counter: ${values}
    should be true    max(${values[-1]}, ${values[-2]}) >= ${min}
    should be true    max(${values[-1]}, ${values[-2]}) <= ${max}
    [Return]    ${values[-1]}


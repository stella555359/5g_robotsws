*** Settings ***
Documentation    author: Hu Caoli
...               contact: caoli.hu@nokia-sbell.com
...               squad group: SG_01
...               feature : CB008967
Library           urllib
Library           String
Library           taf.config.scf                        WITH NAME    scf
Library           taf.transport.ssh		             WITH NAME	  ssh
Library           taf.sbts.oam.coam.admin                WITH NAME    coam
Library           taf.sw.dcap.rd                        WITH NAME    rd
Library           taf.collectors.core   WITH NAME   core
Library           taf.sbts.oam.coam.admin  WITH NAME   admin
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.selenium.sbts   WITH NAME   selenium_sbts
#Library                taf.selenium.sbts                   WITH NAME  selenium_coam
#Library                ReadJason.py
Resource     ../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
#Resource     ../../../OAM/RAN_PZ_HAZ_34/None_Feature_SG1/OAM_Interface.robot
#Resource     ../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
#Resource     ../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource     ../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG1/OAM_Interface.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
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
${counter_full_path}   EQM-1/APEQM-1/RMOD-1/FAN-1/SBTS_RMOD_FAN/SBTS_RMOD_MAX_FANSPEED

*** Keywords ***
TC.CB008967_SR_E_SBTS_SFP_SM_AVG_TEMPERATURE
    [Documentation]
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: Login WebEM online modify mtSBTSSfpSMOD to enable SMOD SFP AVG counter
    ...    Step2: Check counter for SMOD SFP AVG counter M40006C2 after waiting for one reporting interval
    ...    Checkpoint configuration:
    log to console    Step1: Login WebEM online modify mtSBTSSfpSMOD to enable SMOD SFP AVG counter
    KW.EnableSMODSFPAVGTEMP
    log to console    Step2: waiting for one reporting interval
    sleep    16min
    log to console    Step3: Check counter for SMOD SFP AVG counter M40006C2
    @{BTS_COUNTER}    Create List    M40006C2
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    KW.FetchCounter    ${BTS_COUNTER}
    run keyword and ignore error    COAM_WebEM.Logout


TC.CB008967_SR_I_AEHC_SBTS_RMOD_MAX_FANSPEED_activation_deactivation
    [Documentation]
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: Login WebEM online modify mtSBTSRMODFan to enable SBTS RMOD MAX FANSPEED Counter
    ...    Step2: Check counter for SBTS RMOD MAX FANSPEED Counter M40030C1 after waiting for one reporting interval
    ...    Checkpoint configuration:
    log to console    Step1: Login WebEM online modify mtSBTSRMODFan to enable SBTS RMOD MAX FANSPEED Counter
    KW.EnableRMODMAXFANSPEED
    log to console    Step2: waiting for one reporting interval
    sleep    6min
    log to console    Step3: Check counter for SBTS RMOD MAX FANSPEED Counter M40030C1
    @{BTS_COUNTER}    Create List    M40030C1
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    ${BTSNAME}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}     filter_param=BTS name     abbr=btsName
    set test variable      ${BTSNAME}
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    KW.FetchCounter    counter_list=${BTS_COUNTER}     full_path=[${BTSNAME}] ${MRBTS_ID}/${counter_full_path}
    run keyword and ignore error    COAM_WebEM.Logout


TC.CB008967-SR-B_8_fault 4792_ EFaultId_CabinetLowTempViolationAl-deactivation_Dualcore
    [Documentation]
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: Login WebEM online modify actCabiTempMonAlarms from false to true and modify tempLowOffset vlaue to 35
    ...    Step2: check fault 4792 reported or not;
    ...    Step3: modify FMCADM/actCabiTempMonAlarms from true to false;
    ...    Step4: check fault 4792 cancelled or not;
    log to console    Step1:Login WebEM online modify FMCADM/actCabiTempMonAlarms from false to true
    KW.EnableCABTEMPALARM
    log to console    Step2: check fault 4792 reported or not
    AlarmWatchdog.add_allow_alarms    fault_id=4792
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    wait until keyword succeeds    3min    1s    KW.CheckAlarmFor_fault_4792
    run keyword and ignore error    COAM_WebEM.Logout
    log to console    Step3: modify FMCADM/actCabiTempMonAlarms from true to false
    KW.DeactCABTEMPALARM
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    ${status}    Run Keyword And Return Status    KW.CheckAlarmFor_fault_4792
    COAM_WebEM.Logout
    AlarmWatchdog.remove_allow_alarms    fault_id=4792
    Should not be true    ${status}
    run keyword and ignore error    COAM_WebEM.Logout


TC.CB008967-SR-F_1_Exploratory_Testing
    [Documentation]
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: Login WebEM online modify actKpiAlarms from false to true
    ...    Step2: check fault 4569 reported or not;
    ...    Step3: modify actKpiAlarms from true to false;
    ...    Step4: check fault 4569 cancelled or not;
    log to console    Step1:Login WebEM online modify actKpiAlarms from false to true
    KW.EnablekpiALARM
    log to console    Step2: check fault 4569 reported or not
    AlarmWatchdog.add_allow_alarms    fault_id=4569
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    wait until keyword succeeds    3min    1s    KW.CheckAlarmFor_fault_4569
    run keyword and ignore error    COAM_WebEM.Logout
    log to console    Step3: modify actKpiAlarms from true to false
    KW.DeactkpiALARM
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    ${status}    Run Keyword And Return Status    KW.CheckAlarmFor_fault_4569
    COAM_WebEM.Logout
    AlarmWatchdog.remove_allow_alarms    fault_id=4569
    Should not be true    ${status}
    run keyword and ignore error    COAM_WebEM.Logout

KW.EnablekpiALARM
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate KPI Alarms
    ...    new_value=true
    CM_WebEM.ValidateAndActiveParameters
    run keyword and ignore error    COAM_WebEM.Logout


KW.DeactkpiALARM
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate KPI Alarms
    ...    new_value=false
    CM_WebEM.ValidateAndActiveParameters
    run keyword and ignore error    COAM_WebEM.Logout

KW.EnableCABTEMPALARM
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...    filter_param=Activate cabinet ambient temperature monitoring alarms
    ...    new_value=true
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1
    ...    filter_param=Low ambient temperature threshold offset
    ...    new_value=35
    CM_WebEM.ValidateAndActiveParameters
    run keyword and ignore error    COAM_WebEM.Logout

KW.DeactCABTEMPALARM
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...    filter_param=Activate cabinet ambient temperature monitoring alarms
    ...    new_value=false
    CM_WebEM.ValidateAndActiveParameters
    run keyword and ignore error    COAM_WebEM.Logout

KW.CheckAlarmFor_fault_4569
    ${all_alarm}    selenium_coam.get_active_alarm_info
    log     ${all_alarm}
    ${alarm_info}    selenium_coam.get_active_alarm_info  alarm_filter=4569
    should not be empty    ${alarm_info}



KW.CheckAlarmFor_fault_4792
    ${all_alarm}    selenium_coam.get_active_alarm_info
    log     ${all_alarm}
    ${alarm_info}    selenium_coam.get_active_alarm_info  alarm_filter=4792
    should not be empty    ${alarm_info}

KW.EnableRMODMAXFANSPEED
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
#    run keyword and ignore error    selenium_sbts.remove_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
#    run keyword and ignore error    CM_WebEM.ValidateAndActiveParameters
#    selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1
#    ...    object_class_name=PMMNL  id_value=1    timeout=60    is_load_default_values=true
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1   filter_param=SBTS RMOD Fan Monitoring
    ...    new_value=5min
    CM_WebEM.ValidateAndActiveParameters
     ${pm_interval_org}    COAM_WebEM.GetParameterValue      ${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
     ...    Performance measurement data reporting interval
     run keyword if    '${pm_interval_org}'!='15min'    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
     ...    filter_param=Performance measurement data reporting interval     new_value=15min
     run keyword and ignore error   CM_WebEM.ValidateAndActiveParameters
     run keyword and ignore error    COAM_WebEM.Logout


KW.EnableSMODSFPAVGTEMP
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
#    run keyword and ignore error    selenium_sbts.remove_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
#    run keyword and ignore error    CM_WebEM.ValidateAndActiveParameters
#    selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1
#    ...    object_class_name=PMMNL  id_value=1    timeout=60    is_load_default_values=true
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1   filter_param=SBTS SFP SMOD
    ...    new_value=15min
    CM_WebEM.ValidateAndActiveParameters
     ${pm_interval_org}    COAM_WebEM.GetParameterValue      ${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
     ...    Performance measurement data reporting interval
     run keyword if    '${pm_interval_org}'!='15min'    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
     ...    filter_param=Performance measurement data reporting interval     new_value=15min
     run keyword and ignore error   CM_WebEM.ValidateAndActiveParameters
     run keyword and ignore error    COAM_WebEM.Logout


CM_WebEM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan


#COAM_WebEM.GetParameterValue
#    [Arguments]    ${distName}=MRBTS-1969    ${abbr}=BTS name
#    ${value}   Wait Until Keyword Succeeds    3 times    30s
#    ...    selenium_coam.get_parameter_value    dist_name=${distName}    filter_param=${abbr}
#    [Return]       ${value}


KW.FetchCounter
    [Arguments]    ${counter_list}    ${full_path}=none
    FOR  ${counter_id}  IN  @{counter_list}
        ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}    full_path=${full_path}
#        ...   timeout_for_loading_available_counters=180
        log    ${res}
        ${values}    get dictionary values   ${res}
        log    ${values}
        log  The latest one is: ${values[-1]}
#        ${status}    run keyword and continue on failure    should be true    ${values[-1]}>0
#        ${case_status}    run keyword if    '${status}'=="None"
#        ...    set variable    pass
#        ...    ELSE    set variable    fail
#        AppendCaseResultToFile    requirement_id=${counter_id}    target_value=NA    result_value=${values[-1]}    case_result=${case_status}
        should be true    ${values[-1]}>0
        should be true    ${values[-1]}<100
    END

AppendCaseResultToFile
    [Arguments]   ${requirement_id}=NA    ${index}=NA    ${ru_type}=NA    ${ru_index}=NA
    ...           ${target_value}=NA   ${result_value}=NA    ${case_result}=NA
    ${check_kpi_value}    run keyword if
    ...    '${result_value}'!='NA' and '${target_value}'!='NA' and ${result_value}<=${target_value} and ${result_value}>${0}
    ...    set variable    pass
    ...    ELSE    set variable    fail

    ${data}    run keyword if    '${case_result}'!='NA'
    ...   Catenate    SEPARATOR=,    ${TEST NAME}    ${requirement_id}    ${index}    ${ru_type}
    ...   ${ru_index}    ${target_value}    ${result_value}    ${case_result}\n
    ...   ELSE    Catenate    SEPARATOR=,    ${TEST NAME}    ${requirement_id}    ${index}    ${ru_type}
    ...   ${ru_index}    ${target_value}    ${result_value}    ${check_kpi_value}\n

    Append To File    ${case_result_save_path}    ${data}

KW.ResetSite
    Set Test Variable    ${GnbReset}    True
    COAM_WebEM.Login    version=${sbts_stream}
    ${status}    Run Keyword And Return Status    selenium_coam.reset_site
    should be true    ${status}
    sleep    60s
    ${status}    Run Keyword And Return Status    KW.ConnectDualCoreBySSH
    Should not be true    ${status}
    COAM_WebEM.Login    version=${sbts_stream}
    Wait Until Keyword Succeeds    20min    1min    COAM_Admin.CheckAllCellsOnair     type=both
#    COAM_WebEM.Logout
    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
#    wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair     type=lte
#COMMON SETUP AND TEARDOWM

KW.ConnectDualCoreBySSH
    [Documentation]   ssh to the given IP with username and password
    @{ipList}    Create list    ${LMP_Primary}    ${ASIK_IP_Mplane}
    FOR    ${ip}    IN     @{ipList}
        ssh.Connect to    ${ip}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=tmpConn
        ssh.disconnect    connection=tmpConn
    END

KW.GetAndCheckAlarm
    @{Fault_whitelist}    Create list    4655   4654   61524   61652   4459    4681   7312
    Run Keyword if   '${GnbReset}' == 'True'    append to list    ${Fault_whitelist}    4592
#    COAM_WebEM.Login
    ${active_alarm}    selenium_coam.get_active_alarm_info
    log    ${active_alarm}
    ${history_alarm}    selenium_coam.get_history_alarm_info
    log    ${history_alarm}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    FOR    ${item}    IN    @{history_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...   append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    ${alarm_result}=    run keyword and return status    should be empty    ${unexpect_fault}
    COAM_WebEM.Logout
    [Return]    ${alarm_result}


Setup Suite
    log to console    \n***SISO Coam Suite Setup***
    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
    ...    ELSE     UTECloud.AdaptCommissionFiles
    TestSuite.Start
    ${res}    Run Keyword And Ignore error    gNB.GenerateTestLineSCFs
#	${res}    Run Keyword And Ignore error    gNB.Generate TL SCF
#	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
#	...                  TestLineSCF_cell_num=${2}    cell_type=Both
#	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}

	Set Suite Variable    ${Dula_core_base_scf}    ${LOG_PATH}/TestLineSCF2Cell.xml

    run keyword if    '${res[0]}'=='PASS'
    ...      gNB.Commission   scf_file=${LOG_PATH}/TestLineSCF2Cell.xml
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${stream}   ${subversion}    Split String   string=${Active_SW_version}   separator=_     max_split=1
    ${stream}    set variable if   '${stream}'>='SBTS22R2'    SBTS22R2    SBTS21B
    set suite variable    ${sbts_stream}    ${stream}

    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}


Teardown Suite
    log to console    \n***SISO Coam Suite Teardown***
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}
#    ...    Commission    ${CFGFILE_PATH}/SCF_CB007475.xml
    ${cells_status}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair    type=both
#    ${cells_status_LTE}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=lte
    run keyword if    '${cells_status}'=='False'    run keyword and ignore error    KW.ResetSite

    TestSuite.Stop


Setup case
    log to console    \n***SISO Coam Test Setup***
    log to console    Active_SW_version:${Active_SW_version}
    TestCase.Start
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${cells_status}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=both
#    ${cells_status_LTE}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=lte
    run keyword if    '${cells_status}'=='False'   run keyword and ignore error    KW.ResetSite
    Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}    Fail    TEST
#    ...    Commission
#    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser

Setup case after common setup
    log to console    \n***SISO Coam Test Setup***
    log to console    Active_SW_version:${Active_SW_version}
    CI_interface.Common Case Setup
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${cells_status}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=both
#    ${cells_status_LTE}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=lte
    run keyword if    '${cells_status}'=='False'   run keyword and ignore error    KW.ResetSite
    Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}    Fail    TEST
#    ...    Commission
#    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser

Teardown case
    log to console    \n***SISO Coam Test Teardown***
    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    Connect to gnb coam via ssl
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Run Keyword And Ignore error    gNB.CollectSnapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
#    Connect to gnb coam via ssl
#    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
#    log to console  RU status: ${ru_status}
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    should be true    ${cell_status}
#    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
#    should be true    ${alarm_status}
#    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
#    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
#    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
#    run keyword if test failed     Collect Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Conn.ResetCache
#    CI_interface.Common Case Teardown
    TestCase.Stop

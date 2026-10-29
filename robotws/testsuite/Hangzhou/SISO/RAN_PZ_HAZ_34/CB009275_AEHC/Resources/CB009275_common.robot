*** Settings ***
Documentation    This is for feature CB009275 related common keywords.
...              Please do not modify the file without notification to author
...              Author:stella.lin@nokia-sbell.com
...              Squard: HZ SG6

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Library     taf.selenium.sbts   WITH NAME   selenium_sbts
Variables    TestCase_Variables.py

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
@{SWCONFIG_11039}   0x190418=1


*** Keywords ***
02_CB009275_Feature_Enable_with_Fault_1932_actived
    [Arguments]    ${ru_index}=1
    ${fans_name}    Set Variable If    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'    tcs_fans.bin    fans.bin
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    ${stream_version}    Get Active SW Version Based On Stream Version
    Update Parameter actRadioFanFailureEarlyNotif
    Comment     #--- STEP0: login RU ---#
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    Comment     #--- STEP1: generate fans.json file ---#
    ${localhost_login}    Set Variable    ${sudo} frmonShellClient localhost 2000
    ${cmd}   Set Variable  echo '/ action create ConfigAccess /CI/ConfigAccess_Module /module'|${localhost_login}
    ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=${cmd}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/ConfigAccess_Module action fetch DECODED "${fans_name}" "/ram/fans.json"'|${localhost_login}
    ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=${cmd}
    Should Contain    ${output}    done ok
    sleep    2s
    Comment     #--- STEP2: modify fans.json file ---#
    ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=${sudo} cat /ram/fans.json
    ${fanTestRpmMin}    Set Variable If    '${stream_version}'=='23R3'    1500    2100
    ${fanDetectionPeriod}    Set Variable If    '${stream_version}'=='23R3'    305000    60000
    ${fanTestPeriod}    Set Variable If    '${stream_version}'=='23R3'    300000    30000
    ${cmd}    Set Variable    ${sudo} sed -i 's/"fanTestRpmMin": 1800,/"fanTestRpmMin": ${fanTestRpmMin},/g' /ram/fans.json
    ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=${cmd}
    sleep    1s
    ${cmd}    Set Variable    ${sudo} sed -i 's/"fanTestPeriod": 30000,/"fanTestPeriod": ${fanTestPeriod},/g' /ram/fans.json
    ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=${cmd}
    sleep    1s
    ${cmd}    Set Variable    ${sudo} sed -i 's/"fanDetectionPeriod": 3600000,/"fanDetectionPeriod": ${fanDetectionPeriod},/g' /ram/fans.json
    ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=${cmd}
    sleep    1s
    Comment    #---  STEP3: update config to RU ---#
    ${cmd}   Set Variable    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "${fans_name}" "/ram/fans.json"'|${localhost_login}
    ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=${cmd}
    Should Contain    ${output}    done ok
    sleep    2s
    Comment    #---  STEP4: reboot RU ---#
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM_RU    gnb_index=${0}
    coam.reset_unit    dist_name=MRBTS-299/EQM-1/APEQM-1/RMOD-1    force_radio_reset=${True}    timeout=${1200}    connection=GNB_OAM_RU
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM_RU
    Sleep    240s
    Comment    #---  STEP4: Wait For RU On and check 1932 alarm report on RMOD ---#
    Run Keyword And Continue On Failure    Wait RU On and check 1932 alarm report
    Comment    #---  STEP5: Update param actRadioFanFailureEarlyNotif to true ---#
    Update Parameter actRadioFanFailureEarlyNotif    status=true
    Comment    #---  STEP4: Wait For RU On and check 1932 alarm report on FAN-1 and FAN-2 ---#
    Wait RU On and check 1932 alarm report    alarm_source=RMOD_R-1/FAN_R-1    severity=Warning
#    Wait RU On and check 1932 alarm report    alarm_source=RMOD_R-1/FAN_R-2    severity=Warning
    Comment    #---  STEP5: Update param actRadioFanFailureEarlyNotif to false ---#
    Update Parameter actRadioFanFailureEarlyNotif
    Comment    #---  STEP4: Wait For RU On and check 1932 alarm report on RMOD ---#
    Wait RU On and check 1932 alarm report
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Common_keywords.Collect Snapshot Log    AND
    ...                           FAN Recovery And Check 1932 Disappeared

FAN Recovery And Check 1932 Disappeared
    [Arguments]    ${ru_index}=1
    Log To Console    \n***start to recovery ru***
    ${fans_name}    Set Variable If    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'    tcs_fans.bin    fans.bin
    csn.reset_cache
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}

    ${cmd}   Set Variable  echo '/ action create ConfigAccess /CI/ConfigAccess_Module /module'|${sudo} frmonShellClient localhost 2000
    ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=${cmd}
    Should Contain    ${output}    done ok

    ${cmd}   Set Variable  echo '/CI/ConfigAccess_Module action delete "${fans_name}"'|${sudo} frmonShellClient localhost 2000
    ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=${cmd}
    Should Contain    ${output}    done ok

    ${cmd}   Set Variable  echo '/CI/ConfigAccess_Module action terminate'|${sudo} frmonShellClient localhost 2000
    ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=${cmd}
    Should Contain    ${output}    done ok

    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM_RU    gnb_index=${0}
    coam.reset_unit    dist_name=MRBTS-299/EQM-1/APEQM-1/RMOD-1    force_radio_reset=${True}    timeout=${1200}    connection=GNB_OAM_RU
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM_RU
    Sleep    240s
    Comment    #--- Wait For RU On and check 1932 alarm Disappeared ---#
    Connect to gnb coam via ssl
    Wait until keyword succeeds    20min    20 sec    COAM Check GNB RU status
    Wait until keyword succeeds    20min    20 sec    Verify all cells should be onair
    Wait until keyword succeeds    3min    20 sec    Expect Fault Should Absent    faultId=1932
    [Teardown]    Run keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_${ru_index}    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

Wait RU On and check 1932 alarm report
    [Arguments]    ${alarm_source}=RMOD_R-1
#    ...            ${availabilitystatus}=failed
    ...    ${severity}=Minor
    Log To Console    \n***start to check 1932 appear***
    Connect to gnb coam via ssl
    Wait until keyword succeeds    20min    20 sec    COAM Check GNB RU status
    Wait until keyword succeeds    20min    20 sec    Verify all cells should be onair
    Wait until keyword succeeds    10min    10 sec    Expect Fault Should Present    faultId=1932
    ...   source=[SG6_SA_TL299_9275] MRBTS-299/EQM_R-1/APEQM_R-1/${alarm_source}
    ...    severity=${severity}
    Wait until keyword succeeds    10min    5 sec    Expect Fault Should Present    faultId=1932
    ...   source=[SG6_SA_TL299_9275] MRBTS-299/EQM_R-1/APEQM_R-1/RMOD_R-2
    ...    severity=${severity}
#    Run Keyword And Continue On Failure    Check RU FAN Availability Status    availabilitystatus=${availabilitystatus}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Update Parameter actRadioFanFailureEarlyNotif
    [Arguments]    ${status}=false
    Log To Console    \n***start to update actRadioFanFailureEarlyNotif to ${status}***
    ${actRadioFanFailureEarlyNotif}    catenate   {'dist_name': 'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1',
    ...    'parameter':'actRadioFanFailureEarlyNotif','value':'${status}'}
    ${actRadioFanFailureEarlyNotif_update}     evaluate    [${actRadioFanFailureEarlyNotif}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${actRadioFanFailureEarlyNotif_update}

Check RU FAN Availability Status
    [Arguments]    ${availabilitystatus}=failed
    ${bts_info}    coam.get_bts_info    connection=GNB_OAM
    Log    ${bts_info}
    ${availabilitystatus_fan_1}    set variable    ${bts_info['radioModules']['rmod'][0]['fanStatus']['fans'][0]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_1}    ${availabilitystatus}
    ...    msg=FAN_1 should be in vailabilitystatus <not installed>,actual is <${availabilitystatus_fan_1}>
    ${operationalstate_fan_1}    set variable    ${bts_info['radioModules']['rmod'][0]['fanStatus']['fans'][0]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_1}    disabled
    ...    msg=FAN_1 should be in operationalstate <not installed>,actual is <${availabilitystatus_fan_1}>
    ${availabilitystatus_fan_2}    set variable    ${bts_info['radioModules']['rmod'][0]['fanStatus']['fans'][1]['stateInfo']['availabilityStatus']}
    should be equal    ${availabilitystatus_fan_2}    ${availabilitystatus}
    ...    msg=FAN_1 should be in vailabilitystatus <not installed>,actual is <${availabilitystatus_fan_1}>
    ${operationalstate_fan_2}    set variable    ${bts_info['radioModules']['rmod'][0]['fanStatus']['fans'][1]['stateInfo']['operationalState']}
    should be equal    ${operationalstate_fan_2}    disabled
    ...    msg=FAN_1 should be in operationalstate <not installed>,actual is <${availabilitystatus_fan_1}>

CB008990-SR-01_Ecpri_RU_Beamer_Beamer_link_fault_activation
    [Arguments]    ${ru_index}=1
    Create Case Log Path
    Run Keyword And Ignore Error    Enable capture soap log
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    Update Parameter recoveryResetDelay
    Sleep    4min
    Comment     #--- STEP0: login RU ---#
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    Comment     #--- STEP1: arb0p4 down ---#
    Log To Console    \n***start to down arb0p4***
    csn.Send command  command=sudo su    connection=RU_${ru_index}
    ${arb0p4_down_cmd}    csn.execute    command=sudo ifconfig arb0p4 down    connection=RU_${ru_index}
    Comment     #--- STEP2: check arb0p4 port not exist ---#
    ${output}    csn.execute    command=ifconfig    connection=RU_${ru_index}
    Should Not Contain    ${output}   arb0p4   msg=arb0p4 is not down successfully
    Comment     #--- STEP3: check 1103 in fault history log  ---#
    Wait Until Keyword Succeeds    5min   5s    Check 1103 In Fault History Log    connection=RU_${ru_index}
    Comment     #--- STEP4: check 1904 in webui ---#
    Log To Console    \n***start to check 1904 appear***
    Connect to gnb coam via ssl
    Wait until keyword succeeds    5min    3s    Expect Fault Should Present    faultId=1904
    ${allowed_fault_1904}    Create Dictionary    faultId=${1904}
    ${allowed_fault_7313}    Create Dictionary    faultId=${7313}
    ${add_allowed_list}    Create List    ${allowed_fault_1904}    ${allowed_fault_7313}
    ${allowed_faults_list}    Combine Lists    ${ALLOWED_FAULT}    ${add_allowed_list}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults_list}
    ...    connection=GNB_OAM
    Run Keyword And Continue On Failure    should be true    ${alarm_status}
    Wait until keyword succeeds    20min    20 sec    COAM Check GNB RU status
    Wait until keyword succeeds    20min    20 sec    Verify all cells should be onair
    csn.reset_cache
    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_${ru_index}
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    Download SOAP Log For 8990
    ${path_prefix}    Set Variable    ${SOAP_LOG_PATH.split('RU')[0]}
    ${arb0p4_ru_soap_file_path}    Join Path    ${path_prefix}    arb0p4_ru_soap.xml
    copy file    ${SOAP_LOG_PATH}    ${arb0p4_ru_soap_file_path}
    Connect to gnb coam via ssl
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults_list}
    ...    connection=GNB_OAM
    Run Keyword And Continue On Failure    should be true    ${alarm_status}
    ${ue_type}    translate_power_ue_type_from_testline
    Set Test Variable    ${ue_type}
    Procedures.UE Prepare    ue_type=${ue_type}
    ${attach_info}    Procedures.UE Attach    wireshark_log_prefix=ca_attach
    ...                                       ue_type=${ue_type}
    ...                                       sleep_interval=45 sec
    ...                                       4G_check=${False}
    Start L3 Call Data Transfer    ul_data_transfer=150M
    ...                            dl_data_transfer=1500M
    ...                            duration=600
    ...                            need_get_ue_ip=${True}
    ...                            cpif_log_path=${attach_info['cpif_log_path']}
    ...                            ue_iperf_path=/data/local/tmp/iperf
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=90
    ...                                                                expect_ul_tput=120
    ...                                                                expect_dl_tput=1400
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.20
    ...                                                                ue_type=${ue_type}
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    [Teardown]    Run keywords    Update Parameter recoveryResetDelay    value=180    AND
    ...    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_${ru_index}    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master   AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${0}    iperf_port=${UL_PORT}  AND
    ...    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}   AND
    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Update Parameter recoveryResetDelay
    [Arguments]    ${value}=0
    Log To Console    \n***start to update recoveryResetDelay to ${value}***
    ${recoveryResetDelay}    catenate   {'dist_name': 'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1',
    ...    'parameter':'recoveryResetDelay','value':'${value}'}
    ${recoveryResetDelay_update}     evaluate    [${recoveryResetDelay}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${recoveryResetDelay_update}

Check 1103 In Fault History Log
    [Arguments]    ${connection}=RU_1
    ${1103_cmd}    Set Variable    cat /ram/fault_history_log_temp.txt | grep -a "1103" | grep -a "active"| grep -a "critical"| grep -av grep
    ${output}    csn.execute    command=${1103_cmd}    connection=${connection}
    Should Not Be Empty    ${output}    msg=1103 is not triggered

CB011039-A_01_Radio_Module_fail_safe_mode_fault_activation
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${testline_alarm}=[SG6_SA_TL299_9275] MRBTS-299
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    ${stream_version}    Get Active SW Version Based On Stream Version
    Set Test Variable    ${stream_version}
    Enable fail safe mode
    Wait RU On and check 2934 alarm report    ru_index=${ru_index}    testline_alarm=${testline_alarm}
    Check Whether RFSW Log Include In Snapshot
    ${status}    Run Keyword And Return Status    Case_11039_Diagnostic_Check    checkPoints=${Case_11039_CheckPoint_OK}
    Run Keyword If   not ${status}    Case_11039_Diagnostic_Check    checkPoints=${Case_11039_CheckPoint_OK}
    Case_11039_Trigger_RU Input_Voltage_High
    ${status1}    Run Keyword And Return Status    Case_11039_Diagnostic_Check    checkPoints=${Case_11039_CheckPoint10_NOK}
    Run Keyword If   not ${status1}    Case_11039_Diagnostic_Check    checkPoints=${Case_11039_CheckPoint10_NOK}
    Check 2919 alarm report
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    [Teardown]    RU Recovery And Check 2934 Disappeared    ru_index=${ru_index}

Wait RU On and check 2934 alarm report
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}    ${testline_alarm}=[TL271_Both_2089_42] MRBTS-10107
    Log To Console    \n***start to check 2934 and appear***
    Connect to gnb coam via ssl
    Wait until keyword succeeds    5min    20 sec    Expect Fault Should Present    faultId=2934
    ...   source=${testline_alarm}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Check 2919 alarm report
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}
    Log To Console    \n***start to check 2919 and appear***
    Connect to gnb coam via ssl
    Wait until keyword succeeds    5min    20 sec    Expect Fault Should Present    faultId=2919
    ...   source=[SG6_SA_TL299_9275] MRBTS-299/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Check Whether RFSW Log Include In Snapshot
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}=1
    ${prefix_name}    Set Variable If    '${stream_version}'=='25R1'    BTS    BTS${MRBTS_ID}
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    Verify RFSW Log Include In Snapshot    ru_index=${ru_index}    ru_alias=RU_${ru_index}    prefix_name=${prefix_name}
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_${ru_index}    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

Capture The RU Logs For Compare
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${log_path}=${TS_CASE_LOG_PATH}
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${log_on_ru}   Get RFSW Log File List On RU   connection=RU_${ru_index}    download_dir=${log_path}
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_${ru_index}    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

Enable fail safe mode
    [Arguments]    ${ru_index}=1
    Log To Console    \n***start to Enable fail safe mode***
    csn.reset_cache
    Comment     #--- STEP1:  Enable fail safe mode---#
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${localhost_login}    Set Variable    ${sudo} frmonShellClient localhost 2000
    ${cmd}   Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Run Keyword And Ignore Error    Should Contain    ${output}    done ok
    Sleep    2s
    ${cmd}   Set Variable  echo '/CI/resetControl/module action enable_fail_safe_mode'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    5s
    Perform RU Reset    ru_index=${ru_index}
    sleep   5m
    csn.reset_cache
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_${ru_index}    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

RU Recovery And Check 2934 Disappeared
    [Arguments]    ${ru_index}=1
    Case_11039_Trigger_RU Input_Voltage_High    ru_index=${ru_index}    vol_value=0
    Log To Console    \n***start to Disable fail safe mode***
    csn.reset_cache
    Comment     #--- STEP1:  Reset RU---#
    Perform RU Reset    ru_index=${ru_index}
    Sleep    5m
    Log To Console    \n***start to check 2934 and disappear***
    Comment     #--- STEP2: check the RU not in fail safe mode---#
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${localhost_login}    Set Variable    ${sudo} frmonShellClient localhost 2000
    ${cmd}   Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/resetControl/module get fail_safe_mode'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok ACTIVE
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/resetControl/module action disable_fail_safe_mode'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    ${cmd}   Set Variable  sudo rm -rf /mnt/runtime/rfsw/uoam/fail_safe_mode
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Perform RU Reset    ru_index=${ru_index}
    Sleep    5m
    csn.reset_cache
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl
    Wait until keyword succeeds    10min    20 sec    COAM Check GNB RU status
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${localhost_login}    Set Variable    ${sudo} frmonShellClient localhost 2000
    ${cmd}   Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/resetControl/module get fail_safe_mode'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok INACTIVE
    ${cmd}   Set Variable  sudo rm -rf /mnt/runtime/rfsw/uoam/fail_safe_mode
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Perform RU Reset    ru_index=${ru_index}
    Wait until keyword succeeds    20min    20 sec    Verify all cells should be onair
    Wait until keyword succeeds    3min     20 sec    Expect Fault Should Absent    faultId=2934
    Wait until keyword succeeds    3min     20 sec    Expect Fault Should Absent    faultId=2919
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_${ru_index}    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

CNI-109465-A_01_SOC SW log collection needs to be added to RU Snapshots
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${timeout}=${1800}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    Comment     #--- STEP1:  Reset RU---#
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl
    Perform RU Reset    ru_index=${ru_index}
    Sleep    5min
    csn.reset_cache
    Comment     #--- STEP2:  Waiting cells on air---#
    Connect to gnb coam via ssl
    Wait until keyword succeeds    20min    20 sec    COAM Check GNB RU status
    Wait until keyword succeeds    20min    20 sec    Verify all cells should be onair
    Comment     #--- STEP3:  Capture snapshot log---#
#    Capture The RU Logs For Compare
#    Sleep    30sec
    ${snapshot_file_path}    Common_keywords.Collect Snapshot Log    timeout=${timeout}
    Run    mkdir ${TS_CASE_LOG_PATH}/Snapshot/
    ${snapshot}     Set Variable    ${TS_CASE_LOG_PATH}/Snapshot
    Run    unzip ${snapshot_file_path} -d ${TS_CASE_LOG_PATH}/Snapshot/
    Sleep    60sec
    Run    cat ${snapshot}/snapshot_file_list.txt | grep "part\\|soc_sw_logs" > ${snapshot}/part.txt
    Run    cat ${snapshot}/part.txt | grep -B1 "soc_sw_logs" > ${snapshot}/logpath.txt
    ${log_path2}    Run    cat ${snapshot}/logpath.txt | grep part
    ${log_path2}    Split String    ${log_path2}    \r\n
    ${log_path2}    Split String    ${log_path2[0]}    \n
    ${length}    Get Length    ${log_path2}
    Should Be True    ${length}==${2}    msg=Should be have two basic soc logs.
    FOR    ${log_path2}   IN    @{log_path2}
        ${log_path3}    Fetch From Left    ${log_path2}    :
        Run    unzip ${snapshot}/${log_path3} -d ${snapshot}/Logs_${log_path2}
        ${filename}    Run    ls ${snapshot}/Logs_${log_path2} | grep soc_sw_logs
        ${size}    Run    ls -l ${snapshot}/Logs_${log_path2} | grep soc_sw_logs |awk '{print $5}' |tail -n 1
        Should Be True    ${size}!=0    msg=soc file is empty.
    END
    ${stream_version}    Get Active SW Version Based On Stream Version
    IF    '${stream_version}'=='25R1'
        Verify The SOC SW Logs For 25R1    path=${snapshot}
    ELSE
        Verify The SOC SW Logs    path=${snapshot}
    END
    The Check Point Of CNI-113323    snapshot=${snapshot}
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_${ru_index}    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

The Check Point Of CNI-113323
    [Arguments]    ${snapshot}
    Log To Console    \n*** start to check psu-reg_dumps_filer for CNI-113323 ***
    Run    cat ${snapshot}/snapshot_file_list.txt | grep -i "part\\|psu-reg_dumps" > ${snapshot}/partCNI.txt
    Run    cat ${snapshot}/partCNI.txt | grep -B1 -i "psu-reg_dumps" > ${snapshot}/logpathCNI.txt
    ${CNI_log_path}    Run    cat ${snapshot}/logpathCNI.txt | grep part
    ${CNI_log_name}    Fetch From Left    ${CNI_log_path}    :
    Run    unzip ${snapshot}/${CNI_log_name} -d ${snapshot}/Logs_CNI
    ${CNI_filename}    Run    ls ${snapshot}/Logs_CNI | grep -i psu-reg_dumps
    Run    mkdir ${snapshot}/Logs_CNI/psu-reg_dumps_file
    Run    cp ${snapshot}/Logs_CNI/${CNI_filename} ${snapshot}/Logs_CNI/psu-reg_dumps_file
    Run    cd ${snapshot}/Logs_CNI/psu-reg_dumps_file && gunzip ${CNI_filename}
    ${CNI_file_size}    Run    ls -l ${snapshot}/Logs_CNI/psu-reg_dumps_file | grep -i psu-reg_dumps |awk '{print $5}' |tail -n 1
    Should Be True    ${CNI_file_size}!=0    msg=CNI113323 file is empty.

Case_11039_Check_All_CPs_From_RU_Report
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${RUreport}     ${checkPoints}
	Set Test Variable    ${report}    ${RUreport}
    FOR  ${cp}  IN  @{checkPoints}
        Case_11039_Check_CP_From_RU_Report    checkPoint=${cp}
    END

Case_11039_Check_CP_From_RU_Report
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${checkPoint}
    FOR  ${item}  IN  @{report}
        ${Status}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${item}    ${checkPoint}
        Run Keyword If    ${Status}    Remove Values From List    ${report}    ${item}
		...       ELSE    Continue For Loop
        Exit For Loop
    END

Case_11039_Diagnostic_Check
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${checkPoints}
    ...            ${timeout}=120
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
	${active_version}    coam.get_sw_version    timeout=60    connection=${connection}
	${version_splitted}    Split String    ${active_version}    _
    ${sw_version}    Strip string    ${version_splitted[0]}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}    download_dir=${download_dir}
    ...                    timeout=${timeout}    version=${sw_version}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_screen_lock
    selenium_sbts.start_diagnostic_check   scope=Full diagnostic check    allow_service_impact=${False}    timeout=300
	Sleep    3min
    ${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    Set Variable    ${full_diagnostic_report['RU diagnostic check report']}
    Case_11039_Check_All_CPs_From_RU_Report    RUreport=${RUfullreport}    checkPoints=${checkPoints}
    [Teardown]    Run Keyword And Ignore Error    COAM selenium logout

Case_11039_Trigger_RU Input_Voltage_High
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${vol_value}=57001
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${cmd}    Set Variable    ccsShell.sh rad -mw 0x110032 ${vol_value}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Sleep    30s
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_${ru_index}    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

11039_Case_Teardown
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    Run Keyword And Ignore Error    Do gNB Reset site and Wait Onair

109465_Case_Setup
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    log to console    \n***SISO Coam Test Setup***
    log to console    gNB CU type:${gNb_CuType}
    log to console    Active_SW_version(gNB):${Active_SW_version}
    run keyword if    '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
    ...    Run Keyword And Ignore Error    Log to console    Active_SW_version(eNB):${enb_active_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    log to console  case log path:${TS_CASE_LOG_PATH}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${ru_info}    COAM get all ru detail info    connection=${connection}
    ${ru_value}    get dictionary values    ${ru_info}
    ${ru_info}    Set variable    ${ru_value}[0]
    run keyword and ignore error  should contain  ${TEST_NAME}  ${ru_info}[productName]
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status    connection=${connection}
    ${cell_status}    Run Keyword And Return Status    Check all cells info should be onair    connection=${connection}
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    Commissioning SCF And Check On Air    scf_path=${SCF_Path}    timeout=30
    Run Keyword And Ignore Error    selenium_coam.close_browser

109465_Case_Teardown
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed

Check Logs In Single File
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${path}=${snapshot}    ${filter_name}=pm1_flash_logs
    ${zip_file}    Run    cat ${path}/snapshot_file_list.txt | grep "${filter_name}"
    Run    mkdir ${path}/Logs
    Run    cp ${path}/${zip_file} ${path}/Logs
    Run    cd ${path}/Logs && tar -xf ${zip_file}
    ${soc_size}    Run    ls -l ${path}/Logs | grep soc_sw_logs |awk '{print $5}' |tail -n 1
    Should Be True    ${soc_size}!=0    msg=soc file is empty.

Check Logs In Part Path
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${path}=${snapshot}    ${filter_name}=pm1_flash_logs
    Run    cat ${path}/snapshot_file_list.txt | grep "part\\|${filter_name}" > ${path}/part.txt
    Run    cat ${path}/part.txt | grep -B1 "${filter_name}" > ${path}/logpath.txt
    ${log_path2}    Run    cat ${path}/logpath.txt | grep part
    ${log_path2}    Split String    ${log_path2}    \r\n
    ${log_path2}    Split String    ${log_path2[0]}    \n
    ${log_path3}    Fetch From Left    ${log_path2[0]}    :
    Run    mkdir ${path}/Logs_soc_pm1
    ${output}    Run    unzip ${path}/${log_path3} -d ${path}/Logs_soc_pm1
    ${filename}    Run    ls ${path}/Logs_soc_pm1 | grep ${filter_name}
    Run    cd ${path}/Logs_soc_pm1 && tar -xf ${filename}
    ${size}    Run    ls -l ${path}/Logs_soc_pm1 | grep soc_sw_logs |awk '{print $5}' |head -n 1
    Should Be True    ${size}!=0    msg=soc file is empty.

Verify The SOC SW Logs
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${path}=${snapshot}
    ${filter_list}    Create List    pm1_flash_logs_node0    pm1_flash_logs_node1
    FOR    ${item}    IN    @{filter_list}
        ${zip_file}    Run    cat ${path}/snapshot_file_list.txt | grep ${item}
        ${response}    Get Substring   ${zip_file}    0    3
        IF    '${response}' == 'BTS'
            Check Logs In Single File    path=${path}    filter_name=${item}
        ELSE
            Check Logs In Part Path    path=${path}    filter_name=${item}
        END
    END

Verify The SOC SW Logs For 25R1
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${path}=${snapshot}
    ${zip_file}    Run    cat ${path}/snapshot_file_list.txt | grep "pm1_flash_logs_beamer"
    Run    mkdir ${path}/Logs
    Run    cp ${path}/${zip_file} ${path}/Logs
    Run    cd ${path}/Logs && tar -xf ${zip_file}
    ${1011_soc_size}    Run    ls -l ${path}/Logs/pm1/BEAMER_NODES | grep 1011_soc_sw_logs |awk '{print $5}' |tail -n 1
    ${2011_soc_size}    Run    ls -l ${path}/Logs/pm1/BEAMER_NODES | grep 2011_soc_sw_logs |awk '{print $5}' |tail -n 1
    Should Be True    ${1011_soc_size}!=0    msg=soc file is empty.
    Should Be True    ${2011_soc_size}!=0    msg=soc file is empty.

Download SOAP Log For 8990
    [Documentation]    Author: Stella
    [Arguments]    ${is_right_blade}=${False}
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master0
    Run Keyword If    ${is_right_blade}    csn.connect to
    ...    hostname=fct-4a
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=ASIK Master1
    ...    proxy=ASIK Master0
    ${connection_alias}    Set Variable If    ${is_right_blade}    ASIK Master1    ASIK Master0
    Connect to RU With Allocated IP    ru_alias=RU_1    asik_alias=${connection_alias}
    ${SOAP_LOG_PATH}    Download soap msg from RU Reg For 8990   soap_log=UnitOAM_SOAP_Log*.xml
    ...                                                          log_path=${TS_CASE_LOG_PATH}
    ...                                                          ru_alias=RU_1
    Set Test Variable    ${SOAP_LOG_PATH}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_1    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master1  AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master0

Download soap msg from RU Reg For 8990
    [Documentation]    Author:Wang Yixiang
    ...            Download soap log with regular expression.
    [Arguments]    ${soap_log}=UnitOAM_SOAP_Log*.xml    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_alias}=RU
    ${soap_log_fullpath}    csn.execute    command=ls /ram/${soap_log}    connection=${ru_alias}
    ${soap_log_fullpath}    Strip String    string=${soap_log_fullpath}
    ${soap_log_path}    ${soap_log_name}    split path    ${soap_log_fullpath}
    ${local_path}    Download soap msg from RU For 8990    soap_log=${soap_log_name}    log_path=${log_path}    ru_alias=${ru_alias}
    [Return]    ${local_path}

Download soap msg from RU For 8990
    [Documentation]    Author: Xu Huamin.1
    [Arguments]    ${soap_log}=UnitOAM_SOAP_Log.xml    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_alias}=RU
    csn.Download File    remote_path=/ram/${soap_log}    local_path=${log_path}/${soap_log}    connection=${ru_alias}
    ${cmd_delete_soap_log}    set variable    sudo rm /ram/${soap_log}
    csn.execute    command=${cmd_delete_soap_log}    connection=${ru_alias}
    OperatingSystem.Run    mv '${log_path}/${soap_log}' '${log_path}/${ru_alias}_${soap_log}'
    ${local_path}    set variable    ${log_path}/${ru_alias}_${soap_log}
    [Return]    ${local_path}

SISO Coam Suite Setup For 9275
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0
    run keyword and ignore error    Check And Power on RUs For 9275
    log to console    \n*** SISO Coam Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    ${swconfig_path}    Set Variable    ${CURDIR}/swconfig.txt
    Common_setup_and_teardown.Upload Swconfig File Via LMP    swconfig_path=${swconfig_path}
    Run Keyword And Ignore Error   Add Syslog Flag To Swconfig If Not Exist
    run keyword if     ${if_commissioning}    Run Keyword And Ignore Error   Start Btslog With Path Check
    ${gnb_status}    Run Keyword And Return Status    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    run keyword if    not ${gnb_status}    run keywords
    ...    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api    log_path=${OUTPUT DIR}/Case_Logs    timeout=${600}
    robot_common_operations.Common Suite Setup
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable    ${stream}
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if  not ${gnb_status}   run keywords    Power Reset All RF For 9275    AND
    ...                                                               Upgrade RF Version For Gnb For 9275
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable    ${mrbtsID}
    set suite variable    ${nrbtsID}
    ${ru_type_init}    get_ru_type_from_init    ru_type=${ru_type}
    set suite variable    ${ru_type_init}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    set suite variable    ${suite_setup_fail_flag}    ${False}
    run keyword if     ${if_commissioning}    Run Keyword And Ignore Error  Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}

Check And Power on RUs For 9275
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_numbers}    get length    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    log to console    ru_numbers: ${ru_numbers}
    FOR    ${index}    IN RANGE    0    ${ru_numbers}
        ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.__class__.__name__}
        ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.addr}
        ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.port_no}
        ${ru_index}    evaluate    ${index}+1
        log to console    for ru ${ru_index}, model is ${model}, pb ip is ${address}, pb port is ${port}
        pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_${ru_index}
        ${port_status}    pdu.Get Port Status    port=${port}    pdu_device=pdu_ru_${ru_index}
        log to console    port status of ru ${ru_index} is ${port_status}
        run keyword if    '${port_status}'=='off'    pdu.power on    port=${port}    pdu_device=pdu_ru_${ru_index}
        sleep    5s
    END

Power Reset All RF For 9275
    ${rus}   Set Variable   ${tl.gnbs[0].dus[0].rus}
    ${ru_count}   Get Length   ${rus}
    FOR   ${index}    IN RANGE    ${ru_count}
        ${pb_host}   Set Variable   ${rus[${index}].pdu_port.pdu.addr}
        ${pb_port}   Set Variable   ${rus[${index}].pdu_port.port_no}
        ${pb_model}   Set Variable   ${rus[${index}].pdu_port.pdu.__class__.__name__}
        pdu.setup_pdu    model=${pb_model}   host=${pb_host}   alias=ru_${index}
        pdu.power_off    port=${pb_port}    pdu_device=ru_${index}
        Sleep    5sec
        pdu.power_on    port=${pb_port}    pdu_device=ru_${index}
    END

Upgrade RF Version For Gnb For 9275
    run keyword and ignore error    COAM Teardown gnb connections
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${bts_stream}    ${bts_version}    Split String From Right    ${Active_SW_version}    ENB     1
    ${testline_name}  Get Variable Value    ${testline_name}
    WAIT UNTIL KEYWORD SUCCEEDS    15min    30s    CI_commssion.All Hw Should Be Detected    testline=${testline_name}
    ...                                                                  build=${stream}_ENB${bts_version}    stream=${stream}    ute_env=${True}

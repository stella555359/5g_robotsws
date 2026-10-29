*** Settings ***

Documentation    :copyright: Nokia
...              :authors: ganesha.u@nokia.com
...              :contact: ganesha.u@nokia.com,suresh.babu@nokia.com
...              CB007039 helps to validate Overload Trigger for L2-Hi.
...              Whenever Threshold overcomes the configured value in RADParamter Suspend Streaming will be triggered by L2Hi.
...              Start/Suspend/Stop Streaming will be validated only via Syslog collected.
...              RAD Parameter Used :
...              #7039 rdAvgL2HICPULoadThreshStream default = 95    0x5A00A1=2
...              #7039 rdOvlProtStreamingGuardTimerInterval default = 300 [seconds]     0x5A00A3=300


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../ET_Performance/Performance_keywords.resource
Resource          gNB_TTI_Sharpa_start_and_stop.resource
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Update GNB R&D Parameter
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

Suite Teardown      Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_15.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${rnd_parameter}      0x5A00A1=2;0x5A00A3=300

*** Test Cases ***
[1][1.0] 5GC007039_L2HI_Sherpa_OVL_Indication_Validation_Suspend_State
    ${LOG_PATH}  Set Variable     ${LOG_PATH}
    set test variable      ${LOG_PATH}
    Start Log    btslog    cprt
    Start TTITrace and Sherpa
    log to console   Streaming started
	Sleep  2s  reason=wait to start trace
	Wait Until Keyword Succeeds   5 min   2 sec   Validate activation msg in syslog
    Register Multiple UE and Send the Data     1    15     Traffic_rate=mbps   DL_Rate=8   UL_Rate=2
	Stop TTITrace and Sherpa
	Sleep  2s  reason=wait to stop trace
	Wait Until Keyword Succeeds   5 min   2 sec   Validate deactivation msg in syslog
    Stop Log    btslog    cprt   snapshot    sosreport       test_scenario=Scenario_1
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${rnd_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Register Multiple UE and Send the Data
    [Arguments]   ${Start_UE}    ${MAX_UE}   ${DL_Rate}   ${UL_Rate}   ${Traffic_rate}=mbps
    [Documentation]   Use This keyword to Register multiple UE.. Pass the Arguments StartUE, EndUE, DLRate, ULRate and Traffic_rate
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1
         log to console   UE attach triggering now...${UE}
         UE Register should be Successful     ${UE}
         Trigger DL Data Traffic for SA    ue_id=${UE}     Traffic_rate=${Traffic_rate}   dl_rate=${DL_Rate}      pdu_id=${Pdu_session_ID}
         ...    trf_id=${TRF_ID}
         sleep    1s
         Trigger UL Data Traffic for SA    ue_id=${UE}     Traffic_rate=${Traffic_rate}    ul_rate=${UL_Rate}      pdu_id=${Pdu_session_ID}
         ...    trf_id=${TRF_ID}
         sleep    1s
         BuiltIn.Log    UE Registration Done...${UE}    WARN
		 ${Suspend}    check suspend msg in syslog
         Run keyword if   ${Suspend}==${TRUE}   Run Keywords    Check suspendresp and release ue    ${UE}
         ...    AND    Exit for loop
    END

Validate activation msg in syslog
    ${Reqmsg}   run    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "StreamActivationReq" -m 1
    Builtin.Log   ${Reqmsg}
    ${Req}   Run keyword and return status   Should Not Be Empty    ${Reqmsg}
    ${Respomsg}   Run Keyword if    ${Req}==${TRUE}   run
    ...    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "StreamActivationResp" -m 1
    Should Not Be Empty    ${Respomsg}

Validate deactivation msg in syslog
    ${Reqmsg}   run    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "StreamDeactivationReq" -m 1
    Builtin.Log   ${Reqmsg}
    ${Req}   Run keyword and return status   Should Not Be Empty    ${Reqmsg}
    ${Respomsg}   Run Keyword if   ${Req}==${TRUE}   run
    ...    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "StreamDeactivationResp" -m 1
    Should Not Be Empty    ${Respomsg}

Check suspend msg in syslog
    ${Reqmsg}   run    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "SuspendStreamingReq" -m 1
    Builtin.Log   ${Reqmsg}
    ${Req}   Run keyword and return status    Should Not Be Empty    ${Reqmsg}
    [Return]    ${Req}

Check suspendresp and release ue
    [Arguments]   ${Max_ue}
    ${Respomsg}   run   command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "SuspendStreamingResp" -m 1
	Should Not Be Empty    ${Respomsg}
	Stop Traffic and Dettach Multiple UE    1    ${Max_ue}

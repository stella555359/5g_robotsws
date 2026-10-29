*** Settings ***

Documentation    :copyright: Nokia
...              :authors: manasa.shankarappa@nokia.com
...              :contact: manasa.shankarappa@nokia.com
...              CB008285 covers parity of CB007039 FR1 feature to FR2.
...              CB007039 helps to validate Overload Trigger for L2-Hi.
...              Whenever Threshold overcomes the configured value in RADParamter Suspend Streaming will be triggered by L2Hi.
...              Start/Suspend/Stop Streaming will be validated only via Syslog collected.
...              RAD Parameter Used :
...              #7039 rdAvgL2HICPULoadThreshStream default = 95    0x5A00A1=2
...              #7039 rdOvlProtStreamingGuardTimerInterval default = 300 [seconds]     0x5A00A3=300
...             TEST SET NAME:    CB008285
...             TESTING SPLIT:    Refer CB008285 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008285 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20146



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../ET_Performance/Performance_keywords.resource
Resource         ../CB007039/gNB_TTI_Sharpa_start_and_stop.resource
Resource         ../resources/robot/common_log_collection.robot

Resource         CB008285_Resource.robot


Suite Setup         Run keywords    Run Keyword and Ignore Error      Log to console      "Suite Setup started"
...                 AND     Update GNB R&D Parameter
...                 AND     Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     Log to console    "sleep for 100s"
...                 AND     sleep     100s
...                 AND     Log to console    "starting WTS"
...                 AND     sleep     1s
...                 AND     Start WTS Using WTS_Runner      ${LUA_CFG}


Suite Teardown      Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner


*** Variables ***
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
${r&d_parameter}      0x5A00A1=2;0x5A00A3=300

${LUA_CFG}=                ${CURDIR}/config/A_TC2/15_UE_32_SSB_BASIC_CONFIG_FILE.cfg
${SCFC}=                   ${CURDIR}/config/E_TC1/SCF_Max_tput_GMC.xml
${AP_XML}=                 ${CURDIR}/config/A_TC2/iphy_32SSB_4cell_2CG.xml

*** Test Cases ***
[1]USCB008285-B#B1#CB007039#TC1_L2HI_Sherpa_OVL_Indication_Validation_Suspend_State
    [Tags]     QC_304038
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    btslog    cprt
    Start TTITrace and Sherpa
    log to console   Streaming started
	Sleep  2s  reason=wait to start trace
	Wait Until Keyword Succeeds   5 min   2 sec   Validate activation msg in syslog
    Log to console       "check UE register"
    sleep    10s
    Register Multiple UE and Send the Data     1    130     Traffic_rate=mbps   DL_Rate=8   UL_Rate=2
	Stop TTITrace and Sherpa
	Sleep  2s  reason=wait to stop trace
	Wait Until Keyword Succeeds   5 min   2 sec   Validate deactivation msg in syslog
    Stop Log    btslog    cprt   snapshot    sosreport       test_scenario=Scenario_1
    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
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

*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB013511_A
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
...             Manual Tester: Satoshi Macchi
#-------------------------------------------------------------------------------------------------------------

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/gnb.robot
Resource        ../../../resources/Common/pmcounters.robot
Resource        ../../../resources/Common/snapshot.robot
Resource        ../../../resources/Common/testline.robot
Resource        ../../../resources/Common/tshark.robot
Resource        ../../../resources/Common/ute_workarounds.robot
Resource        ../../../resources/Common/wts_ue.robot

Resource        ../../../resources/Common/alarm_handling.robot
Library         ../../../resources/Common/python/alarm_handling.py   WITH NAME    alarm

Resource        ../../../resources/Common/btslog.robot
Library         ../../../resources/Common/syslog_parser/syslog_parser.py

Resource        ../../resources/SQD60/keywords-tracing.robot

Resource        ../CB013511-common/CB013511-keywords.robot
Resource        ../CB013511-common/CB013511-commissioning.robot
Resource        ../CB013511-common/CB013511-keywords-egate.robot
Resource        ../CB013511-common/CB013511-keywords-wts.robot
Resource        ../CB013511-common/CB013511-counter.robot
Resource        ../CB013511-common/CB013511-keywords-egate-verify.robot
Resource        ../CB013511-common/CB013511-keywords-wireshark.robot
Resource        ../CB013511-common/CB013511-keywords-verify_syslog.robot


Suite Setup       Suite Setup CB013511
Suite Teardown    CB013511-keywords.Suite Teardown CB013511

*** Variables ***

&{SCF}                                &{EMPTY}
${LOGS_COLLECTED}                     False
${DIR_SYSLOG_PARSER}                  ${CURDIR}/../../../resources/Common/syslog_parser

*** Test Cases ***


CB013511_A_SE_TC05_B4_Successful_config_Intrafreq_IntraDU_PSCellchange_MeasProfile_UE_CA_NSA
    [Documentation]    This test case verifies Successful_config_Intrafreq_IntraDU_PSCellchange_MeasProfile_UE_CA_NSA
    ...       :Author: Sylvia Schneider
    [Tags]   t1
    [Setup]  CB013511-keywords.Perform Preconditions Of Test Scenario CB013511

    Prepare Scf And Wts And Egate Logs And Bring Tl On Air
    Save Present Alarms     teststart
    Start Dcap And Wireshark

    Start Syslog

    Attach UE On Cell-1 And Start DL Traffic
    Trigger Sgnb Addition To PSCELL 1 And Get Meas Config
    Trigger Intra-DU HO With Change To PSCell 53
    Get Bearer Stats For DL And Stop Traffic And Detach UE

    Stop Syslog

    Stop Wireshark And Save Egate Log
    Save Present Alarms     testend

    Verify Test Results
    Verify Alarms
    Verify Syslog Trace

    [Teardown]   CB013511-keywords.Perform Postconditions Of Test Scenario CB013511



*** Keywords ***
Suite Setup CB013511
    [Documentation]    [PRIVATE]   Suite Setup CB013511
    ...       :Author: Sylvia Schneider
    CB013511-keywords.Create Test Suite Folders
    ${allGlobalVariables} =    Get Variables
    ${gnb_sw_version}   testline.Fetch Current GNB SW Version    gnb_id=0
    Log To Console   sw version GNB with gnb_id 0: ${gnb_sw_version}
    gnb.Get SCF From GNB With COAM      gnbScfName=SCFC_start.xml   resultConfigDir=${resultBaseDir}   gnb_id=0
    CB013511-keywords.Get Version Mcc Mnc From GNB SCF   ${resultBaseDir}/SCFC_start.xml
    ute_workarounds.UTE Cloud Workaround
    testline.Check TL Infos


Prepare Scf And Wts And Egate Logs And Bring Tl On Air
    [Documentation]    [PRIVATE]    Prepare Scf And Wts And Egate Logs And Bring Tl On Air
    ...       :Author: Sylvia Schneider
    CB013511-keywords-wts.Update Wts File For A_SE_TC05
    CB013511-commissioning.Update SCF A_SE_TC05
    CB013511-keywords-egate.Remove Egate Console Logs
    CB013511-commissioning.Activate SCF And Bring Tl OnAir     TC05


Start Dcap And Wireshark
    [Documentation]    [PRIVATE]    Start Dcap And Wireshark
    ...       :Author: Sylvia Schneider

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.DCAP Tracing Start
    CB013511-keywords-wireshark.Start Wireshark Trace


Stop Wireshark And Save Egate Log
    [Documentation]    [PRIVATE]    Stop Wireshark And Save Egate Log
    ...       :Author: Sylvia Schneider
    CB013511-keywords-wireshark.Stop Wireshark Trace
    CB013511-keywords-egate.Save Egate Logs    save_dir=${resultDir}/egate


Start Syslog
    [Documentation]    [PRIVATE]    Start Syslog
    ...       :Author: Sylvia Schneider
    btslog.Start Btslog


Stop Syslog
    [Documentation]    [PRIVATE]    Stop Syslog
    ...       :Author: Sylvia Schneider
    btslog.Stop Btslog      target_dir=${resultDir}


Save Present Alarms
    [Documentation]    [PRIVATE]    Save Present Alarms
    ...       :Author: Sylvia Schneider
    [Arguments]   ${action}
    IF  '${action}' == 'teststart'
         ${alarms_before_testrun}   alarm_handling.Get All Alarms From Node
         Set Test Variable     ${alarms_before_testrun}
    ELSE
        ${alarms_after_testrun}     alarm_handling.Get All Alarms From Node
         Set Test Variable     ${alarms_after_testrun}
    END


Verify Alarms
    [Documentation]    [PRIVATE]    Verify Alarms
    ...       :Autoor: Sylvia Schneider
    ${cleared_alarms}   ${active_alarms}   alarm.Check For New Alarms
    ...    alarm_list_1=${alarms_before_testrun}
    ...    alarm_list_2=${alarms_after_testrun}
    ...    exclude_active_alarms=alarmId:7115

    alarm_handling.Log Alarm List  ${cleared_alarms}   WARN
    alarm_handling.Log Alarm List  ${active_alarms}    ERROR


Verify Syslog Trace
    [Documentation]    [PRIVATE]    verify syslog trace
    ...       :Autor: Sylvia Schneider
    Log to console   verify syslog
    ${syslog_dir}     Set Variable  ${resultDir}/btslog_gnb0
    ${syslog_files}   OperatingSystem.List Files In Directory  ${syslog_dir}  *.tgz
    ${num_of_files}   Get Length  ${syslog_files}

    ${EXCEPTIONFILE}     Set Variable  ${CURDIR}/../CB013511-common/SYSLOG_EXCEPTION.TXT
    ${ERRORARRAYFILE}    Set Variable  ${DIR_SYSLOG_PARSER}/SYSLOG_ARRAY.TXT
    ${REQUIREMENTFILE}   Set Variable  ${DIR_SYSLOG_PARSER}/SYSLOG_REQUIREMENT.TXT

    ${error_file}=  IF  ${num_of_files}==1
    ...    find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...    ${syslog_dir}/${syslog_files}[0]
    ...    ignorefname=${EXCEPTIONFILE}
    ...    errordeffname=${ERRORARRAYFILE}
    ...    requirementfname=${REQUIREMENTFILE}
    ...    ELSE    Log To Console    No syslog_files.tgz available

    Run Keyword And Warn On Failure          OperatingSystem.File Should Be Empty  ${error_file}


Verify Test Results
    [Documentation]    [PRIVATE]    Verify Test Results
    ...       :Author: Sylvia Schneider
    Run Keyword And Continue On Failure    CB013511-keywords-egate-verify.Verify Egate Logs A_SE_TC05


Attach UE On Cell-1 And Start DL Traffic
    [Documentation]    [PRIVATE]    Attach UE On Cell-1 And Start DL Traffic
    ...       :Author: Sylvia Schneider
    CB013511-keywords-egate.Attach UE 111 On Gnb Cell 1
    CB013511-keywords-egate.Start DL Traffic       ue_id=111


Trigger Sgnb Addition To PSCELL 1 And Get Meas Config
    [Documentation]    [PRIVATE]    Trigger Sgnb Addition To PSCELL 1
    ...       :Author: Sylvia Schneider
    CB013511-keywords-egate.Trigger Sgnb Addition         ue_id=111
    CB013511-keywords-egate.Display Measurement Config    ue_id=111   action=after_sgnbAdd


Trigger Intra-DU HO With Change To PSCell 53
    [Documentation]    [PRIVATE]    Trigger Intra-DU HO With Change To PSCell 53
    ...       :Author: Sylvia Schneider
    Log To Console   Start Intra-DU HO With PSCell Change
    CB013511-keywords-egate.Start Intra-DU HO With PSCell Change    ue_id=111
    CB013511-keywords-egate.Display Measurement Config                ue_id=111   action=after_HO


Get Bearer Stats For DL And Stop Traffic And Detach UE
    [Documentation]    [PRIVATE]    Get Bearer Stats For DL And Ul And Stop Traffic
    ...       :Author: Sylvia Schneider
    CB013511-keywords-egate.Delay   seconds=2    reason=Wait for stable traffic
    CB013511-keywords-egate.Get Bearer Statistics In One Direction   ue_id=111   direction=dl
    wts_ue.Stop Data Traffic In Egate                                ue_id=111   direction=dl
    wts_ue.Detach UE From LTE                                        ue_id=111

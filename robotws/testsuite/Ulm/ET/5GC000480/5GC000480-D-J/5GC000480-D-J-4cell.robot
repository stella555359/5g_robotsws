** Settings ***

Documentation   This is a Robot Test Suite for subfeature 5GC000480-D strong cell
...             on a testline with 4 cells
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
#-------------------------------------------------------------------------------------------------------------
Resource        ../keywordbook-480.robot
Resource        ../../../resources/Common/reporting.robot
Resource         5GC000480DJ-wts.robot
Resource         5GC000480DJ-commissioning-4cell.robot
Resource         5GC000480DJ-keywords.robot
Resource         5GC000480DJ-keywords-4cell.robot
Library          taf.config.wts    WITH NAME    wts

Resource        ../../resources/SQD60/keywords-tracing.robot

Resource        ../../../resources/Common/alarm_handling.robot
Library         ../../../resources/Common/python/alarm_handling.py   WITH NAME    alarm

Resource        ../../../resources/Common/btslog.robot
Library         ../../../resources/Common/syslog_parser/syslog_parser.py


Suite Setup       Suite Setup For 5GC000480-D Testing Strong Cell
Suite Teardown    5GC000480DJ-keywords.Suite Teardown For 5GC000480-D-J Testing


*** Variables ***

${wts_GNB3_X2_ADDR}                   10.0.1.3
${wts_GNB3_S1U_ADDR}                  10.0.1.4

${measurement_period_in_min}          5

${logs_collected}                     False
${dir_syslog_parser}                  ${CURDIR}/../../../resources/Common/syslog_parser


*** Test Cases ***

5GC000480_D_Successful_PSCell_change_with_RAC_and_strongest_neighbor_cell_not_allowed
    [Documentation]    This Test Scenario verifies the counters
    ...                cell1: M55114C00001, M55114C00002, M55114C00003, M55114C00004, M55115C00002, M55115C00003,
    ...                cell2: M55114C00016, M55114C00017, M55114C00018, M55114C00019, M55115C00002, M55115C00003,
    ...                cell3: M55114C00016, M55114C00017, M55114C00018, M55114C00019, M55115C00002, M55115C00003,
    ...                cell4: M55114C00016, M55114C00017, M55114C00018, M55114C00019, M55115C00002, M55115C00003
    [Tags]    strong
    [Setup]    5GC000480DJ-keywords.Perform Preconditions Of Test Scenario

    5GC000480DJ-keywords-4cell.Prepare Counters And Expected Values Strong Cell
    5GC000480DJ-commissioning-4cell.Bring Tl onAir

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Start

    btslog.Start Btslog
    ${alarms_before_testrun}   alarm_handling.Get All Alarms from Node

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval

    5GC000480DJ-keywords-4cell.Attach UE11 On eNB 2 cell 1 And Handover To gNB 2 cell 2
    5GC000480DJ-keywords-4cell.Attach UE12 On eNB 2 cell 1 And Handover To gNB 2 cell 3
    5GC000480DJ-keywords-4cell.Attach UE13 On eNB 3 cell 1 And Handover To gNB 2 cell 4

    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    5GC000480DJ-keywords-4cell.Collect Pm File And Verify Counter Values Strong Cell
    5GC000480DJ-keywords-4cell.Verify String Present In Egate Log Inter Sgnb Handover Is Successful
    5GC000480DJ-keywords-4cell.Verify Wireshark Strong Cell

    ${alarms_after_testrun}   alarm_handling.Get All Alarms from Node
    Verify Alarms    ${alarms_before_testrun}    ${alarms_after_testrun}

    Stop Btslog   target_dir=${resultDir}
    Verify Syslog Trace

    [Teardown]    Perform Postconditions Of Test Scenario



*** Keywords ***

Suite Setup For 5GC000480-D Testing Strong Cell
    [Documentation]    [PRIVATE]    Prepare TL for 5GC000480-D 4 cell
    ...       :Autor: Sylvia Schneider
    Create Ips For Simulated gnb
    keywordbook-480.Create Test Suite Folders
    keywordbook-480.Get Test Variables And Upload Start SCF
    ute_workarounds.UTE Cloud Workaround
    gnb.Store Current SCF From gNB
    5GC000480DJ-keywords.Get Version From gNB SCF
    gnb.Store Current Swconfig From gNB
    wts_ue.Store Current Swconfig From Airphone
    wts_ue.Store Current WTS Config
    5GC000480DJ-keywords-4cell.Update Iphy File
    5GC000480DJ-wts.Update Wts File For TC 480D Strong Cell
    wts_ue.Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_480D_strongCell.cfg
    5GC000480DJ-commissioning-4cell.Update And Activate SCF


Create Ips For Simulated gnb
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs on VM eth3
    Configure IP On VM    ip=${wts_GNB3_X2_ADDR}    interface=eth3
    Configure IP On VM    ip=${wts_GNB3_S1U_ADDR}   interface=eth3


Perform Postconditions of Test Scenario
    [Documentation]    [PRIVATE]    postconditions for 480-D
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   reporting.Set SCOUT TC ID For Reporting
    Run Keyword And Continue On Failure   5GC000480DJ-keywords.Stop Wireshark Trace     part=_Wireshark_ErrorInTest
    Run Keyword And Continue On Failure   keywords-tracing.Dcap Tracing Stop
    Run Keyword And Continue On Failure   keywords-tracing.End Dcap Tracing And Collect Traces
    Run Keyword And Continue On Failure   wts_ue.Teardown Egate Connection For Airphone
    Run Keyword And Continue On Failure   wts_ue.Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    keywordbook-480.Collect Snapshot And Sos Report Data     ${resultDir}


Verify Alarms
    [Documentation]    [PRIVATE]    Verify Alarms
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${alarms_before_testrun}   ${alarms_after_testrun}
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

    ${exception_file}     Set Variable  ${CURDIR}/SYSLOG_EXCEPTION.TXT
    ${errorarray_file}    Set Variable  ${dir_syslog_parser}/SYSLOG_ARRAY.TXT
    ${requirement_file}   Set Variable  ${dir_syslog_parser}/SYSLOG_REQUIREMENT.TXT

    ${error_file}=  IF  ${num_of_files}==1
    ...    find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...    ${syslog_dir}/${syslog_files}[0]
    ...    ignorefname=${exception_file}
    ...    errordeffname=${errorarray_file}
    ...    requirementfname=${requirement_file}
    ...    ELSE    Log To Console    No syslog_files.tgz available

    Run Keyword And Warn On Failure          OperatingSystem.File Should Be Empty  ${error_file}

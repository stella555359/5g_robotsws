*** Settings ***
Documentation   This is a keyword file for CB006139
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        ../../../resources/Common/reporting.robot


*** Keywords ***

Perform Preconditions Of Test Scenario CB006139
    [Documentation]    [PRIVATE]    preconditions for CB006139
    ...       :Autor: Sylvia Schneider
    keywordbook-480.Create A Test Scenario Folder


Perform Postconditions Of Test Scenario CB006139
    [Documentation]    [PRIVATE]    postconditions for CB006139
    ...       :Autor: Sylvia Schneider
    reporting.Set SCOUT TC ID For Reporting
    CB006139-keywords-wireshark.Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    keywords-tracing.Dcap Tracing Stop
    keywords-tracing.End Dcap Tracing And Collect Traces
    wts_ue.Teardown Egate Connection For Airphone
    wts_ue.Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    keywordbook-480.Collect Snapshot And Sos Report Data     ${resultDir}


Suite Teardown CB006139
    [Documentation]    [PRIVATE]    suite teardown for CB006139
    ...       :Autor: Sylvia Schneider
    CB006139-keywords-wireshark.Stop Wireshark Trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    keywordbook-480.Collect Snapshot And Sos Report Data   ${resultBaseDir}
    wts_ue.Reload Stored WTS Config


Check All Radio Units Online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Sylvia Schneider
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM HTTP Session    node_type=gnb  node_id=${0}
    Wait Until Keyword Succeeds
    ...    10min   20sec
    ...    gnb.Verify All Radios Are Online    connection=${oam_alias}
    Log To Console    RUs ready
    [Teardown]     connect.Teardown OAM HTTP Session    node_type=gnb  node_id=${0}


Start Netcat For Tracing
    Log To Console    Netcat started
    Run     sudo pkill -9 -f 'nc -l ${port_trace} -k'
    ${NC_PROC}=    Start Process  nc  -l  ${port_trace}  -k  stdout=/dev/null  stderr=/dev/null
    Sleep    5
    Run    ps -ef | grep nc
    Set Test Variable    ${NC_PROC}


Stop Netact For Tracing
    Log To Console    Netcat stopped
    Terminate Process  ${NC_PROC}

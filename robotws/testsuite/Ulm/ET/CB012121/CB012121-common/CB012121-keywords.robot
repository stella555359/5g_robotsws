*** Settings ***
Documentation   This is a keyword file for CB012121
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        ../../../resources/Common/reporting.robot

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***

Perform Preconditions of Test Scenario CB012121
    [Documentation]    [PRIVATE]    preconditions for CB012121
    ...       :Autor: Sylvia Schneider
    keywordbook-480.Create a Test Scenario Folder


Perform Postconditions of Test Scenario CB012121
    [Documentation]    [PRIVATE]    postconditions for CB012121 with emil trace
    ...       :Autor: Sylvia Schneider
    reporting.Set SCOUT TC ID for Reporting
    CB012121-keywords.Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    keywords-tracing.End Dcap Tracing And Collect Traces
    wts_ue.Teardown Egate Connection For Airphone
    wts_ue.Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    keywordbook-480.Collect Snapshot And Sos Report Data     ${resultDir}


Perform Postconditions of Test Scenario CB012121 without dcap
    [Documentation]    [PRIVATE]    postconditions for CB012121 without dcap trace
    ...       :Autor: Sylvia Schneider
    reporting.Set SCOUT TC ID for Reporting
    CB012121-keywords.Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    wts_ue.Teardown Egate Connection For Airphone
    wts_ue.Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    keywordbook-480.Collect Snapshot And Sos Report Data     ${resultDir}


Perform Postconditions Of Test Scenario CB012121 Dcap
    [Documentation]    [PRIVATE]    postconditions for CB012121 with emil trace
    ...       :Autor: Sylvia Schneider
    reporting.Set SCOUT TC ID For Reporting
    CB012121-keywords.Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    keywords-tracing.Dcap Tracing Stop
    keywords-tracing.End Dcap Tracing And Collect Traces
    wts_ue.Teardown Egate Connection For Airphone
    wts_ue.Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    keywordbook-480.Collect Snapshot And Sos Report Data     ${resultDir}


Suite Teardown CB012121
    [Documentation]    [PRIVATE]    suite teardown for CB012121
    ...       :Autor: Sylvia Schneider
    CB012121-keywords.Stop Wireshark Trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    keywordbook-480.Collect Snapshot And Sos Report Data   ${resultBaseDir}
    wts_ue.Reload Stored WTS Config


Check All Radio Units Online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Sylvia Schneider
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb  node_id=${0}
    Wait Until Keyword Succeeds
    ...    10min   20sec
    ...    gnb.Verify All Radios Are Online    connection=${oam_alias}
    Log to console    RUs ready
    [Teardown]     connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}


Get Version mcc mnc From gNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update commissioning
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${current_SCF_gnb}
    ${parsed_SCF}    Parse XML    ${current_SCF_gnb}
    ${version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    Set To Dictionary    ${SCF}   version   ${version}
    Log To Console    variable SCF.version contains ${SCF.version}
    ${MNL_version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="MRBTS-1/MNL-1"]
    Set To Dictionary    ${SCF}   MNL_version   ${MNL_version}
    Log To Console    variable SCF.MNL_version contains ${SCF.MNL_version}
    ${NRPMRNL_version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_version   ${NRPMRNL_version}
    Log To Console    variable SCF.NRPMRNL_version contains ${SCF.NRPMRNL_version}
    ${NRPMRNL_distName}    Get Element Attribute    ${parsed_SCF}    distName     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_distName   ${NRPMRNL_distName}
    Log To Console    variable SCF.NRPMRNL_distName contains ${SCF.NRPMRNL_distName}
    ${mcc}    Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    Set To Dictionary    ${SCF}   mcc   ${mcc}
    Log To Console    variable SCF.mcc contains ${SCF.mcc}
    ${mnc}    Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    Set To Dictionary    ${SCF}   mnc   ${mnc}
    Log To Console    variable SCF.mnc contains ${SCF.mnc}


Start Wireshark Trace
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Autor: Sylvia Schneider
    tcpdump.Start Tcpdump On TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Sleep     1s
    Set Suite Variable      ${WIRESHARK_RUNNING}    true


Stop Wireshark Trace
    [Documentation]    [PRIVATE]    Stop Wireshark Trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    Sleep     2s
    @{result_place}    Split String     ${wireshark_store}    /
    ${tcpdump_dir}     Remove String    ${wireshark_store}    /${result_place}[-1]
    ${tcpdump_file}    tcpdump.Stop Tcpdump On TestPc
    ...  collector=dump_testpc
    ...  target_dir=${tcpdump_dir}
    Sleep     2s
    Move File    ${tcpdump_file}    ${wireshark_store}
    Set Suite Variable      ${WIRESHARK_RUNNING}    false


Stop Wireshark Trace For Setup
    [Documentation]    [PRIVATE]    Stop Wireshark Trace for setup
    ...       :Autor: Sylvia Schneider
    Stop Wireshark Trace            wireshark_store=${resultDir}/wireshark_startTL.pcap


Stop Btslog and save trace
    [Documentation]    [PRIVATE]    Stop Btslog and save trace
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${part}
    Create Directory    ${resultDir}/${part}
    Stop Btslog         target_dir=${resultDir}/${part}

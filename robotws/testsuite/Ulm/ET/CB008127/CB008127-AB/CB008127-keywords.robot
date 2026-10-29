*** Settings ***
Documentation   This is a keyword file for CB008127
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        ../../../resources/Common/reporting.robot

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***

Set Sw Release Version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   Split String    ${gnb_swVersion}    _
    Set Suite Variable    ${RELEASE}   ${gnb_sw_version_parts}[0]


Create Ips For Simulated Gnb
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs 10.0.1.3, 10.0.1.4 and 10.0.1.121 on VM eth3
    Configure IP On VM    ip=10.0.1.3        interface=eth3
    Configure IP On VM    ip=10.0.1.4        interface=eth3
    Configure IP On VM    ip=10.0.1.121      interface=eth3


Create Ips For Simulated Gnb 4
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs 10.0.1.5, 10.0.1.6 on VM eth3
    Configure IP On VM    ip=10.0.1.5        interface=eth3
    Configure IP On VM    ip=10.0.1.6        interface=eth3


Check All Radio Units Online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Sylvia Schneider
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb  node_id=${0}
    Wait Until Keyword Succeeds
    ...    10min   20sec
    ...    Verify All Radios Are Online    connection=${oam_alias}
    Log To Console    RUs ready
    [Teardown]     connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}


Get Version Mcc Mnc From GNB SCF
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
    Start Tcpdump On TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Sleep     1s
    Set Suite Variable      ${WIRESHARK_RUNNING}    true


Stop Wireshark Trace
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    Sleep     2s
    ${tcpdump_file}    Stop Tcpdump On TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Sleep     2s
    Move File    ${tcpdump_file}    ${wireshark_store}
    Set Suite Variable      ${WIRESHARK_RUNNING}    false


Perform Preconditions Of Test Scenario CB008127
    [Documentation]    [PRIVATE]    preconditions for CB008127
    ...       :Autor: Sylvia Schneider
    Create A Test Scenario Folder


Perform Postconditions Of Test Scenario CB008127
    [Documentation]    [PRIVATE]    postconditions for CB008127
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID For Reporting
    Run Keyword And Continue On Failure   Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   End Dcap Tracing And Collect Traces
    Run Keyword And Continue On Failure   Teardown Egate Connection For Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect Snapshot And SOS Report Data     ${resultDir}


Suite Teardown CB008127
    [Documentation]    [PRIVATE]    suite teardown for CB008127
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Stop Wireshark Trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect Snapshot And SOS Report Data   ${resultBaseDir}
    Reload Stored WTS Config


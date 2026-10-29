*** Settings ***
Documentation   This is a keyword file for CB008127-G
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------

Resource        ../../../resources/Common/reporting.robot

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***

Create ips for simulated gnb and eNB
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \ncreate IPs 10.0.1.3, 10.0.1.4, 10.0.1.5 on VM eth3 for gnb-3
    Configure IP on VM    ip=10.0.1.3        interface=eth3
    Configure IP on VM    ip=10.0.1.4        interface=eth3
    Configure IP on VM    ip=10.0.1.5        interface=eth3
    Log To Console    \ncreate IPs 10.0.1.6, 10.0.1.7, 10.0.1.8 on VM eth3 for enb-9
    Configure IP on VM    ip=10.0.1.6        interface=eth3
    Configure IP on VM    ip=10.0.1.7        interface=eth3
    Configure IP on VM    ip=10.0.1.8        interface=eth3


check all radio units online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Shruthi Shivaprasad
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    wait until keyword succeeds
    ...    10min   20sec
    ...    Verify All Radios are Online    connection=${oam_alias}
    Log to console    RUs ready
    [Teardown]     connect.Teardown OAM http session    node_type=gnb  node_id=${0}


get version mcc mnc from gNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update commissioning
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${current_SCF_gnb}
    ${parsed_SCF}    parse XML    ${current_SCF_gnb}
    ${version}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    Set To Dictionary    ${SCF}   version   ${version}
    Log To Console    variable SCF.version contains ${SCF.version}
    ${MNL_version}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="MRBTS-1/MNL-1"]
    Set To Dictionary    ${SCF}   MNL_version   ${MNL_version}
    Log To Console    variable SCF.MNL_version contains ${SCF.MNL_version}
    ${NRPMRNL_version}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_version   ${NRPMRNL_version}
    Log To Console    variable SCF.NRPMRNL_version contains ${SCF.NRPMRNL_version}
    ${NRPMRNL_distName}    get element attribute    ${parsed_SCF}    distName     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_distName   ${NRPMRNL_distName}
    Log To Console    variable SCF.NRPMRNL_distName contains ${SCF.NRPMRNL_distName}
    ${mcc}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    Set To Dictionary    ${SCF}   mcc   ${mcc}
    Log To Console    variable SCF.mcc contains ${SCF.mcc}
    ${mnc}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    Set To Dictionary    ${SCF}   mnc   ${mnc}
    Log To Console    variable SCF.mnc contains ${SCF.mnc}
    ${mnclenght}    get element text    ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mncLength"]
    set suite variable   ${mnclenght}
    Log To Console    set suite variable mnclenght_SCF to value: ${mnclenght}



start wireshark trace
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Autor: Shruthi Shivaprasad
    Start Tcpdump on TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    sleep     1s
    Set suite variable      ${WIRESHARK_RUNNING}    true

start wireshark trace gNB
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    wireshark on GNB started
    Start Tcpdump on gNB Common Unit
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    sleep     1s
    Set suite variable      ${WIRESHARK_RUNNING}    true

stop wireshark trace
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    sleep     2s
    ${tcpdump_file}    Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    sleep     2s
    Move File    ${tcpdump_file}    ${wireshark_store}
    Set suite variable      ${WIRESHARK_RUNNING}    false

stop wireshark trace gNB
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    sleep     2s
    ${tcpdump_file}    Stop Tcpdump on gNB Common Unit
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    sleep     2s
    Log To Console    wireshark on GNB stopped
    Move File    ${tcpdump_file}    ${wireshark_store}
    Set suite variable      ${WIRESHARK_RUNNING}    false

Perform Preconditions of Test Scenario CB008127-G
    [Documentation]    [PRIVATE]    preconditions for CB008127
    ...       :Autor: Shruthi Shivaprasad
    Create a Test Scenario Folder


Perform Postconditions of Test Scenario CB008127-G
    [Documentation]    [PRIVATE]    postconditions for CB008127-G
    ...       :Autor: Shruthi Shivaprasad
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   stop wireshark trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   end dcap tracing and collect traces
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect Snapshot And SOS Report Data     ${resultDir}


Suite Teardown CB008127-G
    [Documentation]    [PRIVATE]    suite teardown for CB008127-G
    ...       :Autor: Shruthi Shivaprasad
    Run Keyword And Continue On Failure   stop wireshark trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect Snapshot And SOS Report Data   ${resultBaseDir}
    Reload Stored WTS Config


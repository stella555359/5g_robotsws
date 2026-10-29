*** Settings ***
Documentation   This is a keyword file for CB008127-CD
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../../resources/Common/reporting.robot

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***

Create Ips For Simulated gnb And eNB
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs 10.0.1.3, 10.0.1.4, 10.0.1.5 on VM eth3 for gnb-3
    Configure IP on VM    ip=10.0.1.3        interface=eth3
    Configure IP on VM    ip=10.0.1.4        interface=eth3
    Configure IP on VM    ip=10.0.1.5        interface=eth3
    Log To Console    \ncreate IPs 10.0.1.6, 10.0.1.7, 10.0.1.8 on VM eth3 for enb-9
    Configure IP on VM    ip=10.0.1.6        interface=eth3
    Configure IP on VM    ip=10.0.1.7        interface=eth3
    Configure IP on VM    ip=10.0.1.8        interface=eth3


Check All Radio Units Online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Sylvia Schneider
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM HTTP Session    node_type=gnb  node_id=${0}
    Wait Until Keyword Succeeds
    ...    10min   20sec
    ...    Verify All Radios Are Online    connection=${oam_alias}
    Log to console    RUs ready
    [Teardown]     connect.Teardown OAM HTTP Session    node_type=gnb  node_id=${0}


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
    Start Tcpdump on TestPc
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
    ${tcpdump_file}    Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Sleep     2s
    Move File    ${tcpdump_file}    ${wireshark_store}
    Set Suite Variable      ${WIRESHARK_RUNNING}    false


Perform Preconditions of Test Scenario CB008127-CD
    [Documentation]    [PRIVATE]    preconditions for CB008127
    ...       :Autor: Sylvia Schneider
    Create a Test Scenario Folder


Perform Postconditions of Test Scenario CB008127-CD
    [Documentation]    [PRIVATE]    postconditions for CB008127-CD
    ...       :Autor: Sylvia Schneider
    Set SCOUT TC ID for Reporting
    Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Dcap Tracing Stop
    End Dcap Tracing And Collect Traces
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect Snapshot And Sos Report Data     ${resultDir}


Suite Teardown CB008127-CD
    [Documentation]    [PRIVATE]    suite teardown for CB008127-CD
    ...       :Autor: Sylvia Schneider
    Stop Wireshark Trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect Snapshot And Sos Report Data   ${resultBaseDir}
    Reload Stored WTS Config


Verify Syslog Trace
    [Documentation]    [PRIVATE]    verify syslog trace
    ...       :Autor: Sylvia Schneider
    Log to console   verify syslog
    ${syslog_dir}     Set Variable  ${resultDir}/btslog_gnb0
    ${syslog_files}   OperatingSystem.List Files In Directory  ${syslog_dir}  *.tgz
    ${num_of_files}   Get Length  ${syslog_files}

    ${EXCEPTIONFILE}     Set Variable  ${CURDIR}/SYSLOG_EXCEPTION.TXT
    ${ERRORARRAYFILE}    Set Variable  ${dir_syslog_parser}/SYSLOG_ARRAY.TXT
    ${REQUIREMENTFILE}   Set Variable  ${dir_syslog_parser}/SYSLOG_REQUIREMENT.TXT

    ${error_file}=  IF  ${num_of_files}==1
    ...    find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...    ${syslog_dir}/${syslog_files}[0]
    ...    ignorefname=${EXCEPTIONFILE}
    ...    errordeffname=${ERRORARRAYFILE}
    ...    requirementfname=${REQUIREMENTFILE}
    ...    ELSE    Log To Console    No syslog_files.tgz available

    Run Keyword And Warn On Failure          OperatingSystem.File Should Be Empty  ${error_file}


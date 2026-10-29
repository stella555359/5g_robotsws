*** Settings ***

Documentation   This is a Robot Test Suite for subfeature 5GC001248-K
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
#-------------------------------------------------------------------------------------------------------------
Library         taf.config.wts    WITH NAME    wts
Resource        ../keywordbook-480.robot
Resource        ../../../resources/Common/reporting.robot



Suite Setup     Suite Setup 5GC001248-K
Suite Teardown  Suite Teardown 5GC001248-K

*** Variables ***
${part2}    /field[@name="nr-rrc.CSI_ReportConfig_element"]/field[@name="nr-rrc.reportConfigType"]
${part3}    /field[@name="nr-rrc.periodic_element"]/field[@name="nr-rrc.reportSlotConfig"]/field[@name="nr-rrc.slots320"]

${xpath_nzp1}    .//field[@name="nr-rrc.NZP_CSI_RS_Resource_element"]/field[@name="nr-rrc.periodicityAndOffset"]
${xpath_nzp2}    /field[@name="nr-rrc.slots320"]

${logs_collected}          False
${TCPDUMP_RUNNING}         false


*** Test Cases ***

5GC001248_K_Successful_SgNBAddition_for_UE_supporting_1_simultaneousCSIReportsPerCC
    [Documentation]
    ...    This Test Scenario verifies parameter simultaneousCSI-ReportsPerCC=1
    ...    This test case verifies the radio resource allocation for CSI reporting for a UE supporting just
    ...    one CSI Report measurement per CC. Radio Admission control has to evaluate the parameter
    ...    simultaneousCSIReportsPerCC which can be set in the UE capabilities.
    [Tags]    CRT
    ...       csi1

    [Setup]    Perform Preconditions of Test Scenario 1248-K

    LTE Attach And sgNB Addition      ue_id=101
    LTE Attach And sgNB Addition      ue_id=103
    Verify Radio Resource Allocation For SimultaneousCSI Reporting In X2    csi=csi1   ue_id=101
    Verify Radio Resource Allocation For SimultaneousCSI Reporting In X2    csi=csi1   ue_id=103

    [Teardown]    Perform Postconditions Of Test Scenario 1248-K



5GC001248_K_Successful_SgNBAddition_for_UE_supporting_2_simultaneousCSIReportsPerCC
    [Documentation]
    ...    This Test Scenario verifies parameter simultaneousCSI-ReportsPerCC=2
    ...    This test case verifies the radio resource allocation for CSI reporting for a UE supporting just
    ...    two CSI Report measurement per CC. Radio Admission control has to evaluate the parameter
    ...    simultaneousCSIReportsPerCC which can be set in the UE capabilities.
    [Tags]    CIT
    ...       csi2

    [Setup]    Perform Preconditions of Test Scenario 1248-K

    LTE Attach And sgNB Addition      ue_id=102
    Verify Radio Resource Allocation For SimultaneousCSI Reporting In X2    csi=csi2   ue_id=102

    [Teardown]    Perform Postconditions Of Test Scenario 1248-K





*** Keywords ***
Suite Setup 5GC001248-K
    [Documentation]    [PRIVATE]    suite setup for 1248-K
    ...       :Autor: Sylvia Schneider
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update wts file for 1248K
    Update and activate SCF


Perform Preconditions of Test Scenario 1248-K
    [Documentation]    [PRIVATE]    suite setup for 1248-K
    ...       :Autor: Sylvia Schneider
    Create a Test Scenario Folder
    Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_1248K.cfg
    Bring Airphone TL to on Air status


Perform Postconditions of Test Scenario 1248-K
    [Documentation]    [PRIVATE]    postconditions for 1248-K
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID For Reporting
    Run Keyword And Continue On Failure   Stop Tcpdump Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   Teardown Egate Connection For Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect Snapshot And SOS Report Data     ${resultDir}


Suite Teardown 5GC001248-K
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect Snapshot And SOS Report Data   ${resultBaseDir}
    Reload Stored WTS Config


Update wts file for 1248K
    [Documentation]    [PRIVATE]    update wts cfg file
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}

    ${cap101}   Set Variable
    ...   0300000002000800000180008002012000100000010D00180C0000007C7E80100000030900520000000207800000000000013A000080000000008008EC00
    ${cap102}   Set Variable
    ...   0300000002000800000180008002012000100000010D00180C0000107C7E80100000030900520000000207800000000000013A000080000000008008EC00
    ${cap103}   Set Variable
    ...   0300000002000800000180008002012000100000010D00100407C7C280100000030900520000000207800000000000013A000080000000008008EC00

    wts.Modify   ue_param id=101    ue_nr_capabilities=${cap101}
    wts.Modify   ue_param id=102    ue_nr_capabilities=${cap102}
    wts.Modify   ue_param id=103    ue_nr_capabilities=${cap103}

    wts.Save wts cfg              ${resultBaseDir}/basic_wts_1248K.cfg
    Log To Console    \nwts cfg saved as ${resultBaseDir}/basic_wts_1248K.cfg


Update and activate SCF
    [Documentation]    [PRIVATE]    update SCF and activate on gNB
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${gnb_id}=0
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_1248K.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable    ${scf_xml}

    ${xpath_NRCELL_1}      Set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    ${xpath_NRCELL_2}      Set Variable    managedObject[@distName="${bts_distName}/NRCELL-2"]
    ${xpath_NRCELLGRP_0}   Set Variable    managedObject[@distName="${bts_distName}/NRCELLGRP-0"]
    ${xpath_NRCELLGRP_1}   Set Variable    managedObject[@distName="${bts_distName}/NRCELLGRP-1"]

    Set Element Text   ${scf_xml}    text=true                 xpath=.//${xpath_NRCELL_1}/p[@name="actBeamforming"]
    Set Element Text   ${scf_xml}    text=false                xpath=.//${xpath_NRCELL_2}/p[@name="actBeamforming"]
    Set Element Text   ${scf_xml}    text=beamSetAbf_32A       xpath=.//${xpath_NRCELL_1}/list[@name="beamSet"]/item/p[@name="basicBeamSet"]
    Set Element Text   ${scf_xml}    text=beamSetAbf_1A        xpath=.//${xpath_NRCELL_2}/list[@name="beamSet"]/item/p[@name="basicBeamSet"]

    Set Element Text   ${scf_xml}    text=20                   xpath=.//${xpath_NRCELLGRP_0}/p[@name="ssBurstSetPeriod"]
    Set Element Text   ${scf_xml}    text=10                   xpath=.//${xpath_NRCELLGRP_1}/p[@name="ssBurstSetPeriod"]
    Set Element Text   ${scf_xml}    text=32 beams             xpath=.//${xpath_NRCELLGRP_0}/p[@name="numberOfTransmittedSsBlocks"]
    Set Element Text   ${scf_xml}    text=1 beam               xpath=.//${xpath_NRCELLGRP_1}/p[@name="numberOfTransmittedSsBlocks"]

    Set Elements Text  ${scf_xml}    text=false                xpath=.//p[@name="actDl256Qam"]
    Set Elements Text  ${scf_xml}    text=false                xpath=.//p[@name="actIncreasedFdmUsersPerSlot"]

    Set Element Text   ${scf_xml}    text=false                xpath=.//p[@name="actCsiReportsMuxOnPucch"]
    Save Xml     ${scf_xml}    ${resultBaseDir}/SCFC_1248K.xml

    ${oam_alias}    connect.Setup OAM HTTP Session    node_id=${gnb_id}
    Log To Console    activate ${resultBaseDir}/SCFC_1248K.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultBaseDir}/SCFC_1248K.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/SCFC_1248K.xml finished
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_id=${gnb_id}


LTE attach and sgNB addition
    [Documentation]    [PRIVATE]    start tcpdump, attach UE, stop tcpdump
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    Start tcpdump trace
    Sleep     2s
    Attach UE    ${ue_id}
    Sleep    3s
    Stop Tcpdump Trace    wireshark_store=${resultDir}/wireshark_UE${ue_id}.pcap
    Sleep    3s


Start tcpdump trace
    [Documentation]    [PRIVATE]    start tcpdump trace
    ...       :Autor: Sylvia Schneider
    Log To Console    \ntcpdump started
    Start Tcpdump On TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Set Suite Variable      ${TCPDUMP_RUNNING}    true


Stop tcpdump trace
    [Documentation]    [PRIVATE]    stop tcpdump trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${TCPDUMP_RUNNING}'=='false'   RETURN
    ${tcpdump_file}    Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Run Keyword And Continue On Failure  Move File    ${tcpdump_file}    ${wireshark_store}
    Log To Console    \ntcpdump stopped
    Set Suite Variable      ${TCPDUMP_RUNNING}    false


Verify Radio Resource Allocation for simultaneousCSI reporting in X2
    [Documentation]    extract csi relevant values from wireshark
    [Arguments]     ${csi}  ${ue_id}
    Log to Console    \nextract csi relevant values from wireshark for UE${ue_id}
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/X2_UE${ue_id}.xml
    ...   packet_filter=x2ap.procedureCode==27
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/wireshark_UE${ue_id}.pcap
    ${pdml_xml}    Parse Xml    ${resultDir}/X2_UE${ue_id}.xml

    ${part1_0}        Set Variable   .//field[@show="Item 0"]
    ${part1_1}        Set Variable   .//field[@show="Item 1"]
    ${item0_xpath}    Set Variable   ${part1_0}${part2}${part3}
    ${item0_slots}    Get Element Attribute    ${pdml_xml}    showname    xpath=${item0_xpath}

    ${item1_xpath}    Set Variable   ${part1_1}${part2}${part3}
    ${item1_slots}    Get Element Attribute    ${pdml_xml}    showname    xpath=${item1_xpath}

    ${item0_str}   Fetch From Right     ${item0_slots}   ${SPACE}
    ${item0}       Convert To Integer     ${item0_str}
    ${item1_str}   Fetch From Right     ${item1_slots}   ${SPACE}
    ${item1}       Convert To Integer     ${item1_str}

    ${xpath}   Set Variable   ${xpath_nzp1}${xpath_nzp2}
    ${slots_NZP}      Get Element Attribute    ${pdml_xml}    showname    xpath=${xpath}
    ${slots_NZP_str}  Fetch From Right     ${slots_NZP}   ${SPACE}
    ${slots}          Convert To Integer     ${slots_NZP_str}

    Log To Console    \nCSI_ReportConfig_element-item 0 "${item0}"
    Log To Console    \nCSI_ReportConfig_element-item 1 "${item1}"
    Log To Console    \nNZP_CSI_RS_Resource_element "${slots}"
    Run Keyword       Verify ${csi}    ${slots}    ${item0}    ${item1}
    [Teardown]    teardown tshark


Verify csi1
    [Documentation]    verify csi1 relevant values
    [Arguments]     ${slots}    ${item0}    ${item1}

    ${result}   Set Variable If   ${item0} >= ${slots} >= ${item1}   Passed   Failed

    ${msg1}         Set Variable      \nCSI_ReportConfig_element-item 0 "${item0}" >= NZP_CSI_RS_Resource_element
    ${msg2}         Set Variable      "${slots}" >= CSI_ReportConfig_element-item 1 "${item1}"
    IF    '${result}'=='Passed'    Log To Console    passed: ${msg1} ${msg2}
    IF    '${result}'=='Failed'    Run Keyword And Continue On Failure    Fail    failed: ${msg1} ${msg2}

    ${calculate_item0}     Evaluate    ${item0}-10
    ${result}   Set Variable If  ${calculate_item0} > ${item1}   Passed   Failed
    ${msg1}         Set Variable      \ndifference of CSI_ReportConfig_element-item 0 "${item0}" and
    ${msg2}         Set Variable      CSI_ReportConfig_element-item 1 "${item1}" greater than 10
    IF    '${result}'=='Passed'    Log To Console    passed: ${msg1} ${msg2}
    IF    '${result}'=='Failed'    Run Keyword And Continue On Failure    Fail    failed: ${msg1} ${msg2}


Verify csi2
    [Documentation]    verify csi2 relevant values
    [Arguments]     ${slots}    ${item0}    ${item1}
    ${result}   Set Variable If   ${slots} <= ${item0} <= ${item1}   Passed   Failed

    ${msg1}         Set Variable      \nNZP_CSI_RS_Resource_element "${slots}" <= CSI_ReportConfig_element-item 0
    ${msg2}         Set Variable      "${item0}" <= CSI_ReportConfig_element-item 1 "${item1}"
    IF    '${result}'=='Passed'    Log To Console    passed: ${msg1} ${msg2}
    IF    '${result}'=='Failed'    Run Keyword And Continue On Failure    Fail    failed: ${msg1} ${msg2}

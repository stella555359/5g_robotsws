*** Settings ***
Documentation
...   author: Michal Halucha
...   contact: michal.halucha@nokia.com

Library     taf.ue
Library     SSHLibrary
Library     OperatingSystem
Library     testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008717/resources/test_specific_keywords_CB008717.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    taf/rfrl/common_resources/common_step/interface.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008717/resources/test_variables_C008717.py

*** Variables ***
@{ONE_NODE}               gNB50859
${CUSTOM_CONFIG}          custom-config/Wroclaw/7_16_UTE5GCLOUDWPT3
${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUDWPT3/ue_config.yaml
${LOG_PATH}               ${OUTPUT DIR}
${IS_TEST_HA}             ${FALSE}


*** Keywords ***
Test Setup
    [Arguments]    ${test_parameters}
    Perform Recommissioning    ${test_parameters["srbinactivity"]}  ${test_parameters["reportamount"]}
    ...    ${test_parameters["a4threshold"]}
    Collect Scf Before Test
    Setup Attenuator


Additional Settings For More Than One Candidate NRDC
    Perform Delta  ${25}  NRHOIF-1  NRHOIF-2  NRHOIF-3  NRHOIF-4
    Change One Parameter    ${SET_FOR_I}
    Change Parameters With Relation Error    ${PARAMS_WITH_RELATION_ERRORS}


Additional Settings For EA RESUME
    Change One Parameter    ${SET_FOR_EA}


Test Teardown
    Zip Results
    Run Keyword And Ignore Error    Detach Ue    UE_1
    Run Keyword And Ignore Error    Stop and Prepare Logs
    Run Keyword And Ignore Error    interface.Common Step Trigger
    Run Keyword And Ignore Error    Clear Admin Logs
    Run Keyword If Test Failed      Make Webui Snapshot
    Add Scout Scf Id To Test Data
    IF    '${IS_TEST_HA}' == '${TRUE}'  Turn Off Apn    UE_1    n26wro
    Set Default Attenuation


Start Logs
    Create Tcpdump Collector
    Create Syslog Collector  BtsLog.tgz
    Start Syslog
    Start Tcp Dump
    Sleep  5s


Stop and Prepare Logs
    ${path}=  get_path
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Convert Pdml


Prepare UE
    Require UE    UE_1  SDX70
    Detach Ue    UE_1
    Sleep    3s


Perform Attach
    Attach Ue    UE_1
    Sleep    10s


Successful PSCELL addition with A4 configured and NR-DC activated
    Verify Administrative State  Locked  NRCELL-2  NRCELL-3  NRCELL-4
    Verify Administrative State  Unlocked  NRCELL-1
    Set Attenuation For Cell    GNB_1_CELL_592    0dB
    Start Logs
    Prepare UE
    Perform Attach
    Start DL  UE_1  10s  DT_DL
    Stop Traffic    DT_DL
    Stop And Prepare Logs
    Pcap Flow    ${PS_CELL_ADDITION}
    Check Fr1 Fr2 And Meas Objects
    Check A4   PsCellAddition.pdml
    Supervision Timer Retry Timer  ${0}
    Check Tput On Pcell And Pscell Btslog
    Verify Proper Pci Attach  1


Supervision and Retry timer verification NRDC_on A4_configured
    Verify Administrative State  Locked  NRCELL-2  NRCELL-3  NRCELL-4
    Verify Administrative State  Unlocked  NRCELL-1
    Set Attenuation For Cell    GNB_1_CELL_592    10dB
    Start Logs
    Prepare UE
    Perform Attach
    Sleep  220s
    Stop and Prepare Logs
    Supervision Timer Retry Timer  ${64}
    Verify Proper Pci Attach  592


More than one NR-DC PSCell candidate best reported cell from Idle
    Additional Settings For More Than One Candidate NRDC
    Verify Administrative State  Locked  NRCELL-1  NRCELL-2
    Set Attenuation For Cell    GNB_1_CELL_592    0dB
    Start Logs
    Prepare UE
    Perform Attach
    Start DL  UE_1  100s  DT_DL
    Verify Administrative State  Unlocked  NRCELL-1  NRCELL-2
    Stop Traffic    DT_DL
    Stop And Prepare Logs
    Pcap Flow    ${PS_CELL_ADDITION}
    Check Fr1 Fr2 And Meas Objects  2xFR2
    Verify Proper Pci Attach  592
    Verify Proper Pci Attach  1
    Verify Worse Reported Cell  1  2
    Check Tput On Pcell And Pscell Btslog


NRDC PSCell Addition by A4 measurement after Resume procedure
    Verify Administrative State  Locked  NRCELL-1  NRCELL-2  NRCELL-3  NRCELL-4
    Additional Settings For EA RESUME
    Set Attenuation For Cell    GNB_1_CELL_592    0dB
    Start Logs
    Prepare UE
    Perform Attach
    Sleep  20s
    Verify Administrative State  Unlocked  NRCELL-1
    Start UL   UE_1
    Sleep  20s
    Stop And Prepare Logs
    Pcap Flow    ${INACTIVITY_STATE}
    Check Fr1 Fr2 And Meas Objects
    Check A4   PsCellAddition.pdml
    Verify Proper Pci Attach  592
    Verify Proper Pci Attach  1
    Change One Parameter    ${DISABLE_RRC_INACTIVE}


Start A4 retryTimer after inter gNB HO via NG with NRDC ineligible PDU Session
    Check Remote Cells On Air
    Verify Administrative State  Locked  NRCELL-2  NRCELL-3  NRCELL-4
    Verify Administrative State  Unlocked  NRCELL-1
    Set Attenuation For Cell    GNB_2_CELL_582    0dB
    Start Logs
    Prepare UE
    Turn On Apn    UE_1    n26HOwro
    Set Test Variable    ${IS_TEST_HA}    ${TRUE}
    Perform Attach
    Start DL  UE_1  200s  DT_DL
    Perform Handover  ${CELL_582}  ${CELL_593}  UE_1   40db
    Sleep    150s
    Stop Traffic    DT_DL
    Stop And Prepare Logs
    Verify Reconfiguration From Bts50858    582
    Verify Proper Pci Attach  1
    Pcap Flow    ${BTS_50859_HO_via_NG_PCAP_FLOW}
    Check Fr1 Fr2 And Meas Objects
    Verify Syslog    ${SYSLOG_HA}


Successful NR-DC PSCell Addition after intra-gNB inter-freq handover
    Verify Administrative State  Locked  NRCELL-2  NRCELL-3  NRCELL-4
    Verify Administrative State  Unlocked  NRCELL-1
    Set Attenuation For Cell    GNB_1_CELL_591    0dB
    Start Logs
    Prepare UE
    Perform Attach
    Start DL  UE_1  100s  DT_DL
    Perform Handover  ${CELL_591}  ${CELL_593}    UE_1    53db
    Stop Traffic    DT_DL
    Stop And Prepare Logs
    Verify Proper Pci Attach  591
    Verify Proper Pci Attach  593
    Verify Proper Pci Attach  1
    Check Fr1 Fr2 And Meas Objects
    Verify Syslog    ${SYSLOG_B2A}


Not configure a4 event for NR-DC PSCell Addition for not FWA UE after inter-gNB handover
    Turn Off Fwa Ue
    Verify Administrative State  Locked  NRCELL-2  NRCELL-3  NRCELL-4
    Verify Administrative State  Unlocked  NRCELL-1
    Set Attenuation For Cell    GNB_2_CELL_582    0dB
    Start Logs
    Prepare UE
    Perform Attach
    Start DL  UE_1  100s  DT_DL
    Perform Handover  ${CELL_582}  ${CELL_592}  UE_1    53db
    Perform Handover  ${CELL_592}  ${CELL_591}  UE_1    53db
    Stop Traffic    DT_DL
    Stop And Prepare Logs
    Verify Reconfiguration From Bts50858    582
    Verify Proper Pci Attach  592
    Verify Proper Pci Attach  591
    Pcap Flow    ${BTS_50859_HO_PCAP_FLOW}
    Run Keyword And Expect Error    *    Verify Proper Pci Attach  1
    Turn On Fwa Ue


Successful NR-DC PSCell Addition after inter-gNB HO via NG Link with insufficient UE Capabilities
    Check Remote Cells On Air
    Verify Administrative State  Locked  NRCELL-2  NRCELL-3  NRCELL-4
    Verify Administrative State  Unlocked  NRCELL-1
    Set Attenuation For Cell    GNB_1_CELL_591    0dB
    Start Logs
    Prepare UE
    Perform Attach
    Start DL  UE_1  200s  DT_DL
    Perform Handover  ${CELL_591}  ${CELL_582}    UE_1    53db
    Perform Handover  ${CELL_582}  ${CELL_593}  UE_1    53db
    Stop Traffic    DT_DL
    Stop And Prepare Logs
    Verify Reconfiguration From Bts50858    582
    Verify Proper Pci Attach  593
    Pcap Flow    ${BTS_50859_HO_PCAP_FLOW}
    Check Fr1 Fr2 And Meas Objects
    Verify Syslog    ${SYSLOG_HA}


Successful NR-DC PSCell Addition after inter-RAT HO with sufficient UE Capabilities
    Verify Administrative State  Locked  NRCELL-2  NRCELL-3  NRCELL-4
    Verify Administrative State  Unlocked  NRCELL-1
    Set Attenuation For Cell    GNB_1_CELL_591    0dB
    Start Logs
    Prepare UE
    Perform Attach
    Start DL  UE_1  200s  DT_DL
    Perform Handover  ${CELL_591}  ${CELL_58}  UE_1    53db
    Perform Handover  ${CELL_58}  ${CELL_592}  UE_1    53db
    Perform Handover  ${CELL_592}  ${CELL_591}  UE_1    53db
    Stop Traffic    DT_DL
    Stop And Prepare Logs
    Verify Proper Pci Attach  591
    Verify Proper Pci Attach  592
    Verify Proper Pci Attach  1
    Verify Reconfiguration From Bts50858    58


Not configure a4 event for NRDC PSCell addition due to lack of a4MeasNrDcEnabled configuration
    Change One Parameter    ${SET_FOR_B4_DISABLE}
    Verify Administrative State  Locked  NRCELL-2  NRCELL-3  NRCELL-4
    Verify Administrative State  Unlocked  NRCELL-1
    Set Attenuation For Cell    GNB_2_CELL_582    0dB
    Start Logs
    Prepare UE
    Perform Attach
    Start DL  UE_1  100s  DT_DL
    Perform Handover  ${CELL_582}  ${CELL_592}  UE_1    53db
    Perform Handover  ${CELL_592}  ${CELL_591}  UE_1    53db
    Stop Traffic    DT_DL
    Stop And Prepare Logs
    Verify Reconfiguration From Bts50858    582
    Verify Proper Pci Attach  592
    Run Keyword And Expect Error    *    Verify Proper Pci Attach  1
    Run Keyword And Expect Error    *    Verify Proper Pci Attach  591
    Change One Parameter    ${SET_FOR_B4_ENABLE}

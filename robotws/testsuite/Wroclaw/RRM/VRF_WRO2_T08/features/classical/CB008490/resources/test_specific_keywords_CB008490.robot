*** Settings ***
Documentation
...   author: Michal Halucha
...   contact: michal.halucha@nokia.com

Library     taf.ue
Library     SSHLibrary
Library     OperatingSystem
Library     testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008490/resources/test_specific_keywords_CB008490.py
Library     taf.ul.alarms_watchdog    WITH NAME   WATCHDOG
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Library     testsuite/Wroclaw/RRM/resources/syslog_checker.py
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008490/resources/test_variables_CB008490.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/allowed_alarms.py


*** Variables ***
${LOG_PATH}               ${OUTPUT DIR}
${ABSTRACT_LIB_CONFIG}   /home/ute/testline_configuration/7_16_UTE5GCLOUDWPT3/ue_config.yaml
${IS_CELL_DISABLED}       ${FALSE}
${IS_OVERLOAD_SET}        ${FALSE}
${IS_FWA_CHANGED}         ${FALSE}
${IS_CELLS_LOCKED}         ${FALSE}
${IS_CELL_LOCKED}         ${FALSE}
${IS_INACTIVE_CHANGED}     ${FALSE}
${IS_NRDC_FLAG_CHANGED}    ${FALSE}
${IS_TRACKINGAREA_CHANGED}    ${FALSE}
${REMOTE_MPLANE_IP}       10.42.47.9
${VM_IP_23}        10.42.71.23
${VM_IP_24}        10.42.71.24
${VM_IP_25}        10.42.71.25

*** Keywords ***
Test Setup
    [Arguments]    ${CELL}=GNB_1_CELL_593
    Verify Gnb Is OnAir
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    WATCHDOG.Check Detected Alarms
    Initialize Attenuator
    Set Attenuation For Cell    ${CELL}    0dB
    Prepare UE
    Setup Dcap Controller


Test Teardown
    WATCHDOG.Check Detected Alarms
    WATCHDOG.Stop Watching Alarms
    Run Keyword And Ignore Error    interface.Common Step Trigger
    Run Keyword And Ignore Error    Clear Admin Logs
    Run Keyword If Test Failed      Make Webui Snapshot
    Run Keyword If Test Failed      Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Add Scout Scf Id To Test Data
    Release Attenuator
#    Reestablishement of xnlink is not fully delivered so BTS reset is required
    IF    '${IS_CELL_DISABLED}' == '${TRUE}'  Verify Administrative State
    ...    Unlocked  NRCELL-561  NRCELL-568  NRCELL-567  NRCELL-566  NRCELL-565  NRCELL-562  NRCELL-564  NRCELL-563
    IF    '${IS_CELL_DISABLED}' == '${TRUE}'  Change Shutdown Timer    30
    IF    '${IS_CELL_DISABLED}' == '${TRUE}'  BTS Reset
    IF    '${IS_OVERLOAD_SET}' == '${TRUE}'   Switch Overload Mode  disabled  gnbOvlProtMode
    IF    '${IS_FWA_CHANGED}' == '${TRUE}'   Change FWA Value    99
    IF    '${IS_NRDC_FLAG_CHANGED}' == '${TRUE}'   Change Nrdc Flag    disabled
    IF    '${IS_INACTIVE_CHANGED}' == '${TRUE}'   Prepare Parameters For Ue Inactivity    0    7200    600
    IF    '${IS_TRACKINGAREA_CHANGED}' == '${TRUE}'    Change Tracking Area Dn In Cells    7152
    IF    '${IS_CELLS_LOCKED}' == '${TRUE}'  One Cell Nrdcsn Unlocked    Unlocked
    IF    '${IS_CELLS_LOCKED}' == '${TRUE}'  Change A4 Threshold    0
    IF    '${IS_CELL_LOCKED}' == '${TRUE}'  Change Sn Cell State    Unlocked
    Run Keyword If Test Passed    Find Suspicious Logs

BTS Reset
    SSHLibrary.Open Connection    host=${REMOTE_MPLANE_IP}    alias=target_pcap
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Start Command    reboot

Prepare UE
    Require UE    UE_1  SDX70
    Detach Ue    UE_1
    Sleep    3s


Start Syslog On VM
    [Arguments]    ${remote_ip}
    Create Syslog Collector  BtsLog.tgz    ${remote_ip}
    Start Syslog


Stop and Prepare Logs
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/


Prepare Logs
    ${path}=  Get Path
    Unzip Results
    Find Pcap Files In Subfolders
    Find Syslog Files From Dcap
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Merge Syslog
    Convert Pdml


Prepare Logs With Emil Conversion
    ${path}=  Get Path
    Unzip Results
    Find Pcap Files In Subfolders
    Find Syslog Files From Dcap
    Merge Syslog
    Find Emil Files In Subfolders
    Convert Emil Files To Csv


Graceful_shutdown_of_the_last_NR-DC-SN_cell_and_Xn_link_release
    Set Test Variable    ${IS_CELL_DISABLED}    ${TRUE}
    Verify Administrative State  Locked  NRCELL-568  NRCELL-567  NRCELL-566  NRCELL-565  NRCELL-562  NRCELL-564  NRCELL-563
    Change Shutdown Timer    1
    Start Syslog On VM    ${VM_IP_24}
    Graceful Shutdown with DCAP logging
    Set Test Variable    ${IS_CELL_DISABLED}    ${TRUE}
    Prepare Logs
    Verify Syslog    ${SR_GD_B3_TC05}
    Verify Pcap Flow    ${SHUTDOWN_XN_LINK}


A4MeasurementReport_Discarded_While_gNB_Overloaded
    Switch Overload Mode  classical  gnbOvlProtMode
    Set Test Variable    ${IS_OVERLOAD_SET}    ${TRUE}
    Start Syslog On VM    ${VM_IP_24}
    Overload with DCAP logging
    Prepare Logs
    Verify Syslog    ${MB_B4}


UE_Capability_Enquiring_About_NR-DC_Support_For_All_Cells_On_Target_gNB_after_inter_gNB_HO
    Start Syslog On VM    ${VM_IP_25}
    Perform Handover To Cell Unsupporting NRDC
    Prepare Logs
    Verify Pcap Flow    ${XN_HO_AND_UERADIOCAPABILITYINFOINDICATION_FIELD_PCAP_FLOW}
    Verify Syslog For No NR_DC Setup


Activate_A4_Measurements_For_NR-DC_PSCell_Addition_After_Inter-gNB_HO_via_NG
    Start Syslog On VM    ${VM_IP_25}
    Perform Handover To Cell Supporting NRDC
    Prepare Logs
    Verify Pcap Flow    ${NG_HO_AND_SNODE_ADDITION_PCAP_FLOW}


Not_activate_NR-DC_A4_measurements_after_inter-gNB_HO_to_target_cell_with_MFBI_enabled
    Change Nrdc Flag    inter-gNB_FR1-FR2
    Set Test Variable    ${IS_NRDC_FLAG_CHANGED}    ${TRUE}
    Start Syslog On VM    ${VM_IP_23}
    Perform Handover To Cell Supporting MFBI
    Prepare Logs
    Verify Pcap Flow    ${XN_HO_AND_UERADIOCAPABILITYINFOINDICATION_FIELD_PCAP_FLOW}
    Verify Syslog    ${B2_MFBI}
    Verify Syslog For No NR_DC Setup


A4_Timer_After_Successfull_Reestablishment_To_Different_Serving_Cell_With_A2_actRedirect
    Start Syslog On VM    ${VM_IP_23}
    Perform Reestablishment To Cell With A2 Redirect
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Find Pcap Files In Subfolders
    Convert Pdml
    Verify Pcap Flow    ${REESTABLISHMENT_WITH_A2_REDIRECT}
    Verify Syslog   ${MB_B2_A2}    /btslog/SYSLOG_1.LOG


Not_Configure_Inter-frequency_A4_Measurements_For_NR-DC_PSCell_Addition_After_Intra-gNB_Intra-DU_Handover_For_NR-DC_Setup_Not_FWA
    Change FWA Value    50
    Set Test Variable    ${IS_FWA_CHANGED}    ${TRUE}
    Perform Handover With UE Not In FWA
    Prepare Logs With Emil Conversion
    Verify Interaction With CB006733


Activate_NR-DC_A4_measurements_after_successful_transition_of_suspended_UE_in_RRC_INACTIVE_state_to_RRC_CONNECTED
    Prepare Parameters For Ue Inactivity    600    10    5
    Change A4 Threshold    127
    Set Test Variable    ${IS_INACTIVE_CHANGED}    ${TRUE}
    Perform Transition To RRC_Connected With Change A4 Threshold Parameter
    Prepare Logs With Emil Conversion
    Verify Correct Transition And Setup Of Nr Dc


Dynamic_Reconfiguration_Of_NR_DC_SN_Cells_With_Config_Update_Procedures_On_F1_And_Xn_Interfaces
    Set Test Variable    ${IS_TRACKINGAREA_CHANGED}    ${TRUE}
    Perform Tracking Area Update
    Unzip Results
    Find Pcap Files In Subfolders
    Find Syslog Files From Dcap
    Merge Syslog
    Convert Pdml
    Verify Pcap Flow    ${NGCONFIGURATION_TAC_UPDATE}
    Verify Xn Links And Cells Availability


Unsuccessful_XN_Setup_due_to_lack_of_configured_NR_DC_SN_cells
    Block Xnlinks And Cells
    Unsuccessful Xn Setup
    Find Pcap Files In Subfolders
    Convert Pdml
    Verify Pcap Flow    ${XNSETUPS}
    Verify Xn Links And Cells Availability


Blocking_periodical_NR-DC_A4_activation_if_UE_stays_outside_NR-DC_PSCell_coverage_after_ICS
    Set Test Variable    ${IS_CELLS_LOCKED}    ${TRUE}
    One Cell Nrdcsn Unlocked    Locked
    Change A4 Threshold    127
    Start Syslog On VM    ${VM_IP_23}
    Blocking Periodical A4 Activation
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Merge Syslog
    Verify Syslog   ${MA_B1}    /btslog/btslogs_merged/btslog.LOG


Dynamic_removal_of_SN_cell_with_supported_PLMN_from_already_configured_NR-DC_A4_measurements_set
    Set Test Variable    ${IS_CELL_LOCKED}    ${TRUE}
    Set Ran Configuration    ${CURDIR}
    Dynamic Removal Sn Cell With Ue Attached
    Find Pcap Files In Subfolders
    Convert Pdml
    Verify Pcap Flow    ${DYNAMIC_REMOVAL}

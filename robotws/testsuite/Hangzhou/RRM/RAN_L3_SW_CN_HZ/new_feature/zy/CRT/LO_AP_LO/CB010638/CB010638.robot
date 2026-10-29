*** Settings ***

Force Tags    QCD_MN_RAN    QCP_RAN_ET    CB010638    STATE_CONFIGURED    PY39
...           CLOUD_5G_I_LO_AP_LO
...           RAN_5G   RAN_5G_TDD    SBTS00

Documentation
...
...      INTRODUCTION:  CB010638 modifies criteria used for selection of low loaded Cells to be switched off or for which Tx paths to be reduced
...                     in order to save energy by considering ongoing Priority Access (PA) calls. Such Cells from now will be excluded from
...                     Power Saving. In this testplan, the mechanism for detecting the various Priority Access calls (with and without PDU
...                     session) is verified together with it's resulting effect of excluding the cell in question from power saving.
...
...                     CB010638 also extends the way of recognition of Emergency calls without DRB established, and such exclusion from
...                     power saving is also verified in this testplan.
...
...                     Additionally, CB010638 introduces new PM counters allowing operator to identify Cell(s) most often excluded from power
...                     saving due to blocking conditions: CMAS/ETWS broadcasting, Emergency and Priority Access calls ongoing. All such new
...                     PM counters are verified in this testplan.
...
...                     New NIDD parameter 'powerSavingAvoidanceForPACalls' is introduced for activating/controlling the feature, which is
...                     also verified.
...
...      TEST SET NAME: CB010638
...
...      TESTING SCOPE: CB010638-SR-A-B1, CB010638-SR-A-B3, CB010638-SR-A-B4, CB010638-SR-A-B5
...
...      PRECONDITIONS: Configurations described in test instances. Backlog level preconditions handled
...                     via FOT schedule planning
...
...      DEPENDENCIES:  CB010638 CFAM chapter 1.3.4 Feature Dependencies
...
...      TEST INSTANCE SPECIFIC NOTES:
...        Case 1: CB010638-A-B1_001_highPriorityAccess_PA_call_excludes_single_cell_with_lowest_lbpsCellSOOrder_from_power_saving
...        TEST CASE NAME - CB010638-A-B1_001_highPriorityAccess_PA_call_excludes_single_cell_with_lowest_lbpsCellSOOrder_from_power_saving
...        Purpose: This testcase verifies single cell exclusion from TX muting when highPriorityAcces connection is ongoing
...        Case 2: CB010638-A-B1_002_mps-PriorityAccess_mcs-PriorityAccess_PA_calls_exclude_from_cell_switch_off_when_all_lbpsCellSOOrder_equal_to_10
...        TEST CASE NAME - CB010638-A-B1_002_mps-PriorityAccess_mcs-PriorityAccess_PA_calls_exclude_from_cell_switch_off_when_all_lbpsCellSOOrder_eq
...        Purpose: This testcase verifies all cells with ongoing PA call exlcusion from multiple cell switch off decision
...        Case 3: CB010638-A-B1_003_mix_of_PA_and_EM_calls_excludes_multiple_cells_from_cell_switch_off
...        TEST CASE NAME - CB010638-A-B1_003_mix_of_PA_and_EM_calls_excludes_multiple_cells_from_cell_switch_off
...        Purpose: This testcase verifies cell exclusion from cell switch off decisions with multiple different PA and emergency
...                 connections ongoing
...        Case 4: CB010638-A-B1_004_PA_and_EM_calls_triggered_by_priority_callback
...        TEST CASE NAME - CB010638-A-B1_004_PA_and_EM_calls_triggered_by_priority_callback
...        Purpose: This testcase aims to validate the exclusion behavior of cells from certain power-saving mechanisms
...                 when priority access (PA) and emergency (EM) calls are triggered by priority callbacks.
...        Case 5: CB010638-A-B1_005_interaction_with_CB008745_determine_cell_switch_off_list
...        TEST CASE NAME - CB010638-A-B1_005_interaction_with_CB008745_determine_cell_switch_off_list
...        Purpose: This testcase verifies cell exclusion due PA connection works correctly when CB008745 is in use. That is,
...                 lbpsMonWinForCellSOff and lbpsSOffTrRule parameters are configured.
...        Case 6: CB010638-A-B1_006_PA_RRC_connection_establishes_QoS_Flow_with_non_PA_ARP
...        TEST CASE NAME - CB010638-A-B1_006_PA_RRC_connection_establishes_QoS_Flow_with_non_PA_ARP
...        Purpose: This test verifies that a single cell is excluded to save energy by establishing QoS Flow
...                 with ARP outside the allowed range for the PA call.
...        Case 7: CB010638-A-B1_007_Robustness_multiple_online_modification_of_powerSavingAvoidanceForPACalls
...        TEST CASE NAME - CB010638-A-B1_007_Robustness_multiple_online_modification_of_powerSavingAvoidanceForPACalls
...        Purpose: This testcase verifies online modification of feature activation flag powerSavingAvoidanceForPACalls
...        Case 10: CB010638-A-B3_001_SCell_with_carrier_aggregation_PA_call_exclusion_from_cell_switch_off
...        TEST CASE NAME - CB010638-A-B3_001_SCell_with_carrier_aggregation_PA_call_exclusion_from_cell_switch_off
...        Purpose: This testcase verifies that cell, which has been added as Scell for ongoing priority access connection is
...                 excluded from cell switch off according to value of parameter powerSavingAvoidanceForPACalls
...        Case 11: CB010638-A-B3_002_SCell_with_carrier_aggregation_PA_call_exclusion_from_TX_muting
...        TEST CASE NAME - CB010638-A-B3_002_SCell_with_carrier_aggregation_PA_call_exclusion_from_TX_muting
...        Purpose: This testcase verifies that cell, which has been added as Scell for ongoing priority access connection is
...                 excluded from TX muting according to value of parameter powerSavingAvoidanceForPACalls
...        Case 12: CB010638-A-B4_001_CMAS_broadcasting_caused_exclusions_from_power_saving
...        TEST CASE NAME - CB010638-A-B4_001_CMAS_broadcasting_caused_exclusions_from_power_saving
...        Purpose: This testcase verifies new PM counter updates in interaction with CMAS broadcasting
...        Case 13: CB010638-A-B4_002_ETWS_broadcasting_caused_exclusions_from_power_saving
...        TEST CASE NAME - CB010638-A-B4_002_ETWS_broadcasting_caused_exclusions_from_power_saving
...        Purpose: This testcase verifies new PM counter updates in interaction with ETWS broadcasting
...        Case 14: CB010638-A-B4_003_Emergency_call_with_and_without_PDU_session_caused_exclusions_from_power_saving
...        TEST CASE NAME - CB010638-A-B4_003_Emergency_call_with_and_without_PDU_session_caused_exclusions_from_power_saving
...        Purpose: This testcase verifies new PM counter updates in interaction with emergency call
...        Case 15: CB010638-A-B5_001_interaction_with_CB010683_switch_off_method_mixed_mode
...        TEST CASE NAME - CB010638-A-B5_001_interaction_with_CB010683_switch_off_method_mixed_mode
...        Purpose: This testcase verifies that a cell having ongoing RRC connection established with cause  highPriorityAccess
...                 is excluded from Power Saving when CB010683 is in use and power saving method is mixed switch off
...
...       CONTACTS:
...       Author     : Johan Huhta (Nokia) johan.huhta@nokia.com
...       FOT leader : Lukasz Magos (Nokia) <lukasz.magos@nokia.com>
...       CFAM author: Tomasz Sokolowski (Nokia) tomasz.sokolowski@nokia.com
...       EFS author : Xin K. Chen (NSB) xin.k.chen@nokia-sbell.com
...       SW Cplane  : Xianhua Li (NSB) xianhua.li@nokia-sbell.com
...                  : Tian F. Xia (NSB) tian.f.xia@nokia-sbell.com
...                  : Lingli Tang (NSB) lingli.tang@nokia-sbell.com
...       FTL        : Gopi Kandasamy (Nokia) gopi.kandasamy@nokia.com
...
...      REFERENCES: CB010638-SR-A-B1 : https://jiradc.ext.net.nokia.com/browse/FCA_5G_L2L3-151582
...                  CB010638-SR-A-B3 : https://jiradc.ext.net.nokia.com/browse/FCA_5G_L2L3-151837
...                  CB010638-SR-A-B4 : https://jiradc.ext.net.nokia.com/browse/FCA_5G_L2L3-151838
...                  CB010638-SR-A-B5 : https://jiradc.ext.net.nokia.com/browse/FCA_5G_L2L3-163082
...                  CB010638 CFAM: https://gates.nsn-net.net/view/00026af0#o=0
...                  CB008940 FTS: RAN Productization WoWDocuments 6. Feature Documents CB010600-CB010799
...                                CB010638 Approved_Full_Feature_Test_Strategy_CB010638
...
...      TERMS AND ABBREVIATIONS:  -
...
...      HISTORY:  History, current status and TC description is available in repository:
...                https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/blob/master/testsuite/Espoo/ET/CB010638/CB010638.robot
...
...               [21.08.2023] - Created TP
...               [28.08.2023] - Review findings corrected
...               [20.09.2023] - Review completed
...                              https://collab.ext.net.nokia.com/ui#review:id=892650
...                              https://collab.ext.net.nokia.com/ui#review:id=893574

Resource    CB010638_keywords.robot

Suite Setup    Run Keywords    Run    rm -rf /opt/iphy/latest; ln -s /opt/wts/latest/ /opt/iphy/;sudo chown -R ute:ute /opt/wts/latest/ -R
...    AND    Put Swconfig File    ${CURDIR}/cfg/sm_swconfig.txt
...    AND    Update And Put Iphy Xml    input_filepath=${CURDIR}/cfg/iphy.xml
...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}
...    AND    Find Scfc And Fix And Send Full Commissioning    scfc_filename=scfc.xml
...    AND    Reach Onair   lua_cfg=${CURDIR}/cfg/basic_setup.lua
...    AND    Run    mkdir ${OUTPUT_DIR}/json_files
...    AND    Execute Egate Command    cmd=sim_trace amf=1 protocol=ng on

Suite Teardown    Run Keywords   Kill UEs
...    AND    Stop Default Logging
...    AND    stop_simenb_interface_and_stop_default_processes_and_gather_logs_without_infomodel

*** Test Cases ***
CB010638-A-B4_001_CMAS_broadcasting_caused_exclusions_from_power_saving
    [Tags]    c1    crt-true
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies that counter M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS is correctly
    ...               incremented when cell is exluded from cell switch-off due to ongoing CMAS broadcasting
    ...               Also verified is, that when simultaneously priority access connection is ongoing, the
    ...               M55601C00014 counter is not incremented and counter M55601C00012 is.
    ...
    ...  PRECONDITION: gNB with ASIL / ABIO HW (CLOUD_5G_I_LO_AP_LO)
    ...
    ...  AEQE 64T64R Massive MIMO RU's for TDD n78 NR Cells
    ...  AZQU non-massive MIMO RU's for TDD n77 NR Cells
    ...
    ...  NRCELL-1, TDD n78, Massive MIMO
    ...      - actPriorityAccess = True
    ...      - actBeamforming = True
    ...  NRCELL-2, TDD n78, Massive MIMO
    ...      - actPriorityAccess = True
    ...      - actBeamforming = True
    ...  NRCELL-3, TDD n77, non Massive MIMO
    ...      - actPriorityAccess = True
    ...  NRCELL-4, TDD n77, non Massive MIMO
    ...      - actPriorityAccess = True
    ...
    ...  NRBTS.powerSavingAvoidanceForPACalls = PA avoidance PCell enabled
    ...  NRBTS.actCMAS = True
    ...  NRBTS.actMicroDTX = True
    ...  NRBTS.actNrLBPowerSaving = True
    ...  NRBTS.actNrLBmMimoRTXPowerSaving = False
    ...  NRBTS.actNrLBRTXPowerSaving = False
    ...
    ...  NRPGRP-0
    ...      - lbpsSOMethod = cell switch off
    ...      - lbpsLastCellSOEnabled = true
    ...      - lbpsCellList
    ...          - nrCellId = 1
    ...          - lbpsCellSOOrder = 100
    ...          - nrCellId = 2
    ...          - lbpsCellSOOrder = 100
    ...          - nrCellId = 3
    ...          - lbpsCellSOOrder = 100
    ...          - nrCellId = 4
    ...          - lbpsCellSOOrder = 100
    ...
    ...  rdLowLoadSwitchOffDelay = 1 (10s)
    ...
    ...  TEST EXECUTION:
    ...  1. Setup several non PA/EM connections in each NRCELL such, that pgLoad is still below
    ...     lbpsMinLoad
    ...  2. AMF sends NGAP: WRITE-REPLACE WARNING REQUEST to initiate CMAS warning procedure in NRCELL-2 and NRCELL-3
    ...  3. Verify energySavingState of all NRCELLs
    ...  4. Wait for load-based power saving period for NRPGRP-0 to start
    ...  5. After next rdLowLoadSwitchOffDelay expiration, verify energySavingState of all NRCELLs
    ...  6. After graceful cell shutdown procedure is completed, verify energySavingState of all NRCELLs
    ...  7. Wait for next PM counter file generation and verify "NR Cell Availability" PM counter M55601C00012,
    ...     M55601C00013, M55601C00014 and M55601C00015 values from latest full PM counter file
    ...  8. Delta commission load-based power saving period for NRPGRP-0 to start
    ...     in 1 minute (or other applicable time for case flow)
    ...  9. Register UE in NRCELL-2 with RRCSetupRequest:establishmentCause=highPriorityAccess and establish UE context
    ...     without PDU session
    ...  10. Verify energySavingState of all NRCELLs
    ...  11. Wait for load-based power saving period for NRPGRP-0 to start
    ...  12. After next rdLowLoadSwitchOffDelay expiration, verify energySavingState of all NRCELLs
    ...  13. After graceful cell shutdown procedure is completed, verify energySavingState of all NRCELLs
    ...  14. Wait for next PM counter file generation and verify "NR Cell Availability" PM counter M55601C00012,
    ...      M55601C00013, M55601C00014 and M55601C00015 values from latest full PM counter file
    ...
    ...  EXPECTED RESULTS:
    ...  2. gNB sends NGAP: WRITE-REPLACE WARNING RESPONSE to AMF indicating successful CMAS notification broadcasting
    ...  3. All cells are in notEnergySaving state
    ...  5. NRCELL energySavingState values:
    ...     - NRCELL-1.energySavingState = switching off
    ...     - NRCELL-2.energySavingState = notEnergySaving
    ...     - NRCELL-3.energySavingState = notEnergySaving
    ...     - NRCELL-4.energySavingState = switching off
    ...  6. NRCELL energySavingState values:
    ...     - NRCELL-1.energySavingState = energySaving
    ...     - NRCELL-2.energySavingState = notEnergySaving
    ...     - NRCELL-3.energySavingState = notEnergySaving
    ...     - NRCELL-4.energySavingState = energySaving
    ...  7. PM counter values:
    ...     NRCELL-1:
    ...     M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...     M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...     M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...     M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...     NRCELL-2:
    ...     M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...     M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...     M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = <value correct according to exclusions>
    ...     M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...     NRCELL-3:
    ...     M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...     M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...     M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = <value correct according to exclusions>
    ...     M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...     NRCELL-4:
    ...     M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...     M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...     M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...     M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...  10. All cells are in notEnergySaving state
    ...  12. NRCELL energySavingState values:
    ...      - NRCELL-1.energySavingState = switching off
    ...      - NRCELL-2.energySavingState = notEnergySaving
    ...      - NRCELL-3.energySavingState = notEnergySaving
    ...      - NRCELL-4.energySavingState = switching off
    ...  13. NRCELL energySavingState values:
    ...      - NRCELL-1.energySavingState = energySaving
    ...      - NRCELL-2.energySavingState = notEnergySaving
    ...      - NRCELL-3.energySavingState = notEnergySaving
    ...      - NRCELL-4.energySavingState = energySaving
    ...  14. PM counter values:
    ...      NRCELL-1:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...      NRCELL-2:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = <value correct according to exclusions>
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...      NRCELL-3:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = <value correct according to exclusions>
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...      NRCELL-4:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...
    ...  POSTCONDITION: -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID: ASIL, ABIO
    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_20342,
    ...																			 5G_PM_1093,
    ...                                      CB_FIM_37494,
    ...                                      5G_CP_ARC_ALG_10450,
    ...                                      5G_CP_ARC_ALG_10821,
    ...                                      5G_CP_OTH_14481,
    ...                                      5G_CP_OTH_14482
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       NON-REQUIREMENTS-BASED TESTS:  -
    ...       PM COUNTERS:                   M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...                                      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...                                      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS
    ...                                      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS
    ...       BACKLOG ID:                    FCA_5G_L2L3-151838
    ...
    ...  FEATURE SUB-ITEMS: CB010638-A
    ...
    ...  DEFINITIONS FROM THE TEST PLAN:  -
    ...
    ...  REQUIRED LOGS: Simulator traces, Wireshark logs, PM counter files
    ...
    ...  CONTACTS:    Refer to test plan section
    ...
    ...  REFERENCES:  CB010638 CFAM
    ...
    ...  HISTORY:     History, current status and TC description is available in repository:
    ...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/
    ...
    ...              [21.08.2023] - Created TC
    ...              [28.08.2023] - Review findings corrected
    ...              [29.08.2023] - TC review completed : https://collab.ext.net.nokia.com/ui#review:id=892650
    ...              [xx.xx.2023] - TC GIT review completed : https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/86944

    [Setup]    Run Keywords    Start Testcase Logs
    ...        AND             Perform Parameter Commissioning    parameter=actCMAS   value=true
    ...        AND             Setup and connect Infomodel    alias=${TEST_NAME}
    ...        AND             Reset Power Saving Period To Init
    ...        AND             Wait For Next Full Pm Interval

    Wait and Verify energySavingState of all NRCELLs
    ...    waitTimer=0
    ...    cell1State=notEnergySaving
    ...    cell2State=notEnergySaving
    ...    cell3State=notEnergySaving
    ...    cell4State=notEnergySaving
    ...    alias=${TEST_NAME}
    Configure Power Saving Period To Start    inMinutes=2
    Setup UE Initial Context Without PDU Session    ue=2    nrcell=1    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=3    nrcell=2    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=13    nrcell=3    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=14    nrcell=4    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=4    nrcell=1    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=5    nrcell=2    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=15    nrcell=3    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=16    nrcell=4    establishment_cause=mo-Signalling
    Start CMAS Broadcast for NRCELL    nrcell=2,3
    Wait for nrCell energySavingState    nrcell=1    energySavingState=switchingOff    alias=${TEST_NAME}    timeout=130
    Wait and Verify energySavingState of all NRCELLs
    ...    waitTimer=0
    ...    cell1State=switchingOff
    ...    cell2State=notEnergySaving
    ...    cell3State=notEnergySaving
    ...    cell4State=switchingOff
    ...    alias=${TEST_NAME}
    Wait for nrCell energySavingState    nrcell=1    energySavingState=energySaving    alias=${TEST_NAME}    timeout=130
    Wait and Verify energySavingState of all NRCELLs
    ...    waitTimer=0
    ...    cell1State=energySaving
    ...    cell2State=notEnergySaving
    ...    cell3State=notEnergySaving
    ...    cell4State=energySaving
    ...    alias=${TEST_NAME}
    Verify Ue State    ue_id=3    expected_state=active
    Verify Ue State    ue_id=5    expected_state=active
    Verify Ue State    ue_id=13    expected_state=active
    Verify Ue State    ue_id=15    expected_state=active
    Verify Ue State    ue_id=2    expected_state=off
    Verify Ue State    ue_id=4    expected_state=off
    Verify Ue State    ue_id=14    expected_state=off
    Verify Ue State    ue_id=16    expected_state=off
    Reset Power Saving Period To Init
    ${pm_counter_file}=    Wait and Get Latest PM Counter File
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  >3  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00014  <8  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  >3  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00014  <8  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counter_file}
    Deregister UEs
    Configure Power Saving Period To Start    inMinutes=2
    Setup UE Initial Context Without PDU Session    ue=2    nrcell=1    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=3    nrcell=2    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=13    nrcell=3    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=14    nrcell=4    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=4    nrcell=1    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=5    nrcell=2    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=15    nrcell=3    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=16    nrcell=4    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=1    nrcell=2   establishment_cause=highPriorityAccess
    Wait for nrCell energySavingState    nrcell=1    energySavingState=energySaving    alias=${TEST_NAME}    timeout=300
    Wait and Verify energySavingState of all NRCELLs
    ...    waitTimer=0
    ...    cell1State=energySaving
    ...    cell2State=notEnergySaving
    ...    cell3State=notEnergySaving
    ...    cell4State=energySaving
    ...    alias=${TEST_NAME}
    ${pm_counter_file}=    Wait and Get Latest PM Counter File
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  >8  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00012  <12  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  >8  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00014  <12  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counter_file}

    [Teardown]    Run Keywords    Stop CMAS Broadcast for NRCELL    nrcell=2,3
    ...           AND             Perform Parameter Commissioning    parameter=actCMAS   value=false
    ...           AND             Teardown Infomodel    alias=${TEST_NAME}
    ...           AND             Deregister UEs
    ...           AND             Collect Testcase Logs


CB010638-A-B4_002_ETWS_broadcasting_caused_exclusions_from_power_saving
    [Tags]    c2
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies that counter M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS is correctly
    ...               incremented when cell is exluded from TX muting due to ongoing ETWS broadcasting
    ...               Also verified is, that when simultaneously priority access connection is ongoing, the
    ...               M55601C00015 counter is not incremented and counter M55601C00013 is.
    ...
    ...  PRECONDITION: gNB with ASIL / ABIO HW (CLOUD_5G_I_LO_AP_LO)
    ...
    ...  AEQE 64T64R Massive MIMO RU's for TDD n78 NR Cells
    ...  AZQU non-massive MIMO RU's for TDD n77 NR Cells
    ...
    ...  NRCELL-1, TDD n78, Massive MIMO
    ...      - actPriorityAccess = True
    ...      - actBeamforming = True
    ...  NRCELL-2, TDD n78, Massive MIMO
    ...      - actPriorityAccess = True
    ...      - actBeamforming = True
    ...  NRCELL-3, TDD n77, non Massive MIMO
    ...      - actPriorityAccess = True
    ...  NRCELL-4, TDD n77, non Massive MIMO
    ...      - actPriorityAccess = True
    ...
    ...  NRBTS.powerSavingAvoidanceForPACalls = PA avoidance PCell enabled
    ...  NRBTS.actETWS = True
    ...  NRBTS.actMicroDTX = True
    ...  NRBTS.actNrLBmMimoRTXPowerSaving = True
    ...  NRBTS.actNrLBRTXPowerSaving = True
    ...
    ...  NRPGRP-0
    ...      - lbpsSOMethod = TX switch off
    ...      - lbpsLastCellSOEnabled = true
    ...      - lbpsCellList
    ...          - nrCellId = 1
    ...          - lbpsCellSOOrder = 100
    ...          - nrCellId = 2
    ...          - lbpsCellSOOrder = 100
    ...          - nrCellId = 3
    ...          - lbpsCellSOOrder = 100
    ...          - nrCellId = 4
    ...          - lbpsCellSOOrder = 100
    ...
    ...  rdLowLoadSwitchOffDelay = 1 (10s)
    ...
    ...  TEST EXECUTION:
    ...  1. Setup several non PA/EM connections in each NRCELL such, that pgLoad is still below
    ...     lbpsMinLoad
    ...  2. AMF sends NGAP: WRITE-REPLACE WARNING REQUEST to initiate ETWS Primary notification procedure in
    ...     NRCELL-1 and NRCELL-4
    ...  3. Verify energySavingState of all NRCELLs
    ...  4. Wait for load-based power saving period for NRPGRP-0 to start
    ...  5. After next rdLowLoadSwitchOffDelay expiration, verify energySavingState of all NRCELLs
    ...  6. After several rdLowLoadSwitchOffDelay expirations, verify energySavingState of all NRCELLs
    ...  7. Wait for next PM counter file generation and verify "NR Cell Availability" PM counter M55601C00012,
    ...     M55601C00013, M55601C00014 and M55601C00015 values from latest full PM counter file
    ...  8. Delta commission load-based power saving period for NRPGRP-0 to start
    ...     in 1 minute (or other applicable time for case flow)
    ...  9. Register UE in NRCELL-1 with RRCSetupRequest:establishmentCause=highPriorityAccess and establish UE context
    ...     without PDU session
    ...  10. Verify energySavingState of all NRCELLs
    ...  11. Wait for load-based power saving period for NRPGRP-0 to start
    ...  12. After next rdLowLoadSwitchOffDelay expiration, verify energySavingState of all NRCELLs
    ...  13. After several rdLowLoadSwitchOffDelay expirations, verify energySavingState of all NRCELLs
    ...  14. Wait for next PM counter file generation and verify "NR Cell Availability" PM counter M55601C00012,
    ...      M55601C00013, M55601C00014 and M55601C00015 values from latest full PM counter file
    ...
    ...  EXPECTED RESULTS:
    ...  2. gNB sends NGAP: WRITE-REPLACE WARNING RESPONSE to AMF indicating successful ETWS notification broadcasting
    ...  3. All cells are in notEnergySaving state
    ...  5. NRCELL energySavingState values:
    ...     - NRCELL-1.energySavingState = notEnergySaving
    ...     - NRCELL-2.energySavingState = reducedEnergySaving
    ...     - NRCELL-3.energySavingState = reducedEnergySaving
    ...     - NRCELL-4.energySavingState = notEnergySaving
    ...  6. NRCELL energySavingState values:
    ...     - NRCELL-1.energySavingState = notEnergySaving
    ...     - NRCELL-2.energySavingState = reducedEnergySaving
    ...     - NRCELL-3.energySavingState = reducedEnergySaving
    ...     - NRCELL-4.energySavingState = notEnergySaving
    ...  7. PM counter values:
    ...     NRCELL-1:
    ...     M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...     M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...     M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...     M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = <value correct according to exclusions>
    ...     NRCELL-2:
    ...     M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...     M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...     M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...     M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...     NRCELL-3:
    ...     M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...     M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...     M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...     M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...     NRCELL-4:
    ...     M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...     M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...     M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...     M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = <value correct according to exclusions>
    ...  10. All cells are in notEnergySaving state
    ...  12. NRCELL energySavingState values:
    ...      - NRCELL-1.energySavingState = switching off
    ...      - NRCELL-2.energySavingState = notEnergySaving
    ...      - NRCELL-3.energySavingState = notEnergySaving
    ...      - NRCELL-4.energySavingState = switching off
    ...  13. NRCELL energySavingState values:
    ...      - NRCELL-1.energySavingState = energySaving
    ...      - NRCELL-2.energySavingState = notEnergySaving
    ...      - NRCELL-3.energySavingState = notEnergySaving
    ...      - NRCELL-4.energySavingState = energySaving
    ...  14. PM counter values:
    ...      NRCELL-1:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = <value correct according to exclusions>
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...      NRCELL-2:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...      NRCELL-3:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...      NRCELL-4:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = <value correct according to exclusions>
    ...
    ...  POSTCONDITION: -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID: ASIL, ABIO
    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_20342,
    ...                                      5G_PM_1093,
    ...                                      CB_FIM_37495,
    ...                                      5G_CP_ARC_ALG_10821,
    ...                                      5G_CP_OTH_14481,
    ...                                      5G_CP_OTH_14482
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       NON-REQUIREMENTS-BASED TESTS:  -
    ...       PM COUNTERS:                   M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...                                      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...                                      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS
    ...                                      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS
    ...       BACKLOG ID:                    FCA_5G_L2L3-151838
    ...
    ...  FEATURE SUB-ITEMS: CB010638-A
    ...
    ...  DEFINITIONS FROM THE TEST PLAN:  -
    ...
    ...  REQUIRED LOGS: Simulator traces, Wireshark logs, PM counter files
    ...
    ...  CONTACTS:    Refer to test plan section
    ...
    ...  REFERENCES:  CB010638 CFAM
    ...
    ...  HISTORY:     History, current status and TC description is available in repository:
    ...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/
    ...
    ...              [21.08.2023] - Created TC
    ...              [28.08.2023] - Review findings corrected
    ...              [29.08.2023] - TC review completed : https://collab.ext.net.nokia.com/ui#review:id=892650
    ...              [xx.xx.2023] - TC GIT review completed : https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/86944

    [Setup]    Run Keywords    Start Testcase Logs
    ...        AND             Perform Parameter Commissioning    parameter=actETWS   value=true
    ...        AND             Setup and connect Infomodel    alias=${TEST_NAME}
    ...        AND             Configure Power Saving Parameters    parameterList=false,true,true,false,TX switch off
    ...        AND             Reset Power Saving Period To Init
    ...        AND             Wait For Next Full Pm Interval

    Wait and Verify energySavingState of all NRCELLs
    ...    waitTimer=0
    ...    cell1State=notEnergySaving
    ...    cell2State=notEnergySaving
    ...    cell3State=notEnergySaving
    ...    cell4State=notEnergySaving
    ...    alias=${TEST_NAME}
    Configure Power Saving Period To Start    inMinutes=2
    Setup UE Initial Context Without PDU Session    ue=2    nrcell=1    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=3    nrcell=2    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=13    nrcell=3    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=14    nrcell=4    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=4    nrcell=1    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=5    nrcell=2    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=15    nrcell=3    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=16    nrcell=4    establishment_cause=mo-Signalling
    Start ETWS Broadcast for NRCELL    nrcell=1,4
    Wait for nrCell energySavingState    nrcell=2    energySavingState=reducedEnergySaving    alias=${TEST_NAME}    timeout=130
    Wait and Verify energySavingState of all NRCELLs
    ...    waitTimer=0
    ...    cell1State=notEnergySaving
    ...    cell2State=reducedEnergySaving
    ...    cell3State=reducedEnergySaving
    ...    cell4State=notEnergySaving
    ...    alias=${TEST_NAME}
    Reset Power Saving Period To Init
    ${pm_counter_file}=    Wait and Get Latest PM Counter File
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  >0  CELL_TX_PATH_RED_EXCL_PWS
    ...  M55601C00015  <5  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  >0  CELL_TX_PATH_RED_EXCL_PWS
    ...  M55601C00015  <5  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counter_file}
    Deregister UEs
    Configure Power Saving Period To Start    inMinutes=2
    Setup UE Initial Context Without PDU Session    ue=2    nrcell=1    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=3    nrcell=2    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=13    nrcell=3    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=14    nrcell=4    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=4    nrcell=1    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=5    nrcell=2    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=15    nrcell=3    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=16    nrcell=4    establishment_cause=mo-Signalling
    Setup UE Initial Context Without PDU Session    ue=1    nrcell=1   establishment_cause=highPriorityAccess
    Wait for nrCell energySavingState    nrcell=2    energySavingState=reducedEnergySaving   alias=${TEST_NAME}    timeout=300
    Wait and Verify energySavingState of all NRCELLs
    ...    waitTimer=0
    ...    cell1State=notEnergySaving
    ...    cell2State=reducedEnergySaving
    ...    cell3State=reducedEnergySaving
    ...    cell4State=notEnergySaving
    ...    alias=${TEST_NAME}
    ${pm_counter_file}=    Wait and Get Latest PM Counter File
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  >10  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00013  <14  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  >10  CELL_TX_PATH_RED_EXCL_PWS
    ...  M55601C00015  <14  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counter_file}

    [Teardown]    Run Keywords    Stop ETWS Broadcast for NRCELL    nrcell=2,3
    ...           AND             Perform Parameter Commissioning    parameter=actETWS   value=false
    ...           AND             Configure Power Saving Parameters    parameterList=true,false,false,false,cell switch off
    ...           AND             Teardown Infomodel    alias=${TEST_NAME}
    ...           AND             Deregister UEs
    ...           AND             Collect Testcase Logs


CB010638-A-B4_003_Emergency_call_with_and_without_PDU_session_caused_exclusions_from_power_saving
    [Tags]    c3
    [Documentation]
    ...  DESCRIPTION: This testcase verifies that counter M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC is correctly
    ...               incremented when cell is exluded from TX mujting  due to ongoing emergency call with and
    ...               without PDU session
    ...
    ...  PRECONDITION: gNB with ASIL / ABIO HW (CLOUD_5G_I_LO_AP_LO)
    ...
    ...  AEQE 64T64R Massive MIMO RU's for TDD n78 NR Cells
    ...  AZQU non-massive MIMO RU's for TDD n77 NR Cells
    ...
    ...  NRCELL-1, TDD n78, Massive MIMO
    ...      - actBeamforming = True
    ...      - actIMSEmergency = True
    ...      - arpPrioEmergencyCall = 1
    ...  NRCELL-2, TDD n78, Massive MIMO
    ...      - actBeamforming = True
    ...  NRCELL-3, TDD n77, non Massive MIMO
    ...  NRCELL-4, TDD n77, non Massive MIMO
    ...      - actIMSEmergency = True
    ...      - arpPrioEmergencyCall = 1
    ...
    ...  NRBTS.powerSavingAvoidanceForPACalls = PA avoidance disabled
    ...  NRBTS.actMicroDTX = True
    ...  NRBTS.actNrLBmMimoRTXPowerSaving = True
    ...  NRBTS.actNrLBRTXPowerSaving = True
    ...
    ...  NRPGRP-0
    ...      - lbpsSOMethod = TX switch off
    ...      - lbpsLastCellSOEnabled = true
    ...      - lbpsCellList
    ...          - nrCellId = 1
    ...          - lbpsCellSOOrder = 100
    ...          - nrCellId = 2
    ...          - lbpsCellSOOrder = 100
    ...          - nrCellId = 3
    ...          - lbpsCellSOOrder = 100
    ...          - nrCellId = 4
    ...          - lbpsCellSOOrder = 100
    ...
    ...  rdLowLoadSwitchOffDelay = 1 (10s)
    ...
    ...  TEST EXECUTION:
    ...  1. Setup several non PA/EM connections in each NRCELL such, that pgLoad is still below
    ...     lbpsMinLoad
    ...  2. Register UE's in NRCELL-1 and NRCELL-4 with RRCSetupRequest:establishmentCause=emergency
    ...  3. Verify energySavingState of all NRCELLs
    ...  4. Wait for load-based power saving period for NRPGRP-0 to start
    ...  5. After next rdLowLoadSwitchOffDelay expiration, verify energySavingState of all NRCELLs
    ...  6. After several rdLowLoadSwitchOffDelay expirations, verify energySavingState of all NRCELLs
    ...  7. For emergency connection UE in NRCELL-1, Setup PDU session with one QoS Flow having ARP priority = 2
    ...  8. For emergency connection UE in NRCELL-4, Setup PDU session with one QoS Flow having ARP priority = 3
    ...  9. After next rdLowLoadSwitchOffDelay expiration, verify energySavingState of all NRCELLs
    ...  10. Wait for next PM counter file generation and verify "NR Cell Availability" PM counter M55601C00012,
    ...      M55601C00013, M55601C00014 and M55601C00015 values from latest full PM counter file
    ...
    ...  EXPECTED RESULTS:
    ...  2. gNB sends NGAP: WRITE-REPLACE WARNING RESPONSE to AMF indicating successful ETWS notification broadcasting
    ...  3. All cells are in notEnergySaving state
    ...  5. NRCELL energySavingState values:
    ...     - NRCELL-1.energySavingState = notEnergySaving
    ...     - NRCELL-2.energySavingState = reducedEnergySaving
    ...     - NRCELL-3.energySavingState = reducedEnergySaving
    ...     - NRCELL-4.energySavingState = notEnergySaving
    ...     (NOTE: NRCELL-2 intermediate state 'switchingOffRTX' may not be observable via Web EM)
    ...  6. NRCELL energySavingState values:
    ...     - NRCELL-1.energySavingState = notEnergySaving
    ...     - NRCELL-2.energySavingState = reducedEnergySaving
    ...     - NRCELL-3.energySavingState = reducedEnergySaving
    ...     - NRCELL-4.energySavingState = notEnergySaving
    ...  9. NRCELL energySavingState values:
    ...     - NRCELL-1.energySavingState = notEnergySaving
    ...     - NRCELL-2.energySavingState = reducedEnergySaving
    ...     - NRCELL-3.energySavingState = reducedEnergySaving
    ...     - NRCELL-4.energySavingState = reducedEnergySaving
    ...  10. PM counter values:
    ...      NRCELL-1:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = <value correct according to exclusions>
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...      NRCELL-2:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...      NRCELL-3:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = 0
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...      NRCELL-4:
    ...      M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC = 0
    ...      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC = <value correct according to exclusions>
    ...      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS = 0
    ...      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS = 0
    ...
    ...  POSTCONDITION: -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID: ASIL, ABIO
    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_20342,
    ...                                      CB_FIM_37496,
    ...                                      5G_CP_ARC_ALG_10725,
    ...                                      5G_CP_ARC_ALG_10821,
    ...                                      5G_CP_OTH_14481,
    ...                                      5G_CP_OTH_14482
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       NON-REQUIREMENTS-BASED TESTS:  -
    ...       PM COUNTERS:                   M55601C00012 - CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...                                      M55601C00013 - CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...                                      M55601C00014 - CELL_SWITCH_OFF_EXCL_PWS
    ...                                      M55601C00015 - CELL_TX_PATH_RED_EXCL_PWS
    ...       BACKLOG ID:                    FCA_5G_L2L3-151838
    ...
    ...  FEATURE SUB-ITEMS: CB010638-A
    ...
    ...  DEFINITIONS FROM THE TEST PLAN:  -
    ...
    ...  REQUIRED LOGS: Simulator traces, Wireshark logs, PM counter files
    ...
    ...  CONTACTS:    Refer to test plan section
    ...
    ...  REFERENCES:  CB010638 CFAM
    ...
    ...  HISTORY:     History, current status and TC description is available in repository:
    ...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/
    ...
    ...              [21.08.2023] - Created TC
    ...              [28.08.2023] - Review findings corrected
    ...              [29.08.2023] - TC review completed : https://collab.ext.net.nokia.com/ui#review:id=892650
    ...              [xx.xx.2023] - TC GIT review completed : https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/86944

    [Setup]    Run Keywords    Start Testcase Logs
    ...        AND             Setup and connect Infomodel    alias=${TEST_NAME}
    ...        AND             Configure Power Saving Parameters    parameterList=false,true,true,false,TX switch off
    ...        AND             Reset Power Saving Period To Init
    ...        AND             Wait For Next Full Pm Interval

    Configure Power Saving Period To Start    inMinutes=2
    Setup UE Initial Context Without PDU Session    ue=1    nrcell=1    establishment_cause=emergency
    Setup UE Initial Context Without PDU Session    ue=11    nrcell=4    establishment_cause=emergency
    Wait and Verify energySavingState of all NRCELLs
    ...    waitTimer=0
    ...    cell1State=notEnergySaving
    ...    cell2State=notEnergySaving
    ...    cell3State=notEnergySaving
    ...    cell4State=notEnergySaving
    ...    alias=${TEST_NAME}
    Wait for nrCell energySavingState    nrcell=2    energySavingState=reducedEnergySaving   alias=${TEST_NAME}    timeout=130
    Wait and Verify energySavingState of all NRCELLs
    ...    waitTimer=60
    ...    cell1State=notEnergySaving
    ...    cell2State=reducedEnergySaving
    ...    cell3State=reducedEnergySaving
    ...    cell4State=notEnergySaving
    ...    alias=${TEST_NAME}
    Establish PDU Session    ue=1    arpPriority=1
    Establish PDU Session    ue=11    arpPriority=5
    Wait for nrCell energySavingState    nrcell=4    energySavingState=reducedEnergySaving   alias=${TEST_NAME}    timeout=130
    Wait and Verify energySavingState of all NRCELLs
    ...    waitTimer=30
    ...    cell1State=notEnergySaving
    ...    cell2State=reducedEnergySaving
    ...    cell3State=reducedEnergySaving
    ...    cell4State=reducedEnergySaving
    ...    alias=${TEST_NAME}
    ${pm_counter_file}=    Wait and Get Latest PM Counter File
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  >7  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00013  <11  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  0  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55601C00012  0  CELL_SWITCH_OFF_EXCL_PAC_EMC
    ...  M55601C00013  >2  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00013  <6  CELL_TX_PATH_RED_EXCL_PAC_EMC
    ...  M55601C00014  0  CELL_SWITCH_OFF_EXCL_PWS
    ...  M55601C00015  0  CELL_TX_PATH_RED_EXCL_PWS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counter_file}

    [Teardown]    Run Keywords    Configure Power Saving Parameters    parameterList=true,false,false,false,cell switch off
    ...           AND             Teardown Infomodel    alias=${TEST_NAME}
    ...           AND             Deregister UEs
    ...           AND             Collect Testcase Logs

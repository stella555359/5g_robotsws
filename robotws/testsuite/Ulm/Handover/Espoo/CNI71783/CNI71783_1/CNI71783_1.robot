*** Settings ***

Documentation
...
...      INTRODUCTION: This CNI implements solution for pronto PR578550, which was raised due to call drops
...      in IRAT Handover from 5G to LTE when 4G is under MOCN configuration. Solution brings new configurable eNB secondary
...      PLMN list (NIDD secondaryPlmnIdList parameter) to allow the operator to optionally define up to 5 PLMN IDs per neighbor
...      LTE cell in addition to the eNB primary PLMN-ID.
...
...      This new list of PLMNs is used in an appropriate way so that, the UE A2 and B2 measurements are configured by matching
...      the selected serving PLMN with all PLMN's configured in E-UTRAN adjacent cell parameters ecgiPlmn and secondaryPlmnIdList,
...      and if any match is found the corresponding measurement is configured.
...
...      During the handover to LTE, the PLMN Id in "Handover Required" is filled as:
...       - globalENB-ID     : ecgiPlmn of target E-UTRAN adjacent cell
...       - selected-EPS-TAI : selected serving PLMN
...
...      TEST SET NAME: CNI71783
...
...      TESTING SCOPE: CNI71783 A2/B2 measurement event configuration and Handover Required message contents
...
...      PRECONDITIONS: 5G_RAN_USR_RRM_14386, 5G_RAN_USR_RRM_14387, 5G_RAN_USR_RRM_14388
...
...      DEPENDENCIES:  -
...
...      TEST INSTANCE SPECIFIC NOTES:
...        Case 1: CNI71783_001_IRAT_Handover_to_EUTRAN_cell_with_ecgiPlmn_or_secondaryPlmnIdList_matching_selectedPLMN_Identity
...        TEST CASE NAME - CNI71783_001_IRAT_Handover_to_EUTRAN_cell_with_ecgiPlmn_or_secondaryPlmnIdList_matching_selectedPLMN_Identity
...        Purpose: This testcase verifies that A2 and B2 measurements for I-RAT handover to LTE are correctly
...        configured and PLMN Id information is correctly filled in "Handover required" message in case
...        RAN sharing is used on LTE side
...
...        Case 4: CNI71783_004_A2_measurement_configuration_with_no_matching_ecgiPlmn_or_secondaryPlmnIdList
...        TEST CASE NAME - CNI71783_004_A2_measurement_configuration_with_no_matching_ecgiPlmn_or_secondaryPlmnIdList
...        Purpose: This testcase verifies that A2 measurement is not configured for UE in case mobility restriction
...        list is provided by AMF and UE's selected serving PLMN does not match with any configured
...        ecgiPlmn or secondaryPlmnIdList of adjacent EUTRAN cells
...
...        Case 5: CNI71783_005_A2_measurement_configuration_with_matching_EUTRAN_cell_blacklisted
...        TEST CASE NAME - CNI71783_005_A2_measurement_configuration_with_matching_EUTRAN_cell_blacklisted
...        Purpose: This testcase verifies that A2 measurement is not configured for UE in case selected
...        serving PLMN matches with secondaryPlmnIdList but adjacent EUTRAN cell is blacklisted
...
...        Case 6: CNI71783_006_B2_measurement_configuration_with_no_matching_ecgiPlmn_or_secondaryPlmnIdList
...        TEST CASE NAME - CNI71783_006_B2_measurement_configuration_with_no_matching_ecgiPlmn_or_secondaryPlmnIdList
...        Purpose: This testcase verifies that B2 measurement is not configured for UE in case mobility restriction
...        list is provided by AMF and UE's selected serving PLMN does not match with any configured
...        ecgiPlmn or secondaryPlmnIdList of adjacent EUTRAN cells
...
...      CONTACTS:
...       Author: Huhta, Johan (Nokia - FI/Espoo) <johan.huhta@nokia.com>
...       Author: Bolar, Roohi (Nokia - FI/Espoo) <roohi.bolar@nokia.com>
...       FOT leader: Mennerich, Wolfgang (Nokia - DE/Ulm) <wolfgang.mennerich@nokia.com>
...       SFS author: Baron, Roland (Nokia - FR/Paris-Saclay) <roland.baron@nokia.com>
...       EFS author: Aalto, Risto (Nokia - FI/Espoo) <risto.aalto@nokia.com>
...       SW Cplane: Bjorklund, Tony (Nokia - FI/Espoo) <tony.bjorklund@nokia.com>
...       SyVe: Bailliere, Xavier (Nokia - FR/Paris-Saclay) <xavier.bailliere@nokia.com>
...
...      REFERENCES: CNI-71783 : https://jira3.ext.net.nokia.com/browse/CNI-71783
...                  5G_RAN_USR_RRM_14386, 5G_RAN_USR_RRM_14387, 5G_RAN_USR_RRM_14388, 5G_CP_ARC_ALG_4299
...
...      TERMS AND ABBREVIATIONS:  -
...
...      HISTORY:  History, current status and TC description is available in repository:
...                <link_to_testsuite>
...
...                [14.02.2022] - Created TC
...                [02.03.2022] - Updated with review comments
...                [07.03.2022] - Review approved https://collab.ext.net.nokia.com/ui#review:id=852882

#Library    Dialogs

Resource        ../../../../resources/Common/reporting.robot

Resource   basic_ap_test_keywords.robot
Variables  basic_ap_test_variables.py

Suite Setup    Run Keywords    Add AP RadParam
...    AND    Enable CP runtime logging
...    AND    Update And Put Iphy Xml    input_filepath=${IPHY_XML}
...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}
...    AND    Find Scfc And Fix And Send Full Commissioning    scfc_filename=scfc.xml
...    AND    Reach Onair   lua_cfg=${EPCSIM_CFG_PATH}
...    AND    Execute Egate Command  cmd=sim_trace amf=1 protocol=ng on

Suite Teardown    Run Keywords   Teardown Egate And Collect Logs
...    AND    Stop Default Logging
...    AND    stop_simenb_interface_and_stop_default_processes_and_gather_logs_without_infomodel

*** Variables ***
${SWCONFIG}                  ${CURDIR}/cfg/gnb_swconfig.txt
${SWCONFIG_AP}               ${CURDIR}/cfg/ap_swconfig.txt
${IPHY_DIR_PATH}             /opt/iphy
${EPCSIM_DIR_PATH}           ${IPHY_DIR_PATH}/latest
${EPCSIM_CFG_PATH}           ${CURDIR}/cfg/basic_setup.cfg
${IPHY_XML}                  ${CURDIR}/cfg/iphy.xml
${AP_XML_PATH}               ${CURDIR}/cfg/AirPhoneConfig_TDD.xml
# hardcoded frame content checking may cause update need in case
# Handover Required content changes...
${GLOBAL_ENBID_PLMN1_1}        ((frame[97:7] == 40:13:41:98:00:00:01)
${EPSTAI_CELL1_PLMN1_1}        (frame[104:6] == 20:13:41:98:00:de))
${EPSTAI_CELL2_PLMN2_1}        (frame[104:6] == 20:13:41:09:00:df))
${TGT_CELLID_PLMN1_1}          (frame[917:7] == 00:13:41:98:00:01:20)
${GLOBAL_ENBID_PLMN1_2}        ((frame[99:7] == 40:13:41:98:00:00:01)
${EPSTAI_CELL1_PLMN1_2}        (frame[106:6] == 20:13:41:98:00:de))
${EPSTAI_CELL2_PLMN2_2}        (frame[106:6] == 20:13:41:09:00:df))
${TGT_CELLID_PLMN1_2}          (frame[919:7] == 00:13:41:98:00:01:20)
${IRAT_CELL1}                ${GLOBAL_ENBID_PLMN1_1} && ${EPSTAI_CELL1_PLMN1_1} && ${TGT_CELLID_PLMN1_1}
${IRAT_CELL2}                ${GLOBAL_ENBID_PLMN1_2} && ${EPSTAI_CELL2_PLMN2_2} && ${TGT_CELLID_PLMN1_2}
# variables for contents checked from meas_cfg_disp when verifying B2 event
# escape characted needed for spaces in contents (can be removed once collapse_spaces is availabel with
# robot framework 4.1
@{UE1_B2_INCLUDED}           2\ \ \ EUTRAN\ \ 1    3\ \ \ EUTRAN\ \ 2    3\ \ \ EUTRA\ \ EventB2
@{UE2_B2_INCLUDED}           2\ \ \ EUTRAN\ \ 2    3\ \ \ EUTRA\ \ EventB2
@{UE2_B2_EXCLUDED}           EUTRAN\ \ 1
@{UE4_B2_INCLUDED}           2\ \ \ EUTRAN\ \ 2    3\ \ \ EUTRA\ \ EventB2
@{UE4_B2_EXCLUDED}           EUTRAN\ \ 1
@{UE5_B2_INCLUDED}           2\ \ \ NR\ \ \ EventA1    3\ \ \ NR\ \ \ EventA3
@{UE5_B2_EXCLUDED}           EUTRAN\ \ 1    EUTRAN\ \ 2    EventB2

*** Test Cases ***
CNI71783_001_IRAT_Handover_to_EUTRAN_cell_with_ecgiPlmn_or_secondaryPlmnIdList_matching_selectedPLMN_Identity
    [Tags]    TC01
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies that A2 and B2 measurements for I-RAT handover to LTE are correctly
    ...               configured and PLMN Id information is correctly filled in "Handover required" message in case
    ...               RAN sharing is used on LTE side
    ...
    ...               The UE A2 and B2 measurements are configured by matching the selected serving PLMN with all
    ...               PLMN's configured in E-UTRAN adjacent cell parameters ecgiPlmn and secondaryPlmnIdList, and
    ...               if any match is found the corresponding measurement is configured
    ...
    ...               The PLMN Id in "Handover Required" is filled as:
    ...                 - globalENB-ID     : ecgiPlmn of target E-UTRAN adjacent cell
    ...                 - selected-EPS-TAI : selected serving PLMN
    ...
    ...  PRECONDITION: 5G_RAN_USR_RRM_14388 preconditions with modifications
    ...                - PLMN1 : 311:489
    ...                - PLMN2 : 311:490
    ...                - Single Served AMF supports both PLMN1 and PLMN2
    ...                - E-UTRAN cell-1 has earfcnValue=1, ecgiPlmn = PLMN1, secondaryPlmnIdList unconfigured
    ...                - E-UTRAN cell-2 has earfcnValue=2, ecgiPlmn = PLMN1, secondaryPlmnIdList 5 PLMN's including PLMN2/311:490
    ...
    ...  TEST EXECUTION:
    ...  1. Register and Establish PDU session for UE1 in NR cell-1 with:
    ...     - selectedPLMN-Identity PLMN1
    ...     - AMF provided MobilityRestrictionList
    ...       - servingPLMN PLMN1
    ...       - forbiddenAreaInformation PLMN=123:321
    ...  2. Verify UE1 measurement configuration received from gNB
    ...  3. With UE1 : send A2 measurement report
    ...  4. Verify UE1 measurement configuration received from gNB
    ...  5. With UE1 : send B2 measurement report with EUTRAN cell-1 in measResultListEUTRA
    ...  6. Verify content of "Handover Required" message
    ...  7. Register and Establish PDU session for UE2 in NR cell-1 with:
    ...     - selectedPLMN-Identity PLMN2
    ...     - AMF provided MobilityRestrictionList
    ...       - servingPLMN PLMN2
    ...       - forbiddenAreaInformation PLMN=123:321
    ...  8. Verify UE2 measurement configuration received from gNB
    ...  9. With UE2 : send A2 measurement report
    ...  10. Verify UE2 measurement configuration received from gNB
    ...  11. With UE2 : send B2 measurement report with EUTRAN cell-2 in measResultListEUTRA
    ...  12. Verify content of "Handover Required" message
    ...
    ...  EXPECTED RESULTS:
    ...  2. Measurement configuration for UE1
    ...     - A2 event
    ...     [configured as selectedPLMN-Identity PLMN1 == E-UTRAN cell-1 ecgiPlmn]
    ...  4. Measurement configuration for UE1
    ...     - A1 event
    ...     - B2 event for object E-UTRAN cell-1
    ...     - B2 event for object E-UTRAN cell-2
    ...     [configured as selectedPLMN-Identity PLMN1 == E-UTRAN cell-1 & cell-2 ecgiPlmn]
    ...  6. Handover Required:
    ...     - TargetID IE
    ...       - globalENB-ID = PLMN1
    ...       - selected-EPS-TAI = PLMN1
    ...     - SourceToTarget-TransparentContainer IE
    ...       - globalENB-ID = PLMN1
    ...  8. Measurement configuration for UE2
    ...     - A2 event
    ...     [configured as selectedPLMN-Identity PLMN2 == E-UTRAN cell-2 secondaryPlmnId]
    ...  10. Measurement configuration for UE1
    ...     - A1 event
    ...     - B2 event for object E-UTRAN cell-2
    ...     [configured as selectedPLMN-Identity PLMN2 == E-UTRAN cell-2 secondaryPlmnId]
    ...  12. Handover Required:
    ...     - TargetID IE
    ...       - globalENB-ID = PLMN1
    ...       - selected-EPS-TAI = PLMN2
    ...     - SourceToTarget-TransparentContainer IE
    ...       - globalENB-ID = PLMN1
    ...
    ...  POSTCONDITION: -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID:           ASIB, ABIL
    ...       ENVIRONMENT ELEMENTS:  real gNB (SUT), Simulated eNB, simulated AMF,
    ...                              simulated RH (AEQA) and UE's
    ...       TEST CONFIGURATIONS:   CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:     5G_RAN_USR_RRM_14386,5G_RAN_USR_RRM_14387,5G_RAN_USR_RRM_14388
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       NON-REQUIREMENTS-BASED TESTS:  -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:          FCA_5G_L2L3-72173
    ...
    ...  FEATURE SUB-ITEMS:  CNI-71783#B1,CNI-71783#B2,CNI-71783#B3
    ...
    ...  DEFINITIONS FROM THE TEST PLAN:  -
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Simulator NR-RRC&NGAP traces
    ...
    ...  CONTACTS:
    ...
    ...  REFERENCES:  CNI-71783, 5G_RAN_USR_RRM_14386, 5G_RAN_USR_RRM_14387, 5G_RAN_USR_RRM_14388
    ...
    ...  HISTORY:     History, current status and TC description is available in repository:
    ...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/
    ...
    ...              [14.02.2022] - Created TC
    ...              [02.03.2022] - Updated with review comments
    ...              [07.03.2022] - Review approved https://collab.ext.net.nokia.com/ui#review:id=852882
    ...              [21.03.2022] - TC code review completed https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/15275

    [Setup]    NONE

    AMFSim Configure MRL Basic
    UE Register With Selected PLMN    UE=1  selected_plmn=311:489
    UE PDU Session With A2 Event Verification    UE=1    A2_Event=True
    UE A2 Measurements With B2 Event Verification    UE=1  ShouldContain=@{UE1_B2_INCLUDED}
    IRAT Handover to LTE With Handover Required Content Verification    UE=1    eutran_cell=1
    UE Deregister And Verify Detached    UE=1

    UE Register With Selected PLMN    UE=2  selected_plmn=311:490
    UE PDU Session With A2 Event Verification    UE=2    A2_Event=True
    UE A2 Measurements With B2 Event Verification    UE=2  ShouldContain=@{UE2_B2_INCLUDED}  ShouldNotContain=@{UE2_B2_EXCLUDED}
    IRAT Handover to LTE With Handover Required Content Verification    UE=2    eutran_cell=2
    UE Deregister And Verify Detached    UE=2

    [Teardown]    Run keywords     Set SCOUT TC ID for Reporting
    ...   AND                      Run Keyword And Ignore Error    Deregister UEs


CNI71783_005_A2_measurement_configuration_with_matching_EUTRAN_cell_blacklisted
    [Tags]    TC05
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies that A2 measurement is not configured for UE in case selected
    ...               serving PLMN matches with secondaryPlmnIdList but adjacent EUTRAN cell is blacklisted
    ...
    ...  PRECONDITION: 5G_RAN_USR_RRM_14386 preconditions with modifications
    ...                - PLMN1 : 311:489
    ...                - PLMN2 : 311:490
    ...                - Single Served AMF supports both PLMN1 and PLMN2
    ...                - E-UTRAN cell-1 has earfcnValue=1, ecgiPlmn = PLMN1, secondaryPlmnIdList unconfigured
    ...                - E-UTRAN cell-2 has earfcnValue=2, ecgiPlmn = PLMN1, secondaryPlmnIdList 5 PLMN's including PLMN2/311:490
    ...
    ...  TEST EXECUTION:
    ...  1. Perform delta commissioning to set E-UTRAN cell-2 related parameter:
    ...     - NRRELE-eutranCellBlacklisted = true
    ...  2. Register and Establish PDU session for UE1 in NR cell-1 with:
    ...     - selectedPLMN-Identity PLMN2
    ...     - AMF provided MobilityRestrictionList
    ...       - servingPLMN PLMN2
    ...       - forbiddenAreaInformation PLMN=123:321
    ...  3. Verify UE1 measurement configuration received from gNB
    ...  4. Perform delta commissioning to set E-UTRAN cell-2 related parameter:
    ...     - NRRELE-eutranCellBlacklisted = false
    ...  5. Register and Establish PDU session for UE2 in NR cell-1 with:
    ...     - selectedPLMN-Identity PLMN2
    ...     - AMF provided MobilityRestrictionList
    ...       - servingPLMN PLMN2
    ...       - forbiddenAreaInformation PLMN=123:321
    ...  6. Verify UE2 measurement configuration received from gNB
    ...
    ...  EXPECTED RESULTS:
    ...  3. Measurement configuration for UE1
    ...     - A2 event is not configured
    ...     [PLMN2 matches E-UTRAN cell-2 which is blacklisted]
    ...  6. Measurement configuration for UE2
    ...     - A2 event
    ...     [PLMN2 matches E-UTRAN cell-2]
    ...
    ...  POSTCONDITION: -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID:           ASIB, ABIL
    ...       ENVIRONMENT ELEMENTS:  real gNB (SUT), Simulated eNB, simulated AMF,
    ...                              simulated RH (AEQA) and UE's
    ...       TEST CONFIGURATIONS:   CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:		 5G_RAN_USR_RRM_14386
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       NON-REQUIREMENTS-BASED TESTS:  -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:				     FCA_5G_L2L3-77502
    ...
    ...  FEATURE SUB-ITEMS:  CNI-71783#B1
    ...
    ...  DEFINITIONS FROM THE TEST PLAN:  -
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Simulator NR-RRC&NGAP traces
    ...
    ...  CONTACTS:
    ...
    ...  REFERENCES:  CNI-71783, 5G_RAN_USR_RRM_14386
    ...
    ...  HISTORY:     History, current status and TC description is available in repository:
    ...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/
    ...
    ...              [14.02.2022] - Created TC
    ...              [02.03.2022] - Updated with review comments
    ...              [07.03.2022] - Review approved https://collab.ext.net.nokia.com/ui#review:id=852882
    ...              [21.03.2022] - TC code review completed https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/15275

    [Setup]    NONE

    Find SCFC and Send Delta Commissioning    scfc_filename=nrrele2_blacklist_true.json
    Check All Cells Are Enabled

    AMFSim Configure MRL Basic
    UE Register With Selected PLMN    UE=4  selected_plmn=311:490
    UE PDU Session With A2 Event Verification    UE=4    A2_Event=False
    UE Deregister And Verify Detached    UE=4

    Find SCFC and Send Delta Commissioning    scfc_filename=nrrele2_blacklist_false.json
    Check All Cells Are Enabled

    UE Register With Selected PLMN    UE=4  selected_plmn=311:490
    UE PDU Session With A2 Event Verification    UE=4    A2_Event=True
    UE A2 Measurements With B2 Event Verification    UE=4  ShouldContain=@{UE4_B2_INCLUDED}  ShouldNotContain=@{UE4_B2_EXCLUDED}
    IRAT Handover to LTE With Handover Required Content Verification    UE=4    eutran_cell=2
    UE Deregister And Verify Detached    UE=4

    [Teardown]    Run Keywords    Set SCOUT TC ID for Reporting
    ...    AND    Run Keyword And Ignore Error    Deregister UEs
    ...    AND    Find SCFC and Send Delta Commissioning    scfc_filename=nrrele2_blacklist_false.json
    ...    AND    Check All Cells Are Enabled


CNI71783_006_B2_measurement_configuration_with_no_matching_ecgiPlmn_or_secondaryPlmnIdList
    [Tags]    TC06
    [Documentation]
    ...
    ...  DESCRIPTION: This testcase verifies that B2 measurement is not configured for UE in case mobility restriction
    ...               list is provided by AMF and UE's selected serving PLMN does not match with any configured
    ...               ecgiPlmn or secondaryPlmnIdList of adjacent EUTRAN cells
    ...
    ...
    ...  PRECONDITION: 5G_RAN_USR_RRM_14387 preconditions with modifications
    ...                - PLMN1 : 311:489
    ...                - PLMN2 : 311:490
    ...                - Single Served AMF supports both PLMN1 and PLMN2
    ...                - E-UTRAN cell-1 has earfcnValue=1, ecgiPlmn = PLMN1, secondaryPlmnIdList unconfigured
    ...                - E-UTRAN cell-2 has earfcnValue=2, ecgiPlmn = PLMN1, secondaryPlmnIdList NOT including PLMN2/311:490
    ...                - A2 Event activation for 5GC000706 Inter-frequency handover is configured
    ...
    ...  TEST EXECUTION:
    ...  1. Register and Establish PDU session for UE1 in NR cell-1 with:
    ...     - selectedPLMN-Identity PLMN2
    ...     - AMF provided MobilityRestrictionList
    ...       - servingPLMN PLMN2
    ...       - forbiddenAreaInformation PLMN=123:321
    ...  2. Verify UE1 measurement configuration received from gNB
    ...  3. With UE1 : send A2 measurement report
    ...  4. Verify UE1 measurement configuration received from gNB
    ...
    ...  EXPECTED RESULTS:
    ...  2. Measurement configuration for UE1
    ...     - A2 event
    ...     [Configured due to 5GC000706 Inter-frequency handover]
    ...  4. Measurement configuration for UE1
    ...     - No B2 event
    ...     [selectedPLMN-Identity PLMN2 <> E-UTRAN cell-1/cell-2 ecgiPlmn/secondaryPlmnIdList]
    ...
    ...  POSTCONDITION: -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID:           ASIB, ABIL
    ...       ENVIRONMENT ELEMENTS:  real gNB (SUT), Simulated eNB, simulated AMF,
    ...                              simulated RH (AEQA) and UE's
    ...       TEST CONFIGURATIONS:   CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:		 5G_RAN_USR_RRM_14387
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       NON-REQUIREMENTS-BASED TESTS:  -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:				     FCA_5G_L2L3-77503
    ...
    ...  FEATURE SUB-ITEMS:  CNI-71783#B1
    ...
    ...  DEFINITIONS FROM THE TEST PLAN:  -
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Simulator NR-RRC&NGAP traces
    ...
    ...  CONTACTS:
    ...
    ...  REFERENCES:  CNI-71783, 5G_RAN_USR_RRM_14387
    ...
    ...  HISTORY:     History, current status and TC description is available in repository:
    ...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/
    ...
    ...              [14.02.2022] - Created TC
    ...              [02.03.2022] - Updated with review comments
    ...              [07.03.2022] - Review approved https://collab.ext.net.nokia.com/ui#review:id=852882
    ...              [21.03.2022] - TC code review completed https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/15275

    [Setup]    NONE

    Find SCFC and Send Delta Commissioning    scfc_filename=nradje2_mcc_211.json
    Find SCFC and Send Delta Commissioning    scfc_filename=interfreq_ho_enable.json
    Check All Cells Are Enabled

    AMFSim Configure MRL Basic

    UE Register With Selected PLMN    UE=5  selected_plmn=311:490
    UE PDU Session With A2 Event Verification    UE=5    A2_Event=True
    UE A2 Measurements With B2 Event Verification    UE=5  ShouldContain=@{UE5_B2_INCLUDED}  ShouldNotContain=@{UE5_B2_EXCLUDED}
    UE Deregister And Verify Detached    UE=5

    [Teardown]    Run Keywords    Set SCOUT TC ID for Reporting
    ...    AND    Run Keyword And Ignore Error    Deregister UEs
    ...    AND    Find SCFC and Send Delta Commissioning    scfc_filename=nradje2_mcc_311.json
    ...    AND    Find SCFC and Send Delta Commissioning    scfc_filename=interfreq_ho_disable.json
    ...    AND    Check All Cells Are Enabled

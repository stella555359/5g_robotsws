*** Settings ***
Documentation
...    author: 'VRF Ulm Team #4'
...    Team: 'MN RAN RD VRF ULM 4'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: Test Suite for CB008146-F Mobility Profiles for Inter-RAT handover
...    Link to Feature Test Strategy:    https://nokia.sharepoint.com/:f:/r/sites/MN5GSCProductization/Shared%20Documents/General/
...                                      5G%26SC%20Collaborator/5GC000600%E2%80%935GC000799/5GC000710?csf=1&web=1&e=mQM0y9

Resource          CB008146-F_Keywords.robot

Suite Setup       Prepare TL for CB008146-F
Suite Teardown    Reload backuped config files

Test Setup        Perform Precondition of Test Scenario
Test Teardown     Perform Postconditions of Test Scenario


*** Test Cases ***

[1]5GC000710_F_B1_Successful_configuration_of_A2_measurement_for_HO_From_MobilityProfile
    [Documentation]  This testcase verifies that the gNB configures the UE (via RRC configuration message) with the required A2 measurement
    ...              which in-turn should be the same as the one picked up from the Mobility profile.
    ...              Correspondent User Scenario is a copy from US5GC000707-F#B1:
    ...              Successful configuration of A2 measurement during intial call setup.
    [Tags]    B1  B1.1
    UE Register
    Restart EGATE Log
    UE PDU Session Setup
    Sleep  2
    ${a2_addition}=  Restart EGATE Log
    Verify Measurement is configured  EventA2
    ${pm_files}=            Collect PMCounters
    UE Deregister
    Verify A2 Addition      ${a2_addition}
    Counter Verification    counter_files=${pm_files}  counter_names=${MOP2_COUNTER}

[2]5GC000710_F_B1_Successful_configuration_of_A2_measurement_for_HO_From_MobilityProfile
    [Documentation]  Alt#1: No A2 configuration for HO in case no configured earfcnValue defined in the mobility profile
    ...              (NRBTS/NRMOPR_SA.nrMeasCfgIrDNList ->NRBTS/NRMEASCFG_IR.earfcnValue) belongs to a band supported by the UE.
    ...              Hint: Only for TDD (UE 5 is hardcoded with TDD capabilties)
    [Tags]    B1  B1.2
    ${ue_id}=               Set Variable  5
    UE Register             ue_id=${ue_id}
    UE PDU Session Setup    ue_id=${ue_id}
    Sleep  2
    Verify Measurement is absent  EventA2  ue_id=${ue_id}
    ${pm_files}=            Collect PMCounters
    UE Deregister           ue_id=${ue_id}
    Counter Verification    counter_files=${pm_files}  counter_names=${MOP2_COUNTER}

[1]5GC000710_F_B2_Successful_Configuration_of_Inter_Rat_B2_Measurement_When_UE_Configured_With_A2_Measurements_From_MobilityProfile
    [Documentation]  This testcase verifies the gNB’s behavior, when an RRC_CONNECTED UE sends an A2 measurement report to it,
    ...              and verifies that the RRC reconfiguration message contains information from Mobility profile
    ...              about configured B2/A1 measurement event at UE side.
    ...              Correspondent User Scenario is a copy from US5GC000707-F#B4:
    [Tags]    B2  B2.1
    Apply Config for B2.1_Conf_of_B2_Meas
    UE Register
    UE PDU Session Setup
    Setup B2 Measurement
    Verify B2 Measurement Config
    UE Deregister
    ${pm_files}=                  Collect PMCounters
    Counter Verification          counter_files=${pm_files}  counter_names=${MOP2_COUNTER}

[2]5GC000710_F_B2_Successful_Configuration_of_Inter_Rat_B2_Measurement_When_UE_Configured_With_A2_Measurements_From_MobilityProfile
    [Documentation]  Alt#3: In case the carrierFreq defined in the mobility profile
    ...              (NRBTS/NRMOPR_SA.nrMeasCfgIrDNList->NRBTS/NRMEASCFG_IR.earfcnValue)
    ...              have been updated between A2 configuration in the UE and RRC measurement report for event A2,
    ...              the new carrierFreq defined in the mobility profile are used
    [Tags]    B2  B2.2
    UE Register
    UE PDU Session Setup
    ${meas_cfg}=                  Change EARFCN Value
    Setup B2 Measurement
    Verify B2 Measurement Config  ${meas_cfg}  ${NRHOIR_1}
    UE Deregister
    ${pm_files}=                  Collect PMCounters
    Counter Verification          counter_files=${pm_files}  counter_names=${MOP2_COUNTER}

[3]5GC000710_F_B2_Successful_Configuration_of_Inter_Rat_B2_Measurement_When_UE_Configured_With_A2_Measurements_From_MobilityProfile
    [Documentation]  Alt#5: In case the mobility profile has been deleted between A2 configuration in the UE and RRC measurement report for event A2,
    ...              the default mobility profile is used
    [Tags]    B2  B2.3
    UE Register
    UE PDU Session Setup
    Delete MOP2
    Setup B2 Measurement
    Verify B2 Measurement Config  ${MEAS_CFG_1}  ${NRHOIR_1}
    UE Deregister
    ${pm_files}=                  Collect PMCounters
    Counter Verification          counter_files=${pm_files}  counter_names=${MOP2_COUNTER}

[1]5GC000710_F_B3_Successful_Removal_Of_Inter_Rat_B2_Measurements_Where_UE_Configured_With_A1_Measurements_From_MobilityProfile
    [Documentation]  This testcase verifies the behavior of the gNB when an RRC connected UE sends the A1 measurement report.
    ...              Correspondent User Scenario is a copy from US5GC000707-A#B4: Successful removal of inter-rat B2 measurements
    [Tags]   B3  B3.1
    ${b2_removal}=  Set Variable  b2_removal
    UE Register
    Restart EGATE Log
    UE PDU Session Setup
    Sleep  2
    Save EGATE Log  a2_addition
    Restart EGATE Log
    Send Measurement Report       meas_id=1 event=A2 srsrq_nr=89 srsrp_nr=50    #5G_CP_ARC_ALG_1697
    Sleep  2
    Save EGATE Log  b2a1_addition
    Verify Measurement is configured  EventB2
    Verify Measurement is configured  EventA1
    Restart EGATE Log
    ${meas_id}=    Get Measurement id   EventA1
    Send Measurement Report       meas_id=${meas_id} event=A1
    Sleep  2
    Save EGATE Log  ${b2_removal}
    Verify Measurement is absent      EventB2
    Verify Measurement is absent      EventA1
    Verify Measurement is configured  EventA2
    ${pm_files}=                 Collect PMCounters
    UE Deregister
    Verify B2 Removal            ${b2_removal}
    Counter Verification         counter_files=${pm_files}  counter_names=${MOP2_COUNTER}

[2]5GC000710_F_B3_Successful_Removal_Of_Inter_Rat_B2_Measurements_Where_UE_Configured_With_A1_Measurements_From_MobilityProfile
    [Documentation]  Alt#1: In case the test on measurement result of secondary quantity failed (for rsrpCombined or rsrqCombined case),
    ...              no change in the measurement configuration. gNB-CU-CP waits for next UE measurement report.
    [Tags]   B3  B3.2
    Update SCF Param    value=rsrqCombined  parameter=a1MeashoEnabledSA  dist_name=NRBTS-1/NRMOPR_SA-2
    UE Register
    Restart EGATE Log
    UE PDU Session Setup
    Sleep  2
    Save EGATE Log  a2_addition
    Restart EGATE Log
    Send Measurement Report       meas_id=1 event=A2 srsrq_nr=89 srsrp_nr=50    #5G_CP_ARC_ALG_1697
    Sleep  2
    Save EGATE Log  b2a1_addition
    Verify Measurement is configured  EventB2
    Verify Measurement is configured  EventA1
    Restart EGATE Log
    ${meas_id}=    Get Measurement id   EventA1
    ${rsrp_value}=    Evaluate  ${a1ThresholdhoSsbRsrpSA} - 20  # calculate a "not fitting" value
    Send Measurement Report       meas_id=${meas_id} srsrp_nr=${rsrp_value} event=A1
    Sleep  2
    Save EGATE Log  no_b2_removal
    Verify Measurement is configured  EventB2
    Verify Measurement is configured  EventA1
    ${pm_files}=                 Collect PMCounters
    UE Deregister
    Counter Verification         counter_files=${pm_files}  counter_names=${MOP2_COUNTER}

[1]5GC000710_F_B4_A2_Meas_Config_After_HO_On_TargetCell_After_successful_Intra_gNB_HO_A3_A5_measurements
    [Documentation]  This testcase verifies the A2 configuration when on the target cell after an intra-gNB HO happens as a result of A3/A5 events.
    ...              Correspondent User Scenario is a copy from US5GC000707-A#B5: A2 measurement configuration on target cell
    ...              after successful intra-frequency Intra-DU Intra-gNB handover triggered by A3/A5 measurements.
    [Tags]    B4  B4.1
    ${ueId}=                               Set Variable   21    # attached to cell2
    ${meas_cfg_b4}  ${a2_meas_cfg_b4}=     Apply Config for B4
    UE Register                            ue_id=${ueId}
    UE PDU Session Setup                   ue_id=${ueId}
    IntraDUHO                              ue_id=${ueId}  target_cell=${physCellId1}                # cell2(51) -> cell1(50)
    Verify A2 Addition                     filename=${EGATE_CONSOLE_LOG}  meascfg=${meas_cfg_b4}  a2measconfig=${a2_meas_cfg_b4}
    ${pm_files}=                           Collect PMCounters
    Counter Verification                   counter_files=${pm_files}  counter_names=${MOP2_COUNTER}
    [Teardown]                             B4 Teardown  ${ueId}

[2]5GC000710_F_B4_A2_Meas_Config_After_HO_On_TargetCell_After_successful_Intra_gNB_HO_A3_A5_measurements
    [Documentation]  Alt#5: A new mobility profile can be selected in the target cell in case a new RFSP value was received for the UE between
    ...              initial mobility profile selection and A3/A5 for inter freq HO reception, and 5GC000710 is activated for RFSP support
    [Tags]    B4  B4.2
    ${ueId}=                               Set Variable   21    # attached to cell2(51)
    ${meas_cfg_b4}  ${a2_meas_cfg_b4}=     Apply Config for B4
    UE Register                            ue_id=${ueId}
    UE PDU Session Setup                   ue_id=${ueId}
    Set RFSPIndex                          ue_id=${ueId}  rfsp_index=${RFSP_INDEX}
    IntraDUHO                              ue_id=${ueId}  target_cell=${physCellId1}           # cell2(51) -> cell1(50)
    Verify A2 Addition                     filename=${EGATE_CONSOLE_LOG}  meascfg=${meas_cfg_b4}  a2measconfig=${a2_meas_cfg_b4}
    AP WA IntraDUHO To Source              ue_id=${ueId}  event=A3  target_cell=${physCellId2}
    UE Deregister                          ue_id=${ueId}
    MoPCounter Verification B4.2

[3]5GC000710_F_B4_A2_Meas_Config_After_HO_On_TargetCell_After_successful_Intra_gNB_HO_A3_A5_measurements
    [Documentation]  Alt#6: A new mobility profile can be selected in the target cell in case a new slide has been allocated to the UE
    ...              after a PDU session setup between initial mobility profile selection and A3/A5 for inter freq HO reception
    [Tags]    B4  B4.3
    ${ueId}=                               Set Variable   21    # attached to cell2(51)
    ${meas_cfg_b4}  ${a2_meas_cfg_b4}=     Apply Config for B4
    UE Register                            ue_id=${ueId}
    UE PDU Session Setup                   ue_id=${ueId}
    UE PDU Session Setup                   ue_id=${ueId}  pdu=2  gw=2  nwslice=2
    ...                                    pass_regexp=Pdu Session Resource Setup Response Message with RAN UE NGAP ID \\d+ handled successfully
    UE PDU Session Release                 ue_id=${ueId}
    IntraDUHO                              ue_id=${ueId}  target_cell=${physCellId1}           # cell2(51) -> cell1(50)
    Verify A2 Addition                     filename=${EGATE_CONSOLE_LOG}  meascfg=${meas_cfg_b4}  a2measconfig=${a2_meas_cfg_b4}
    AP WA IntraDUHO To Source              ue_id=${ueId}  event=A3  target_cell=${physCellId2}
    UE Deregister                          ue_id=${ueId}
    MoPCounter Verification B4.2

[1]5GC000710_F_B6_A2_Meas_Config_For_HO_From_MobilityProfile_After_Inter_gNB_HO_A3_A5_Meas
    [Documentation]  This testcase verifies the A2 configuration when on the target cell after an inter-gNB HO happens as a result of A3/A5 events.
    ...              Correspondent User Scenario is a copy from US5GC000707-F#B3:
    ...              A2 measurement configuration after successful intra-frequency Inter-gNB handover based on A3 /A5 measurements
    ...              Hint: Only for TDD (Cell in simulated gNB is hardcoded to TDD only)
    [Tags]    B6  B6.1
    Apply Config for B6
    UE Register
    UE PDU Session Setup
    Send NR Measurement Report             event=A3  meas_values=srsrp_nr=50 phycell_id=48 nrsrp_nr=70
    ...                                    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-${Simulated_gNB_ID}.1 performed
    Enable HO back to real gNB
    Restart EGATE Log
    Send NR Measurement Report             event=A3  meas_values=srsrp_nr=50 phycell_id=${physCellId1} nrsrp_nr=70
    ...                                    pass_regexp=Inter-eNB handover from ENB-${Simulated_gNB_ID}.1 to EXT_ENB-2.1 performed
    Verify Measurement is configured       EventA2
    Verify Measurement is configured       EventA3
    Verify Measurement is configured       EventA5
    Verify Measurement is absent           EventB2
    Verify Measurement is absent           EventA1
    ${a2_addition}=                        Save EGATE Log  a2_addition
    run_keyword_and_warn_on_failure        UE Deregister
    Verify A2 Addition                     ${a2_addition}
    ${pm_files}=                           Collect PMCounters
    Counter Verification                   counter_files=${pm_files}  counter_names=${MOP2_COUNTER}  counter_value=2

[2]5GC000710_F_B6_A2_Meas_Config_For_HO_From_MobilityProfile_After_Inter_gNB_HO_A3_A5_Meas
    [Documentation]  This testcase verifies the A2 configuration when on the target cell after an inter-gNB HO happens as a result of A3/A5 events.
    ...              Correspondent User Scenario is a copy from US5GC000707-F#B3:
    ...              Alt#5 scenario: Instead of main description, UE configured with B2/A1/A3/A5.
    ...              Precondition: Initial context is setup successfully and UE has been configured for intra-frequency measurement event A2/A3/A5
    ...              and UE configured with B2/A1/A3/A5 following A2 reception.
    ...              Postcondition: UE is configured with A3/A5 measurement and A2 measurement for HO.
    ...              Hint: Only for TDD (Cell in simulated gNB is hardcoded to TDD only)
    [Tags]    B6  B6.2
    Apply Config for B6
    UE Register
    UE PDU Session Setup
    Send NR Measurement Report             event=A3  meas_values=srsrp_nr=50 phycell_id=48 nrsrp_nr=70
    ...                                    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-${Simulated_gNB_ID}.1 performed
    Enable HO back to real gNB
    Verify Measurement is configured       EventA2
    Send Measurement Report                meas_id=1 event=A2 srsrq_nr=7 srsrp_nr=7
    Verify Measurement is configured       EventB2
    Verify Measurement is configured       EventA1
    Restart EGATE Log
    Send NR Measurement Report             event=A3  meas_values=srsrp_nr=50 phycell_id=${physCellId1} nrsrp_nr=70
    ...                                    pass_regexp=Inter-eNB handover from ENB-${Simulated_gNB_ID}.1 to EXT_ENB-2.1 performed
    Verify Measurement is configured       EventA2
    Verify Measurement is configured       EventA3
    Verify Measurement is configured       EventA5
    Verify Measurement is absent           EventB2
    Verify Measurement is absent           EventA1
    ${a2_addition}=                        Save EGATE Log  a2_addition
    run_keyword_and_warn_on_failure        UE Deregister
    Verify A2 Addition    ${a2_addition}
    ${pm_files}=                           Collect PMCounters
    Counter Verification                   counter_files=${pm_files}  counter_names=${MOP2_COUNTER}  counter_value=2

5GC000710_F_B7_Inter_RAT_HO_B2_Meas
    [Documentation]  This testcase verifies the gNB’s behavior when the UE sends a B2 measurement report (configured from the mobility profile)
    ...              and the gNB triggers a handover to a cell in a neighbour eNB.
    ...              Correspondent User Scenario is a copy from US5GC000707-B#B1: Successful Inter-Rat handover based on B2 measurements.
    ...              AP unusable after TC execution (restart needed)
    [Tags]    B7
    [Setup]  Setup for 5GC000710_F_B7_B8
    Apply Config for B7_Inter_RAT_HO_B2_Meas
    UE Register
    UE PDU Session Setup
    InterRatHO
    Verify InterRatHo
    ${pm_files}=                  Collect PMCounters
    Counter Verification          counter_files=${pm_files}  counter_names=${B7_COUNTERS}
    Counter Verification          counter_files=${pm_files}  counter_names=${B7_NREMO_COUNTERS}  dn=${NREMO_COUNTERS_DN}

CB008146-F_B8_Ignoring_restriction_of_Mobility_Restriction_list_in_case_of_inter-RAT_Emergency_call_mobility
    [Documentation]  This user scenario describes gNB behaviour successful ignoring restriction of (MRL) in the Emergency voice call case
    ...              when inter-PLMN/intra-PLMN inter-RAT handover procedure is performed for SA user.
    ...              Copy from US5GC000784-B#B3: Ignoring restriction of Mobility Restriction list in case of inter-RAT Emergency call mobility
    [Tags]    B8
	[Setup]  Setup for 5GC000710_F_B7_B8
    Apply Config for CB008146-F_B8
    Config AMF MRL With Restriction For UE    ue_id=1  sa_plmn=311:489  fa_plmn=311:489  forbidden_tacs=222
    ...   restricted_plmn=311:489  restricted_rat=eutra
    UE Register
    UE PDU Session Setup    ue_id=1  pdu=1  gw=1
    Set Emergency Call Priority    priority=1
    UE PDU Session Setup    ue_id=1  pdu=2  gw=2
    ...    pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=1  pdu=2  qos_flow_list=@{pdu2_qos_list_B8}  by=amf
    InterRatHO
    ${pm_files}=                  Collect PMCounters
    Counter Verification          counter_files=${pm_files}  counter_names=${B8_COUNTERS}  dn=${NREMO_COUNTERS_DN}

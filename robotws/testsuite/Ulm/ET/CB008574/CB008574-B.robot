*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: RRC Connection Re-establishment under a prepared gNB via RRCSetup


Resource          CB008574_Keywords.robot

Suite Setup       Setup TL for CB008574
Suite Teardown    CB008574 Teardown

Test Setup        Perform Precondition of Test Scenario
Test Teardown     Perform Postconditions of Test Scenario

*** Test Cases ***
#[1]CB008574_B_B2_RRE_to_target_gNB_before_NG_HO_ACK
#    [Documentation]  This user scenario describes that if RRC: RRCReestablishmentRequest to handover target cell or a prepared cell
#    ...              during Inter-gNB HO via NG is received by target gNB before sending out NGAP:HandoverRequestAcknowledge message,
#    ...              target gNB shall do fallback RRC Setup
#    ...              [1] RRC Reestablishment (RRC Setup) to handover target cell (FR1:TDD)
#    [Tags]    B2  B2.1
#    Register UE on srcGnb and start traffic and tracing
#    Setup Reestablishment sent after Measurement and delay Handover Request
#    Trigger HO
#    Start TCE tracing
#    Log To Console   Start Testing
#    Sleep            120s
#    Log To Console   Stop Testing
#    ${tce_trc_cu}    Collect trace and stop TCE  collector=trace_session_cu
#    ${tce_trc_du}    Collect trace and stop TCE  collector=trace_session_du
#    ${pm_files_src}  ${pm_files_tgt}   Collect PM counters from both gNBs
#    Verify PM Counter Reference Table  reference_table=${B_B2_Target_Counters}    pm_dir=${pm_files_tgt}   distname_suffix=1
#    Verify PM Counter Reference Table  reference_table=${B_B4.1_Source_Counters}  pm_dir=${pm_files_src}   distname_suffix=1

#[2]CB008574_B_B2_RRE_to_target_gNB_before_NG_HO_ACK
#    [Documentation]  refer to TI 2.1
#    ...              [2] RRC Reestablishment (RRC Setup) to prepared cell  (FR1:FDD)
#    [Tags]    B2  B2.2
#    Start TCE tracing
#    Log To Console   Start Testing
#    Sleep            120s
#    Log To Console   Stop Testing
#    ${tce_trc_cu}    Collect trace and stop TCE  collector=trace_session_cu
#    ${tce_trc_du}    Collect trace and stop TCE  collector=trace_session_du
#    ${pm_files_src}  ${pm_files_tgt}   Collect PM counters from both gNBs

[1]CB008574_B_B4_RRE_with_cause_reconfiguration_failure_to_target_gNB_after_NG_HO_ACK
    [Documentation]  This user scenario describes that if RRC: RRCReestablishmentRequest with cause reconfiguration failure to
    ...              handover target cell or a prepared cell during Inter-gNB HO via NG, target gNB shall do fallback RRC Setup
    ...              [1] RRC Reestablishment (RRC Setup) to handover target cell (FR1:TDD)
    [Tags]    B4  B4.1  CRT
    Register UE on srcGnb and start traffic and tracing
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=reconfigurationFailure
    Trigger HO       pass_regexp=UE CONTEXT RELEASE REQUEST: gNB=${SRC_GNB}
    B4 Verification

[2]CB008574_B_B4_RRE_with_cause_reconfiguration_failure_to_target_gNB_after_NG_HO_ACK
    [Documentation]  refer to TI 4.1
    ...              [2] RRC Reestablishment (RRC Setup) to prepard cell  (FR1:FDD)
    [Tags]    B4  B4.2  CRT
    Register UE on srcGnb and start traffic and tracing
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=reconfigurationFailure  target_cell=${PREP_CELL}
    Trigger HO        pass_regexp=UE CONTEXT RELEASE REQUEST: gNB=${SRC_GNB}
    B4 Verification   target_cell=${PREP_CELL}

[1]CB008574_B_B6_RRE_with_invalid_shortMAC-I_or_unkonwn_C-RNTI_or_to_unprepared_cell_to_target_gNB_after_NG_HO_ACK
    [Documentation]  This user scenario describes the case of RRC reestablishment request with invalid shortMAC-I or unknown C-RNTI or
    ...              to unprepared cell during Inter-gNB HO via NG.
    ...              This user scenario describes that as response to RRC reestablishment request, the gNB is sending RRC Setup message to UE.
    ...              As per 3GPP agreement, when the gNB could not fetch the UE context successfully,
    ...              the gNB can response with an RRCSetup in case of RRC re-establishment failure.
    ...              [1] RRC Reestablishment request with invalid shortMAC-I during Inter-gNB Handover via NG on target cell
    [Tags]    B6  B6.1  CRT
    Register UE on srcGnb and start traffic and tracing
    Ignore RRC Reconf
    Trigger HO                         pass_regexp=Hit on error cases presence=any action=drop
    RRC Reestablishment Request        action=invalid_short_mac_i
    Sleep                              10s               # wait for rrc reestablishment failed timeout
    Set Counter Value                  ${RRC_REESTAB_FAIL_TARGET_DU}   RRC_REESTAB_HO_FAILURE_DU             1
    B6 Verification

[2]CB008574_B_B6_RRE_with_invalid_shortMAC-I_or_unkonwn_C-RNTI_or_to_unprepared_cell_to_target_gNB_after_NG_HO_ACK
    [Documentation]  refer to TI 6.1
    ...              [2] RRC Reestablishment request with invalid shortMAC-I during Inter-gNB Handover via NG on prepared cell
    [Tags]    B6  B6.2  CRT
    Register UE on srcGnb and start traffic and tracing
    Ignore RRC Reconf
    Trigger HO                         pass_regexp=Hit on error cases presence=any action=drop
    RRC Reestablishment Request        target_cell=${PREP_CELL}  action=invalid_short_mac_i  cause=otherFailure
    Sleep                              10s               # wait for rrc reestablishment failed timeout
    Set Counter Value                  ${RRC_REESTAB_FAIL_TARGET_DU}   RRC_REESTAB_OTHER_FAILURE_DU          1
    B6 Verification  target_cell=${PREP_CELL}  cause=otherFailure

[3]CB008574_B_B6_RRE_with_invalid_shortMAC-I_or_unkonwn_C-RNTI_or_to_unprepared_cell_to_target_gNB_after_NG_HO_ACK
    [Documentation]  refer to TI 6.1
    ...              [3] RRC Reestablishment request with unknown C-RNTI during Inter-gNB Handover via NG
    [Tags]    B6  B6.3
    Register UE on srcGnb and start traffic and tracing
    Ignore RRC Reconf
    Trigger HO                         pass_regexp=Hit on error cases presence=any action=drop
    RRC Reestablishment Request        action=invalid_crnti
    Sleep                              10s               # wait for rrc reestablishment failed timeout
    Set Counter Value                  ${RRC_REESTAB_FAIL_TARGET_DU}   RRC_REESTAB_HO_FAILURE_DU             1
    B6 Verification

[4]CB008574_B_B6_RRE_with_invalid_shortMAC-I_or_unkonwn_C-RNTI_or_to_unprepared_cell_to_target_gNB_after_NG_HO_ACK
    [Documentation]  refer to TI 6.1
    ...              [4] RRC Reestablishment request to unprepared cell during Inter-gNB Handover via NG
    [Tags]    B6  B6.4
    Disable Prepared Cell
    Register UE on srcGnb and start traffic and tracing
    Ignore RRC Reconf
    Trigger HO                         pass_regexp=Hit on error cases presence=any action=drop
    RRC Reestablishment Request        target_cell=${PREP_CELL}     cause=otherFailure
    Sleep                              10s               # wait for rrc reestablishment failed timeout
    Set Counter Value                  ${RRC_REESTAB_FAIL_TARGET_DU}   RRC_REESTAB_OTHER_FAILURE_DU          1
    B6 Verification                    target_cell=${PREP_CELL}  cause=otherFailure

[1]CB008574_B_B8_Interaction_with_CB008699_Full_RRC_Configuration_for_SA_Handover
    [Documentation]  This user scenario describes the interaction with CB008699 Full RRC Configuration for SA Handover:
    ...              During Inter-gNB handover via NG, target gNB detects that full configuration is needed
    ...              and fullConfig IE shall be included in RRCReconfiguration RRC Reestablishment request received by target gNB,
    ...              if internal flag "fullConfigTriggered" is true from the HO context,
    ...              gNB-CU-CP falls back to RRC Setup procedure by sending the RRCSetup message and follows the steps from
    ...              idle to connected state transition procedure.
    ...              [1] Source DRB to QoS flow mapping is missing at target gNB during NG based handover
    [Tags]    B8  B8.1  CRT  CDRT
    Set actFullRRCConfigurationSaHo
    Register UE on simGnb and start traffic
    Remove QosFlow Mapping List in HandOverRequired
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=handoverFailure
    Trigger HO       pass_regexp=T_NG_RELOC_Overall Timeout
    B8 Verification

[2]CB008574_B_B8_Interaction_with_CB008699_Full_RRC_Configuration_for_SA_Handover
    [Documentation]  refer to TI 8.1
    ...              [2] Source DRB to QoS flow mapping is not supported at target gNB during NG based handover
    [Tags]    B8  B8.2
    Set actFullRRCConfigurationSaHo
    Register UE on simGnb and start traffic
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=handoverFailure  target_cell=${PREP_CELL}
    Invalid QosFlow Mapping in HandOverRequired
    Trigger HO       pass_regexp=T_NG_RELOC_Overall Timeout
    B8 Verification  target_cell=${PREP_CELL}
    ### M55125C07505:   NG_HO_RES_ALC_F_AC_TRG ???

[3]CB008574_B_B8_Interaction_with_CB008699_Full_RRC_Configuration_for_SA_Handover
    [Documentation]  refer to TI 8.1
    ...              [3] Unknown extension detected by the target gNB  during inter-gNB NG based handover
    [Tags]    B8  B8.3
    Set actFullRRCConfigurationSaHo
    Register UE on simGnb and start traffic
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=handoverFailure
    Unsupported Extension Type in HandOverRequired
    Trigger HO       pass_regexp=T_NG_RELOC_Overall Timeout
    B8 Verification

[4]CB008574_B_B8_Interaction_with_CB008699_Full_RRC_Configuration_for_SA_Handover
    [Documentation]  refer to TI 8.1
    ...              [4] actForceFullRRCConfigurationSaHo=enabled
    [Tags]    B8  B8.4  CRT
    Set actFullRRCConfigurationSaHo
    Set actForceFullRRCConfigurationSaHo
    Register UE on simGnb and start traffic
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=handoverFailure
    Trigger HO       pass_regexp=T_NG_RELOC_Overall Timeout
    B8 Verification

[5]CB008574_B_B8_Interaction_with_CB008699_Full_RRC_Configuration_for_SA_Handover
    [Documentation]  refer to TI 8.1
    ...              [5] actForceFullRRCConfigurationSaHo=onlyNgHo
    [Tags]    B8  B8.5
    Set actFullRRCConfigurationSaHo
    Set actForceFullRRCConfigurationSaHo  value=onlyNgHo
    Register UE on simGnb and start traffic
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=handoverFailure  target_cell=${PREP_CELL}
    Trigger HO       pass_regexp=T_NG_RELOC_Overall Timeout
    B8 Verification  target_cell=${PREP_CELL}

[1]CB008574_B_B9_Security_algorithm_validation_failure
    [Documentation]  During the inter-gNB handover via NG, RRC Reestablishment request is received on target gNB,
    ...              if IE CipheringAlgorithm and IE InterityProtAlgorithm are not received from source gNB during handover or
    ...              these algorithms are not supported on target gNB:
    ...              gNB-CU-CP falls back to RRC Setup procedure by sending the RRCSetup message and follows the steps from
    ...              idle to connected state transition procedure.
    ...              [1] Integrity Protection Algorithm not supported by gNB
    [Tags]    B9  B9.1  CRT
    [Setup]  Setup for CB008574_B_B9  instance=1
    [Teardown]  Teardown for CB008574_B_B9
    Register UE on simGnb and start traffic
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=handoverFailure
    Trigger HO       pass_regexp=T_NG_RELOC_Overall Timeout
    B9 Verification

[2]CB008574_B_B9_Security_algorithm_validation_failure
    [Documentation]  refer to TI 9.1
    ...              [2] Ciphering Algorithm not supported by gNB
    [Tags]    B9  B9.2
    [Setup]  Setup for CB008574_B_B9  instance=2
    [Teardown]  Teardown for CB008574_B_B9
    Register UE on simGnb and start traffic
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=handoverFailure  target_cell=${PREP_CELL}
    Trigger HO       pass_regexp=T_NG_RELOC_Overall Timeout
    B9 Verification  target_cell=${PREP_CELL}

[3]CB008574_B_B9_Security_algorithm_validation_failure
    [Documentation]  refer to TI 9.1
    ...              [3] SecurityConfig not included in HandoverRequest
    [Tags]    B9  B9.3
    Register UE on simGnb and start traffic
    Disable SecurityConfig
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=handoverFailure
    Trigger HO       pass_regexp=T_NG_RELOC_Overall Timeout
    B9 Verification

[4]CB008574_B_B9_Security_algorithm_validation_failure
    [Documentation]  refer to TI 9.1
    ...              [4] IE NewSecurityContextInd is present in HandoverRequest
    [Tags]    B9  B9.4
    Register UE on simGnb and start traffic
    Include NewSecurityContextInd
    Ignore RRC Reconfig and Trigger RRCReestablishmentRequest   cause=handoverFailure  target_cell=${PREP_CELL}
    Trigger HO       pass_regexp=T_NG_RELOC_Overall Timeout
    B9 Verification  target_cell=${PREP_CELL}

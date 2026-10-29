*** Settings ***
Documentation   CRT regression

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
...           CRT   CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB
...           SBTS00

Resource         taf/rfrl/common_resources/common_step/interface.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC002481/AGBL/B/resources/keywords_1796_B.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/A/resources/keywords_774_A.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/B/resources/keywords_774_B.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/keywords_7564_AB.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008116/resources/keywords_8116.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008116/resources/keywords_98256.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/B/resources/keywords_8238_B.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/D/resources/keywords_8238_D.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008021/resources/keywords_8021.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008200/resources/keywords_8200.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB012669/resources/keywords_669.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/require.robot
Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library          taf.sbts.oam.coam.admin    WITH NAME    coam
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py    WITH NAME    tl166_btslog
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC000732/A/resources/keywords_732_A.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC000732/F/resources/keywords_732_F.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008116/resources/test_specific_keywords_98256.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB012669/resources/test_specific_keywords_669.py
Variables        testsuite/Wroclaw/RRM/VRF_WRO2_T07/regression/regression_globals.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Suite Setup       Run keywords
...               initialise_attenuator                                                                              AND
...               Set counter period parameters for all

Suite Teardown    Run keyword and ignore error   interface.Common step trigger

Test Teardown     Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


*** Variables ***

${CELL_ID_732_A3}=                2

*** Test Cases ***
5GC000774_A_01_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD
    [Documentation]   This TC verifies whether VoNR with ROHC enabled is established correctly (FDD).
    ...               EDA for 04054426: ACC_UE_UL_DRB_DATA_5QI1 and ACC_UE_UL_DRB_DATA_PMQAP comparison since 24R3.
    [Tags]   SBTS22R3   SBTS22R4   SBTS23R1
    [Setup]       Run Keywords
    ...           nullify_attenuation_on_all_ports
    5GC000774_A_01_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD
    [Teardown]   Run Keywords
    ...           Detach UE    UE_1                                AND
    ...           Detach UE    UE_2                                AND
    ...           AdminUtils.Unlock All Cells                      AND
    ...           nullify_attenuation_on_all_ports                 AND
    ...           774_A_btslog.teardown_btslog                     AND
    ...           Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB007564-B_3_NG_FLOW_REL_GNB_UE_INACTIVITY_incrementation_with_UE_Context_released_due_to_DRB_inactivity
    [Documentation]   This test case verifies incrementation of counter provided to measure number QoS Flow release
     ...              when gNB initiated Ue Context Release due to DRB inactivity.
    [Tags]   SBTS22R3
    [Setup]       Run Keywords
     ...           nullify_attenuation_on_all_ports              AND
     ...           tl166_btslog.start_btslog_on_local_machine
    CB007564-B_3_NG_FLOW_REL_GNB_UE_INACTIVITY_incrementation_with_UE_Context_released_due_to_DRB_inactivity
    [Teardown]    Run Keywords
     ...           tl166_btslog.teardown_btslog                  AND
     ...           nullify_attenuation_on_all_ports              AND
     ...           Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


CB008200-B_6_NG_FLOW_SETUP_ATT_TOT_5QI1_and_NG_FLOW_SETUP_SUCC_TOT_5QI1_due_to_successful_setup_of_VoNR_call
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-B_6_NG_FLOW_SETUP_ATT_TOT_5QI1_and_NG_FLOW_SETUP_SUCC_TOT_5QI1_due_to_successful_setup_of_VoNR_call

CB008200-E_1_AVE_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-E_1_AVE_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup

CB008200-E_3_ACC_UE_DL_DRB_DATA_5QI1_and_ACC_UE_UL_DRB_DATA_5QI1_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-E_3_ACC_UE_DL_DRB_DATA_5QI1_and_ACC_UE_UL_DRB_DATA_5QI1_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1

CB008200-E_4_ACC_UE_DL_DRB_DATA_PMQAP_and_ACC_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-E_4_ACC_UE_DL_DRB_DATA_PMQAP_and_ACC_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1

CB008200-F_1_MAX_UE_DL_DRB_DATA_PMQAP_and_MAX_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-F_1_MAX_UE_DL_DRB_DATA_PMQAP_and_MAX_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered

CB008200-D_7_NG_FLOW_REL_NORMAL_5QI1_incrementation_due_to_release_with_normal_cause
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-D_7_NG_FLOW_REL_NORMAL_5QI1_incrementation_due_to_release_with_normal_cause

CB008200-D_8_NG_FLOW_SESSION_DUR_NORM_5QI1_incrementation_during_VoNR_call
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-D_8_NG_FLOW_SESSION_DUR_NORM_5QI1_incrementation_during_VoNR_call

CB008200-E_2_PEAK_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-E_2_PEAK_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup

CB008200-F_14_NG_FLOW_CON_SESSION_TIME_PMQAP_incrementation_due_to_duration_of_session
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-F_14_NG_FLOW_CON_SESSION_TIME_PMQAP_incrementation_due_to_duration_of_session

5GC001796_BB_TC76_DL_LA_iniDeltaCqi_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-15MHz_SA
    [Documentation]  check that during the transient phase improvement of 1796-B is applied and update of iniDeltaCqi
    ...              occurs for MCS different than highest and lowest MCS when NIDD parameter is set to TRUE (default value)
    [Tags]
    [Setup]      Run Keywords
    ...          nullify_attenuation_on_all_ports             AND
    ...          tl166_btslog.start_btslog_on_local_machine
    5GC002481_AGBL_5GC001796_BB_TC76_DL_LA_iniDeltaCqi_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-15MHz_SA
    [Teardown]   Run Keywords
    ...          Detach UE    UE_1                                AND
    ...          tl166_btslog.stop_and_collect_btslog                   AND
    ...          Teardown TTI Traces in Streaming mode            AND
    ...          nullify_attenuation_on_all_ports  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

5GC000774_A_03_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD_with_maxCidAllowed=1
    [Tags]     SBTS22R3   SBTS22R4
    [Documentation]   The TC verifies whether VoNR with ROHC works correctly, when maxCidAllowed=1. FDD
    5GC000774_A_03_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD_with_maxCidAllowed=1
    [Teardown]   Run Keywords
    ...           Detach UE    UE_1                                AND
    ...           Detach UE    UE_2                                AND
    ...           774_A_btslog.teardown_btslog  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

5GC000774_B_03_Verification_of_PM_counters_M55320C19001_M55320C19002_M55320C19003_and_M55320C19004
    [Documentation]   Check PM counters M55320C19001, M55320C19003, which are related to no. ROHC (de)compressions
    [Tags]     SBTS22R3   SBTS22R4
    5GC000774_B_03_Verification_of_PM_counters_M55320C19001_M55320C19002_M55320C19003_and_M55320C19004
    [Teardown]   Run Keywords
    ...           Detach UE    UE_1                                AND
    ...           Detach UE    UE_2                                AND
    ...           774_B_btslog.teardown_btslog  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

5GC000774_B_04_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_and_M55124C06002
    [Documentation]   Check PM counters M55135C01001, M55135C01002, M55124C06001 and M55124C06002
    [Tags]      SBTS22R4
    5GC000774_B_04_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_and_M55124C06002
    [Teardown]   Run Keywords
    ...           Detach UE    UE_1                                AND
    ...           Detach UE    UE_2                                AND
    ...           774_B_btslog.teardown_btslog  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

5GC000732-A_1_FDD_RLF_RRC_Connection_Re-establishment_Same_Serving_Cell_Valid_UE_Context
    [Documentation]    This TC checks whether reestablishment is performed correctly.
    [Tags]
    TC_5GC000732_A_1_FDD_RLF_RRC_Connection_Reestablishment_Same_Serving_Cell_Valid_UE_Context
    [Teardown]  Run keywords
    ...         TC_teardown_732_A  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

5GC000732-A_3_FDD_RLF_RRC_Connection_Re-establishment_With_the_Same_Serving_Cell_Counters_Update
    [Documentation]    This TC checks whether PM counters are updated correctly during reestablishment.
    [Tags]
    TC_5GC000732_A_3_setup
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${CELL_ID_732_A3}
    TC_5GC000732_A_3_FDD_RLF_RRC_Connection_Reestablishment_With_the_Same_Serving_Cell_Counters_Update
    [Teardown]  Run keywords
    ...         AdminUtils.unlock_all_cells     AND
    ...         TC_teardown_732_A               AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

5GC000732-F_10_FDD_RLF_RRC_Connection_Re-establishment_Same_Serving_Cell_Valid_UE_Context_int_VoNR_with Counters
    [Documentation]    This TC checks whether reestablishment works correctly during VoNR.
    [Tags]
    TC_5GC000732_F_10
    [Teardown]  Run keywords
    ...         F_10_teardown  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-B_2_Multi-UE_SA_DTX_interactions_with_non_GBR_traffic
    [Documentation]   This TC shall verify optimized DTX for mutli UE scenario
    [Tags]   CDRT    SBTS22R4   SBTS23R1
    keywords_8238_B.CB008238-5G-B_2_Multi-UE_SA_DTX_interactions_with_non_GBR_traffic
    [Teardown]  Run Keywords
    ...         keywords_8238_B.TC_teardown_B_2  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-B_4_Multi-UE_interactions_with_delay_sensitive_data_(VoNR)
    [Documentation]   This TC shall verify optimized DTX for mutli UE scenario with VoNr data flow
    keywords_8238_B.CB008238-5G-B_4_Multi-UE_interactions_with_delay_sensitive_data_(VoNR)
    [Tags]   SBTS22R4
    [Teardown]   Run Keywords
    ...         keywords_8238_B.TC_teardown_B_4  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-D_01_DTX_Scheduler_Enabling_Disabling_Based_On_Ues_In_C1_List
    [Documentation]  This TC verifies whether rdDtxCS1SizeThreshold can be reached for 2 UEs
    [Tags]   CDRT    SBTS22R4
    keywords_8238_D.CB008238-5G-D_01_DTX_Scheduler_Enabling_Disabling_Based_On_Ues_In_C1_List
    [Teardown]  Run Keywords
    ...         keywords_8238_D.TC_teardown_D_1   AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008021-A_1_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_1_enabledWithPRACH_PUCCH_F1
    [Tags]   SBTS22R4
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements for PRACH and PUCCH channel
    ${scf_default_A1}     backup current scf 8021
    [Setup]   Require Keyword   UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1_ADDITIONAL_COUNTERS
    CB008021-A_1_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_1_enabledWithPRACH_PUCCH_F1
    [Teardown]  Run Keywords
    ...         revert scf 8021    ${scf_default_A1}    AND
    ...         Nullify attenuation on all ports    AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal



CB008021-A_8_FDD_Activation_of_L1_measurements_for_1_enabledWithPRACH_PUCCH_F1
    [Documentation]   This testcase is checking L1 logs for uplink interference
    [Tags]   SBTS22R4
     ...              and noise measurements for PRACH and PUCCH F1 channel
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1
    CB008021-A_8_FDD_Activation_of_L1_measurements_for_1_enabledWithPRACH_PUCCH_F1

CB008021-A_9_Verification_of_scheduled_PRB_values_for_1_enabledWithPRACH_PUCCH_F1
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
    [Tags]   SBTS22R4
     ...              and noise measurements for PRACH and PUCCH F1 channel
    [Setup]   Require Keyword   UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1_ADDITIONAL_COUNTERS
    CB008021-A_9_Verification_of_scheduled_PRB_values_for_1_enabledWithPRACH_PUCCH_F1

CB008021-A_17_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_1_enabledWithPRACH_PUCCH_F1
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (with PRACH AND PUCCH_F1).
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1
    CB008021-A_17_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_1_enabledWithPRACH_PUCCH_F1

CB008021-A_2_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_2_enabledWithoutPRACH
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements without PRACH channel
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    CB008021-A_2_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_2_enabledWithoutPRACH
    [Teardown]  Run Keywords
    ...         CB008021 scf revert          AND
    ...         Nullify attenuation on all ports

CB008021-A_6_FDD_Activation_of_L1_measurements_for_2_enabledWithoutPRACH
    [Documentation]   This testcase is checking L1 logs for uplink interference
     ...              and noise measurements without PRACH channel
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    CB008021-A_6_FDD_Activation_of_L1_measurements_for_2_enabledWithoutPRACH

CB008021-A_10_Verification_of_scheduled_PRB_values_for_2_enabledWithoutPRACH
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PRACH channel
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    CB008021-A_10_Verification_of_scheduled_PRB_values_for_2_enabledWithoutPRACH

CB008021-A_18_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_2_enabledWithoutPRACH
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (without PRACH channel).
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    CB008021-A_18_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_2_enabledWithoutPRACH

CB008021-A_3_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements without PUCCH channel
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    CB008021-A_3_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_3_enabledWithoutPUCCH_F1
    [Teardown]  Run Keywords
    ...         CB008021 scf revert          AND
    ...         Nullify attenuation on all ports
#
CB008021-A_5_FDD_Activation_of_L1_measurements_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This testcase is checking L1 logs for uplink interference
     ...              and noise measurements for PUCCH channel
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    CB008021-A_5_FDD_Activation_of_L1_measurements_for_3_enabledWithoutPUCCH_F1

CB008021-A_11_Verification_of_scheduled_PRB_values_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PUCCH channel
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    CB008021-A_11_Verification_of_scheduled_PRB_values_for_3_enabledWithoutPUCCH_F1

CB008021-A_19_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (without PUCCH channel).
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    CB008021-A_19_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_3_enabledWithoutPUCCH_F1

CB008021-A_4_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements without PRACH and PUCCH channel
    [Tags]   SBTS22R4
    ${scf_default_A4}     backup current scf 8021
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
    CB008021-A_4_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_4_enabledWithoutPRACH_PUCCH_F1
    [Teardown]  Run Keywords
    ...         revert scf 8021    ${scf_default_A4}    AND
    ...         Nullify attenuation on all ports    AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008021-A_7_FDD_Activation_of_L1_measurements_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This testcase is checking L1 logs for uplink interference
     ...              and noise measurements with PRACH and PUCCH channel disabled
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
    CB008021-A_7_FDD_Activation_of_L1_measurements_for_4_enabledWithoutPRACH_PUCCH_F1

CB008021-A_12_Verification_of_scheduled_PRB_values_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements with PRACH and PUCCH channel disabled
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
    CB008021-A_12_Verification_of_scheduled_PRB_values_for_4_enabledWithoutPRACH_PUCCH_F1

CB008021-A_20_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (without PRACH and PUCCH F1).
    [Tags]   SBTS22R4
    [Setup]   Require Keyword   REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
   CB008021-A_20_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_4_enabledWithoutPRACH_PUCCH_F1

CB008200-D_2_NG_FLOW_REL_GNB_UE_LOST_5QI1_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART_2__D_2__F_8__RLF
    CB008200-D_2_NG_FLOW_REL_GNB_UE_LOST_5QI1_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF

CB008200-F_8_NG_FLOW_REL_GNB_RLF_PMQAP_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART_2__D_2__F_8__RLF
    CB008200-F_8_NG_FLOW_REL_GNB_RLF_PMQAP_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF

CB008200-B_7_NG_FLOW_STP_ATT_RES_IADU_5QI1_and_NG_FLOW_STP_SUC_RES_IADU_5QI1_due_to_reestablishment_to_different_cell_same_gNB
    [Tags]     SBTS22R4
    [Setup]   Require Keyword   REQ_PART_3__B_7__F_15__REESTABLISHMENT
    CB008200-B_7_NG_FLOW_STP_ATT_RES_IADU_5QI1_and_NG_FLOW_STP_SUC_RES_IADU_5QI1_due_to_reestablishment_to_different_cell_same_gNB

CB008200-F_15_NG_FLOW_STP_ATT_RES_IADU_PMQAP_and_NG_FLOW_STP_SUC_RES_IADU_PMQAP_due_to_reestablishment_to_different_cell_same_gNB
    [Tags]     SBTS22R4
    [Setup]   Require Keyword   REQ_PART_3__B_7__F_15__REESTABLISHMENT
    CB008200-F_15_NG_FLOW_STP_ATT_RES_IADU_PMQAP_and_NG_FLOW_STP_SUC_RES_IADU_PMQAP_due_to_reestablishment_to_different_cell_same_gNB

CB008200-B_3_NG_FLOW_STP_ATT_INC_HO_5QI1_and_NG_FLOW_STP_SUC_INC_HO_5QI1_due_to_Intra-gNB_Intra_DU_HO
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART_6__B_3__D_3__F_4__F_9__INTRA__gNB__HO
    CB008200-B_3_NG_FLOW_STP_ATT_INC_HO_5QI1_and_NG_FLOW_STP_SUC_INC_HO_5QI1_due_to_Intra-gNB_Intra_DU_HO

CB008200-D_3_NG_FLOW_REL_IANR_SUC_HO_5QI1_incrementation_due_to_Intra-gNB_Intra_DU_HO
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART_6__B_3__D_3__F_4__F_9__INTRA__gNB__HO
    CB008200-D_3_NG_FLOW_REL_IANR_SUC_HO_5QI1_incrementation_due_to_Intra-gNB_Intra_DU_HO

CB008200-F_4_NG_FLOW_STP_ATT_INC_HO_PMQAP_and_NG_FLOW_STP_SUC_INC_HO_PMQAP_due_to_Intra-gNB_Intra_DU_HO
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART_6__B_3__D_3__F_4__F_9__INTRA__gNB__HO
    CB008200-F_4_NG_FLOW_STP_ATT_INC_HO_PMQAP_and_NG_FLOW_STP_SUC_INC_HO_PMQAP_due_to_Intra-gNB_Intra_DU_HO

CB008200-F_9_NG_FLOW_REL_IANR_SUC_HO_PMQAP_incrementation_due_to_Intra-gNB_Intra_DU_HO
    [Tags]     SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART_6__B_3__D_3__F_4__F_9__INTRA__gNB__HO
    CB008200-F_9_NG_FLOW_REL_IANR_SUC_HO_PMQAP_incrementation_due_to_Intra-gNB_Intra_DU_HO

CB008116-A_1_Integrity_Protection_in_DL_with_AES_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in DL direction and AES IP algorithm.
    CB008116-A_1_Integrity_Protection_in_DL_with_AES_IP_algorithm_ASIB_ABIO

CB008116-A_2_Integrity_Protection_in_DL_with_SNOW_3G_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in DL direction and SNOW 3G algorithm.
    CB008116-A_2_Integrity_Protection_in_DL_with_SNOW_3G_IP_algorithm_ASIB_ABIO

CB008116-A_3_Integrity_Protection_in_DL_with_ZUC_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in DL direction and ZUC algorithm.
    CB008116-A_3_Integrity_Protection_in_DL_with_ZUC_IP_algorithm_ASIB_ABIO

CB008116-A_4_Integrity_Protection_in_UL_with_AES_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in UL direction and AES IP algorithm
    CB008116-A_4_Integrity_Protection_in_UL_with_AES_IP_algorithm_ASIB_ABIO

CNI_98256_B_15_Intra_gNB_HO_with_UPIP_activated_and_IP_’preferred’
    [Documentation]   This test case aims to check the behavior of Nokia gNB in SA mode
     ...              during the intra gNB Handover with UPIP activated and
     ...              Integrity protection Indication value set to 'preferred'.
     CNI_98256_B_15_Intra_gNB_HO_with_UPIP_activated_and_IP_preferred

CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz
    [Documentation]   The purpose of this TC is
    CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz


*** Keywords ***
REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    Require Ues    num_of_ues=2    capabilities=SA_VONR
    PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call


REQ_PART_2__D_2__F_8__RLF
    Require Ues    num_of_ues=2    capabilities=SA_VONR
    PART_2__D_2__F_8__RLF


REQ_PART_3__B_7__F_15__REESTABLISHMENT
    Require Ues    num_of_ues=2    capabilities=SA_VONR
    PART_3__B_7__F_15__REESTABLISHMENT


REQ_PART_6__B_3__D_3__F_4__F_9__INTRA__gNB__HO
    Require Ues    num_of_ues=2    capabilities=SA_VONR
    PART_6__B_3__D_3__F_4__F_9__INTRA__gNB__HO


REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1
    [Documentation]   Setup for CB008021 testcases using PRACH and PUCCH F1 measurement
    Run Keywords
    ...            Nullify attenuation on all ports      AND
    ...            Set attenuation    90    ${cell_2_attenuator_ports}
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1
    [Teardown]     Nullify attenuation on all ports


REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    [Documentation]   Setup for CB008021 testcases using interference measurement without PRACH
    Run Keywords
    ...            Nullify attenuation on all ports      AND
    ...            Set attenuation    90    ${cell_2_attenuator_ports}
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    [Teardown]     Nullify attenuation on all ports


REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    [Documentation]   Setup for CB008021 testcases using interference measurement without PUCCH
    Run Keywords
    ...            Nullify attenuation on all ports      AND
    ...            Set attenuation    90    ${cell_2_attenuator_ports}
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    [Teardown]     Nullify attenuation on all ports


REQ_UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
    [Documentation]   Setup for CB008021 testcases using interference measurement without PUCCH and PRACH
    Run Keywords
    ...            Nullify attenuation on all ports      AND
    ...            Set attenuation    90    ${cell_2_attenuator_ports}
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
    [Teardown]     Nullify attenuation on all ports

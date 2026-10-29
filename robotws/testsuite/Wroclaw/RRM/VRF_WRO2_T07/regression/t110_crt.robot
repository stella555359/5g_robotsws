*** Settings ***
Documentation    All T110 CRT regression TCs shall be added here for fully automated regression testing.


Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008985/resources/keywords_8985.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008434/resources/keywords_8434.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008200/resources/keywords_8200.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/keywords_7564_AB.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/keywords_9333.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/require.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008941/resources/keywords_8941.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CNI99270/resources/keywords_99270.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py    WITH NAME    tl166_btslog
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T07/regression/regression_globals.py


Suite Setup      Run Keywords
...              Initialise Attenuator                            AND
...              Set counter period parameters for all

Test Teardown     Add scout external execution id to the reporting portal

*** Test Cases ***
CB008985_A_02_FeatureActivationDeactivation
    [Documentation]   The purpose of this TC is to verify if the feature can be activated and deactivated.
    [Setup]           Run Keywords
    ...               Nullify attenuation on all ports                 AND
    ...               BTSLOG Start btslog on local machine
    CB008985_A_02_FeatureActivationDeactivation
    [Teardown]        Run Keywords
    ...               BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                 AND
    ...               Add scout external execution id to the reporting portal


CB008985_A_06_SA_SingleUE_Attach_allSubcells_L3Call
    [Documentation]   The purpose of this TC is to verify if UE in SA mode get attach
    ...               and call can be performed in all sub-cells.
    [Setup]           Run Keywords
    ...               Nullify attenuation on all ports                 AND
    ...               BTSLOG Start btslog on local machine
    CB008985_A_06_SA_SingleUE_Attach_allSubcells_L3Call
    [Teardown]        Run Keywords
    ...               BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                 AND
    ...               Add scout external execution id to the reporting portal

CB008985_A_07_SA_Subcell_Switch_failure_recovery
    [Documentation]   The purpose of this TC is to verify if UE can recover after subcell switch failure.
    [Setup]           Run Keywords
    ...               Nullify attenuation on all ports                 AND
    ...               BTSLOG Start btslog on local machine
    CB008985_A_07_SA_Subcell_Switch_failure_recovery
    [Teardown]        Run Keywords
    ...               BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                 AND
    ...               Add scout external execution id to the reporting portal

CB008985_A_12_SA_VoNR_Call
    [Documentation]   The purpose of this TC is to verify if VoNR call can be performed in supercell.
    [Setup]           Run Keywords
    ...               Nullify attenuation on all ports                 AND
    ...               BTSLOG Start btslog on local machine
    CB008985_A_12_SA_VoNR_Call
    [Teardown]        Run Keywords
    ...               BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                 AND
    ...               Add scout external execution id to the reporting portal

CB008434_A_01_SuperCellSetup_HalfABIO_1x3subcells_AZHM
    [Documentation]   The purpose of this TC is to check if one NR FR1 TDD super cell (up to 3 subcells)
    ...               can be set up for Half ABIO configuration.
    [Setup]           Run Keywords
    ...               Nullify attenuation on all ports                 AND
    ...               BTSLOG Start btslog on local machine
    CB008434_A_01_SuperCellSetup_HalfABIO_1x3subcells_AZHM
    [Teardown]        Run Keywords
    ...               BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                 AND
    ...               Add scout external execution id to the reporting portal

CB008434_B_01_SuperCellSetup_FullABIO_6Subcells_AZHM
    [Documentation]   The purpose of this TC is to check if one NR FR1 TDD super cell
    ...               (up to 6 subcells) can be set up for Full ABIO configuration.
    [Setup]           Run Keywords
    ...               Nullify attenuation on all ports                 AND
    ...               BTSLOG Start btslog on local machine
    CB008434_B_01_SuperCellSetup_FullABIO_6Subcells_AZHM
    [Teardown]        Run Keywords
    ...               BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                 AND
    ...               Add scout external execution id to the reporting portal

CB008985_B_04_HighSpeedCell_SA_VoNRCall_HSTCB
    [Documentation]   The purpose of this TC is to verify if UE can be attached to Super cell with
    ...               High Speed Cell Feature enabled and if VoNR call is possible to establish.
    [Setup]           Run Keywords
    ...               Nullify attenuation on all ports                 AND
    ...               test_specific_keywords_8985.HighSpeed Cell Activation                        AND
    ...               BTSLOG Start btslog on local machine
    CB008985_B_04_HighSpeedCell_SA_VoNRCall_HSTCB
    [Teardown]        Run Keywords
    ...               Nullify attenuation on all ports                 AND
    ...               test_specific_keywords_8985.HighSpeed Cell Deactivation                      AND
    ...               BTSLOG Collect btslog                            AND
    ...               Add scout external execution id to the reporting portal

CB007564-B_3_NG_FLOW_REL_GNB_UE_INACTIVITY_incrementation_with_UE_Context_released_due_to_DRB_inactivity
    [Documentation]   This test case verifies incrementation of counter provided to measure number QoS Flow release
     ...              when gNB initiated Ue Context Release due to DRB inactivity.
    [Tags]            SBTS22R3
    [Setup]           Run Keywords
     ...              nullify_attenuation_on_all_ports                 AND
     ...              tl166_btslog.start_btslog_on_local_machine
    CB007564-B_3_NG_FLOW_REL_GNB_UE_INACTIVITY_incrementation_with_UE_Context_released_due_to_DRB_inactivity
    [Teardown]        Run Keywords
     ...              tl166_btslog.teardown_btslog                     AND
     ...              nullify_attenuation_on_all_ports                 AND
     ...              Add scout external execution id to the reporting portal

CB008200-B_6_NG_FLOW_SETUP_ATT_TOT_5QI1_and_NG_FLOW_SETUP_SUCC_TOT_5QI1_due_to_successful_setup_of_VoNR_call
    [Tags]            SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-B_6_NG_FLOW_SETUP_ATT_TOT_5QI1_and_NG_FLOW_SETUP_SUCC_TOT_5QI1_due_to_successful_setup_of_VoNR_call
    [Teardown]        Run Keywords
    ...               Run Keyword and Ignore Error    BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                                                 AND
    ...               Add scout external execution id to the reporting portal

CB008200-E_1_AVE_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup
    [Tags]            BTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-E_1_AVE_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup
    [Teardown]        Run Keywords
    ...               Run Keyword and Ignore Error    BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                                                 AND
    ...               Add scout external execution id to the reporting portal

CB008200-E_3_ACC_UE_DL_DRB_DATA_5QI1_and_ACC_UE_UL_DRB_DATA_5QI1_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1
    [Tags]            SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-E_3_ACC_UE_DL_DRB_DATA_5QI1_and_ACC_UE_UL_DRB_DATA_5QI1_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1
    [Teardown]        Run Keywords
    ...               Run Keyword and Ignore Error    BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                                                 AND
    ...               Add scout external execution id to the reporting portal

CB008200-E_4_ACC_UE_DL_DRB_DATA_PMQAP_and_ACC_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1
    [Tags]            SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-E_4_ACC_UE_DL_DRB_DATA_PMQAP_and_ACC_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1
    [Teardown]        Run Keywords
    ...               Run Keyword and Ignore Error    BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                                                 AND
    ...               Add scout external execution id to the reporting portal

CB008200-F_1_MAX_UE_DL_DRB_DATA_PMQAP_and_MAX_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered
    [Tags]            SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-F_1_MAX_UE_DL_DRB_DATA_PMQAP_and_MAX_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered
    [Teardown]        Run Keywords
    ...               Run Keyword and Ignore Error    BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                                                 AND
    ...               Add scout external execution id to the reporting portal

CB008200-D_7_NG_FLOW_REL_NORMAL_5QI1_incrementation_due_to_release_with_normal_cause
    [Tags]            SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-D_7_NG_FLOW_REL_NORMAL_5QI1_incrementation_due_to_release_with_normal_cause
    [Teardown]        Run Keywords
    ...               Run Keyword and Ignore Error    BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                                                 AND
    ...               Add scout external execution id to the reporting portal

CB008200-D_8_NG_FLOW_SESSION_DUR_NORM_5QI1_incrementation_during_VoNR_call
    [Tags]            SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-D_8_NG_FLOW_SESSION_DUR_NORM_5QI1_incrementation_during_VoNR_call
    [Teardown]        Run Keywords
    ...               Run Keyword and Ignore Error    BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                                                 AND
    ...               Add scout external execution id to the reporting portal

CB008200-E_2_PEAK_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup
    [Tags]            SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-E_2_PEAK_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup
    [Teardown]        Run Keywords
    ...               Run Keyword and Ignore Error    BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                                                 AND
    ...               Add scout external execution id to the reporting portal

CB008200-F_14_NG_FLOW_CON_SESSION_TIME_PMQAP_incrementation_due_to_duration_of_session
    [Tags]            SBTS22R3   SBTS22R4
    [Setup]   Require Keyword   REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    CB008200-F_14_NG_FLOW_CON_SESSION_TIME_PMQAP_incrementation_due_to_duration_of_session
    [Teardown]        Run Keywords
    ...               Run Keyword and Ignore Error    BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                                                 AND
    ...               Add scout external execution id to the reporting portal

CB009333_B_6_Multi_UE_interaction_with_micro_DTX_optimized_scheduling_enabled_on_Multiple_TDD_cell_on_Same_PA_SA_only
    [Documentation]   This Test Case describes expected Nokia gNB behavior and micro DTX optimized scheduling enabled
     ...              on multiple cells in TDD SA configuration.
    [Setup]           Run Keywords
    ...               Nullify attenuation on all ports                 AND
    ...               BTSLOG Start btslog on local machine
    CB009333_B_6_Multi_UE_interaction_with_micro_DTX_optimized_scheduling_enabled_on_Multiple_TDD_cell_on_Same_PA_SA_only
    [Teardown]        Run Keywords
    ...               BTSLOG Collect btslog                            AND
    ...               Nullify attenuation on all ports                 AND
    ...               Add scout external execution id to the reporting portal

CB008941-5G_06_Verify_SRS_triggered_with_PUSCH_mapping_type_B_on_DU_with_Loki_BB_HW_eCPRI_TDD_FR1_FD_Beamforming_RU
    [Documentation]   This user scenario validates system behavior in case when UL UP dynamic fragmentation
    ...               is activated and SRS is triggered with PUSCH mapping type B, the data transmission
    ...               in eCPRI uplink contains the NR IQ of scheduled PRBs for TDD FR1 deployments,
    ...               the NR carrier supports UL PRB dynamic fragmentation. No impact when the SRS is triggered
    ...               in last symbol with PUSCH mapping type B. This Test Case will check also counters from test 08:
    ...               M55308C10002 (PRBs used for PUSCH) and M55308C10004 (PRBs available for PUSCH)
    CB008941-5G_06_Verify_SRS_triggered_with_PUSCH_mapping_type_B_on_DU_with_Loki_BB_HW_eCPRI_TDD_FR1_FD_Beamforming_RU
    [Teardown]  Run Keywords
    ...        Add scout external execution id to the reporting portal

CNI-99270_03_SA_2CC_DLCA_Supercell_Intraband_covBasedA1
    [Documentation]   The purpose of this TC is to verify if UE can be attached to Super cell
    ...               and intra band DL CA 2CC TDD in SA mode can be
    ...               set up with sCellAdditionMethod set to covBasedA1.
    CNI-99270_03_SA_2CC_DLCA_Supercell_Intraband_covBasedA1
    [Teardown]        Add scout external execution id to the reporting portal

CNI-99270_05_NSA_2CC_DLCA_Supercell_Interband_covBasedA1
    [Documentation]   The purpose of this TC is to verify if UE can be attached to Super cell (NSA)
    ...               and inter band DL CA 2CC TDD in SA mode can be
    ...               set up with sCellAdditionMethod set to covBasedA1.
    CNI-99270_05_NSA_2CC_DLCA_Supercell_Interband_covBasedA1
    [Teardown]        Add scout external execution id to the reporting portal


*** Keywords ***
REQ_PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    attach_utils.Require Ues    num_of_ues=2    capabilities=SA_VONR
    PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call


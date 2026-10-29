*** Settings ***
Documentation    All T109 CIT regression TCs shall be added here for fully automated regression testing.

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP   PY36
...           CRT   CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIK_ABIL_3xAHLOA_ENB
...           SBTS00

Library          taf.ue
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB007781/A/resources/keywords_7781.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library          testsuite/Wroclaw/RRM/resources/TestCaseRequirement.py
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000501/resources/keywords_501.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/keywords_7564_C.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/A/resources/keywords_8238_A.robot
Resource         taf/rfrl/common_resources/common_step/interface.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Suite Setup       Run keywords
...               prepare_testline     second_wind=${True}             AND
...               Initialise Attenuator

Test Setup        Run keywords
...               Set TESTNAME without spaces         AND
...               Nullify attenuation on all ports    AND
...               Upload runtime ini to gnb

Test Teardown     Run keywords
...               Make snapshot in case of error      AND
...               Nullify attenuation on all ports  AND
...          Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


Suite Teardown    Run keywords
...               Release attenuator                                                AND
...               Run keyword and ignore error   interface.Common step trigger


*** Test Cases ***
5GC000501_A_23_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_handovers_handling
    [Documentation]  This test describes automation part for feature 5GC000501 which concerns parameters verification and handovers handling.
    [Tags]   SBTS22R3   SBTS22R4
    ...              This test covers following operations realated to the Graceful cell shutdown feature like:
    ...              1) Check of neccessary precondition parameters,
    ...              2) Check feature activation parameter,
    ...              3) Check feature proper working according to feature's parameters values,
    ...              4) Check 'Intra gnB intra frequency' handover,
    ...              5) Check proper feauture deactivation working according to feature's parameters values.
    [1.0] 5GC000501_A_23_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_handovers_handling


5GC000501_A_22_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_invalid_parameters_values_handling
    [Documentation]  This test describes automation part for feature 5GC000501 which concerns validation and handling
    ...              of invalid values for parameters.
    ...              This test covers following operations realated to the Gracefull cell shutdown feature like:
    ...              1) Check if test fail for out of range parameters values
    ...              2) Check if feauture activation fail becouse of invalid parameters
    [Tags]
    [1][1.0] 5GC000501_A_22_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_invalid_parameters_values_handling


5GC000501_A_21_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_operators_parameters_check
    [Documentation]  This test describes automation part for feature 5GC000501 which concerns operator's parameters check.
    ...              This test covers following operations realated to the Gracefull cell shutdown feature like:
    ...              Check operator's parameters after graceful cell shutdown
    [Tags]
    [1][1.0] 5GC000501_A_21_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_operators_parameters_check


CB007564-C_5_RA_CB_INIT_RESOLVED_incrementation_due_to_successful_initial_RA_setup_with_CRC_OK_and_contention_resolved
    [Documentation]   This test case verifies incrementation of counter provided to measure number of time when
     ...              RA setup is successful and the contention is resolved by UL grant addressed to its CRNTI.
     ...              Contention is considered resolved when an UL transmission with CRC OK is received.
    [Tags]   SBTS22R3   SBTS22R4
    [Setup]      Run Keywords
    ...          BTSLOG Start btslog on local machine         AND
    ...          Initialise Attenuator                        AND
    ...          Nullify attenuation on all ports
    CB007564-C_5_RA_CB_INIT_RESOLVED_incrementation_due_to_successful_initial_RA_setup_with_CRC_OK_and_contention_resolved
    [Teardown]   Run Keywords
    ...          Make snapshot in case of error               AND
    ...          BTSLOG Collect btslog                        AND
    ...          Nullify attenuation on all ports             AND
    ...          AdminUtils.Unlock All Cells                  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB007564-C_6_RA_MSG3_RECEP_INIT_incrementation_due_to_successful_initial_RA_setup
    [Documentation]   This test case verifies incrementation of counter provided to measure number of time when
     ...              RA setup is successful and msg3 is received successfully from UE.
    [Tags]   SBTS22R3   SBTS22R4
    [Setup]      Run Keywords
    ...          BTSLOG Start btslog on local machine         AND
    ...          Initialise Attenuator                        AND
    ...          Nullify attenuation on all ports
    CB007564-C_6_RA_MSG3_RECEP_INIT_incrementation_due_to_successful_initial_RA_setup
    [Teardown]   Run Keywords
    ...          Make snapshot in case of error               AND
    ...          BTSLOG Collect btslog                        AND
    ...          Nullify attenuation on all ports             AND
    ...          AdminUtils.Unlock All Cells                  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB007564-C_8_Incrementation_of_counters_due_to_initial_access_based_on_contention_free_procedure
    [Documentation]   This test case verifies incrementation of counter provided to measure number of times when
     ...              dedicated preamble is sent to the UE from gNB for initial access: DED_PREAMBL_SENT_CFRA_INIT,
     ...              number of time when dedicated preamble assigned to UE by the gNB is used by UE during Msg1:
     ...              INIT_RA_ATT_CFRA_and_DED_PREAMBL_USED_CFRA_INIT_and_INIT_MSG1_ACK_CFRA and number of time when
     ...              CFRA setup is successful and the UE responds in first UL transmission
     ...              that CRC is OK: INIT_MSG2_ACK_CFRA.
    [Tags]   SBTS22R4
    [Setup]      Run Keywords
    ...          BTSLOG Start btslog on local machine         AND
    ...          Initialise Attenuator                        AND
    ...          Nullify attenuation on all ports
    CB007564-C_8_Incrementation_of_counters_due_to_initial_access_based_on_contention_free_procedure
    [Teardown]   Run Keywords
    ...          Make snapshot in case of error               AND
    ...          BTSLOG Collect btslog                        AND
    ...          Nullify attenuation on all ports             AND
    ...          AdminUtils.Unlock All Cells                  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


CB007781_5G_A_1_Dynamic_Transform_Precoder_Switching_SA_UE_DCI_0_1_5MHz_UDP
    [Documentation]    This TC checks whether transform is correctly switched on.
    [Tags]   SBTS22R3   SBTS22R4
    TC_CB007781_5G_A_1_Dynamic_Transform_Precoder_Switching_SA_UE_DCI_0_1_5MHz_UDP
    [Teardown]  Run keywords
    ...         keywords_7781.TC_teardown                  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


CB007781_5G_A_2_Dynamic_Transform_Precoder_Switching_NSA_UE_DCI_0_1_20MHz_TCP_Open_Loop_MIMO
    [Documentation]    This TC checks whether transform is correctly switched on.
    [Tags]
    TC_CB007781_5G_A_2_Dynamic_Transform_Precoder_Switching_NSA_UE_DCI_0_1_20MHz_SRB3_TCP_Open_Loop_MIMO
    [Teardown]  Run keywords
    ...         keywords_7781.TC_teardown                  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


CB007781_5G_A_3_Transform_Precoder_activation_16QAM_DMRS_Active_NSA_UE
    [Documentation]    This TC checks whether transform is correctly switched on.
    [Tags]
    TC_CB007781_5G_A_3_Transform_Precoder_activation_16QAM_DMRS_Active_NSA_UE
    [Teardown]  Run keywords
    ...         keywords_7781.TC_teardown                  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238_A_03_Single-UE_small_packet_timer_lower_than_dtxMaxRetentionDelay_on_NSA
    [Documentation]   This TC shall verify the optimized DTX algorithm when traffic interval is LOWER than dtxMaxRetentionDelay
    [Tags]   SBTS22R4
    CB008238_A_03_Single-UE_small_packet_timer_lower_than_dtxMaxRetentionDelay_on_NSA
    [Teardown]  Run Keywords
    ...         TC_teardown_8238_A                  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

*** Settings ***
Documentation    All CIT regression TCs shall be added here for fully automated regression testing.

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
...           CRT

Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py    WITH NAME    t119_btslog
Library          taf.sbts.oam.coam.admin        WITH NAME  coam
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.py
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/A/resources/keywords_8238_A.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000723_5GC000728/resources/keywords_723.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/keywords_7564_AB.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008200/resources/keywords_8200.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC002333/resources/keywords_2333.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001178/resources/keywords_1178_BE.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001178/resources/keywords_1178_BB.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/A/resources/keywords_8238_A.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/C/resources/keywords_8238_C.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/E/resources/keywords_8238_E.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/F/resources/keywords_8238_F.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/keywords_9333.robot
Resource         taf/rfrl/common_resources/common_step/interface.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/require.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000501/resources/keywords_501.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC000431/resources/keywords_431.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009059/resources/keywords_9059.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009059/resources/test_specific_keywords_9059.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/keywords_8409.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_8409.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB012669/resources/keywords_669.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CNI-126050/resources/CNI-126050_keywords.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB012439/resources/keywords_CB012439.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB013152/resources/keywords_CB013152.robot





Suite Setup     Run Keywords
...             initialise_attenuator                                                AND
...             Nullify attenuation on all ports


Suite Teardown  Run keywords
...             Get active alarms                                               AND
...             Run keyword and ignore error   interface.Common step trigger

Test Setup      Run Keywords
...             t119_btslog.start_btslog_on_local_machine

Test Teardown   Run Keywords
...             testline_preparation.what_is_wrong_with_pdu                     AND
...             testline_preparation.wake_up_samurai                            AND
...             TcpdumpSmod.teardown_tcpdump_on_smod                            AND
...             Run keyword if test failed    AdminUtils.collect_snapshot       AND
...             t119_btslog.stop_and_collect_btslog                             AND
...             Add scout external execution id to the reporting portal

*** Variables ***
# TODO: NEW VARIABLES (USE FOR EDA)
${GCS_CELL_ID}            1
${CALL_FLAG}              call   #call/no_call
&{START_UE}               call=Start call   no_call=Attach
&{STOP_UE}                call=Stop call    no_call=Detach
${CHECK_TYPE}             NAA    #NAA/ANTL
&{BEFORE_CHECK}           NAA=Measure RX power on UE before shutdown  ANTL=Start Power Measurement in Webem
&{WHILE_CHECK}            NAA=Measure RX power on UE while shutdown   ANTL=Stop Power Measurement in Webem
${DEPLOYMENT_MODE}        SA     #SA/NSA
&{RSRP_KEY_MAP}           NSA=nrDbm  SA=dbm
&{JSON_KEY_TL_MAP}        50078=(NRCell1)  50096=(51997-01)  41810=(AHPMDB1)  55200=(55200-00)
# TODO: ANTL MONITORING IN WEBEM IS MORE STABLE WHEN ${SHUTDOWN_WINDOW}/${SHUTDOWN_STEP_AMOUNT} equals 10
${SHUTDOWN_WINDOW}        ${180}   #(6, 12, 18?, 180 sec)
${SHUTDOWN_STEP_AMOUNT}   ${6}     #(1,2,3?.16)
${DEVIATION}              ${1}     #deviation for every shutdown step [dB] (3dB +- deviation)


*** Test Cases ***
CB009333_D_1_Micro-DTX_scheduler_with_DRX_configured
    [Documentation]   This Test Case describes expected Nokia gNB behaviour for UE with configured DRX is scheduled
     ...              during the DRX Active time
    CB009333_D_1_Micro-DTX_scheduler_with_DRX_configured
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

CB009333_F_1_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_SA
    [Documentation]   This Test Case describes expected Nokia gNB behaviour for RLC status PDU (for UL packets)
    ...               are scheduled on DL in the same manner as any delay-sensitive data in terms of
    ...               micro-DTX functionality. Scheduling of delay-sensitive data is not impacted.
    ...               Delay-sensitive data includes: SSBs, TRS, System Information including SIB1 (optional for NSA),
    ...               other SIBs (only for SA), paging ? SA Case.
    CB009333_F_1_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_SA
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

CB008238_A_03_Single-UE_small_packet_timer_lower_than_dtxMaxRetentionDelay_on_NSA
    [Documentation]   This TC shall verify the optimized DTX algorithm when traffic interval is LOWER than dtxMaxRetentionDelay
    [Tags]   SBTS22R4
    CB008238_A_03_Single-UE_small_packet_timer_lower_than_dtxMaxRetentionDelay_on_NSA
    [Teardown]  Run Keywords
    ...         TC_teardown_8238_A                  AND
    ...         Add scout external execution id to the reporting portal

CB008238_A_09_Single-UE_small_packet_timer_higher_than_dtxMaxRetentionDelay_on_NSA+SA (SA)
    [Documentation]   This TC shall verify the optimized DTX algorithm when traffic interval is HIGHER than dtxMaxRetentionDelay.
    [Tags]   CDRT
    ...      SBTS22R4
    CB008238_A_09_Single-UE_small_packet_timer_higher_than_dtxMaxRetentionDelay_on_NSA+SA (SA)
    [Teardown]  Run Keywords
    ...          TC_teardown_8238_A                AND
    ...          Add scout external execution id to the reporting portal

CB008238-5G-E_1_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_SA_mode_FDD_FDD
    [Documentation]  This TC checks whether CB008238 is turned on and off correctly, when SCell activates/deactivates.
    CB008238-5G-E_1_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_SA_mode_FDD_FDD
    [Teardown]   Run Keywords
    ...          TC_teardown_E                AND
    ...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal    AND
    ...              qrxlevmin_8238_E_teardown

CB008238-5G-E_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_for_SA_mode_for_blind_method_activation_FDD_FDD
    [Documentation]  This TC checks whether CB008238 is turned on and off correctly, when SCell activates/deactivates.
    CB008238-5G-E_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_for_SA_mode_for_blind_method_activation_FDD_FDD
    [Teardown]   Run Keywords
    ...          TC_teardown_E                AND
    ...          Add scout external execution id to the reporting portal    AND
    ...          qrxlevmin_8238_E_teardown

CB008238-5G-F_7_Single-UE_conditional_buffering_based_on_the_delay_since_last_scheduling_with_counters_incremented_M55308C33000_5308C33001_SA
    [Documentation]  This TC verifies whether delaySinceLastScheduled works correctly for tput BELOW threshold.
    [Tags]   CDRT
    ...      SBTS22R4
    CB008238-5G-F_7
    [Teardown]   Run Keywords
    ...          TC_teardown_F_7                AND
    ...          Add scout external execution id to the reporting portal

CB008238-5G-C_6_Single_UE_Max_Throughput
    [Documentation]   This TC verifies whether feature CB008238-C doesn't negatively affect throughput.
    [Tags]   SBTS22R4
    CB008238-5G-C_6_Single_UE_Max_Throughput
    [Teardown]   Run Keywords
    ...          TC_teardown_C_6                AND
    ...          Add scout external execution id to the reporting portal

[1]5GC000431_A_15_Un-suspend_Load-Based_Power_Saving
    [Tags]   CDRT
    [Setup]     Run keywords
    ...         t119_btslog.start_btslog_on_local_machine                                              AND
    ...         Setup A7
    [1]5GC000431_A_15_Un-suspend_Load-Based_Power_Saving
    [Teardown]   Run Keywords
    ...          Add scout external execution id to the reporting portal

5GC000501_A_24_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_release_handling
    [Setup]     Run keywords
    ...         t119_btslog.start_btslog_on_local_machine                                              AND
    ...         Require Ue  ${UE_ALIAS}  capabilities=REAL_UE_SA
    [1.0] 5GC000501_A_24_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_release_handling
    [Teardown]  Run keywords
    ...         Detach Ue      ${UE_ALIAS}                                                             AND
    ...         stop_data_transfer_if_active                                                           AND
    ...         Stop Using Ue  ${UE_ALIAS}                                                             AND
    ...         AdminUtils.unlock_all_cells                                                            AND
    ...         Run keyword if test failed  AdminUtils.collect_snapshot                                AND
    ...             Add scout external execution id to the reporting portal

[1]CB009059_A_1_One_PDU_ICS_Blind_SCell_Add_two_FR1_CA_eligible_DRB_one_no_FR1_CA_eligible_DRB_with_additional_QoS_Flow
    [Tags]  CRT  24R2  A1
    [Setup]     Run keywords
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}    AND
    ...             Start syslog capture                                AND
    ...             Create init list of dts for tc                      AND
    ...             Wait for next counter interval                      AND
    ...             nullify_all_custom_data_in_pcf
    [1]CB009059_A_1_One_PDU_ICS_Blind_SCell_Add_two_FR1_CA_eligible_DRB_one_no_FR1_CA_eligible_DRB_with_additional_QoS_Flow
    [Teardown]  Run keywords
    ...             Stop All Data Transfers                           AND
    ...             Detach Ue                  ${UE_ALIAS}            AND
    ...             Reset DRBs to default                             AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}        AND
    ...             Stop syslog capture                               AND
    ...             QRXLEVMIN_REVERT                                  AND
    ...             AdminUtils.collect_snapshot                       AND
    ...             nullify_all_custom_data_in_pcf                    AND
    ...             Add scout external execution id to the reporting portal


[1]CB009059_A_3_PDU_Session_Modification_with_new_DRB_when_UE_is_not_in_CA_due_to_incompatible_DRB
    [Tags]  CRT  24R2  A3
    [Setup]     Run keywords
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}    AND
    ...             Start syslog capture                                AND
    ...             Create init list of dts for tc                      AND
    ...             Wait for next counter interval                      AND
    ...             nullify_all_custom_data_in_pcf
    [1]CB009059_A_3_PDU_Session_Modification_with_new_DRB_when_UE_is_not_in_CA_due_to_incompatible_DRB
    [Teardown]  Run keywords
    ...             Stop All Data Transfers                           AND
    ...             Detach Ue                  ${UE_ALIAS}            AND
    ...             Reset DRBs to default                             AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}        AND
    ...             Stop syslog capture                               AND
    ...             QRXLEVMIN_REVERT                                  AND
    ...             AdminUtils.collect_snapshot                       AND
    ...             nullify_all_custom_data_in_pcf                    AND
    ...             Add scout external execution id to the reporting portal

[1]CB009059_A_8_PDU_Session_Modification_with_eligible_DRB_setup_and_CA_incompatible_DRB_release
    [Tags]  CRT  24R2  A8
    [Setup]     Run keywords
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}    AND
    ...             Start syslog capture                                AND
    ...             Create init list of dts for tc                      AND
    ...             Wait for next counter interval                      AND
    ...             nullify_all_custom_data_in_pcf
    [1]CB009059_A_8_PDU_Session_Modification_with_eligible_DRB_setup_and_CA_incompatible_DRB_release
    [Teardown]  Run keywords
    ...             Stop All Data Transfers                           AND
    ...             Detach Ue                  ${UE_ALIAS}            AND
    ...             Reset DRBs to default                             AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}        AND
    ...             Stop syslog capture                               AND
    ...             QRXLEVMIN_REVERT                                  AND
    ...             AdminUtils.collect_snapshot                       AND
    ...             nullify_all_custom_data_in_pcf                    AND
    ...             Add scout external execution id to the reporting portal

[1]CB009059_AB_3_PDU_Session_Modification_last_CA_eligible_DRB_release_CA_release
    [Tags]  CRT  24R2  AB3
    [Setup]     Run keywords
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}    AND
    ...             Start syslog capture                                AND
    ...             Create init list of dts for tc                      AND
    ...             Wait for next counter interval                      AND
    ...             nullify_all_custom_data_in_pcf
    [1]CB009059_AB_3_PDU_Session_Modification_last_CA_eligible_DRB_release_CA_release
    [Teardown]  Run keywords
    ...             Stop All Data Transfers                           AND
    ...             Detach Ue                  ${UE_ALIAS}            AND
    ...             Reset DRBs to default                             AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}        AND
    ...             Stop syslog capture                               AND
    ...             QRXLEVMIN_REVERT                                  AND
    ...             AdminUtils.collect_snapshot                       AND
    ...             nullify_all_custom_data_in_pcf                    AND
    ...             Add scout external execution id to the reporting portal

[1]CB009059_AC_4_Online_DRB_profile_setting_parameter_modification
    [Tags]  CRT  24R2  AC4
    [Setup]     Run keywords
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}    AND
    ...             Start syslog capture                                AND
    ...             Create init list of dts for tc                      AND
    ...             Wait for next counter interval                     AND
    ...             nullify_all_custom_data_in_pcf
    [1]CB009059_AC_4_Online_DRB_profile_setting_parameter_modification
    [Teardown]  Run keywords
    ...             Stop All Data Transfers                           AND
    ...             Detach Ue                  ${UE_ALIAS}            AND
    ...             Reset DRBs to default                             AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}        AND
    ...             Stop syslog capture                               AND
    ...             QRXLEVMIN_REVERT                                  AND
    ...             AdminUtils.collect_snapshot                       AND
    ...             nullify_all_custom_data_in_pcf                    AND
    ...             Add scout external execution id to the reporting portal

[1]CB009059_BA_9_DL_buffer_monitoring_for_SCell_Addition_only_FR1_CA_eligible_DRB_blind_SCell_Addition_method_buffer-based_activated
    [Tags]  CRT  24R2  BA9
    [Setup]     Run keywords
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}    AND
    ...             Create init list of dts for tc                      AND
    ...             Start syslog capture                                AND
    ...             Wait for next counter interval                      AND
    ...             nullify_all_custom_data_in_pcf
    [1]CB009059_BA_9_DL_buffer_monitoring_for_SCell_Addition_only_FR1_CA_eligible_DRB_blind_SCell_Addition_method_buffer-based_activated
    [Teardown]  Run keywords
    ...             Stop All Data Transfers                           AND
    ...             Detach Ue                  ${UE_ALIAS}            AND
    ...             Reset DRBs to default                             AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}        AND
    ...             Stop syslog capture                               AND
    ...             QRXLEVMIN_REVERT                                  AND
    ...             AdminUtils.collect_snapshot                       AND
    ...             nullify_all_custom_data_in_pcf                    AND
    ...             Add scout external execution id to the reporting portal

[1]CB009059_BE_2_Interworking_with_VoNR_Call_setup_after_ICS_one_DRB_FR1_CA_incompatible
    [Tags]  CRT  24R2  BE2
    [Setup]     Run keywords
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}    AND
    ...             Start syslog capture                                AND
    ...             Create init list of dts for tc                      AND
    ...             Wait for next counter interval                      AND
    ...             nullify_all_custom_data_in_pcf
    [1]CB009059_BE_2_Interworking_with_VoNR_Call_setup_after_ICS_one_DRB_FR1_CA_incompatible
    [Teardown]  Run keywords
    ...             Stop All Data Transfers                           AND
    ...             Detach Ue                  ${UE_ALIAS}            AND
    ...             Reset DRBs to default                             AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}        AND
    ...             Stop syslog capture                               AND
    ...             QRXLEVMIN_REVERT                                  AND
    ...             AdminUtils.collect_snapshot                       AND
    ...             nullify_all_custom_data_in_pcf                    AND
    ...             Add scout external execution id to the reporting portal

[1][1.0] CB009059_C_2_ICS_and_SCell_Addition_one_FR1_CA_eligible_DRB_no_FR1_CA_incompatible_DRB_UM_RLC_mode_DRB_FR1 _CA_eligible
    [Tags]  CRT  24R2  C2
    [Setup]     Run keywords
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}    AND
    ...             Start syslog capture                                AND
    ...             Create init list of dts for tc                      AND
    ...             Wait for next counter interval                      AND
    ...             nullify_all_custom_data_in_pcf
    CB009059_C_2_ICS_and_SCell_Addition_one_FR1_CA_eligible_DRB_no_FR1_CA_incompatible_DRB_UM_RLC_mode_DRB_FR1_CA_eligible
    [Teardown]  Run keywords
    ...             Stop All Data Transfers                           AND
    ...             Detach Ue                  ${UE_ALIAS}            AND
    ...             Reset DRBs to default                             AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}        AND
    ...             Stop syslog capture                               AND
    ...             QRXLEVMIN_REVERT                                  AND
    ...             AdminUtils.collect_snapshot                       AND
    ...             nullify_all_custom_data_in_pcf                    AND
    ...             Add scout external execution id to the reporting portal

CB009059_F_2_Interworking_with_PCMD_for_CA_eligible_DRB_release_PDU_Modification
    [Tags]  CRT 24R2 F2
    [Setup]     Run keywords
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}    AND
    ...             Start syslog capture                                AND
    ...             Create init list of dts for tc                      AND
    ...             Wait for next counter interval                      AND
    ...             nullify_all_custom_data_in_pcf
    CB009059_F_2_Interworking_with_PCMD_for_CA_eligible_DRB_release_PDU_Modification
    [Teardown]  Run keywords
    ...             Stop All Data Transfers                           AND
    ...             Detach Ue                  ${UE_ALIAS}            AND
    ...             Reset DRBs to default                             AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}        AND
    ...             Stop syslog capture                               AND
    ...             QRXLEVMIN_REVERT                                  AND
    ...             AdminUtils.collect_snapshot                       AND
    ...             nullify_all_custom_data_in_pcf                    AND
    ...             Add scout external execution id to the reporting portal

CB009059_BC_4_Interaction_with_RRC_Resume_procedure_CB008225_SCell_Addition_Method_blind_buffer_based_activated
    [Tags]  CRT 24R2 BC4
    [Setup]     Run keywords
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}    AND
    ...             Start syslog capture                                AND
    ...             Create init list of dts for tc                      AND
    ...             Wait for next counter interval                      AND
    ...             nullify_all_custom_data_in_pcf
    CB009059_BC_4_Interaction_with_RRC_Resume_procedure_CB008225_SCell_Addition_Method_blind_buffer_based_activated
    [Teardown]  Run keywords
    ...             Stop All Data Transfers                           AND
    ...             Detach Ue                  ${UE_ALIAS}            AND
    ...             Reset DRBs to default                             AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}        AND
    ...             Stop syslog capture                               AND
    ...             QRXLEVMIN_REVERT                                  AND
    ...             AdminUtils.collect_snapshot                       AND
    ...             nullify_all_custom_data_in_pcf                    AND
    ...             Add scout external execution id to the reporting portal


[1]CB008409_A_2_CSI_IM_randomization_in_FDD_cell_with_DRX_configured_ASOE_2DL_2UL
    [Tags]  CRT  24R2  A1
    [Setup]     Run keywords
    ...             Prepare Attenuator                                    AND
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}
    [1]CB008409_A_2_CSI_IM_randomization_in_FDD_cell_with_DRX_configured_ASOE_2DL_2UL
     [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS}                  AND
    ...             test_specific_keywords_8409.Stop Syslog Collection      AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}              AND
    ...             Stop syslog capture                                     AND
    ...             test_specific_keywords_8409.Dectivate Feature A2        AND
    ...             Add scout external execution id to the reporting portal


[1]CB133099_Comparison_with_CB008409_test
    [Tags]  CRT  26R1
    [Setup]     Run keywords
    ...             Prepare Attenuator                                    AND
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}
    [1]CB133099 Comparison With CB008409
     [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS}                  AND
    ...             test_specific_keywords_8409.Stop Syslog Collection      AND
    ...             deactivation_cni_CB0133099                              AND
    ...             Dectivate feature A2                                    AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}              AND
    ...             Stop syslog capture


[1]CB008409_A_2_CSI_IM_randomization_in_FDD_cell_with_DRX_configured_ASOE_2DL_2UL_pooling_off
    [Tags]  CRT  24R2  A1
    [Setup]     Run keywords
    ...             Prepare Attenuator                                    AND
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}
    [1]CB008409_A_2_CSI_IM_randomization_in_FDD_cell_with_DRX_configured_ASOE_2DL_2UL_pooling_off
     [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS}                      AND
    ...             test_specific_keywords_8409.Stop Syslog Collection          AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}                  AND
    ...             Stop syslog capture                                         AND
    ...             test_specific_keywords_8409.Dectivate Feature A2 pooling    AND
    ...             Add scout external execution id to the reporting portal


[1]CB008409_B_17_FDD_BW15_DL_power_boosting_of_retransmission_for_VoNR_data_with_PRB_Pooling
    [Tags]  CRT  25R1  CB008409-B
    [Setup]     Run keywords
    ...             Prepare Attenuator                                    AND
    ...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}
    keywords_8409.CB008409 B 17 FDD BW15 DL Power Boosting Of Retransmission For VoNR Data With PRB Pooling Test
    [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS}                  AND
    ...             test_specific_keywords_8409.Stop Syslog Collection      AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}              AND
    ...             Stop syslog capture                                     AND
    ...             Dectivate feature B                                     AND
    ...             Add scout external execution id to the reporting portal


[1][1.0] CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz
    [Documentation]   The purpose of this TC is
    CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz
    [Teardown]  Run keywords
    ...             Add scout external execution id to the reporting portal


[1]CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz_pooling_off
    [Documentation]   The purpose of this TC is
    CB012669_01_Feature_activation_and_deactivation_DL_resurce_allocation_for_1UE_FDD_cell_20MHz_pooling_off
    [Teardown]  Run keywords
    ...             Add scout external execution id to the reporting portal


[1]CNI-126050_5_Verification_of_different_interference_levels_low_medium_high_for_1_enabledWithPRACH_PUCCH_F1_SA
    [Documentation]   The purpose of this TC is to check IP CNI counters and bips
    [Setup]     Run keywords
    ...             Require Ue   ${UE_1_alias}   capabilities=${UE_1}     AND
    ...             Require Ue   ${UE_2_alias}   capabilities=${UE_2}
    [1]CNI-126050_Verification_of_different_interference_low_enabledWithPrach_pucch_SA
    [Teardown]    Run Keywords
    ...             Detach Ue   ${UE_1_alias}                               AND
    ...             Detach Ue   ${UE_2_alias}                               AND
    ...             Dectivate CNI126050                                     AND
    ...             Stop syslog capture                                     AND
    ...             Add scout external execution id to the reporting portal


[1]CB012439_01_Intra_GNB_handover_with_5QI1_5QI9
    [Documentation]   The purpose of this TC is to check counters for feature CB012439
    [Setup]     Run keywords
    ...             Prepare Attenuator                                    AND
    ...             Require Ue  ${UE_ALIAS_12439}  capabilities=${UE_CAPA_12439}
    [1]CB012439 Handover With 5QI9 5QI1 Test
    [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS_12439}                  AND
    ...             test_specific_keywords_8409.Stop Syslog Collection      AND
    ...             deactivating_handover_CB012439                          AND
    ...             AdminUtils.unlock_all_cells                             AND
    ...             Stop syslog capture                                     AND
    ...             Add scout external execution id to the reporting portal


[1.0] CB012439_C_B28_3_UPD004_Configuration_of_A1_meas_using_mobility_profile_reselected_upon_setup_of_VoNR_call_with_CA_enabled
    [Tags]  CRT  26R2  A1
    [Setup]     Run keywords
    ...             Prepare Attenuator                                    AND
    ...             Require Ue  ${UE_ALIAS_12439}  capabilities=${UE_CAPA_12439}
    [1]CB012439 VoNR CA checking counters
    [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS_12439}                  AND
    ...             test_specific_keywords_8409.Stop Syslog Collection      AND
    ...             deactivating_handover_CB012439                          AND
    ...             AdminUtils.unlock_all_cells                             AND
    ...             Stop syslog capture                                     AND
    ...             Add scout external execution id to the reporting portal


[1][1.0] CB013152-SR-A_Interworking_with_CB010850
    [Tags]  CRT  26R2  PRB BLANKING TMO AI_SUPPORTED
    [Setup]     Run keywords
    ...             Prepare Attenuator                                    AND
    ...             Require Ue  ${UE_ALIAS_13152}  capabilities=${UE_CAPA_13152}
    [1]CB013152 PRB Blanking
    [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS_13152}                  AND
    ...             Add scout external execution id to the reporting portal       AND
    ...             AdminUtils.unlock_all_cells                             AND
    ...             deactivating_for_prb_blanking_13152                     AND
    ...             Stop syslog capture                                     AND


[1]CB013152-SR-A_IWK3_Interworking_with_CB008954
    [Tags]  CRT  26R2  BWP TMO AI_SUPPORTED
    [Setup]     Run keywords
    ...             Prepare Attenuator                                    AND
    ...             Require Ue  ${UE_ALIAS_13152}  capabilities=${UE_CAPA_13152}
    [1]CB013152 BWP profile IWK
    [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS_13152}                  AND
    ...             Add scout external execution id to the reporting portal       AND
    ...             Rollback SCF afer test                                  AND
    ...             AdminUtils.unlock_all_cells                             AND
    ...             Stop syslog capture

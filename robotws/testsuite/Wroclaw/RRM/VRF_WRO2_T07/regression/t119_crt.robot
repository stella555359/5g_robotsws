*** Settings ***
Documentation    All CIT regression TCs shall be added here for fully automated regression testing.

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
...           CRT   PY36

Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py    WITH NAME    t119_btslog
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000723_5GC000728/resources/keywords_723.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/keywords_7564_AB.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008200/resources/keywords_8200.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC002333/resources/keywords_2333.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001178/resources/keywords_1178_BE.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001178/resources/keywords_1178_BB.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/keywords_9333.robot
Resource         taf/rfrl/common_resources/common_step/interface.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/require.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Suite Setup     Run Keywords
...             testline_preparation.prepare_testline     second_wind=${True}        AND
...             initialise_attenuator

Suite Teardown  Run keywords
...             Get active alarms                                               AND
...             Run keyword and ignore error   interface.Common step trigger

Test Setup      t119_btslog.start_btslog_on_local_machine

Test Teardown   Run Keywords
...             testline_preparation.what_is_wrong_with_pdu                     AND
...             testline_preparation.wake_up_samurai                            AND
...             TcpdumpSmod.teardown_tcpdump_on_smod                            AND
...             Run keyword if test failed    AdminUtils.collect_snapshot       AND
...             t119_btslog.stop_and_collect_btslog                             AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


*** Test Cases ***
CB009333_D_1_Micro-DTX_scheduler_with_DRX_configured
    [Documentation]   This Test Case describes expected Nokia gNB behaviour for UE with configured DRX is scheduled
     ...              during the DRX Active time
    CB009333_D_1_Micro-DTX_scheduler_with_DRX_configured


CB009333_F_1_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_SA
    [Documentation]   This Test Case describes expected Nokia gNB behaviour for RLC status PDU (for UL packets)
    ...               are scheduled on DL in the same manner as any delay-sensitive data in terms of
    ...               micro-DTX functionality. Scheduling of delay-sensitive data is not impacted.
    ...               Delay-sensitive data includes: SSBs, TRS, System Information including SIB1 (optional for NSA),
    ...               other SIBs (only for SA), paging – SA Case.
    CB009333_F_1_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_SA


[1]5GC001178_BE_3_Attach_UE_GoodCondition_WithoutTraffic_CSI-RS_CSI report_check_20MHz_bandwidth
    [Documentation]  The puropose of the test is to check if CSI-RS in SS slot are received by the UE and the
     ...             CSI reports for channel measurement are sent periodically by the UE on the PUCCH.
    [Tags]       SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    [1]5GC001178_BE_3_Attach_UE_GoodCondition_WithoutTraffic_CSI-RS_CSI report_check_20MHz_bandwidth


[1]5GC001178_BE_4_2UE_UL&DL_TimingCheck_UlDataPucchReceiveReq and UlDataPucchReceiveRespPs_CSI-RS_SSBslot_check_CSI-RS_CSI_report_20MHz_bandwidth
    [Documentation]  The purpose of this test case is to validate the timing of UlDataPucchReceiveRespPs
    ...              and UlDataPucchReceiveReq. They should be sent on the same SFN and slot.
    [Tags]       SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    [1]5GC001178_BE_4_2UE_UL&DL_TimingCheck_UlDataPucchReceiveReq and UlDataPucchReceiveRespPs_CSI-RS_SSBslot_check_CSI-RS_CSI_report_20MHz_bandwidth


CB007564-B_4_NG_FLOW_REL_GNB_RLF_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF
    [Documentation]   This test case verifies incrementation of counter provided to measure number of QoS Flow release
     ...              when Radio Link Failure (RLF) is detected by gNB. The gNB initiate the UE context release
     ...              procedure over F1 and NG interface and send UE to idle state
     ...              by initiating the RRC Release procedure.
    [Tags]       SBTS22R3__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    ...          SBTS22R4__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    ...          SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    [Setup]      Run Keywords
    ...          initialise_attenuator                            AND
    ...          nullify_attenuation_on_all_ports
    CB007564-B_4_NG_FLOW_REL_GNB_RLF_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF
    [Teardown]     Run keywords
    ...   Nullify attenuation on all ports                  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


CB007564-A_3_NG_FLOW_STP_ATT_INC_HO_and_NG_FLOW_STP_SUC_INC_HO_due_to_Intra-gNB_Intra_DU_HO
    [Documentation]   This test case verifies incrementation of counter provided to measure number of
     ...              QoS Flow setup due to to Intra-frequency (inter-cell) Intra-DU Intra-gNB handover.
    [Tags]       SBTS22R4__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    ...          SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    [Setup]      Run Keywords
    ...          initialise_attenuator                            AND
    ...          nullify_attenuation_on_all_ports
    CB007564-A_3_NG_FLOW_STP_ATT_INC_HO_and_NG_FLOW_STP_SUC_INC_HO_due_to_Intra-gNB_Intra_DU_HO
    [Teardown]    Run keywords
    ...    Nullify attenuation on all ports                  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


CB007564-B_5_NG_FLOW_REL_IANR_SUC_HO_incrementation_due_to_Intra-gNB_Intra_DU_HO
    [Documentation]   This test case verifies incrementation of counter provided to measure number of QoS Flow release
     ...              during Intra-frequency (inter-cell) Intra-DU Intra-gNB handover.
    [Tags]       SBTS22R3__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    ...          SBTS22R4__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    ...          SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    [Setup]      Run Keywords
    ...          initialise_attenuator                            AND
    ...          nullify_attenuation_on_all_ports
    CB007564-B_5_NG_FLOW_REL_IANR_SUC_HO_incrementation_due_to_Intra-gNB_Intra_DU_HO
    [Teardown]    Run keywords
    ...    Nullify attenuation on all ports                  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


CB007564-B_1_NG_FLOW_REL_GNB_REDIRECT_incrementation_due_to_redirection_of_Voice_call_to_LTE
    [Documentation]   This test case verifies incrementation of counter provided to measure number of QoS Flow released
     ...              when A2 measurements for redirection have been configured. UE sends a A2 measurement report
     ...              and gNB performs RRC Connection Release with redirection information procedure based
     ...              on the configured target carrier priority at gNB to the LTE cell.
    [Tags]       SBTS22R3__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    ...          SBTS22R4__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    ...          SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    [Setup]        Require Keyword   REQ_SETUP_NG_FLOW_REL_GNB_REDIRECT
    CB007564-B_1_NG_FLOW_REL_GNB_REDIRECT_incrementation_due_to_redirection_of_Voice_call_to_LTE
    [Teardown]     Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008200-D_1_NG_FLOW_REL_GNB_REDIRECT_5QI1_incrementation_due_to_redirection_of_Voice_call_to_LTE
    [Documentation]   Check counter M55125C09502 provided to measure number of 5QI1
    ...               release when A2 measurements for redirection have been configured.
    ...               UE sends a A2 measurement report and gNB performs RRC Connection Release
    ...               with redirection information procedure based on the configured target carrier priority
    ...               at gNB to the LTE cell.
    [Tags]
    [Setup]        Require Keyword   REQ_SETUP_NG_FLOW_REL_GNB_REDIRECT
    CB008200-D_1_NG_FLOW_REL_GNB_REDIRECT_5QI1_incrementation_due_to_redirection_of_Voice_call_to_LTE
    [Teardown]     Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008200-F_7_NG_FLOW_REL_GNB_REDIRECT_PMQAP_incrementation_due_to_redirection_of_Voice_call_to_LTE
    [Documentation]   Check counter M55163C00503 provided to measure number of 5QI1
    ...               released for a UE for which A2 measurements for redirection have been configured.
    ...               UE sends a A2 measurement report and gNB performs RRC Connection Release
    ...               with redirection information procedure based on the configured target carrier priority
    ...               at gNB to the LTE cell.
    ...               The Profile counter shall count the only for the configured Profile parameters.
    [Tags]
    [Setup]        Require Keyword   REQ_SETUP_NG_FLOW_REL_GNB_REDIRECT
    CB008200-F_7_NG_FLOW_REL_GNB_REDIRECT_PMQAP_incrementation_due_to_redirection_of_Voice_call_to_LTE
    [Teardown]     Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB007564-A_1_NG_FLOW_SETUP_FAIL_FALLBACK_incrementation_due_to_voice_fallback_to_LTE
	[Documentation]   This test case verifies incrementation of counter provided to measure number of
	 ...              all QoS Flow setup failed due to fallback to LTE when VoNR feature
    [Tags]       SBTS22R3__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    ...          SBTS22R4__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    ...          SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB
    [Setup]        Require Keyword   REQ_SETUP_NG_FLOW_SETUP_FAIL_FALLBACK
    CB007564-A_1_NG_FLOW_SETUP_FAIL_FALLBACK_incrementation_due_to_voice_fallback_to_LTE
    [Teardown]     Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008200-B_1_NG_FLOW_STP_FAIL_FALLBACK_5QI1_incrementation_due_to_voice_fallback_to_LTE
    [Documentation]   Check counter M55125C09519 provided to measure number of 5QI1
     ...              setup failed due to fallback to LTE when VoNR feature is disabled.
    [Tags]
    [Setup]        Require Keyword   REQ_SETUP_NG_FLOW_SETUP_FAIL_FALLBACK
    CB008200-B_1_NG_FLOW_STP_FAIL_FALLBACK_5QI1_incrementation_due_to_voice_fallback_to_LTE
    [Teardown]     Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008200-F_2_NG_FLOW_STP_FAIL_FALLBACK_PMQAP_incrementation_due_to_voice_fallback_to_LTE
    [Documentation]   Check counter M55163C00501 provided to measure number of 5QI1
    ...               setup failed and when VoNR feature is disabled and fallback to LTE is possible.
    ...               The Profile counter shall count the only for the configured Profile parameters.
    [Tags]
    [Setup]        Require Keyword   REQ_SETUP_NG_FLOW_SETUP_FAIL_FALLBACK
    CB008200-F_2_NG_FLOW_STP_FAIL_FALLBACK_PMQAP_incrementation_due_to_voice_fallback_to_LTE
    [Teardown]     Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


*** Keywords ***
REQ_SETUP_NG_FLOW_REL_GNB_REDIRECT
    [Documentation]   Setup for CB007564-B1/CB008200-D1
    Run Keywords
    ...   initialise_attenuator   AND
    ...   nullify_attenuation_on_all_ports
    SETUP_NG_FLOW_REL_GNB_REDIRECT
    [Teardown]     Nullify attenuation on all ports


REQ_SETUP_NG_FLOW_SETUP_FAIL_FALLBACK
    [Documentation]   Setup for CB007564-A1/CB008200-B1/CB008200-F2
    Run Keywords
    ...   initialise_attenuator   AND
    ...   nullify_attenuation_on_all_ports
    SETUP_NG_FLOW_SETUP_FAIL_FALLBACK
    [Teardown]     Nullify attenuation on all ports

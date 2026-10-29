*** Settings ***
Documentation
...   author: Adrian Jakobik
...   contact: adrian.jakobik@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB007564_AB
...
...      == HISTORY ==
...         [16.05.2022] - Aligned CB007564-B_4 test with the changes introduced in 5G_L3_FLOW_59779 for PR644597


Library      taf.ue
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/test_specific_keywords_7564.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/test_specific_keywords_7564.py


*** Keywords ***
SETUP_NG_FLOW_SETUP_FAIL_FALLBACK
    [Documentation]   Setup for CB007564-A1/CB008200-B1

	Setup and check preconditions in scf   params_to_check=${a1_params}

    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

    test_specific_keywords_7564.Call With Logs    pcap_filename=FALLBACK

    GnbCounter.Wait for next pm period   interval=${pm_interval}


CB007564-A_1_NG_FLOW_SETUP_FAIL_FALLBACK_incrementation_due_to_voice_fallback_to_LTE
	[Documentation]   This test case verifies incrementation of counter provided to measure number of
	 ...              all QoS Flow setup failed due to fallback to LTE when VoNR feature

	test_specific_keywords_7564.Check 5QI Setup   pcap_file=${LOG_PATH}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap
	Check IMS Voice EPS Fallback   pcap_file=${LOG_PATH}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap
	Check UE Context Release Command Redirection   pcap_file=${LOG_PATH}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap
	Check UE Context Release Command Complete   pcap_file=${LOG_PATH}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap

	${counter_ids}=     Create List    M55125C09008
	Verify PM Counters   pm_counters_list=${counter_ids}


CB007564-A_3_NG_FLOW_STP_ATT_INC_HO_and_NG_FLOW_STP_SUC_INC_HO_due_to_Intra-gNB_Intra_DU_HO
    [Documentation]   This test case verifies incrementation of counter provided to measure number of
     ...              QoS Flow setup due to to Intra-frequency (inter-cell) Intra-DU Intra-gNB handover.

    scf_verifier.Setup and check preconditions in scf   params_to_check=${a3_params}

    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

    Handover With Logs   sleep_after_attach=30   source_cell_attenator_ports=${cell_1_attenuator_ports}
    ...                  destination_cell_attenuator_ports=${cell_2_attenuator_ports}

    GnbCounter.Wait for next pm period   interval=${pm_interval}
    ${counter_ids}=     Create List    M55125C09013   M55125C09014
    Verify PM Counters   pm_counters_list=${counter_ids}

SETUP_NG_FLOW_REL_GNB_REDIRECT
    [Documentation]   Setup for CB007564-B1/CB008200-D1

	Setup and check preconditions in scf   params_to_check=${b1_params}

    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

	Handover With Logs   sleep_after_attach=30   lte_ho=True    pcap_filename=REDIRECT

	GnbCounter.Wait for next pm period   interval=${pm_interval}


CB007564-B_1_NG_FLOW_REL_GNB_REDIRECT_incrementation_due_to_redirection_of_Voice_call_to_LTE
    [Documentation]   This test case verifies incrementation of counter provided to measure number of QoS Flow released
     ...              when A2 measurements for redirection have been configured. UE sends a A2 measurement report
     ...              and gNB performs RRC Connection Release with redirection information procedure based
     ...              on the configured target carrier priority at gNB to the LTE cell.

    test_specific_keywords_7564.Check 5QI Setup   pcap_file=${LOG_PATH}/CB007564_CB008200_REDIRECT_tcpdump_SMOD_MASTER.pcap
	Check UE Context Release Command Redirection   pcap_file=${LOG_PATH}/CB007564_CB008200_REDIRECT_tcpdump_SMOD_MASTER.pcap

	${counter_ids}=     Create List    M55125C09002   M55125C09502   M55163C00503
	Verify PM Counters   pm_counters_list=${counter_ids}


CB007564-B_3_NG_FLOW_REL_GNB_UE_INACTIVITY_incrementation_with_UE_Context_released_due_to_DRB_inactivity
    [Documentation]   This test case verifies incrementation of counter provided to measure number QoS Flow release
     ...              when gNB initiated Ue Context Release due to DRB inactivity.

    scf_verifier.Setup and check preconditions in scf   params_to_check=${b3_params}

    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

    UE Inactivity With Logs

    Check User Inactivity In Ue Context   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap

    GnbCounter.Wait for next pm period   interval=${pm_interval}
    ${counter_ids}=     Create List    M55125C09004
    test_specific_keywords_7564.Verify PM Counters   pm_counters_list=${counter_ids}

    [Teardown]       Detach UE    UE_1


CB007564-B_4_NG_FLOW_REL_GNB_RLF_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF
    [Documentation]   This test case verifies incrementation of counter provided to measure number of QoS Flow release
     ...              when Radio Link Failure (RLF) is detected by gNB. The gNB initiate the UE context release
     ...              procedure over F1 and NG interface and send UE to idle state
     ...              by initiating the RRC Release procedure.

    scf_verifier.Setup and check preconditions in scf   params_to_check=${b4_params}

    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

    RLF With Logs   sleep_after_attach=30

    Check UE Context Modification With RL Failure   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check UE Context Release Request With Radio Connection With UE Lost Cause
    ...    pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check UE Context Release Command Complete   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap

    GnbCounter.Wait for next pm period   interval=${pm_interval}
    ${counter_ids}=     Create List    M55125C09005
    Verify PM Counters   pm_counters_list=${counter_ids}

    [Teardown]       Run Keywords
     ...              Detach UE    UE_1                                AND
     ...              Detach UE    UE_2


CB007564-B_5_NG_FLOW_REL_IANR_SUC_HO_incrementation_due_to_Intra-gNB_Intra_DU_HO
    [Documentation]   This test case verifies incrementation of counter provided to measure number of QoS Flow release
     ...              during Intra-frequency (inter-cell) Intra-DU Intra-gNB handover.

    scf_verifier.Setup and check preconditions in scf   params_to_check=${b5_params}

    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

    Handover With Logs   sleep_after_attach=30   source_cell_attenator_ports=${cell_1_attenuator_ports}
    ...                  destination_cell_attenuator_ports=${cell_2_attenuator_ports}

    GnbCounter.Wait for next pm period   interval=${pm_interval}
    ${counter_ids}=     Create List    M55125C09015
    Verify PM Counters   pm_counters_list=${counter_ids}


CB007564-B_7_NG_FLOW_REL_IRAT_SUC_HO_incrementation_due_to_Inter-RAT_HO_from_5G
    [Documentation]   This test case verifies incrementation of counter provided to measure number of
     ...              QoS Flow released during Inter-RAT handover from 5G.
	Setup and check preconditions in scf   params_to_check=${b7_params}

    Handover With Logs   sleep_after_attach=30   lte_ho=True

	GnbCounter.Wait for next pm period   interval=${pm_interval}
	${counter_ids}=     Create List    M55125C09016
	Verify PM Counters   pm_counters_list=${counter_ids}

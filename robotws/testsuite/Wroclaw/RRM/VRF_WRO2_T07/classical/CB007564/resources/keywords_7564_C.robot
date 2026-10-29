*** Settings ***
Documentation
...   author: Adrian Jakobik
...   contact: adrian.jakobik@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB007564_C


Library      taf.ue
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils     WITH NAME    AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/test_specific_keywords_7564.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot


Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/test_specific_keywords_7564.py

*** Keywords ***
Attach And Check HARQ OK
    Attach With Logs    sleep_after_attach=15
    ${rntis}=    Get Attached RNTIs    sctp_logs=${LOG_PATH}/${test_name}_tcpdump_SMOD_ALL.pcap
    Find Harqu With Crc Ok    pcap_file=${LOG_PATH}/${test_name}_L1L2.pcap    rntis=${rntis}


Attach And Check Prach Preamble Index
    Attach With Logs    sleep_after_attach=15
    Check Event Rach Config In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_ALL.pcap
    Check Prach Preamble Index   pcap_file=${LOG_PATH}/${test_name}_L1L2.pcap   preamble_index=56
    ${rntis}=    Get Attached RNTIs    sctp_logs=${LOG_PATH}/${test_name}_tcpdump_SMOD_ALL.pcap
    Find Harqu With Crc Ok    pcap_file=${LOG_PATH}/${test_name}_L1L2.pcap    rntis=${rntis}


CB007564-C_5_RA_CB_INIT_RESOLVED_incrementation_due_to_successful_initial_RA_setup_with_CRC_OK_and_contention_resolved
    [Documentation]   This test case verifies incrementation of counter provided to measure number of time when
     ...              RA setup is successful and the contention is resolved by UL grant addressed to its CRNTI.
     ...              Contention is considered resolved when an UL transmission with CRC OK is received.

    scf_verifier.Setup And Check Preconditions In SCF   params_to_check=${c_default_scf_params}
    Setup And Check Preconditions In LTE SCF   params_to_check=${lte_scf_params_off}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${cell_id}
    Require Ue   UE_1   capabilities=${c_capabilities}
    Wait Until Keyword Succeeds  3x  30 seconds  Attach And Check HARQ OK
    GnbCounter.Wait for next pm period   interval=${pm_interval}
    ${counter_ids}=     Create List    M55306C09006
    Verify PM Counters   pm_counters_list=${counter_ids}


CB007564-C_6_RA_MSG3_RECEP_INIT_incrementation_due_to_successful_initial_RA_setup
    [Documentation]   This test case verifies incrementation of counter provided to measure number of time when
     ...              RA setup is successful and msg3 is received successfully from UE.

    scf_verifier.Setup And Check Preconditions In SCF   params_to_check=${c_default_scf_params}
    Setup And Check Preconditions In LTE SCF   params_to_check=${lte_scf_params_off}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${cell_id}
    Require Ue   UE_1   capabilities=${c_capabilities}
    Wait Until Keyword Succeeds  3x  30 seconds  Attach And Check HARQ OK
    GnbCounter.Wait for next pm period   interval=${pm_interval}
    ${counter_ids}=     Create List    M55306C09008
    Verify PM Counters   pm_counters_list=${counter_ids}


CB007564-C_8_Incrementation_of_counters_due_to_initial_access_based_on_contention_free_procedure
    [Documentation]   This test case verifies incrementation of counter provided to measure number of times when
     ...              dedicated preamble is sent to the UE from gNB for initial access: DED_PREAMBL_SENT_CFRA_INIT,
     ...              number of time when dedicated preamble assigned to UE by the gNB is used by UE during Msg1:
     ...              INIT_RA_ATT_CFRA_and_DED_PREAMBL_USED_CFRA_INIT_and_INIT_MSG1_ACK_CFRA and number of time when
     ...              CFRA setup is successful and the UE responds in first UL transmission
     ...              that CRC is OK: INIT_MSG2_ACK_CFRA.

    Setup And Check Preconditions In LTE SCF   params_to_check=${c8_lte_scf_params_on}
    scf_verifier.Setup And Check Preconditions In SCF   params_to_check=${c_default_scf_params}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${cell_id}
    Require Ue   UE_1   capabilities=${c_capabilities}
    Wait Until Keyword Succeeds  3x  30 seconds  Attach And Check Prach Preamble Index
    GnbCounter.Wait for next pm period   interval=${pm_interval}
    ${counter_ids}=     Create List    M55125C09021    M55306C09002    M55306C09000    M55306C09003
    Verify PM Counters   pm_counters_list=${counter_ids}

    [Teardown]   Setup And Check Preconditions In LTE SCF   params_to_check=${lte_scf_params_off}

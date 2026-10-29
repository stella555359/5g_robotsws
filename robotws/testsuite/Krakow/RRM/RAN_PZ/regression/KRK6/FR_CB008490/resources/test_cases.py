"""
CB008490 Test Cases

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""
import time
from ute_ue import ute_ue

from .pcap.collecting import gather_pcap_from
from .pcap.verifier import (
    verify_csi_rs_downgrade_from_rs3_to_rs1,
    verify_fr2_cells_were_not_added_for_not_supported_plmn_at_sn,
    verify_handling_of_the_ue_capability_pdcch_blind_detection_ie_in_the_scg,
    verify_nrdc_call_setup,
    verify_nrdc_with_8cc_fr2_call_setup, verify_that_power_saving_bwp_was_configured_in_rrc,
    verify_pucch_multiplexing_in_scg_single_csi_process_single_csi_report_group,
    verify_pucch_multiplexing_in_scg_single_csi_process_two_csi_report_groups,
    verify_radiolinkmonitoringconfig_for_2_ies_in_scg,
    verify_radiolinkmonitoringconfig_for_3_ies_in_scg,
    verify_radiolinkmonitoringconfig_for_failuredetectionresourcestoaddmodlist_in_scg,
    verify_small_and_large_bwp_was_configured_in_rrc,
    verify_that_band_combination_with_pcell_alternative_band_was_selected_for_nrdc,
    verify_that_drx_was_setup_in_second_rrc_reconfiguration_after_ics,
    verify_that_fr1_ca_was_kept_and_nrdc_was_not_setup_after_a4_report,
    verify_that_radiolinkmonitoringconfig_ie_is_not_present_in_scg,
    verify_that_ue_doesnt_support_native_band_and_do_support_alternative_band_based_on_ue_capabilities,
    verify_totalnumberportssimultaneousnzp_csi_rs_percc_ge_4,
    verify_ue_activity_resumption,
)
from .pm_counters import (
    verify_at_least_one_snode_initiated_sn_modifications_was_successful_by_checking_pm_counters,
    verify_nrdc_user_capacity_counters_for_release_procedure_have_been_incremented_in_mn_and_sn_gnb,
    verify_that_8cc_ca_on_fr2_cells_were_activated_and_deactivated_by_checking_pm_counters,
    verify_that_all_nrdc_user_capacity_counters_for_release_procedure_are_equal_to_0_in_mn_gnb_and_sn_gnb,
    verify_that_gnb_sa_admission_mfbi_succ_and_gnb_sa_du_admission_mfbi_succ_pm_counters_were_incremented,
    verify_that_m55116c00054_nrdc_mn_snode_uecap_fail_was_incremented,
    wait_for_next_pm_counters_interval,
)
from .software import Software
from .suite_specific import (
    adjust_fr2_cell_power_and_a4_nrdc_threshold_that_a4_measurement_report_wont_be_reported,
    adjust_fr2_cell_power_that_nrdc_a4_will_reported,
    configure_4_sn_cells_with_ue_plmn,
    configure_actcdrx_for_aeqp_cell,
    configure_actrrcreconfigatbeamswitch_on_sn_gnb_cells,
    configure_as_encryption_on_mn_and_sn_gnbs,
    configure_csirsnumberwithinreportperiod_set1_on_aeqp_cell,
    configure_disableuebeamfailurerecovery_on_sn_gnb_cells,
    configure_srb_and_drb_inactivity_timers_on_mn_and_sn,
    eb_200_test_cleanup,
    enable_data_split_to_mn_if_needed,
    enable_zero_pm_counters_suppression,
    generate_and_verify_scout_nrdc_report,
    nrdc_kpi_scenario_with_pm_intervals,
    rollback_dd_200_configuration,
    trigger_and_verify_ng_partial_reset_by_fr2_cell_lock,
    trigger_rlf_and_verify_nrdc_release_and_reestablishment,
    trigger_and_verify_sn_terminated_offloaded_pdu_session_release, verify_ru_cell_is_configured_with_bands,
)
from .commissioning import perform_bts_delta_commissioning
from .ue import (
    attach_ue_with_cell_verification,
    attach_ue_with_nrdc_establishment_verification,
    attach_ue_with_pcap_gathering,
    detach_nrdc_ue,
    detach_ue_with_nrdc_release_verification,
    multiple_loops_of_nrdc_call_with_dl_peak_tput_verification,
    perform_short_voice_call_using_mn_terminated_pdu_session,
    start_and_verify_tcp_dl_and_ul_data_transfer,
    start_dl_tcp_data_transfer_for_ue,
    stop_dl_tcp_data_transfer_for_ue,
    ue_activity_resumption,
    verify_that_dl_tcp_data_transfer_is_still_ongoing,
)
from .variables.common import MY_UE_ALIAS_UE1_AT, MY_UE_ALIAS_UE2
from .variables.delta import LD_201_ROLLBACK, LD_201_PRECONDITIONS


class TestCases:

    @staticmethod
    def cb008490_c_101_b1_ue_release_due_to_amf_initiated_context_release():
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3657375/
        """
        ute_ue().require_ue(ue_alias=MY_UE_ALIAS_UE1_AT, capabilities="AT_UE")
        attach_ue_with_nrdc_establishment_verification()
        detach_ue_with_nrdc_release_verification(ue_alias=MY_UE_ALIAS_UE1_AT)

    @staticmethod
    def cb008490_k_101_b1_successful_fr2_8cc():
        """Test Cases:
        - https://rep-portal.ext.net.nokia.com/details/qc-case/3658741/ (-K)
        - https://rep-portal.ext.net.nokia.com/details/qc-case/3656972/ (-KC)
        - https://rep-portal.ext.net.nokia.com/details/qc-case/3658696/ (-KC)
        - https://rep-portal.ext.net.nokia.com/details/qc-case/4015345/ (-LC)
        """
        wait_for_next_pm_counters_interval()
        attach_ue_with_nrdc_establishment_verification()
        verify_nrdc_with_8cc_fr2_call_setup()
        start_and_verify_tcp_dl_and_ul_data_transfer()
        detach_nrdc_ue()
        wait_for_next_pm_counters_interval()
        verify_that_8cc_ca_on_fr2_cells_were_activated_and_deactivated_by_checking_pm_counters()
        verify_at_least_one_snode_initiated_sn_modifications_was_successful_by_checking_pm_counters()

    @staticmethod
    def cb008490_e_101_b1_rrcreestablishment_to_same_gnb():
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3656496/"""
        attach_ue_with_nrdc_establishment_verification()
        trigger_rlf_and_verify_nrdc_release_and_reestablishment()
        start_and_verify_tcp_dl_and_ul_data_transfer()
        detach_nrdc_ue()

    @staticmethod
    def cb008490_eb_202_b2a3_ng_partial_reset_nr_dc_sn_cells_locked():
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3785811/"""

        attach_ue_with_nrdc_establishment_verification()
        verify_nrdc_with_8cc_fr2_call_setup()
        try:
            start_dl_tcp_data_transfer_for_ue()
            trigger_and_verify_ng_partial_reset_by_fr2_cell_lock()
            verify_that_dl_tcp_data_transfer_is_still_ongoing()
            stop_dl_tcp_data_transfer_for_ue()
            detach_nrdc_ue()
        finally:
            eb_200_test_cleanup()

    @staticmethod
    def cb008490_ec_100_b1_nrdc_user_capacity_counters_for_release_procedure():
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3779324/"""
        wait_for_next_pm_counters_interval()
        attach_ue_with_nrdc_establishment_verification()
        verify_nrdc_with_8cc_fr2_call_setup()
        detach_nrdc_ue()
        wait_for_next_pm_counters_interval()
        verify_nrdc_user_capacity_counters_for_release_procedure_have_been_incremented_in_mn_and_sn_gnb()
        wait_for_next_pm_counters_interval()
        verify_that_all_nrdc_user_capacity_counters_for_release_procedure_are_equal_to_0_in_mn_gnb_and_sn_gnb()

    @staticmethod
    def cb008490_ea_101_b1_offloaded_pdu_session_release():
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3657021/"""
        attach_ue_with_nrdc_establishment_verification()
        perform_short_voice_call_using_mn_terminated_pdu_session()
        trigger_and_verify_sn_terminated_offloaded_pdu_session_release()
        perform_short_voice_call_using_mn_terminated_pdu_session()
        detach_nrdc_ue()

    @staticmethod
    def cb008490_qbw_101_b1_attach_3bwps_tdd():
        """Test Cases:
        - https://rep-portal.ext.net.nokia.com/details/qc-case/3853252/ (-QBW)
        - https://rep-portal.ext.net.nokia.com/details/qc-case/3680020/ (-LA)
        """
        attach_ue_with_nrdc_establishment_verification()
        verify_small_and_large_bwp_was_configured_in_rrc()
        verify_handling_of_the_ue_capability_pdcch_blind_detection_ie_in_the_scg()
        detach_nrdc_ue()

    @staticmethod
    def cb008490_qbw_501_b5_pws_bwp():
        """Test Cases:
        - https://rep-portal.ext.net.nokia.com/details/qc-case/3853322/ (CB08490-QBW)
        - https://rep-portal.ext.net.nokia.com/details/qc-case/3901769/ (CB013233-A)
        """
        attach_ue_with_nrdc_establishment_verification()
        verify_that_power_saving_bwp_was_configured_in_rrc()
        verify_that_drx_was_setup_in_second_rrc_reconfiguration_after_ics()
        detach_nrdc_ue()

    @staticmethod
    def cb008490_dd_200_b3_ue_activity_resumption():
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3756554/"""
        try:
            configure_srb_and_drb_inactivity_timers_on_mn_and_sn()
            adjust_fr2_cell_power_and_a4_nrdc_threshold_that_a4_measurement_report_wont_be_reported()
            attach_ue_with_cell_verification()
            (gather_pcap_from(file_name_part="NRDC_Setup", wait_time=10)
             (adjust_fr2_cell_power_that_nrdc_a4_will_reported)())
            verify_nrdc_call_setup()
            gather_pcap_from("Inactivity")(ue_activity_resumption)()
            verify_ue_activity_resumption()
            detach_nrdc_ue()
        finally:
            rollback_dd_200_configuration()

    @staticmethod
    def cb008490_la_101_b1a1_csi_rs_capability_check_passed_in_mn(ue_alias=MY_UE_ALIAS_UE2):
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3748231/
        :param ue_alias: UE alias to be used in the test case
        """
        attach_ue_with_nrdc_establishment_verification(ue_alias=ue_alias)
        verify_totalnumberportssimultaneousnzp_csi_rs_percc_ge_4()
        start_and_verify_tcp_dl_and_ul_data_transfer(
            ue_alias=ue_alias,
            apn="5gsakrk2",
            expected_dl_tput="2000 Mbits/sec",
            dl_streams="2",
            expected_ul_tput="100 Mbits/sec",
        )
        detach_nrdc_ue(ue_alias=ue_alias)

    @staticmethod
    def cb008490_la_601_b6_mn_sn_coordination_mtk_m80(ue_alias=MY_UE_ALIAS_UE2):
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3754580/
        :param ue_alias: UE alias to be used in the test case
        """
        try:
            configure_actcdrx_for_aeqp_cell(value="false")
            attach_ue_with_nrdc_establishment_verification(ue_alias=ue_alias)
            detach_nrdc_ue(ue_alias=ue_alias)
            verify_csi_rs_downgrade_from_rs3_to_rs1()
        finally:
            configure_actcdrx_for_aeqp_cell(value="true")

    @staticmethod
    def cb008490_la_701_b7a1_csi_rs_capability_check_fail_in_mn_fr1_ca(ue_alias=MY_UE_ALIAS_UE2):
        """Test Cases:
        - https://rep-portal.ext.net.nokia.com/details/qc-case/3754198/ (LA-B301)
        - https://rep-portal.ext.net.nokia.com/details/qc-case/3754541/ (LA-B701)
        :param ue_alias: UE alias to be used in the test case
        """
        try:
            configure_csirsnumberwithinreportperiod_set1_on_aeqp_cell(value="1")
            wait_for_next_pm_counters_interval()
            attach_ue_with_pcap_gathering(ue_alias=ue_alias, file_name_part="LA_701_NRDC_fail")
            detach_nrdc_ue(ue_alias=ue_alias)
            verify_that_fr1_ca_was_kept_and_nrdc_was_not_setup_after_a4_report()
            wait_for_next_pm_counters_interval()
            verify_that_m55116c00054_nrdc_mn_snode_uecap_fail_was_incremented()
        finally:
            configure_csirsnumberwithinreportperiod_set1_on_aeqp_cell(value="4")

    @staticmethod
    def cb008490_ld_101_real_ue_pucchf2maxcoderate_zerodot25_nrofreportedrs_2():
        """Test Cases:
        - https://rep-portal.ext.net.nokia.com/details/qc-case/3705666/ (-LD)
        - https://rep-portal.ext.net.nokia.com/details/qc-case/4022498/ (-QR)
        """
        verify_ru_cell_is_configured_with_bands(
            ru_name="AEQP", native_band='78', alternative_band='77'
        )
        wait_for_next_pm_counters_interval()
        attach_ue_with_nrdc_establishment_verification()
        verify_that_ue_doesnt_support_native_band_and_do_support_alternative_band_based_on_ue_capabilities()
        verify_that_band_combination_with_pcell_alternative_band_was_selected_for_nrdc()
        verify_pucch_multiplexing_in_scg_single_csi_process_two_csi_report_groups()
        start_and_verify_tcp_dl_and_ul_data_transfer()
        detach_nrdc_ue()
        wait_for_next_pm_counters_interval()
        verify_that_gnb_sa_admission_mfbi_succ_and_gnb_sa_du_admission_mfbi_succ_pm_counters_were_incremented()

    @staticmethod
    def cb008490_ld_201_real_ue_pucchf2maxcoderate_zerodot35_nrofreportedrs_1():
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3786701/"""
        try:
            perform_bts_delta_commissioning(
                delta=LD_201_PRECONDITIONS, bts_id=1, wait_onair=True
            )
            attach_ue_with_nrdc_establishment_verification()
            verify_pucch_multiplexing_in_scg_single_csi_process_single_csi_report_group()
            start_and_verify_tcp_dl_and_ul_data_transfer(expected_ul_tput="150 Mbits/sec")
            detach_nrdc_ue()
        finally:
            perform_bts_delta_commissioning(
                delta=LD_201_ROLLBACK, bts_id=1, wait_onair=True
            )

    @staticmethod
    def cni_125505_101_faf_check_with_nrdc_call_actrrcreconfigatbeamswitch_false():
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3863198/"""
        try:
            attach_ue_with_nrdc_establishment_verification(file_name_part="FAF_not_configured")
            verify_radiolinkmonitoringconfig_for_2_ies_in_scg()
            start_and_verify_tcp_dl_and_ul_data_transfer()
            detach_nrdc_ue()
            configure_disableuebeamfailurerecovery_on_sn_gnb_cells(action='false')
            attach_ue_with_nrdc_establishment_verification(file_name_part="FAF_false")
            verify_radiolinkmonitoringconfig_for_2_ies_in_scg()
            detach_nrdc_ue()
            configure_disableuebeamfailurerecovery_on_sn_gnb_cells(action='true')
            attach_ue_with_nrdc_establishment_verification(file_name_part="FAF_true")
            verify_that_radiolinkmonitoringconfig_ie_is_not_present_in_scg()
            start_and_verify_tcp_dl_and_ul_data_transfer()
            detach_nrdc_ue()
        finally:
            configure_disableuebeamfailurerecovery_on_sn_gnb_cells(action="delete")

    @staticmethod
    def cni_125505_102_faf_check_with_nrdc_call_actrrcreconfigatbeamswitch_true():
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3863199/"""
        try:
            configure_actrrcreconfigatbeamswitch_on_sn_gnb_cells(value='true')
            attach_ue_with_nrdc_establishment_verification(file_name_part="FAF_not_configured")
            verify_radiolinkmonitoringconfig_for_3_ies_in_scg()
            start_and_verify_tcp_dl_and_ul_data_transfer()
            detach_nrdc_ue()
            configure_disableuebeamfailurerecovery_on_sn_gnb_cells(action='true')
            attach_ue_with_nrdc_establishment_verification(file_name_part="FAF_true")
            verify_radiolinkmonitoringconfig_for_failuredetectionresourcestoaddmodlist_in_scg()
            start_and_verify_tcp_dl_and_ul_data_transfer()
            detach_nrdc_ue()
        finally:
            configure_disableuebeamfailurerecovery_on_sn_gnb_cells(action="delete")
            configure_actrrcreconfigatbeamswitch_on_sn_gnb_cells(value="false")

    @staticmethod
    def cb008490_ka_101_b1_fr2_cells_not_added_not_supported_plmn_at_sn():
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/3793874/"""
        try:
            configure_4_sn_cells_with_ue_plmn(supported=False)
            attach_ue_with_nrdc_establishment_verification(file_name_part="KA_not_supported_PLMN")
            verify_fr2_cells_were_not_added_for_not_supported_plmn_at_sn()
            detach_nrdc_ue()
        finally:
            configure_4_sn_cells_with_ue_plmn(supported=True)

    @staticmethod
    def cb008490_w_b1_101_nrdc_single_ue_dl_peak_tput_mn_tdd():
        """Test Cases: https://rep-portal.ext.net.nokia.com/details/qc-case/4106810/"""
        configure_as_encryption_on_mn_and_sn_gnbs(True)
        enable_data_split_to_mn_if_needed()
        multiple_loops_of_nrdc_call_with_dl_peak_tput_verification()

    @staticmethod
    def cb008490_kpi_benchmarking():
        sw = Software()
        src_sw, tgt_sw = sw.get_source_and_target_sw_from_artifacts_if_not_defined()
        sw.check_active_sw_and_rollback_if_found_on_passive_partition(src_sw)
        configure_as_encryption_on_mn_and_sn_gnbs(True)
        enable_zero_pm_counters_suppression()

        reference_start_time, reference_end_time = nrdc_kpi_scenario_with_pm_intervals()

        sw.upgrade_btses_sw_in_sequence(tgt_sw)

        current_start_time, current_end_time = nrdc_kpi_scenario_with_pm_intervals()

        time.sleep(20*60)    # Wait At Least 20 Min Before Creating Compare Report On Scout
        generate_and_verify_scout_nrdc_report(
            scout_mn_bts_name="7_7_UTE5GCLOUDT4SK010_1",
            scout_sn_bts_name="7_7_UTE5GCLOUDT4SK010_2",
            mn_template_id="1407",
            sn_template_id="1439",
            reference_start_time=reference_start_time,
            reference_end_time=reference_end_time,
            current_start_time=current_start_time,
            current_end_time=current_end_time,
            first_period_description=src_sw,
            second_period_description=tgt_sw,
            alpha="0.005",
        )

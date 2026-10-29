from robot.api import logger
from time import sleep

from ute_wtssim.exception import NoRegexpMatch

from variables import *


def attach_ue_and_establish_pdu_session(ue_id=1, sleep_sec=3):
    ta5g_ue_mobility = BuiltIn().get_library_instance('ta5g_ue_mobility')
    ta5g_ue_mobility.attach_ue(ue_id=ue_id, pass_regexp=BuiltIn().get_variable_value("${ATTACH_PASS_REGEXP}"))
    sleep(1)
    ta5g_ue_mobility.establish_pdu_session(ue_id=ue_id, gw_id=ue_id)
    sleep(int(sleep_sec))


def _prepare_validation_of_measurement_reports(ue_id, should_perform_ho, pass_regexp, fail_regexp, ho_type="intra"):
    if ho_type not in {"inter", "intra"}:
        raise ValueError("ho_type: {} must be either \"inter\" or \"intra\"".format(ho_type))
    if ho_type == "intra":
        ho_type_successful_egate_print = INTRA_HO_SUCCESSFUL_EGATE_PRINT
    else:
        ho_type_successful_egate_print = INTER_HO_SUCCESSFUL_EGATE_PRINT

    if should_perform_ho is True:
        pass_regexp = ho_type_successful_egate_print.format(ue_id)
        fail_regexp = None
    elif should_perform_ho is False:
        pass_regexp = None
        fail_regexp = ho_type_successful_egate_print.format(ue_id)
    return pass_regexp, fail_regexp


def send_A3_measurement_report_with_PCI(ue_id=1, should_perform_ho=None, pass_regexp=None, fail_regexp=None,
                                        meas_id=1, srsrp_nr=20, srsrq_nr=40, pci=50, nrsrp_nr=100, nrsrq_nr=50,
                                        ho_type="intra", sleep_sec=3, wait_after=True):

    pass_regexp, fail_regexp = _prepare_validation_of_measurement_reports(ue_id, should_perform_ho,
                                                                          pass_regexp, fail_regexp, ho_type)

    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_measurement_send_nr id={} meas_id={} event=A3 srsrp_nr={} srsrq_nr={} '
        'phycell_id={} nrsrp_nr={} nrsrq_nr={}'.format(ue_id, meas_id, srsrp_nr, srsrq_nr, pci, nrsrp_nr, nrsrq_nr),
        pass_regexp=pass_regexp, fail_regexp=fail_regexp)
    if pass_regexp or should_perform_ho:
        logger.info(pass_regexp, also_console=True)
    elif should_perform_ho is False:
        logger.info("UE{}: did not perform handover - this was expected".format(ue_id), also_console=True)
    if wait_after:
        sleep(int(sleep_sec))


def send_A3_measurement_report_with_PCI_return_status(ue_id=1, should_perform_ho=None, pass_regexp=None,
                                                      fail_regexp=None, meas_id=1, srsrp_nr=20, srsrq_nr=40, pci=50,
                                                      nrsrp_nr=100, nrsrq_nr=50, ho_type="intra", sleep_sec=3,
                                                      wait_after=True):
    pass_regexp, fail_regexp = _prepare_validation_of_measurement_reports(ue_id, should_perform_ho,
                                                                          pass_regexp, fail_regexp, ho_type)
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    try:
        ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
            'ue_measurement_send_nr id={} meas_id={} event=A3 srsrp_nr={} srsrq_nr={} '
            'phycell_id={} nrsrp_nr={} nrsrq_nr={}'.format(ue_id, meas_id, srsrp_nr, srsrq_nr, pci, nrsrp_nr,
                                                           nrsrq_nr),
            pass_regexp=pass_regexp, fail_regexp=fail_regexp)
        if pass_regexp or should_perform_ho:
            logger.info(pass_regexp, also_console=True)
        elif not should_perform_ho:
            logger.info("UE{}: did not perform handover - this was expected".format(ue_id), also_console=True)
        if wait_after:
            sleep(int(sleep_sec))
        return True
    except NoRegexpMatch:
        return False


def send_A3_measurement_report_with_3_unknown_PCIs(ue_id="1", should_perform_ho=None,
                                                   pass_regexp=None, fail_regexp=None, ho_type="intra"):
    pass_regexp, fail_regexp = _prepare_validation_of_measurement_reports(ue_id, should_perform_ho,
                                                                          pass_regexp, fail_regexp, ho_type)
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=10 srsrq_nr=40 '
        'phycell_id=51 nrsrp_nr=20 nrsrq_nr=50 '
        'phycell_id=60 nrsrp_nr=25 nrsrq_nr=50 '
        'phycell_id=65 nrsrp_nr=30 nrsrq_nr=50', pass_regexp=pass_regexp, fail_regexp=fail_regexp)
    if pass_regexp:
        logger.info(pass_regexp, also_console=True)
    sleep(3)


def send_A3_measurement_report_with_60_and_51_PCIs_with_different_RSRP_values(ue_id="1", should_perform_ho=None,
                                                                              pass_regexp=None, fail_regexp=None,
                                                                              ho_type="intra"):
    pass_regexp, fail_regexp = _prepare_validation_of_measurement_reports(ue_id, should_perform_ho,
                                                                          pass_regexp, fail_regexp, ho_type)
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_measurement_send_nr id={} meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 '
        'phycell_id=60 nrsrp_nr=90  nrsrq_nr=50 '
        'phycell_id=51 nrsrp_nr=100 nrsrq_nr=50'.format(ue_id), pass_regexp=pass_regexp, fail_regexp=fail_regexp)
    if pass_regexp:
        logger.info(pass_regexp, also_console=True)
    sleep(3)


def send_A3_measurement_report_with_51_and_60_PCIs_with_higher_RSRP_for_60(ue_id="1", should_perform_ho=None,
                                                                           pass_regexp=None, fail_regexp=None,
                                                                           ho_type="intra"):
    pass_regexp, fail_regexp = _prepare_validation_of_measurement_reports(ue_id, should_perform_ho,
                                                                          pass_regexp, fail_regexp, ho_type)
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_measurement_send_nr id={} meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 '
        'phycell_id=51 nrsrp_nr=100 nrsrq_nr=50 '
        'phycell_id=60 nrsrp_nr=120 nrsrq_nr=70'.format(ue_id), pass_regexp=pass_regexp, fail_regexp=fail_regexp)
    if pass_regexp:
        logger.info(pass_regexp, also_console=True)
    sleep(3)


def send_A3_measurement_report_with_51_and_60_PCIs_with_higher_RSRP_for_51(ue_id="1", should_perform_ho=None,
                                                                           pass_regexp=None, fail_regexp=None,
                                                                           ho_type="intra"):
    pass_regexp, fail_regexp = _prepare_validation_of_measurement_reports(ue_id, should_perform_ho,
                                                                          pass_regexp, fail_regexp, ho_type)
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_measurement_send_nr id={} meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 '
        'phycell_id=60 nrsrp_nr=100 nrsrq_nr=50 '
        'phycell_id=51 nrsrp_nr=120 nrsrq_nr=70'.format(ue_id), pass_regexp=pass_regexp, fail_regexp=fail_regexp)
    if pass_regexp:
        logger.info(pass_regexp, also_console=True)
    sleep(3)


def trigger_not_sending_next_rrc_reconfiguration_complete_message_sent_during_next_report_cgi_procedure():
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id=1 if_contains=report_cgi action=drop')
    sleep(3)


def trigger_RRC_reestablishment_during_next_report_cgi_procedure():
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id=1 if_contains=report_cgi action=reestablish')
    sleep(3)


def trigger_not_sending_measurement_report_with_CGI_mgs_during_next_report_cgi_procedure():
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id=1 if_contains=report_cgi action=donot_send_NRCGI')
    sleep(3)


def trigger_sending_measurement_report_with_CGI_info_with_measResults_broken_during_next_report_cgi_procedure():
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id=1 if_contains=report_cgi action=report_noSIB1AndnoNRCGI')
    sleep(3)


def trigger_failure_of_next_handover(ue_id="1", sleep_sec=3):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id={} if_contains=reconfiguration_with_sync action=drop'.format(ue_id))
    sleep(int(sleep_sec))


def trigger_sending_noSIB1_in_RRC_measurement_report(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id={} if_contains=report_cgi action=report_noSIB1'.format(ue_id))
    sleep(3)


def trigger_sending_CGI_complete_and_hex(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id={} if_contains=report_cgi action=send_complete_and_hex '
        'hex=0041000432D8A288080050CD6C8CB0CC0086D0104C4691200000000000800400 skip_processing=on'.format(ue_id))
    sleep(3)


def trigger_sending_CGI_complete_and_hex_with_A3(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id={} if_contains=report_cgi action=send_complete_and_hex '
        'hex=0040000432D8A288080010CD6C8C80'.format(ue_id))
    sleep(3)


def trigger_sending_CGI_complete_and_hex_with_A3_27(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id={} if_contains=report_cgi action=send_complete_and_hex '
        'hex=0040000432D8A288080010F16C8C80 skip_processing=on'.format(ue_id))
    sleep(3)


def trigger_sending_MR_with_CGI_info_with_optional_ie_trackingAreaCode_missing(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id={} if_contains=report_cgi action=send_complete_and_hex '
        'hex=0041000432D8A288080030C4008550004C4691200000200200 skip_processing=on'.format(ue_id))
    sleep(7)


def trigger_sending_MR_with_CGI_info_with_8_PLMN_entries_on_identityInfoList(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id={} if_contains=report_cgi action=send_complete_and_hex '
        'hex=0041000432D8A288080030C40090D013CC4691300703C0080500301C0100900502C0180D001008000000000008008000 '
        'skip_processing=on'.format(ue_id))
    sleep(7)


def trigger_sending_MR_with_CGI_info_with_2_PLMN_entries_on_identityInfoList(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id={} if_contains=report_cgi action=send_complete_and_hex '
        'hex=0041000432D8A288080030C4008DD050CC4691301108800000000000800D040040200000200000200300 '
        'skip_processing=on'.format(ue_id))
    sleep(7)


def trigger_sending_MR_with_CGI_info_with_1_supported_and_5_unsupported_PLMN_entries_on_identityInfoList(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id={} if_contains=report_cgi action=send_complete_and_hex '
        'hex=0041000432D8A288080030C400925051CC4691300201400C070040200000000000080090C0140B006030000008000008008000 '
        'skip_processing=on'.format(ue_id))
    sleep(7)


def trigger_sending_MR_with_CGI_info_with_2_duplicated_and_4_unsupported_PLMN_entries_on_identityInfoList(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_nr_rrc_reconf_param id={} if_contains=report_cgi action=send_complete_and_hex '
        'hex=0041000432D8A288080030C400925051CC4691300201400C070040200000000000080090CC4691300502800000800000800800 '
        'skip_processing=on'.format(ue_id))
    sleep(7)


def create_mobility_restriction_list_on_amf():
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'amf_mobility_restriction_list_param id=1 fa_plmn=311:489 forbidden_tacs=0')
    sleep(3)


def assign_mobility_restriction_list_to_ues(ue_ids="1", mrl_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'amf_ics_param id=1 ue={} mobility_restriction_list_id={}'.format(ue_ids, mrl_id))
    sleep(3)


def gnb_xn_handover_preparation_force_failure(id_="3"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'gnb_xn_handover_preparation_param action=force_failure id={}'.format(id_))
    sleep(3)


def gnb_xn_handover_preparation_reset(id_="3"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'gnb_xn_handover_preparation_param reset id={}'.format(id_))
    sleep(3)


def override_target_gnb_id_in_downlink_ran_configuration_transfer_to_real_gnb(ue_id="1", gnb_id="3",
                                                                              target_gnb_id="0x213:27"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'amf_ran_config_transfer_param id={} gnb={} action=override_ie target_gnb_id={}'.format(ue_id, gnb_id,
                                                                                                target_gnb_id))
    sleep(3)


def enable_son_config_transfer_procedure_delay_in_amf(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'amf_ran_config_transfer_param id={} gnb=2 action=delay time_to_wait=30'.format(ue_id))
    sleep(3)


def force_XnSetupFailure_response_from_ransim(gnb_id="3"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'gnb_xn_setup_param id={} action=force_failure'.format(gnb_id))
    sleep(3)


def configure_ransim_params_before_sending_measurement_report_part1():
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'gnb_cell_param gnb=3 id=1 enable_anr=on neighbor_pci=16:2')
    sleep(3)


def configure_ransim_params_before_sending_measurement_report_part2():
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'gnb_param id=3 sib1_period=40 send_xn_setup=true xn_listening_socket=on')


def ue_meas_cfg_disp(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_meas_cfg_disp id={} meas_obj_type=nr'.format(ue_id))
    sleep(3)


def send_A2_measurement_report_to_obtain_SSB_frequency(ue_id="1"):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_measurement_send_nr id={} meas_id=1 event=A2 srsrp_nr=20 srsrq_nr=40 '
        'phycell_id=70 nrsrp_nr=100 nrsrq_nr=50'.format(ue_id))
    sleep(3)


def set_gnb_xnlink_up():
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'gnb_xn_link_up gnb=3 target=2')
    sleep(3)


def set_sinr_testmode():
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ul_sinr_testmode_nr profile_id=1 sinr_target_srs=300 sinr_target_pusch=200 sinr_target_pucch=-300')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_testmode_set_nr id=1,2,3,4,5,6,7,8,9,10,11,12,13 testmode=ul_sinr action=activate profile_id=1')

import logging
from robot.api.deco import keyword
from taf.analyzer.pcap.pcap_packet import PcapPacket
from taf.rfrl.bts.commissioning import perform_commissioning_on_gnb_to_onair_state
from taf.rfrl.utilities.parsers.pcap_checker import pcap_checker, VerificationError

import testsuite.Wroclaw.RRM.WRO_2.CB008490.resources.pcap_e1ap_msgs as e1ap
import testsuite.Wroclaw.RRM.WRO_2.CB008490.resources.pcap_xnap_msgs as xnap
import testsuite.Wroclaw.RRM.WRO_2.CB008490.resources.pcap_f1ap_msgs as f1ap
import testsuite.Wroclaw.RRM.WRO_2.CB008490.resources.pcap_ngap_msgs as ngap
import testsuite.Wroclaw.RRM.WRO_2.CB008490.resources.pcap_rrc_msgs as rrc
from taf.rfrl.utilities.robot.parallel_runner import run_parallel_in_robot
from testsuite.Wroclaw.RRM.WRO_2.CB008490.resources.common_keywords import *


@keyword()
def verify_ngap_initial_context_setup(pcap_file: str, nrcell_id, forbidden_msgs_check=True) -> None:
    """Verifies NGAP messages content based on pcap file.
    KW checks if UE perform Registration on desired cell and if PDU Session was established successfully.

    :param pcap_file: path to pcap file
    :param nrcell_id: nr cell identity in DECIMAL
    :param forbidden_msgs_check: bool whether to check forbidden_messages
    """
    hex_cell_id = get_nr_cell_id_in_hex(nr_cell_id=nrcell_id, hex_len=18)

    ng_ics_flow = "".join([ngap.initial_ue_message_nrcellid % hex_cell_id,
                           ngap.ics_setup_req_pdu_session,
                           ngap.ics_setup_resp_pdu_session])

    forbidden_messages = ngap.ue_ctx_rel_req if forbidden_msgs_check else None
    pcap_checker().expect_flow(pcap_file=pcap_file,
                               display_filter='ngap',
                               awaited_messages=ng_ics_flow,
                               forbidden_messages=forbidden_messages)


def verify_nrdc_call_setup(pcap_file: str) -> None:
    """Verifies basic flow of NRDC call setup on XN interface

    :param pcap_file: path to pcap file
    """
    snode_addition_flow = "".join([xnap.snode_add_req_allowed_bc,
                                   xnap.snode_add_req_ack,
                                   xnap.xnu_addr_ind,
                                   xnap.sn_status_transfer,
                                   xnap.snode_reconf_complete])

    pcap_checker().expect_flow(pcap_file=pcap_file,
                               display_filter='xnap',
                               awaited_messages=snode_addition_flow,
                               forbidden_messages=xnap.snode_release_req)


def verify_mn_nrdc_with_8cc_fr2_call_setup(mn_pcap_file) -> None:
    """Verifies flow of NRDC call with 8CC on FR2 on MN gNB

    :param mn_pcap_file: path to pcap file
    """
    snode_addition_flow = "".join([xnap.snode_add_req_allowed_bc,
                                   xnap.snode_add_req_ack_8cc,
                                   f1ap.ue_ctx_mod_req_allowedbc_listmrdc,
                                   f1ap.ue_ctx_mod_resp_bc_idx_fs_idx,
                                   xnap.xnu_addr_ind,
                                   xnap.sn_status_transfer,
                                   xnap.snode_reconf_complete])
    rrc_reconfig_flow_xn = "".join([xnap.snode_add_req_ack_8cc,
                                    rrc.rrc_reconfig_8cc,
                                    rrc.rrc_reconfig_complete,
                                    xnap.snode_reconf_complete])
    rrc_reconfig_flow_rrc = "".join([xnap.snode_add_req_ack_8cc,
                                     rrc.rrc_reconfig_8cc,
                                     rrc.rrc_reconfig_complete,
                                     f1ap.ue_ctx_mod_req_rrc_reconfig_complete_ind,
                                     f1ap.ue_ctx_mod_resp])
    snode_addition_flow_pdu_session = "".join([xnap.snode_add_req_ack_8cc,
                                               e1ap.bearer_mod_req,
                                               e1ap.bearer_mod_resp,
                                               ngap.pdu_session_res_mod_ind,
                                               ngap.pdu_session_res_mod_confirm,
                                               e1ap.bearer_mod_req,
                                               e1ap.bearer_mod_resp])

    pc = pcap_checker()
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages=snode_addition_flow,
                   forbidden_messages=xnap.snode_release_req)
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages=rrc_reconfig_flow_xn)
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages=rrc_reconfig_flow_rrc)
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or ngap or e1ap',
                   awaited_messages=snode_addition_flow_pdu_session)


def verify_sn_nrdc_with_8cc_fr2_call_setup(sn_pcap_file) -> None:
    """Verifies flow of NRDC call with 8CC on FR2 on SN gNB

    :param sn_pcap_file: path to pcap file
    """
    xn_f1_flow = "".join([xnap.snode_add_req_allowed_bc,
                          f1ap.ue_ctx_setup_req_8cc,
                          f1ap.ue_ctx_setup_resp,
                          xnap.snode_add_req_ack_8cc,
                          xnap.xnu_addr_ind,
                          xnap.sn_status_transfer,
                          xnap.snode_reconf_complete])

    xn_e1_flow = "".join([xnap.snode_add_req_allowed_bc,
                          e1ap.bearer_setup_req,
                          e1ap.bearer_setup_resp,
                          e1ap.bearer_mod_req,
                          e1ap.bearer_mod_resp,
                          e1ap.bearer_context_inactivity_notification_active])

    pc = pcap_checker()
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages=xn_f1_flow)
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='xnap or e1ap',
                   awaited_messages=xn_e1_flow)


@keyword()
def verify_nrdc_with_8cc_fr2_call_setup(mn_pcap_file, sn_pcap_file) -> None:
    """Verifies flow of NRDC call establishment with 8CC on FR2 on MN and SN gNBs

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    """
    verify_mn_nrdc_with_8cc_fr2_call_setup(mn_pcap_file)
    verify_sn_nrdc_with_8cc_fr2_call_setup(sn_pcap_file)


@keyword()
def verify_nrdc_call_release_due_to_amf(mn_pcap_file, sn_pcap_file) -> None:
    """Verifies  flow of NRDC call release on MN and SN gNBs

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    """
    verif_mn_nrdc_call_release_due_to_amf(mn_pcap_file)
    verify_sn_nrdc_call_release_due_to_amf(sn_pcap_file)


def verif_mn_nrdc_call_release_due_to_amf(mn_pcap_file) -> None:
    """Verifies ng_xn_release_flow of NRDC call release on MN gNB

    :param mn_pcap_file: path to pcap file
    """
    ng_xn_release_flow = "".join([ngap.ue_ctx_rel_req_nas_deregister,
                                  xnap.snode_rel_req_radio_network_normal_release,
                                  xnap.snode_rel_req_ack,
                                  xnap.ue_ctx_rel,
                                  ngap.ue_ctx_release_complete])

    f1_release_flow = "".join([f1ap.ue_ctx_rel_command_radio_network_normal_release,
                               f1ap.ue_ctx_rel_complete])

    e1_release_flow = "".join([e1ap.bearer_rel_command_radio_network_normal_release,
                               e1ap.bearer_rel_complete])

    pc = pcap_checker()
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='ngap or xnap',
                   awaited_messages=ng_xn_release_flow)
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='f1ap',
                   awaited_messages=f1_release_flow)
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='e1ap',
                   awaited_messages=e1_release_flow)


def verify_sn_nrdc_call_release_due_to_amf(sn_pcap_file) -> None:
    """Verifies flow of NRDC call release on SN gNB

    :param sn_pcap_file: path to pcap file
    """
    snode_release_flow = "".join([xnap.snode_rel_req_radio_network_normal_release,
                                  f1ap.ue_ctx_mod_req_stop,
                                  xnap.snode_rel_req_ack,
                                  xnap.ue_ctx_rel,
                                  f1ap.ue_ctx_rel_command_radio_network_normal_release])
    snode_release_flow_e1_flow = "".join([xnap.snode_rel_req_radio_network_normal_release,
                                          e1ap.bearer_mod_req_stop,
                                          xnap.snode_rel_req_ack,
                                          xnap.ue_ctx_rel,
                                          e1ap.bearer_rel_command_radio_network_normal_release])
    f1_context_mod_and_release_flow = "".join([f1ap.ue_ctx_mod_req_stop,
                                               f1ap.ue_ctx_mod_resp,
                                               f1ap.ue_ctx_rel_command_radio_network_normal_release,
                                               f1ap.ue_ctx_rel_complete])
    e1_bearer_mod_and_release_flow = "".join([e1ap.bearer_mod_req_stop,
                                              e1ap.bearer_mod_resp,
                                              e1ap.bearer_rel_command_radio_network_normal_release,
                                              e1ap.bearer_rel_complete])

    pc = pcap_checker()
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages=snode_release_flow)
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='xnap or e1ap',
                   awaited_messages=snode_release_flow_e1_flow)
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='f1ap',
                   awaited_messages=f1_context_mod_and_release_flow)
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='e1ap',
                   awaited_messages=e1_bearer_mod_and_release_flow)


@keyword()
def verify_nrdc_release_and_reestablishment(mn_pcap_file: str, sn_pcap_file: str) -> None:
    """
    Verifies flow of NRDC release and RRC Reestablishment on MN and SN gNBs

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    """

    verify_mn_nrdc_release_and_reestablishment(mn_pcap_file)
    verify_sn_nrdc_release_and_reestablishment(sn_pcap_file)


def verify_mn_nrdc_release_and_reestablishment(mn_pcap_file: str) -> None:
    """Verifies flow of NRDC release and RRC Reestablishment on MN gNB

    :param mn_pcap_file: path to pcap file
    """
    ng_xn_release_flow = "".join([ngap.ue_ctx_rel_req_radio_connection_with_ue_lost,
                                  xnap.snode_release_req,
                                  xnap.snode_rel_req_ack])

    f1_release_flow = "".join([f1ap.ue_ctx_rel_command_radio_network_normal_release,
                               f1ap.ue_ctx_rel_complete])

    e1_release_flow = "".join([e1ap.bearer_rel_command_radio_network_normal_release,
                               e1ap.bearer_rel_complete])

    rrc_release_flow = "".join([rrc.rrc_reestablishment,
                                rrc.rrc_setup,
                                rrc.rrc_setup_complete])

    pc = pcap_checker()
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='ngap or xnap',
                   awaited_messages=ng_xn_release_flow)
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='f1ap',
                   awaited_messages=f1_release_flow)
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='e1ap',
                   awaited_messages=e1_release_flow)
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='nr-rrc',
                   awaited_messages=rrc_release_flow)


def verify_sn_nrdc_release_and_reestablishment(sn_pcap_file: str) -> None:
    """Verifies flow of NRDC release and RRC Reestablishment on SN gNB

    :param sn_pcap_file: path to pcap file
    """
    ng_xn_release_flow = "".join([xnap.snode_rel_req_radio_network_radio_connection_with_ue_lost,
                                  xnap.snode_rel_req_ack,
                                  xnap.ue_ctx_rel,
                                  xnap.snode_add_req_allowed_bc,
                                  xnap.snode_add_req_ack,
                                  xnap.xnu_addr_ind,
                                  xnap.sn_status_transfer,
                                  xnap.snode_reconf_complete])

    f1_release_flow = "".join([f1ap.ue_ctx_rel_command_radio_network_unspecified,
                               f1ap.ue_ctx_rel_complete])

    e1_release_flow = "".join([e1ap.bearer_rel_command_radio_network_unspecified,
                               e1ap.bearer_rel_complete])

    pc = pcap_checker()
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='ngap or xnap',
                   awaited_messages=ng_xn_release_flow)
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='f1ap',
                   awaited_messages=f1_release_flow)
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='e1ap',
                   awaited_messages=e1_release_flow)


@keyword()
def verify_sn_initiated_partial_reset(mn_pcap_file: str, sn_pcap_file: str) -> None:
    """Verifies flow SN initiated Partial Reset on MN and SN gNBs

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    """
    verify_mn_part_of_sn_initiated_partial_reset(mn_pcap_file)
    verify_sn_part_of_sn_initiated_partial_reset(sn_pcap_file)


@keyword()
def verify_mn_part_of_sn_initiated_partial_reset(mn_pcap_file: str) -> None:
    """Verifies flow of SN initiated Partial Reset on MN gNB

    :param mn_pcap_file: path to pcap file
    """
    main_reset_flow = [xnap.reset_req_partial_misc_om_intervention,
                       xnap.reset_resp_partial_misc_om_intervention,
                       ngap.ng_reset_resp_partial_misc_om_intervention,
                       ngap.ng_reset_ack,
                       rrc.rrc_reestablishment,
                       rrc.rrc_setup,
                       rrc.rrc_setup_complete]

    xn_e1_reset_flow = [xnap.reset_req_partial_misc_om_intervention,
                        xnap.reset_resp_partial_misc_om_intervention,
                        e1ap.reset_partial_transport_unspecified,
                        e1ap.reset_ack]

    xn_f1_reset_flow = [xnap.reset_req_partial_misc_om_intervention,
                        xnap.reset_resp_partial_misc_om_intervention,
                        f1ap.reset_partial_transport_unspecified,
                        f1ap.reset_ack]

    pc = pcap_checker()
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or ngap or nr-rrc',
                   awaited_messages="".join(main_reset_flow))
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or e1ap',
                   awaited_messages="".join(xn_e1_reset_flow))
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages="".join(xn_f1_reset_flow))
    verify_nrdc_call_setup(mn_pcap_file)


@keyword()
def verify_sn_part_of_sn_initiated_partial_reset(sn_pcap_file: str) -> None:
    """Verifies flow of SN initiated Partial Reset on MN gNB

    :param sn_pcap_file: path to pcap file
    """
    e1_reset_flow = [e1ap.reset_partial_misc_om_intervention,
                     e1ap.reset_ack]

    xn_reset_flow = [xnap.reset_req_partial_misc_om_intervention,
                     xnap.reset_resp_partial_misc_om_intervention]

    f1_reset_flow = [f1ap.reset_partial_misc_om_intervention,
                     f1ap.reset_ack]

    pc = pcap_checker()
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='e1ap',
                   awaited_messages="".join(e1_reset_flow))
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='xnap',
                   awaited_messages="".join(xn_reset_flow))
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='f1ap',
                   awaited_messages="".join(f1_reset_flow))


@keyword()
def verify_sn_terminated_pdu_session_release(mn_pcap_file: str, sn_pcap_file: str) -> None:
    """Verifies flow SN Terminated PDU Session release on MN and SN gNBs

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    """
    verify_on_mn_gnb_sn_terminated_pdu_session_release(mn_pcap_file)
    verify_on_sn_gnb_sn_terminated_pdu_session_release(sn_pcap_file)


@keyword()
def verify_on_mn_gnb_sn_terminated_pdu_session_release(mn_pcap_file: str) -> None:
    """Verifies flow SN Terminated PDU Session release on MN gNB

    :param mn_pcap_file: path to pcap file
    """
    ng_flow = [ngap.pdu_session_res_rel_command,
               ngap.pdu_session_res_rel_response]

    xn_flow = [xnap.snode_release_req,
               xnap.snode_rel_req_ack,
               xnap.ue_ctx_rel]

    e1_flow = [e1ap.bearer_mod_req_release,
               e1ap.bearer_mod_resp]

    f1_flow = [f1ap.ue_ctx_mod_req_scg_release,
               f1ap.ue_ctx_mod_resp_dutocurrcinfo,
               rrc.rrc_reconfig_scg_release,
               rrc.rrc_reconfig_complete,
               f1ap.ue_ctx_mod_req_rrc_reconfig_complete_ind,
               f1ap.ue_ctx_mod_resp,
               f1ap.ue_ctx_mod_req_du_config_query,
               f1ap.ue_ctx_mod_resp_dutocurrcinfo]

    pc = pcap_checker()
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='ngap',
                   awaited_messages="".join(ng_flow))
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap',
                   awaited_messages="".join(xn_flow))
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='e1ap',
                   awaited_messages="".join(e1_flow))
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='f1ap',
                   awaited_messages="".join(f1_flow))


@keyword()
def verify_on_sn_gnb_sn_terminated_pdu_session_release(sn_pcap_file: str) -> None:
    """Verifies flow SN Terminated PDU Session release on SN gNB

    :param sn_pcap_file: path to pcap file
    """
    xn_flow = [xnap.snode_release_req,
               xnap.snode_rel_req_ack,
               xnap.ue_ctx_rel]

    e1_flow = [e1ap.bearer_mod_req_stop,
               e1ap.bearer_mod_resp,
               e1ap.bearer_rel_command_radio_network_normal_release,
               e1ap.bearer_rel_complete]

    f1_flow = [f1ap.ue_ctx_mod_req_stop,
               f1ap.ue_ctx_mod_resp,
               f1ap.ue_ctx_rel_command_radio_network_normal_release,
               f1ap.ue_ctx_rel_complete]

    pc = pcap_checker()

    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='xnap',
                   awaited_messages="".join(xn_flow))
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='e1ap',
                   awaited_messages="".join(e1_flow))
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='f1ap',
                   awaited_messages="".join(f1_flow))


@keyword()
def verify_that_power_saving_bwp_was_configured_in_rrc(pcap_file: str) -> None:
    """Verifies RRCReconfiguration for PS BWP configuration with given bandwidth

    :param pcap_file: path to pcap file
    """
    rrc_flow = [rrc.ue_capability_info_ps_bwp,
                rrc.rrc_reconfig_passes % 'sskpy.verify_mcg_ps_bwp_is_20mhz',
                rrc.rrc_reconfig_complete]

    pc = pcap_checker()
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='f1ap',
                   awaited_messages="".join(rrc_flow))


@keyword()
def verify_small_and_large_bwp_in_rrc(pcap_file: str) -> None:
    """Verifies RRCSetup and RRCReconfiguration for Small and Large BWP configuration

    :param pcap_file: path to pcap file
    """
    rrc_flow = [rrc.rrc_setup_passes % 'sskpy.verify_mcg_bwp_is_20mhz',
                rrc.ue_capability_info,
                rrc.rrc_reconfig_passes % 'sskpy.verify_mcg_bwp_is_100mhz',
                xnap.snode_add_req_ack,
                rrc.rrc_reconfig_passes % 'sskpy.verify_mcg_bwp_was_not_changed',
                rrc.rrc_reconfig_complete]

    pc = pcap_checker()
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='f1ap or xnap',
                   awaited_messages="".join(rrc_flow))


def verify_mcg_bwp_was_not_changed(packet: PcapPacket):
    """ KW checks if nr-rrc.locationAndBandwidth is not present in PCAP packet what means that in given
    RRCReconfiguration value was not changed.

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :return: None
    """
    mcg = '//nr-rrc.masterCellGroup'
    dl_bwp_add_mod = '//nr-rrc.downlinkBWP_ToAddModList'
    ul_bwp_add_mod = '//nr-rrc.uplinkBWP_ToAddModList'
    loc_and_bw = '//nr-rrc.locationAndBandwidth'
    verify_xpath_field_is_empty(packet=packet, xpath=mcg + dl_bwp_add_mod + loc_and_bw)
    verify_xpath_field_is_empty(packet=packet, xpath=mcg + ul_bwp_add_mod + loc_and_bw)


def verify_mcg_bwp_is_100mhz(packet: PcapPacket):
    """KW checks if nr-rrc.locationAndBandwidth value represents 100 MHz Dedicated BWP

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :return: None
    """
    loc_and_bw_100mhz = ['1099']
    verify_mcg_bwp(packet, loc_and_bw_100mhz)


def verify_mcg_bwp_is_20mhz(packet: PcapPacket):
    """KW checks if nr-rrc.locationAndBandwidth value represents 20 MHz Dedicated BWP

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :return: None
    """
    loc_and_bw_20mhz = ['13750']
    verify_mcg_bwp(packet, loc_and_bw_20mhz)


def verify_mcg_ps_bwp_is_20mhz(packet: PcapPacket):
    """ KW checks if nr-rrc.locationAndBandwidth value represents 20 MHz PS BWP

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :return: None
    """

    loc_and_bw_20mhz = ['13750']
    verify_ps_bwp(packet, loc_and_bw_20mhz)


def verify_mcg_bwp(packet: PcapPacket, loc_and_bw_value: list) -> None:
    """KW checks values for nr-rrc.locationAndBandwidth field. Intention is to pass PCAP packet with
    RRC Reconfiguration where bwp_Id = 1 will be checked.

    :param packet: RRC Reconfiguration where UE gets BWPs configuration
    :param loc_and_bw_value: list of strings that is expected when checking PCAP packet for nr-rrc.locationAndBandwidth
    """
    mcg = '//nr-rrc.masterCellGroup'
    first_active_dl_bwp = '//nr-rrc.firstActiveDownlinkBWP_Id'
    first_active_ul_bwp = '//nr-rrc.firstActiveUplinkBWP_Id'
    dl_bwp_add_mod = '//nr-rrc.downlinkBWP_ToAddModList//nr-rrc.BWP_Downlink_element'
    ul_bwp_add_mod = '//nr-rrc.uplinkBWP_ToAddModList//nr-rrc.BWP_Uplink_element'
    bwp_id = '/nr-rrc.bwp_Id'
    loc_and_bw = '//nr-rrc.locationAndBandwidth'
    bwp_id_values = ['1']
    first_active_bwp_id_values = ['1']
    verify_xpath_field_for_value(packet=packet, xpath=mcg + dl_bwp_add_mod + loc_and_bw,
                                 value=loc_and_bw_value)
    verify_xpath_field_for_value(packet=packet, xpath=mcg + ul_bwp_add_mod + loc_and_bw,
                                 value=loc_and_bw_value)
    verify_xpath_field_for_value(packet=packet, xpath=mcg + dl_bwp_add_mod + bwp_id,
                                 value=bwp_id_values)
    verify_xpath_field_for_value(packet=packet, xpath=mcg + ul_bwp_add_mod + bwp_id,
                                 value=bwp_id_values)
    verify_xpath_field_for_value(packet=packet, xpath=mcg + first_active_dl_bwp,
                                 value=first_active_bwp_id_values)
    verify_xpath_field_for_value(packet=packet, xpath=mcg + first_active_ul_bwp,
                                 value=first_active_bwp_id_values)


def verify_ps_bwp(packet: PcapPacket, loc_and_bw_value: list) -> None:
    """KW checks values for nr-rrc.locationAndBandwidth field. Intention is to pass PCAP packet with
    RRC Reconfiguration where 2 BWPs are configured for UE (Dedicated and PS BWPs)

    :param packet: RRC Reconfiguration where UE gets BWPs configuration
    :param loc_and_bw_value: list of strings that is expected when checking PCAP packet for nr-rrc.locationAndBandwidth
    """
    mcg = '//nr-rrc.masterCellGroup'
    first_active_dl_bwp = '//nr-rrc.firstActiveDownlinkBWP_Id'
    first_active_ul_bwp = '//nr-rrc.firstActiveUplinkBWP_Id'
    dl_bwp_add_mod = '//nr-rrc.downlinkBWP_ToAddModList//nr-rrc.BWP_Downlink_element'
    ul_bwp_add_mod = '//nr-rrc.uplinkBWP_ToAddModList//nr-rrc.BWP_Uplink_element'
    bwp_id = '/nr-rrc.bwp_Id'
    loc_and_bw = '//nr-rrc.locationAndBandwidth'
    bwp_id_values = ['1', '2']
    first_active_bwp_id_values = ['1']

    verify_xpath_field_for_value(packet=packet, xpath=mcg + dl_bwp_add_mod + loc_and_bw,
                                 value=loc_and_bw_value)
    verify_xpath_field_for_value(packet=packet, xpath=mcg + ul_bwp_add_mod + loc_and_bw,
                                 value=loc_and_bw_value)
    verify_xpath_field_for_value(packet=packet, xpath=mcg + dl_bwp_add_mod + bwp_id,
                                 value=bwp_id_values)
    verify_xpath_field_for_value(packet=packet, xpath=mcg + ul_bwp_add_mod + bwp_id,
                                 value=bwp_id_values)
    verify_xpath_field_for_value(packet=packet, xpath=mcg + first_active_dl_bwp,
                                 value=first_active_bwp_id_values)
    verify_xpath_field_for_value(packet=packet, xpath=mcg + first_active_ul_bwp,
                                 value=first_active_bwp_id_values)


@keyword()
def verify_ue_activity_resumption(mn_pcap_file: str, sn_pcap_file: str) -> None:
    """Verifies flow UE activity resumption during NRDC call

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    :return: None
    """
    verify_on_mn_ue_activity_resumption(mn_pcap_file)
    verify_on_sn_ue_activity_resumption(sn_pcap_file)


def verify_on_mn_ue_activity_resumption(pcap_file: str) -> None:
    """Verifies low UE activity resumption on MN during NRDC call

    :param pcap_file: path to pcap file
    """
    flow = [xnap.activity_notification_inactive,
            xnap.activity_notification_reactivated,
            xnap.activity_notification_inactive,
            xnap.snode_release_req,
            xnap.snode_rel_req_ack,
            xnap.ue_ctx_rel]

    pc = pcap_checker()
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='xnap',
                   awaited_messages="".join(flow))


@keyword()
def verify_on_sn_ue_activity_resumption(pcap_file: str) -> None:
    """Verifies low UE activity resumption on SN during NRDC call

    :param pcap_file: path to pcap file
    """
    flow = [e1ap.bearer_context_inactivity_notification_not_active,
            xnap.activity_notification_inactive,
            e1ap.bearer_context_inactivity_notification_active,
            xnap.activity_notification_reactivated,
            e1ap.bearer_context_inactivity_notification_not_active,
            xnap.activity_notification_inactive,
            xnap.snode_release_req,
            xnap.snode_rel_req_ack,
            xnap.ue_ctx_rel]

    pc = pcap_checker()
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='xnap or e1ap',
                   awaited_messages="".join(flow))


@keyword()
def verify_totalnumberportssimultaneousnzp_csi_rs_percc_ge_4(pcap_file: str) -> None:
    """KW checks that UE Capabilities fr1_fr2_Add_UE_NR_Capabilities_element ->
    totalNumberPortsSimultaneousNZP_CSI_RS_PerCC is grater or equal 4 in PCAP packet

    :param pcap_file: path to pcap file
    """
    xpath = '//nr-rrc.fr1_fr2_Add_UE_NR_Capabilities_element//nr-rrc.totalNumberPortsSimultaneousNZP_CSI_RS_PerCC'
    packet = pcap_checker().get_packets(pcap_file=pcap_file,
                                        display_filter='f1ap',
                                        awaited_message=rrc.ue_capability_info)[0]

    verify_xpath_value_is_greater_or_equal(packet=packet,
                                           xpath=xpath,
                                           value=4)


@keyword()
def verify_pdcch_blind_detection_handling(pcap_file: str) -> None:
    """Verifies PCAP file that in UE Capabilities
       pdcch-BlindDetectionCA >= 4
       pdcch-BlindDetectionNRDC is present
    in RRC Reconfiguration/ XnAP Snode Additon Request Acknowledge with NRDC setup
       pdcch-BlindDetection = pdcch-BlindDetectionCA - 1

    :param pcap_file: path to pcap file
    """
    pc = pcap_checker()
    caps_packet = pc.get_packets(pcap_file=pcap_file,
                                 display_filter='f1ap',
                                 awaited_message=rrc.ue_capability_info)[0]
    real_value = verify_xpath_value_is_greater_or_equal(packet=caps_packet,
                                                        value=4,
                                                        xpath='//nr-rrc.pdcch_BlindDetectionCA')
    caps_packet.get_field_value_by_name('nr-rrc.pdcch_BlindDetectionNRDC_element')

    nrdc_scg_setup_packet = pc.get_packets(pcap_file=pcap_file,
                                           display_filter='f1ap',
                                           awaited_message=rrc.rrc_reconfig_nrdc_scg_config)[0]

    rrc_reconfig_pddch_blind_xpath = '//nr-rrc.mrdc_SecondaryCellGroupConfig//nr-rrc.pdcch_BlindDetection/nr-rrc.setup'
    verify_xpath_field_for_value(packet=nrdc_scg_setup_packet,
                                 xpath=rrc_reconfig_pddch_blind_xpath,
                                 value=[str(int(real_value) - 1)])


@keyword()
def verify_pucch_mux_one_process_two_report_groups(pcap_file: str) -> None:
    """KW verifies that
    - Single CSI-Process is sufficient for multiplexing what means that all csi-ReportConfigs
      uses the same periodicity and offset
    - PSCell (CQI +SR) + 1 SCell CQI is multiplexed into a Report_#1
    - Remaining 6 SCells CQI are multiplexed into a Report_#2
    - After first SNodeModification the csi-ReportConfig for BM (reportConfigId : 2)
      is added to the multiplexed report in the CSI-Process #1 and Report_#1
    - PUCCH Max Code Rate is zeroDot25

    :param pcap_file: path to pcap file
    """
    rrc_snode_add, rrc_snode_mod = get_rrc_snode_add_snode_mod_packets(pcap_file)
    verify_pucch_mux_resource_is_used_for_all_report_configs(rrc_snode_add, rrc_snode_mod)
    verify_csi_report_config_ids(rrc_snode_add, rrc_snode_mod)
    verify_single_csi_process_is_used(rrc_snode_add)

    verify_pucch_code_rate(rrc_snode_add, '2')
    verify_two_csi_groups_pscell_bm_one_scell_in_first(rrc_snode_add, rrc_snode_mod)


@keyword()
def verify_pucch_mux_one_process_one_report_group(pcap_file: str) -> None:
    """KW verifies that
    - Single CSI-Process is sufficient for multiplexing what means that all csi-ReportConfigs
      uses the same periodicity and offset
    - PSCell (CQI +SR) + 7 SCell CQI is multiplexed into a Report_#1
    - After first SNodeModification the csi-ReportConfig for BM (reportConfigId : 2)
      is added to the multiplexed report in the CSI-Process #1 and Report_#1
    - PUCCH Max Code Rate is zeroDot35

    :param pcap_file: path to pcap file
    """
    rrc_snode_add, rrc_snode_mod = get_rrc_snode_add_snode_mod_packets(pcap_file)
    verify_pucch_mux_resource_is_used_for_all_report_configs(rrc_snode_add, rrc_snode_mod)
    verify_csi_report_config_ids(rrc_snode_add, rrc_snode_mod)
    verify_single_csi_process_is_used(rrc_snode_add)

    verify_pucch_code_rate(rrc_snode_add, '3')
    verify_one_csi_report_group_is_used(rrc_snode_add, rrc_snode_mod)


@keyword()
def verify_rlmc_for_2_ies_in_scg(pcap_file: str) -> None:
    """KW verifies that for each FR2 cell
      BWP-DownlinkDedicated.radioLinkMonitoringConfig setup (1):
           failureDetectionResourcesToAddModList IE is not present
           beamFailureInstanceMaxCount: n3 (2)
           beamFailureDetectionTimer: pbfd2 (1)

    :param pcap_file: path to pcap file
    """
    pc = pcap_checker()
    rrc_snode_add = pc.get_packets(pcap_file=pcap_file,
                                   display_filter='f1ap',
                                   awaited_message=rrc.rrc_reconfig_nrdc_scg_config)[0]

    rlmc = "//nr-rrc.mrdc_SecondaryCellGroup//nr-rrc.bwp_Dedicated_element/nr-rrc.radioLinkMonitoringConfig"

    verify_rlmc_setup(rlmc, rrc_snode_add)
    verify_fail_detect_res_to_add_is_not_set(rlmc, rrc_snode_add)
    verify_beam_fail_inst_max_count(rlmc, rrc_snode_add)
    verify_beam_fail_detect_timer(rlmc, rrc_snode_add)


@keyword()
def verify_rlmc_for_3_ies_in_scg(pcap_file: str) -> None:
    """KW verifies that for each FR2 cell
      BWP-DownlinkDedicated.radioLinkMonitoringConfig setup (1):
           failureDetectionResourcesToAddModList
              radioLinkMonitoringRS-Id: 0
              purpose: both (2)
              detectionResource ssb-Index (0):
                ssb-Index: <SSB_INDEX_ID>
           beamFailureInstanceMaxCount: n3  (2)
           beamFailureDetectionTimer: pbfd2 (1)

    :param pcap_file: path to pcap file
    """
    pc = pcap_checker()
    rrc_snode_add = pc.get_packets(pcap_file=pcap_file,
                                   display_filter='f1ap',
                                   awaited_message=rrc.rrc_reconfig_nrdc_scg_config)[0]

    rlmc = "//nr-rrc.mrdc_SecondaryCellGroup//nr-rrc.bwp_Dedicated_element/nr-rrc.radioLinkMonitoringConfig"

    verify_rlmc_setup(rlmc, rrc_snode_add)
    verify_fail_detect_res_to_add_mod_purpose_both(rlmc, rrc_snode_add)
    verify_beam_fail_inst_max_count(rlmc, rrc_snode_add)
    verify_beam_fail_detect_timer(rlmc, rrc_snode_add)


@keyword()
def verify_rlmc_for_1_ie_in_scg(pcap_file: str) -> None:
    """KW verifies that for each FR2 cell
      BWP-DownlinkDedicated.radioLinkMonitoringConfig setup (1):
         failureDetectionResourcesToAddModList IE is present
              radioLinkMonitoringRS-Id: 0
              purpose: rlf (0)
              detectionResource ssb-Index (0):
                ssb-Index: <SSB_INDEX_ID>
         beamFailureInstanceMaxCount IE is NOT preset
         beamFailureDetectionTimer IE is NOT preset

    :param pcap_file: path to pcap file
    """
    pc = pcap_checker()
    rrc_snode_add = pc.get_packets(pcap_file=pcap_file,
                                   display_filter='f1ap',
                                   awaited_message=rrc.rrc_reconfig_nrdc_scg_config)[0]

    rlmc = "//nr-rrc.mrdc_SecondaryCellGroup//nr-rrc.bwp_Dedicated_element/nr-rrc.radioLinkMonitoringConfig"

    verify_rlmc_setup(rlmc, rrc_snode_add)
    verify_fail_detect_res_to_add_mod_purpose_rlf(rlmc, rrc_snode_add)
    verify_beam_fail_max_count_is_not_set(rlmc, rrc_snode_add)
    verify_beam_detect_is_not_set(rlmc, rrc_snode_add)


def verify_fail_detect_res_to_add_mod_purpose_both(rlmc, rrc_snode_add):
    """Function verifies if failureDetectionResourcesToAddModList IE is not present

    :param rlmc: XPATH to radioLinkMonitoringConfig for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    """
    fdrs_elem = rlmc + "//nr-rrc.failureDetectionResourcesToAddModList//nr-rrc.RadioLinkMonitoringRS_element"
    verify_rlms_id(fdrs_elem, rrc_snode_add)
    verify_purpose_both(fdrs_elem, rrc_snode_add)
    verify_detect_res(fdrs_elem, rrc_snode_add)


def verify_fail_detect_res_to_add_mod_purpose_rlf(rlmc, rrc_snode_add):
    """Function verifies if failureDetectionResourcesToAddModList IE is not present

    :param rlmc: XPATH to radioLinkMonitoringConfig for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    """
    fdrs_elem = rlmc + "//nr-rrc.failureDetectionResourcesToAddModList//nr-rrc.RadioLinkMonitoringRS_element"
    verify_rlms_id(fdrs_elem, rrc_snode_add)
    verify_purpose_rlf(fdrs_elem, rrc_snode_add)
    verify_detect_res(fdrs_elem, rrc_snode_add)


def verify_detect_res(fdrs_elem, rrc_snode_add):
    """Function verifies that all 8 SCG cells have detectionResource: ssb-Index (0)
    and same ssb-Index: <SSB_INDEX_ID>

    :param fdrs_elem: XPATH to RadioLinkMonitoringRS_element for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """
    detect_res = fdrs_elem + "/nr-rrc.detectionResource"
    detect_res_values = get_and_log_field_value(rrc_snode_add, detect_res)
    msg = f'Verifying that all 8 SCG cells have detectionResource: ssb-Index (0) -> {detect_res_values}'
    logging.info(msg)
    if not list_contains_same_values(detect_res_values, '0', 8):
        raise VerificationError(msg)
    ssb_idx = detect_res + "/nr-rrc.ssb_Index"
    ssb_idx_values = get_and_log_field_value(rrc_snode_add, ssb_idx)
    msg = f'Verifying that all 8 SCG cells have ssb-Index: <SSB_INDEX_ID> -> {ssb_idx_values}'
    logging.info(msg)
    if not list_contains_same_values(ssb_idx_values, ssb_idx_values[0], 8):
        raise VerificationError(msg)


def verify_purpose_both(fdrs_elem, rrc_snode_add):
    """Function verifies that all 8 SCG cells have purpose: both (2)

    :param fdrs_elem: XPATH to RadioLinkMonitoringRS_element for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """
    purpose = fdrs_elem + "/nr-rrc.purpose"
    purpose_values = get_and_log_field_value(rrc_snode_add, purpose)
    msg = f'Verifying that all 8 SCG cells have purpose: both (2) -> {purpose_values}'
    logging.info(msg)
    if not list_contains_same_values(purpose_values, '2', 8):
        raise VerificationError(msg)


def verify_purpose_rlf(fdrs_elem, rrc_snode_add):
    """Function verifies that all 8 SCG cells have radioLinkMonitoringRS-Id: 0

    :param fdrs_elem: XPATH to RadioLinkMonitoringRS_element for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """
    purpose = fdrs_elem + "/nr-rrc.purpose"
    purpose_values = get_and_log_field_value(rrc_snode_add, purpose)
    msg = f'Verifying that all 8 SCG cells have purpose: rlf (1) -> {purpose_values}'
    logging.info(msg)
    if not list_contains_same_values(purpose_values, '1', 8):
        raise VerificationError(msg)


def verify_rlms_id(fdrs_elem, rrc_snode_add):
    """Function verifies that all 8 SCG cells have radioLinkMonitoringRS-Id: 0

    :param fdrs_elem: XPATH to RadioLinkMonitoringRS_element for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """
    fdrs_id = fdrs_elem + "/nr-rrc.radioLinkMonitoringRS_Id"
    fdrs_id_values = get_and_log_field_value(rrc_snode_add, fdrs_id)
    msg = f'Verifying that all 8 SCG cells have radioLinkMonitoringRS_Id: 0 -> {fdrs_id_values}'
    logging.info(msg)
    if not list_contains_same_values(fdrs_id_values, '0', 8):
        raise VerificationError(msg)


def verify_fail_detect_res_to_add_is_not_set(rlmc: str, rrc_snode_add: PcapPacket) -> None:
    """Function verifies if failureDetectionResourcesToAddModList IE is not present

    :param rlmc: XPATH to radioLinkMonitoringConfig for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """
    fdrs_to_add = rlmc + "//nr-rrc.failureDetectionResourcesToAddModList"
    verify_xpath_field_is_empty(rrc_snode_add, fdrs_to_add)


def verify_beam_fail_max_count_is_not_set(rlmc: str, rrc_snode_add: PcapPacket) -> None:
    """Function verifies if beamFailureInstanceMaxCount IE is not present

    :param rlmc: XPATH to radioLinkMonitoringConfig for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """
    beam_failure_max_count = rlmc + "//nr-rrc.beamFailureInstanceMaxCount"
    verify_xpath_field_is_empty(rrc_snode_add, beam_failure_max_count)


def verify_beam_detect_is_not_set(rlmc: str, rrc_snode_add: PcapPacket) -> None:
    """Function verifies if beamFailureDetectionTimer IE is not present

    :param rlmc: XPATH to radioLinkMonitoringConfig for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """
    beam_failure_detect = rlmc + "//nr-rrc.beamFailureDetectionTimer"
    verify_xpath_field_is_empty(rrc_snode_add, beam_failure_detect)


def verify_beam_fail_detect_timer(rlmc: str, rrc_snode_add: PcapPacket) -> None:
    """Function verifies that all 8 SCG cells have beamFailureDetectionTimer: pbfd2 (1)

    :param rlmc: XPATH to radioLinkMonitoringConfig for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """
    beam_failure_detect = rlmc + "//nr-rrc.beamFailureDetectionTimer"
    beam_failure_detect_values = get_and_log_field_value(rrc_snode_add, beam_failure_detect)
    msg = f'Verifying that all 8 SCG cells have beamFailureDetectionTimer: pbfd2 (1) -> {beam_failure_detect}'
    logging.info(msg)
    if not list_contains_same_values(beam_failure_detect_values, '1', 8):
        raise VerificationError(msg)


def verify_beam_fail_inst_max_count(rlmc: str, rrc_snode_add: PcapPacket) -> None:
    """Function verifies that all 8 SCG cells have beamFailureInstanceMaxCount: n3 (2)

    :param rlmc: XPATH to radioLinkMonitoringConfig for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """
    beam_failure_max_count = rlmc + "//nr-rrc.beamFailureInstanceMaxCount"
    beam_failure_max_count_values = get_and_log_field_value(rrc_snode_add, beam_failure_max_count)
    msg = f'Verifying that all 8 SCG cells have beamFailureInstanceMaxCount: n3 (2)->{beam_failure_max_count_values}'
    logging.info(msg)
    if not list_contains_same_values(beam_failure_max_count_values, '2', 8):
        raise VerificationError(msg)


def verify_rlmc_setup(rlmc: str, rrc_snode_add: PcapPacket) -> None:
    """Function verifies if ll 8 SCG cells have radioLinkMonitoringConfig: setup (1)

    :param rlmc: XPATH to radioLinkMonitoringConfig for all SCG cells
    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """

    rlmc_values = get_and_log_field_value(rrc_snode_add, rlmc)
    msg = f'Verifying that all 8 SCG cells have radioLinkMonitoringConfig: setup (1) -> {rlmc_values}'
    logging.info(msg)
    if not list_contains_same_values(rlmc_values, '1', 8):
        raise VerificationError(msg)


@keyword()
def verify_rlmc_not_present_in_scg(pcap_file: str) -> None:
    """KW verifies that for each FR2 cell BWP-DownlinkDedicated.radioLinkMonitoringConfig IE is not present

    :param pcap_file: path to pcap file
    """
    pc = pcap_checker()
    rrc_snode_add = pc.get_packets(pcap_file=pcap_file,
                                   display_filter='f1ap',
                                   awaited_message=rrc.rrc_reconfig_nrdc_scg_config)[0]

    rlmc = "//nr-rrc.mrdc_SecondaryCellGroup//nr-rrc.bwp_Dedicated_element/nr-rrc.radioLinkMonitoringConfig"
    verify_xpath_field_is_empty(rrc_snode_add, rlmc)


def get_rrc_snode_add_snode_mod_packets(pcap_file: str) -> tuple[PcapPacket, PcapPacket]:
    """Function returns 2 PCAP packets with RRC Reconfiguration containing NDRC Setup and NRDC SCG Modification

    :param pcap_file: path to pcap file
    :return: two RRC Reconfiguration messages with SCG configuration
    """
    pc = pcap_checker()
    rrc_snode_config_packets = pc.get_packets(pcap_file=pcap_file,
                                              display_filter='f1ap',
                                              awaited_message=rrc.rrc_reconfig_nrdc_scg_config)
    try:
        rrc_snode_add = rrc_snode_config_packets[0]
        rrc_snode_mod = rrc_snode_config_packets[1]
        return rrc_snode_add, rrc_snode_mod
    except ValueError:
        logging.error("PCAP does not contain two RRC Reconfiguration messages with SCG Configuration")


def verify_two_csi_groups_pscell_bm_one_scell_in_first(rrc_snode_add: PcapPacket, rrc_snode_mod: PcapPacket) -> None:
    """Verifies if two CSI Report Groups are used for NRDC SCG cells.
    2 CSI Groups -> reportSlotConfig values in to groups: 2*X 6*Y, X for PSCell (first in table) and one SCell
                    reportSlotConfig of Report Config added in NRDC SCG modification (BM) has X value

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    """
    csi_report_periodicity = "//nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.reportSlotConfig"
    csi_report_offset = csi_report_periodicity + "/nr-rrc.slots320"

    csi_report_periodicity_values = get_and_log_field_value(rrc_snode_add, csi_report_periodicity)
    snode_mod_csi_report_periodicity_values = get_and_log_field_value(rrc_snode_mod, csi_report_periodicity)
    msg = f'Verifying if all CSI Report Config has the same reportSlotConfig value: {csi_report_periodicity_values}, '\
          f'{snode_mod_csi_report_periodicity_values}'
    logging.info(msg)
    if not list_contains_same_values(csi_report_periodicity_values, csi_report_periodicity_values[0], 8):
        raise VerificationError(msg)
    if not csi_report_periodicity_values[0] == snode_mod_csi_report_periodicity_values[0]:
        raise VerificationError(msg)

    csi_report_offset_values = get_and_log_field_value(rrc_snode_add, csi_report_offset)
    snode_mod_csi_report_offset_values = get_and_log_field_value(rrc_snode_mod, csi_report_offset)
    msg = f'Verifying if CSI Report Config offset values are divided in 2 groups: \n' \
          f'{csi_report_offset_values} have 2*X and 6*Y value and X is first element\n' \
          f'{snode_mod_csi_report_offset_values} have X value'
    logging.info(msg)
    if not csi_report_offset_values.count(csi_report_offset_values[0]) == 2:
        raise VerificationError(msg)
    if not csi_report_offset_values.count(csi_report_offset_values[1]) == 6:
        raise VerificationError(msg)
    if not csi_report_offset_values[0] == snode_mod_csi_report_offset_values[0]:
        raise VerificationError(msg)


def verify_one_csi_report_group_is_used(rrc_snode_add: PcapPacket, rrc_snode_mod: PcapPacket) -> None:
    """Verifies if one CSI Report Groups are used for NRDC SCG cells.
    1 CSI Groups -> reportSlotConfig values in to groups: 8*X for PSCell (first in table) and 7 SCells
                    reportSlotConfig of Report Config added in NRDC SCG modification (BM) has X value

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    """
    csi_report_periodicity = "//nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.reportSlotConfig"
    csi_report_offset = csi_report_periodicity + "/nr-rrc.slots320"

    csi_report_periodicity_values = get_and_log_field_value(rrc_snode_add, csi_report_periodicity)
    snode_mod_csi_report_periodicity_values = get_and_log_field_value(rrc_snode_mod, csi_report_periodicity)
    msg = f'Verifying if all CSI Report Config has the same reportSlotConfig value: {csi_report_periodicity_values}, '\
          f'{snode_mod_csi_report_periodicity_values}'
    logging.info(msg)
    if not list_contains_same_values(csi_report_periodicity_values, csi_report_periodicity_values[0], 8):
        raise VerificationError(msg)
    if not csi_report_periodicity_values[0] == snode_mod_csi_report_periodicity_values[0]:
        raise VerificationError(msg)

    csi_report_offset_values = get_and_log_field_value(rrc_snode_add, csi_report_offset)
    snode_mod_csi_report_offset_values = get_and_log_field_value(rrc_snode_mod, csi_report_offset)
    msg = f'Verifying if CSI Report Config has the same offset value: {csi_report_offset_values}, ' \
          f'{snode_mod_csi_report_offset_values}'
    logging.info(msg)
    if not csi_report_offset_values.count(csi_report_offset_values[0]) == 8:
        raise VerificationError(msg)
    if not csi_report_offset_values[0] == snode_mod_csi_report_offset_values[0]:
        raise VerificationError(msg)


def verify_single_csi_process_is_used(rrc_snode_add: PcapPacket) -> None:
    """Verifies if Single CSI Process is used for NRDC SCG
    Single CSI Process -> all CSI-RS Resources are using the same periodicityAndOffset vales

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """
    csi_res_periodicity = "//nr-rrc.csi_MeasConfig//nr-rrc.nzp_CSI_RS_ResourceToAddModList//nr-rrc.periodicityAndOffset"
    csi_res_offset = csi_res_periodicity + "/nr-rrc.slots320"
    csi_res_periodicity_values = get_and_log_field_value(rrc_snode_add, csi_res_periodicity)

    msg = 'periodicityAndOffset of CSI-RS Resources are not the same for all SCG cells'
    logging.info(msg)
    if not list_contains_same_values(csi_res_periodicity_values, csi_res_periodicity_values[0], 8):
        raise VerificationError(msg)
    csi_res_offset_values = get_and_log_field_value(rrc_snode_add, csi_res_offset)
    if not list_contains_same_values(csi_res_offset_values, csi_res_offset_values[0], 8):
        raise VerificationError(msg)


def verify_csi_report_config_ids(rrc_snode_add: PcapPacket, rrc_snode_mod: PcapPacket) -> None:
    """Verifies the presence of specific CSI Report Config IDs in RRC Reconfiguration messages for
    NRDC call establishment.
    Report Config IDs: 0 for PSCell CQI, 2 for PSCell BM (added in SNodeModification), 13-19 for SCell CQI

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    :raises: VerificationError
    """
    report_configs_ids = "//nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.reportConfigId"
    report_config_id_values = get_and_log_field_value(rrc_snode_add, report_configs_ids)
    expected_report_config_id_values = {'0', '13', '14', '15', '16', '17', '18', '19'}
    msg = f'Verifying that CSI reportConfigIds: {expected_report_config_id_values} ' \
          f'are subset of {report_config_id_values}'
    logging.info(msg)
    if not expected_report_config_id_values.issubset(report_config_id_values):
        raise VerificationError(msg)

    values = get_and_log_field_value(rrc_snode_mod, report_configs_ids)
    msg = f'Verifying that reportConfigId: 2 is present in RRC Reconfiguration with SCG Modification'
    logging.info(msg)
    if not {'2'}.issubset(values):
        raise VerificationError(msg)


def verify_pucch_mux_resource_is_used_for_all_report_configs(rrc_snode_add: PcapPacket,
                                                             rrc_snode_mod: PcapPacket) -> None:
    """Verifies that PUCCH Resource ID selected for Multiplexing is used for all CSI Report Configs
    Single CSI process -> all cells uses same PUCCH Resource ID selected for MUX

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    :raises: VerificationError
    """
    pucch_mux_res_id = "//nr-rrc.multi_CSI_PUCCH_ResourceList//nr-rrc.PUCCH_ResourceId"
    pucch_mux_res_id_value = get_and_log_field_value(rrc_snode_add, pucch_mux_res_id)[0]

    csi_report_pucch_res = "//nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.pucch_Resource"
    csi_report_pucch_res_values_list = get_and_log_field_value(rrc_snode_add, csi_report_pucch_res)
    snode_mod_csi_report_pucch_res_values_list = get_and_log_field_value(rrc_snode_mod, csi_report_pucch_res)
    msg = f'PUCCH MUX Resource ID slected for MUX: {pucch_mux_res_id_value} ' \
          f'should be used for all SCG reportConfigs: {csi_report_pucch_res_values_list}, ' \
          f'{snode_mod_csi_report_pucch_res_values_list}'
    logging.info(msg)
    if not list_contains_same_values(csi_report_pucch_res_values_list, pucch_mux_res_id_value, 8):
        raise VerificationError(msg)
    if not list_contains_same_values(snode_mod_csi_report_pucch_res_values_list, pucch_mux_res_id_value, 1):
        raise VerificationError(msg)


def verify_pucch_code_rate(rrc_snode_add: PcapPacket, value: str) -> None:
    """Verifies that PUCCH Max Code Rate

    :param rrc_snode_add: PCAP packet with RRC Reconfiguration message with NRDC Setup
    :param value: str with enum of PUCCH-MaxCodeRate ::=
                  ENUMERATED {zeroDot08, zeroDot15, zeroDot25, zeroDot35, zeroDot45, zeroDot60, zeroDot80}
                  e.g. '2' for zeroDot25
    :raises: VerificationError
    """
    pucch_code_rate = "//nr-rrc.bwp_Dedicated_element//nr-rrc.pucch_Config//nr-rrc.maxCodeRate"
    pucch_code_rate_value = get_and_log_field_value(rrc_snode_add, pucch_code_rate)[0]

    msg = f'Verifying that PUCCH Max Code Rate value {pucch_code_rate_value} is equal to {value}'
    logging.info(msg)
    if pucch_code_rate_value != value:
        raise VerificationError(msg)


@keyword
def perform_parallel_commissioning(prefix_tag=None) -> None:
    """Performs full commissioning on 2 BTSes in parallel

    :param prefix_tag: str based on which files will be chosen
    """
    list_of_functions = [{
        'function': perform_commissioning_on_gnb_to_onair_state,
        'function_kwargs': {'bts_id': 0,
                            'asir_hub': True,
                            'prefix_tag': prefix_tag,
                            'update_timeout': 1800},
        'device_name': 'GNB0'
    }, {
        'function': perform_commissioning_on_gnb_to_onair_state,
        'function_kwargs': {'bts_id': 1,
                            'prefix_tag': prefix_tag,
                            'update_timeout': 1200},
        'device_name': 'GNB1'
    }]
    run_parallel_in_robot(list_of_functions)


# CB008490_ET_LD_alt6
@keyword()
def verify_pucch_mux_two_process_four_report_groups(pcap_file: str) -> None:
    """KW verifies that
    - Two CSI-Process are sufficient for multiplexing, which means that there are two groups of csi-ReportConfigs cells
      and these four groups of cells use four different periodicities and

    - First CSI-Process is sufficient for multiplexing what means that all the same csi-ReportConfigs
      uses the same periodicity and offset
      [configured BM report non-multiplexing]+[PSCell (CQI)+1SCell (CQI)]+[2SCell (CQI)] =4cells
    - Second CSI-Process is sufficient for multiplexing what means that all the same csi-ReportConfigs
      uses the same periodicity and offset [2SCells (CQ1)+2SCells (CQI)] =4 cells
    - PSCell (CQI +SR) + 1 SCell CQI is multiplexed into a Report_#1 = PSCell + SCell2 (Resource0=9)
    - Remaining 2 SCells CQI are multiplexed into a Report_#2
    - Remaining 2 SCells CQI are multiplexed into a Report_#3
    - Remaining 2 SCells CQI are multiplexed into a Report_#4
    - After first SNodeModification the csi-ReportConfig for non_BM (reportConfigId : 2)
      is added to the multiplexed report in the CSI-Process #1 and CSI-Process #2 and Report_#1
    :param pcap_file: path to pcap file
    """
    xnap_rrc_snode_add, xnap_rrc_snode_mod = get_xnap_rrc_snode_add_snode_mod_packets(pcap_file)
    verify_different_pucch_mux_resource_is_used_in_report_configs(xnap_rrc_snode_add, xnap_rrc_snode_mod)
    verify_csi_report_config_ids(xnap_rrc_snode_add, xnap_rrc_snode_mod)
    verify_elements_from_two_prcccesses_are_different(xnap_rrc_snode_add)

    verify_pucch_code_rate(xnap_rrc_snode_add, '1')
    verify_four_csi_groups_pscell_bm_one_scell_in_first(xnap_rrc_snode_add)
    verify_BM_report_with_separate_non_multiplexed_PUCCH_resource(xnap_rrc_snode_add, xnap_rrc_snode_mod)


# CB008490_ET_LD_alt6
def get_xnap_rrc_snode_add_snode_mod_packets(pcap_file: str) -> tuple[PcapPacket, PcapPacket]:
    """Function returns 2 PCAP packets with RRC Reconfiguration containing NDRC Setup and NRDC SCG Modification
    :param pcap_file: path to pcap file
    :return: two RRC Reconfiguration messages with SCG configuration
    """
    pc = pcap_checker()
    rrc_snode_config_packets = pc.get_packets(pcap_file=pcap_file,
                                              display_filter='xnap',
                                              awaited_message=rrc.rrc_reconfig_snode_add_mod)
    try:
        xnap_rrc_snode_add = rrc_snode_config_packets[0]
        xnap_rrc_snode_mod = rrc_snode_config_packets[1]
        return xnap_rrc_snode_add, xnap_rrc_snode_mod
    except ValueError:
        logging.error("PCAP does not contain two RRC Reconfiguration messages with SCG Configuration")


# CB008490_ET_LD_alt6
def verify_different_pucch_mux_resource_is_used_in_report_configs(xnap_rrc_snode_add: PcapPacket,
                                                                  xnap_rrc_snode_mod: PcapPacket) -> None:
    """Verifies that PUCCH Resource ID selected for Multiplexing is used for all CSI Report Configs but not the same
    for CB008490-LD-alt6
    Two CSI process -> all cells uses same PUCCH Resource ID selected for MUX

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    :raises: VerificationError
    """
    pucch_mux_res_id = "//nr-rrc.multi_CSI_PUCCH_ResourceList//nr-rrc.PUCCH_ResourceId"
    pucch_mux_res_id_value = get_and_log_field_value(xnap_rrc_snode_add, pucch_mux_res_id)[0]

    csi_report_pucch_res = "//nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.pucch_Resource"
    csi_report_pucch_res_values_list = get_and_log_field_value(xnap_rrc_snode_add, csi_report_pucch_res)
    snode_mod_csi_report_pucch_res_values_list = get_and_log_field_value(xnap_rrc_snode_mod, csi_report_pucch_res)
    msg = f'PUCCH MUX Resource ID slected for MUX: {pucch_mux_res_id_value} ' \
          f'should be used for all SCG reportConfigs: {csi_report_pucch_res_values_list}'
    logging.info(msg)
    if not list_contains_same_values(csi_report_pucch_res_values_list, pucch_mux_res_id_value, 8):
        raise VerificationError(msg)

    msg = f'CSI Report Res has value equal 10 in SnodeAdditionAcknowledge: {csi_report_pucch_res_values_list} ' \
          f'CSI Report Res should be used with different value e.g == 12: {snode_mod_csi_report_pucch_res_values_list}'
    if not snode_mod_csi_report_pucch_res_values_list[0] != csi_report_pucch_res_values_list[0]:
        raise VerificationError(msg)


# CB008490_ET_LD_alt6
@keyword()
def verify_elements_from_two_prcccesses_are_different(xnap_rrc_snode_add: PcapPacket) -> None:
    """Verifies If Two CSI Process is used for NRDC SCG
    Two CSI Process -> PSCell + 3 SCells are using the same periodicityOffset vales and remaining 4 SCells are using
    the same but different compared to the first CSI Process
    :param xnap_rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """

    csi_res_periodicity_scells = "//xnap//nr-rrc.secondaryCellGroup//nr-rrc.CellGroupConfig_element//" \
                                 "nr-rrc.sCellToAddModList//" \
                                 "nr-rrc.sCellConfigDedicated_element//nr-rrc.csi_MeasConfig//" \
                                 "nr-rrc.nzp_CSI_RS_ResourceToAddModList//nr-rrc.periodicityAndOffset"
    csi_res_periodicity_pscell = "//xnap//nr-rrc.secondaryCellGroup//nr-rrc.spCellConfig_element//" \
                                 "nr-rrc.spCellConfigDedicated_element//nr-rrc.csi_MeasConfig//" \
                                 "nr-rrc.nzp_CSI_RS_ResourceToAddModList//nr-rrc.periodicityAndOffset"
    csi_res_offset_scells = csi_res_periodicity_scells + "/nr-rrc.slots320"
    csi_res_offset_pscells = csi_res_periodicity_pscell + "/nr-rrc.slots320"
    csi_res_periodicity_values_scells = get_and_log_field_value(xnap_rrc_snode_add, csi_res_offset_scells)
    csi_res_periodicity_values_pscell = get_and_log_field_value(xnap_rrc_snode_add, csi_res_offset_pscells)
    msg = f'csi_res_periodicity_values_scells {csi_res_periodicity_values_scells}'
    logging.info(msg)
    msg = f'csi_res_periodicity_values_pscell {csi_res_periodicity_values_pscell}'
    logging.info(msg)
    msg = 'periodicityAndOffset of CSI-RS Resources are not the same for all SCG cells'
    logging.info(msg)

    scells_lists = [int(value) for value in csi_res_periodicity_values_scells]
    msg = f'{scells_lists}'
    logging.info(msg)
    unique_values = list(set(scells_lists))  # 1, 171
    msg = f'{unique_values}'
    logging.info(msg)
    scell_first_value = unique_values[0]
    scell_second_value = unique_values[1]
    first_value_amount = scells_lists.count(scell_first_value)  # 3
    second_value_amount = scells_lists.count(scell_second_value)  # 4
    msg = f'{first_value_amount}'
    logging.info(msg)
    msg = f'{second_value_amount}'
    logging.info(msg)
    pscell_value = int(csi_res_periodicity_values_pscell[0])
    msg = f'{pscell_value}'
    logging.info(msg)
    first_list_of_values = [value for value in scells_lists if value == scell_first_value]
    second_list_of_values = [value for value in scells_lists if value == scell_second_value]
    msg = f'{first_list_of_values}'
    logging.info(msg)
    msg = f'{second_list_of_values}'
    logging.info(msg)
    # mniejsza liczba zawiera elementy równe 1 i koresponduje do wartosci pscellki
    smaller_list = min(first_list_of_values, second_list_of_values)
    msg = f'{smaller_list}'
    logging.info(msg)
    assert pscell_value == smaller_list[0]


# CB008490_ET_LD_alt6
def verify_four_csi_groups_pscell_bm_one_scell_in_first(xnap_rrc_snode_add: PcapPacket) -> None:
    """Verifies if four CSI Report Groups are used for NRDC SCG cells.
    4 CSI Groups -> reportSlotConfig values in to groups: 2xX 2xY 2xW 2xZ, X for PSCell (first in table) and one SCell
    - [PSCell (CQI)+1SCell (CQI)]
    - [2SCells (CQI)],
    - [2SCells (CQ1)]
    - [2SCells (CQI)]
    :param xnap_rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param xnap_rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    """
    csi_report_periodicity_all_groups = "//xnap.SNodeAdditionRequestAcknowledge_element//nr-rrc.secondaryCellGroup//" \
                                        "nr-rrc.spCellConfig_element//nr-rrc.spCellConfigDedicated_element//" \
                                        "nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//" \
                                        "nr-rrc.reportSlotConfig//nr-rrc.slots320"

    csi_report_periodicity_values = get_and_log_field_value(xnap_rrc_snode_add, csi_report_periodicity_all_groups)
    msg = f'csi_report_periodicity_values {csi_report_periodicity_values}'
    logging.info(msg)
    msg = f'Verifying if CSI Report Config offset values are divided in 4 groups'
    logging.info(msg)

    report_lists = [int(value) for value in csi_report_periodicity_values]
    msg = f'{report_lists}'
    logging.info(msg)
    unique_values = list(set(report_lists))     # 9, 169, 179, 183
    msg = f'{unique_values}'
    logging.info(msg)
    report_first_value = unique_values[0]
    report_second_value = unique_values[1]
    report_third_value = unique_values[2]
    report_fourth_value = unique_values[3]
    first_value_amount = report_lists.count(report_first_value)     # 9
    second_value_amount = report_lists.count(report_second_value)   # 169
    third_value_amount = report_lists.count(report_third_value)     # 179
    fourth_value_amount = report_lists.count(report_fourth_value)   # 183
    msg = f'{first_value_amount}'
    logging.info(msg)
    msg = f'{second_value_amount}'
    logging.info(msg)
    msg = f'{third_value_amount}'
    logging.info(msg)
    msg = f'{fourth_value_amount}'
    logging.info(msg)


# CB008490_ET_LD_alt6
def verify_BM_report_with_separate_non_multiplexed_PUCCH_resource(xnap_rrc_snode_add: PcapPacket,
                                                                  xnap_rrc_snode_mod: PcapPacket) -> None:
    """Verifies if BM report:
    SNodeAddition: BM report is configured with non-multiplexing PUCCH resource
    SNodeModification: BM report is configured with a separate non-multiplexed PUCCH resource in the CSI-Process #1
    :param xnap_rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param xnap_rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    """
    bm_report_snode_add = "//xnap.SNodeAdditionRequestAcknowledge_element//nr-rrc.secondaryCellGroup//" \
                          "nr-rrc.CellGroupConfig_element//nr-rrc.spCellConfigDedicated_element//" \
                          "nr-rrc.uplinkBWP_ToAddModList//nr-rrc.BWP_Uplink_element//" \
                          "nr-rrc.multi_CSI_PUCCH_ResourceList//nr-rrc.PUCCH_ResourceId"
    bm_report_snode_mod = "//xnap.SNodeModificationRequired_element//nr-rrc.secondaryCellGroup//" \
                          "nr-rrc.spCellConfig_element//nr-rrc.spCellConfigDedicated_element//" \
                          "nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.pucch_Resource"

    bm_report_snode_values_add = get_and_log_field_value(xnap_rrc_snode_add, bm_report_snode_add)
    bm_report_snode_values_mod = get_and_log_field_value(xnap_rrc_snode_mod, bm_report_snode_mod)
    msg = f'Veryfing if value of configured BM report has different BM report value: \n' \
          f'{bm_report_snode_values_add} has configured BM report with non-multiplexing PUCCH resource \n' \
          f'{bm_report_snode_values_mod} has configured BM as above but different value\n'
    logging.info(msg)
    if not bm_report_snode_values_add.count(bm_report_snode_values_add[0]) == 1:
        raise VerificationError(msg)
    if not bm_report_snode_values_add[0] != bm_report_snode_values_mod[0]:
        raise VerificationError


# CB008490_ET_LD_alt7
@keyword()
def verify_pucch_mux_two_process_three_report_groups(pcap_file: str) -> None:
    """KW verifies that
    - Two CSI-Process are sufficient for multiplexing, which means that there are two groups of csi-ReportConfigs cells
      and these three groups of cells use three different periodicities and

    - First CSI-Process is sufficient for multiplexing what means that all the same csi-ReportConfigs
      uses the same periodicity and offset
      [configured BM report multiplexing]+[PSCell (CQI)+1SCell (CQI)]+[3SCell (CQI)] =5cells
    - Second CSI-Process is sufficient for multiplexing what means that all the same csi-ReportConfigs
      uses the same periodicity and offset [3SCells (CQ1) =3 cells
    - PSCell (CQI +SR) + 1 SCell CQI is multiplexed into a Report_#1 = PSCell + SCell1 +3xScell(Resource0=9)
    - Remaining 3 SCells CQI are multiplexed into a Report_#2
    - Remaining 3 SCells CQI are multiplexed into a Report_#3
    - After first SNodeModification the csi-ReportConfig for nBM (reportConfigId : 2)
      is added to the multiplexed report in the CSI-Process #1 and CSI-Process #2 and Report_#1
    :param pcap_file: path to pcap file
    """
    xnap_rrc_snode_add, xnap_rrc_snode_mod = get_xnap_rrc_snode_add_snode_mod_packets(pcap_file)
    verify_pucch_mux_resource_is_used_for_all_report_configs_ld(xnap_rrc_snode_add, xnap_rrc_snode_mod)
    verify_csi_report_config_ids(xnap_rrc_snode_add, xnap_rrc_snode_mod)
    verify_elements_from_two_prcccesses_are_different(xnap_rrc_snode_add)

    verify_pucch_code_rate(xnap_rrc_snode_add, '1')
    verify_three_csi_groups_pscell_bm_one_scell_in_first(xnap_rrc_snode_add)
    verify_the_same_BM_report_multiplexed_PUCCH_resource(xnap_rrc_snode_add, xnap_rrc_snode_mod)


# CB008490_ET_LD_alt7
def verify_pucch_mux_resource_is_used_for_all_report_configs_ld(xnap_rrc_snode_add: PcapPacket,
                                                                xnap_rrc_snode_mod: PcapPacket) -> None:
    """Verifies that PUCCH Resource ID selected for Multiplexing is used for all CSI Report Configs
    Single CSI process -> all cells uses same PUCCH Resource ID selected for MUX

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    :raises: VerificationError
    """
    pucch_mux_res_id = "//nr-rrc.multi_CSI_PUCCH_ResourceList//nr-rrc.PUCCH_ResourceId"
    pucch_mux_res_id_value = get_and_log_field_value(xnap_rrc_snode_add, pucch_mux_res_id)[0]

    csi_report_pucch_res = "//nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.pucch_Resource"
    csi_report_pucch_res_values_list = get_and_log_field_value(xnap_rrc_snode_add, csi_report_pucch_res)
    snode_mod_csi_report_pucch_res_values_list = get_and_log_field_value(xnap_rrc_snode_mod, csi_report_pucch_res)
    msg = f'PUCCH MUX Resource ID slected for MUX: {pucch_mux_res_id_value} ' \
          f'should be used for all SCG reportConfigs: {csi_report_pucch_res_values_list}, ' \
          f'{snode_mod_csi_report_pucch_res_values_list}'
    logging.info(msg)
    if not list_contains_same_values(csi_report_pucch_res_values_list, pucch_mux_res_id_value, 8):
        raise VerificationError(msg)
    if not list_contains_same_values(snode_mod_csi_report_pucch_res_values_list, pucch_mux_res_id_value, 1):
        raise VerificationError(msg)


# CB008490_ET_LD_alt7
def verify_three_csi_groups_pscell_bm_one_scell_in_first(xnap_rrc_snode_add: PcapPacket) -> None:
    """Verifies if four CSI Report Groups are used for NRDC SCG cells.
    3 CSI Groups -> reportSlotConfig values in to groups: 2xX 3xY 3xW, X for PSCell (first in table) and one SCell
    - [PSCell (CQI)+1SCell (CQI)]
    - [3SCells (CQI)],
    - [3SCells (CQ1)]

    :param xnap_rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param xnap_rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    """
    csi_report_periodicity_all_groups = "//xnap.SNodeAdditionRequestAcknowledge_element//nr-rrc.secondaryCellGroup//" \
                                        "nr-rrc.spCellConfig_element//nr-rrc.spCellConfigDedicated_element//" \
                                        "nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//" \
                                        "nr-rrc.reportSlotConfig//nr-rrc.slots320"

    csi_report_periodicity_values = get_and_log_field_value(xnap_rrc_snode_add, csi_report_periodicity_all_groups)
    BuiltIn().log("csi_report_periodicity_values {}".format(csi_report_periodicity_values), console=True)
    msg = 'Verifying if CSI Report Config offset values are divided in 4 groups'
    logging.info(msg)

    report_lists = [int(value) for value in csi_report_periodicity_values]
    msg = f'{report_lists}'
    logging.info(msg)
    unique_values = list(set(report_lists))     # 9, 169, 179, 183
    msg = f'{unique_values}'
    logging.info(msg)
    report_first_value = unique_values[0]
    report_second_value = unique_values[1]
    report_third_value = unique_values[2]
    first_value_amount = report_lists.count(report_first_value)     # 9
    second_value_amount = report_lists.count(report_second_value)   # 169
    third_value_amount = report_lists.count(report_third_value)     # 179
    msg = f'{first_value_amount}'
    logging.info(msg)
    msg = f'{second_value_amount}'
    logging.info(msg)
    msg = f'{third_value_amount}'
    logging.info(msg)


# CB008490_ET_LD_alt7
def verify_the_same_BM_report_multiplexed_PUCCH_resource(xnap_rrc_snode_add: PcapPacket,
                                                         xnap_rrc_snode_mod: PcapPacket) -> None:
    """Verifies if BM reports are the same:
    SNodeAddition: BM report is configured with multiplexing PUCCH resource
    SNodeModification: BM report is configured with multiplexed PUCCH resource in the CSI-Process #1
    :param xnap_rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param xnap_rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    """
    bm_report_snode_add = "//xnap.SNodeAdditionRequestAcknowledge_element//nr-rrc.secondaryCellGroup//" \
                          "nr-rrc.CellGroupConfig_element//nr-rrc.spCellConfigDedicated_element//" \
                          "nr-rrc.uplinkBWP_ToAddModList//nr-rrc.BWP_Uplink_element//" \
                          "nr-rrc.multi_CSI_PUCCH_ResourceList//nr-rrc.PUCCH_ResourceId"
    bm_report_snode_mod = "//xnap.SNodeModificationRequired_element//nr-rrc.secondaryCellGroup//" \
                          "nr-rrc.spCellConfig_element//nr-rrc.spCellConfigDedicated_element//" \
                          "nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.pucch_Resource"

    bm_report_snode_values_add = get_and_log_field_value(xnap_rrc_snode_add, bm_report_snode_add)
    bm_report_snode_values_mod = get_and_log_field_value(xnap_rrc_snode_mod, bm_report_snode_mod)
    msg = f'Veryfing if value of configured BM report has different BM report value: \n' \
          f'{bm_report_snode_values_add} has configured BM report with non-multiplexing PUCCH resource \n' \
          f'{bm_report_snode_values_mod} has configured BM as above but different value\n'
    logging.info(msg)
    if not bm_report_snode_values_add.count(bm_report_snode_values_add[0]) == 1:
        raise VerificationError(msg)
    if not bm_report_snode_values_add[0] == bm_report_snode_values_mod[0]:
        raise VerificationError


# CB008490_ET_LD_alt8
def verify_single_csi_process_and_report_group_from_xnap(pcap_file: str) -> None:
    """KW verifies that
    - Single CSI-Process is sufficient for multiplexing what means that all csi-ReportConfigs
      uses the same periodicity and offset
    - PSCell (CQI +SR) + 7 SCell CQI is multiplexed into a Report_#1
    - After first SNodeModification the csi-ReportConfig for BM (reportConfigId : 2)
      is added to the multiplexed report in the CSI-Process #1 and Report_#1
    - PUCCH Max Code Rate is zeroDot35

    :param pcap_file: path to pcap file
    """
    xnap_rrc_snode_add, xnap_rrc_snode_mod = get_xnap_rrc_snode_add_snode_mod_packets(pcap_file)
    verify_pucch_mux_resource_is_used_for_all_report_configs(xnap_rrc_snode_add, xnap_rrc_snode_mod)
    verify_csi_report_config_ids(xnap_rrc_snode_add, xnap_rrc_snode_mod)
    verify_single_csi_process_is_used(xnap_rrc_snode_add)
    verify_pucch_code_rate(xnap_rrc_snode_add, '3')

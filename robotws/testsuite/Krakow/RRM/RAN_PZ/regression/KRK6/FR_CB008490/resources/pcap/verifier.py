"""
Keywords related to PCAP verification.

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""

import logging
import copy
from pprint import pformat
from typing import Any, List

from taf.analyzer.pcap.pcap_packet import PcapPacket
from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.parsers.pcap_checker import VerificationError, Checker, inspectors
from taf.rfrl.utilities.parsers.pcap_checker.utils import PACKET, PcapProvider
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.common import Misc
from . import pdml_xpath
from .msg import e1ap, f1ap, xnap, ngap, rrc
from .collecting import get_default_pcap_paths

_pcap_provider = PcapProvider()
pc = Checker(pcap_provider=_pcap_provider)


@log_as_robot_keyword
def verify_ngap_initial_context_setup(pcap_file: str | None = None,
                                      nrcell_id: str = '1',
                                      forbidden_msgs_check: bool = True) -> None:
    """Verifies NGAP messages content based on pcap file.
    KW checks if UE perform Registration on desired cell and if PDU Session was established successfully.

    :param pcap_file: path to pcap file
    :param nrcell_id: nr cell identity in DECIMAL
    :param forbidden_msgs_check: bool whether to check forbidden_messages
    """
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    hex_cell_id = Misc().get_nr_cell_id_in_hex(nr_cell_id=nrcell_id, hex_len=18)

    ngap.INITIAL_UE_MESSAGE_NRCELLID.verify_by = [inspectors.HasInspector('ngap.NRCellIdentity', hex_cell_id)]
    ng_ics_flow = [ngap.INITIAL_UE_MESSAGE_NRCELLID,
                   ngap.ICS_SETUP_REQ_PDU_SESSION,
                   ngap.ICS_SETUP_RESP_PDU_SESSION]

    forbidden_messages = [ngap.UE_CTX_REL_REQ] if forbidden_msgs_check else []
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='ngap',
                   awaited_messages=ng_ics_flow,
                   forbidden_messages=forbidden_messages)


@log_as_robot_keyword
def verify_nrdc_call_setup(pcap_file: str | None = None) -> None:
    """Verifies basic flow of NRDC call setup on XN interface

    :param pcap_file: path to pcap file
    """
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    snode_addition_flow = [xnap.SNODE_ADD_REQ_ALLOWED_BC,
                           xnap.SNODE_ADD_REQ_ACK,
                           xnap.XNU_ADDR_IND,
                           xnap.SN_STATUS_TRANSFER,
                           xnap.SNODE_RECONF_COMPLETE]

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='xnap',
                   awaited_messages=snode_addition_flow,
                   forbidden_messages=[xnap.SNODE_RELEASE_REQ])


@log_as_robot_keyword
def verify_mn_nrdc_with_8cc_fr2_call_setup(mn_pcap_file: str) -> None:
    """Verifies flow of NRDC call with 8CC on FR2 on MN gNB

    :param mn_pcap_file: path to pcap file
    """
    snode_addition_flow = [xnap.SNODE_ADD_REQ_ALLOWED_BC,
                           xnap.SNODE_ADD_REQ_ACK_8CC,
                           f1ap.UE_CTX_MOD_REQ_ALLOWEDBC_LISTMRDC,
                           f1ap.UE_CTX_MOD_RESP_BC_IDX_FS_IDX,
                           xnap.XNU_ADDR_IND,
                           xnap.SN_STATUS_TRANSFER,
                           xnap.SNODE_RECONF_COMPLETE]
    rrc_reconfig_flow_xn = [xnap.SNODE_ADD_REQ_ACK_8CC,
                            rrc.RRC_RECONFIG_8CC,
                            rrc.RRC_RECONFIG_COMPLETE,
                            xnap.SNODE_RECONF_COMPLETE]
    rrc_reconfig_flow_rrc = [xnap.SNODE_ADD_REQ_ACK_8CC,
                             rrc.RRC_RECONFIG_8CC,
                             rrc.RRC_RECONFIG_COMPLETE,
                             f1ap.UE_CTX_MOD_REQ_RRC_RECONFIG_COMPLETE_IND,
                             f1ap.UE_CTX_MOD_RESP]
    snode_addition_flow_pdu_session = [xnap.SNODE_ADD_REQ_ACK_8CC,
                                       e1ap.BEARER_MOD_REQ,
                                       e1ap.BEARER_MOD_RESP,
                                       ngap.PDU_SESSION_RES_MOD_IND,
                                       ngap.PDU_SESSION_RES_MOD_CONFIRM,
                                       e1ap.BEARER_MOD_REQ,
                                       e1ap.BEARER_MOD_RESP]

    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages=snode_addition_flow,
                   forbidden_messages=[xnap.SNODE_RELEASE_REQ])
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages=rrc_reconfig_flow_xn,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages=rrc_reconfig_flow_rrc,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or ngap or e1ap',
                   awaited_messages=snode_addition_flow_pdu_session,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_sn_nrdc_with_8cc_fr2_call_setup(sn_pcap_file: str) -> None:
    """Verifies flow of NRDC call with 8CC on FR2 on SN gNB

    :param sn_pcap_file: path to pcap file
    """
    xn_f1_flow = [xnap.SNODE_ADD_REQ_ALLOWED_BC,
                  f1ap.UE_CTX_SETUP_REQ_8CC,
                  f1ap.UE_CTX_SETUP_RESP,
                  xnap.SNODE_ADD_REQ_ACK_8CC,
                  xnap.XNU_ADDR_IND,
                  xnap.SN_STATUS_TRANSFER,
                  xnap.SNODE_RECONF_COMPLETE]

    xn_e1_flow = [xnap.SNODE_ADD_REQ_ALLOWED_BC,
                  e1ap.BEARER_SETUP_REQ,
                  e1ap.BEARER_SETUP_RESP,
                  e1ap.BEARER_MOD_REQ,
                  e1ap.BEARER_MOD_RESP,
                  e1ap.BEARER_CONTEXT_INACTIVITY_NOTIFICATION_PSCELLADD]

    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages=xn_f1_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='xnap or e1ap',
                   awaited_messages=xn_e1_flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_nrdc_with_8cc_fr2_call_setup(mn_pcap_file: str | None = None,
                                        sn_pcap_file: str | None = None) -> None:
    """Verifies flow of NRDC call establishment with 8CC on FR2 on MN and SN gNBs

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    """
    mn_pcap_file = get_default_pcap_paths()[0] if mn_pcap_file is None else mn_pcap_file
    sn_pcap_file = get_default_pcap_paths()[1] if sn_pcap_file is None else sn_pcap_file
    verify_mn_nrdc_with_8cc_fr2_call_setup(mn_pcap_file)
    verify_sn_nrdc_with_8cc_fr2_call_setup(sn_pcap_file)


@log_as_robot_keyword
def verify_nrdc_call_release_due_to_amf(mn_pcap_file: str | None = None,
                                        sn_pcap_file: str | None = None) -> None:
    """Verifies  flow of NRDC call release on MN and SN gNBs

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    """
    mn_pcap_file = get_default_pcap_paths()[0] if mn_pcap_file is None else mn_pcap_file
    sn_pcap_file = get_default_pcap_paths()[1] if sn_pcap_file is None else sn_pcap_file
    verify_mn_nrdc_call_release_due_to_amf(mn_pcap_file)
    verify_sn_nrdc_call_release_due_to_amf(sn_pcap_file)


@log_as_robot_keyword
def verify_mn_nrdc_call_release_due_to_amf(pcap_file: str) -> None:
    """Verifies ng_xn_release_flow of NRDC call release on MN gNB

    :param pcap_file: path to pcap file
    """
    ng_xn_release_flow = [ngap.UE_CTX_REL_REQ_NAS_DEREGISTER,
                          xnap.SNODE_REL_REQ_RADIO_NETWORK_NORMAL_RELEASE,
                          xnap.SNODE_REL_REQ_ACK,
                          xnap.UE_CTX_REL,
                          ngap.UE_CTX_RELEASE_COMPLETE]

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='ngap or xnap',
                   awaited_messages=ng_xn_release_flow,
                   forbidden_messages=[])

    verify_e1_f1_release_flow(pcap_file)


@log_as_robot_keyword
def verify_e1_f1_release_flow(pcap_file: str) -> None:
    """
    Verify F1AP and E1AP release flows.

    :param pcap_file: Path to PCAP file.
    :return: None
    """
    f1_release_flow = [f1ap.UE_CTX_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE,
                       f1ap.UE_CTX_REL_COMPLETE]

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='f1ap',
                   awaited_messages=f1_release_flow,
                   forbidden_messages=[])

    e1_release_flow = [e1ap.BEARER_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE,
                       e1ap.BEARER_REL_COMPLETE]

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='e1ap',
                   awaited_messages=e1_release_flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_sn_nrdc_call_release_due_to_amf(pcap_file: str) -> None:
    """Verifies flow of NRDC call release on SN gNB

    :param pcap_file: path to pcap file
    """
    snode_release_flow = [xnap.SNODE_REL_REQ_RADIO_NETWORK_NORMAL_RELEASE,
                          f1ap.UE_CTX_MOD_REQ_STOP,
                          xnap.SNODE_REL_REQ_ACK,
                          xnap.UE_CTX_REL,
                          f1ap.UE_CTX_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE]
    snode_release_flow_e1_flow = [xnap.SNODE_REL_REQ_RADIO_NETWORK_NORMAL_RELEASE,
                                  e1ap.BEARER_MOD_REQ_STOP,
                                  xnap.SNODE_REL_REQ_ACK,
                                  xnap.UE_CTX_REL,
                                  e1ap.BEARER_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE]
    f1_context_mod_and_release_flow = [f1ap.UE_CTX_MOD_REQ_STOP,
                                       f1ap.UE_CTX_MOD_RESP,
                                       f1ap.UE_CTX_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE,
                                       f1ap.UE_CTX_REL_COMPLETE]
    e1_bearer_mod_and_release_flow = [e1ap.BEARER_MOD_REQ_STOP,
                                      e1ap.BEARER_MOD_RESP,
                                      e1ap.BEARER_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE,
                                      e1ap.BEARER_REL_COMPLETE]

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages=snode_release_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='xnap or e1ap',
                   awaited_messages=snode_release_flow_e1_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='f1ap',
                   awaited_messages=f1_context_mod_and_release_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='e1ap',
                   awaited_messages=e1_bearer_mod_and_release_flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_nrdc_release_and_reestablishment(mn_pcap_file: str | None = None,
                                            sn_pcap_file: str | None = None) -> None:
    """
    Verifies flow of NRDC release and RRC Reestablishment on MN and SN gNBs

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    """
    mn_pcap_file = get_default_pcap_paths()[0] if mn_pcap_file is None else mn_pcap_file
    sn_pcap_file = get_default_pcap_paths()[1] if sn_pcap_file is None else sn_pcap_file
    verify_mn_nrdc_release_and_reestablishment(mn_pcap_file)
    verify_sn_nrdc_release_and_reestablishment(sn_pcap_file)


@log_as_robot_keyword
def verify_mn_nrdc_release_and_reestablishment(pcap_file: str) -> None:
    """Verifies flow of NRDC release and RRC Reestablishment on MN gNB

    :param pcap_file: path to pcap file
    """
    ng_xn_release_flow = [ngap.UE_CTX_REL_REQ_RELEASE_DUE_TO_CN_DETECTED_MOBILITY,
                          xnap.SNODE_RELEASE_REQ,
                          xnap.SNODE_REL_REQ_ACK]

    f1_release_flow = [f1ap.UE_CTX_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE,
                       f1ap.UE_CTX_REL_COMPLETE]

    e1_release_flow = [e1ap.BEARER_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE,
                       e1ap.BEARER_REL_COMPLETE]

    rrc_release_flow = [rrc.RRC_REESTABLISHMENT,
                        rrc.RRC_SETUP,
                        rrc.RRC_SETUP_COMPLETE]

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='ngap or xnap',
                   awaited_messages=ng_xn_release_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='f1ap',
                   awaited_messages=f1_release_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='e1ap',
                   awaited_messages=e1_release_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='nr-rrc',
                   awaited_messages=rrc_release_flow,
                   forbidden_messages=[])


def verify_sn_nrdc_release_and_reestablishment(pcap_file: str) -> None:
    """Verifies flow of NRDC release and RRC Reestablishment on SN gNB

    :param pcap_file: path to pcap file
    """
    ng_xn_release_flow = [xnap.SNODE_REL_REQ_RADIO_NETWORK_NORMAL_RELEASE,
                          xnap.SNODE_REL_REQ_ACK,
                          xnap.UE_CTX_REL,
                          xnap.SNODE_ADD_REQ_ALLOWED_BC,
                          xnap.SNODE_ADD_REQ_ACK,
                          xnap.XNU_ADDR_IND,
                          xnap.SN_STATUS_TRANSFER,
                          xnap.SNODE_RECONF_COMPLETE]

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='ngap or xnap',
                   awaited_messages=ng_xn_release_flow,
                   forbidden_messages=[])

    verify_e1_f1_release_flow(pcap_file)


@log_as_robot_keyword
def verify_sn_initiated_partial_reset(mn_pcap_file: str | None = None,
                                      sn_pcap_file: str | None = None) -> None:
    """Verifies flow SN initiated Partial Reset on MN and SN gNBs

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    """
    mn_pcap_file = get_default_pcap_paths()[0] if mn_pcap_file is None else mn_pcap_file
    sn_pcap_file = get_default_pcap_paths()[1] if sn_pcap_file is None else sn_pcap_file
    verify_mn_part_of_sn_initiated_partial_reset(mn_pcap_file)
    verify_sn_part_of_sn_initiated_partial_reset(sn_pcap_file)


@log_as_robot_keyword
def verify_mn_part_of_sn_initiated_partial_reset(mn_pcap_file: str) -> None:
    """Verifies flow of SN initiated Partial Reset on MN gNB

    :param mn_pcap_file: path to pcap file
    """
    main_reset_flow = [xnap.RESET_REQ_PARTIAL_MISC_OM_INTERVENTION,
                       xnap.RESET_RESP_PARTIAL_MISC_OM_INTERVENTION,
                       ngap.NG_RESET_RESP_PARTIAL_MISC_OM_INTERVENTION,
                       ngap.NG_RESET_ACK,
                       rrc.RRC_REESTABLISHMENT,
                       rrc.RRC_SETUP,
                       rrc.RRC_SETUP_COMPLETE]

    xn_e1_reset_flow = [xnap.RESET_REQ_PARTIAL_MISC_OM_INTERVENTION,
                        xnap.RESET_RESP_PARTIAL_MISC_OM_INTERVENTION,
                        e1ap.RESET_PARTIAL_TRANSPORT_UNSPECIFIED,
                        e1ap.RESET_ACK]

    xn_f1_reset_flow = [xnap.RESET_REQ_PARTIAL_MISC_OM_INTERVENTION,
                        xnap.RESET_RESP_PARTIAL_MISC_OM_INTERVENTION,
                        f1ap.RESET_PARTIAL_TRANSPORT_UNSPECIFIED,
                        f1ap.RESET_ACK]

    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or ngap or nr-rrc',
                   awaited_messages=main_reset_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or e1ap',
                   awaited_messages=xn_e1_reset_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap or f1ap',
                   awaited_messages=xn_f1_reset_flow,
                   forbidden_messages=[])
    verify_nrdc_call_setup(mn_pcap_file)


@log_as_robot_keyword
def verify_sn_part_of_sn_initiated_partial_reset(sn_pcap_file: str) -> None:
    """Verifies flow of SN initiated Partial Reset on MN gNB

    :param sn_pcap_file: path to pcap file
    """
    e1_reset_flow = [e1ap.RESET_PARTIAL_MISC_OM_INTERVENTION,
                     e1ap.RESET_ACK]

    xn_reset_flow = [xnap.RESET_REQ_PARTIAL_MISC_OM_INTERVENTION,
                     xnap.RESET_RESP_PARTIAL_MISC_OM_INTERVENTION]

    f1_reset_flow = [f1ap.RESET_PARTIAL_MISC_OM_INTERVENTION,
                     f1ap.RESET_ACK]

    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='e1ap',
                   awaited_messages=e1_reset_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='xnap',
                   awaited_messages=xn_reset_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='f1ap',
                   awaited_messages=f1_reset_flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_sn_terminated_pdu_session_release(mn_pcap_file: str | None = None,
                                             sn_pcap_file: str | None = None) -> None:
    """Verifies flow SN Terminated PDU Session release on MN and SN gNBs

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    """
    mn_pcap_file = get_default_pcap_paths()[0] if mn_pcap_file is None else mn_pcap_file
    sn_pcap_file = get_default_pcap_paths()[1] if sn_pcap_file is None else sn_pcap_file
    verify_on_mn_gnb_sn_terminated_pdu_session_release(mn_pcap_file)
    verify_on_sn_gnb_sn_terminated_pdu_session_release(sn_pcap_file)


@log_as_robot_keyword
def verify_on_mn_gnb_sn_terminated_pdu_session_release(mn_pcap_file: str) -> None:
    """Verifies flow SN Terminated PDU Session release on MN gNB

    :param mn_pcap_file: path to pcap file
    """
    ng_flow = [ngap.PDU_SESSION_RES_REL_COMMAND,
               ngap.PDU_SESSION_RES_REL_RESPONSE]

    xn_flow = [xnap.SNODE_RELEASE_REQ,
               xnap.SNODE_REL_REQ_ACK,
               xnap.UE_CTX_REL]

    e1_flow = [e1ap.BEARER_MOD_REQ_RELEASE,
               e1ap.BEARER_MOD_RESP]

    f1_flow = [f1ap.UE_CTX_MOD_REQ_SCG_RELEASE,
               f1ap.UE_CTX_MOD_RESP_DUTOCURRCINFO,
               rrc.RRC_RECONFIG_SCG_RELEASE,
               rrc.RRC_RECONFIG_COMPLETE,
               f1ap.UE_CTX_MOD_REQ_RRC_RECONFIG_COMPLETE_IND,
               f1ap.UE_CTX_MOD_RESP,
               f1ap.UE_CTX_MOD_REQ_DU_CONFIG_QUERY,
               f1ap.UE_CTX_MOD_RESP_DUTOCURRCINFO]

    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='ngap',
                   awaited_messages=ng_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='xnap',
                   awaited_messages=xn_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='e1ap',
                   awaited_messages=e1_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=mn_pcap_file,
                   display_filter='f1ap',
                   awaited_messages=f1_flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_on_sn_gnb_sn_terminated_pdu_session_release(sn_pcap_file: str) -> None:
    """Verifies flow SN Terminated PDU Session release on SN gNB

    :param sn_pcap_file: path to pcap file
    """
    xn_flow = [xnap.SNODE_RELEASE_REQ,
               xnap.SNODE_REL_REQ_ACK,
               xnap.UE_CTX_REL]

    e1_flow = [e1ap.BEARER_MOD_REQ_STOP,
               e1ap.BEARER_MOD_RESP,
               e1ap.BEARER_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE,
               e1ap.BEARER_REL_COMPLETE]

    f1_flow = [f1ap.UE_CTX_MOD_REQ_STOP,
               f1ap.UE_CTX_MOD_RESP,
               f1ap.UE_CTX_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE,
               f1ap.UE_CTX_REL_COMPLETE]

    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='xnap',
                   awaited_messages=xn_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='e1ap',
                   awaited_messages=e1_flow,
                   forbidden_messages=[])
    pc.expect_flow(pcap_file=sn_pcap_file,
                   display_filter='f1ap',
                   awaited_messages=f1_flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_that_power_saving_bwp_was_configured_in_rrc(pcap_file: str | None = None) -> None:
    """Verifies RRCReconfiguration for PS BWP configuration with given bandwidth

    :param pcap_file: path to pcap file
    """
    logger.log_info_to_console("Verifying NR-RRC for PS BWP Configuration")
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file

    rrc.RRC_RECONFIG_PASSES.verify_by = [inspectors.PassesInspector(verify_mcg_ps_bwp_is_20mhz)]
    rrc_flow = [rrc.UE_CAPABILITY_INFO_PS_BWP,
                rrc.RRC_RECONFIG_PASSES,
                rrc.RRC_RECONFIG_COMPLETE]

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='f1ap',
                   awaited_messages=rrc_flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_small_and_large_bwp_was_configured_in_rrc(pcap_file: str | None = None) -> None:
    """Verifies RRCSetup and RRCReconfiguration for Small and Large BWP configuration

    :param pcap_file: path to pcap file
    """
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    rrc.RRC_SETUP_PASSES.verify_by = [inspectors.PassesInspector(verify_mcg_bwp_is_20mhz)]
    rrc.RRC_RECONFIG_PASSES.verify_by = [inspectors.PassesInspector(verify_mcg_bwp_is_100mhz)]
    rrc_100mhz = copy.deepcopy(rrc.RRC_RECONFIG_PASSES)
    rrc.RRC_RECONFIG_PASSES.verify_by = [inspectors.PassesInspector(verify_mcg_bwp_was_not_changed)]
    rrc_no_change = rrc.RRC_RECONFIG_PASSES
    rrc_flow = [rrc.RRC_SETUP_PASSES,
                rrc.UE_CAPABILITY_INFO,
                rrc_100mhz,
                xnap.SNODE_ADD_REQ_ACK,
                rrc_no_change,
                rrc.RRC_RECONFIG_COMPLETE]

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='f1ap or xnap',
                   awaited_messages=rrc_flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_mcg_bwp_was_not_changed(packet: PcapPacket) -> None:
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


@log_as_robot_keyword
def verify_mcg_bwp_is_100mhz(packet: PcapPacket) -> None:
    """KW checks if nr-rrc.locationAndBandwidth value represents 100 MHz Dedicated BWP

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :return: None
    """
    loc_and_bw_100mhz = ['1099']
    bwp_id_values = ['1']
    verify_mcg_bwp(packet, loc_and_bw_100mhz, bwp_id_values)


@log_as_robot_keyword
def verify_mcg_bwp_is_20mhz(packet: PcapPacket) -> None:
    """KW checks if nr-rrc.locationAndBandwidth value represents 20 MHz Dedicated BWP

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :return: None
    """
    loc_and_bw_20mhz = ['13750']
    bwp_id_values = ['1']
    verify_mcg_bwp(packet, loc_and_bw_20mhz, bwp_id_values)


@log_as_robot_keyword
def verify_mcg_ps_bwp_is_20mhz(packet: PcapPacket) -> None:
    """ KW checks if nr-rrc.locationAndBandwidth value represents 20 MHz PS BWP

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :return: None
    """

    loc_and_bw_20mhz = ['13750']
    bwp_id_values = ['1', '2']
    verify_mcg_bwp(packet, loc_and_bw_20mhz, bwp_id_values)


@log_as_robot_keyword
def verify_mcg_bwp(packet: PcapPacket,
                   loc_and_bw_value: List[str],
                   bwp_id_values: List[str]) -> None:
    """KW checks values for nr-rrc.locationAndBandwidth field. Intention is to pass PCAP packet with
    RRC Reconfiguration where bwp_Id = 1 will be checked.


    :param packet: RRC Reconfiguration where UE gets BWPs configuration
    :param loc_and_bw_value: list of strings that is expected when checking PCAP packet for nr-rrc.locationAndBandwidth
    :param bwp_id_values:  list of strings that is expected when checking PCAP packet for nr-rrc.bwp_Id
    """

    mcg = '//nr-rrc.masterCellGroup'
    first_active_dl_bwp = '//nr-rrc.firstActiveDownlinkBWP_Id'
    first_active_ul_bwp = '//nr-rrc.firstActiveUplinkBWP_Id'
    dl_bwp_add_mod = '//nr-rrc.downlinkBWP_ToAddModList//nr-rrc.BWP_Downlink_element'
    ul_bwp_add_mod = '//nr-rrc.uplinkBWP_ToAddModList//nr-rrc.BWP_Uplink_element'
    bwp_id = '/nr-rrc.bwp_Id'
    loc_and_bw = '//nr-rrc.locationAndBandwidth'
    first_active_bwp_id_values = ['1']
    verify_xpath_field_for_values(packet=packet, xpath=mcg + dl_bwp_add_mod + loc_and_bw,
                                  values=loc_and_bw_value)
    verify_xpath_field_for_values(packet=packet, xpath=mcg + ul_bwp_add_mod + loc_and_bw,
                                  values=loc_and_bw_value)
    verify_xpath_field_for_values(packet=packet, xpath=mcg + dl_bwp_add_mod + bwp_id,
                                  values=bwp_id_values)
    verify_xpath_field_for_values(packet=packet, xpath=mcg + ul_bwp_add_mod + bwp_id,
                                  values=bwp_id_values)
    verify_xpath_field_for_values(packet=packet, xpath=mcg + first_active_dl_bwp,
                                  values=first_active_bwp_id_values)
    verify_xpath_field_for_values(packet=packet, xpath=mcg + first_active_ul_bwp,
                                  values=first_active_bwp_id_values)


@log_as_robot_keyword
def verify_ue_activity_resumption(mn_pcap_file: str | None = None,
                                  sn_pcap_file: str | None = None) -> None:
    """Verifies flow UE activity resumption during NRDC call

    :param mn_pcap_file: path to pcap file
    :param sn_pcap_file: path to pcap file
    :return: None
    """
    mn_pcap_file = get_default_pcap_paths()[0] if mn_pcap_file is None else mn_pcap_file
    sn_pcap_file = get_default_pcap_paths()[1] if sn_pcap_file is None else sn_pcap_file
    verify_on_mn_ue_activity_resumption(mn_pcap_file)
    verify_on_sn_ue_activity_resumption(sn_pcap_file)


@log_as_robot_keyword
def verify_on_mn_ue_activity_resumption(pcap_file: str) -> None:
    """Verifies low UE activity resumption on MN during NRDC call

    :param pcap_file: path to pcap file
    """
    flow = [xnap.ACTIVITY_NOTIFICATION_INACTIVE,
            xnap.ACTIVITY_NOTIFICATION_REACTIVATED,
            xnap.ACTIVITY_NOTIFICATION_INACTIVE,
            xnap.SNODE_RELEASE_REQ,
            xnap.SNODE_REL_REQ_ACK,
            xnap.UE_CTX_REL]

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='xnap',
                   awaited_messages=flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_on_sn_ue_activity_resumption(pcap_file: str) -> None:
    """Verifies low UE activity resumption on SN during NRDC call

    :param pcap_file: path to pcap file
    """
    flow = [e1ap.BEARER_CONTEXT_INACTIVITY_NOTIFICATION_NOT_ACTIVE,
            xnap.ACTIVITY_NOTIFICATION_INACTIVE,
            e1ap.BEARER_CONTEXT_INACTIVITY_NOTIFICATION_ACTIVE,
            xnap.ACTIVITY_NOTIFICATION_REACTIVATED,
            e1ap.BEARER_CONTEXT_INACTIVITY_NOTIFICATION_NOT_ACTIVE,
            xnap.ACTIVITY_NOTIFICATION_INACTIVE,
            xnap.SNODE_RELEASE_REQ,
            xnap.SNODE_REL_REQ_ACK,
            xnap.UE_CTX_REL]

    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='xnap or e1ap',
                   awaited_messages=flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_totalnumberportssimultaneousnzp_csi_rs_percc_ge_4(pcap_file: str | None = None) -> None:
    """KW checks that UE Capabilities fr1_fr2_Add_UE_NR_Capabilities_element ->
    totalNumberPortsSimultaneousNZP_CSI_RS_PerCC is grater or equal 4 in PCAP packet

    :param pcap_file: path to pcap file
    """
    logger.log_info_to_console(
        "Verify UE Capabilities for fr1-fr2-Add-UE-NR-Capabilities -> totalNumberPortsSimultaneousNZP_CSI_RS_PerCC")
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    total_port = '//nr-rrc.fr1_fr2_Add_UE_NR_Capabilities_element//nr-rrc.totalNumberPortsSimultaneousNZP_CSI_RS_PerCC'
    packet = pc.get_packets(pcap_file=pcap_file,
                            display_filter='f1ap',
                            awaited_message=rrc.UE_CAPABILITY_INFO)[0]

    verify_xpath_value_is_greater_or_equal(packet=packet,
                                           xpath=total_port,
                                           value=4)


@log_as_robot_keyword
def verify_handling_of_the_ue_capability_pdcch_blind_detection_ie_in_the_scg(pcap_file: str | None = None) -> None:
    """Verifies PCAP file that in UE Capabilities
       pdcch-BlindDetectionCA >= 4
       pdcch-BlindDetectionNRDC is present
    in RRC Reconfiguration/ XnAP Snode Addition Request Acknowledge with NRDC setup
       pdcch-BlindDetection = pdcch-BlindDetectionCA - 1

    :param pcap_file: path to pcap file
    """
    logger.log_info_to_console("Verify Handling Of The UE Capability pdcch-BlindDetection IE In The SCG")
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    caps_packet = pc.get_packets(pcap_file=pcap_file,
                                 display_filter='f1ap',
                                 awaited_message=rrc.UE_CAPABILITY_INFO)[0]
    real_value = verify_xpath_value_is_greater_or_equal(packet=caps_packet,
                                                        value=4,
                                                        xpath='//nr-rrc.pdcch_BlindDetectionCA')
    caps_packet.get_field_value_by_name('nr-rrc.pdcch_BlindDetectionNRDC_element')

    nrdc_scg_setup_packet = pc.get_packets(pcap_file=pcap_file,
                                           display_filter='f1ap',
                                           awaited_message=rrc.RRC_RECONFIG_NRDC_SCG_CONFIG)[0]

    rrc_reconfig_pdcch_blind_xpath = '//nr-rrc.mrdc_SecondaryCellGroupConfig//nr-rrc.pdcch_BlindDetection/nr-rrc.setup'
    verify_xpath_field_for_values(packet=nrdc_scg_setup_packet,
                                  xpath=rrc_reconfig_pdcch_blind_xpath,
                                  values=[str(int(real_value) - 1)])


@log_as_robot_keyword
def verify_pucch_multiplexing_in_scg_single_csi_process_two_csi_report_groups(pcap_file: str | None = None) -> None:
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
    logger.log_info_to_console("Verify PUCCH Multiplexing in SCG - Single CSI Process, Two CSI Report Groups")
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    rrc_snode_add, rrc_snode_mod = get_rrc_snode_add_snode_mod_packets(pcap_file)
    verify_pucch_mux_resource_is_used_for_all_report_configs(rrc_snode_add, rrc_snode_mod)
    verify_csi_report_config_ids(rrc_snode_add, rrc_snode_mod)
    verify_single_csi_process_is_used(rrc_snode_add)

    verify_pucch_code_rate(rrc_snode_add, '2')
    verify_two_csi_groups_pscell_bm_one_scell_in_first(rrc_snode_add, rrc_snode_mod)


@log_as_robot_keyword
def verify_pucch_multiplexing_in_scg_single_csi_process_single_csi_report_group(pcap_file: str | None = None) -> None:
    """KW verifies that
    - Single CSI-Process is sufficient for multiplexing what means that all csi-ReportConfigs
      uses the same periodicity and offset
    - PSCell (CQI +SR) + 7 SCell CQI is multiplexed into a Report_#1
    - After first SNodeModification the csi-ReportConfig for BM (reportConfigId : 2)
      is added to the multiplexed report in the CSI-Process #1 and Report_#1
    - PUCCH Max Code Rate is zeroDot35

    :param pcap_file: path to pcap file
    """
    logger.log_info_to_console("Verify PUCCH Multiplexing in SCG - Single CSI Process, Single CSI Report Group")
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    rrc_snode_add, rrc_snode_mod = get_rrc_snode_add_snode_mod_packets(pcap_file)
    verify_pucch_mux_resource_is_used_for_all_report_configs(rrc_snode_add, rrc_snode_mod)
    verify_csi_report_config_ids(rrc_snode_add, rrc_snode_mod)
    verify_single_csi_process_is_used(rrc_snode_add)

    verify_pucch_code_rate(rrc_snode_add, '3')
    verify_one_csi_report_group_is_used(rrc_snode_add, rrc_snode_mod)


@log_as_robot_keyword
def verify_radiolinkmonitoringconfig_for_2_ies_in_scg(
        pcap_file: str | None = None) -> None:
    """KW verifies that for each FR2 cell
      BWP-DownlinkDedicated.radioLinkMonitoringConfig setup (1):
           failureDetectionResourcesToAddModList IE is not present
           beamFailureInstanceMaxCount: n3 (2)
           beamFailureDetectionTimer: pbfd2 (1)

    :param pcap_file: path to pcap file
    """
    logger.log_info_to_console(
        "Verify radioLinkMonitoringConfig for beamFailureInstanceMaxCount and beamFailureDetectionTimer in SCG")
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    rrc_snode_add = pc.get_packets(pcap_file=pcap_file,
                                   display_filter='f1ap',
                                   awaited_message=rrc.RRC_RECONFIG_NRDC_SCG_CONFIG)[0]

    verify_rlmc_setup_for_nrdc_scg(rrc_snode_add)

    fdrs_to_add = pdml_xpath.RLMC_PSCELL + "//nr-rrc.failureDetectionResourcesToAddModList"
    verify_xpath_field_is_empty(rrc_snode_add, fdrs_to_add)

    verify_beam_fail_inst_max_count(rrc_snode_add)
    verify_beam_fail_detect_timer(rrc_snode_add)


@log_as_robot_keyword
def verify_radiolinkmonitoringconfig_for_3_ies_in_scg(pcap_file: str | None = None) -> None:
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
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    rrc_snode_add = pc.get_packets(pcap_file=pcap_file,
                                   display_filter='f1ap',
                                   awaited_message=rrc.RRC_RECONFIG_NRDC_SCG_CONFIG)[0]

    verify_rlmc_setup_for_nrdc_scg(rrc_snode_add)
    verify_rlms_id(rrc_snode_add)
    verify_xpath_field_for_values(rrc_snode_add, pdml_xpath.FDRS_PURPOSE, ['2'])
    verify_detect_res(rrc_snode_add)
    verify_beam_fail_inst_max_count(rrc_snode_add)
    verify_beam_fail_detect_timer(rrc_snode_add)


@log_as_robot_keyword
def verify_rlmc_for_1_ie_in_scg(pcap_file: str | None = None) -> None:
    """KW verifies that for each FR2 cell
      BWP-DownlinkDedicated.radioLinkMonitoringConfig setup (1):
         failureDetectionResourcesToAddModList IE is present
              radioLinkMonitoringRS-Id: 0
              purpose: rlf (1)
              detectionResource ssb-Index (0):
                ssb-Index: <SSB_INDEX_ID>
         beamFailureInstanceMaxCount IE is NOT preset
         beamFailureDetectionTimer IE is NOT preset

    :param pcap_file: path to pcap file
    """
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    rrc_snode_add = pc.get_packets(pcap_file=pcap_file,
                                   display_filter='f1ap',
                                   awaited_message=rrc.RRC_RECONFIG_NRDC_SCG_CONFIG)[0]

    verify_rlmc_setup_for_nrdc_scg(rrc_snode_add)
    verify_rlms_id(rrc_snode_add)
    verify_xpath_field_for_values(rrc_snode_add, pdml_xpath.FDRS_PURPOSE, ['1'])
    verify_detect_res(rrc_snode_add)
    verify_xpath_field_is_empty(rrc_snode_add, pdml_xpath.BEAM_FAILURE_MAX_COUNT)
    verify_xpath_field_is_empty(rrc_snode_add, pdml_xpath.BEAM_FAILURE_DETECT)


@log_as_robot_keyword
def verify_detect_res(rrc_snode_add: PcapPacket) -> None:
    """Function verifies that NRDC PSCell have detectionResource: ssb-Index (0)
    and same ssb-Index: <SSB_INDEX_ID>

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    """

    detect_res = pdml_xpath.FDRS_ELEM + "/nr-rrc.detectionResource"
    verify_xpath_field_for_values(rrc_snode_add, detect_res, ['0'])


@log_as_robot_keyword
def verify_rlms_id(rrc_snode_add: PcapPacket) -> None:
    """Function verifies that NRDC PSCell have radioLinkMonitoringRS-Id: 0

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """

    verify_xpath_field_for_values(rrc_snode_add, pdml_xpath.FDRS_ID, ['0'])


@log_as_robot_keyword
def verify_beam_fail_detect_timer(rrc_snode_add: PcapPacket) -> None:
    """Function verifies that NRDC PSCell have beamFailureDetectionTimer: pbfd2 (1)

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    """

    verify_xpath_field_for_values(rrc_snode_add, pdml_xpath.BEAM_FAILURE_DETECT, ['1'])


@log_as_robot_keyword
def verify_beam_fail_inst_max_count(rrc_snode_add: PcapPacket) -> None:
    """Function verifies that NRDC PSCell have beamFailureInstanceMaxCount: n3 (2)

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    """

    verify_xpath_field_for_values(rrc_snode_add, pdml_xpath.BEAM_FAILURE_MAX_COUNT, ['2'])


@log_as_robot_keyword
def verify_rlmc_setup_for_nrdc_scg(rrc_snode_add: PcapPacket) -> None:
    """Function verifies if only PSCell have radioLinkMonitoringConfig: setup (1)

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    """

    verify_xpath_field_for_values(rrc_snode_add, pdml_xpath.RLMC_PSCELL, ['1'])
    verify_xpath_field_is_empty(rrc_snode_add, pdml_xpath.RLMC_SCELLS)


@log_as_robot_keyword
def verify_rlmc_not_present_in_scg(pcap_file: str | None = None) -> None:
    """KW verifies that for each FR2 cell BWP-DownlinkDedicated.radioLinkMonitoringConfig IE is not present

    :param pcap_file: path to pcap file
    """
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    rrc_snode_add = pc.get_packets(pcap_file=pcap_file,
                                   display_filter='f1ap',
                                   awaited_message=rrc.RRC_RECONFIG_NRDC_SCG_CONFIG)[0]

    verify_xpath_field_is_empty(rrc_snode_add, pdml_xpath.RLMC_PSCELL)
    verify_xpath_field_is_empty(rrc_snode_add, pdml_xpath.RLMC_SCELLS)


@log_as_robot_keyword
def get_rrc_snode_add_snode_mod_packets(pcap_file: str) -> tuple[PACKET, PACKET] | None:
    """Function returns 2 PCAP packets with RRC Reconfiguration containing NRDC Setup and NRDC SCG Modification

    :param pcap_file: path to pcap file
    :return: two RRC Reconfiguration messages with SCG configuration
    """
    rrc_snode_config_packets = pc.get_packets(pcap_file=pcap_file,
                                              display_filter='f1ap',
                                              awaited_message=rrc.RRC_RECONFIG_NRDC_SCG_CONFIG)
    try:
        rrc_snode_add = rrc_snode_config_packets[0]
        rrc_snode_mod = rrc_snode_config_packets[1]
        return rrc_snode_add, rrc_snode_mod
    except ValueError:
        logging.error("PCAP does not contain two RRC Reconfiguration messages with SCG Configuration")
        return None


@log_as_robot_keyword
def verify_two_csi_groups_pscell_bm_one_scell_in_first(rrc_snode_add: PcapPacket, rrc_snode_mod: PcapPacket) -> None:
    """Verifies if two CSI Report Groups are used for NRDC SCG cells.
    2 CSI Groups -> reportSlotConfig values in to groups: 2*X 6*Y, X for PSCell (first in table) and one SCell
                    reportSlotConfig of Report Config added in NRDC SCG modification (BM) has X value

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    """
    csi_report_periodicity = "//nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.reportSlotConfig"
    csi_report_offset = csi_report_periodicity + "/nr-rrc.slots320"

    verify_xpath_field_have_the_same_values(csi_report_periodicity, 8, rrc_snode_add, rrc_snode_mod)

    csi_report_offset_values = get_and_log_field_value(rrc_snode_add, csi_report_offset)
    snode_mod_csi_report_offset_values = get_and_log_field_value(rrc_snode_mod, csi_report_offset)
    msg = f'Verifying if CSI Report Config offset values are divided in 2 groups: \n' \
          f'{csi_report_offset_values} have 2*X and 6*Y value and X is first element\n' \
          f'{snode_mod_csi_report_offset_values} have X value'
    logging.info(msg)
    errors: list[str] = []

    if len(csi_report_offset_values) < 2:
        errors.append(f"Expected at least 2 offset values, got {len(csi_report_offset_values)}: "
                      f"{csi_report_offset_values}")
    else:
        first_val = csi_report_offset_values[0]
        second_val = csi_report_offset_values[1]

        count_first = csi_report_offset_values.count(first_val)
        if count_first != 2:
            errors.append(f"First offset value {first_val} expected 2 times, found {count_first} times in "
                          f"{csi_report_offset_values}")

        count_second = csi_report_offset_values.count(second_val)
        if count_second != 6:
            errors.append(f"Second offset value {second_val} expected 6 times, found {count_second} times in "
                          f"{csi_report_offset_values}")

    if not snode_mod_csi_report_offset_values:
        errors.append("SCG modification packet has no reportSlotConfig offsets.")
    elif len(csi_report_offset_values) >= 1 and csi_report_offset_values[0] != snode_mod_csi_report_offset_values[0]:
        errors.append(
            f"First offset value in modification ({snode_mod_csi_report_offset_values[0]}) "
            f"does not match expected group value ({csi_report_offset_values[0]})."
        )

    if errors:
        raise VerificationError(msg + "\nErrors:\n - " + "\n - ".join(errors))


@log_as_robot_keyword
def verify_one_csi_report_group_is_used(rrc_snode_add: PcapPacket, rrc_snode_mod: PcapPacket) -> None:
    """Verifies if one CSI Report Groups are used for NRDC SCG cells.
    1 CSI Groups -> reportSlotConfig values in to groups: 8*X for PSCell (first in table) and 7 SCells
                    reportSlotConfig of Report Config added in NRDC SCG modification (BM) has X value

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    """
    csi_report_periodicity = "//nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.reportSlotConfig"
    csi_report_offset = csi_report_periodicity + "/nr-rrc.slots320"

    verify_xpath_field_have_the_same_values(csi_report_periodicity, 8, rrc_snode_add, rrc_snode_mod)

    csi_report_offset_values = get_and_log_field_value(rrc_snode_add, csi_report_offset)
    snode_mod_csi_report_offset_values = get_and_log_field_value(rrc_snode_mod, csi_report_offset)
    msg = f'Verifying if CSI Report Config has the same offset value: {csi_report_offset_values}, ' \
          f'{snode_mod_csi_report_offset_values}'
    logging.info(msg)
    if not csi_report_offset_values.count(csi_report_offset_values[0]) == 8:
        raise VerificationError(msg)
    if not csi_report_offset_values[0] == snode_mod_csi_report_offset_values[0]:
        raise VerificationError(msg)


@log_as_robot_keyword
def verify_xpath_field_have_the_same_values(xpath_field: str,
                                            occurrences: int,
                                            first_packet: PcapPacket,
                                            second_packet: PcapPacket) -> None:
    """
    Verifies if given field in both packets have the same values
    and in the first packet all values are the same
    :param xpath_field: XPath of the field to be checked
    :param occurrences: How many times the value should occur in the list
    :param first_packet: PCAP packet to be checked
    :param second_packet: PCAP packet to be checked
    :return:
    """
    csi_report_periodicity_values = get_and_log_field_value(first_packet, xpath_field)
    snode_mod_csi_report_periodicity_values = get_and_log_field_value(second_packet, xpath_field)
    msg = f'Verifying if all CSI Report Config has the same reportSlotConfig value: {csi_report_periodicity_values}, ' \
          f'{snode_mod_csi_report_periodicity_values}'
    logging.info(msg)
    if not Misc().list_contains_same_values(csi_report_periodicity_values,
                                            csi_report_periodicity_values[0],
                                            occurrences):
        raise VerificationError(msg)
    if not csi_report_periodicity_values[0] == snode_mod_csi_report_periodicity_values[0]:
        raise VerificationError(msg)


@log_as_robot_keyword
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
    ck = Misc()
    if not ck.list_contains_same_values(csi_res_periodicity_values, csi_res_periodicity_values[0], 8):
        raise VerificationError(msg)
    csi_res_offset_values = get_and_log_field_value(rrc_snode_add, csi_res_offset)
    if not ck.list_contains_same_values(csi_res_offset_values, csi_res_offset_values[0], 8):
        raise VerificationError(msg)


@log_as_robot_keyword
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


@log_as_robot_keyword
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
    msg = f'PUNCH MUX Resource ID selected for MUX: {pucch_mux_res_id_value} ' \
          f'should be used for all SCG reportConfigs: {csi_report_pucch_res_values_list}, ' \
          f'{snode_mod_csi_report_pucch_res_values_list}'
    logging.info(msg)
    ck = Misc()
    if not ck.list_contains_same_values(csi_report_pucch_res_values_list, pucch_mux_res_id_value, 8):
        raise VerificationError(msg)
    if not ck.list_contains_same_values(snode_mod_csi_report_pucch_res_values_list, pucch_mux_res_id_value, 1):
        raise VerificationError(msg)


@log_as_robot_keyword
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


@log_as_robot_keyword
def verify_csi_rs_downgrade_from_rs3_to_rs1(pcap_file: str | None = None) -> None:
    """KW verifies masterCellGroup.cellGroupConfig.spCellConfig.spCellConfigDedicated.csi-MeasConfig for
         CSI-RS resource set changed from set3 to set1:
        nzp-CSI-RS-ResourceSetToAddModList -> contains 1 item
        csi-IM-ResourceSetToAddModList -> contains 1 item
     CSI-RS reduction from 4CSI-RS to 1CSI_RS:
        nzp-CSI-RS-ResourceToReleaseList -> contains 3 items
        nzp-CSI-RS-ResourceToAddModList -> contains 1 item
     CSI-IM resources that are bound with CSI-RS:
        csi-IM-ResourceToReleaseList -> contains 3 items
        csi-IM-ResourceToAddModList -> contains 1 item

    :param pcap_file: path to pcap file
    """
    logger.log_info_to_console("Verify CSI-RS configuration downgrade from RS3 to RS1")
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    rrc_snode_add = pc.get_packets(pcap_file=pcap_file,
                                   display_filter='f1ap',
                                   awaited_message=rrc.RRC_RECONFIG_NRDC_SCG_CONFIG)[0]

    csi_meas_config = "//nr-rrc.masterCellGroup//nr-rrc.spCellConfigDedicated_element/nr-rrc.csi_MeasConfig"
    verify_xpath_field_for_values(rrc_snode_add, csi_meas_config + "//nr-rrc.nzp_CSI_RS_ResourceToAddModList",
                                  ['1'])
    verify_xpath_field_for_values(rrc_snode_add, csi_meas_config + "//nr-rrc.nzp_CSI_RS_ResourceToReleaseList",
                                  ['3'])

    verify_xpath_field_for_values(rrc_snode_add, csi_meas_config + "//nr-rrc.csi_IM_ResourceToAddModList",
                                  ['1'])
    verify_xpath_field_for_values(rrc_snode_add, csi_meas_config + "//nr-rrc.csi_IM_ResourceToReleaseList",
                                  ['3'])

    verify_xpath_field_for_values(rrc_snode_add, csi_meas_config + "//nr-rrc.nzp_CSI_RS_ResourceSetToAddModList",
                                  ['1'])
    verify_xpath_field_for_values(rrc_snode_add, csi_meas_config + "//nr-rrc.csi_IM_ResourceSetToAddModList",
                                  ['1'])

    verify_xpath_field_is_empty(rrc_snode_add, csi_meas_config + "//nr-rrc.csi_ReportConfigToReleaseList")


@log_as_robot_keyword
def verify_nrdc_was_not_setup_after_a4(pcap_file: str | None = None) -> None:
    """KW verifies that A4 NRDC was reported with PCI of PSCell but XNAP:SNodeAdditionRequest was not sent
    F1AP:UECapabilityCheckResponse with check result 'temporarily failed'

    :param pcap_file: path to pcap file
    """
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file

    # rrc.MEASUREMENT_REPORT_PCI.verify_by = [inspectors.HasInspector('nr-rrc.physCellId', '60')]
    meas_report_pci_60 = copy.copy(rrc.MEASUREMENT_REPORT_PCI)
    meas_report_pci_60.verify_by = [inspectors.HasInspector('nr-rrc.physCellId', '60')]
    flow = [rrc.RRC_RECONFIG_MEAS_OBJECT_FR2,
            rrc.MEASUREMENT_REPORT_PCI,
            meas_report_pci_60,
            meas_report_pci_60,
            meas_report_pci_60]

    logging.info('%s:\n%s', "Messages flow to be checked", pformat(flow))
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='nr-rrc or xnap',
                   awaited_messages=flow,
                   forbidden_messages=[xnap.SNODE_ADD_REQ_ALLOWED_BC])


@log_as_robot_keyword
def verify_fr1_ca_was_kept(pcap_file: str | None = None) -> None:
    """KW verifies that there is RRCReconfiguration with SCell Addition and
    there is NO RRCReconfiguration with SCell Release

    :param pcap_file: path to pcap file
    """
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='nr-rrc',
                   awaited_messages=[rrc.RRC_RECONFIG_SCELL_ADD],
                   forbidden_messages=[rrc.RRC_RECONFIG_SCELL_RELEASE])


@log_as_robot_keyword
def verify_drx_setup_for_nrdc_ue(pcap_file: str | None = None) -> None:
    """KW verifies that first RRCReconfiguration after Initial Context Setup does NOT contain DRX-Config and
    second RRCReconfiguration does contain DRX-Config

    :param pcap_file: path to pcap file
    """
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    flow = [ngap.ICS_SETUP_REQ_PDU_SESSION,
            rrc.RRC_RECONFIG_NO_DRX,
            rrc.RRC_RECONFIG_DRX]
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='ngap or nr-rrc',
                   awaited_messages=flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_bands_support_in_ue_capabilities(supported_bands: list[str],
                                            not_supported_bands: list[str] | None = None,
                                            pcap_file: str | None = None) -> None:
    """KW verifies is present / not present in NR UE Capabilities paths
    RF-Parameters.supportedBandListNR.bandNR
    RF-Parameters.supportedBandCombinationList

    :param pcap_file: path to pcap file
    :param supported_bands: list of bands to be checked as supported, e.g. ['77', '1']
    :param not_supported_bands: list of bands to be checked as not supported, e.g. ['78']
    """
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    packet = pc.get_packets(pcap_file=pcap_file,
                            display_filter='f1ap',
                            awaited_message=rrc.UE_CAPABILITY_INFO)[0]

    verify_xpath_field_for_values(packet=packet, xpath='//nr-rrc.rat_Type', values=['0'])

    bands_nr = '//nr-rrc.rf_Parameters_element/nr-rrc.supportedBandListNR//nr-rrc.bandNR'
    verify_xpath_field_contains_values(packet, bands_nr, supported_bands)
    if not_supported_bands:
        verify_xpath_field_dont_contain_values(packet, bands_nr, not_supported_bands)

    band_combos_nr = '//nr-rrc.rf_Parameters_element/nr-rrc.supportedBandCombinationList//nr-rrc.bandNR'
    verify_xpath_field_contains_values(packet, band_combos_nr, supported_bands)
    if not_supported_bands:
        verify_xpath_field_dont_contain_values(packet, band_combos_nr, not_supported_bands)


@log_as_robot_keyword
def verify_bands_in_selected_nrdc_band_combination(pcap_file: str | None = None,
                                                   bands: list[str] | None = None) -> None:
    """KW verifies

    :param pcap_file: path to pcap file
    :param bands: bands to be checked, e.g. ['77']
    """
    bands = ['1'] if bands is None else bands
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    snode_add = pc.get_packets(pcap_file=pcap_file,
                               display_filter='xnap',
                               awaited_message=xnap.SNODE_ADD_REQ_ALLOWED_BC)[0]
    bc_ids = get_and_log_field_value(snode_add, '//nr-rrc.allowedBC_ListMRDC//nr-rrc.bandCombinationIndex')

    caps = pc.get_packets(pcap_file=pcap_file,
                          display_filter='f1ap',
                          awaited_message=rrc.UE_CAPABILITY_INFO)[0]
    verify_xpath_field_for_values(packet=caps, xpath='//nr-rrc.rat_Type', values=['0'])
    for bc in bc_ids:
        band_combo_nr = f'//nr-rrc.rf_Parameters_element/nr-rrc.supportedBandCombinationList/_[{int(bc)}]' \
                        f'//nr-rrc.bandNR'
        verify_xpath_field_contains_values(packet=caps, xpath=band_combo_nr, values=bands)


@log_as_robot_keyword
def verify_native_nrcell_band(cell_params: dict[str, Any], native_band: str) -> None:
    """KW verifies NR Cell configured bands

    :param cell_params: cell parameters dictionary
    :param native_band: band number e.g. '78' to be compared with NRCELL.freqBandIndicatorNR
    """
    cell_native_band = cell_params['freqBandIndicatorNR']

    msg = f'Expecting that NRCELL.freqBandIndicatorNR = {cell_native_band} is equal to {native_band}'
    logging.debug(msg)
    if cell_native_band != native_band:
        raise VerificationError(msg)


@log_as_robot_keyword
def verify_fr2_cells_were_not_added_for_not_supported_plmn_at_sn(pcap_file: str | None = None) -> None:
    """Verifies that only measObject for cell with supported PLMN is configured and that only 4CC was set up in FR2 leg

    :param pcap_file: path to pcap file
    """
    logger.log_info_to_console('Verifying FR2 cells were not added for supported PLMN')
    pcap_file = get_default_pcap_paths()[0] if pcap_file is None else pcap_file
    flow = [rrc.RRC_RECONFIG_MEAS_OBJECT_KA_TEST,
            rrc.RRC_RECONFIG_4CC,
            rrc.RRC_RECONFIG_COMPLETE]
    pc.expect_flow(pcap_file=pcap_file,
                   display_filter='nr-rrc',
                   awaited_messages=flow,
                   forbidden_messages=[])


@log_as_robot_keyword
def verify_radiolinkmonitoringconfig_for_failuredetectionresourcestoaddmodlist_in_scg() -> None:
    """
    KW verifies radioLinkMonitoringConfig for failureDetectionResourcesToAddModList in all SCG cells.
    """
    logger.log_info_to_console("Verify radioLinkMonitoringConfig for failureDetectionResourcesToAddModList in SCG")
    verify_rlmc_for_1_ie_in_scg()


@log_as_robot_keyword
def verify_that_radiolinkmonitoringconfig_ie_is_not_present_in_scg() -> None:
    """
    KW verifies that radioLinkMonitoringConfig IE is not present in all SCG cells.
    """
    logger.log_info_to_console("Verify that radioLinkMonitoringConfig IE is not present in SCG")
    verify_rlmc_not_present_in_scg()


@log_as_robot_keyword
def verify_that_fr1_ca_was_kept_and_nrdc_was_not_setup_after_a4_report() -> None:
    """
    KW verifies that FR1 CA was kept and NRDC was not setup after A4 report.
    """
    logger.log_info_to_console("Verify that FR1 CA was kept and NRDC was not setup after A4 report")
    verify_nrdc_was_not_setup_after_a4()
    verify_fr1_ca_was_kept()


@log_as_robot_keyword
def verify_that_drx_was_setup_in_second_rrc_reconfiguration_after_ics() -> None:
    """
    KW verifies that DRX was set up in second RRC Reconfiguration after ICS.
    """
    logger.log_info_to_console("Verify that DRX was setup in second RRC Reconfiguration after ICS")
    verify_drx_setup_for_nrdc_ue()


@log_as_robot_keyword
def verify_that_ue_doesnt_support_native_band_and_do_support_alternative_band_based_on_ue_capabilities() -> None:
    """
    KW verifies that UE don't support native band (n78) and do support alternative band (n77) based on UE Capabilities.
    """
    logger.log_info_to_console(
        "Verify that UE doesn't support native band (n78) and do support alternative band (n77) based "
        "on UE Capabilities")
    supported_bands = ['77']
    not_supported_bands = ['78']
    verify_bands_support_in_ue_capabilities(supported_bands=supported_bands, not_supported_bands=not_supported_bands)


@log_as_robot_keyword
def verify_that_band_combination_with_pcell_alternative_band_was_selected_for_nrdc() -> None:
    """
    KW verifies that UE band combination with PCell alternative band was selected for NRDC.
    """
    logger.log_info_to_console("Verify that band combination with PCell alternative band was selected for NRDC")
    bands = ['77']
    verify_bands_in_selected_nrdc_band_combination(bands=bands)


def verify_xpath_field_for_values(packet: PcapPacket, xpath: str, values: list[str]) -> None:
    """
    KW verifies given list of values is returned when checking PCAP packet in PDML format using XPATH

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :param xpath: string in XPATH syntax defining PCAP packet field to be checked
    :param values: list of strings that is expected when checking PCAP packet field(s)
    """

    frame_no = packet.get_field_value_by_name('frame.number')
    real_value = packet.get_field_value_by_xpath(xpath)
    msg = f"Packet No: {frame_no} - Expecting in xpath {xpath} value {values} and real value is {real_value}"
    logging.info(msg)
    if real_value != values:
        raise VerificationError(msg)


def verify_xpath_field_dont_contain_values(packet: PcapPacket, xpath: str, values: list[str]) -> None:
    """
    KW verifies given list of values is returned when checking PCAP packet in PDML format using XPATH

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :param xpath: string in XPATH syntax defining PCAP packet field to be checked
    :param values: list of strings that is expected when checking PCAP packet field(s)
    """

    frame_no = packet.get_field_value_by_name('frame.number')
    real_value = packet.get_field_value_by_xpath(xpath)
    msg = f"Packet No: {frame_no} - Expecting that xpath {xpath} don't contain {values} and real value is {real_value}"
    logging.info(msg)
    for element in values:
        if element in real_value:
            raise VerificationError(msg)


def verify_xpath_field_contains_values(packet: PcapPacket, xpath: str, values: list[str]) -> None:
    """
    KW verifies given list of values is returned when checking PCAP packet in PDML format using XPATH

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :param xpath: string in XPATH syntax defining PCAP packet field to be checked
    :param values: list of strings that is expected when checking PCAP packet field(s)
    """

    frame_no = packet.get_field_value_by_name('frame.number')
    real_value = packet.get_field_value_by_xpath(xpath)
    msg = f"Packet No: {frame_no} - Expecting that xpath {xpath} contains {values} and real value is {real_value}"
    logging.info(msg)
    for element in values:
        if element not in real_value:
            raise VerificationError(msg)


def verify_xpath_field_is_empty(packet: PcapPacket, xpath: str) -> None:
    """
    KW verifies that empty list is returned when checking PCAP packet in PDML format using XPATH
    Returning empty list means that field we want to check does not exist

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :param xpath: string in XPATH syntax defining PCAP packet field to be checked
    """

    frame_no = packet.get_field_value_by_name('frame.number')
    real_value = packet.get_field_value_by_xpath(xpath)
    msg = f"Packet No: {frame_no} - Expecting that xpath {xpath} returns empty list and real value is {real_value}"
    logging.info(msg)
    if real_value:
        raise VerificationError(msg)


def verify_xpath_value_is_greater_or_equal(packet: PcapPacket, xpath: str, value: int) -> int:
    """
    KW verifies if given value is greater or equal to one returned when checking PCAP packet in PDML format using XPATH

    :param packet: taf.analyzer.pcap.pcap_packet.PcapPacket
    :param xpath: string in XPATH syntax defining PCAP packet field to be checked
    :param value: int that is expected when checking PCAP packet field
    """

    frame_no = packet.get_field_value_by_name('frame.number')
    real_value = int(packet.get_field_value_by_xpath(xpath)[0])
    msg = f"Packet No: {frame_no} - Expecting in xpath {xpath} that real value {real_value} is grater or equal {value}"
    logging.info(msg)
    if real_value >= value:
        return real_value
    else:
        raise VerificationError(msg)


def get_and_log_field_value(packet: PcapPacket, xpath: str, console: bool = False) -> list:
    """
    Function for getting filed value by XPATH from PCAP packet with additional logging for debugging purposes

    :param packet: PCAP packet
    :param xpath: str in XPATH format to retrieve value of field(s)
    :param console: bool to decide if logs to be displayed on console
    :return: list of field values
    """

    frame_no = packet.get_field_value_by_name('frame.number')
    real_value = packet.get_field_value_by_xpath(xpath)
    msg = (f'Packet Number: {frame_no}\n'
           f' XPath: {xpath}\n'
           f' Value: {real_value}\n')
    logging.info(msg)
    if console:
        logger.log_info_to_console(msg)
    return real_value

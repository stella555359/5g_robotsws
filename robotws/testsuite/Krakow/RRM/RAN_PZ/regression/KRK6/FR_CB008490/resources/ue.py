"""
Keywords related to UE operations.

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""

import time

from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.parsers.pcap_checker import VerificationError
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword
from taf.rfrl.utilities.robot.general import get_builtin_value, get_robot_builtin_instance_and_import_if_needed

from .pcap.verifier import verify_ngap_initial_context_setup, verify_nrdc_call_setup, \
    verify_nrdc_call_release_due_to_amf
from .pcap.collecting import gather_pcap_from
from .variables.common import MY_UE_ALIAS_UE1, UE_CAPS

DL_TCP_DT_1_NAME = 'TCP_DL_DataTransfer_1'
SN_DRB_INACTIVITY_TIMER = 30
INACTIVITY_SAVE_OFFSET = 20

_ue = get_robot_builtin_instance_and_import_if_needed(name=None, library_path='taf.ue')


@log_as_robot_keyword
def require_and_reboot_ue(ue_alias: str = MY_UE_ALIAS_UE1, reboot_ue: bool = False) -> None:
    """Require UE and then reboot it.

    :param reboot_ue: Whether to reboot the UE after requiring it.
    :param ue_alias: UE alias.
    :return: None
    """
    logger.log_info_to_console(f"Requiring UE: {ue_alias}")
    log_as_robot_keyword(_ue.require_ue)(ue_alias=ue_alias, capabilities=UE_CAPS[ue_alias])
    if reboot_ue:
        logger.log_info_to_console(f"Rebooting UE: {ue_alias}")
        log_as_robot_keyword(_ue.reboot_ue)(ue_alias=ue_alias)


@log_as_robot_keyword
def attach_nrdc_ue(ue_alias: str = MY_UE_ALIAS_UE1) -> None:
    """
    Attach UE in NRDC mode.

    :param ue_alias: UE alias.
    :return: None
    """
    logger.log_info_to_console(f"Attach NRDC UE: {ue_alias}")
    _ue.attach_ue(ue_alias=ue_alias)


@log_as_robot_keyword
def detach_nrdc_ue(ue_alias: str = MY_UE_ALIAS_UE1) -> None:
    """
    Detach NRDC UE.

    :param ue_alias: UE alias.
    :return: None
    """
    logger.log_info_to_console(f"Detach NRDC UE: {ue_alias}")
    _ue.detach_ue(ue_alias=ue_alias)


@log_as_robot_keyword
def attach_ue_with_cell_verification(ue_alias: str = MY_UE_ALIAS_UE1,
                                     expected_nrcellid: str | None = None,
                                     wait_after_attach: int = 0) -> None:
    """
    Attach UE and verify serving cell (NRCellId).

    :param ue_alias: UE alias.
    :param expected_nrcellid: Expected NRCellId (optional).
    :param wait_after_attach: Seconds to wait post attach.
    :return: None
    """
    attach_nrdc_ue(ue_alias)
    verify_ue_cell_id(ue_alias, expected_nrcellid)
    if wait_after_attach != 0:
        wait_a_moment_for_nrdc_call_establishment(wait_after_attach)


@log_as_robot_keyword
def attach_ue_with_pcap_gathering(ue_alias: str = MY_UE_ALIAS_UE1,
                                  file_name_part: str = 'Attach',
                                  wait_after_attach: int = 15) -> tuple[str, str]:
    """
    Attach UE while capturing PCAPs.

    :param ue_alias: UE alias.
    :param file_name_part: Base filename component.
    :param wait_after_attach: Seconds to wait post attach.
    :return: (mn_pcap_path, sn_pcap_path)
    """
    logger.log_info_to_console('Attach NRDC UE with PCAP gathering')
    mn_pcap_file_path, sn_pcap_file_path = (gather_pcap_from(file_name_part=file_name_part, wait_before=5)
                                            (attach_ue_with_cell_verification)(ue_alias=ue_alias,
                                                                               wait_after_attach=wait_after_attach))
    return mn_pcap_file_path, sn_pcap_file_path


@log_as_robot_keyword
def detach_ue_with_nrdc_release_verification(ue_alias: str = MY_UE_ALIAS_UE1) -> None:
    """
    Detach UE and verify NRDC release.

    :param ue_alias: UE alias.
    :return: None
    """
    logger.log_info_to_console('Detach NRDC UE with NRDC release verification')
    gather_pcap_from(file_name_part="Detach")(detach_nrdc_ue)(ue_alias=ue_alias)
    verify_nrdc_call_release_due_to_amf()


@log_as_robot_keyword
def attach_ue_with_nrdc_establishment_verification(ue_alias: str = MY_UE_ALIAS_UE1,
                                                   file_name_part: str = 'Attach') -> None:
    """
    Attach UE and verify NRDC establishment.

    :param ue_alias: UE alias.
    :param file_name_part: Base filename component.
    :return: None
    """
    logger.log_info_to_console('Attach NRDC UE with NRDC setup verification')
    attach_ue_with_pcap_gathering(ue_alias, file_name_part)
    expected_nrcellid = get_builtin_value('used_cell_nrcellidentity')
    verify_ngap_initial_context_setup(nrcell_id=expected_nrcellid,
                                      forbidden_msgs_check=False)
    verify_nrdc_call_setup()


@log_as_robot_keyword
def verify_ue_cell_id(ue_alias: str, expected_nrcellid: str | None = None) -> None:
    """
    Verify that UE is camped on expected NRCellId.

    :param ue_alias: UE alias.
    :param expected_nrcellid: Expected NRCellId or derived if None.
    :return: None
    """
    time.sleep(1)
    cell_id = _ue.get_ue_info(ue_alias, "CELL_ID")
    if expected_nrcellid is None:
        expected_nrcellid = get_builtin_value('used_cell_nrcellidentity')
    msg = f'UE attached to NRCellId: {cell_id} ({expected_nrcellid} is expected)'
    if cell_id != expected_nrcellid:
        logger.log_warn_to_console(msg)
    else:
        logger.log_info_to_console(msg)


@log_as_robot_keyword
def start_and_verify_tcp_dl_and_ul_data_transfer(ue_alias: str = MY_UE_ALIAS_UE1,
                                                 apn: str | None = None,
                                                 protocol: str = 'tcp',
                                                 dl_tput: str = '100Kbits/sec',
                                                 dl_streams: str = '6',
                                                 expected_dl_tput: str = '4000 Mbits/sec',
                                                 ul_tput: str = '100Kbits/sec',
                                                 ul_streams: str = '4',
                                                 expected_ul_tput: str = '180 Mbits/sec',
                                                 data_transfer_time: str = '30s',
                                                 omit: str = '5') -> None:
    """
    Start and verify simultaneous TCP DL and UL transfers.

    :param ue_alias: UE alias.
    :param apn: APN.
    :param protocol: TCP
    :param dl_tput: Minimum DL throughput. Not applicable for TCP
    :param dl_streams: DL parallel streams.
    :param expected_dl_tput: Minimum DL throughput.
    :param ul_tput: Minimum UL throughput. Not applicable for TCP
    :param ul_streams: UL parallel streams.
    :param expected_ul_tput: Minimum UL throughput.
    :param data_transfer_time: Transfer duration.
    :param omit: Omit interval for throughput calc.
    :return: None
    """
    start_and_verify_dl_and_ul_data_transfer(ue_alias, apn, protocol, dl_tput, dl_streams, expected_dl_tput,
                                             ul_tput, ul_streams, expected_ul_tput, data_transfer_time, omit)


@log_as_robot_keyword
def start_and_verify_dl_and_ul_data_transfer(ue_alias: str = MY_UE_ALIAS_UE1,
                                             apn: str | None = None,
                                             protocol: str = 'udp',
                                             dl_tput: str = '800 Mbits/sec',
                                             dl_streams: str = '5',
                                             expected_dl_tput: str = '3800 Mbits/sec',
                                             ul_tput: str = '100 Mbits/sec',
                                             ul_streams: str = '1',
                                             expected_ul_tput: str = '90 Mbits/sec',
                                             data_transfer_time: str = '8s',
                                             omit: str = '1') -> None:
    """
    Start and verify simultaneous UDP DL and UL transfers.

    :param ue_alias: UE alias.
    :param apn: APN.
    :param protocol: UDP
    :param dl_tput: Minimum DL throughput.
    :param dl_streams: DL parallel streams.
    :param expected_dl_tput: Expected DL throughput.
    :param ul_tput: Minimum UL throughput.
    :param ul_streams: UL parallel streams.
    :param expected_ul_tput: Expected UL throughput.
    :param data_transfer_time: Transfer duration.
    :param omit: Omit interval for throughput calc.
    :return: None
    """
    dl_dt_alias = f"DL_{protocol}_data_transfer"
    ul_dt_alias = f"UL_{protocol}_data_transfer"
    logger.log_info_to_console(f"Start and Verify {protocol} DL and UL data transfer for UE: {ue_alias}")
    if protocol == 'tcp':
        packet_size = '1310B'
        log_as_robot_keyword(_ue.start_data_transfer)(dt_name=dl_dt_alias, ue_alias=ue_alias, apn=apn, direction='dl',
                                                      duration=data_transfer_time, protocol=protocol,
                                                      throughput=dl_tput,
                                                      max_segment_size=packet_size, parallel_streams=dl_streams,
                                                      enhanced_reports='true')
        log_as_robot_keyword(_ue.start_data_transfer)(dt_name=ul_dt_alias, ue_alias=ue_alias, apn=apn, direction='ul',
                                                      duration=data_transfer_time, protocol=protocol,
                                                      throughput=ul_tput,
                                                      max_segment_size=packet_size,
                                                      parallel_streams=ul_streams)
    else:
        packet_size = '1322B'
        log_as_robot_keyword(_ue.start_data_transfer)(dt_name=dl_dt_alias, ue_alias=ue_alias, apn=apn, direction='dl',
                                                      duration=data_transfer_time, protocol=protocol,
                                                      throughput=dl_tput,
                                                      packet_size=packet_size, parallel_streams=dl_streams,
                                                      enhanced_reports='true', buffer="4M")
        log_as_robot_keyword(_ue.start_data_transfer)(dt_name=ul_dt_alias, ue_alias=ue_alias, apn=apn, direction='ul',
                                                      duration=data_transfer_time, protocol=protocol,
                                                      throughput=ul_tput,
                                                      packet_size=packet_size, parallel_streams=ul_streams)
    log_as_robot_keyword(_ue.await_data_transfer_finish)(dl_dt_alias)
    log_as_robot_keyword(_ue.await_data_transfer_finish)(ul_dt_alias)
    log_as_robot_keyword(_ue.stop_data_transfer)(dt_name=dl_dt_alias)
    log_as_robot_keyword(_ue.stop_data_transfer)(dt_name=ul_dt_alias)
    log_as_robot_keyword(_ue.verify_average_throughput)(dt_name=dl_dt_alias, tput_min=expected_dl_tput, omit=omit)
    log_as_robot_keyword(_ue.verify_average_throughput)(dt_name=ul_dt_alias, tput_min=expected_ul_tput, omit=omit)


@log_as_robot_keyword
def start_and_verify_tcp_dl_data_transfer(ue_alias: str = MY_UE_ALIAS_UE1,
                                          dl_tput: str = '5750 Mbits/sec',
                                          data_transfer_time: str = '60s',
                                          omit: str = '5') -> None:
    """
    Start and verify TCP DL transfer.

    :param ue_alias: UE alias.
    :param dl_tput: Minimum DL throughput.
    :param data_transfer_time: Duration.
    :param omit: Omit interval for throughput calc.
    :return: None
    """
    logger.log_info_to_console(f"Start and Verify TCP DL data transfer for UE: {ue_alias}")
    start_dl_tcp_data_transfer_for_ue(ue_alias, data_transfer_time)
    log_as_robot_keyword(_ue.await_data_transfer_finish)(DL_TCP_DT_1_NAME)
    log_as_robot_keyword(_ue.stop_data_transfer)(DL_TCP_DT_1_NAME)
    tput = log_as_robot_keyword(_ue.get_average_throughput)(dt_name=DL_TCP_DT_1_NAME, omit=omit)
    logger.log_info_to_console(f"Average DL Throughput: {tput}")
    log_as_robot_keyword(_ue.verify_average_throughput)(dt_name=DL_TCP_DT_1_NAME, tput_min=dl_tput, omit=omit)


@log_as_robot_keyword
def start_dl_tcp_data_transfer_for_ue(ue_alias: str = MY_UE_ALIAS_UE1,
                                      data_transfer_time: str = '300s') -> None:
    """
    Start long DL TCP transfer.

    :param ue_alias: UE alias.
    :param data_transfer_time: Duration.
    :return: None
    """
    logger.log_info_to_console("Start DL TCP data transfer for UE")
    _ue.start_data_transfer(dt_name=DL_TCP_DT_1_NAME, ue_alias=ue_alias, direction='dl',
                            duration=data_transfer_time, linux_congestion='reno',
                            protocol='tcp', max_segment_size='1310B', parallel_streams='6',
                            enhanced_reports='true')


@log_as_robot_keyword
def verify_that_dl_tcp_data_transfer_is_still_ongoing(ue_alias: str = MY_UE_ALIAS_UE1) -> None:
    """
    Verify ongoing DL TCP transfer.

    :param ue_alias: UE alias.
    :return: None
    """
    logger.log_info_to_console(f"Verify that DL TCP data transfer is still ongoing for UE: {ue_alias}")
    _ue.check_data_transfer_is_alive(dt_name=DL_TCP_DT_1_NAME)


@log_as_robot_keyword
def stop_dl_tcp_data_transfer_for_ue(ue_alias: str = MY_UE_ALIAS_UE1) -> None:
    """
    Stop DL TCP transfer.

    :param ue_alias: UE alias.
    :return: None
    """
    logger.log_info_to_console(f"Stop DL TCP data transfer for UE: {ue_alias}")
    _ue.stop_data_transfer(dt_name=DL_TCP_DT_1_NAME)


@log_as_robot_keyword
def start_data_transfer_for_time_of_sn_drb_inactivity_timer_and_wait_until_it_is_finished(
        ue_alias: str = MY_UE_ALIAS_UE1) -> None:
    """
    Run DL TCP transfer matching SN DRB inactivity timer.

    :param ue_alias: UE alias.
    :return: None
    """
    logger.log_info_to_console(f"Start Data Transfer For Time Of SN DRB Inactivity Timer "
                               f"And Wait Until It Is Finished for UE: {ue_alias}")
    _ue.start_data_transfer(dt_name=DL_TCP_DT_1_NAME, ue_alias=ue_alias, direction='dl',
                            duration=f'{SN_DRB_INACTIVITY_TIMER}s', protocol='tcp', max_segment_size='1310B',
                            parallel_streams='1', enhanced_reports='true')
    _ue.await_data_transfer_finish(DL_TCP_DT_1_NAME)
    _ue.stop_data_transfer(dt_name=DL_TCP_DT_1_NAME)


@log_as_robot_keyword
def perform_short_voice_call_using_mn_terminated_pdu_session(ue_alias: str = MY_UE_ALIAS_UE1,
                                                             duration: str = '15s') -> None:
    """
    Perform short voice call on MN-terminated PDU session.

    :param ue_alias: UE alias.
    :param duration: Call duration.
    :return: None
    """
    logger.log_info_to_console(f"Perform Short Voice Call Using MN Terminated PDU Session for UE: {ue_alias}")
    vc_alias = 'VC_1'
    _ue.start_voice_call(vc_alias, ue_alias, to='0105', duration=duration)
    _ue.await_voice_call_finish(vc_alias)
    time.sleep(5)


@log_as_robot_keyword
def trigger_sn_terminated_offloaded_pdu_session_release(ue_alias: str = MY_UE_ALIAS_UE1) -> None:
    """
    Trigger SN-terminated offloaded PDU session release.

    :param ue_alias: UE alias.
    :return: None
    """
    logger.log_info_to_console(f"Trigger SN Terminated (Offloaded) PDU Session Release for UE: {ue_alias}")
    _ue.turn_mobile_data_off(ue_alias)


@log_as_robot_keyword
def nrdc_call_with_dl_peak_tput_verification(ue_alias: str = MY_UE_ALIAS_UE1) -> bool:
    """
    Execute NRDC call and verify DL peak throughput.

    :param ue_alias: UE alias.
    :return: True on success, False on failure.
    """
    logger.log_info_to_console(f"NRDC Call with DL Peak Tput Verification for UE: {ue_alias}")
    tput = None
    try:
        attach_ue_with_cell_verification()
        wait_a_moment_for_nrdc_call_establishment()
        start_and_verify_tcp_dl_data_transfer(ue_alias, dl_tput='5750 Mbits/sec', data_transfer_time='60s', omit='10')
        return True
    except Exception as e:
        logger.log_warn_to_console(f"Tput: {tput} Verification failed for UE: {ue_alias}: {e}")
        return False
    finally:
        detach_nrdc_ue(ue_alias)


@log_as_robot_keyword
def multiple_loops_of_nrdc_call_with_dl_peak_tput_verification(loops: int = 5,
                                                               fail_threshold: int = 2) -> None:
    """
    Run multiple NRDC peak throughput loops with failure threshold.

    :param loops: Number of loops.
    :param fail_threshold: Max allowed failures before abort.
    :return: None
    """
    call_results = []
    for i in range(1, loops + 1):
        logger.log_banner_to_console(f'=== NRDC Call loop {i} ===')
        status = nrdc_call_with_dl_peak_tput_verification()
        call_results.append(status)
        if call_results.count(False) >= fail_threshold:
            raise VerificationError(f'TPUT results {call_results} are above FAIL threshold: {fail_threshold}')


@log_as_robot_keyword
def wait_a_moment_for_nrdc_call_establishment(wait_time: int = 15) -> None:
    """
    Wait for NRDC call establishment.

    :param wait_time: Seconds to wait.
    :return: None
    """
    logger.log_info_to_console(f'Waiting {wait_time} seconds for NRDC call establishment')
    time.sleep(wait_time)


@log_as_robot_keyword
def wait_until_sn_drb_inactivity_timer_expiry() -> None:
    """
    Wait until SN DRB inactivity timer expires.

    :return: None
    """

    logger.log_info_to_console(f"Waiting SN DRB Inactivity Timer Expiry {SN_DRB_INACTIVITY_TIMER} + "
                               f"{INACTIVITY_SAVE_OFFSET} seconds")
    time.sleep(SN_DRB_INACTIVITY_TIMER + INACTIVITY_SAVE_OFFSET)


@log_as_robot_keyword
def ue_activity_resumption():
    wait_until_sn_drb_inactivity_timer_expiry()
    start_data_transfer_for_time_of_sn_drb_inactivity_timer_and_wait_until_it_is_finished()
    wait_until_sn_drb_inactivity_timer_expiry()

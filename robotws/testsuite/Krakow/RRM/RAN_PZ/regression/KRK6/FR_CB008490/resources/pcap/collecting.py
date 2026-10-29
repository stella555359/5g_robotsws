"""
Keywords related to PCAP gathering on BTSes.

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""

import functools
import logging
import time
from datetime import datetime
from re import search
from subprocess import run, STDOUT, check_output
from typing import Callable, List, Tuple

from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog
from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword
from taf.rfrl.utilities.robot.general import set_robot_test_variable, get_builtin_value


@log_as_robot_keyword
def start_pcap_gathering_on_mn_and_sn_btses(file_name_part: str) -> tuple[str, str]:
    """
    Start PCAP gathering on MN and SN BTSes.

    :param file_name_part: Base part of filename.
    :return: Tuple (mn_pcap_file, sn_pcap_file).
    """
    logger.log_info_to_console(f'Start PCAP Gathering On MN And SN BTSes')
    date = datetime.now().strftime("%Y%m%d_%H%M%S")
    mn_pcap_file = f'MN_gNB_{file_name_part}_{date}.pcap'
    sn_pcap_file = f'SN_gNB_{file_name_part}_{date}.pcap'
    set_robot_test_variable('mn_pcap_file', mn_pcap_file)
    set_robot_test_variable('sn_pcap_file', sn_pcap_file)
    interface = "any"
    additional_options = "'sctp and (port 38412 or port 38472 or port 38462 or port 38422 or port 29211)'"
    gnb_log = GnbLog()
    gnb_log.start_tcpdump_on_smod(bts_id=0, interface=interface, background=True, capture_file=mn_pcap_file,
                                  additional_options=additional_options)
    gnb_log.start_tcpdump_on_smod(bts_id=1, interface=interface, background=True, capture_file=sn_pcap_file,
                                  additional_options=additional_options)
    return mn_pcap_file, sn_pcap_file


@log_as_robot_keyword
def get_ng_and_xn_cplane_ips(bts_id: int = 0) -> List[str]:
    """
    Get NG and XN control plane IP addresses for the given BTS.
    :param bts_id:
    :return: List of IP addresses.
    """
    tl = get_builtin_value('tl')
    ip_addresses = []
    try:
        ip_addresses.append(tl.gnbs[bts_id].cu.xnc.v4.split('/', 1)[0])
    except (AttributeError, IndexError, KeyError):
        logging.info(f"XN control plane IP not found for BTS ID {bts_id}")
    try:
        ip_addresses.append(tl.gnbs[bts_id].cu.ngc.v4.split('/', 1)[0])
    except (AttributeError, IndexError, KeyError):
        logging.info(f"NG control plane IP not found for BTS ID {bts_id}")
    return ip_addresses


@log_as_robot_keyword
def stop_and_download_pcap_files_from_mn_and_sn_btses(refilter: bool = False) -> tuple[str, str]:
    """
    Stop tcpdump and download PCAP files from MN and SN BTSes.
    Optionally refilters to retain selected protocols only.

    :param refilter: Whether to refilter to protocol subset.
    :return: Tuple (mn_pcap_file_path, sn_pcap_file_path).
    """
    logger.log_info_to_console(f'Stop PCAP Gathering On MN And SN BTSes')
    stop_tcpdump_on_btses()
    mn_pcap_file = get_builtin_value('mn_pcap_file')
    sn_pcap_file = get_builtin_value('sn_pcap_file')
    file_dir = download_tcpdump_from_mn_and_sn_btses(mn_pcap_file, sn_pcap_file)
    mn_pcap_file_path = f'{file_dir}/{mn_pcap_file}'
    sn_pcap_file_path = f'{file_dir}/{sn_pcap_file}'
    if refilter:
        logger.log_info_to_console("Refiltering PCAP files to keep only F1AP, E1AP, XNAP, NGAP protocols")
        pcap_filter = "f1ap or e1ap"
        refilter_mn_pcap_file_path = mn_pcap_file_path.replace('.pcap', '_filtered.pcap')
        refilter_sn_pcap_file_path = sn_pcap_file_path.replace('.pcap', '_filtered.pcap')
        mn_ips = get_ng_and_xn_cplane_ips(bts_id=0)
        sn_ips = get_ng_and_xn_cplane_ips(bts_id=1)

        mn_ip_filter = create_tshark_filter(mn_ips) if mn_ips else ""
        sn_ip_filter = create_tshark_filter(sn_ips) if sn_ips else ""

        refilter_pcap_with_protocols(input_pcap=mn_pcap_file_path,
                                     pcap_filter=pcap_filter + mn_ip_filter,
                                     output_pcap=refilter_mn_pcap_file_path)
        refilter_pcap_with_protocols(input_pcap=sn_pcap_file_path,
                                     pcap_filter=pcap_filter + sn_ip_filter,
                                     output_pcap=refilter_sn_pcap_file_path)
        mn_pcap_file_path = refilter_mn_pcap_file_path
        sn_pcap_file_path = refilter_sn_pcap_file_path
    set_robot_test_variable('mn_pcap_file_path', mn_pcap_file_path)
    set_robot_test_variable('sn_pcap_file_path', sn_pcap_file_path)
    return mn_pcap_file_path, sn_pcap_file_path


@log_as_robot_keyword
def create_tshark_filter(ips: List[str]) -> str:
    """
    Create a tshark display filter for given IP addresses.
    Always starts with ' or' and never ends with ' or''.
    Returns empty string if no valid IPs provided.
    """
    unique_ips = set(ips)
    if not unique_ips:
        return ""
    return " or " + " or ".join(f"ip.addr=={ip}" for ip in unique_ips)


@log_as_robot_keyword
def download_tcpdump_from_mn_and_sn_btses(mn_pcap_file: str, sn_pcap_file: str) -> str:
    """
    Download tcpdump files from MN and SN BTSes.

    :param mn_pcap_file: MN capture filename.
    :param sn_pcap_file: SN capture filename.
    :return: Directory path where files were stored.
    """
    gnblog = GnbLog()
    file_dir = log_as_robot_keyword(gnblog.download_tcpdump_from_bts)(bts_id=0, interface='FCT',
                                                                      log_file_name=mn_pcap_file)
    log_as_robot_keyword(
        gnblog.download_tcpdump_from_bts)(bts_id=1, interface='FCT',
                                          log_file_name=sn_pcap_file)
    return file_dir


@log_as_robot_keyword
def stop_tcpdump_on_btses(bts_num: int = 2) -> None:
    """
    Stop tcpdump on MN and SN BTSes
    :param bts_num: number of BTSes to stop tcpdump on (default 2)
    :return: None
    """
    for bts_id in range(bts_num):
        GnbLog().stop_tcpdump_on_smod(bts_id=bts_id)


def gather_pcap_from(file_name_part: str = 'Attach', wait_time: int = 0, wait_before: int = 0) -> Callable:
    """
    Decorator that wraps a callable with start/stop PCAP collection on MN and SN.

    :param file_name_part: Base filename component.
    :param wait_time: Time to wait after calling wrapped function (in seconds).
    :param wait_before: Time to wait before calling wrapped function (in seconds).
    :return: Wrapped callable returning (mn_pcap_path, sn_pcap_path).
    """

    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            try:
                start_pcap_gathering_on_mn_and_sn_btses(file_name_part=file_name_part)
                time.sleep(wait_before)
                func(*args, **kwargs)
                time.sleep(wait_time)
                mn_pcap_file_path, sn_pcap_file_path = stop_and_download_pcap_files_from_mn_and_sn_btses(refilter=True)
                return mn_pcap_file_path, sn_pcap_file_path
            finally:
                stop_tcpdump_on_btses()

        return wrapper

    return decorator


@log_as_robot_keyword
def get_default_pcap_paths() -> Tuple[str, str]:
    """
    Get default PCAP file paths stored in Robot variables.

    :return: Tuple (mn_pcap_file_path, sn_pcap_file_path).
    """
    mn_pcap_file_path = get_builtin_value('mn_pcap_file_path')
    sn_pcap_file_path = get_builtin_value('sn_pcap_file_path')
    logging.info(f"Default PCAP file paths: {mn_pcap_file_path}, {sn_pcap_file_path}")
    return mn_pcap_file_path, sn_pcap_file_path


@log_as_robot_keyword
def refilter_pcap_with_protocols(input_pcap: str, pcap_filter: str, output_pcap: str | None = None) -> bool:
    """
    Refilter a PCAP using tshark display filter.

    :param input_pcap: Input PCAP path.
    :param pcap_filter: Tshark display filter expression.
    :param output_pcap: Output PCAP path (defaults to input overwriting).
    :return: True if filtering succeeded, else False.
    """
    if output_pcap is None:
        output_pcap = input_pcap

    cmd = f"tshark -Y '{pcap_filter}' -r '{input_pcap}' -w '{output_pcap}'"
    logging.info(f"Refiltering pcap with command: {cmd}")
    output = None
    try:
        output = run(cmd, shell=True, stderr=STDOUT)
        logging.info(f"Filtered pcap saved to: {output_pcap}")
        return True
    except Exception as e:
        logging.warning(f"Failed to filter pcap: {e}")
        return False
    finally:
        text = output.decode('utf-8', errors='ignore') if isinstance(output, bytes) else str(output)
        logging.info(f"Output from command: {text}")


@log_as_robot_keyword
def log_mcshark_plugin_presence(plugin_substring: str = "mcshark") -> bool:
    """
    Check for Wireshark plugin containing given substring.

    :param plugin_substring: Substring to search in plugin list.
    :return: True if found, else False.
    """
    try:
        raw = check_output("tshark -G plugins", shell=True, stderr=STDOUT)
    except Exception as e:
        logger.log_warn_to_console(f"Failed to execute 'tshark -G plugins': {e}")
        return False
    text = raw.decode(errors='ignore') if isinstance(raw, bytes) else str(raw)
    if search(plugin_substring, text):
        plugin_match = search(rf"{plugin_substring}[-A-Za-z0-9_.+]*\.so", text)
        if plugin_match:
            logger.log_info_to_console(f"McShark plugin found: {plugin_match.group(0)}")
        else:
            logger.log_info_to_console(f"McShark plugin present (substring '{plugin_substring}' found)")
        return True
    logger.log_warn_to_console(f"No plugin containing '{plugin_substring}' found in 'tshark -G plugins' output "
                               f"F1AP/NR-RRC verification will fail.")
    return False

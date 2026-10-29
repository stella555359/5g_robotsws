"""
Keywords related to UTF logs collection.

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""

import logging

from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog
from taf.rfrl.bts.devices.ru.ru_btslog_collector import GnbRuBtslogCollector
from taf.rfrl.bts.devices.ru.ru_serial_logs_collector import GnbRuSerialLogsCollector
from taf.rfrl.utilities.logger import custom_logger as logger
from taf.internal.sw.dcap.rd.client.dcap_lite.v3.exceptions import ApiException
from taf.rfrl.utilities.robot.parallel_runner import run_parallel_in_robot
from taf.rfrl.utilities.test_config import get_log_path
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.sw.dcap.rd import rd
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword

_utf = rd()


@log_as_robot_keyword
def start_utf_logs_collection(bts_ids: list[int] | None = None) -> str | None:
    """Starts the collection of UTF logs for specified BTS IDs.
    Args:
    :param bts_ids: (list[int], optional): A list of BTS IDs to start log collection for.
                                        If None, it uses all BTS IDs from the 'tl' variable. Defaults to None.
    :return: The trace ID of the started trace.  Returns None if an error occurs.
    """
    logger.log_info_to_console('*** Starting UTF Log Collection ***')
    try:
        _tl = get_builtin_value(param_name="tl")

        if bts_ids is None:
            logging.info(f"List w BTS IDs not provided, taking IDs from tl variable: {_tl.gnbs}")
            bts_ids = list(range(len(_tl.gnbs)))

        bts_ids = [int(x) for x in bts_ids if isinstance(x, (int, float, str))]
        _utf.connect_to(host=_tl.gnbs[bts_ids[0]].dcap.connection_details.addr,
                        port=_tl.gnbs[bts_ids[0]].dcap.connection_details.port,
                        secure=True)

        for bts_id in bts_ids:
            try:
                _utf.create_bts(host=_tl.gnbs[bts_id].cu.oam_http_connection_details.addr)
            except ApiException as e:
                if e.body == '{"msg":"The BTS already exists in the database."}':
                    logging.info(f'BTS is already added to UTF: {e.body}')
                else:
                    raise

        trace_bts_list = []
        for bts_id in bts_ids:
            bts = {'host': _tl.gnbs[bts_id].cu.oam_http_connection_details.addr,
                   'port': 443,
                   'bts_id': _tl.gnbs[bts_id].global_bts_id}
            trace_bts_list.append(bts)
        trace_profiles = ['cp_5g']
        logging.info(f"Starting trace for BTSes: {trace_bts_list} with trace profiles: {trace_profiles}")
        precondition_status = _utf.check_precondition(invalidate_bts_info_cache=False,
                                                      bts=trace_bts_list,
                                                      gnb_custom_profile=trace_profiles,
                                                      control_plane_interface=True)
        logging.info(f'Check preconditions status: {precondition_status}')

        trace_id = _utf.start_trace(bts=trace_bts_list,
                                    gnb_custom_profile=trace_profiles,
                                    wait_for_activation=True,
                                    control_plane_interface=True)
        return str(trace_id['tracer_id'])
    except Exception as e:
        logger.log_warn_to_console(f'UTF logs collection start failed: {e}')

    return None


@log_as_robot_keyword
def stop_utf_logs_collection(trace_id: str | None = None) -> bool:
    """Stops a UTF log collection trace, retrieves results, and cleans up.

    :param trace_id: (int, optional): The ID of the trace to stop.
                     If None, no specific trace is targeted. Defaults to None.
    :return bool: True if the trace was stopped and cleaned up successfully, False otherwise.
    """
    logger.log_info_to_console('*** Stopping UTF Log Collection  ***')
    try:
        logging.info(f"Stopping trace with ID: {trace_id}")
        _utf.stop_trace(trace_id=trace_id)
        log_dir = get_log_path()
        logging.info(f"Retrieving results to: {log_dir}")
        _utf.get_results(result_id=trace_id, target_dir=log_dir, timeout=180)
        logging.info(f"Deleting trace with ID: {trace_id}")
        _utf.delete_trace(trace_id=trace_id)
        logging.info(f"Trace {trace_id} stopped and cleaned up successfully.")
        return True
    except Exception as e:
        logging.error(f"UTF logs collection stop failed for trace_id: {trace_id} with exception: {e}")
        return False


@log_as_robot_keyword
def collect_snapshots_in_parallel() -> None:
    """
    Collects BTS snapshots in parallel on both gNBs.

    :return: None
    """
    logger.log_info_to_console('Collecting Snapshots from BTSes in parallel')
    gnblog = GnbLog()
    log_path = get_builtin_value(param_name="LOG_PATH")
    list_of_functions = [{
        'function': gnblog.collect_snapshot,
        'function_kwargs': {'bts_id': 0,
                            'log_dir': log_path},
        'device_name': 'GNB0'
    }, {
        'function': gnblog.collect_snapshot,
        'function_kwargs': {'bts_id': 1,
                            'log_dir': log_path},
        'device_name': 'GNB1'
    }]
    try:
        run_parallel_in_robot(list_of_functions)
    except Exception as e:
        logging.warning(f'Parallel Snapshot gathering failed due to {e} exception')


@log_as_robot_keyword
def start_ru_console_and_syslog_logs_collection() -> None:
    """
    KW for startup RU Console and Syslog Logs Collection. 4SK010 TL currently have only 1 full LMI for AEQP.

    :return: None
    """
    logger.log_info_to_console("Starting RU Console and Syslog Logs Collection")
    gnb_ru_lmi = GnbRuSerialLogsCollector()
    gnb_ru_lmi.setup_hosts_for_all_ru_console_collection()
    gnb_ru_lmi.setup_serial_console_connection_for_all_rus()
    gnb_ru_lmi.set_swconfig_to_collect_ru_syslog(bts_id=0, du_id=0, ru_id=1, common_unit_id=0, capacity_unit_id=1,
                                                 ru_alias="GNB0_DU0_RU2_LMI")
    gnb_ru_lmi.start_streaming_syslog_on_ru(bts_id=0, du_id=0, ru_id=1, common_unit_id=0, capacity_unit_id=1,
                                            ru_alias="GNB0_DU0_RU2_LMI")
    syslog_ru = GnbRuBtslogCollector()
    syslog_ru.setup_ru_btslog_collector(bts_id=0, du_id=0, ru_id=1, common_unit_id=0, capacity_unit_id=1)
    syslog_ru.start_collecting_ru_btslog(bts_id=0, du_id=0, ru_id=1, common_unit_id=0, capacity_unit_id=1)


@log_as_robot_keyword
def stop_ru_console_and_syslog_logs_collection() -> None:
    """
    Stops RU syslog/BTS log collection and tears down console connections.

    :return: None
    """
    logger.log_info_to_console("Stopping RU Console and Syslog Logs Collection")
    gnb_ru_lmi = GnbRuSerialLogsCollector()
    syslog_ru = GnbRuBtslogCollector()
    syslog_ru.stop_collecting_ru_btslog(bts_id=0, du_id=0, ru_id=1, common_unit_id=0, capacity_unit_id=1)
    syslog_ru.teardown_ru_btslog_collector(bts_id=0, du_id=0, ru_id=1, common_unit_id=0, capacity_unit_id=1)
    gnb_ru_lmi.collect_console_log_from_all_setup_rus()
    gnb_ru_lmi.teardown_serial_console_connection_for_all_setup_rus()

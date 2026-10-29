"""

Set of PROPSIM Keywords used for setting IN/OUT ports and reading current values.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
"""

import os
import time
import logging
import testsuite.Krakow.resources.qxdm_collection as qxdmcolection
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn
from taf.ul.sc.perf.util.logger import log_function_status_to_console, log_info_to_console
from taf.rfrl.utilities.robot.general import (set_robot_test_variable, set_robot_suite_variable,
                                              get_builtin_instance, get_builtin_value)
from taf.rfrl.utilities.test_config import set_test_case_log_path
from taf.rfrl.bts.connections import device_aliases as connection_names
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.logs_collecting.sherpa_collector import GenericSherpaCollector
from taf.rfrl.bts.devices.du.logs_collecting.btslog_collector import GnbBtslogCollector
from taf.rfrl.utilities.reports.excel_report import ExcelReport
from local_pc_keywords import make_local_logs_directory, change_file_name_on_local_pc, clear_local_logs_directory
from csv_report import PropsimCsvReport, SummaryCsvReport, CsvReport
from propsim_keywords import CustomPropsimKeywords


def prepare_rfp_logs_directory():
    """
    Make rfp logs directory on local machine and set test variable
    """

    log_path = set_test_case_log_path()
    rfp_logs = os.path.join(log_path, 'rfp_logs')
    make_local_logs_directory(log_dir=rfp_logs)
    set_robot_test_variable('RFP_LOGS', rfp_logs)


def make_directory_for_iteration(log_dir, iteration=1):
    """
    Make rfp logs directory for single iteration

    :param log_dir:       directory path.
    :param iteration:     number of iteration.
    :return: full_path
    """
    full_path = os.path.join(log_dir, str(iteration))
    make_local_logs_directory(log_dir=full_path)

    return full_path


def generate_steps(dl_start, dl_end, ul_start, ul_end, step=-1):
    def _all_values_generated(_current_value, _end, _step):
        if (_step < 0 and _current_value > _end) or (_step > 0 and _current_value < _end):
            return True
        else:
            return False

    def _generate_steps(start, end, step):
        list_of_values = [start]
        current_value = start
        while _all_values_generated(current_value, end, step):
            current_value = round(current_value + step, 1)
            list_of_values.append(current_value)

        return list_of_values

    dl_steps = _generate_steps(float(dl_start), float(dl_end), float(step))
    ul_steps = _generate_steps(float(ul_start), float(ul_end), float(step))

    steps = list(zip(dl_steps, ul_steps))
    return steps, len(steps)


# PROPSIM
@log_function_status_to_console(msg="Start Propsim Emulation", log_hierarchy=1)
def start_propsim_emulation(emulation_file_path):
    BuiltIn().run_keyword('CPK.start_propsim_emulation', emulation_file_path)


@log_function_status_to_console(msg="Change Propsim output gain", log_hierarchy=2)
def change_propsim_output_gain(downlink_gain, uplink_gain):
    BuiltIn().run_keyword('CPK.set_output_gain', downlink_gain, uplink_gain)


@log_function_status_to_console(msg="Stop Propsim Emulation", log_hierarchy=1)
def stop_propsim_emulation():
    BuiltIn().run_keyword('CPK.stop_propsim_emulation')


# UE
@log_function_status_to_console(msg="Perform Attach and Verify UE Properly Attached", log_hierarchy=1)
def perform_attach_and_verify_ue_properly_attached(log_dir=None, attempts=2, python_path=None):
    current_propism_data = CustomPropsimKeywords().get_current_values()
    logging.info("Propsim values before attach {}".format(current_propism_data))

    start_collecting_qxdm_logs(duration=12, python_path=python_path)
    BuiltIn().run_keyword('ue.attach_ue', 'UE')
    cell_id = BuiltIn().run_keyword('ue.get_ue_info', 'UE', 'CELL_ID')
    ip = BuiltIn().run_keyword('ue.get_ue_info', 'UE', 'IP')
    if cell_id and ip:
        convert_qxdm_log_to_txt()
        download_qxdm_logs(log_dir=os.path.join(log_dir, 'passed'))
        log_info_to_console(msg="UE is attached to Cell: {} and got IP: {}".format(cell_id, ip), log_hierarchy=2)
    else:
        if attempts - 1 > 0:
            logging.warning("First attempt of Attach failed! Trying again")
            convert_qxdm_log_to_txt()
            download_qxdm_logs(log_dir=os.path.join(log_dir, 'failed'))
            BuiltIn().run_keyword('ue.detach_ue', 'UE')
            BuiltIn().run_keyword('ue.Reboot Ue', 'UE', 120)
            perform_attach_and_verify_ue_properly_attached(log_dir=log_dir, attempts=attempts - 1)
        else:
            raise Exception("Cannot attach UE ")


@log_function_status_to_console(msg="Detach UE", log_hierarchy=1)
def detach_ue():
    BuiltIn().run_keyword('ue.detach_ue', 'UE')


@log_function_status_to_console(msg="Start Data Transfer on Real UE", log_hierarchy=2)
def start_data_transfer_on_real_ue(direction, protocol, duration, tput, parallel_streams, size_packet, buffer_client,
                                   buffer_server, interval, qci):
    BuiltIn().run_keyword('taf.rfrl.ue.helpers.data_transfer.start_data_transfer_on_real_ue',
                          "DT_{}".format(direction.upper()), 'UE', direction, protocol, duration, tput,
                          parallel_streams, size_packet, buffer_client, buffer_server, interval, qci)


@log_function_status_to_console(msg="Wait for Tput stabilization", log_hierarchy=2)
def wait_for_tput_stabilization(sleep_time=60):
    time.sleep(sleep_time)


@log_function_status_to_console(msg="Wait for Tput finished", log_hierarchy=2)
def wait_for_tput_finished(direction):
    ute_ue = get_builtin_instance('ue')
    ute_ue.await_data_transfer_finish(dt_name="DT_{}".format(direction))


# Log Collection
@log_function_status_to_console(msg="Collect Propsim Results", log_hierarchy=3)
def collect_propsim_results(log_dir):
    current_data = CustomPropsimKeywords().get_current_values()
    PropsimCsvReport().create_propsim_csv_report_for_single_iteration(data=current_data,
                                                                      log_dir=log_dir)


@log_function_status_to_console(msg="Collect IPERF Results", log_hierarchy=3)
def collect_iperf_results(direction, log_dir, file_name='iperf_results.txt'):
    ue = get_builtin_instance('ue')
    # avg,min,max;[smaple1, sample2, sample3....]
    tput_data = ue.get_data_transfer_statistics('DT_{}'.format(direction.upper())).split(';')
    tput_stats = tput_data[0].split(',')
    tput_samples = tput_data[1]

    iperf_headers = ['iperf_min_tput', 'iperf_avg_tput', 'iperf_max_tput', 'iperf_samples']
    iperf_data = [tput_stats[1], tput_stats[0], tput_stats[2], tput_samples]
    iperf_data_mbps = []
    for value in iperf_data:
        try:
            value_mbps = round(float(value)/1000000, 2)
            iperf_data_mbps.append(value_mbps)
        except ValueError:
            samples = tput_samples.split(',')
            samples_mbps = [str(round(float(sample)/1000000, 2)) for sample in samples]
            iperf_data_mbps.append(",".join(samples_mbps))

    CsvReport.create_csv_file(csv_file_path=os.path.join(log_dir, file_name),
                              data=[iperf_data_mbps], headers=iperf_headers)


# @log_function_status_to_console(msg="Create Summary CSV Report(Propsim/Sherpa/QXDM)", log_hierarchy=2)
def create_summary_csv_report(log_dir=None):
    log_info_to_console(msg="Create Summary CSV Report(Propsim/Sherpa/QXDM)", log_hierarchy=2)
    log_dir = log_dir if log_dir else get_builtin_value('RFP_LOGS')
    pci = get_builtin_value('USED_PHYSICAL_CELL_ID')
    logging.debug("PCI used for parsing {}".format(pci))
    return SummaryCsvReport().create_summary_csv_report(logs_dir=log_dir, pci=pci)


graphs_data = [
        {"x_header": "iperf_avg_tput", "y_header": "sinLayer0 gNB", "title": "5GMax UL throughput vs UL SINR",
         "label": "5G Max Rank1"},
        {"x_header": "iperf_avg_tput", "y_header": "Cell Quality RSRP", "title": "5GMax UL throughput vs DL RSRP",
         "label": "5G Max Rank1"},
        {"x_header": "MEAN MCS gNB UL", "y_header": "sinLayer0 gNB", "title": "5GMax UL MCS vs UL SNR",
         "label": "5G Max Rank1"},
        {"x_header": "iperf_avg_tput", "y_header": "CarrierIdType->PUCCH Data->Pathloss",
         "title": "5GMax UL throughput vs UL Pathloss", "label": "5G Max Rank1"},
        {"x_header": "iperf_avg_tput", "y_header": "CarrierIdType->PUSCH Data->Pathloss",
         "title": "5GMax UL throughput vs UL Pathloss", "label": "5G Max Rank1"},
        {"x_header": "MEAN MCS gNB UL", "y_header": "Cell Quality RSRP",  "title": "5GMax UL MCS vs DL RSRP",
         "label": "5G Max Rank1"},
        {"x_header": "MEAN MCS gNB UL", "y_header": "CarrierIdType->PUCCH Data->Pathloss",
         "title": "5GMax UL MCS vs UL PathLoss", "label": "5G Max Rank1"},
        {"x_header": "MEAN MCS gNB UL", "y_header": "CarrierIdType->PUSCH Data->Pathloss",
         "title": "5GMax UL MCS vs UL PathLoss", "label": "5G Max Rank1"},
        {"x_header": "iperf_avg_tput", "y_header": "rssi gNB", "title": "5GMax UL throughput vs RSSI",
         "label": "5G Max Rank1"}
]


@log_function_status_to_console(msg="Create Summary Excel Report with Graphs", log_hierarchy=2)
def create_summary_excel_report(csv_summary_path):
    excel_file_path = CsvReport.convert_csv_to_excel(csv_file_path=csv_summary_path)
    excel_report = ExcelReport(excel_file_path)

    anchors = _generate_anchors(graphs_data, excel_report)

    iter_anchors = iter(anchors)
    for graph in graphs_data:
        excel_report.add_graph_to_excel(x_header=graph["x_header"], y_header=graph["y_header"], title=graph["title"],
                                        label=graph["label"], anchor=next(iter_anchors))
    return excel_file_path


@log_function_status_to_console(msg="Create Collective Excel Report with Graphs", log_hierarchy=2)
def create_collective_excel_report(excel_reports_dict, log_dir=None, filename="collective_summary_report.xlsx"):
    log_dir = log_dir if log_dir else get_builtin_value('RFP_LOGS')
    collective_report_path = os.path.join(log_dir, filename)
    collective_report = _prepare_collective_report_from_files(excel_reports_dict, collective_report_path)

    data = []
    collective_report.add_worksheet(name="Collective")
    collective_graphs_data = []
    for graph_data in graphs_data:
        x_header = graph_data["x_header"]
        y_header = graph_data["y_header"]
        x_data = []
        y_data = []
        single_graph_data = {}
        for sheetname in collective_report.worksheets[:-1]:
            x_column = collective_report.get_column_values_by_header(header_name=x_header, sheetname=sheetname)
            x_column[0] = "{} {}".format(x_column[0], sheetname)
            x_data.append(x_column)
            y_column = collective_report.get_column_values_by_header(header_name=y_header, sheetname=sheetname)
            y_column[0] = "{} {}".format(y_column[0], sheetname)
            y_data.append(y_column)
            single_graph_data[sheetname] = {
                "x_header": x_column[0],
                "y_header": y_column[0]
            }
        data.extend(x_data)
        data.extend(y_data)
        collective_graphs_data.append({"graph_lines_params": single_graph_data,
                                       "x_axis_title": x_header,
                                       "y_axis_title": y_header,
                                       "graph_title": graph_data["title"]})
    full_data = list(zip(*data))
    collective_report.add_data_to_worksheet(data=full_data, name="Collective")

    _add_graphs_to_collective_report(collective_graphs_data, collective_report)

    return collective_report_path


def _prepare_collective_report_from_files(excel_reports_dict, collective_report_path):
    collective_report = ExcelReport(collective_report_path)
    for sheetname in excel_reports_dict.keys():
        report_path = excel_reports_dict[sheetname]
        worksheet = ExcelReport(report_path).get_worksheet()
        if not collective_report.file_exists:
            rows = list(worksheet.values)
            collective_report.create_new_excel_file(headers=rows[0], data=rows[1:], sheetname=sheetname)
        else:
            rows = list(worksheet.values)
            collective_report.add_worksheet(name=sheetname)
            collective_report.add_data_to_worksheet(data=rows, name=sheetname)
    return collective_report


def _add_graphs_to_collective_report(collective_graphs_data, collective_report):
    anchors = _generate_anchors(collective_graphs_data, collective_report)

    iter_anchors = iter(anchors)
    for graph in collective_graphs_data:
        collective_report.add_multi_line_graph_to_excel(graph_lines_params=graph["graph_lines_params"],
                                                        x_axis_title=graph["x_axis_title"],
                                                        y_axis_title=graph["y_axis_title"],
                                                        graph_title=graph["graph_title"],
                                                        anchor=next(iter_anchors),
                                                        sheetname="Collective")


def _generate_anchors(graphs_data, excel_report):
    anchors = []
    anchor_col = ["A", "K", "U"]
    anchor_row = excel_report.get_max_row() + 3
    while len(anchors) < len(graphs_data):
        for col in anchor_col:
            anchors.append("{}{}".format(col, anchor_row))
        anchor_row = anchor_row + 17
    return anchors


@log_function_status_to_console(msg="Start Collecting Sherpa logs", log_hierarchy=3)
def start_collecting_sherpa_logs(log_dir=None):
    gnblog = GenericSherpaCollector()
    gnblog.start_collecting_sherpa_tcpdump()


@log_function_status_to_console(msg="Start Collecting QXDM logs", log_hierarchy=3)
def start_collecting_qxdm_logs(duration=6, python_path=None):
    qxdmcolection.start_collecting_qxdm_logs(duration=duration, python_path=python_path)


@log_function_status_to_console(msg="Stop Collecting Sherpa logs", log_hierarchy=3)
def stop_collecting_sherpa_logs(log_dir=None):
    gnblog = GenericSherpaCollector()
    log_path = gnblog.stop_collecting_sherpa_tcpdump(log_dir=log_dir)
    set_robot_test_variable('sherpa_pcap_log_path', log_path)
    return log_path


@log_function_status_to_console(msg="Convert QXDM log to txt", log_hierarchy=3)
def convert_qxdm_log_to_txt():
    qxdmcolection.convert_qxdm_log_to_txt()


@log_function_status_to_console(msg="Convert Sherpa log to csv", log_hierarchy=3)
def convert_sherpa_log_to_csv(log_path=None):
    if log_path is None:
        log_path = get_builtin_value('sherpa_pcap_log_path')
        log_path = os.path.join(log_path, os.path.basename(log_path))
        log_path = "{}.pcap".format(log_path)
    gnblog = GenericSherpaCollector()
    gnblog.convert_sherpa_pcap_log_to_csv(path_to_pcap=log_path, output_dir=os.path.dirname(log_path))

    dir_path_to_converted_logs = os.path.splitext(log_path)[0]
    iteration_log_dir = os.path.dirname(os.path.dirname(log_path))
    sherpa_logs_dir = os.path.join(iteration_log_dir, 'sherpa')
    make_local_logs_directory(log_dir=sherpa_logs_dir)
    change_file_name_on_local_pc(current_name=os.path.join(dir_path_to_converted_logs, '*'), new_name=sherpa_logs_dir)
    clear_local_logs_directory(log_dir=os.path.dirname(log_path), all_files_in_dir=False)


@log_function_status_to_console(msg="Download QXDM logs", log_hierarchy=3)
def download_qxdm_logs(log_dir=None):
    qxdmcolection.download_qxdm_logs(log_dir=log_dir)


@MolerTest.raise_background_exceptions()
def start_ue_drop_observer(bts_id=0, du_id=0, timeout=2 * 60 * 60):
    """
    Based on sylsog observer.
    :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :param timeout: timeout for running observer
    :return:
    """
    def _ue_drop_callback(variable, event):
        log_info_to_console(msg="UE Dropped - stopping procedure", log_hierarchy=1)
        last_occurrence = event.get_last_occurrence()
        variable.append(last_occurrence)
        MolerTest.info(msg="Matched{}".format(last_occurrence['matched']))

    _re_ue_drop = r'ConcreteUeNsaSgnbReleaseRequest.*Received SgnbReleaseRequest'

    GnbBtslogCollector().start_collecting_syslog(bts_id=bts_id, du_id=du_id)
    syslog_device = DeviceFactory.get_device(name=connection_names.syslog_bts_du.format('GNB', bts_id, du_id))
    # syslog_device.disable_logging()

    syslog_event = syslog_device.get_event(
        event_name="wait4",
        event_params={"detect_patterns": [_re_ue_drop],
                      "till_occurs_times": 1}
    )

    exit_loop = []
    set_robot_test_variable('Exit_Loop', exit_loop)
    syslog_event.add_event_occurred_callback(
        callback=_ue_drop_callback,
        callback_params={
            "variable": exit_loop,
            "event": syslog_event
        }
    )

    syslog_event.start(timeout=timeout)


def start_sherpa_trace():
    try:
        GenericSherpaCollector().start_streaming_sherpa_logs()
    except Exception as e:
        logging.warning("Probably sherpa is already started. Stop it and start again")
        logging.debug("Exception {}".format(repr(e)))
        GenericSherpaCollector().stop_streaming_sherpa_logs()
        GenericSherpaCollector().start_streaming_sherpa_logs()


def set_used_physical_cell_id(bts_id=0, du_id=0):
    if get_builtin_value('USED_PHYSICAL_CELL_ID'):
        logging.debug("USED_PHYSICAL_CELL_ID already set to {} - "
                      "skipping obtaining automatically".format(get_builtin_value('USED_PHYSICAL_CELL_ID')))
    else:
        gco = GnbCellOperations()
        gco.connect(bts_id=bts_id, du_id=du_id)
        cell_ids = gco._get_all_physical_cell_ids(bts_id=bts_id, du_id=du_id, cell_type='nr')
        used_cell_id = cell_ids[0]
        logging.debug("Setting USED_PHYSICAL_CELL_ID={}".format(used_cell_id))
        set_robot_suite_variable('USED_PHYSICAL_CELL_ID', used_cell_id)

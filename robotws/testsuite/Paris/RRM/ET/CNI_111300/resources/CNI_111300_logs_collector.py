"""
:author: Anna Bien
:maintainer: Anna Bien
:owner_email: anna.bien@nokia.com
:team: I_5G_SW_MMW_PLKRK_04
:email: I_5G_SW_MMW_PLKRK_04@nokia.com
:description: Internal resurces for CNI_111300
"""

import os
import shutil

from taf.converters.eventdecoder import eventdecoder
from taf.internal.sw.dcap.rd.client.dcap_lite.v3.exceptions import ApiException

from testsuite.Paris.RRM.ET.resources_KRK.python.dcap import Dcap
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_warning
from testsuite.Paris.RRM.ET.resources_KRK.python.common_wts import (
    start_collecting_ueapp_sosreport, stop_collecting_ueapp_sosreport
)
from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import collect_gnb_snapshot
from testsuite.Paris.RRM.ET.resources_KRK.python.logs_collector import (
    start_collecting_basic_logs, stop_collecting_basic_logs
)
from testsuite.Paris.RRM.ET.resources_KRK.python.tshark_operations import (
    start_capturing_traffic_on_vm_interface, stop_capturing_traffic_on_vm, terminate_all_traffic_capture_on_vm
)

from testsuite.Paris.RRM.ET.CNI_111300.resources.variables import *
from testsuite.Paris.RRM.ET.CNI_111300.resources.CNI_111300_resources import get_log_dir


class LogsCollector:

    def __init__(self):
        self.log_path = ''
        self.l2_ps_component_list = ['L2Ps_Component']
        self.l2_hi_component_list = ['L2HiRlc_Component', 'L2HiPdcp_Component']
        self.l2_lo_component_list = ['L2Lo_Component']
        self.emil_component_list = ['cp_5g']
        self.bts_details = {'host': GNB_IP, 'username': WEBEM_USERNAME, 'password': WEBEM_PASSWORD, 'port': '443'}
        self.dcap_instance = Dcap()

    def set_test_log_path(self):
        self.log_path = get_log_dir()

    def enable_dcap(self):
        self.dcap_instance.start_dcap_basic_controller()

    def _start_collecting_traces(self, component_list):
        """
        Start Dcap trace.
        """

        self.dcap_instance.create_dcap_session()
        self.dcap_instance.check_if_bts_is_configured_in_dcap()
        try:
            trace_id = self.dcap_instance.start_new_trace(
                bts_details=self.bts_details,
                gnb_custom_profile=component_list
            )
        except (RuntimeError, ApiException) as trace_failure:
            logger_warning(f'Starting tew trace has failed: {trace_failure}. Performing second attempt...')
            self.dcap_instance.delete_bts_from_dcap(bts_id=self.dcap_instance.get_dcap_bts_id(ip=GNB_IP))
            self.dcap_instance.create_dcap_session()
            self.dcap_instance.check_if_bts_is_configured_in_dcap()
            trace_id = self.dcap_instance.start_new_trace(
                bts_details=self.bts_details,
                gnb_custom_profile=component_list
            )
        return trace_id

    def start_collecting_tti_traces(self):
        """
        Start Dcap trace to collect TTI Traces.
        """

        component_list = self.l2_ps_component_list
        return self._start_collecting_traces(component_list)

    def start_collecting_emil_and_l2hi_traces(self):
        """
        Start Dcap trace to collect Emil and L2-HI Traces.
        """

        component_list = self.emil_component_list + self.l2_hi_component_list
        return self._start_collecting_traces(component_list)

    def stop_collecting_traces(self, trace_id=None, dcap_zip_filename='dcap_tti_trace.zip'):
        """
        Stop Dcap trace and download collected logs.
        """

        target_path = os.path.join(self.log_path, dcap_zip_filename)
        self.dcap_instance.create_dcap_session()
        self.dcap_instance.stop_trace(ip=GNB_IP, trace_id=trace_id)
        self.dcap_instance.get_result_file(
            target_dir=target_path,
            trace_id=trace_id
        )
        return target_path

    def extract_dcap_zip(self, dcap_zip_filename):
        """
        Unpack DCAP results .zip file

        :param dcap_zip_filename: (str) Name of DCAP results .zip file
        """

        dcap_zip_file_path = os.path.join(self.log_path, dcap_zip_filename)
        extract_dir_path = dcap_zip_file_path.replace('.zip', '')
        shutil.unpack_archive(dcap_zip_file_path, extract_dir=extract_dir_path)
        return extract_dir_path

    @staticmethod
    def _find_pcap_in_dcap_results(dcap_results_dir):
        """
        Find all pcap files in DCAP results directory.

        :param dcap_results_dir: (str) Path to unpacked DCAP results directory
        :return: Pcap file paths (list)
        """

        pcap_filepaths = []
        pcap_filepaths_last_run = []
        for root, dirnames, filenames in os.walk(dcap_results_dir):
            for filename in filenames:
                if filename.endswith('.pcap'):
                    pcap_filepaths.append(os.path.join(root, filename))
        pcap_filepaths.sort()
        last_run = pcap_filepaths[-1].split('/')[-5] + pcap_filepaths[-1].split('/')[-4]
        for filepath in pcap_filepaths:
            if filepath.split('/')[-5] + filepath.split('/')[-4] == last_run:
                pcap_filepaths_last_run.append(filepath)
        return pcap_filepaths_last_run

    def extract_tti_from_dcap_zip(self, dcap_zip_filename='dcap_tti_trace.zip', output_file_format='legacyCsv',
                                  excel_csv_options='-d combineDlAndUl', ):
        """
        Convert TTI traces from .pcap to .csv

        :param dcap_zip_filename: (str) Name of DCAP results .zip file
        :param output_file_format: (str) e.g. 'json', 'legacyCsv' or 'excelCsv'
        :param excel_csv_options: (str)
        """

        extracted_dir = self.extract_dcap_zip(dcap_zip_filename)
        pcap_filepaths = self._find_pcap_in_dcap_results(extracted_dir)
        ed = eventdecoder()
        for index in range(len(pcap_filepaths)):
            ed.create_eventdecoder_converter(
                name='ttitrace_converter',
                input_file_path=pcap_filepaths[index],
                output_file_format=output_file_format,
                output_file_path=os.path.join(extracted_dir, f'tti_trace{str(index)}'),
                excel_csv_options=excel_csv_options
            )
            ed.convert(name='ttitrace_converter')
        return extracted_dir

    def start_collecting_sosreport(self):
        """
        Start collecting ue app sosreport.
        """

        start_collecting_ueapp_sosreport(
            stdout_file_path=os.path.join(self.log_path, 'start_sosreport_output.log')
        )

    def stop_collecting_sosreport(self):
        """
        Stop collecting ue app sosreport. If test is PASS, no sosreport logs are collected.
        """

        stop_collecting_ueapp_sosreport(
            destination_path_for_sosreport=self.log_path,
            stdout_file_path=os.path.join(self.log_path, 'stop_sosreport_output.log')
        )

    def start_collecting_sctp_tcpdump(self, filename):
        """
        Start collecting tcpdump on VM with SCTP filter.

        :param filename: (str) Target filename
        """

        start_capturing_traffic_on_vm_interface(
            capture_filter='sctp',
            file_dir=self.log_path,
            file_name=filename
        )

    @staticmethod
    def stop_collecting_sctp_tcpdump():
        """
        Stop collecting tcpdump on VM.
        """

        stop_capturing_traffic_on_vm()

    @staticmethod
    def terminate_all_background_tcpdump_processes():
        terminate_all_traffic_capture_on_vm()

    def collect_snapshot(self, filename):
        """
        Collect snapshot at common log dir

        :param filename: (str) Filename of snapshot file *.zip
        """

        collect_gnb_snapshot(
            output_filepath=os.path.join(self.log_path, filename)
        )

    def start_collecting_syslog(self):
        start_collecting_basic_logs(log_dir=self.log_path)

    def stop_collecting_syslog_and_save_cfg_files(self):
        stop_collecting_basic_logs(log_dir=self.log_path)

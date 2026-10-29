"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import os
import re
import xml.etree.ElementTree as ET
from datetime import datetime
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ScriptIssue, EnvironmentIssue)
import testsuite.Oulu.TrunkEng.Common.Python.Resources.GetFileFromArchivedFolder as GetFromArchived
from testsuite.Oulu.TrunkEng.OMKPI.Python.Resources.exceptions import NoKpi77aStartPoints, NoKpi77aEndPoints


class Kpi77aFilesAndStrings:
    """Class for KPI#77a calculations - Getting files and strings needed for calculations"""
    bbdmod_cpri_starttime = {}
    bbdmod_cpri_endtimes = {}

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")

    def _get_unit_and_times(self, print_list):
        """
        Get unit and times from KPI77a start point strings

        :param print_list: list of KPI77a start point strings
        :return: dictionary of bbmod_cpri and their corresponding KPI77a start point times
        """
        all_dict = {}
        self.logger.debug(f"KPI77a start point strings found: {len(print_list)}")
        for line in print_list:
            m = re.search(r"<(?P<timestamp>.*)>.*(?P<bbmod>BBMOD_L-\d+:CONNECTOR_L-\d+).*cpriLink\s+(?P<cpri_link>\d+)",
                          line)
            if m:
                dt_str = m.group("timestamp")
                t_obj = datetime.strptime(dt_str.rstrip("Z"), "%Y-%m-%dT%H:%M:%S.%f")
                if f"{m.group('bbmod')} - cpriLink:{m.group('cpri_link')}" not in all_dict:
                    all_dict[f"{m.group('bbmod')} - cpriLink:{m.group('cpri_link')}"] = [t_obj]
                else:
                    all_dict[f"{m.group('bbmod')} - cpriLink:{m.group('cpri_link')}"].append(t_obj)
        return all_dict

    def _parse_timestamps(self, timestamp, all_dict):
        """
        Parse timestamps from KPI77a start point strings

        :param timestamp: timestamp when KPI77a test case started
        :param all_dict: dictionary of bbmod_cpri and their corresponding KPI77a start point times
        :return: None
        """
        for bbmod_and_cpri, cpri_lost_times in all_dict.items():
            after_list = [dt for dt in cpri_lost_times if dt > timestamp]
            if not after_list:
                error(f"For {bbmod_and_cpri} no KPI77a start point found after test case start time "
                      f"{timestamp.strftime('%Y-%m-%d %H:%M:%S.%f')}")
            else:
                closest = min(after_list, key=lambda dt: dt - timestamp)
                info(f"KPI77a start point for {bbmod_and_cpri} found at {closest.strftime('%Y-%m-%d %H:%M:%S.%f')}")
                Kpi77aFilesAndStrings.bbdmod_cpri_starttime[bbmod_and_cpri] = closest
        self.logger.debug(f"KPI77a start points:\n{Kpi77aFilesAndStrings.bbdmod_cpri_starttime}")

    def get_kpi77a_startpoint_file(self, timestamp):
        """
        Get kpi77a startpoint file gets KPI77a needed files and strings from snapshot file collected from remote BTS

        :param timestamp: timestamp when KPI77a test case started
        :return: path to the uncompressed file runtime_SYSTEM_PLH_DBG.log
        """
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        swdl_info = BuiltIn().get_variable_value("${EXTRA_INFO_FOR_LOOP}")
        # make sure that snapshot is from the time when SWDL has been done to DU not when SWDL done to RU
        if (not self.collect_logs.snapshot_file_remote or "RF_SWDL_of_" in self.collect_logs.snapshot_file_remote or
                "Rollback_from_" in self.collect_logs.snapshot_file_remote or
                swdl_info[1:] not in self.collect_logs.snapshot_file_remote):
            info("Get snapshot from remote BTS")
            self.collect_logs.collect_snapshot(just_remote=True)
        if not self.collect_logs.snapshot_file_remote:
            error("No snapshot file get from remote BTS. Unable to get KPI77a start point file.")
            raise EnvironmentIssue("No snapshot file get from remote BTS. Unable to get KPI77a start point file.")
        info(f"Getting startpoint file for KPI#77a calculations from {self.collect_logs.snapshot_file_remote}")
        start_point_file = self.collect_logs.get_file_from_zip_or_tar(
            "runtime_SYSTEM_PLH_DBG.log.xz", archived_path=self.collect_logs.snapshot_file_remote,
            folder_to_extract=self.logger.log_dir, upper_folder="_1011_runtime.zip")
        if not start_point_file:
            error("No start point file runtime_SYSTEM_PLH_DBG.log.xz found from snapshot. Check if filename has "
                  "changed.")
            raise EnvironmentIssue("No start point file found from snapshot.")
        info(f"Start point file found: {start_point_file}")
        print_to_search = r"received API_CPRI_STATE_IND_MSG \[cpriLink \d+, cpriState B\]"
        print_list, uncompressed_file = GetFromArchived.search_from_xz_gz_archive(start_point_file, print_to_search,
                                                                                  return_multiple=True,
                                                                                  add_to_folder="startpoint_logs",
                                                                                  remove_compressed=True)
        if not print_list:
            error(r"No KPI77a start point string found from start point file (no line containing received "
                  r"API_CPRI_STATE_IND_MSG [cpriLink \d+, cpriState B]).")
            raise NoKpi77aStartPoints("No KPI77a start point string found from file runtime_SYSTEM_PLH_DBG.log.")
        all_dict = self._get_unit_and_times(print_list)
        if not all_dict:
            error(r'Regex "<(?P<timestamp>.*)>.*(?P<bbmod>BBMOD_L-\d+:CONNECTOR_L-\d+).*cpriLink\s+(?P<cpri_link>\d+)"'
                  r'was not working. Check if regex needs some modifications.')
            raise NoKpi77aStartPoints("Unable to parse start point information from file runtime_SYSTEM_PLH_DBG.log.")
        self._parse_timestamps(timestamp, all_dict)
        info(f"KPI77a start point file for calculations: {uncompressed_file}")
        return uncompressed_file

    def parse_end_point_xml(self, file_path, swdl_timestamp, just_lte=True):
        """
        Parse end point xml parses KPI77a end point XML file to get busy to ready transitions.

        :param file_path: path to the KPI77a end point XML file
        :param swdl_timestamp: timestamp when software download started, datetime object
        :param just_lte: if True, prints only LTE related entries
        :return: list of dictionaries with 'from_distname' and 'timestamp' keys
        """
        if not swdl_timestamp:
            error("Parameter swdl_timestamp is None, cannot parse end point XML without SWDL start time.")
            raise ScriptIssue("swdl_timestamp is None, cannot parse end point XML without SW timestamp.")
        with open(file_path, 'r', encoding='utf-8') as f:
            xml_content = f.read()
        # Remove SOAP-ENV namespace for easier parsing
        xml_content = xml_content.replace('SOAP-ENV:', '')
        # Split envelopes and timestamps
        envelope_blocks = re.split(r'(<Envelope.*?</Envelope>)', xml_content, flags=re.DOTALL)
        busy_to_ready_results = []
        # iterate over the indices of envelope_blocks the envelopes are at odd indices (1, 3, 5, ...), and the
        # UTC-Timestamps or separators are at even indices (0, 2, 4, ...)
        for i in range(1, len(envelope_blocks), 2):
            dt_obj = None
            radio = ""
            envelope_xml = envelope_blocks[i]
            # Find the next UTC-Timestamp after this envelope
            timestamp_match = re.search(r'<UTC-Timestamp>(.*?)</UTC-Timestamp>',
                                        envelope_blocks[i + 1] if i + 1 < len(envelope_blocks) else '')
            utc_timestamp = timestamp_match.group(1) if timestamp_match else None
            if utc_timestamp is not None:
                dt_obj = datetime.strptime(utc_timestamp.rstrip("Z"), "%Y-%m-%dT%H:%M:%S.%f")
            if dt_obj:
                self.logger.debug(f"Parsed UTC-Timestamp: {dt_obj} from envelope index {i}")
                root = ET.fromstring(envelope_xml)
                for rmod in root.findall('.//from'):
                    if rmod is not None:
                        radio = rmod.text
                for mo in root.findall('.//managedObject'):
                    mo_class = mo.get('class')
                    if mo_class in ('Tx', 'Rx'):
                        for o in mo.findall('.//operation'):
                            if o is not None:
                                if o.text == "update_parm":
                                    mo_distname = mo.get('distName')
                                    for param in mo.findall('.//parameter'):
                                        pname = param.findtext('parameterName')
                                        if pname == "state":
                                            nval = param.find('newValue')
                                            pval = param.find('prevValue')
                                            if "READY" in nval.text and "BUSY" in pval.text:
                                                if dt_obj > swdl_timestamp:  # we are interested only times after SWDL
                                                    print(f"The {pname} of {radio} - {mo_distname} changed from "
                                                          f"{pval.text} to {nval.text} at {utc_timestamp}")
                                                    self.logger.debug(f"Busy to Ready transition found for {radio} - "
                                                                      f"{mo_distname} at {utc_timestamp}")
                                                    if just_lte and mo_distname[0] == "L":
                                                        busy_to_ready_results.append({
                                                            'from_distname': f"{radio} - {mo_distname}",
                                                            'timestamp': dt_obj
                                                        })
                                                    elif not just_lte:
                                                        busy_to_ready_results.append({
                                                            'from_distname': f"{radio} - {mo_distname}",
                                                            'timestamp': dt_obj
                                                        })
        self.logger.debug(f"Busy to Ready transitions: {busy_to_ready_results}")
        return busy_to_ready_results

    def get_kpi77a_endpoint_files(self, swdl_timestamp):
        """
        Get kpi77a endpoint files gets KPI77a needed files and strings from snapshot file collected from remote BTS

        :param swdl_timestamp: timestamp when SWDL of KPI77a started
        :return: dictionary of bbmod_cpri and their corresponding uncompressed file runtime_SYSTEM_PLH_DBG.log
        """
        if not self.collect_logs:
            BuiltIn().get_library_instance("COLLECTLOGS")
        # make sure that snapshot is from the time when SWDL has been done to DU not when SWDL done to RU
        if (not self.collect_logs.snapshot_file_remote or "RF_SWDL_of_" in self.collect_logs.snapshot_file_remote
                or "Rollback_from" in self.collect_logs.snapshot_file_remote):
            info("Get snapshot from remote BTS")
            self.collect_logs.collect_snapshot(just_remote=True)
        if not self.collect_logs.snapshot_file_remote:
            error("No snapshot file get from remote BTS. Unable to get KPI77a endpoint files.")
            raise EnvironmentIssue("No snapshot file get from remote BTS. Unable to get KPI77a endpoint files.")
        info(f"Getting endpoint files for KPI#77a calculations from {self.collect_logs.snapshot_file_remote}")
        endpoint_files = self.collect_logs.get_file_from_zip_or_tar(
            "_SOAPCFG.xml.gz", archived_path=self.collect_logs.snapshot_file_remote,
            folder_to_extract=self.logger.log_dir, get_multiple_files=True)
        if not endpoint_files:
            info("No _SOAPCFG.xml.gz files found from snapshot, checking if _SOAPMessageTraceCFG.xml.gz files are "
                 "found instead.")
        another_endpoint_files = self.collect_logs.get_file_from_zip_or_tar(
                "_SOAPMessageTraceCFG.xml.gz", archived_path=self.collect_logs.snapshot_file_remote,
                folder_to_extract=self.logger.log_dir, get_multiple_files=True, print_if_not_found=False)
        if another_endpoint_files:
            endpoint_files.extend(another_endpoint_files)
        else:
            info("SOAPMessageTraceCFG.xml.gz files were not found from snapshot.")
        if not endpoint_files:
            error("No endpoint file _SOAPCFG.xml.gz nor _SOAPMessageTraceCFG.xml.gz found from snapshot. Check if "
                  "there has been some unexpected reset during test or if filename has changed.")
            raise NoKpi77aEndPoints("No endpoint file found from snapshot.")
        info(f"Endpoint files are found:\n{endpoint_files}")
        info(f"Parsing endpoint files to get Busy to Ready transitions after SWDL start time "
             f"{swdl_timestamp.strftime('%Y-%m-%dT%H:%M:%S.%f')}.")
        return_end_point_files = []
        for e_file in endpoint_files:
            uncompressed_file = GetFromArchived.unarchive_xz_gz_file(e_file, save_path=self.logger.log_dir,
                                                                     add_to_folder="endpoint_logs",
                                                                     remove_compressed=True)
            if uncompressed_file and uncompressed_file not in return_end_point_files:
                return_end_point_files.append(uncompressed_file)
                list_of_timestamp_dicts = self.parse_end_point_xml(uncompressed_file, swdl_timestamp)
                serial_numer_l_name = re.search(r"\w+_\d+_(?P<rmod>\w+_RMOD_\d+)", uncompressed_file)
                if serial_numer_l_name:
                    key = serial_numer_l_name.group(0)
                    if key not in self.bbdmod_cpri_endtimes:
                        self.bbdmod_cpri_endtimes[key] = list_of_timestamp_dicts
        if self.bbdmod_cpri_endtimes:
            for radiounit, timestamp_list in self.bbdmod_cpri_endtimes.items():
                if timestamp_list:
                    info(f"Busy to Ready transitions for {radiounit}:")
                    for entry in timestamp_list:
                        timestamp = entry['timestamp']
                        formatted_time = timestamp.strftime('%Y-%m-%d %H:%M:%S.%f')
                        info(f"\t{entry['from_distname']}: {formatted_time}")
                else:
                    info(f"No Busy to Ready transitions found for {radiounit} after SWDL start time:"
                         f"{swdl_timestamp.strftime('%Y-%m-%d %H:%M:%S.%f')}.")
        if not return_end_point_files:
            error("No files get from remote snapshot that includes KPI77a endpoints")
            raise NoKpi77aEndPoints("No KPI77a endpoint files found from file runtime_SYSTEM_PLH_DBG.log.")
        info(f"KPI77a endpoint files:\n{return_end_point_files}")
        return return_end_point_files

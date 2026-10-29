"""
:author: Anna Bien
:maintainer: Anna Bien
:owner_email: anna.bien@nokia.com
:team: I_5G_SW_MMW_PLKRK_04
:email: I_5G_SW_MMW_PLKRK_04@nokia.com
"""

import os
import re
import math
import pkgutil
import importlib
import collections
import subprocess as sp
import xml.etree.ElementTree as ET
from xml.dom import minidom
from datetime import datetime, timedelta
from pathlib import Path

from taf.rfrl.utilities.robot.general import get_builtin_value
from robot.libraries.BuiltIn import BuiltIn

from testsuite.Krakow.RRM.Airphone.resources.Python.pcap_validation import (
    convert_pcap_to_json_using_tshark,
    read_json_file,
)
from testsuite.Krakow.RRM.Airphone.resources.Python.egate_console_msg import (
    EgateConsoleMsg,
)
from testsuite.Krakow.RRM.Airphone.resources.Python.common_gnb import (
    load_scf_from_site_and_get_taf_scf_instance,
    handle_admin, get_parameter_value_from_scf,
)
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import (
    logger_info,
    logger_console_info,
    logger_warning,
    logger_debug,
)
from testsuite.Krakow.RRM.Airphone.CB010636.resources.utilities import get_log_dir
from testsuite.Krakow.RRM.Airphone.CB010636.resources.utilities import get_test_prefix
from testsuite.Krakow.RRM.Airphone.CB010636.resources.variables import *
from testsuite.Krakow.RRM.Airphone.CB010636.resources.L3_files.CB010636_CC_counters import (
    get_rlc_times_from_merged_burst_from_all_cells_for_ue, get_csv_list_of_dicts, filter_data_by_key_values,
    inter_gnb_ca_rlc_times
)


class PMCountersValidationFail(Exception):
    pass


class SyscomValidationFail(Exception):
    pass


class Validation:

    def __init__(self):
        release = BuiltIn().get_variable_value("${RELEASE}")
        tti_trace_prefix = '' if release in ['SBTS26R1'] else 'tti_trace_'
        self._csv_file_mapping = {
            "rlc_pdu_vol_ul": f"{tti_trace_prefix}MacSubPduRxAm18.csv",
            "rlc_pdu_vol_dl": f"{tti_trace_prefix}MacSubPduTxAm18.csv",
            "mux": f"{tti_trace_prefix}MacPduMuxReq.csv",
            "burst": f"{tti_trace_prefix}LocalL2LoBurstsTx.csv"
        }
        self._pd = None
        self.pm_counters_dir = os.path.join(os.path.dirname(__file__), "pm_counters")

    def import_pandas(self):
        if not bool(pkgutil.find_loader("pandas")):
            logger_info("Installing pandas")
            sp.call(["pip", "install", "pandas"])
        self._pd = importlib.import_module("pandas")

    @staticmethod
    def get_counters_values_from_report(counters_to_extract, direct_pm_counters_path=None):
        """
        Get values of counters from PM reports.
        Only values for counters passed in counters_to_extract will be obtained
        """

        def validate_file_path(path):
            path_to_validate = Path(path)
            if not path_to_validate.is_absolute():
                return False, "Path is not absolute"
            if not path_to_validate.is_file():
                return False, "File does not exist"
            return True, "Path is correct"

        def get_pm_report_file_path(gnb_alias):
            """
            Returns path to PM counter report.
            """
            if direct_pm_counters_path:
                is_valid, message = validate_file_path(direct_pm_counters_path)
                if is_valid:
                    logger_info(message)
                    return direct_pm_counters_path

            pm_counters_dir = os.path.join(get_log_dir(), f"pm_counters_{gnb_alias}")

            paths_to_pm_file = [filename for filename in os.listdir(pm_counters_dir) if filename.endswith(".xml")]
            if not paths_to_pm_file:
                logger_info("PM counters report path not found.")
                return None
            paths_to_pm_file.sort()
            last_path = paths_to_pm_file[-1]
            path_to_pm_file = os.path.join(pm_counters_dir, last_path)
            logger_info(f"PM counters report path: {path_to_pm_file}")
            return path_to_pm_file

        extracted_counters = collections.defaultdict(dict)
        for gnb in counters_to_extract:
            tree = ET.parse(get_pm_report_file_path(gnb))
            root = tree.getroot()
            for pmmo_result in root.findall(".//PMMOResult"):
                mo_dns = pmmo_result.findall('./MO/DN')
                path_core = mo_dns[0].text
                mid_path = ''
                if len(mo_dns) > 1:
                    mid_path = f'/{mo_dns[1].text.split("/")[-1]}'
                ne_wbts_obj = pmmo_result.find("./NE-WBTS_1.0")
                for counter_to_extract in counters_to_extract[gnb]:
                    counter_path, counter_id = counter_to_extract.rsplit("/", 1)
                    if (
                            counter_path
                            == f"{path_core}/{ne_wbts_obj.attrib['measurementType']}{mid_path}"
                    ):
                        try:
                            ne_wbts_counter = ne_wbts_obj.find(f"./{counter_id}").text
                            extracted_counters[gnb][counter_to_extract] = float(
                                ne_wbts_counter
                            )
                        except AttributeError:
                            logger_warning(
                                f"{counter_to_extract} not found in PM report"
                            )
        return extracted_counters

    def get_csv_files_path(self, filename_key, dir_to_search=None):
        """
        Get paths to csv files that should be validated

        :param filename_key: (str) Key to self._csv_file_mapping map
        :param dir_to_search: (str) Path to tti trace directory
        """

        filename = self._csv_file_mapping[filename_key.lower()]
        file_paths = []
        if dir_to_search:
            search_dir = os.path.join(get_log_dir(), dir_to_search)
        else:
            search_dir = get_log_dir()
        for root, dirs, files in os.walk(search_dir):
            if filename in files:
                csv_filepath = os.path.join(root, filename)
                file_paths.append(csv_filepath)
                logger_info(f"{csv_filepath} will be involved in validation process")
        return file_paths

    def calculate_rlc_pdu_vol(self, cell_mapping, direction, dir_to_search=None):
        """
        Get RLC PDU Vol values from tti traces for single traffic direction.
        Used to create variables defined in resources/pm_counters e.g. D1_2, U2_2 etc.
        """

        def calculate_traffic_from_single_file():
            data = self._pd.read_csv(
                filepath_or_buffer=csv_file_path,
                delimiter=",",
                usecols=["rnti", "physCellId", "rlcAmDc", "macLength", "lcId"],
            )
            grouped_data = data.groupby(["rnti", "physCellId", "lcId"])
            rlc_pdu_vol = collections.Counter()
            rnti_to_ue_dict = {**nsa_rnti_ue_dict, **sa_rnti_ue_dict}

            for (rnti, physCellId, lcId), group in grouped_data:
                if (
                        rnti in rnti_to_ue_dict.keys()
                        and int(physCellId) in cell_mapping.keys()
                ):
                    filtered_group = group[group["rlcAmDc"] == "DATA"]
                    key = f"{direction[0].upper()}{rnti_to_ue_dict[rnti]}_{cell_mapping[int(physCellId)]}_{lcId}"
                    rlc_pdu_vol[key] = filtered_group["macLength"].sum()
            return rlc_pdu_vol

        nsa_rnti_ue_dict = self.get_nsa_rnti_ue_dict()
        sa_rnti_ue_dict = self.get_sa_rnti_ue_dict()
        csv_filepaths = self.get_csv_files_path(filename_key=f'rlc_pdu_vol_{direction}', dir_to_search=dir_to_search)
        tti_traces_traffic = collections.Counter()
        for csv_file_path in csv_filepaths:
            single_file_traffic = calculate_traffic_from_single_file()
            tti_traces_traffic += single_file_traffic
        return tti_traces_traffic

    def get_sum_of_vol_and_duration_from_local_l2lo_bursts(self, csv_file_path, physCellId, rnti, **kwargs):
        """
        Calculates the sum of volInBytes and durationInUs columns for the specified physCellId and rnti.
        Optionally applies thresholds for volume and duration filtering if both
        vol_threshold and duration_threshold are provided in kwargs.

        Args:
            csv_file_path (str): The path to the CSV file containing the data.
            physCellId (int): The physical cell ID.
            rnti (int): UE identifier (RNTI).
            **kwargs: Optional thresholds for volInBytes and durationInUs filtering.
                - volume_threshold (int): The threshold for volInBytes filtering.
                - duration_threshold (int): The threshold for durationInUs filtering.

        Returns:
            tuple: Tuple containing the sum of volInBytes and durationInUs.
        """

        csv_data = get_csv_list_of_dicts(csv_file_path)
        filtered_data = filter_data_by_key_values(csv_data, physCellId=physCellId, rnti=rnti)

        volume_threshold = kwargs.get("volume_threshold")
        duration_threshold = kwargs.get("duration_threshold")

        if volume_threshold is not None and duration_threshold is not None:
            additional_filtered_data = [
                row for row in filtered_data
                if (int(row["volInBytes"]) > volume_threshold * 1000 and
                    int(row["durationInUs"]) > duration_threshold * 1000)
            ]
        else:
            additional_filtered_data = filtered_data

        total_vol_in_bytes = sum(int(row['volInBytes']) for row in additional_filtered_data)
        total_duration_in_us = sum(int(row['durationInUs']) for row in additional_filtered_data)

        return total_vol_in_bytes, total_duration_in_us

    def get_sum_of_component_values(self, counters, traffic_data):
        """
        Calculates the sum of component values based on the provided counters and traffic data.

        Args:
            counters (str): The counters to be processed e.g. time_MAC_D11_1 + time_MAC_D12_1
            traffic_data (dict): The traffic data with volume or duration values.
            e.g. Counter({'RLC_D12_1': 41668.872, 'MAC_D12_1': 1187.28})

        Returns:
            str: The sum of component values. e.g. RLC_D11_1 + RLC_D11_2 + RLC_D11_3

        """

        sum_of_component_values = counters
        matches = re.findall(r'\b\w+\b', counters)
        for match in matches:
            if match in traffic_data or any(f"{match}_{cell}" in traffic_data for cell in range(1, 9)):
                parts = [f"{match}_{cell}" for cell in range(1, 9) if f"{match}_{cell}" in traffic_data]
                if parts:
                    sum_of_component_values = sum_of_component_values.replace(match, " + ".join(parts))
        return sum_of_component_values

    def calculate_expected_pm_counters_values(self, counters_to_calculate, suffix, direct_pm_counters_path,
                                              dir_to_search=None, diff_period_counters=None):
        """
        This method computes the expected PM counter values by invoking the appropriate
        calculation functions for each counter specified.

        Args:
            counters_to_calculate (dict): A dictionary where keys are the names of the counters to calculate,
                                          and values are the configurations or parameters required for the calculation.
            suffix (str): The suffix to append to PM counter names or filenames.
            direct_pm_counters_path (str): The path where direct PM counters data is located.
            dir_to_search (str, optional): The directory to search for additional files. Defaults to None.
            diff_period_counters (dict, optional): A dictionary containing counters from different period.
                                                       Defaults to None.

        Returns:
            dict: A dictionary containing the calculated counter values for each gNB. The structure of the dictionary
                  matches the structure of `counters_to_calculate`, with calculated values replacing the configurations
                  or parameters.

        Raises:
            PMCountersValidationFail: If the traffic data could not be calculated based on TTI Traces.
        """
        test_name = BuiltIn().get_variable_value("${TEST_NAME}")
        if "6CC" in test_name:
            if "019" in test_name:
                test_item = "b"
            elif "020" in test_name:
                test_item = "c"
            elif "022" in test_name:
                test_item = "d"
            else:
                test_item = "a"
        else:
            test_item = get_test_prefix()[0]
        traffic_data = collections.Counter()
        cell_mapping = self.get_cell_mapping()
        if any(c in test_item for c in ["a"]):
            traffic_data += self.calculate_rlc_pdu_vol(
                cell_mapping=cell_mapping, direction="dl", dir_to_search=dir_to_search
            )
            traffic_data += self.calculate_rlc_pdu_vol(
                cell_mapping=cell_mapping, direction="ul", dir_to_search=dir_to_search
            )
        if any(c in test_item for c in ["b", "e"]):
            traffic_data += self.calculate_rlc_pdu_vol_burst(cell_mapping=cell_mapping)
            traffic_data += self.calculate_mac_sdu_burst(cell_mapping=cell_mapping)
            traffic_data += self.calculate_merged_burst()
            if get_test_prefix() in SYSLOG_VALIDATION_TCS:
                traffic_data += self.calculate_rlc_pdu_vol_burst_from_syslog()
        if any(c in test_item for c in ["c"]):
            traffic_data += self.get_volume_and_time_per_cc_counters(
                suffix=suffix,
                direct_pm_counters_path=direct_pm_counters_path)
            traffic_data += self.parse_diff_period_counters(diff_period_counters)
        if any(c in test_item for c in ["d"]):
            traffic_data += self.calculate_rlc_pdu_vol_burst_from_syslog()
            # traffic_data += self.calculate_throughput_per_mhz_denominator()
            # TODO traffic_data += self.calculate_burst_amount_and_time_per_cc()
        traffic_data = self.get_summed_traffic_components(traffic_data)
        if not traffic_data:
            raise PMCountersValidationFail(
                "Could not calculate traffic based on TTI Traces"
            )
        logger_debug(f"Traffic mapped per UE and cell: {traffic_data}")

        calculated_counters = collections.defaultdict(dict)
        for gnb in counters_to_calculate.keys():
            for counter in counters_to_calculate[gnb].keys():
                if counters_to_calculate[gnb][counter] == ">0":
                    calculated_counters[gnb][counter] = ">0"
                elif counters_to_calculate[gnb][counter] == "any":
                    calculated_counters[gnb][counter] = "any"
                elif "DIFF_PERIOD" in str(counters_to_calculate[gnb][counter]):
                    traffic_sum = eval(counters_to_calculate[gnb][counter], traffic_data)
                    calculated_counters[gnb][counter] = traffic_sum
                else:
                    if counters_to_calculate[gnb][counter] == 0:
                        calculated_counters[gnb][counter] = 0
                        continue
                    traffic_sum = eval(counters_to_calculate[gnb][counter], traffic_data)
                    calculated_counters[gnb][counter] = traffic_sum
        return calculated_counters

    def validate_pm_counters(self, skip_checking_tti=False, suffix="PM_COUNTERS", dir_to_search=None,
                             direct_pm_counters_path=None, diff_period_counters=None):

        """
        Compare PM counters values from PM report with values calculated based on TTI traces.

        Args:
            skip_checking_tti (bool): Flag indicating whether to skip checking TTI traces. Default is False.
            suffix (str): Suffix to be used for PM counters. Default is "PM_COUNTERS".
            dir_to_search (str): Directory to search for PM counters. Default is None.
            direct_pm_counters_path (str): Path to direct PM counters. Default is None.
            diff_period_counters (dict, optional): A dictionary containing counters from different period.
                                                   Defaults to None.

        Returns:
            dict: A dictionary containing the current values of the PM counters.

        Raises:
            PMCountersValidationFail: If the validation of PM counters fails.
        """
        self.import_pandas()
        test_prefix = get_test_prefix()
        counters_template = self.get_counters_for_testcase(suffix=suffix)
        current_values = self.get_counters_values_from_report(
            counters_to_extract=counters_template,
            direct_pm_counters_path=direct_pm_counters_path
        )
        if skip_checking_tti:
            expected_values = counters_template
        else:
            expected_values = self.calculate_expected_pm_counters_values(
                counters_to_calculate=counters_template,
                suffix=suffix,
                direct_pm_counters_path=direct_pm_counters_path,
                dir_to_search=dir_to_search,
                diff_period_counters=diff_period_counters
            )
        passed_counters = []
        failed_counters = []
        if 'd_' in test_prefix or '022' in test_prefix:
            counters_diff_threshold = 0.005
        elif any(prefix in test_prefix for prefix in ['c_b103_004', 'c_b201_010', 'c_b201_011', 'c_b201_008',
                                                      'c_b103_007']):
            counters_diff_threshold = 0.05
        else:
            counters_diff_threshold = 0.002
        for gnb in expected_values:
            for counter in expected_values[gnb]:
                current_value = current_values[gnb][counter]
                expected_value = expected_values[gnb][counter]
                if current_value == 0 and expected_value != "any":
                    relative_diff = 1 if expected_value == ">0" else abs(current_value - expected_value)
                else:
                    if expected_value == ">0":
                        relative_diff = 0
                    elif expected_value == "any":
                        relative_diff = 0
                    elif "DIFF_PERIOD" in str(expected_value):
                        counters_diff_percentage = 100 * current_value / float(expected_value.split("_")[2]) - 100
                        relative_diff = 0 if current_value < float(expected_value.split("_")[2]) else 1
                        logger_console_info(f"{gnb}/{counter} - {abs(round(counters_diff_percentage))}% difference "
                                            f"between previous counters period")
                    else:
                        relative_diff = abs(current_value - expected_value) / current_value
                if relative_diff > counters_diff_threshold:
                    failed_counters.append({
                        f"{gnb}/{counter}": {
                            "expected value": expected_value,
                            "current value": current_value,
                        }
                    })
                else:
                    passed_counters.append({
                        f"{gnb}/{counter}": {
                            "expected value": expected_value,
                            "current value": current_value,
                        }
                    })

        formatted_failed_counters = "\n".join([f"- {counter}" for counter in failed_counters])
        formatted_passed_counters = "\n".join([f"- {counter}" for counter in passed_counters])

        logger_info(f"Counters validation passed: \n{formatted_passed_counters}\n")

        if failed_counters:
            raise PMCountersValidationFail(f"Counters validation failed: \n{formatted_failed_counters}\n")

        logger_console_info("PM Counters validation has finished successfully!")

        return current_values

    @staticmethod
    def get_nsa_rnti_ue_dict(filename="/opt/wts/latest/egate_console.log"):
        pattern_new_ue = re.compile(r"newUE-Identity (\d+),")
        pattern_uec = re.compile(r"UEC-1: UE(\d+)")
        rnti_ue_dict = {}
        with open(filename, "r") as file:
            lines = file.readlines()
        for i in range(len(lines)):
            line = lines[i]
            match_new_ue = pattern_new_ue.search(line)
            if match_new_ue:
                new_ue_number = match_new_ue.group(1)
                for j in range(i - 1, -1, -1):
                    match_uec = pattern_uec.search(lines[j])
                    if match_uec:
                        other_ue_number = match_uec.group(1)
                        rnti_ue_dict[int(new_ue_number)] = int(other_ue_number)
                        break
        value_to_last_key = {}
        for key, value in reversed(list(rnti_ue_dict.items())):
            if value not in value_to_last_key:
                value_to_last_key[value] = key
        return {value_to_last_key[value]: value for value in value_to_last_key}

    @staticmethod
    def get_sa_rnti_ue_dict():
        egate_analyzer = EgateConsoleMsg()
        rnti_dict = {value: key for key, value in egate_analyzer.get_ues_rnti(convert_to_dec=True).items()}
        ues_conf = get_builtin_value(f'{get_test_prefix()}_UE_CFG')
        sa_ue_ids = {item['ue_id'] for item in ues_conf if item['net_arch'] == 'sa'}
        return {key: value for key, value in rnti_dict.items() if value in sa_ue_ids}

    def get_counters_for_testcase(self, suffix="PM_COUNTERS"):
        test_prefix = get_test_prefix().upper()
        module_path = os.path.join(self.pm_counters_dir, f"{test_prefix}_pms.py")
        spec = importlib.util.spec_from_file_location("module", module_path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        return getattr(module, f"{test_prefix}_{suffix}", None)

    @staticmethod
    def get_cell_mapping():

        @handle_admin
        def get_cell_mapping_for_gnb(gnb_ip, **kwargs):
            scf_config = kwargs["connection"].get_scf(export_type="configuration")
            xmldom = minidom.parseString(scf_config)
            itemlist = xmldom.getElementsByTagName("managedObject")
            dist_names = [
                item.attributes["distName"].value
                for item in itemlist
                if re.findall(
                    "MRBTS-\\d+/NRBTS-\\d+/NRCELL-\\d+$",
                    item.attributes["distName"].value,
                )
            ]
            scf_instance = load_scf_from_site_and_get_taf_scf_instance(
                bts_host_ip=gnb_ip
            )
            cell_mapping_for_gnb = {}
            for dist_name in dist_names:
                pci = scf_instance.get_value_from_scf(
                    dist_name=dist_name, p_name="physCellId"
                )
                nrcell = int(dist_name.split("NRCELL-")[1])
                cell_mapping_for_gnb[int(pci)] = nrcell
            return cell_mapping_for_gnb

        cell_mapping = get_cell_mapping_for_gnb(GNB_IP, bts_host_ip=GNB_IP)
        if GNB2_IP:
            cell_mapping.update(get_cell_mapping_for_gnb(GNB2_IP, bts_host_ip=GNB2_IP))
        return cell_mapping

    @staticmethod
    def get_cell_mode():

        @handle_admin
        def get_cell_mode_for_gnb(gnb_ip, **kwargs):
            scf_config = kwargs["connection"].get_scf(export_type="configuration")
            xmldom = minidom.parseString(scf_config)
            itemlist = xmldom.getElementsByTagName('managedObject')
            dist_names = [item.attributes['distName'].value for item in itemlist
                          if re.findall('MRBTS-\\d+/NRBTS-\\d+/NRCELL-\\d+$', item.attributes['distName'].value)]
            scf_instance = load_scf_from_site_and_get_taf_scf_instance(bts_host_ip=gnb_ip)
            cell_mode_for_gnb = []
            for dist_name in dist_names:
                pci = scf_instance.get_value_from_scf(dist_name=dist_name, p_name='physCellId')
                band = scf_instance.get_value_from_scf(dist_name=dist_name, p_name='freqBandIndicatorNR')
                frequency_range = 'FR2' if 257 <= int(band) <= 263 else 'FR1'
                nrcell = int(dist_name.split('NRCELL-')[1])
                celltechnology = scf_instance.get_value_from_scf(dist_name=dist_name, p_name='cellTechnology')
                cell_mode_for_gnb.append(
                    {'id': str(nrcell), 'pci': str(pci), 'type': f'{frequency_range}_' + celltechnology})
            return cell_mode_for_gnb

        cell_mapping = get_cell_mode_for_gnb(GNB_IP, bts_host_ip=GNB_IP)
        if GNB2_IP:
            cell_mapping_gnb2 = get_cell_mode_for_gnb(GNB2_IP, bts_host_ip=GNB2_IP)
            cell_mapping.extend(cell_mapping_gnb2)
        return cell_mapping

    def validate_LoUser_SetupReq(
            self,
            path_to_syslog=None,
            msg_to_check=("LoUser_UserSetupReq", "LoUser_BearerSetupReq"),
    ):
        if path_to_syslog is None:
            path_to_syslog = os.path.join(get_log_dir(), 'syslog.log')
        for msg in msg_to_check:
            if os.popen(f"cat {path_to_syslog} | grep -F '{msg}'").read() == "":
                raise Exception("ValidateLoUserSetupReq")

    def validate_ul_rlc_pm_counters_distribution(self):
        """
        Check if all UL_RLC_UE_TPUT_BIN counters selected for test are incremented
        """

        expected_values = self.get_counters_for_testcase(suffix="PM_COUNTERS_UL_RLC")
        current_values = self.get_counters_values_from_report(expected_values)
        failed_counters = []
        for gnb in expected_values:
            for counter in expected_values[gnb]:
                try:
                    if current_values[gnb][counter] > 0:
                        continue
                    else:
                        failed_counters.append(f"{gnb}/{counter} not incremented")
                except KeyError:
                    failed_counters.append(f"{gnb}/{counter} not present in PM raport")
        if failed_counters:
            raise PMCountersValidationFail(
                f"UL RLC PM Counters validation failed: \n{failed_counters}\n"
            )
        logger_console_info("UL RLC PM Counters validation has finished successfully!")

    @staticmethod
    def get_default_log_dir():
        """
        The function to get default directory for storing logs
        :return: (str) Path to the default directory for storing logs
        """
        output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
        test_name = BuiltIn().get_variable_value("${TEST_NAME}")
        try:
            return os.path.join(output_dir, test_name)
        except TypeError:
            logger_info("TEST_NAME variable is not available")
        return os.path.join(output_dir, test_name)

    @staticmethod
    def _extract_itf_l2_hi_du_user_bearer_setup_req_t(syscom_message):
        return syscom_message["_source"]["layers"]["icom_5g"]["hiuserdu"][
            "itf_l2_hi_du_user_bearersetupreq"
        ]["itf_l2_hi_du_user_bearersetupreq_t"]

    @staticmethod
    def _get_logical_channel_id(itf_l2_hi_du_user_bearer_setup_req_t):
        return itf_l2_hi_du_user_bearer_setup_req_t[
            "itf_l2_hi_du_user_BearerSetupReq_t.logicalChannelId"
        ]

    @staticmethod
    def _get_type_of_bearer(itf_l2_hi_du_user_bearer_setup_req_t):
        return itf_l2_hi_du_user_bearer_setup_req_t["itf_l2_hi_du_user_pmcountersinfo"][
            "itf_l2_hi_du_user_PmCountersInfo.typeOfBearer"
        ]

    @staticmethod
    def _extract_itf_l2_lo_cell_cell_setup_req_t(syscom_message):
        return syscom_message["_source"]["layers"]["icom_5g"]["locell"]["itf_l2_lo_cell_cellsetupreq"][
            "itf_l2_lo_cell_cellsetupreq_t"
        ]

    @staticmethod
    def _act_nrpmqap_profiles(itf_l2_lo_cell_cell_setup_req_t):
        return itf_l2_lo_cell_cell_setup_req_t[
            "itf_l2_lo_cell_CellSetupReq_t.actNrPmqapProfiles"
        ]

    @staticmethod
    def _get_actperccdluserthpt_from_setup(itf_l2_lo_cell_cell_setup_req_t):
        return itf_l2_lo_cell_cell_setup_req_t[
            "itf_l2_lo_cell_CellSetupReq_t.actPerCcDlUserThpt"
        ]

    @staticmethod
    def _get_actpercculuserthpt_from_setup(itf_l2_lo_cell_cell_setup_req_t):
        return itf_l2_lo_cell_cell_setup_req_t[
            "itf_l2_lo_cell_CellSetupReq_t.actPerCcUlUserThpt"
        ]

    @staticmethod
    def _extract_itf_l2_lo_cell_cell_reconfiguration_req_t(syscom_message):
        return syscom_message["_source"]["layers"]["icom_5g"]["locell"]["itf_l2_lo_cell_cellreconfigurationreq"][
            "itf_l2_lo_cell_cellreconfigurationreq_t"
        ]

    @staticmethod
    def _extract_itf_l2_hi_du_cnfg_pmcountersinfo(syscom_message):
        config_param_req = syscom_message["_source"]["layers"]["icom_5g"]["hicnfgdu"][
            "itf_l2_hi_du_cnfg_configparamreq"]
        return config_param_req["itf_l2_hi_du_cnfg_sconfigparamreq"]["pmCountersInfo (StaticOptional)"][
            "itf_l2_hi_du_cnfg_pmcountersinfo"]

    @staticmethod
    def _act_nrpmqap_profiles_rec(itf_l2_lo_cell_cell_reconfiguration_req_t):
        return itf_l2_lo_cell_cell_reconfiguration_req_t[
            "itf_l2_lo_cell_CellReconfigurationReq_t.actNrPmqapProfiles"
        ]

    @staticmethod
    def _get_actperccdluserthpt_from_recon(itf_l2_lo_cell_cell_setup_req_t):
        return itf_l2_lo_cell_cell_setup_req_t[
            "itf_l2_lo_cell_CellReconfigurationReq_t.actPerCcDlUserThpt"
        ]

    @staticmethod
    def _get_actpercculuserthpt_from_recon(itf_l2_lo_cell_cell_setup_req_t):
        return itf_l2_lo_cell_cell_setup_req_t[
            "itf_l2_lo_cell_CellReconfigurationReq_t.actPerCcUlUserThpt"
        ]

    @staticmethod
    def _get_actperccdluserthpt_from_hicnfgdu(itf_l2_hi_du_cnfg_pmcountersinfo):
        return itf_l2_hi_du_cnfg_pmcountersinfo["itf_l2_hi_du_cnfg_PmCountersInfo.actPerCCDLUserThpt"]

    @staticmethod
    def _get_actpercculuserthpt_from_hicnfgdu(itf_l2_hi_du_cnfg_pmcountersinfo):
        return itf_l2_hi_du_cnfg_pmcountersinfo["itf_l2_hi_du_cnfg_PmCountersInfo.actPerCCULUserThpt"]

    @staticmethod
    def _get_nrcellids_from_hicnfgdu(itf_l2_hi_du_cnfg_pmcountersinfo):
        itf_l2_hi_du_cnfg_pmcountersinfo = itf_l2_hi_du_cnfg_pmcountersinfo[
            "nrCellIdsForCountersReporting (StaticVariableSizedArray capacity=144)"
        ]
        return itf_l2_hi_du_cnfg_pmcountersinfo[
            "itf_l2_hi_du_cnfg_PmCountersInfo.nrCellIdsForCountersReporting.Length"
        ]

    @staticmethod
    def _extract_drb_add_req_lo(syscom_message):
        return syscom_message["_source"]["layers"]["icom_5g"]["louser"][
            "itf_l2_lo_user_bearersetupreq"]["itf_l2_lo_user_bearersetupreq_t"]

    @staticmethod
    def _pm_qap_index_item_in_drbAddReqLo_item_0(drbAddReqLo):
        return drbAddReqLo["drbAddReqLo (StaticVariableSizedArray capacity=16)"]["itf_l2_lo_sdrbaddreqlo"][
            "pmqapProfileList (StaticVariableSizedArray capacity=40)"][
            "itf_l2_lo_SDrbAddReqLo.pmqapProfileList_item"]

    @staticmethod
    def _pm_qap_length_in_drbAddReqLo(drbAddReqLo):
        return drbAddReqLo["drbAddReqLo (StaticVariableSizedArray capacity=16)"]["itf_l2_lo_sdrbaddreqlo"][
            "pmqapProfileList (StaticVariableSizedArray capacity=40)"][
            "itf_l2_lo_SDrbAddReqLo.pmqapProfileList.Length"]

    @staticmethod
    def _extract_itf_l2_ps_user_bearer_setup_req_t(syscom_message):
        return syscom_message["_source"]["layers"]["icom_5g"]["psuser"][
            "itf_l2_ps_user_bearersetupreq"]["itf_l2_ps_user_bearersetupreq_t"]

    @staticmethod
    def _get_dlcaeligible(itf_l2_ps_bearer_setup_req_t):
        return itf_l2_ps_bearer_setup_req_t['drbAddReqPs (DynamicVariableSizedArray)']['itf_l2_ps_drbaddreqps'][
            'itf_l2_ps_DrbAddReqPs.dlCaEligible']

    @staticmethod
    def _get_qos_id(itf_l2_ps_bearer_setup_req_t):
        return itf_l2_ps_bearer_setup_req_t['drbAddReqPs (DynamicVariableSizedArray)']['itf_l2_ps_drbaddreqps'][
            'itf_l2_ps_DrbAddReqPs.qosId']

    def check_hi_user_du_bearer_setup_req_messages(self):
        """
        The function to verification typeOfBearer value in itf_l2_hi_du_user_bearersetupreq SYSCOM message.
        For SA UEs typeOfBearer should be 0 for each bearer.
        For NSA UEs typeOfBearer should be 1 for each bearer.
        """

        type_of_bearer_sa = "0"
        type_of_bearer_nsa = "1"
        sa_rnti_ues_dict = self.get_sa_rnti_ue_dict()
        nsa_rnti_ues_dict = self.get_nsa_rnti_ue_dict()
        errors = []

        hi_user_du_bearer_setup_req_messages = convert_pcap_to_json_using_tshark(
            pcap_path=os.path.join(self.get_default_log_dir(), "xp_syscom_gnb1.pcap"),
            message_filter="itf_l2_hi_du_user_bearersetupreq",
        )

        messages_to_check = read_json_file(hi_user_du_bearer_setup_req_messages)

        for message in messages_to_check:
            itf_l2_hi_du_user_bearer_setup_req_t = (
                self._extract_itf_l2_hi_du_user_bearer_setup_req_t(message)
            )
            logical_channel_id = int(
                self._get_logical_channel_id(itf_l2_hi_du_user_bearer_setup_req_t)
            )
            type_of_bearer = self._get_type_of_bearer(
                itf_l2_hi_du_user_bearer_setup_req_t
            )
            ue_rnti = int(itf_l2_hi_du_user_bearer_setup_req_t["3gpp.rnti"])

            if ue_rnti in sa_rnti_ues_dict.keys():
                if (
                        logical_channel_id in [1, 2, 4]
                        and type_of_bearer != type_of_bearer_sa
                ):
                    errors.append(
                        f"Wrong typeOfBearer={type_of_bearer} value for SA UE {ue_rnti}. "
                        f"Should be typeOfBearer={type_of_bearer_sa}"
                    )
                elif logical_channel_id not in [1, 2, 4]:
                    errors.append(
                        f"Incorrect logicalChannelId={logical_channel_id} for SA UE"
                    )
            elif ue_rnti in nsa_rnti_ues_dict.keys():
                if logical_channel_id == 4 and type_of_bearer != type_of_bearer_nsa:
                    errors.append(
                        f"Wrong typeOfBearer={type_of_bearer} value for NSA UE {ue_rnti}. "
                        f"Should be typeOfBearer={type_of_bearer_nsa}"
                    )
                elif logical_channel_id != 4:
                    errors.append(
                        f"Incorrect logicalChannelId={logical_channel_id} for NSA UE"
                    )
            else:
                errors.append(
                    f"SysCom packet with unknown UE-rnti={ue_rnti} was captured"
                )

        if errors:
            raise SyscomValidationFail("\n".join(errors))

    def check_lo_cell_cell_setup_req_messages(self):
        """
        The function to verification actNrpmqapProfiles value in itf_l2_lo_cell_cellsetupreq SYSCOM message.
        actNrpmqapProfiles should be True.
        """

        errors = []
        lo_cell_cell_setup_req_messages = convert_pcap_to_json_using_tshark(
            pcap_path=os.path.join(self.get_default_log_dir(), "xp_syscom_gnb1.pcap"),
            message_filter="itf_l2_lo_cell_cellsetupreq",
        )

        messages_to_check = read_json_file(lo_cell_cell_setup_req_messages)

        for message in messages_to_check:
            itf_l2_lo_cell_cell_setup_req_t = (
                self._extract_itf_l2_lo_cell_cell_setup_req_t(message)
            )

            act_nrpmqap_profiles = int(
                self._act_nrpmqap_profiles(itf_l2_lo_cell_cell_setup_req_t)
            )

            if act_nrpmqap_profiles is False:
                errors.append(
                    f"Incorrect actNrpmqapProfiles for SA UE"
                )

        if errors:
            raise SyscomValidationFail("\n".join(errors))

    def check_lo_cell_cell_reconfiguration_req_messages(self):
        """
        The function to verification actNrpmqapProfiles value in itf_l2_lo_cell_cellreconfigurationreq SYSCOM message.
        actNrpmqapProfiles should be True.
        """

        errors = []

        lo_cell_cell_reconfiguration_req_messages = convert_pcap_to_json_using_tshark(
            pcap_path=os.path.join(self.get_default_log_dir(), "xp_syscom_gnb1.pcap"),
            message_filter="itf_l2_lo_cell_cellreconfigurationreq",
        )

        messages_to_check = read_json_file(lo_cell_cell_reconfiguration_req_messages)

        for message in messages_to_check:
            itf_l2_lo_cell_cell_reconfiguration_req_t = (
                self._extract_itf_l2_lo_cell_cell_reconfiguration_req_t(message)
            )
            act_nrpmqap_profiles = int(
                self._act_nrpmqap_profiles_rec(itf_l2_lo_cell_cell_reconfiguration_req_t)
            )

            if act_nrpmqap_profiles is False:
                errors.append(
                    f"Incorrect actNrpmqapProfiles for SA UE"
                )

        if errors:
            raise SyscomValidationFail("\n".join(errors))

    def check_lo_user_bearer_setup_req_messages(self):
        """
        The function to verification pmQapIndex value in itf_l2_lo_user_bearersetupreq SYSCOM message.
        pmQapIndex should be equal to NRPMQAP id.
        """

        errors = []

        lo_user_bearer_setup_req_messages = convert_pcap_to_json_using_tshark(
            pcap_path=os.path.join(self.get_default_log_dir(), "xp_syscom_gnb1.pcap"),
            message_filter="itf_l2_lo_user_bearersetupreq",
        )

        messages_to_check = read_json_file(lo_user_bearer_setup_req_messages)

        rnti_ue_dict = self.get_sa_rnti_ue_dict()
        ue1_rnti = next(iter(rnti_ue_dict))
        ue2_rnti = next(iter(dict(list(rnti_ue_dict.items())[1:])))

        for index, message in enumerate(messages_to_check):
            drb_add_req_lo = self._extract_drb_add_req_lo(message)
            ue_rnti = int(drb_add_req_lo["3gpp.rnti"])

            if index in (0, 1):
                pm_qap_length = int(self._pm_qap_length_in_drbAddReqLo(drb_add_req_lo))
                if pm_qap_length != 0:
                    errors.append(f"Unexpected pmQapIndex_item ({pm_qap_length}) for UE-rnti={ue_rnti}")
            elif index == 2 and ue_rnti == ue1_rnti:
                pm_qap_index_item_1 = int(self._pm_qap_index_item_in_drbAddReqLo_item_0(drb_add_req_lo))
                if pm_qap_index_item_1 != 1:
                    errors.append(f"Incorrect pmQapIndex_item ({pm_qap_index_item_1}) for UE-rnti={ue_rnti}")
            elif index == 3 and ue_rnti == ue2_rnti:
                pm_qap_index_item_1 = int(self._pm_qap_index_item_in_drbAddReqLo_item_0(drb_add_req_lo))
                if pm_qap_index_item_1 != 2:
                    errors.append(f"Incorrect pmQapIndex_item ({pm_qap_index_item_1}) for UE-rnti={ue_rnti}")
            else:
                errors.append(f"Unexpected UE-rnti={ue_rnti}")

        if errors:
            raise SyscomValidationFail("\n".join(errors))

    def calculate_rlc_pdu_vol_burst(self, cell_mapping):
        """
        Get Burst RLC PDU Vol values from tti traces for downlink traffic.
        Used to create variables defined in resources/pm_counters e.g. RLC_D152, time_RLC_D21 etc.
        """

        csv_file = self.get_merged_csv_file('burst')
        cell_mode = self.get_cell_mode()
        nsa_rnti_ue_dict = self.get_nsa_rnti_ue_dict()
        sa_rnti_ue_dict = self.get_sa_rnti_ue_dict()
        rnti_to_ue_dict = {**nsa_rnti_ue_dict, **sa_rnti_ue_dict}
        rlc_dict = {}
        pci_values = [int(cell['pci']) for cell in cell_mode]

        duration_threshold, volume_threshold = self.get_threshold_values_for_vol_and_duration_burst()
        for rnti_id in rnti_to_ue_dict.keys():
            for pci in pci_values:
                cell_id = cell_mapping[pci]
                merged_burst_volume, merged_burst_duration = (
                    self.get_sum_of_vol_and_duration_from_local_l2lo_bursts(
                        csv_file_path=csv_file, physCellId=pci, rnti=str(rnti_id),
                        duration_threshold=duration_threshold,
                        volume_threshold=volume_threshold
                    )
                )
                merged_burst_volume = merged_burst_volume * 8 / 1000
                merged_burst_duration = merged_burst_duration / 1000
                rlc_dict[f'RLC_D{rnti_to_ue_dict[rnti_id]}_{cell_id}'] = merged_burst_volume
                rlc_dict[f'time_RLC_D{rnti_to_ue_dict[rnti_id]}_{cell_id}'] = merged_burst_duration
        return rlc_dict

    def calculate_rlc_pdu_vol_burst_from_syslog(self, syslog_paths=None):
        """
        Get Burst RLC PDU Vol values for downlink traffic based on
        10240ADBG/10636DBG successful validation prints from syslog
        Used to create variables defined in resources/pm_counters e.g. RLC_D152_syslog, time_RLC_D21_syslog etc.

        :param syslog_paths: (list) List of paths to a syslog files, if not specified it will be taken
        from a test directory
        """

        def read_and_filter_file(file_path, search_string):
            with open(file_path, 'r') as file:
                lines = file.readlines()
            filtered_lines = [line.strip() for line in lines if search_string in line]
            return filtered_lines

        def load_data_to_dataframe(file_path, search_string='10240ADBG/10636DBG printCalculatedBurst'):
            filtered_lines = read_and_filter_file(file_path, search_string)
            headers = ['content']
            df = self._pd.DataFrame(filtered_lines, columns=headers)
            df['duration'] = df['content'].str.extract(r'burstDuration:(\d+)us')[0]
            df['duration'] = df['duration'].astype(int)
            df['volume'] = df['content'].str.extract(r'burstVolume:(\d+)B')[0]
            df['volume'] = df['volume'].astype(int)
            df['ue_data'] = df['content'].str.extract(r'INF/([^/]+)/')[0]
            df['time'] = df['content'].str.extract(r'(\d{2}:\d{2}:\d{2}\.\d{6})')
            df['burstDurationBwp'] = df['content'].str.extract(r'burstDurationBwp:(\d+)')[0]
            df['burstDurationBwp'] = df['burstDurationBwp'].astype(int)
            return df

        def get_l2hidu_to_ue(file_path):
            nsa_rnti_ue_dict = self.get_nsa_rnti_ue_dict()
            sa_rnti_ue_dict = self.get_sa_rnti_ue_dict()
            rnti_ue_dict = {**nsa_rnti_ue_dict, **sa_rnti_ue_dict}
            with open(file_path, 'r') as file:
                log_data = file.read()
            pattern = re.compile(r'INF/L2HiDu, ([^/]+)/Ln:\d+/setupRb: crnti:(\d+)')
            matches = pattern.findall(log_data)
            l2hidu_to_crnti = {match[0]: match[1] for match in matches}
            l2hidu_to_crnti_int = {key: int(value) for key, value in l2hidu_to_crnti.items()}
            l2hidu_to_ue = {key: rnti_ue_dict[value] for key, value in
                            l2hidu_to_crnti_int.items() if value in rnti_ue_dict}
            return l2hidu_to_ue

        def discard_data_from_other_pm_intervals(df):
            df['time'] = self._pd.to_datetime(df['time'], format='%H:%M:%S.%f').dt.time
            if df.empty:
                return df
            first_time = df.loc[0, 'time']
            first_time_period_start = first_time.replace(minute=(first_time.minute // 5) * 5, second=0, microsecond=0)
            first_time_period_end = (
                    self._pd.Timestamp.combine(self._pd.Timestamp.today(), first_time_period_start)
                    + self._pd.Timedelta(minutes=5)).time()
            df_single_interval = df[(df['time'] >= first_time_period_start) & (df['time'] < first_time_period_end)]
            return df_single_interval

        def extract_time_and_volume_data(df):
            sum_duration = df.groupby('ue_data')['duration'].sum().reset_index()
            sum_duration['duration'] = sum_duration['duration'] / 1000  # Microseconds to milliseconds
            sum_volume = df.groupby('ue_data')['volume'].sum().reset_index()
            sum_volume['volume'] = sum_volume['volume'] / 125  # Bytes to kilobits
            sum_burstDurationBwp = df.groupby('ue_data')['burstDurationBwp'].sum().reset_index()
            sum_burstDurationBwp['burstDurationBwp'] = sum_burstDurationBwp['burstDurationBwp'] / 1000
            df_time_volume = sum_duration.merge(sum_volume, on='ue_data')
            df_time_volume = df_time_volume.merge(sum_burstDurationBwp, on='ue_data')

            return df_time_volume

        self.import_pandas()
        if syslog_paths is None and not GNB2_IP:
            syslog_paths = [os.path.join(get_log_dir(), 'syslog.log')]
        elif syslog_paths is None and GNB2_IP:
            syslog_paths = [os.path.join(get_log_dir(), 'syslog_gnb1.log'),
                            os.path.join(get_log_dir(), 'syslog_gnb2.log')]
        traffic_data = {}
        for syslog_path in syslog_paths:
            l2hidu_ue_dict = get_l2hidu_to_ue(syslog_path)
            syslog_data = load_data_to_dataframe(syslog_path)
            syslog_data = discard_data_from_other_pm_intervals(syslog_data)
            syslog_data = extract_time_and_volume_data(syslog_data)
            for index, row in syslog_data.iterrows():
                if f'RLC_D{l2hidu_ue_dict[row["ue_data"]]}_syslog' in traffic_data:
                    traffic_data[f'RLC_D{l2hidu_ue_dict[row["ue_data"]]}_syslog'] += row['volume']
                    traffic_data[f'time_RLC_D{l2hidu_ue_dict[row["ue_data"]]}_syslog'] += row['duration']
                    traffic_data[f'burstDurationBwp_RLC_D{l2hidu_ue_dict[row["ue_data"]]}_syslog'] += \
                        row['burstDurationBwp']
                else:
                    traffic_data[f'RLC_D{l2hidu_ue_dict[row["ue_data"]]}_syslog'] = row['volume']
                    traffic_data[f'time_RLC_D{l2hidu_ue_dict[row["ue_data"]]}_syslog'] = row['duration']
                    traffic_data[f'burstDurationBwp_RLC_D{l2hidu_ue_dict[row["ue_data"]]}_syslog'] = \
                        row['burstDurationBwp']
        return traffic_data

    def get_merged_csv_file(self, filename_key):
        csv_files = self.get_csv_files_path(filename_key=filename_key)
        csv_file = csv_files[0]
        if len(csv_files) > 1:
            dataframes = [self._pd.read_csv(file) for file in csv_files]
            combined_df = self._pd.concat(dataframes, ignore_index=True)
            sorted_df = combined_df.sort_values(by=['days', 'hours', 'minutes', 'seconds', 'microSeconds'])
            csv_file = os.path.join(get_log_dir(), f'merged_{self._csv_file_mapping[filename_key]}')
            sorted_df.to_csv(csv_file, index=False)
        return csv_file

    def calculate_mac_sdu_burst(self, cell_mapping):
        csv_file = self.get_merged_csv_file('burst')
        cell_mode = self.get_cell_mode()
        nsa_rnti_ue_dict = self.get_nsa_rnti_ue_dict()
        sa_rnti_ue_dict = self.get_sa_rnti_ue_dict()
        rnti_to_ue_dict = {**nsa_rnti_ue_dict, **sa_rnti_ue_dict}
        mac_dict = {}
        pci_values = [int(cell['pci']) for cell in cell_mode]

        duration_threshold, volume_threshold = self.get_threshold_values_for_vol_and_duration_burst()
        for rnti_id in rnti_to_ue_dict.keys():
            for pci in pci_values:
                cell_id = cell_mapping[pci]
                merged_burst_volume, merged_burst_duration = (
                    self.get_sum_of_vol_and_duration_from_local_l2lo_bursts(
                        csv_file_path=csv_file, physCellId=pci, rnti=str(rnti_id),
                        duration_threshold=duration_threshold,
                        volume_threshold=volume_threshold
                    )
                )
                total_amount_bytes = merged_burst_volume * 8 / 1000
                total_burst_duration = merged_burst_duration / 1000
                mac_dict[f'MAC_D{rnti_to_ue_dict[rnti_id]}_{cell_id}'] = total_amount_bytes
                mac_dict[f'time_MAC_D{rnti_to_ue_dict[rnti_id]}_{cell_id}'] = total_burst_duration
        return mac_dict

    def calculate_burst_amount_and_time_per_cc(self, dir_to_search=None):
        test_prefix = get_test_prefix()
        test_prefix_cell_variable = f"{test_prefix.upper()}_CELL_INFO"
        csv_file = self.get_csv_files_path(filename_key="mux", dir_to_search=dir_to_search)[0]
        cell_info_variable = BuiltIn().get_variable_value(f"${test_prefix_cell_variable}")
        cell_mode = cell_info_variable if cell_info_variable else self.get_cell_mode()
        nsa_rnti_ue_dict = self.get_nsa_rnti_ue_dict()
        sa_rnti_ue_dict = self.get_sa_rnti_ue_dict()
        rnti_to_ue_dict = {**nsa_rnti_ue_dict, **sa_rnti_ue_dict}
        rnti_ue_dict = [{"id": f"{ue_id}", "rnti": f"{rnti}"} for rnti, ue_id in rnti_to_ue_dict.items()]
        result = BuiltIn().run_keyword("Get CSV Data for CC RLC counters from MacPduMuxReq",
                                       csv_file, rnti_ue_dict, cell_mode)
        return result

    def get_volume_and_time_per_cc_counters(self, suffix, direct_pm_counters_path):
        """
        Retrieves the volume and time per cc counters for a given suffix and direct PM counters path.

        Args:
            suffix (str): The suffix for the test case.
            direct_pm_counters_path (str): The path to the direct PM counters.

        Returns:
            dict: A dictionary containing the volume and time per cc counters.
                  The keys are in the format "<nrcell>_<counter_name>" and the values are the corresponding counter
                  values.
        """
        result = {}
        counters_template = self.get_counters_for_testcase(suffix=suffix)
        current_values = self.get_counters_values_from_report(
            counters_to_extract=counters_template,
            direct_pm_counters_path=direct_pm_counters_path
        )
        for counter, value in current_values['gnb1'].items():
            split_counter_path = counter.split('/')
            split_nrcell = split_counter_path[3].split('-')
            result.update({f"{split_nrcell[0]}_{split_nrcell[1]}_{split_counter_path[-1]}": value})
        return result

    def verify_lo_cell_cell_setup_request_messages(self, exp_actperccdluserthpt, exp_actpercculuserthpt):
        """
        The function to verification actPerCCDLUserThpt and actPerCCULUserThpt values
        in itf_l2_lo_cell_cellsetupreq SYSCOM messages.
        """

        lo_cell_setup_req_messages = convert_pcap_to_json_using_tshark(
            pcap_path=os.path.join(self.get_default_log_dir(), "xp_syscom_gnb1.pcap"),
            message_filter="itf_l2_lo_cell_cellsetupreq",
        )
        messages_to_check = read_json_file(lo_cell_setup_req_messages)

        errors = []
        for message in messages_to_check:
            itf_l2_lo_cell_cell_setup_req_t = (self._extract_itf_l2_lo_cell_cell_setup_req_t(message))
            actperccdluserthpt = int(self._get_actperccdluserthpt_from_setup(itf_l2_lo_cell_cell_setup_req_t))
            actpercculuserthpt = int(self._get_actpercculuserthpt_from_setup(itf_l2_lo_cell_cell_setup_req_t))
            nr_cell_identity = itf_l2_lo_cell_cell_setup_req_t["itf_l2_lo_cell_CellSetupReq_t.nrCellIdentity"]

            if actperccdluserthpt != int(exp_actperccdluserthpt):
                errors.append(
                    f"Incorrect value actperccdluserthpt = {actperccdluserthpt} for Cell {nr_cell_identity}. "
                    f"Expected {exp_actperccdluserthpt}."
                )

            if actpercculuserthpt != int(exp_actpercculuserthpt):
                errors.append(
                    f"Incorrect value actpercculuserthpt {actpercculuserthpt} for Cell {nr_cell_identity}. "
                    f"Expected {exp_actpercculuserthpt}."
                )

        if errors:
            raise SyscomValidationFail("\n".join(errors))

    def verify_lo_cell_cell_reconfiguration_request_messages(self, exp_actperccdluserthpt, exp_actpercculuserthpt):
        """
        The function to verification actPerCCDLUserThpt and actPerCCULUserThpt values
        in itf_l2_lo_cell_cellreconfigurationreq SYSCOM messages.
        """

        lo_cell_reconfiguration_req_messages = convert_pcap_to_json_using_tshark(
            pcap_path=os.path.join(self.get_default_log_dir(), "xp_syscom_gnb1.pcap"),
            message_filter="itf_l2_lo_cell_cellreconfigurationreq",
        )
        messages_to_check = read_json_file(lo_cell_reconfiguration_req_messages)

        errors = []
        for message in messages_to_check:
            itf_l2_lo_cell_cell_recon_req_t = (self._extract_itf_l2_lo_cell_cell_reconfiguration_req_t(message))
            actperccdluserthpt = int(self._get_actperccdluserthpt_from_recon(itf_l2_lo_cell_cell_recon_req_t))
            actpercculuserthpt = int(self._get_actpercculuserthpt_from_recon(itf_l2_lo_cell_cell_recon_req_t))
            nr_cell_identity = itf_l2_lo_cell_cell_recon_req_t[
                "itf_l2_lo_cell_CellReconfigurationReq_t.nrCellIdentity"
            ]

            if actperccdluserthpt != int(exp_actperccdluserthpt):
                errors.append(
                    f"Incorrect value actperccdluserthpt {actperccdluserthpt} for Cell {nr_cell_identity}. "
                    f"Expected {exp_actperccdluserthpt}."
                )

            if actpercculuserthpt != int(exp_actpercculuserthpt):
                errors.append(
                    f"Incorrect value actpercculuserthpt {actpercculuserthpt} for Cell {nr_cell_identity}. "
                    f"Expected {exp_actpercculuserthpt}."
                )

        if errors:
            raise SyscomValidationFail("\n".join(errors))

    def verify_hi_du_cnfg_config_param_request_messages(self, exp_actperccdluserthpt=(0, 1),
                                                        exp_actpercculuserthpt=(0, 1), configured_cells=8):
        """
        The function to verification actPerCCDLUserThpt and actPerCCULUserThpt values
        in itf_l2_hi_du_cnfg_configparamreq SYSCOM messages.
        """

        hi_config_param_req_messages = convert_pcap_to_json_using_tshark(
            pcap_path=os.path.join(self.get_default_log_dir(), "xp_syscom_gnb1.pcap"),
            message_filter="itf_l2_hi_du_cnfg_configparamreq",
        )
        messages_to_check = read_json_file(hi_config_param_req_messages)

        errors = []
        for msg_id in range(len(messages_to_check)):
            itf_l2_hi_du_cnfg_pmcountersinfo = (
                self._extract_itf_l2_hi_du_cnfg_pmcountersinfo(messages_to_check[msg_id])
            )
            actperccdluserthpt = int(self._get_actperccdluserthpt_from_hicnfgdu(itf_l2_hi_du_cnfg_pmcountersinfo))
            actpercculuserthpt = int(self._get_actpercculuserthpt_from_hicnfgdu(itf_l2_hi_du_cnfg_pmcountersinfo))
            nrcellids_length = int(self._get_nrcellids_from_hicnfgdu(itf_l2_hi_du_cnfg_pmcountersinfo))

            if actperccdluserthpt != int(exp_actperccdluserthpt[msg_id]):
                errors.append(
                    f"Incorrect value actperccdluserthpt: {actperccdluserthpt}. "
                    f"Expected {exp_actperccdluserthpt[msg_id]}."
                )

            if actpercculuserthpt != int(exp_actpercculuserthpt[msg_id]):
                errors.append(
                    f"Incorrect value actpercculuserthpt: {actpercculuserthpt}. "
                    f"Expected {exp_actpercculuserthpt[msg_id]}."
                )

            if nrcellids_length != configured_cells:
                errors.append(
                    f"Incorrect Length of nrCellIdsForCountersReporting: {nrcellids_length}. "
                    f"Expected {configured_cells}."
                )

        if errors:
            raise SyscomValidationFail("\n".join(errors))

    def check_bearersetupreq_messages_before_online_change(self):
        """
        The function to verify dlCaEligible value in itf_l2_ps_user_bearersetupreq SYSCOM message before online change.
        """
        louser_bearersetupreq_messages = convert_pcap_to_json_using_tshark(
            pcap_path=os.path.join(self.get_default_log_dir(), "before_gnb1.pcap"),
            message_filter="itf_l2_ps_user_bearersetupreq",
        )
        messages_to_check = read_json_file(louser_bearersetupreq_messages)
        errors = []
        for message in messages_to_check:
            itf_l2_ps_bearer_setup_req_t = self._extract_itf_l2_ps_user_bearer_setup_req_t(message)
            dl_ca_eligible_value = self._get_dlcaeligible(itf_l2_ps_bearer_setup_req_t)
            qos_id = self._get_qos_id(itf_l2_ps_bearer_setup_req_t)
            qos_id = int(qos_id)
            expected_values = {6: True, 7: False, 8: True}
            if qos_id in expected_values:
                if bool(int(dl_ca_eligible_value)) != expected_values[qos_id]:
                    return (
                        f'Value of dlCaEligible incorrect for qos_id = {qos_id}. Expected "{expected_values[qos_id]}" '
                        f'actual value: {dl_ca_eligible_value}')
            else:
                errors.append(f'Value of qos_id out of range: {qos_id}. Value of dlCaEligible flag:'
                              f' {dl_ca_eligible_value}')
        if errors:
            raise SyscomValidationFail("\n".join(errors))

    def check_bearersetupreq_messages_after_online_change(self):
        """
        The function to verify dlCaEligible value in itf_l2_ps_user_bearersetupreq SYSCOM message after online change.
        """
        louser_bearersetupreq_messages = convert_pcap_to_json_using_tshark(
            pcap_path=os.path.join(self.get_default_log_dir(), "after_gnb1.pcap"),
            message_filter="itf_l2_ps_user_bearersetupreq",
        )
        messages_to_check = read_json_file(louser_bearersetupreq_messages)
        errors = []
        for message in messages_to_check:
            itf_l2_ps_bearer_setup_req_t = self._extract_itf_l2_ps_user_bearer_setup_req_t(message)
            dl_ca_eligible_value = self._get_dlcaeligible(itf_l2_ps_bearer_setup_req_t)
            qos_id = self._get_qos_id(itf_l2_ps_bearer_setup_req_t)
            qos_id = int(qos_id)
            expected_values = {6: False, 7: True, 8: True}
            if qos_id in expected_values:
                if bool(int(dl_ca_eligible_value)) != expected_values[qos_id]:
                    return (
                        f'Value of dlCaEligible incorrect for qos_id = {qos_id}. Expected "{expected_values[qos_id]}" '
                        f'actual value: {dl_ca_eligible_value}')
            else:
                errors.append(f'Value of qos_id out of range: {qos_id}. Value of dlCaEligible flag:'
                              f' {dl_ca_eligible_value}')
        if errors:
            raise SyscomValidationFail("\n".join(errors))

    def calculate_throughput_per_mhz_denominator(self):
        """
        Calculate the throughput per MHz denominator for each UE.

        Returns:
            None
        """
        bw_dict = {}
        ue_time_sum = 0
        ues_time_sum_dict = {}
        test_prefix = get_test_prefix()
        test_prefix_cell_variable = f"{test_prefix.upper()}_CELL_INFO"
        cell_info_variable = BuiltIn().get_variable_value(f"${test_prefix_cell_variable}")
        cell_mode = cell_info_variable if cell_info_variable else self.get_cell_mode()
        nsa_rnti_ue_dict = self.get_nsa_rnti_ue_dict()
        sa_rnti_ue_dict = self.get_sa_rnti_ue_dict()
        rnti_to_ue_dict = {**nsa_rnti_ue_dict, **sa_rnti_ue_dict}
        rnti_ue_dict_list = [{"ue_id": f"{ue_id}", "rnti": f"{rnti}"} for rnti, ue_id in rnti_to_ue_dict.items()]
        ues_times_per_cell_dict = {}

        def get_rlc_times_safe(csv, rnti_value, mode, ue_ident, file_index):
            try:
                return get_rlc_times_from_merged_burst_from_all_cells_for_ue(csv, rnti_value, mode)
            except (IndexError, KeyError) as error:
                logger_console_info(
                    f"Error processing csv_file[{file_index}] for UE {ue_ident} with RNTI {rnti_value}: {error}")
                return {}
        for ue in rnti_ue_dict_list:
            file = self.get_merged_csv_file('mux')
            ues_times_per_cell_dict[ue['ue_id']] = get_rlc_times_safe(file, ue['rnti'], cell_mode, ue['ue_id'], 0)
        for cell in cell_info_variable:
            bw_dict[cell['pci']] = cell['bw']
        for ue_id, time_per_cell in ues_times_per_cell_dict.items():
            for cell in bw_dict:
                op = time_per_cell[cell] * bw_dict[cell]
                ue_time_sum = ue_time_sum + op
            ues_time_sum_dict[f'denominator_ue{ue_id}'] = ue_time_sum
            ue_time_sum = 0

        return ues_time_sum_dict

    def get_threshold_values_for_vol_and_duration_burst(self):
        """
        Retrieves the duration (durationThresDiscardDlMacSdu) and volume (volThresDiscardDlMacSdu) threshold values
        from SCF.

        Returns:
            tuple: A tuple containing the duration threshold and volume threshold values.
        """
        duration_threshold = get_parameter_value_from_scf(dist_name='MRBTS-1/NRBTS-1/NRDRB-1/',
                                                          parameter='durationThresDiscardDlMacSdu')
        volume_threshold = get_parameter_value_from_scf(dist_name='MRBTS-1/NRBTS-1/NRDRB-1/',
                                                        parameter='volThresDiscardDlMacSdu')
        return int(duration_threshold), int(volume_threshold)

    def get_summed_traffic_components(self, traffic_data, max_number_of_underscores=3):
        """
        Calculates the sum of counter component values and adds them to dictionary.
        E.g. sum of RLC_D1_1 and RLC_D1_2 is RLC_D1

        Args:
            traffic_data (dict): values to be summed e.g. {'RLC_D1_1': 41668.872, 'RLC_D1_2': 1187.28, ...}
            max_number_of_underscores (int): current components have max value of underscores=3 (time_RLC_D1_1)

        Returns:
            traffic_data (dict): input dict with sums added
        """
        for underscore_number in range(max_number_of_underscores, 0, -1):
            new_traffic_data = traffic_data.copy()
            for traffic_vol in traffic_data.copy().keys():
                if traffic_vol.count("_") == underscore_number:
                    if "_".join(traffic_vol.split("_")[:underscore_number]) in new_traffic_data.keys():
                        new_traffic_data["_".join(traffic_vol.split("_")[:underscore_number])] += new_traffic_data[
                            traffic_vol
                        ]
                    else:
                        new_traffic_data["_".join(traffic_vol.split("_")[:underscore_number])] = new_traffic_data[
                            traffic_vol
                        ]
            traffic_data = new_traffic_data
        return traffic_data

    def parse_diff_period_counters(self, diff_period_counters=None):
        """
        Parses the diff_period_counters dictionary and returns a parsed version.

        Args:
            diff_period_counters (dict): The diff_period_counters dictionary to be parsed.

        Returns:
            dict: The parsed diff_period_counters dictionary.

        """
        parsed_diff_period_counters = {}
        if diff_period_counters:
            for counter, value in diff_period_counters['gnb1'].items():
                split_counter_path = counter.split('/')
                split_nrcell = split_counter_path[3].split('-')
                parsed_diff_period_counters.update(
                    {f"DIFF_PERIOD_{split_nrcell[0]}_{split_nrcell[1]}_{split_counter_path[-1]}": value})
        return parsed_diff_period_counters

    @staticmethod
    def _extract_nokia_nr_u(message):
        return message["_source"]["layers"]["gtp"]["gtp.ext_hdr"]["nokia_nr_u"]

    def verify_ddds_messages(self, is_feature_enabled, file_path):
        """
        The function to verification DL DATA DELIVERY STATUS trace.

        Args:
            is_feature_enabled (bool): Set True if CB010636 is enabled and False if disabled.
            file_path (str): The path to collected 'IP Traffic capturing' file.
        """
        ddds_messages = convert_pcap_to_json_using_tshark(
            pcap_path=file_path,
            message_filter="nr_u.PDU.Type == 15",
        )
        messages_to_check = read_json_file(ddds_messages)

        errors = []
        for message in messages_to_check:
            nokia_nr_u = self._extract_nokia_nr_u(message)
            spare = nokia_nr_u["nr_u.PDU.Type15.spare"]

            if is_feature_enabled:
                if spare is not None and int(spare, 16) == 0x00:
                    errors.append(
                        f"Incorrect spare={spare} for new DDDS trace. Expected value higher than 0x00."
                    )
                if "nr_u.PDU.Padding" in nokia_nr_u:
                    padding = nokia_nr_u["nr_u.PDU.Padding"]
                    if not padding:
                        errors.append(f"No padding={padding} in new DDDS trace.")
                else:
                    errors.append(f"No padding field in new DDDS trace.")
            else:
                if spare is not None and int(spare, 16) > 0x00:
                    errors.append(
                        f"Incorrect spare={spare} for legacy DDDS trace."
                        f"Expected value is 0x00."
                    )
                if "nr_u.PDU.Padding" in nokia_nr_u:
                    padding = nokia_nr_u["nr_u.PDU.Padding"]
                    errors.append(f"Padding exists in legacy DDDS trace. Padding={padding}")
        if errors:
            raise SyscomValidationFail("\n".join(errors))

    def calculate_merged_burst(self):
        self.import_pandas()
        burst_file_df = self._pd.read_csv(self.get_merged_csv_file('burst'))
        nsa_rnti_ue_dict = self.get_nsa_rnti_ue_dict()
        sa_rnti_ue_dict = self.get_sa_rnti_ue_dict()
        rnti_to_ue_dict = {**nsa_rnti_ue_dict, **sa_rnti_ue_dict}
        merged_burst_dict = {}
        for rnti in burst_file_df['rnti'].unique():
            time_sum = 0
            vol_sum = 0
            df_rnti = burst_file_df[burst_file_df['rnti'] == rnti]
            for burstid in df_rnti['burstId'].unique():
                df_burst = df_rnti[df_rnti['burstId'] == burstid].copy()
                df_burst['t4_slots_total'] = (df_burst['t4Hfn'] * 1024 * 80 +
                                              df_burst['t4Sfn'] * 80 +
                                              df_burst['t4Slot'])
                df_burst['t2_slots_total'] = (df_burst['t2Hfn'] * 1024 * 80 +
                                              df_burst['t2Sfn'] * 80 +
                                              df_burst['t2Slot'])
                df_burst['t1_slots_total'] = (df_burst['t1Hfn'] * 1024 * 80 +
                                              df_burst['t1Sfn'] * 80 +
                                              df_burst['t1Slot'])
                max_t4 = df_burst['t4_slots_total'].max()
                indices_to_drop = []
                for index, row in df_burst.iterrows():
                    if max_t4 - df_burst.at[index, 't1_slots_total'] == 1 and \
                            max_t4 == df_burst.at[index, 't4_slots_total']:
                        indices_to_drop.append(index)
                df_burst.drop(indices_to_drop, inplace=True)
                df_burst.reset_index(drop=True, inplace=True)
                min_t1 = df_burst['t1_slots_total'].min()
                last = 0
                for index, row in df_burst.iterrows():
                    if max_t4 == df_burst.at[index, 't4_slots_total']:
                        burst_last = df_burst.at[index, 't2_slots_total']
                        vol_sum += df_burst.at[index, 'volInBytes']
                    else:
                        burst_last = df_burst.at[index, 't4_slots_total']
                        vol_sum += df_burst.at[index, 'totalVolInBytes']
                    if burst_last > last:
                        last = burst_last
                val = (last - min_t1) * 125
                if not math.isnan(val):
                    time_sum += val
            merged_burst_dict[f'merged_burst_vol_ue_{rnti_to_ue_dict[rnti]}'] = vol_sum / 125
            merged_burst_dict[f'merged_burst_dur_ue_{rnti_to_ue_dict[rnti]}'] = time_sum / 1000
        return merged_burst_dict

import os
import time
import re

import collections
from datetime import datetime
from pathlib import Path
import xml.etree.ElementTree as ET
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import (
    logger_info,
    logger_console_info,
    logger_warning,
    logger_debug,
)
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_gnb import *
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_wts import run_egate_cmd


class ScellValidationFail(Exception):
    pass


class AmfNotActiveFail(Exception):
    pass


class Validation:
    PM_COUNTERS = [
        'PLMN-PLMN/MCC-311/MNC-489/NRASU/M55326C02006',
        'PLMN-PLMN/MCC-002/MNC-002/NRASU/M55326C02006',
        'PLMN-PLMN/MCC-003/MNC-003/NRASU/M55326C02006',
        'PLMN-PLMN/MCC-004/MNC-004/NRASU/M55326C02006',
        'PLMN-PLMN/MCC-005/MNC-005/NRASU/M55326C02006',
        'PLMN-PLMN/MCC-006/MNC-006/NRASU/M55326C02006',
    ]

    def validate_pm_counters(self, direct_pm_counters_path=None, counters_diff_threshold=0.05):

        """
        Compare PM counters values from PM report with values calculated based on TTI traces.

        Args:
            direct_pm_counters_path (str): Path to direct PM counters. Default is None.
            counters_diff_threshold (float): Counters threshold.

        Raises:
            PMCountersValidationFail: If the validation of PM counters fails.
        """
        counters_template = self.PM_COUNTERS
        current_values = self.get_counters_values_from_report(
            counters_to_extract=counters_template,
            direct_pm_counters_path=direct_pm_counters_path
        )
        logger_debug(f"Current PM counters values are: {current_values}")
        failed_counters = {}
        counters_mean = sum(current_values.values()) / len(current_values.values())
        lower_limit = counters_mean * (1 - counters_diff_threshold)
        upper_limit = counters_mean * (1 + counters_diff_threshold)
        logger_debug(f"counters_mean: {counters_mean}, lower_limit: {lower_limit}, upper_limit: {upper_limit}")
        for counter_name, counter_value in current_values.items():
            if counter_value < lower_limit or counter_value > upper_limit:
                failed_counters[counter_name] = counter_value

        if failed_counters:
            raise Exception(f"Counters validation failed! Lower limit is {lower_limit} and upper_limit is "
                            f"{upper_limit}. Following counters have wrong values: {failed_counters}")

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

        def get_pm_report_file_path():
            """
            Returns path to PM counter report.
            """
            if direct_pm_counters_path:
                is_valid, message = validate_file_path(direct_pm_counters_path)
                if is_valid:
                    logger_info(message)
                    return direct_pm_counters_path

            output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
            output_dir = os.path.join(output_dir, BuiltIn().get_variable_value("${TEST_NAME}"))
            pm_counters_dir = os.path.join(output_dir, f"pm_counters")

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
        tree = ET.parse(get_pm_report_file_path())
        root = tree.getroot()
        for pmmo_result in root.findall(".//PMMOResult"):
            mo_dns = pmmo_result.findall('./MO/DN')
            path_core = mo_dns[0].text
            if len(mo_dns) > 1:
                path_core = mo_dns[1].text
            ne_wbts_obj = pmmo_result.find("./NE-WBTS_1.0")
            for counter_to_extract in counters_to_extract:
                counter_path, counter_id = counter_to_extract.rsplit("/", 1)
                if (
                        counter_path
                        == f"{path_core}/{ne_wbts_obj.attrib['measurementType']}"
                ):
                    try:
                        ne_wbts_counter = ne_wbts_obj.find(f"./{counter_id}").text
                        extracted_counters[counter_to_extract] = float(
                            ne_wbts_counter
                        )
                    except AttributeError:
                        logger_warning(
                            f"{counter_to_extract} not found in PM report"
                        )
        return extracted_counters

    def check_plmn_in_sib(self):
        file = '/opt/wts/latest/egate_console.log'
        regexp = r'message c1 : systemInformationBlockType1 :(?:.*\n){14}' \
                 r'.*mcc \n.*{\n.*3,\n.*1,\n.*1\n.*},\n' \
                 r'.*mnc \n.*{\n.*4,\n.*8,\n.*9\n.*}\n.*},\n' \
                 r'.*{\n.*mcc \n.*{\n.*0,\n.*0,\n.*3\n.*},\n' \
                 r'.*mnc \n.*{\n.*0,\n.*0,\n.*3\n.*}\n.*},\n' \
                 r'.*{\n.*mcc \n.*{\n.*0,\n.*0,\n.*4\n.*},\n' \
                 r'.*mnc \n.*{\n.*0,\n.*0,\n.*4\n.*}\n.*},\n' \
                 r'.*{\n.*mcc \n.*{\n.*0,\n.*0,\n.*5\n.*},\n' \
                 r'.*mnc \n.*{\n.*0,\n.*0,\n.*5\n.*}\n.*},\n' \
                 r'.*{\n.*mcc \n.*{\n.*0,\n.*0,\n.*6\n.*},\n' \
                 r'.*mnc \n.*{\n.*0,\n.*0,\n.*6' \
                 r'(?:.*\n){4}.*trackingAreaCode .*00000000 00000011 00010100.*B,' \
                 r'(?:.*\n){8}.*mcc \n.*{\n.*0,\n.*0,\n.*2\n.*},\n' \
                 r'.*mnc \n.*{\n.*0,\n.*0,\n.*2' \
                 r'(?:.*\n){4}.*trackingAreaCode .*00000000 00000000 11001000.*B,'
        with open(file, "r") as egate_console_log:
            matches = re.findall(regexp, egate_console_log.read())
            logger_info(egate_console_log.read())
        found = len(matches)
        assert found == 1, "Found {} occurrences of [{}]; expected 1 occurrence.".format(found, regexp)

    @staticmethod
    def add_timestamp_to_prefix(prefix=" [Console] ", timestamp=True, newline=False):
        date = datetime.today().strftime('%Y/%m/%d %H:%M:%S') if timestamp is True else ""
        date = '\n' + date if newline else date
        return "{}{}".format(date, prefix)

    def logger_console(self, msg, prefix=" [Console] ", timestamp=True, newline=False):
        prefix = self.add_timestamp_to_prefix(prefix=prefix, timestamp=timestamp, newline=newline)
        logger.console("{}{}".format(prefix, msg))

    def validate_scells_state_in_egate(self, cells_to_validate_map={}, messages_occurrences=1, state="activation"):
        """
        Validate SCells state by parsing egate output

        :param cells_to_validate_map: (dict) Map containing UE id's (AP indexing starting from 0) as keys and cells
                                             PCI's tuples as values. Example:
                                             cells_to_validate_map={0: (52, 53, 54, 55, 56, 57, 58), 1: (60,)}
        :param state: (str) State of expected cell behaviour, activation or deactivation
        :param messages_occurrences: (int)
        """
        missing_scells = {}
        retry = 20
        retry_interval = 0.5
        state_print = "activated" if state == "activation" else "deactivated"

        while retry > 0:
            missing_scells = {}
            # run_egate_cmd(cmd="set_log flush")
            with open("/opt/wts/latest/egate_console.log") as egate_console:
                egate_console_content = egate_console.read()
                for ue_id, cell_list in cells_to_validate_map.items():
                    regex_string = re.compile(
                        rf"UeId:\b{ue_id}\b.*PhysCellId:\s*.* {state_print} successfully at airphone")
                    cell_occurrences = len(regex_string.findall(egate_console_content))
                    expected_occurrences = int(messages_occurrences) * len(cell_list)
                    if cell_occurrences != expected_occurrences:
                        missing_scells[ue_id] = [cell_occurrences, expected_occurrences]
                if not missing_scells:
                    self.logger_console("All SCells activated successfully")
                    break
            retry -= 1
            time.sleep(retry_interval)
        if missing_scells:
            error_message = '\n'.join([f'{scells[0]} Scells activated for UE{ue_id + 1}, expected: {scells[1]}'
                                       for ue_id, scells in missing_scells.items()])
            raise ScellValidationFail(error_message)

    def verify_all_amf_are_active(self, amf_ids=None):
        if not amf_ids:
            amf_ids = [amf_id + 1 for amf_id in range(6)]
        amf_inactive_list = []
        for amf_id in amf_ids:
            amf_state = GenericDuOperations(bts_type='GNB').get_gnb_parameter_value_via_gui(
                dist_name=f"MRBTS-1/NRBTS-1/SERVEDAMF-{amf_id}", param_name="NG Link Status", param_abbr="ngLinkStatus")
            if amf_state != f"Active":
                amf_inactive_list.append(amf_id)

        if amf_inactive_list:
            raise AmfNotActiveFail(f"Some AMFs are not active! Inactive AMFs: {amf_inactive_list}")

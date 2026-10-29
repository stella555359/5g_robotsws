from ScfHandlerLogger import ScfHandlerLogger
import bts_connection
from exceptions import PathNotFound, CannotCreateTable, InvalidParameterFormat
import xml.etree.ElementTree as ET
import shutil
import os
from pathlib import Path
from typing import Dict, Tuple

"""
Documentation
...  AUTHORS:       sebastian.suwada@nokia.com
...  MAINTAINER:    MN_RAN_RD_VRF_WRO3_2
...  *****************
...  Basic information
...  *****************
...  The scfHandler library is designed to facilitate the retrieval and verification of information within SCF files.
...  Its primary use case is to assist users during testing by identifying missing parameters that can be configured
...  on the test line. This ensures a more streamlined and efficient testing process
...  by providing actionable insights into parameter settings.
...  scHandler.py file have all of the logic for this library.
...  ******************
...  History of changes
...  ******************
...  https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-26930 - Creation of library
"""


class ScfHandler:

    def __init__(self):
        self.log = ScfHandlerLogger()
        self.namespace = {'ns': 'raml21.xsd'}
        self.scfPath = None
        self.root = None
        self.parameters = {}

    def initialize_scf_path(self):
        """
        Initialize the SCF path and root after all dependencies are loaded.
        """
        self.scfPath = self.get_scf_path()
        if self.scfPath:
            self.root = self.create_root(self.scfPath)

    def get_scf_path(self):
        """
        Collecting SCF from BTS and assign the SCF path to scf_path value.

        Returns:
            scf_path: Path to SCF file

        Raises:
            PathNotFound: If unable to get scfPath
        """
        try:
            scf_path = bts_connection.get_admin_api_connection(host="192.168.255.129")
            self.log.info_robot(f"SCF Collected, path: {scf_path}")
            return scf_path
        except PathNotFound:
            self.log.error_robot("Unable to get scfPath")
            return None

    def create_root(self, scf_path):
        """
        Creating root from SCF file parsing SCF File in XML format.

        Args:
            scf_path: Path to SCF file

        Returns:
            root: Parsed SCF file

        Raises:
            FileNotFoundError: If file is not found
            ET.ParseError: If cannot parse SCF file
        """
        try:
            tree = ET.parse(scf_path)
            root = tree.getroot()
            return root
        except FileNotFoundError:
            self.log.error_robot("File not found")
            return None
        except ET.ParseError as e:
            self.log.error_robot(f"Error during parsing XML file: {e}")
            return None

    def find_parameter(self, parameter_name):
        """
        Getting text value from parameter_name parameter.

        Args:
            parameter_name: Parameter to search for in parsed xml file

        Returns:
            element.text: return of parameter_name value from parsed xml file

        """
        for element in self.root.iter():
            if element.attrib.get('name') == parameter_name:
                return element.text
        return None

    def find_parameter_same(self, parameter_name):
        """
        Getting all occurrences of text value from parameter_name parameter.

        Args:
            parameter_name: Parameter to search for in parsed xml file

        Returns:
            occurrences: return of parameter_name value element.text of all occurrences

        """
        occurrences = []
        for element in self.root.iter():
            if element.attrib.get('name') == parameter_name:
                occurrences.append(element.text)
        return occurrences

    def generate_table(self, headers, data):
        """
        Logic to develop table and displaying part

        Args:
            data: data for the table
            headers: headers for the table

        Returns:
            Display table in console

        Raises:
            ValueError: If line format is invalid
        """
        terminal_width = shutil.get_terminal_size().columns
        max_table_width = terminal_width - 4
        num_columns = len(headers)
        base_column_width = max_table_width // num_columns
        column_widths = [
            min(base_column_width, max(len(str(header)), max(len(str(row[i])) for row in data)))
            for i, header in enumerate(headers)]

        total_width = sum(column_widths) + (num_columns * 3) + 1
        if total_width > terminal_width:
            excess_width = total_width - terminal_width
            for i in range(len(column_widths)):
                if column_widths[i] > 10:
                    reduction = min(excess_width, column_widths[i] - 10)
                    column_widths[i] -= reduction
                    excess_width -= reduction
                    if excess_width <= 0:
                        break

        def split_multiline(value, width):
            value = str(value)
            if len(value) <= width:
                return [value]
            lines = []
            while len(value) > width:
                split_point = value[:width].rfind(" ")
                if split_point == -1:
                    split_point = width
                lines.append(value[:split_point])
                value = value[split_point:].strip()
            lines.append(value)
            return lines

        table = "+"
        for width in column_widths:
            table += "-" * (width + 2) + "+"
        table += "\n|"
        for header, width in zip(headers, column_widths):
            table += f" {header:<{width}} |"
        table += "\n+"
        for width in column_widths:
            table += "-" * (width + 2) + "+"
        table += "\n"

        for row in data:
            split_rows = [split_multiline(row[i], column_widths[i]) if i == 1 else [str(row[i])] for i in
                          range(len(row))]
            max_lines = max(len(lines) for lines in split_rows)

            for line_index in range(max_lines):
                table += "|"
                for i, width in enumerate(column_widths):
                    if line_index < len(split_rows[i]):
                        table += f" {split_rows[i][line_index]:<{width}} |"
                    else:
                        table += f" {'':<{width}} |"
                table += "\n"
        table += "+"
        for width in column_widths:
            table += "-" * (width + 2) + "+"
        table += "\n"
        self.log.warn_robot(f"\n{table}")

    def show_table(self, data):
        """
        Function used to generate table - shortcut to show table

        Args:
            data: data used to be shown in the table
        """
        headers = ["Parameter", "Current value", "Operator", "Expected Value", "Parameter status"]
        self.generate_table(headers=headers, data=data)

    def get_parameters(self) -> None:
        """
        Load parameters from parameters.txt file.

        Raises:
            FileNotFoundError: If parameters.txt is not found
            InvalidParameterFormat: If file contains invalid format
            PermissionError: If file cannot be read due to permissions
        """
        try:
            library_dir = Path(__file__).parent
            file_path = library_dir / "parameters.txt"

            if not file_path.exists():
                raise FileNotFoundError(f"Parameters file not found: {file_path}")

            self.log.info_robot(f"Loading parameters from: {file_path}")

            with file_path.open("r", encoding="utf-8") as file:
                for line_num, line in enumerate(file, start=1):
                    line = line.strip()
                    if not line or line.startswith('#'):  # Skip empty and comments
                        continue

                    try:
                        param, operator, value = self._parse_parameter_line(line)
                        self.parameters[param] = {'value': value, 'operator': operator}
                    except ValueError as e:
                        raise InvalidParameterFormat(
                            f"Line {line_num}: {e} - '{line}'"
                        ) from e

        except FileNotFoundError as e:
            self.log.error_robot(f"Parameters file not found: {e}")
            raise
        except PermissionError as e:
            self.log.error_robot(f"Cannot read parameters file: {e}")
            raise
        except InvalidParameterFormat as e:
            self.log.error_robot(str(e))
            raise

    @staticmethod
    def _parse_parameter_line(line: str) -> Tuple[str, str, str]:
        """
        Parse a single parameter line.

        Args:
            line: Line from parameters file (e.g., "param=value" or "param!=value")

        Returns:
            Tuple of (parameter_name, operator, value)

        Raises:
            ValueError: If line format is invalid
        """
        if '!=' in line:
            parts = line.split('!=', 1)
            operator = '!='
        elif '=' in line:
            parts = line.split('=', 1)
            operator = '='
        else:
            raise ValueError("Missing operator (= or !=)")

        if len(parts) != 2:
            raise ValueError("Invalid format")

        param, value = parts[0].strip(), parts[1].strip()

        if not param:
            raise ValueError("Empty parameter name")
        if not value:
            raise ValueError("Empty parameter value")

        return param, operator, value

    @staticmethod
    def count_feature(expected_value, actual):
        return True if expected_value in actual else False

    def check_values_ee(self):
        """
        Checking set values and defining status to "passed" or "failed".
        This function is calling all other functions to define percentage of coverage
        of defined parameters in parameter.txt

        Returns:
            ZeroDivisionError: when calculating percentage of coverage.
            CannotCreateTable: when there will be a problem with generating table.
        """
        self.initialize_scf_path()
        self.get_parameters()
        counter_main = 0
        counter_pass = 0
        correct_list = "Passed"
        data = []

        for param, details in self.parameters.items():
            expected_value = details['value']
            operator = details['operator']
            actual = self.find_parameter_same(param)

            _count_feature = self.count_feature(expected_value, actual)
            if len(actual) == 0:
                correct_list = "Failed - not accessible"
            else:
                counter_main += 1
                if operator == '=':
                    if _count_feature is True:
                        counter_pass += 1

                    if expected_value in actual:
                        correct_list = "Passed"
                    else:
                        correct_list = "Failed"

                if operator == '!=':
                    if _count_feature is False:
                        counter_pass += 1

                    if expected_value in actual:
                        correct_list = "Failed"
                    else:
                        correct_list = "Passed"

            data.append([param, actual, operator, expected_value, correct_list])

        self.log.warn_robot(f"Energy Efficiency parameters coverage: {counter_pass}")
        self.log.warn_robot(f"All Energy Efficiency parameters accessible on this BTS: {counter_main}")

        try:
            percentage = round((counter_pass/counter_main)*100, 2)
            self.log.warn_robot(f"Percentage of parameters coverage = {percentage}%")
        except ZeroDivisionError:
            self.log.warn_robot("Zero division error!")

        try:
            self.show_table(data=data)
        except CannotCreateTable:
            self.log.error_robot("Unable to create Table")

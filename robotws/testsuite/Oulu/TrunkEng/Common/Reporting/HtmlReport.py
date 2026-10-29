"""
:author:  Valtteri Lamberg
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import io
import os
import json
from lxml import etree
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import eventlog_path, log_folder, time
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info
from datetime import datetime
from pathlib import Path
import re
import testsuite.Oulu.TrunkEng.Common.Python.Resources.AddTestExecutionErrorsToFile as test_execution_errors_to_file


class HtmlReport(object):

    modified_template = ""
    logger = BuiltIn().get_library_instance("LOG")
    table_template = ""
    table_onclick_template = ""
    table_title_template = ""
    passes = ""
    fails = ""
    total = ""
    loop_times = ""
    status_string = ""
    kpi_numbers = []

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")

    def modify_template_start(self, test_name, start_time, title_name, sw_version):
        """
        Starts modifying the HTML-template by replacing placeholders with test name, test start time, title for the
        report and software version.

        :param test_name: Contains the name of the test case
        :param start_time: Timestamp for the beginning of the test
        :param title_name: Title for the HTML report
        :param sw_version: Current software build

        :return: HTML template with these replaced values
        """
        path = "testsuite/Oulu/TrunkEng/Common/Reporting/HtmlReportTemp.txt"
        with open(path, "r+") as html_template:
            self.modified_template = html_template.read()
            self.modified_template = self.modified_template.replace("{{report_name}}", test_name)
            self.modified_template = self.modified_template.replace("{{start_time}}", start_time)
            self.modified_template = self.modified_template.replace("{{title}}", title_name)
            self.modified_template = self.modified_template.replace("{{sw_versions}}", sw_version)
            self.modified_template = self.modified_template.replace("{{i}}", test_name)
        with open("html_temp.txt", "w") as html_temp:
            html_temp.write(self.modified_template)
        return self.modified_template

    def modify_template_loop(self, loops, loop_success, test_name, time_loop_success, results):
        """
        Modify HTML template elements which need to be looped, e.g. color of cells (keywords) for each test loop.

        :param int loops: Number of test loops
        :param bool loop_success: If the current status is Pass or Fail
        :param string test_name: Test name
        :param bool time_loop_success: If the current loop time status is Pass or Fail
        :param list results: List of loop results

        :return: HTML template with modified values
        """
        table = "testsuite/Oulu/TrunkEng/Common/Reporting/tableloop.txt"
        onclick = "testsuite/Oulu/TrunkEng/Common/Reporting/onclickloop.txt"
        robot_keyword_list, robot_keyword_dict, traceback_messages = self.parse_xml_and_get_keywords_and_statuses()
        read_title = self.replace_placeholder_titles("testsuite/Oulu/TrunkEng/Common/Reporting/tabletitles.txt",
                                                     robot_keyword_dict)
        with open("html_temp.txt", "r+") as html_loop:
            with open(table, "r") as read_table, open(onclick, "r") as read_onclick:
                self.table_template = read_table.read() * loops
                self.table_onclick_template = read_onclick.read() * loops
                self.table_title_template = read_title
                data = html_loop.readlines()
                data = [i.strip(' ') for i in data]
                self.modified_template = [self.table_title_template if x == 'tabletitles\n' else x for x in data]
                loop_number = 1
                while loop_number <= loops:
                    self.get_color_of_cells_per_loop(self.table_template,
                                                     robot_keyword_dict, loops, loop_number)
                    self.modify_table_template(loop_number, test_name=test_name, loop_success=loop_success,
                                               time_loop_success=time_loop_success,
                                               traceback_messages=traceback_messages)
                    if results[loop_number-1] and not BuiltIn().get_variable_value("${COLLECT_LOGS}") == "Always":
                        split_template = self.table_template.split("&#8203;")
                        self.table_template = self.table_template.replace(split_template[loop_number], "")
                        self.table_template = "".join(self.table_template)
                    loop_number += 1
                self.modified_template = [self.table_template if x == 'table_here\n' else x for x in
                                          self.modified_template]
                html_loop.writelines(data)
        self.modified_template = ["" if x == 'table_here\n' else x for x in self.modified_template]
        self.modified_template = "".join(self.modified_template)
        return self.modified_template

    def modify_table_template(self, loop_number, test_name, loop_success, time_loop_success, traceback_messages):
        """
        Modify the table that opens after clicking a failed event in the HTML report.

        :param int loop_number: Is used to keep track of loops, incremented after every loop
        :param string test_name: Name of the test
        :param bool loop_success: Whether the loop failed or passed
        :param bool time_loop_success: Whether the loop failed or passed time checks
        :param dict traceback_messages: Dictionary of Traceback messages found in output.xml

        :return: Modified template of the element that opens on click
        """
        self.table_template = self.table_template.replace("{{failure.event}}", test_name + " - %d" % loop_number, 1)
        self.table_template = self.table_template.replace("X", "%d" % loop_number, 1)
        with open(eventlog_path, "r") as eventlog:
            self.loop_times = eventlog.read()
            split = self.loop_times.split(
                "***************************************************************************************************")
            self.loop_times = split[3::4]
        self.table_template = self.table_template.replace("X", "%d" % loop_number, 2)
        self.table_template = self.table_template.replace("{{failure.event}}",
                                                          test_name + " - %d" %
                                                          loop_number, 1)
        loop_times_range = len(self.loop_times)
        for i in range(loop_times_range):
            self.table_template = self.table_template.replace("{{failure.time}}",
                                                              "".join(self.loop_times[i]), 1)
        test_name_safe = test_name.replace(" ", "_")
        eventlog_link = f"{test_name_safe}_1/loop_{loop_number}/Eventlog_{test_name_safe}_loop_{loop_number}.log"
        self.table_template = self.table_template.replace("{{failurelogfilelinkevent}}", eventlog_link, 1)
        for i in range(loop_times_range):
            self.table_template = self.table_template.replace("{{failurelogfilelink}}",
                                                              f"{test_name_safe}_1/loop_{i + 1}", 1)
        if loop_success and time_loop_success and BuiltIn().get_variable_value("${COLLECT_LOGS}") == "On failure":
            pass
        self.table_template = self.table_template.replace(
            "{{message}}", self.get_errors_per_loop(self.logger.errors_and_warnings,
                                                    loop_number, traceback_messages), 1)

        return self.table_template

    def calculate_case_numbers(self, test_statuses):
        """
        Calculates numbers of passed loops, failed loops and total loops

        :param list test_statuses: A list of test statuses

        :return: Integers of passed, failed and total loops
        """
        self.passes = test_statuses.count(True)
        self.fails = test_statuses.count(False)
        self.total = self.passes + self.fails
        return self.passes, self.fails, self.total

    def find_file_in_directory(self, file_name, file_path):
        """
        Find a file in a directory.

        :param string file_name: Name of the file
        :param string file_path: Path to the file

        :return: Path to file
        """
        for root, directories, files in os.walk(file_path):
            for item in files:
                if file_name in item:
                    return os.path.join(root, item)

    def modify_template_end(self, test_name, sw_version, current_time, elapsed_time, status):
        """
        After the test, update HTML template with KPI placeholders and delete Failed events if everything passes.

        :param string test_name: Name of the test
        :param string sw_version: Software version
        :param string current_time: Timestamp at the end of execution
        :param string elapsed_time: Time difference between start time and current time
        :param string status: Status of the test

        :return: The modified template
        """
        self.modified_template = self.modified_template.replace("{{current_time}}", current_time)
        self.modified_template = self.modified_template.replace("{{elapsed_time}}", elapsed_time)
        self.modified_template = self.modified_template.replace("{{logname}}", "Event log")
        self.modified_template = self.modified_template.replace("{{status}}", status)
        self.modified_template = self.modified_template.replace("{{configuration_id}}", "-")
        self.modified_template = self.modified_template.replace("{{case.count}}", str(self.total))
        self.modified_template = self.modified_template.replace("{{total.count}}", str(self.total))
        self.modified_template = self.modified_template.replace("{{total.passed}}", str(self.passes))
        self.modified_template = self.modified_template.replace("{{case.passed}}", str(self.passes))
        self.modified_template = self.modified_template.replace("{{case.failed}}", str(self.fails))
        self.modified_template = self.modified_template.replace("{{total.failed}}", str(self.fails))
        self.modified_template = self.modified_template.replace("{{case.not_run}}",
                                                                "-")
        self.modified_template = self.modified_template.replace("{{total.not_run}}", "-")
        self.modified_template = self.modified_template.replace("{{case.pass_rate}}", str(self.passes /
                                                                                          self.total * 100))
        self.modified_template = self.modified_template.replace("{{total.pass_rate}}", str(self.passes /
                                                                                           self.total * 100))
        self.modified_template = self.modified_template.replace("{{logfilelink}}", f"event_log_{time}.log")
        self.modified_template = self.modified_template.replace("{{logfilename}}", "Test case event log")

        kpi_block_template = """
        <div class="case">
                <h3 onClick="toggleDisplay2('{{result_summary.name}}{{id}}', '{{result_summary.name}}{{id}}_plus')"><a
                        href="javascript:void(0);" style="font-size:1.0em"><span class="monospace"
                                        id="{{result_summary.name}}{{id}}_plus">+</span>{{result_summary.result_type}}
                    on successful {{result_summary.test}} -events</a></h3>
                <table class="hidden" id="{{result_summary.name}}{{id}}">
                    <tr>
                        <td class="counterheader" style="border-left:none;"></td>
                        <td class="counterheader">Min</td>
                        <td class="counterheader">Avg</td>
                        <td class="counterheader">Max</td>
                    </tr>
                    <tr class="even">
                    <tr class="odd">
                        <td class="fixedwidth">{{result_sw.name}}</td>
                        <td class="fixedwidth">{{result_sw.min}}</td>
                        <td class="fixedwidth">{{result_sw.avg}}</td>
                        <td class="fixedwidth">{{result_sw.max}}</td>
                    </tr>
                </table>
            </div>
        """
        self.kpi_numbers = self.get_kpi_number(self.get_kpi_file_path())
        if not self.kpi_numbers:
            info("No KPI numbers found")
            self.modified_template = self.modified_template.replace(
                "kpi_block_template",
                (
                    "<br><div style=\"font-family: 'Segoe UI', Arial, sans-serif; "
                    "font-size: 1.1em; color: #555; background: #f8f8f8; border-radius: 6px; "
                    "padding: 12px 18px; margin: 12px 0; text-align: center;\">"
                    "No KPI data available</div><br>"
                )
            )
        else:
            kpi_blocks_html = ""
            for kpi in self.kpi_numbers:
                match = re.match(r'KPI#(\d+)([a-zA-Z]?)', kpi)
                if match:
                    number = match.group(1)
                    letter = match.group(2)
                    block = kpi_block_template
                    block = block.replace("{{result_summary.name}}", f"result_summary{number}{letter}")
                    block = block.replace("{{result_summary.result_type}}", kpi)
                    block = block.replace("{{result_summary.test}}", test_name)
                    block = block.replace("{{result_sw.name}}", sw_version)
                    kpi_blocks_html += block
            self.modified_template = self.modified_template.replace("kpi_block_template", kpi_blocks_html)
        if status == "Pass":
            self.modified_template = re.sub(
                (
                    r'<h3\s+onClick="toggleDisplay2\(\'\{\{test_failure_list\.step_key\}\}\{\{id\}\}\',\s*'
                    r'\'\{\{test_failure_list\.step_key\}\}\{\{id\}\}_plus\'\);">\s*'
                    r'<a href="javascript:void\(0\);" style="font-size:1\.0em"><span class="monospace"\s*'
                    r'id="\{\{test_failure_list\.step_key\}\}\{\{id\}\}_plus">\+</span>\s*Failed events</a>\s*'
                    r'</h3>'
                ),
                '',
                self.modified_template,
                flags=re.DOTALL
            )
        self.modified_template = self.modified_template.replace("&#8203;", "")
        return self.modified_template

    def _get_kpi_values(self, omkpi_case):
        """
        Get the KPI-values from the KPI-file.

        :param bool omkpi_case: Whether the test case is an OMKPI case or not

        :return: Minimum, average and maximum KPIs on passed iterations
        """
        if not omkpi_case:
            return None
        kpi_path = self.get_kpi_file_path()
        try:
            if kpi_path and os.path.isfile(kpi_path):
                try:
                    with open(kpi_path, encoding="utf-8") as f:
                        js = json.loads(f.read())
                except UnicodeDecodeError:
                    with open(kpi_path, encoding="ISO-8859-1") as f:
                        js = json.loads(f.read())
                kpi_values = []
                for key, value in js.items():
                    if key.lower() in [k.lower().replace("kpi#", "kpi") for k in self.kpi_numbers]:
                        min_value = str(value.get("min_from_passed_iter", ""))
                        avg_value = str(value.get("avg_from_passed_iter", ""))
                        max_value = str(value.get("max_from_passed_iter", ""))
                        kpi_values.append([
                            min_value,
                            avg_value,
                            max_value,
                        ])
                return kpi_values
            else:
                print(f"{kpi_path} is not a file.")
                return None
        except json.JSONDecodeError:
            return None

    def get_errors_per_loop(self, warning_error_list, loop_number, tracebacks_by_loop):
        """
        Returns a string of error messages and tracebacks for the given loop_number.

        :param list warning_error_list: Global list of errors and warnings
        :param int loop_number: 1-based index of the loop
        :param dict tracebacks_by_loop: Dict mapping loop_number to list of tracebacks

        :return: String with error messages and tracebacks for this loop
        """
        error_messages = [test_execution_errors_to_file.format_entry(entry) for entry in warning_error_list]
        loop_pattern = re.compile(rf"Loop {loop_number}:")
        start = next((idx for idx, msg in enumerate(error_messages) if loop_pattern.search(msg)), None)
        next_loop_pattern = re.compile(rf"Loop {loop_number + 1}:")
        end = next((idx for idx, msg in enumerate(error_messages) if next_loop_pattern.search(msg)),
                   len(error_messages))
        tracebacks = tracebacks_by_loop.get(loop_number, [])
        if start is not None or tracebacks:
            errors = error_messages[start:end]
            error_str = "\n".join(errors) if errors else "No error messages"
            if tracebacks:
                error_str += "\n\n--- TRACEBACKS ---\n"
                for tb in tracebacks:
                    error_str += f"\n<pre>{tb}</pre>\n"
            return error_str
        else:
            return "No error messages"

    def parse_xml_with_cut(self, file_path):
        """
        Parse an XML file, removing any problematic headers and ensuring a single root element.

        :param string file_path: Path to the XML file

        :return: The root element of the parsed XML
        """
        import re
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except FileNotFoundError:
            info(f"XML file not found: {file_path}")
            return None
        content = re.sub(r'<\?xml.*?\?>', '', content, flags=re.DOTALL).strip()
        if not content.startswith("<root>"):
            content = f"<root>\n{content}\n</root>"
        info("Parsing now")
        try:
            parser = etree.XMLParser(recover=True)
            root = etree.fromstring(content.encode('utf-8'), parser=parser)
            with open('output_fixed.xml', 'wb') as file:
                xml_string = etree.tostring(root, encoding='utf-8', pretty_print=True)
                file.write(xml_string)
            return root
        except etree.XMLSyntaxError as e:
            raise ValueError(f"Failed to parse XML: {e}")

    def load_target_keywords(self, target_keywords_file):
        """
        Load target keywords from a file.

        :param string target_keywords_file: Path to the file containing target keywords

        :return: A list of target keywords
        """
        try:
            with open(target_keywords_file, 'r') as file:
                target_keywords = [line.strip() for line in file if line.strip()]
            return target_keywords
        except FileNotFoundError:
            info(f"Target keywords file not found: {target_keywords_file}")
            return []

    def find_robot_keywords_from_fixed_xml(self, fixed_xml):
        """
        Extracts all keyword names and their statuses from <kw> tags in the given XML content.
        Also collects traceback messages from <msg> tags, grouped by loop number.

        :param string fixed_xml: Path to the parsed xml-file

        :return: (list of (keyword, status) tuples, dict {keyword: [status, ...]},
                  dict {loop_number: [traceback messages]})
        """
        info("Processing the fixed XML...")
        try:
            tree = etree.parse(fixed_xml)
            root = tree.getroot()
        except etree.XMLSyntaxError as e:
            info(f"Failed to parse XML: {e}")
            return [], {}, {}
        results = []
        keyword_status_dict = {}
        traceback_messages = {}
        skip_keywords = self.load_target_keywords("testsuite/Oulu/TrunkEng/Common/Reporting/skip_keywords.txt")
        current_loop_number = None
        for elem in root.iter():
            if elem.tag == "kw":
                name = elem.get("name")
                if name in skip_keywords:
                    continue
                status_elem = elem.find("status")
                if status_elem is not None:
                    status = status_elem.get("status")
                    results.append((name, status))
                    if name not in keyword_status_dict:
                        keyword_status_dict[name] = []
                    keyword_status_dict[name].append(status)
            elif elem.tag == "msg":
                if elem.text:
                    match = re.search(r"Create folder .*?/loop_(\d+)", elem.text)
                    if match:
                        current_loop_number = int(match.group(1))
                    if "Traceback" in elem.text and current_loop_number is not None:
                        traceback_messages.setdefault(current_loop_number, []).append(elem.text)
        return results, keyword_status_dict, traceback_messages

    def extract_keywords_and_status(self, data):
        """
        Extracts keyword names and their statuses (PASS/FAIL/NOT RUN) from the given list.

        :param list data: List of data from which to gather keyword statuses.

        :return: A list and dictionary of found keywords
        """
        final_keyword_dict = {}
        results = []
        current_keyword = None
        for item in data:
            if isinstance(item, str):
                current_keyword = item
                if current_keyword not in final_keyword_dict:
                    final_keyword_dict[current_keyword] = []
            elif isinstance(item, dict) and current_keyword:
                status = item.get('status')
                final_keyword_dict[current_keyword].append(status)
                results.append((current_keyword, status))
        return results, final_keyword_dict

    def replace_placeholder_titles(self, tabletitles, robot_keyword_dict):
        """
        Replace placeholder for titles with Robot keywords.

        :param string tabletitles: String path to a file containing a placeholder for the titles
        :param dict robot_keyword_dict: A dictionary that contains Robot keywords

        :return: Content with replaced titles
        """
        with open(tabletitles, 'r') as file:
            content = file.read()
        replacement_string = ""
        for element in robot_keyword_dict:
            element_with_tags = f"<th>{element}</th>"
            replacement_string += element_with_tags
        content = content.replace('X', replacement_string, 1)
        return content

    def parse_xml_and_get_keywords_and_statuses(self):
        """
        Parses output.xml and gets Robot keywords from the new xml-file.

        :return: A list and a dict of Robot keywords and a dict of traceback-messages
        """
        robot_output_file = BuiltIn().get_variable_value("${OUTPUT FILE}")
        file_path = robot_output_file
        root = self.parse_xml_with_cut(file_path)
        if root is None:
            info("No XML root found, returning empty results.")
            return [], {}
        output_file_path = 'output_fixed.xml'
        with open(output_file_path, 'wb') as file:
            xml_string = etree.tostring(root, encoding='utf-8', pretty_print=True)
            file.write(xml_string)
        robot_keyword_list, robot_keyword_dict, traceback_messages = \
            self.find_robot_keywords_from_fixed_xml(output_file_path)
        return robot_keyword_list, robot_keyword_dict, traceback_messages

    def get_color_of_cells_per_loop(self, table_cells, robot_keyword_dict, loops, loop_number):
        """
        For each loop, aggregate statuses per keyword and set cell colors accordingly.
        Handles keywords with 1, N, or N*M statuses.

        :param string table_cells: HTML table cells template
        :param dict robot_keyword_dict: Dictionary of Robot keywords and their statuses
        :param int loops: Total number of loops
        :param int loop_number: Current loop number (1-based)
        """
        replacement_string = ""
        for keyword, status_list in robot_keyword_dict.items():
            if len(status_list) == 1:
                chunk = [status_list[0]]
            elif len(status_list) == loops:
                chunk = [status_list[loop_number - 1]]
            elif len(status_list) % loops == 0:
                items_per_loop = len(status_list) // loops
                start = (loop_number - 1) * items_per_loop
                end = start + items_per_loop
                chunk = status_list[start:end]
            else:
                chunk = status_list
            chunk_lower = [s.lower() for s in chunk]
            if "fail" in chunk_lower:
                cell_class = "fail"
            elif all(s == "pass" for s in chunk_lower):
                cell_class = "pass"
            else:
                cell_class = "missing"
            replacement_string += f"<td class={cell_class}></td>"
        self.table_template = table_cells.replace('row_holder', replacement_string, 1)

    def get_kpi_file_path(self):
        """
        Find the path to the KPI-file.

        :return: Path to the KPI-file
        """
        kpi_file_path = None
        dir_path = os.path.dirname(self.logger.log_dir)
        dir_list = sorted(os.listdir(dir_path))
        for file in dir_list:
            if file.startswith("KPI"):
                kpi_file_path = os.path.join(dir_path, file)
                break
        if not kpi_file_path:
            info("No KPI path found")
            return None
        return kpi_file_path

    def get_kpi_number(self, kpi_file_path):
        """
        Find the numbers of the KPI values being measured, e.g. kpi#1a , kpi#3

        :param string kpi_file_path: Path to the KPI-file.

        :return: The KPI numbers
        """
        try:
            with open(kpi_file_path, "r") as file:
                data = json.load(file)
                if not data:
                    return []
                for kpi_key in data.keys():
                    match = re.match(r'kpi(\d+[a-zA-Z]?)', kpi_key)
                    if match:
                        self.kpi_numbers.append(f"KPI#{match.group(1)}")
                return self.kpi_numbers
        except FileNotFoundError:
            info("KPI file not found")
            return None
        except TypeError:
            info("KPI file not found")
            return None

    def _replace_kpi_placeholders(self, modified_template, kpi_values):
        """
        Replace KPI placeholders in the HTML template with actual KPI values.

        :param string modified_template: Modified template for the HTML
        :param list kpi_values: List of KPI values to insert

        :return: The modified template with KPI values replaced
        """
        for values in kpi_values:
            for key, idx in zip(["min", "avg", "max"], range(3)):
                try:
                    value = values[idx] if len(values) > idx else ""
                    modified_template = modified_template.replace(
                        f"{{{{result_sw.{key}}}}}", str(value), 1
                    )
                except IndexError:
                    info(f"IndexError: KPI_values[{idx}] is out of range")
        return modified_template

    def write_html(self, modified_template, omkpi_case):
        """
        Write the OMKPI HTML report.

        :param string modified_template: Modified template for the HTML
        :param bool omkpi_case: Whether the test is an OMKPI case or not
        """
        if omkpi_case:
            omkpi_report_time = datetime.now().strftime("%Y%m%d_%H%M%S")
            html_path = os.path.join(log_folder, f"OMKPI_{omkpi_report_time}.html")
            kpi_values = self._get_kpi_values(omkpi_case=omkpi_case)
            try:
                with open(html_path, "w", encoding="utf-8") as file:
                    if kpi_values:
                        modified_template = self._replace_kpi_placeholders(modified_template, kpi_values)
                    else:
                        info("KPI_values not found")
                    writing = modified_template
                    file.write(writing)
            except UnicodeDecodeError as e:
                print(f"UnicodeDecodeError: {e}")
                with open(html_path, "w", encoding="ISO-8859-1") as file:
                    file.write(writing)

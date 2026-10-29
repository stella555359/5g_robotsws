import json
import os
import multiprocessing
from robot.libraries.BuiltIn import BuiltIn
from difflib import get_close_matches
from xml.etree import ElementTree as et


class NameChanger:
    ROBOT_LIBRARY_SCOPE = 'SUITE'
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.suite_file_path = BuiltIn().get_variable_value("${SUITE SOURCE}")
        self.qc_test_name = ""
        self.qc_list = []

    def iterate_over_json(self, json_obj):
        for key, value in json_obj.items():
            if isinstance(value, dict):
                self.iterate_over_json(value)
            else:
                self.qc_list.append(value)

    def filter_qc_list(self):
        for element in self.qc_list:
            if isinstance(element, list):
                for el in element:
                    self.qc_list.append(el)
                self.qc_list.remove(element)

    def get_test_name_from_qc_file(self, test_name):
        qc_file_path = self.suite_file_path.rsplit('.', 1)[0] + ".qc"
        if os.path.isfile(qc_file_path):
            with open(qc_file_path, "r") as qc_file:
                qc_json = json.load(qc_file)
                self.iterate_over_json(qc_json)
                self.filter_qc_list()
                match_result = get_close_matches(test_name, self.qc_list, n=len(self.qc_list), cutoff=0.8)
                return match_result[0]

    def change_test_name(self, output_file_path):
        print("Changing test name to match QC name...")
        multiprocessing.parent_process().join(timeout=10)
        if output_file_path:
            if output_file_path != "NONE":
                if os.path.isfile(output_file_path):
                    with open(output_file_path, "rb") as of:
                        tree = et.parse(of)
                        tree.find(".//test/[@id='s1-t1']").attrib['name'] = self.qc_test_name
                        tree.write(output_file_path)
                    print("QC name set to", self.qc_test_name)

    def _end_test(self, name, attrs):
        self.qc_test_name = self.get_test_name_from_qc_file(name)
        output_file_path = BuiltIn().get_variable_value('${OUTPUT FILE}')
        proc = multiprocessing.Process(target=self.change_test_name, args=(output_file_path,))
        proc.start()

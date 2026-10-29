import json
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.logger import logging, logger
import os
import pathlib
from taf.config.wts import wts
import regex as re


class JsonReader:
    @logger
    def __init__(self, relative_path_to_json="../../Template/l2_template.json", absolute_path="",
                 basic_setup_path="/opt/iphy/latest/basic_setup.cfg"):
        """Analyzer Class to analyze the L2 Template json file and provide data for Test Execution.

        Args:
            relative_path_to_json (str, optional):   should be used for test automation. Path is relative to this file.
                                        Defaults to "../../Template/l2_template.json".
            absPath (str, optional):    Only used im manually set. Absolute Path to json file. Defaults to "".
        """
        relative_path_to_json = "/" + relative_path_to_json
        self.get_file_path(relative_path_to_json, absolute_path)
        try:
            with open(self.absolute_path_to_json, "r", encoding="utf-8") as json_file:
                self.json_dict = json.load(json_file)
        except FileNotFoundError:
            logging.error("The specified Path for the Json File is wrong, you tried: %s,"
                          "the resulting path was %s", relative_path_to_json, self.absolute_path_to_json)
        self.variable_cell_dict = {}
        self.replace_variables_in_json(basic_setup_path)

    def get_file_path(self, relative_path, absolute_path=''):
        if absolute_path:
            self.absolute_path_to_json = absolute_path
        else:
            combined_paths = os.path.dirname(__file__) + relative_path
            self.absolute_path_to_json = str(pathlib.Path(combined_paths).resolve())

    @property
    def test_description(self):
        return self.json_dict["test_description"]

    @property
    def ue_profiles(self):
        return self.json_dict["ue_profiles"]

    @property
    def traffic_profiles(self):
        return self.json_dict["traffic_profiles"]

    @property
    def logs_and_traces(self):
        return self.json_dict["logs_and_traces"]

    @property
    def extra_options(self):
        return self.json_dict["extra_options"]

    @property
    def scenario_configuration(self):
        return self.json_dict["scenario_configuration"]

    @property
    def csi_report_profile(self):
        try:
            return self.json_dict["csi_report_profile"]
        except KeyError:
            return {}

    def replace_variables_in_json(self, basic_setup_path):
        for scenario_name, scenario in self.json_dict["test_description"].items():
            cells = scenario["cells_ue_mapping"].keys()
            for cell in cells:
                resulting_cell_name = determine_cell_name_for_variable(cell, basic_setup_path)
                cell_name = cell if isinstance(cell, str) and not cell.isdigit() else f"cell_{cell}"
                self.variable_cell_dict.update({cell_name: resulting_cell_name})

            self.json_dict["test_description"][scenario_name]["cells_ue_mapping"] = {
                self.variable_cell_dict.get(key, key): value
                for key, value in self.json_dict["test_description"][scenario_name]["cells_ue_mapping"].items()}


def determine_cell_name_for_variable(cell_name_variable, basic_setup_path):
    cells_by_duplex_type = determine_cell_configuration(basic_setup_path)
    duplex_type = get_duplex_from_variable(cell_name_variable)
    cell_number = get_cell_number_from_variable_name(cell_name_variable)
    try:
        resulting_cell = cells_by_duplex_type[duplex_type][cell_number]
        logging.info(f"translated %s to %s", cell_name_variable, resulting_cell)
    except KeyError:
        logging.warning("cell_name is probably not given in variable form or not enough cells are configured. "
                        "using cell '%s'",
                        cell_name_variable)
        resulting_cell = cell_name_variable
    except IndexError:
        logging.error(f'It seems like the amount of cells in the basic setup is not sufficient.\n{cells_by_duplex_type}\
                       \n{duplex_type}\n{cell_number}')
        resulting_cell = cell_name_variable
    return resulting_cell


def get_cell_number_from_variable_name(variable):
    cell_number = re.search(r"(?!:_)\d", variable).captures()
    cell_number = int(cell_number[0]) - 1
    return cell_number


def get_duplex_from_variable(variable):
    if "tdd" in variable:
        return "tdd"
    if "fdd" in variable:
        return "fdd"
    else:
        return variable


def determine_cell_configuration(basic_setup_path="/opt/iphy/latest/basic_setup.cfg"):
    wtsobj = wts()
    wtsobj.load_wts_cfg(basic_setup_path)
    cell_commands = wtsobj.find_all("set_cell")
    cells_by_duplex_type = {"tdd": [], "fdd": []}
    for cell in cell_commands:
        cell_id = re.findall(r"id=(\d+)", cell)[0]
        if "enb" in cell:
            continue
        if "tdd_cell=on" in cell:
            cells_by_duplex_type["tdd"].append(cell_id)
        else:
            cells_by_duplex_type["fdd"].append(cell_id)
    return cells_by_duplex_type

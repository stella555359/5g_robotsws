"""
Used to manage scf Changes before sending them to commissioning
"""


import collections
import json
import logging
import re

import xmltodict

logging.basicConfig(level=logging.DEBUG)


class ScfChanges:
    """Class to manage scf_changes. Creates output for "Commission Managed Object List"

    Args:
        scf_content (str): The content of the current gnb scf file.
    """

    def __init__(self, scf_content="") -> None:
        self.changes_tree = {}
        self.dists_created: list[str] = []
        self.scf_content = scf_content

    def load_scf(self, scf_content):
        """Load the current SCF into the Class (meant for robot only.
        for python the file should be given during initialization)

        Args:
            scf_content (str): The Content of the current SCF, used for filling missing parameters.
        """
        self.scf_content = scf_content

    def add_robot_change(self, regex, p_name, value, list_name=None):
        """Provides a robot interface to be compatible with older commissioning methods

        Args:
            regex (str): regular expression for the distName
            p_name (str): parameter Name for the change
            value (str): parameter Value for the change
            list_name (str, optional): list name, only for list parameters. Defaults to None.
        """
        change = {
            "regex": regex,
            "p_name": p_name,
            "value": value}
        if list_name:
            change.update({"list_name": list_name})
        self.add_change(change)

    def add_change(self, change):
        """add a scf change

        Args:
            change (dict): dict with the change parameters, can be either a simple change or a complex change or
            a whole list.
            Example for simple change:
            {
                "regex": "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+",
                "p_name": "reqMinNumPuschPrb",
                "value": "30"}
            Example for complex change:
            {
                "regex": "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+",
                "list_name": "periodicCsiAcquisition",
                "p_name": "csiReportPeriodicity",
                "value": "slots160"}
            Example for whole list:
            {
                "regex": "MRBTS-1/NRBTS-1/NRCELL-[1-9]+",
                "list_name": "measPrMaSAList",
                "whole_list": [
                {
                    "measPrPriority": 11,
                    "nrMeasPrMaSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"
                },
                {
                    "measPrPriority": 10,
                    "nrMeasPrMaSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"
                }]
            }
            for each change you can give '"operation": "update | delete | create"' as an optional attribute.
        """
        if not self.changes_tree.get(change["regex"]):
            self.changes_tree.update({change["regex"]: {"complex_changes": {}, "simple_changes": {},
                                                        "list_objects": {}, "dist_deletion": False}})
        if change.get('operation') == 'delete':
            self.changes_tree[change['regex']]['dist_deletion'] = True
            logging.info('dist deletion for %s', change['regex'])
            return
        if change.get('whole_list'):
            self._add_whole_list(change)
            return
        if "list_name" in change:
            self._add_complex_scf_change(change)
        elif not change.get("p_name"):
            pass
        else:
            self._add_simple_scf_change(change)

    def _add_whole_list(self, change):
        if not self.changes_tree[change["regex"]]["list_objects"].get(change["list_name"]):
            self.changes_tree[change["regex"]]["list_objects"].update({change["list_name"]: []})
        self.changes_tree[change["regex"]]["list_objects"][change["list_name"]].extend(change["whole_list"])

    def _add_complex_scf_change(self, change):
        logging.info("adding complex scf change: %s", change)
        if not self.changes_tree[change["regex"]]["complex_changes"].get(change["list_name"]):
            self.changes_tree[change["regex"]]["complex_changes"].update({change["list_name"]: {}})

        self.changes_tree[change["regex"]]["complex_changes"][change["list_name"]].update(
            {change["p_name"]: change["value"]})

    def _add_simple_scf_change(self, change):
        if not self.changes_tree[change["regex"]]["simple_changes"].get(change["p_name"]):
            logging.info("adding simple scf change: %s", change)
            self.changes_tree[change["regex"]]["simple_changes"].update({change["p_name"]: change["value"]})
        else:
            logging.warning("the requested change %s already exists and will NOT be overwritten!", change)

    def get_modifications_for_commissioning(self, is_classical=True):
        """return a list of scf changes, that can be used by the admin API or the Keyword
        "Commission Managed Object List". If is_classical is set to False, AiC environment is expected,
        for this the output will instead be the path to a json file containing the modifications for
        the Keyword "Execute Delta Commissioning for Aic vDU with json"

        Returns:
            list: list of all scf changes that have been added with "add_change" and formatted for the admin API
        """
        managed_object_list = []
        for regex, changes in self.changes_tree.items():
            dist_names = list(set(re.findall(regex, self.scf_content)))
            if not dist_names:
                dists_to_create = self._get_non_existing_dists(regex)
                for dist in dists_to_create:
                    if dist not in self.dists_created:
                        managed_object_list.append(self._get_dist_creation(dist))
                        self.dists_created.append(dist)
                dist_names = [dists_to_create[-1]]
            for dist_name in dist_names:
                for list_name, values in changes["complex_changes"].items():
                    try:
                        current_parameters = self._get_missing_values_in_list(regex, list_name)[dist_name]
                        logging.info("found previous parameters: %s", current_parameters)
                    except KeyError as key_error:
                        current_parameters = {}
                        logging.warning('there seems to be no default '
                                        'parameters for your given list for distName: %s. KeyError: %s',
                                        dist_name, key_error)
                    managed_object_list.append(self._get_complex_change(
                        dist_name, list_name, values, current_parameters))
                for parameter_name, value in changes["simple_changes"].items():
                    managed_object_list.append(self._get_simple_change(
                        dist_name, parameter_name, value))
                for list_name, list_content in changes["list_objects"].items():
                    managed_object_list.append(self._get_simple_change(dist_name, list_name, list_content))
                if changes.get('dist_deletion'):
                    managed_object_list.append(self._get_dist_deletion(dist_name))
        if is_classical:
            return managed_object_list
        else:
            json_output_path = "/tmp/scf_changes.json"
            processed_api_request = self._post_process_aic_request(managed_object_list)
            with open(json_output_path, "w") as json_output:
                json.dump(processed_api_request, json_output)
            return json_output_path

    def _get_non_existing_dists(self, dist_name: str):
        dist_names = []
        found_dist = False
        while not found_dist:
            dist_names.append(dist_name)
            dist_name = dist_name[:dist_name.rfind('/')]
            if re.findall(dist_name, self.scf_content):
                found_dist = True
        dist_names.reverse()
        return dist_names

    @staticmethod
    def _get_dist_deletion(dist_name):
        dist_deletion = {
            "distName": dist_name,
            "operation": "delete",
            "parameters": []
        }
        return dist_deletion

    @staticmethod
    def _get_dist_creation(dist_name):
        dist_creation = {
            "distName": dist_name,
            "operation": "create",
            "parameters": []
        }
        return dist_creation

    @staticmethod
    def _get_simple_change(distName, parameter_name, value):
        simple_change = {
            "distName": distName,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": parameter_name,
                    "value": value,
                    "operation": "update"
                }
            ]
        }
        return simple_change

    @staticmethod
    def _get_complex_change(distName, list_name, parameters, current_parameters):
        """return a complex change. Almost Identical to a simple change, except that
        parameterName is the list name (name of  the object) and the value is a list containing
        key, value pairs.
        Args:
            distName (str): _description_
            list_name (str): _description_
            parameters (dict): _description_
            current_parameters (dict): _description_

        Returns:
            dict: complex change for  class structure
        """
        # prepare parameters
        formatted_parameters = current_parameters
        parameter_list = []
        for parameter_name, parameter_value in parameters.items():
            if parameter_name:
                formatted_parameters.update({parameter_name: parameter_value})
            else:
                parameter_list.append(parameter_value)
        if formatted_parameters:
            parameter_list.append(formatted_parameters)
        complex_change = ScfChanges._get_simple_change(distName, list_name, parameter_list)
        return complex_change

    def _get_missing_values_in_list(self, dist_regex, list_name):
        xml_dict = xmltodict.parse(self.scf_content)
        cmData = xml_dict["raml"]["cmData"]
        pattern = re.compile(dist_regex)
        result_dict = {}
        relevant_objects = [managedObject for managedObject in cmData["managedObject"]
                            if pattern.fullmatch(managedObject["@distName"])]
        for managedObject in relevant_objects:
            current_distName = (managedObject["@distName"])
            try:
                relevant_list_objects = [list_object for list_object in managedObject.get("list")
                                         if list_object["@name"] == list_name]
            except TypeError:
                logging.info("skipping %s, since it does not contain lists")
                relevant_list_objects = []
            for list_object in relevant_list_objects:
                result_dict.update({current_distName: {}})
                for list_item in list_object.values():
                    if not isinstance(list_item, collections.OrderedDict):
                        continue
                    if isinstance(list_item['p'], str):
                        result_dict[current_distName].update(
                            {list_item["p"]["@name"]: list_item["p"]["#text"]})
                    elif isinstance(list_item['p'], list):
                        parameters = self._get_parameters_from_complex_list(list_item)
                        result_dict[current_distName].update(parameters)
        if not result_dict:
            logging.warning("could not find any existing entry for your search. Please check your regex.")
        return result_dict

    @staticmethod
    def _get_parameters_from_complex_list(list_item):
        parameter_dict = {parameter["@name"]: parameter["#text"] for parameter in list_item['p']}
        for p_name, value in parameter_dict.items():
            try:
                parameter_dict[p_name] = int(value)
            except ValueError:
                pass
        return parameter_dict


if __name__ == '__main__':
    scf_test = '/home/ute/csamson/TRACES/scf.xml'
    with open(scf_test, 'r') as scf_content:
        scf_content = scf_content.read()
    listscfchange = {
        "regex": "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+",
        "p_name": "reqMinNumPuschPrb",
        "value": "30"}
    scf_changes = ScfChanges(scf_content)
    scf_changes.add_change(listscfchange)
    listscfchange = {
        "regex": "MRBTS-[0-9]+/NRBTS-[0-9]+/NRDRB-14",
        "p_name": "allowedPdcchPowerBoostALDueCce",
        "value": "AL2_AL4"}
    scf_changes.add_change(listscfchange)
    modifications = scf_changes.get_modifications_for_commissioning()
    modifications = sorted(modifications, key=lambda d: d['distName'])
    with open('/tmp/delta_scf_new.json', 'w') as file:
        json.dump(modifications, file, indent=4)

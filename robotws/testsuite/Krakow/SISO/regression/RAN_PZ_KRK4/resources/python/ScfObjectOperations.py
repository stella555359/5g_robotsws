"""
Operations on site configuration file object.

:copyright: Nokia Networks
:author: Rafal Kawa
:contact: rafal.kawa@nokia.com
:maintainer: rafal.kawa@nokia.com
"""

import json
import logging
import re
import os

from random import choice
from taf.internal.sbts.admin.exceptions import AdminApiProcedureTimeoutException
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.utilities.test_config import DefaultFileLocation
from taf.rfrl.procedures.resources.python.json_delta_scf.exceptions import ObjectsNotFound


class ScfObjectOperations(object):
    """
    A class to perform operations on SCF (Site Configuration File) objects.

    This class provides methods to update parameters, retrieve nested parameters,
    and perform other operations on SCF objects related to GNB SCF operations.
    """

    def __init__(self):
        """
        Initializes the ScfObjectOperations class.
        """
        self._gnb_scf = None
        self._object_dist_name = None

    @property
    def gnb_scf(self):
        """
        Returns the GnbCommissioning instance.
        If the instance doesn't exist, it creates a new one and returns it.
        Returns:
            GnbCommissioning: The GnbCommissioning object for GNB SCF operations.
        """
        if self._gnb_scf is None:
            self._gnb_scf = GnbCommissioning()
        return self._gnb_scf

    def update_nested_param_from_scf_structure(self, param_name, param_value, structure_name, object_class_name,
                                               object_dist_name_pattern, remove_param=False, bts_id=0, du_id=0):
        """
        Updates a parameter from SCF structure.

        Args:
            param_name (str): The name of the parameter to be updated.
            param_value (any): The new value of the parameter.
            structure_name (str): The name of the structure containing the parameter.
            object_class_name (str): The name of the object class to retrieve.
            object_dist_name_pattern (str):
            remove_param (bool, optional): Whether to remove the parameter. Defaults to False.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        structure = self.get_object_from_scf(dist_name_pattern=object_dist_name_pattern,
                                             object_class_name=object_class_name,
                                             bts_id=bts_id, du_id=du_id)["params"].get(structure_name)[0]
        logging.info(f"Structure '{structure_name}' before update: '{structure}'")
        if remove_param:
            del structure[param_name]
        else:
            structure.update({param_name: param_value})
        self._update_structure_from_scf_object(structure_name=structure_name, structure_body=structure)

    def update_power_saving_cell_switch_off_order(self, cell_id, order_value, nrpgrp_dist_name_pattern, bts_id=0,
                                                  du_id=0, timeout=180):
        """
        Updates the power saving cell switch off order.

        Args:
            cell_id (int): The ID of the cell.
            order_value (any): The new value for the lbpsCellSOOrder.
            nrpgrp_dist_name_pattern (str): The distname pattern for the NRPGRP.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            timeout (int, optional): The maximum time to wait for the operation in seconds. Defaults to 180.
        """
        lbps_cell_list = self.get_param_from_scf_object(
            param_name="lbpsCellList", object_class_name="com.nokia.srbts.nrbts:NRPGRP",
            object_dist_name_pattern=nrpgrp_dist_name_pattern, bts_id=bts_id, du_id=du_id, timeout=timeout)
        logging.info(f"lbpsCellList before update: '{lbps_cell_list}'")
        for structure in lbps_cell_list:
            if structure["nrCellId"] == str(cell_id):
                structure.update({"lbpsCellSOOrder": order_value})
        self._update_structure_from_scf_object(structure_name="lbpsCellList", structure_body=lbps_cell_list)

    def set_lowermost_value_to_power_saving_cell_switch_off_order(self, cell_id, nrpgrp_dist_name_pattern="NRPGRP-1",
                                                                  delta=1, bts_id=0, du_id=0, timeout=180):
        """
        Sets the lowermost value of the power saving cell switch off order (lbpsCellSOOrder) to cell_id.

        This method retrieves lbpsCellList and calculates lowermost lbpsCellSOOrder value based on given delta and
        assign it to cell_id.

        Args:
            cell_id (int): The ID of the cell.
            nrpgrp_dist_name_pattern (str, optional): The distname pattern for the NRPGRP. Defaults to "NRPGRP-1".
            delta (int, optional): The delta to calculate lowermost lbpsCellSOOrder value. Defaults to 1.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            timeout (int, optional): The maximum time to wait for the operation in seconds. Defaults to 180.
        """

        def convert_and_find_minimum(lst):
            """
            Converts the elements of the list to integers and returns the lowest value.
            """
            try:
                int_list = [int(element) for element in lst]
                return min(int_list)
            except ValueError as e:
                raise ValueError("List contains non-convertible elements or is empty") from e

        lowest_ps_switch_off = convert_and_find_minimum(self.get_nested_param_from_scf_structure(
            nested_param_name="lbpsCellSOOrder", structure_name="lbpsCellList",
            object_class_name="com.nokia.srbts.nrbts:NRPGRP", object_dist_name_pattern=nrpgrp_dist_name_pattern,
            bts_id=bts_id, du_id=du_id, timeout=timeout))
        self.update_power_saving_cell_switch_off_order(cell_id=cell_id, order_value=lowest_ps_switch_off - delta,
                                                       nrpgrp_dist_name_pattern=nrpgrp_dist_name_pattern,
                                                       bts_id=bts_id, du_id=du_id)

    def get_nested_param_from_scf_structure(self, nested_param_name, structure_name, object_class_name,
                                            object_dist_name_pattern, return_random_value=False, bts_id=0, du_id=0,
                                            timeout=180):
        """
        Retrieves nested parameter values from the SCF structure.

        Args:
            nested_param_name (str): The name of the nested parameter to retrieve.
            structure_name (str): The name of the structure containing the nested parameter.
            object_class_name (str): The name of the object class to retrieve.
            object_dist_name_pattern (str): The distribution name pattern for the object.
            return_random_value (bool, optional): Whether to return a random value from the nested parameters.
            Defaults to False.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            timeout (int, optional): The maximum time to wait for the operation in seconds. Defaults to 180.

        Returns:
            list or any: A list of nested parameter values or a single random value if return_random_value is True.
        """
        nested_param_values = [structure[nested_param_name] for structure in
                               self.get_param_from_scf_object(structure_name, object_class_name,
                                                              object_dist_name_pattern,
                                                              bts_id, du_id, timeout)]
        if return_random_value:
            return choice(nested_param_values)
        else:
            return nested_param_values

    def get_param_from_scf_object(self, param_name, object_class_name, object_dist_name_pattern, bts_id=0, du_id=0,
                                  timeout=180):
        """
        Retrieves a parameter from the SCF object.

        Args:
            param_name (str): The name of the parameter to retrieve.
            object_class_name (str): The name of the object class to retrieve.
            object_dist_name_pattern (str): The distribution name pattern for the object.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            timeout (int, optional): The maximum time to wait for the operation in seconds. Defaults to 180.

        Returns:
            any: The value of the specified parameter from the SCF object.
        """
        return self.get_object_from_scf(dist_name_pattern=object_dist_name_pattern,
                                        object_class_name=object_class_name, bts_id=bts_id, du_id=du_id,
                                        timeout=timeout)["params"][param_name]

    def get_object_from_scf(self, dist_name_pattern, object_class_name, bts_id=0, du_id=0, timeout=180):
        """
        Retrieves an object from the SCF based on the specified parameters.

        Args:
            dist_name_pattern (str): The distribution name pattern to match the object.
            object_class_name (str): The name of the object class to retrieve.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            timeout (int, optional): The maximum time to wait for the operation in seconds. Defaults to 180.

        Returns:
            dict: The SCF object that matches the specified parameters.

        Raises:
            NotFoundInScfException: If no object matching the specified parameters is found in the SCF.
        """
        _re_dist = re.compile(f'(?P<DISTNAME>{dist_name_pattern})', re.I)
        scf_object = [obj for obj in
                      self._get_all_object_classes_from_scf(object_class_name=object_class_name, bts_id=bts_id,
                                                            du_id=du_id, timeout=timeout) if
                      _re_dist.search(obj['dist_name'])]
        if scf_object:
            self._object_dist_name = scf_object[0]['dist_name']
            return scf_object[0]
        else:
            raise NotFoundInScfException(f"{object_class_name} with dist name pattern {dist_name_pattern}")

    def _update_structure_from_scf_object(self, structure_name, structure_body, operation="update"):
        """
        Update the SCF structure.

        Args:
            structure_name (str): The name of the structure.
            structure_body (list or dict): The structure body.
            operation (str, optional): The operation to perform. Defaults to "update".
        """
        recommissioning_structure = [{"parameterName": structure_name,
                                      "operation": operation,
                                      "value": structure_body if isinstance(structure_body, list) else [
                                          structure_body]}]

        self.gnb_scf.perform_object_recommissioning(
            dist_name=self._object_dist_name,
            parameter=recommissioning_structure,
            operation="update")

    def _get_all_object_classes_from_scf(self, object_class_name, export_type="configurationAndRuntimeObjects",
                                         bts_id=0, du_id=0, timeout=180, max_attempts=3):
        """
        Retrieves an object from the SCF based on the specified parameters.

        Args:
            object_class_name (str): The name of the object class to retrieve.
            export_type (str, optional): The export type. Defaults to "configurationAndRuntimeObjects".
            bts_id (int, optional): The BTS ID. Defaults to 0.
            du_id (int, optional): The DU ID. Defaults to 0.
            timeout (int, optional): The timeout value in seconds. Defaults to 180.
            max_attempts (int, optional): The maximum number of attempts to retrieve the object. Defaults to 3.

        Returns:
            list: List of dicts consist of SCF object.

        Raises:
            Exception: If the SCF object could not be retrieved after the maximum number of attempts.
        """
        scf_object = None
        while max_attempts > 0:
            try:
                scf_object = self.gnb_scf.get_all_params_under_class_name(class_name=object_class_name,
                                                                          scf_export_type=export_type, bts_id=bts_id,
                                                                          du_id=du_id, timeout=timeout)
            except AdminApiProcedureTimeoutException:
                max_attempts -= 1
                logging.info(f"AdminApiProcedureTimeoutException occurred during "
                             f"attempt of get '{object_class_name}' object from SCF.")
            else:
                return scf_object
        if not scf_object:
            raise NotFoundInScfException(object_class_name)

    @staticmethod
    def get_scf_path_from_repository(prefix_tag=None, sub_device=None, bts_type='GNB', bts_id=0):
        """
        Constructs the path to the SCF (Site Configuration File) from the repository.

        Args:
            prefix_tag (str, optional): Prefix tag for the SCF name. Defaults to None.
            sub_device (str, bool): Sub-device name. Defaults to None.
            bts_type (str, optional): Type of the BTS (Base Transceiver Station). Defaults to 'GNB'.
            bts_id (int, optional): ID of the BTS. Defaults to 0.

        Returns:
            str: The constructed path to the SCF.
        """
        dfl = DefaultFileLocation()
        return os.path.join(dfl.get_commissioning_dir(),
                            dfl.get_default_scf_name(bts_type=bts_type, bts_id=bts_id, prefix_tag=prefix_tag,
                                                     sub_device=sub_device))

    @staticmethod
    def get_object_info_form_delta(json_delta_file, pattern, operation):
        """
        Extracts object information matching a regex pattern from a JSON delta file.
        Method dedicated for delta files generated by generate_json_delta from
        taf.rfrl.procedures.resources.python.json_delta_scf.JsonDeltaCommissioning

        Args:
            json_delta_file (str): Path to the JSON delta file.
            pattern (str): Regex pattern to match object distribution names. Defaults to '(NRPGRP-)[^/]*$'.
            operation (str): Operation type in the JSON delta file ("added", "removed", "changed"). Defaults to "added".

        Returns:
            dict: A dictionary with matched object information.

        Raises:
            ObjectsNotFound: If no objects match the pattern and operation in the JSON delta file.
        """
        with open(json_delta_file) as delta_file:
            delta_data = json.load(delta_file)

        matched_objects = {
            obj["dist_name"]: {
                "id": obj["dist_name"].split("-")[-1],
                "object_name": "/".join(obj["dist_name"].split("/")[:-1]),
                "object_class": obj["dist_name"].split("/")[-1].split("-")[0],
            }
            for obj in delta_data.get(operation, [])
            if re.search(pattern, obj["dist_name"])
        }

        if not matched_objects:
            raise ObjectsNotFound(
                f"No objects found for pattern '{pattern}' under operation '{operation}' in file '{json_delta_file}'."
            )

        return matched_objects


class NotFoundInScfException(Exception):
    """Exception raised for missing object in Site Configuration File."""

    def __init__(self, object_class_name):
        self.object_class_name = object_class_name
        super().__init__(f"Not found in SCF object: '{object_class_name}'")

# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska, Beata Kapusta
:maintainer:  Adrianna Pienkowska, Beata Kapusta
:contact: adrianna.pienkowska@nokia.com, beata.kapusta@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import os
import time
import json
import xml.etree.ElementTree as ET
from contextlib import contextmanager

from taf.gnb.oam.coam.cu import cu
from taf.selenium.gnb.oam.coam.cu import cu as cu_selenium
from taf.internal.gnb.oam.coam.cu.client.asm.v1.exceptions import ApiException

from testsuite.Paris.RRM.ET.resources_KRK.python.common_AIC import AIC, sleep, BuiltIn, read_delta_json_file
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import (
    logger_console, logger_warning, get_newest_file_in_vm_directory)


class VCUException(Exception):
    pass


def _rewrite_array_to_list(parameters_list):
    """
    Rewrites array to list

    :param parameters_list:
    :return: list of dictionaries
    """
    param_dict_to_return = []
    for param_dict in parameters_list:
        if isinstance(param_dict['value'], list):
            value_list = param_dict['value']
            main_parameter_path = param_dict['parameter_path']
            for key, value in value_list[0].items():
                parameter_path = '{}/{}'.format(main_parameter_path, key)
                new_dict = {'parameter_path': parameter_path, 'value': value,
                            'operation_type': param_dict['operation_type']}
                param_dict_to_return.append(new_dict)
        else:
            param_dict_to_return.append(param_dict)
    return param_dict_to_return


class vCU(AIC):
    """
    vCU Class
    """
    def __init__(self):
        self.host = BuiltIn().get_variable_value('${VCU_OAM_ADDRESS}')
        self.username = BuiltIn().get_variable_value('${VCU_OAM_USERNAME}')
        self.password = BuiltIn().get_variable_value('${VCU_OAM_PASSWORD}')
        super().__init__(cu())

    def __str__(self):
        return "vCU"

    @contextmanager
    def selenium_session(sw_version, url='https://192.168.100.129/login'):
        """
        Creates selenium session with vCU webem

        :param sw_version: sw version uploaded to vCU eg: 5G22R3
        :param url: url to login to vCU webem
        """
        selenium = cu_selenium()
        try:
            selenium.login(url=url, version=sw_version)
            yield selenium
        finally:
            selenium.logout()

    def use_selenium(self):
        """
        Uses selenium to add object to vCU configuration plan
        """
        with self.selenium_session(sw_version='5G22R3') as selenium:
            chosen_plan = selenium.choose_plan(plan_name='new_plan')
            selenium.add_object(dist_name='MRBTS-1900', object_class_name='MRBTSDESC', is_load_default_values=True,
                                id_value=0)

    def generate_delta_plan(self, generate_fun=None, delete_fun=None, info_list_fun=None):
        """
        Generates delta plan

        :param generate_fun: function to generate delta plan
        :param delete_fun:   function to delete existing delta plan
        :param info_list_fun: function to generate get status of deleting delta plan
        """
        generate_fun = self.interface.generate_delta_plan
        delete_fun = self.interface.delete_delta_plan
        info_list_fun = self.interface.get_delta_plan_list
        super().generate_delta_plan(generate_fun, delete_fun, info_list_fun)

    def _find_mo_obj_nidd_id(self, connection, mo_obj_name):
        """
        Finds mo obj nidd id

        :param connection: connection to vCU
        :param mo_obj_name: name of MO object to find
        """
        all_mo_oj = connection.get_nidd(connection='default')
        for mo_oj in all_mo_oj:
            if mo_obj_name == mo_oj['class_name']:
                return mo_oj['nidd_id']

    def _get_mo_uuid_of_an_existing_object(self, object_name, connection):
        """
        Gets MO_UUID of an object, that is present in current plan file

        :object_name: (str) Object name with its ID e.g LUAC-1
        :connection:  (cu)  Connection instance
        """
        diff_tree = connection.get_delta_plan_tree_diff(plan_id='dp_00000000')
        for item in diff_tree['created']:
            if item['name'] == object_name:
                return item['mo_uuid']

    def _add_mo_object(self, dist_info, connection):
        """
        Adds mo object

        :param dist_info: the mo distName that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1
        :param connection: connection to vCU
        """
        mo_dn = dist_info['distName'].split('/')
        parent_uuid = self._get_mo_uuid_of_an_existing_object(mo_dn[-2], connection)
        nidd_id = self._find_mo_obj_nidd_id(connection, mo_dn[-1].split('-')[0])
        connection.create_managed_object_of_delta_plan(plan_id='dp_00000000', parent_mo_uuid=parent_uuid,
                                                       nidd_id=nidd_id, instance_id=1, include_defaults=False)

    def _delete_mo_object(self, dist_info, connection):
        """
        Deletes mo object

        :param dist_info: the mo distName that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1
        :param connection: connection to vCU
        """
        mo_dn = dist_info['distName'].split('/')
        mo_uuid = self._get_mo_uuid_of_an_existing_object(mo_dn[-1], connection)
        if mo_uuid is None:
            logger_warning('Managed object {} not found, deleting skipped'.format(mo_dn[-1]))
        else:
            connection.delete_managed_object_of_delta_plan(plan_id='dp_00000000', mo_uuid=mo_uuid)

    def _parse_delta_distname(self, distname_data):
        """
        Parses delta distname

        :param distname_data: (list) delta distname data
        :return: dict with MO uuid and parameter change list
        """
        return {'mo_uuid': distname_data['distName'], 'parameter_change_list': distname_data['parameters']}

    def update_parameters(self, parameters_list, mo_uuid, connection):
        """
        Updates parameter

        :param parameters_list: list of parameters to update
        :param mo_uuid: the mo uuid
        :param connection: connection instance to vCU
        :return: updated parameter dict
        """
        time.sleep(1)
        if parameters_list:
            try:
                update = connection.update_parameters_of_delta_plan(plan_id='dp_00000000', mo_uuid=mo_uuid,
                                                                    parameter_change_list=parameters_list)
                time.sleep(1)
            except ApiException as api_error:
                if '[json.exception.type_error.302] type must be string, but is array' in str(api_error):
                    parameters_list = _rewrite_array_to_list(parameters_list)
                    update = connection.update_parameters_of_delta_plan(plan_id='dp_00000000', mo_uuid=mo_uuid,
                                                                        parameter_change_list=parameters_list)
                else:
                    raise api_error
            return update

    def upload_delta(self, file_path, connection):
        delta = read_delta_json_file(file_path)
        time.sleep(5)
        for distname in delta:
            time.sleep(3)
            dist_name = distname['distName'].split('/')
            if distname['operation'] == 'delete':
                self._delete_mo_object(distname, connection)
                continue
            if distname['operation'] == 'add':
                self._add_mo_object(distname, connection)
            time.sleep(3)
            mo_uuid = self._get_mo_uuid_of_an_existing_object(dist_name[-1], connection)
            self.update_parameters(distname['parameters'], mo_uuid, connection)

    def update_and_activate_delta_plan(self, delta_plan_path):
        """
        Updates and activates delta plan

        :param delta_plan_path: path to delta plan
        :return: nothing
        """
        with self.admin_session() as connection:
            self.generate_delta_plan(connection)
            logger_console("Sending delta to vCU")
            self.upload_delta(delta_plan_path, connection)
            sleep("Waiting between uploading and validating delta", 10)
            validate = connection.validate_delta_plan(plan_id='dp_00000000', connection='default')
            activate = connection.activate_delta_plan(plan_id='dp_00000000', connection='default')
        repeat = 0
        while repeat < 5:
            repeat += 1
            try:
                with self.admin_session() as connection:
                    status = connection.get_operation_state_of_activating_delta_plan(
                        plan_id='dp_00000000', operation_id=activate['operation_id'], connection='default')
                if status['status'] == 'success':
                    logger_console("vCU delta activation status: {}".format(status['status']))
                    break
                assert status['status'] != 'failure', "vCU delta activation status: {}".format(status)
            except ApiException as err:
                if "Service unavailable" in str(err):
                    sleep("vCU rebooting", 180)
                    continue
                raise
            except AssertionError as err:
                if 'No change in this plan' in status['error_message']:
                    logger_warning('No changes in delta file {}, moving forward'.format(delta_plan_path))
                    break
                raise
            sleep("vCU delta activation status: {}".format(status['status']), 15)

    def get_plan_file(self, file_path):
        """Download vCU plan file (scf)."""
        with self.admin_session() as connection:
            connection.get_current_plan_file(path=file_path)

    @staticmethod
    def get_mrbts_nrbts_val_from_vcu_plan(file_path):
        """
        Get MRBTS and NRBTS ids from vCU plan file.

        :return mrbts_id, nrbts_id: (str, str)
        """
        with open(file_path, 'r') as plan:
            for line in plan.readlines():
                if 'NRBTS' in line:
                    for part in line.split(" "):
                        if 'distName' in part:
                            part = part.split('=')[1].strip('"')
                            mrbts_id = part.split('/')[0].split('-')[1]
                            nrbts_id = part.split('/')[1].split('-')[1]
                            return mrbts_id, nrbts_id

    def get_cu_version(self):
        with self.admin_session() as connection:
            return connection.get_active_software_version()

    def assert_vcu_status(self, status='enabled'):
        """
        Assert vCU is in proper state. VCU has no 'OnAir' state - 'Enabled' is expected.

        :status: (str) expected state
        :return: (bool) vCU in expected state
        """
        with self.admin_session() as connection:
            state = connection.get_cu_state()
            assert state['operational_state'] == status, "VCU status ({}) is not equal to {}".format(
                state['operational_state'], status)

    def commission_vcu(self, file_path):
        """
        Commission vCU

        :param file_path: (str) path to commissioning file
        :return: nothing
        """
        logger_console("Commissioning vCU with: {}".format(file_path.split('/')[-1]))
        with self.admin_session() as connection:
            output = connection.upload_plan_file(path_to_plan_file=file_path)
            try:
                status = connection.get_operation_state_of_uploading_plan(operation_id=output['action_id'])['status']
                assert status == 'success'
            except AssertionError:
                sleep(msg='Waiting for plan upload to succeed...', period=2)
                status = connection.get_operation_state_of_uploading_plan(operation_id=output['action_id'])['status']
                assert status == 'success', 'Failed to upload plan'
            connection.plan_activation(plan_id=output['plan_id'])

    def get_meas_period_from_vcu(self, mrbts_id='1900'):
        """
        Get measurement period from vCU

        :param mrbts_id: mrbts id (str)
        :return: meas period
        """
        with self.admin_session() as connection:
            params = connection.get_parameters(dist_name='MRBTS-{}/MNL-1/MNLENT-1/PMCADM-1'.format(mrbts_id))
            meas_period = params['parameters'][0]['simple_parameter'].value
            if meas_period != '5min':
                logger_warning('Measurement period is not equal to 5min! Check vCU plan!')
            return meas_period

    def reboot_unit(self):
        self.interface.reset_cu()

    def reboot_cu(self):
        with self.admin_session() as connection:
            connection.reboot_unit()

    def collect_vcu_snapshot(self, local_path, timestamp=True):
        with self.admin_session() as connection:
            connection.get_local_snapshot(directory=local_path)
        file = get_newest_file_in_vm_directory(local_path)
        file_split = file.split('/')
        if timestamp:
            file_split[-1] = 'Snapshot_vCU_' + file_split[-1].split('_')[-1]
        else:
            file_split[-1] = 'Snapshot_vCU.' + file_split[-1].split('.')[-1]
        new_file = '/'.join(file_split)
        os.rename(file, new_file)

    def __get_complex_parameter_maxoccurs_from_nidd(self, class_name, param_name, conn_alias='default'):
        with self.admin_session() as connection:
            nidd_info = connection.get_nidd()
        mo = list(filter(lambda x: x['class_name'] == class_name, nidd_info))
        params = mo[0]['parameters']
        for p_name, p_def in params.items():
            if p_name == param_name:
                try:
                    return int(p_def.complex_parameter_def.max_occurs)
                except AttributeError:
                    return int(p_def.simple_list_parameter_def.max_occurs)
        raise VCUException(f'Can not find the parameter {param_name} under {class_name}')

    def __delta_xml_file_to_aic_provision_delta_plan_payload(self, xml_file_path, conn_alias='default'):
        # Define the XML namespaces used in the document
        namespaces = {'r': 'raml21.xsd'}

        # Load the XML file
        tree = ET.parse(xml_file_path)
        root = tree.getroot()

        # Find all <managedObject> elements
        results = []
        for obj in root.findall('.//r:managedObject', namespaces):
            class_name = obj.attrib['class'].split(':')[1]
            dist_name = obj.attrib['distName']
            operation_type = obj.attrib['operation']
            payload = {}
            for param in obj.findall('r:p', namespaces):
                payload[param.attrib['name']] = param.text
            for lst in obj.findall('r:list', namespaces):
                if lst.findall('r:item', namespaces):
                    max_occurs = self.__get_complex_parameter_maxoccurs_from_nidd(class_name, lst.attrib['name'],
                                                                                  conn_alias=conn_alias)
                    if max_occurs > 1:
                        items = []
                        for item in lst.findall('r:item', namespaces):
                            item_payload = {}
                            for param in item.findall('r:p', namespaces):
                                item_payload[param.attrib['name']] = param.text
                            items.append(item_payload)
                        payload[lst.attrib['name']] = items
                    else:
                        item = lst.findall('r:item', namespaces)[0]
                        item_payload = {}
                        for param in item.findall('r:p', namespaces):
                            item_payload[param.attrib['name']] = param.text
                        payload[lst.attrib['name']] = item_payload
                else:
                    payload[lst.attrib['name']] = [p.text for p in lst.findall('r:p', namespaces)]
            results.append({
                'class_name': class_name,
                'dist_name': dist_name,
                'operation_type': operation_type,
                'payload': json.dumps(payload)
            })
        return results

    def upload_xml_delta_file(self, delta_path):
        xml_file_parsed = self.__delta_xml_file_to_aic_provision_delta_plan_payload(xml_file_path=delta_path)
        with self.admin_session() as connection:
            connection.provision_vcu_delta_plan(mo_info_list=xml_file_parsed)

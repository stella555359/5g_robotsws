# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska
:maintainer:  Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
:description:
:justification:
"""

import os
import re
import time
import json
import xml.etree.ElementTree as ET
from contextlib import contextmanager

from taf.gnb.oam.coam.vdu import Vdu
from taf.internal.gnb.oam.coam.vdu.client.asm.v1.exceptions import ApiException as duException

from testsuite.Krakow.RRM.Airphone.resources.Python.mcshark_management import prepare_mcshark_env
from testsuite.Krakow.RRM.Airphone.resources.Python.common_AIC import (
    AIC, AICCommonException, sleep, BuiltIn)
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import (
    logger_console, logger_warning, get_newest_file_in_vm_directory)


class VDUException(Exception):
    pass


class vDU(AIC):
    """
    vDU class
    """

    def __init__(self):
        self.host = BuiltIn().get_variable_value('${VDU_OAM_ADDRESS}')
        self.username = BuiltIn().get_variable_value('${VDU_OAM_USERNAME}')
        self.password = BuiltIn().get_variable_value('${VDU_OAM_PASSWORD}')
        super().__init__(Vdu())

    def __str__(self):
        return "vDU"

    def generate_delta_plan(self, generate_fun=None, delete_fun=None, info_list_fun=None):
        """
        Generates delta plan

        :param generate_fun: function to generate delta plan
        :param delete_fun:   function to delete existing delta plan
        :param info_list_fun: function to generate get status of deleting delta plan
        """
        generate_fun = self.interface.generate_delta_plan
        delete_fun = self.interface.delete_delta_plan_file
        info_list_fun = self.interface.get_delta_plan_info_list
        super().generate_delta_plan(generate_fun, delete_fun, info_list_fun)

    def upload_and_activate_delta_file(self, delta_file=''):
        """
        Uploads and activates delta plan

        :param delta_file: delta file
        :return: nothing
        """
        with self.admin_session() as connection:
            self.generate_delta_plan(connection)
            logger_console("Sending delta to vDU")
            super().upload_params(delta_file, connection.update_vdu_parameter_of_delta_plan,
                                  connection.create_vdu_object_of_delta_plan,
                                  connection.get_update_paras_action_status_of_delta_plan)
            sleep("Waiting between uploading and validating delta", 10)
            validate = connection.validate_delta_plan(delta_plan_id='dp_00000000')
            activate = connection.activate_delta_plan(delta_plan_id='dp_00000000')
        repeat = 0
        while repeat < 5:
            repeat += 1
            try:
                with self.admin_session() as connection:
                    status = connection.get_activate_delta_plan_operation_status(delta_plan_id='dp_00000000',
                                                                                 operation_id=activate['id'])
                    if status['status'] == 'success':
                        logger_console("vDU delta activation status: {}".format(status['status']))
                        break
                    assert status['status'] != 'failure', "vDU delta activation status: {}".format(status)
            except duException as err:
                if "Service unavailable" in str(err):
                    sleep("vDU rebooting", 60)
                    continue
                raise duException(str(err))
            except AttributeError as err:
                if 'MaxRetryError' in str(err):
                    sleep("vDU rebooting", 60)
                    continue
                raise AttributeError(str(err))
            sleep("vDU delta activation status: {}".format(status['status']), 15)

    def wait_for_vdu_status(self, status='onair'):
        """
        Waits for a given status.

        :param status: vDU status string
        :return: nothing
        """
        repeat = 0
        while repeat < 5:
            repeat += 1
            vdu_status = self.get_du_info().get('operational_state')
            if vdu_status.lower() == status.lower():
                logger_console(f"vDU properly reached status {status}, moving forward")
                break
            else:
                sleep(f"vDU currently in status {vdu_status}, waiting 60s for {status}", 60)

    def _parse_delta_distname(self, distname_data):
        """
        Parses delta distname

        :param distname_data: (list) delta distname data
        :return: dict with MO uuid and parameter change list
        """
        distname = distname_data['distName']
        param_dict = {}
        for param in distname_data['parameters']:
            if isinstance(param['value'], list):
                for id, element in enumerate(param['value']):
                    for subparam, value in element.items():
                        new_name = '{}/{}/{}'.format(param['parameter_path'], id, subparam)
                        param_dict.update({new_name: value})
            else:
                param_dict.update({param['parameter_path']: param['value']})
        return {'mo_dn': distname, 'updated_paras_dict': param_dict, 'operation': distname_data['operation']}

    def _add_mo_object(self, dist_info, add_fun):
        """
        Adds mo object

        :param dist_info: the mo distName that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1
        :param add_fun:
        :return: nothing
        """
        mo_dn = dist_info['mo_dn'].split('/')
        parent = '/'.join(mo_dn[:-1])
        try:
            out = add_fun('dp_00000000', parent_mo_dn=parent, mo_name=mo_dn[-1])
            if out['status'] != 'success':
                time.sleep(1)
        except duException as err:
            logger_warning("FAILED TO ADD {}/{}".format(parent, mo_dn))
            logger_warning(str(err))

    def get_plan_file(self, file_dir, file_name):
        """Download vDU plan file (scf)."""
        with self.admin_session() as connection:
            connection.get_current_plan_file(local_dir_path=file_dir, filename=file_name, include_runtime_data=False)

    def commission_vdu(self, file_path):
        """
        Commission vDU

        :param file_path: (str) path to commissioning file
        :return: nothing
        """
        logger_console("Commissioning vDU with: {}".format(file_path.split('/')[-1]))
        with self.admin_session() as connection:
            output = connection.upload_plan(path_to_plan_file=file_path)
            try:
                status = connection.get_upload_plan_operation_status(operation_id=output['action_id'])['status']
                assert status == 'success'
            except AssertionError:
                sleep(msg='Waiting for plan upload to succeed...', period=2)
                status = connection.get_upload_plan_operation_status(operation_id=output['action_id'])['status']
                assert status == 'success', 'Failed to upload plan: {}'.format(status)
            connection.activate_plan(plan_id=output['plan_id'])
        sleep("Waiting for vDU to reboot after plan activation", 300)

    def get_meas_period_from_vdu(self, mrbts_id='1900'):
        """
        Get measurement period from vDU

        :param mrbts_id: mrbts id (str)
        :return: meas period
        """
        with self.admin_session() as connection:
            meas_period = connection.search_parameter_of_current_plan(
                mo_dn='MRBTS-{}/MNL-1/MNLENT-1/PMCADM-1'.format(mrbts_id),
                para_name='reportingIntervalPm')
            if meas_period != '5min':
                logger_warning('Measurement period is not equal to 5min! Check vDU plan!')
            return meas_period

    def reboot_vdu(self, **kwargs):
        with self.admin_session() as connection:
            connection.reset_vdu()

    def reboot_unit(self):
        self.interface.reset_vdu()

    def wait_for_rute_to_vdu(self, **kwargs):
        """
        Waits fdo rute to vDU after reboot
        """
        connection = None
        while True:
            try:
                connection = Vdu().connect_to(**self._connection_args())
                break
            except Exception:
                sleep('Wait for connection', 60)
            finally:
                if connection:
                    connection.disconnect()

    def check_radio_status(self, expected_status):
        """
        Checks radio status

        :param expected_status: expected status of radio
        """
        with self.admin_session() as connection:
            rmods_status = connection.get_rmods_status(vdu_connection='default')
            for cell_id, cell_info in enumerate(rmods_status):
                print(rmods_status)
                if expected_status not in cell_info['availability_status']:
                    raise duException(
                        "Cell nr {} RMODs status is '{}' instead '{}'".format(
                            cell_id + 1, cell_info['availability_status'], expected_status
                        )
                    )

    def wait_until_radio_units_are_in_state(self, expected_status, retry=12, sleep_interval=60):
        """
        Waits until radio units are in expected state

        :param expected_status: expected status of radio
        :param retry: (int) number of retries
        :param sleep_interval: (int) sleep interval
        """
        tries = retry
        while retry > 0:
            try:
                self.check_radio_status(expected_status)
                break
            except duException:
                retry -= 1
            sleep('Wait for RMODs to be in a state: {}'.format(expected_status), sleep_interval)
        if retry is 0:
            raise duException('State {} not achieved after {} tries'.format(expected_status, tries))

    def wait_until_radio_units_are_online(self):
        """
        Wait until radio units are online
        """
        self.wait_until_radio_units_are_in_state(expected_status='on line')

    def get_du_version(self):
        with self.admin_session() as connection:
            return connection.get_vdu_state_data()['software_version']

    def get_du_info(self):
        with self.admin_session() as connection:
            return connection.get_vdu_state_data()

    def download_vdu_mcshark(self):
        du_version = self.get_du_version()
        groups_matched = re.match(r'(^[a-zA-Z]*)([a-zA-Z0-9]*)(.*)', du_version)
        du_version_no_release = groups_matched.group(1) + groups_matched.group(3)
        prepare_mcshark_env(gnb_build=du_version_no_release)

    def collect_vdu_snapshot(self, local_path, timestamp=True):
        with self.admin_session() as connection:
            connection.get_local_snapshot(directory=local_path, compressed_or_not=True)
        file = get_newest_file_in_vm_directory(local_path)
        file_split = file.split('/')
        if timestamp:
            file_split[-1] = 'Snapshot_vDU_' + file_split[-1].split('_')[-1]
        else:
            file_split[-1] = 'Snapshot_vDU.' + file_split[-1].split('.')[-1]
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
        raise VDUException('Can not find the parameter {} under {}'.format(param_name, class_name))

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
            connection.provision_vdu_delta_plan(mo_info_list=xml_file_parsed)

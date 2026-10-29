"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska, Beata Kapusta
:maintainer:  Mateusz Michalik
:contact: mateusz.michalik@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
import os
from functools import wraps

from taf.gnb.oam.coam.vdu import Vdu

from testsuite.Paris.RRM.ET.resources_KRK.krk3_common.Python.common_AIC import AIC
from testsuite.Paris.RRM.ET.resources_KRK.krk3_common.Python.utilities import (
    logger_console,
    logger_warning,
    get_newest_file_in_vm_directory,
    logged_sleep
)
from taf.internal.gnb.oam.coam.cu.client.asm.v1.exceptions import ApiException
from taf.selenium.gnb.oam.coam.cu import cu as cu_selenium
from taf.gnb.oam.coam.cu.exception import AuthenticationFailed
from taf.gnb.oam.coam.cu import cu
from contextlib import contextmanager
import urllib3
import time
import json
from robot.libraries.BuiltIn import BuiltIn

ConnectionError = (OSError, urllib3.exceptions.NewConnectionError, urllib3.exceptions.ProtocolError,
                   urllib3.exceptions.MaxRetryError, AuthenticationFailed)


def read_delta_json_file(file_path):
    """
    Reads delta json file

    :param file_path: path to the file
    :return: data from json file
    """
    with open(file_path) as f:
        return json.load(f)


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

    @contextmanager
    def vcu_session(self, **kwargs):
        """
        Creates vCU session

        """
        while True:
            try:
                connection = cu()
                connection.connect_to(**self._connection_args(**kwargs), secure=True)
                break
            except ConnectionError:
                logged_sleep('Wait for connection', 60)
        try:
            yield connection
        finally:
            connection.disconnect()

    def handle_vcu_admin(self, func):
        """
        Handle vCU admin

        :param func: func
        """

        @wraps(func)
        def wraper(**kwargs):
            while True:
                try:
                    with self.vcu_session(**self._connection_args()) as connection:
                        result = func(connection=connection, **kwargs)
                        break
                except ConnectionError as error:
                    logged_sleep('Wait for connection', 60)
            return result

        return wraper

    def _connection_args(self, **kwargs):
        """
        Connection args
        """
        vcu_host = '192.168.100.129'
        username = 'Nemuadmin'
        password = BuiltIn().get_variable_value("${WEBEM_PASSWORD}", "Nokia@123")
        cu_version = 'cuoam_21b'
        port = 443

        return {"host": vcu_host,
                "username": username,
                "password": password,
                "port": port,
                "cu_version": cu_version}

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

    def generate_delta_plan(self, connection):
        """
        Generates delta plan

        :param connection: connection to vCU
        """
        generate_fun = connection.generate_delta_plan
        delete_fun = connection.delete_delta_plan
        info_list_fun = connection.get_delta_plan_list
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
        for distname in delta:
            dist_name = distname['distName'].split('/')
            if distname['operation'] == 'delete':
                self._delete_mo_object(distname, connection)
                continue
            if distname['operation'] == 'add':
                self._add_mo_object(distname, connection)
            mo_uuid = self._get_mo_uuid_of_an_existing_object(dist_name[-1], connection)
            self.update_parameters(distname['parameters'], mo_uuid, connection)

    def perform_vcu_parameter_commissioning(self, parameter, value, dist_name):
        """
        Keyword used to send parameter commissioning.
        :param parameter: Parameter name ie. "ipAddrPrim"
        :param value: Parameter value ie. "10.0.1.99" or [{"eea1":0, "eea0":1, "eea3":8, "eea2":0}]
        :param dist_name: Object dist name ie. "MRBTS-1/LNBTS-1/LNMME-0"
        :return:
        """
        with self.vcu_session() as connection:
            self.generate_delta_plan(connection)
            logger_console("Update parameter on vCU")
            dist_name = dist_name.split('/')
            mo_uuid = self._get_mo_uuid_of_an_existing_object(dist_name[-1], connection)
            self.update_parameters(
                [{'parameter_path': '/{}'.format(parameter), 'value': value, 'operation_type': 'replace'}],
                mo_uuid,
                connection
            )
            logged_sleep("Waiting between uploading and validating vcu commissioning", 10)
            validate = connection.validate_delta_plan(plan_id='dp_00000000', connection='default')
            activate = connection.activate_delta_plan(plan_id='dp_00000000', connection='default')
        self.wait_for_vcu_parameters_activation(activate, 'parameter_path: {}, value: {}, operation_type: replace'
                                                .format(parameter, value, ))

    def update_and_activate_delta_plan(self, delta_plan_path):
        """
        Updates and activates delta plan

        :param delta_plan_path: path to delta plan
        :return: nothing
        """
        with self.vcu_session() as connection:
            self.generate_delta_plan(connection)
            logger_console("Sending delta to vCU")
            self.upload_delta(delta_plan_path, connection)
            logged_sleep("Waiting between uploading and validating delta", 10)
            validate = connection.validate_delta_plan(plan_id='dp_00000000', connection='default')
            activate = connection.activate_delta_plan(plan_id='dp_00000000', connection='default')
        self.wait_for_vcu_parameters_activation(activate, delta_plan_path)

    def wait_for_vcu_parameters_activation(self, activate, delta_plan):
        repeat = 0
        while repeat < 5:
            repeat += 1
            try:
                with self.vcu_session() as connection:
                    status = connection.get_operation_state_of_activating_delta_plan(
                        plan_id='dp_00000000', operation_id=activate['operation_id'], connection='default')
                if status['status'] == 'success':
                    logger_console("vCU delta activation status: {}".format(status['status']))
                    break
                assert status['status'] != 'failure', "vCU delta activation status: {}".format(status)
            except ApiException as err:
                if "Service unavailable" in str(err):
                    logged_sleep("vCU rebooting", 180)
                    continue
                raise
            except AssertionError as err:
                if 'No content in this plan' in status['error_message']:
                    logger_warning('No changes in delta plan {}, moving forward'.format(delta_plan))
                    break
                raise
            logged_sleep("vcU delta activation status: {}".format(status['status']), 15)

    def get_plan_file(self, file_path):
        """Download vCU plan file (scf)."""
        with self.vcu_session() as connection:
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
        with self.vcu_session() as connection:
            return connection.get_active_software_version()

    def assert_vcu_status(self, status='enabled'):
        """
        Assert vCU is in proper state. VCU has no 'OnAir' state - 'Enabled' is expected.

        :status: (str) expected state
        :return: (bool) vCU in expected state
        """
        with self.vcu_session() as connection:
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
        with self.vcu_session() as connection:
            output = connection.upload_plan_file(path_to_plan_file=file_path)
            try:
                status = connection.get_operation_state_of_uploading_plan(operation_id=output['action_id'])['status']
                assert status == 'success'
            except AssertionError:
                logged_sleep(msg='Waiting for plan upload to succeed...', period=2)
                status = connection.get_operation_state_of_uploading_plan(operation_id=output['action_id'])['status']
                assert status == 'success', 'Failed to upload plan'

            validation_output = connection.plan_validation(plan_id=output['plan_id'])
            max_retries = 5
            while max_retries > 0:
                validation_result = connection.get_operation_state_of_validating_plan(
                    plan_id=output['plan_id'],
                    operation_id=validation_output['action_id']
                )
                if validation_result['status'] != 'ongoing':
                    break
                max_retries -= 1
                logged_sleep('wait for plan validation operation', period=10)
            assert validation_result['status'] == 'success', "vCU validation status: {}".format(
                validation_result['status']
            )
            # using validate function in Vdu for cu plan file result validation due to no this func in taf cu now.
            connection_dict = self._connection_args()
            try:
                self.cu_validate_obj = Vdu()
                self.cu_validate_obj.connect_to(
                    host=connection_dict['host'],
                    port=str(connection_dict['port']),
                    username=connection_dict['username'],
                    password=connection_dict['password'],
                    vdu_version=connection_dict['cu_version'],
                    secure=True,
                    connection_name="cu_validate"
                )

                plan_validation_results = self.cu_validate_obj.get_staged_plan_validation_results(
                    plan_id=output['plan_id'],
                    validation_id=validation_result['validation_id'],
                    vdu_connection="cu_validate"
                )
            finally:
                self.cu_validate_obj.disconnect(vdu_connection="cu_validate")

            for validation_res_element in plan_validation_results.values():
                if isinstance(validation_res_element, list):
                    assert len(validation_res_element) == 0, "Parameters validation error: {}".format(
                        validation_res_element
                    )

            activate = connection.plan_activation(plan_id=output['plan_id'])
        repeat = 10
        while repeat > 0:
            repeat -= 1
            try:
                with self.vcu_session() as connection:
                    status = connection.get_operation_state_of_activating_plan(
                        plan_id='dp_00000000', operation_id=activate['id'], connection='default')
                if status['status'] == 'success':
                    break
                assert status['status'] != 'failure', "vCU activation status: {}".format(status)
            except ApiException as err:
                if "Service unavailable" in str(err):
                    logged_sleep("vCU rebooting", 180)
                    continue
                raise
            except AssertionError as err:
                continue
            logged_sleep("vCU activation status: {}".format(status['status']), 15)

    def get_meas_period_from_vcu(self, mrbts_id='1900'):
        """
        Get measurement period from vCU

        :param mrbts_id: mrbts id (str)
        :return: meas period
        """
        with self.vcu_session() as connection:
            params = connection.get_parameters(dist_name='MRBTS-{}/MNL-1/MNLENT-1/PMCADM-1'.format(mrbts_id))
            meas_period = params['parameters'][0]['simple_parameter'].value
            if meas_period != '5min':
                logger_warning('Measurement period is not equal to 5min! Check vCU plan!')
            return meas_period

    def reboot_cu(self):
        with self.vcu_session() as connection:
            connection.reset_cu()

    def collect_vcu_snapshot(self, local_path):
        with self.vcu_session() as connection:
            connection.get_local_snapshot(directory=local_path)
        file = get_newest_file_in_vm_directory(local_path)
        file_split = file.split('/')
        file_split[-1] = 'Snapshot_vCU_' + file_split[-1].split('_')[-1]
        new_file = '/'.join(file_split)
        os.rename(file, new_file)

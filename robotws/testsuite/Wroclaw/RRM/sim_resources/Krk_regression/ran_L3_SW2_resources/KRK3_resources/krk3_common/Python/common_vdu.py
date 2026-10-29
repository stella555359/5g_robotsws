"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska
:maintainer:  Mateusz Michalik
:contact: mateusz.michalik@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
:description:
:justification:
"""
from taf.internal.gnb.oam.coam.vdu.client.asm.v1.exceptions import ApiException as duException
from testsuite.Krakow.RRM.RAN_L3_SW2.KRK3.resources.krk3_common.Python.common_AIC import AIC, AICCommonException
from testsuite.Krakow.RRM.RAN_L3_SW2.KRK3.resources.krk3_common.Python.utilities import (
    logger_console,
    logger_warning,
    get_newest_file_in_vm_directory,
    logged_sleep
)
from taf.internal.gnb.oam.coam.vdu.client.asm.v1.exceptions import ApiException
# from testsuite.Krakow.RRM.RAN_L3_SW2.KRK3.resources.krk3_common.Python.mcshark_management import prepare_mcshark_env
from taf.gnb.oam.coam.vdu.exceptions import AuthenticationFailed
# from utilities import wait_until_host_unavailable
from contextlib import contextmanager
from taf.gnb.oam.coam.vdu import Vdu
from functools import wraps
import urllib3
import time
import os
import re
from robot.libraries.BuiltIn import BuiltIn


ConnectionError = (OSError, urllib3.exceptions.NewConnectionError, urllib3.exceptions.ProtocolError,
                   urllib3.exceptions.MaxRetryError, AuthenticationFailed)


JSON_PATH = '/home/ute/robotws/testsuite/Krakow/RRM/MN_RAN_L2/CB008608/' \
            'CB008608-TEMPLATE/resources/commissioning/delta.json'
test_dict = {
            'btsName': 'test_auto'
         }


def update_fun(plan_id, mo_dn, updated_paras_dict, vdu_connection):
    print('******************')
    # print(plan_id, mo_dn, updated_paras_dict, vdu_connection)


class vDU(AIC):
    """
    vDU class
    """

    @contextmanager
    def vdu_session(self, **kwargs):
        """
        Creates vDU session
        """
        while True:
            try:
                connection = Vdu()
                connection.connect_to(**self._connection_args(**kwargs), secure=True)
                break
            except ConnectionError:
                logged_sleep('Wait for connection', 60)
        try:
            yield connection
        finally:
            connection.disconnect()

    def handle_vdu_admin(self, func):
        """
        Handle vDU admin

        :param func: func
        """
        @wraps(func)
        def wrapper(**kwargs):
            while True:
                try:
                    with self.vdu_session(**self._connection_args()) as connection:
                        result = func(connection=connection, **kwargs)
                        break
                except ConnectionError as error:
                    logged_sleep('Wait for connection', 60)
            return result
        return wrapper

    def _connection_args(self, **kwargs):
        """
        Connection args
        """
        vdu_host = '192.168.255.129'  # BuiltIn().get_variable_value("${GNB_IP}")
        username = 'Nemuadmin'  # BuiltIn().get_variable_value("${WEBEM_USERNAME}")
        password = BuiltIn().get_variable_value("${WEBEM_PASSWORD}", "Nokia@123")
        vdu_version = 'cuoam_21b'
        port = 443

        return {"host": vdu_host,
                "username": username,
                "password": password,
                "port": port,
                "vdu_version": vdu_version}

    def generate_delta_plan(self, connection):
        """
        Generates delta plan

        :param connection: connection to vDU
        """
        generate_fun = connection.generate_delta_plan
        delete_fun = connection.delete_delta_plan_file
        info_list_fun = connection.get_delta_plan_info_list
        super().generate_delta_plan(generate_fun, delete_fun, info_list_fun)

    def perform_vdu_parameter_commissioning(self, parameter, value, dist_name):
        """
        Keyword used to send parameter commissioning.
        :param parameter: Parameter name ie. "ipAddrPrim"
        :param value: Parameter value ie. "10.0.1.99" or [{"eea1":0, "eea0":1, "eea3":8, "eea2":0}]
        :param dist_name: Object dist name ie. "MRBTS-1/LNBTS-1/LNMME-0"
        :return:
        """
        with self.vdu_session() as connection:
            self.generate_delta_plan(connection)
            logger_console("Update parameter on vDU")
            update = connection.update_vdu_parameter_of_delta_plan(
                plan_id='dp_00000000',
                mo_dn=dist_name,
                updated_paras_dict={parameter: value},
                operation='replace'
            )
            time.sleep(1)
            update = connection.get_update_paras_action_status_of_delta_plan(
                plan_id='dp_00000000',
                action_id=update['action_id']
            )
            update = connection.get_update_paras_action_status_of_delta_plan(
                plan_id='dp_00000000',
                action_id=update['action_id']
            )
            if update['status'] == 'ongoing':
                time.sleep(5)
                update = connection.get_update_paras_action_status_of_delta_plan(
                    plan_id='dp_00000000',
                    action_id=update['action_id']
                )
            assert update['status'] == 'success', "FAILED TO UPDATE {}: {}\n{}".format(dist_name,
                                                                                       parameter, update)
            logged_sleep("Waiting between uploading and validating vdu commissioning", 10)
            validate = connection.validate_delta_plan(delta_plan_id='dp_00000000')
            activate = connection.activate_delta_plan(delta_plan_id='dp_00000000')
        self.wait_for_vdu_parameters_activation(activate)

    def upload_and_activate_delta_file(self, delta_file=''):
        """
        Uploads and activates delta plan

        :param delta_file: delta file
        :return: nothing
        """
        with self.vdu_session() as connection:
            self.generate_delta_plan(connection)
            logger_console("Sending delta to vDU")
            super().upload_params(delta_file, connection.update_vdu_parameter_of_delta_plan,
                                  connection.create_vdu_object_of_delta_plan,
                                  connection.get_update_paras_action_status_of_delta_plan)
            logged_sleep("Waiting between uploading and validating delta", 10)
            validate = connection.validate_delta_plan(delta_plan_id='dp_00000000')
            activate = connection.activate_delta_plan(delta_plan_id='dp_00000000')
        self.wait_for_vdu_parameters_activation(activate)

    def wait_for_vdu_parameters_activation(self, activate):
        repeat = 0
        while repeat < 5:
            repeat += 1
            try:
                with self.vdu_session() as connection:
                    status = connection.get_activate_delta_plan_operation_status(delta_plan_id='dp_00000000',
                                                                                 operation_id=activate['id'])
                    if status['status'] == 'success':
                        logger_console("vDU delta activation status: {}".format(status['status']))
                        break
                    assert status['status'] != 'failure', "vDU delta activation status: {}".format(status)
            except duException as err:
                if "Service unavailable" in str(err):
                    logged_sleep("vDU rebooting", 60)
                    continue
                raise duException(str(err))
            logged_sleep("vDU delta activation status: {}".format(status['status']), 15)

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
        with self.vdu_session() as connection:
            connection.get_current_plan_file(local_dir_path=file_dir, filename=file_name,  include_runtime_data=False)

    def commission_vdu(self, file_path):
        """
        Commission vDU

        :param file_path: (str) path to commissioning file
        :return: nothing
        """
        logger_console("Commissioning vDU with: {}".format(file_path.split('/')[-1]))
        with self.vdu_session() as connection:
            output = connection.upload_plan(path_to_plan_file=file_path)
            try:
                status = connection.get_upload_plan_operation_status(operation_id=output['action_id'])['status']
                assert status == 'success'
            except AssertionError:
                logged_sleep(msg='Waiting for plan upload to succeed...', period=2)
                status = connection.get_upload_plan_operation_status(operation_id=output['action_id'])['status']
                assert status == 'success', 'Failed to upload plan: {}'.format(status)

            validation_output = connection.validate_plan(plan_id=output['plan_id'])
            max_retries = 5
            while max_retries > 0:
                validation_result = connection.get_validate_plan_operation_status(
                    plan_id=output['plan_id'],
                    operation_id=validation_output['action_id']
                )
                if validation_result['status'] != 'ongoing':
                    break
                max_retries -= 1
                logged_sleep('wait for plan validation operation', period=10)
            assert validation_result['status'] == 'success', "vDU validation status: {}".format(
                validation_result['status']
            )

            plan_validation_results = connection.get_staged_plan_validation_results(
                plan_id=output['plan_id'],
                validation_id=validation_result['validation_id']
            )

            for validation_res_element in plan_validation_results.values():
                if isinstance(validation_res_element, list):
                    assert len(validation_res_element) == 0, "Parameters validation error: {}".format(
                        validation_res_element
                    )

            activate = connection.activate_plan(plan_id=output['plan_id'])
        repeat = 10
        while repeat > 0:
            repeat -= 1
            try:
                with self.vdu_session() as connection:
                    status = connection.get_activate_plan_operation_status(
                        plan_id='dp_00000000', operation_id=activate['id'], vdu_connection='default')
                if status['status'] == 'success':
                    break
                assert status['status'] != 'failure', "vDU activation status: {}".format(status)
            except ApiException as err:
                if "Service unavailable" in str(err):
                    logged_sleep("vDU rebooting", 180)
                    continue
                raise
            except AssertionError as err:
                continue
            logged_sleep("vDU activation status: {}".format(status['status']), 15)

    def get_meas_period_from_vdu(self, mrbts_id='1900'):
        """
        Get measurement period from vDU

        :param mrbts_id: mrbts id (str)
        :return: meas period
        """
        with self.vdu_session() as connection:
            meas_period = connection.search_parameter_of_current_plan(
                mo_dn='MRBTS-{}/MNL-1/MNLENT-1/PMCADM-1'.format(mrbts_id),
                para_name='reportingIntervalPm')
            if meas_period != '5min':
                logger_warning('Measurement period is not equal to 5min! Check vDU plan!')
            return meas_period

    def reboot_vdu(self, **kwargs):
        """
        Reboots vDU
        """
        connection = Vdu().connect_to(**self._connection_args(**kwargs), secure=True)
        reset = connection.reset_vdu()
        logged_sleep('Wait for reboot', 5)

    def wait_for_rute_to_vdu(self, **kwargs):
        """
        Waits fdo rute to vDU after reboot
        """
        while True:
            try:
                connection = Vdu().connect_to(**self._connection_args(**kwargs), secure=True)
                break
            except ConnectionError as con_err:
                logged_sleep('Wait for connection', 60)

    def check_radio_status(self, expected_status):
        """
        Checks radio status

        :param expected_status: expected status of radio
        """
        # self._check_if_rute_to_vdu()
        with self.vdu_session() as connection:
            rmods_status = connection.get_rmods_status(vdu_connection='default')
            for cell_id, cell_info in enumerate(rmods_status):
                print(rmods_status)
                if expected_status not in cell_info['availability_status']:
                    raise duException(
                        "Cell nr {} RMODs status is '{}' instead '{}'".format(cell_id+1,
                                                                              cell_info['availability_status'],
                                                                              expected_status))

    def wait_until_radio_units_are_in_state(self, expected_status, retry=12, sleep_interval=60):
        """
        Waits until radio units are in expected state

        :param expected_status: expected status of radio
        :param retry: (int) number of retries
        :param sleep_interval: (int) sleep interval
        """
        tries = retry
        while retry > 0:
            retry -= 1
            try:
                self.check_radio_status(expected_status)
            except duException as du_error:
                if any(err in str(du_error) for err in ['UM service is not available', 'Service unavailable']):
                    logged_sleep('Wait for vDU to be available', sleep_interval)
                    retry += 1
                elif 'RMODs status is' not in str(du_error):
                    raise
            else:
                break
            logged_sleep('Wait for RMODs to be in a state: {}'.format(expected_status), sleep_interval)
        if retry is 0:
            raise duException('State {} not achieved after {} tries'.format(expected_status, tries))

    def wait_until_radio_units_are_online(self):
        """
        Wait until radio units are online
        """
        self.wait_until_radio_units_are_in_state(expected_status='on line')

    def get_du_version(self):
        with self.vdu_session() as connection:
            return connection.get_vdu_state_data()['software_version']

    def collect_vdu_snapshot(self, local_path):
        with self.vdu_session() as connection:
            connection.get_local_snapshot(directory=local_path, compressed_or_not=True)
        file = get_newest_file_in_vm_directory(local_path)
        file_split = file.split('/')
        file_split[-1] = 'Snapshot_vDU_' + file_split[-1].split('_')[-1]
        new_file = '/'.join(file_split)
        os.rename(file, new_file)

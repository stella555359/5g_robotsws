# -*- coding: utf-8 -*-
"""
Generic keywords for CU.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""

import logging
import time
import os
import itertools
import re
import json
from datetime import datetime, timedelta
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from functools import wraps
from taf.gnb.oam.coam.cu import cu as cuadmin
from taf.gnb.oam.coam.cu.exception import AuthenticationFailed
from taf.internal.robot_typecasts import time_to_seconds
from taf.selenium.gnb.oam.coam.cu import cu as cuadmingui
from taf.internal.gnb.oam.coam.cu.client.asm.v1.exceptions \
    import ApiException
from taf.selenium.gnb.oam.coam.cu import cu as selenium_cu
from selenium.common.exceptions \
    import ElementClickInterceptedException

from testsuite.Bangalore.ORAN.resources.python.Macro.Python.exceptions \
    import UnexpectedWebemBehavior, WrongApiException, InvalidParameterValue, \
    AlarmIsActive, AlarmIsNotActive, F1LinkUnavailable, \
    InvalidStatuses, \
    CuNotAvailable, AverageStartupTargetNotMet, StartUpTargetNotMet, \
    NotAllCellsDisabled, NotAllCellsEnabled, \
    LockUnlockTargetNotMet, ValidationError
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.generic_bts import _get_bts_id_arg_name, _convert_id_to_int
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    utilities import get_builtin_value, load_moler_configuration_from_tl,\
    get_log_path
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    helpers import tl_config
from testsuite.Bangalore.ORAN.resources.python.Macro.Python \
    import connection_names
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    transfer_files import download_files

import requests
from urllib3.exceptions import InsecureRequestWarning,\
    ProtocolError


def login_logout(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        bts_id_arg_name = _get_bts_id_arg_name(web_fun)
        bts_id, args, kwargs = _convert_id_to_int(
            bts_id_arg_name, args, kwargs, web_fun)
        requests.packages.urllib3.disable_warnings(
            category=InsecureRequestWarning)

        self.connect(bts_id=bts_id)
        try:
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            self.disconnect(bts_id=bts_id)

    return wrapper


def login_logout_GUI(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        bts_id_arg_name = _get_bts_id_arg_name(web_fun)
        bts_id, args, kwargs = _convert_id_to_int(
            bts_id_arg_name, args, kwargs, web_fun)

        if self.gui_coam_cu is None:
            self.login_gui(bts_id=bts_id)
        elif self._gui_coam_cu_connection_name == \
                connection_names.gui_gnb_cu.format(bts_id):
            try:
                result = web_fun(self, *args, **kwargs)
                return result
            except Exception as ex:
                logging.warning("Cannot call method {}. Caught "
                                "exception: {}".format(web_fun.__name__,
                                                       repr(ex)))
                logging.warning("Try to login again")
                self._login_gui(bts_id=bts_id)
        else:
            self.logout_gui()
            self.login_gui(bts_id=bts_id)

        return web_fun(self, *args, **kwargs)

    return wrapper


class GenericCu(object):
    """CU(Centralized Unit) keywords for gNB"""

    cu = cuadmin()
    gui_coam_cu = cuadmingui()

    def __init__(self, bts_type='GNB'):
        """
        Constructor of GenericBts class.

        :param bts_type: GNB|ENB
        """

        self.bts_type = bts_type

        self.gui_coam_cu = None
        self._gui_coam_cu_connection_name = None

    def connect(self, bts_id=0):
        """
        Connect to gNB CU

        :return: None
        """
        logging.debug("[CU] Connecting "
                      "to {}".format(connection_names.rest_gnb_cu.
                                     format(bts_id)))
        credentials = tl_config.get_web_credentials_for_cu(bts_id,
                                                           self.bts_type)
        self.cu.connect_to(host=credentials['ip'],
                           port='',
                           username=credentials['username'],
                           password=credentials['password'],
                           cu_version="cuoam_19b",
                           secure=True
                           )

    def disconnect(self, bts_id=0):
        """
        Disconnect from gNB CU

        :return: None
        """
        logging.debug("[CU] Disconnecting "
                      "from {}".format(connection_names.rest_gnb_cu.
                                       format(bts_id)))
        self.cu.disconnect()

    def login_gui(self, bts_id=0):
        """
        Login to BTS via GUI

        :return: None
        """
        selenium_logs = os.path.join(get_builtin_value("OUTPUTDIR"),
                                     'selenium_logs')
        self.gui_coam_cu = selenium_cu()

        self._gui_coam_cu_connection_name = \
            connection_names.gui_gnb_cu.format(bts_id)

        self.gui_coam_cu.enable_virtual_display()

        self.gui_coam_cu.download_dir = os.path.join(selenium_logs,
                                                     'download')
        self._login_gui(bts_id=bts_id)

    def _login_gui(self, bts_id=0):
        credentials = tl_config.get_web_credentials_for_cu(
            bts_id, self.bts_type)

        self.gui_coam_cu.enable_virtual_display()
        self.gui_coam_cu.login(url='https://{}/'.format(credentials['ip']),
                               username=credentials['username'],
                               password=credentials['password'],
                               browser='Chrome',
                               version=self._get_proper_coam_selenium_version(
                                   bts_id=bts_id))

    @login_logout
    def _get_proper_coam_selenium_version(self, bts_id=0):
        version = None
        release_number = None
        supported_versions = ["21B"]
        current_trunk_releases = ['22R1']
        try:
            cu_software = self.cu.get_active_software_version()
        except ApiException:
            MolerTest.info("Cannot get active software version")
            return current_trunk_releases[-1]
        if cu_software:
            logging.debug("[CU] Software version: {}".format(cu_software))
            # 5G20B_10.1100.1322, 5G22R1_0.200.1452
            match = re.search(r'5G(\d+(?:([A-C])|(R\d+)))_', cu_software)
            if match:
                release_number = match.group(1)
                logging.debug("[CU] Release number: {}".format(release_number))
            if release_number:
                if release_number in supported_versions:
                    version = release_number
                elif release_number in current_trunk_releases:
                    version = supported_versions[-1]

        logging.debug("Selected selenium version: {}".format(version))
        return version

    def logout_gui(self):
        """
        Logout from BTS via GUI

        :return: None
        """
        for x in range(5):
            try:
                self.gui_coam_cu.logout()
                break
            except ElementClickInterceptedException:
                time.sleep(5)
        self.gui_coam_cu.disable_virtual_display()
        self.gui_coam_cu = None

    def _validate_configuration_file(self, plan_id):
        """
        Validate configuration file and wait for completion

        :param plan_id: ID of plan to validate
        :return: None
        """
        plan_status = self.cu.plan_validation(plan_id)
        action_id = plan_status["action_id"]
        validation_status = \
            self.cu.get_operation_state_of_validating_plan(
                plan_id, action_id)['status']
        logging.debug("Plan validation status: {}".format(validation_status))
        validation_ongoing = True
        while validation_ongoing:
            time.sleep(2)
            validation_status = \
                self.cu.get_operation_state_of_validating_plan(
                    plan_id, action_id)['status']
            logging.debug("Plan validation status: {}".format(
                validation_status))
            if validation_status == "success":
                validation_ongoing = False
        if validation_status == "success":
            logging.debug("Plan: {} validated".format(plan_id))
        else:
            raise WrongApiException("Plan validation failed")

    def _activate_configuration_file(self, plan_id):
        """
        Activate configuration file and wait for completion

        :param plan_id: iD of plan for activation
        :param except_ongoing_operation: set to True if you want to except
         test failure due to ongoing operations
        :return:
        """
        activation_status = self.cu.plan_activation(plan_id)
        logging.debug("Plan activation status: {}".format(activation_status))
        action_id = activation_status["id"]
        activation_ongoing = True
        while activation_ongoing:
            time.sleep(100)
            activation_status = \
                self.cu.get_operation_state_of_activating_plan(plan_id,
                                                               action_id)
            logging.info('Activation status:'
                         ' {}'.format(activation_status['status']))
            if activation_status['status'] != 'ongoing':
                activation_ongoing = False
        if activation_status['status'] == "success":
            logging.debug("Plan: {} activated".format(plan_id))
        else:
            raise WrongApiException(
                "Activation status {}\nError message:{}".
                format(activation_status['status'],
                       activation_status['error_message']))

    @login_logout
    def verify_cu_state_is_operational(self, bts_id=0):
        """
        Checking if cu is online.
        :return: None
        """
        cu_state = self.cu.get_cu_state()
        logging.info("cu state: {}".format(cu_state))
        if cu_state['operational_state'].lower() != "enabled":
            raise InvalidParameterValue("cu operational state is not enabled")
        logging.info("cu is OnAir")

    def _validate_delta_plan(self, delta_plan_id, action_id):
        """
        Validate delta plan and wait for completion

        :param delta_plan_id: ID of delta plan
        :param action_id: ID of validate operation
        :return: None
        """
        validation_ongoing = True
        while validation_ongoing:
            validation_state = \
                self.cu.get_action_state_of_validating_delta_plan(
                    delta_plan_id, action_id)
            logging.info("Validation of delta plan {}".format(
                validation_state))
            validation_status = validation_state['status']
            if validation_status != "ongoing":
                validation_ongoing = False
                if validation_status == "success":
                    logging.info("Validation of delta plan finished with "
                                 "success")
                else:
                    raise ValidationError(
                        "Validation of delta plan failed. "
                        "Error message: {0}".
                        format(validation_state['error_message']),
                        errors=validation_state['error_message'])

    def _activate_delta_plan(self, delta_plan_id, activation_id):
        """
        Activate delta plan and wait for completion

        :param delta_plan_id: ID of delta plan
        :param activation_id: ID of activate operation
        :return: None
        """
        activation_delta_plan_ongoing = True
        while activation_delta_plan_ongoing:
            activation_state = \
                self.cu.get_operation_state_of_activating_delta_plan(
                    delta_plan_id, activation_id)
            activation_delta_plan_status = activation_state['status']
            time.sleep(10)
            logging.info(
                "Activation of delta plan {}".format(
                    activation_delta_plan_status))

            if activation_delta_plan_status != "ongoing":
                activation_delta_plan_ongoing = False
                if activation_delta_plan_status == "success":
                    logging.info("Activation of delta plan finished "
                                 "with success")
                else:
                    raise WrongApiException(
                        "Activation of delta plan failed. Error"
                        " message: {0}".
                        format(activation_state['error_message']))

    def _generate_delta_plan(self, generate_status):
        """
        Generate delta plan and wait for completion

        :param generate_status: status of generation (ongoing,
         success, failure)
        :return: None
        """
        generation_status = self.cu.get_action_state_of_generating_delta_plan(
            generate_status['action_id'])
        logging.info('Generation plan: {}'.format(generation_status))

        while generation_status['status'] != 'success':
            generation_status = \
                self.cu.get_action_state_of_generating_delta_plan(
                    generate_status['action_id'])
            logging.info('Generation plan: {}'.format(generation_status))
            if generate_status['status'] == 'failure':
                logging.info('Generating status {}'.format(generation_status))

    def _upload_configuration_file(self, scf_path):
        """
        Upload configuration file located in the provided SCF path.

        :param scf_path: Path to SCF file.
        :return: plan_id: ID of the uploaded file.
        """
        plan_status = self.cu.upload_plan_file(scf_path)
        plan_id = plan_status["plan_id"]
        action_id = plan_status["action_id"]
        upload_ongoing = True
        while upload_ongoing:
            time.sleep(2)
            upload_status = self.cu.get_operation_state_of_uploading_plan(
                operation_id=action_id)['status']
            logging.info('Uploading status: {}'.format(upload_status))
            if upload_status != 'ongoing':
                upload_ongoing = False
        logging.debug("Uploaded plan: {} with"
                      " ID: {}".format(scf_path, plan_id))
        return plan_id

    def _get_mo_uuid_from_delta_plan(
            self, param_name, delta_plan_id, bts_id=0):
        """
        Get managed object id from delta plan

        :param param_name: parameter name
        :param delta_plan_id: id of delta plan
        :return: managed object id
        """
        param_name = param_name.split('/')[-1]
        try:
            mo = self.cu.search_parameters_of_delta_plan(
                delta_plan_id, param_name)['items'][0]
            logging.debug("Managed object: {}".format(mo))
            return mo['mo_uuid']
        except IndexError:
            raise LookupError("No managed object for given name")

    @login_logout
    def update_one_or_more_parameters_of_delta_plan(
            self, modify_randomly=False, bts_id=0, **parameters_with_values):
        """
        Update selected parameters of delta plan.

        :param modify_randomly: set to True if you want to modify the
        string parameter randomly
        :param parameters_with_values: names and values of parameters,
        which are going to be changed in SCF.
        syntax: param1=value1, param2=value2...
        :return: None
        """
        generate_status = self.cu.generate_delta_plan("plan_1")
        self._generate_delta_plan(generate_status)

        for param_name, param_value in parameters_with_values.items():
            logging.info("Setting {} = {}".format(param_name, param_value))
            prev_value = \
                self.cu.search_parameters_of_current_plan(
                    param_name)['items'][0]['parameter']['simple_parameter']['value']
            if modify_randomly:
                param_value = prev_value + '_0'
            self._update_parameters_of_delta_plan(param_name, param_value,
                                                  generate_status)

    def _update_parameters_of_delta_plan(self, param_name, param_value,
                                         generate_status):
        """
        Update chosen parameter of delta plan to a chosen value

        :param param_name: name of parameter to change
        :param param_value: new value of parameter to change
        :param generate_status: status of generation
        :return: None
        """
        mo_uuid = self._get_mo_uuid_from_delta_plan(param_name,
                                                    generate_status['plan_id'])
        updating_status = self.cu.update_parameters_of_delta_plan(
            generate_status['plan_id'], mo_uuid,
            [{"operation_type": "replace",
              "parameter_path": '/{}'.format(param_name),
              "value": param_value}])
        updated_status = \
            self.cu.get_action_state_of_updating_parameters_of_delta_plan(
                plan_id=generate_status['plan_id'],
                action_id=updating_status['action_id'])
        logging.info('Updating parameter value: {} '
                     'with status: {}'.format(param_value, updated_status))

        while updated_status['status'] != 'success':
            updated_status = \
                self.cu.get_action_state_of_updating_parameters_of_delta_plan(
                    plan_id=generate_status['plan_id'],
                    action_id=updating_status['action_id'])
            logging.info('Updating parameter: {}'.format(
                updated_status))
            if updated_status['status'] == 'failure':
                raise WrongApiException(
                    'Updating status {}'.format(updated_status))

    @login_logout
    def activate_cu_configuration(self, file_path,
                                  except_ongoing_operation=False,
                                  bts_id=0):
        """
        Perform gNB CU commissioning without plan validation.
        Use SCF which is not uploaded to CU.

        :param file_path: path to configuration file
        :param except_ongoing_operation: set to True if you want to
        except test failure due to ongoing operation
        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        plan_id = self._upload_configuration_file(file_path)
        if not except_ongoing_operation:
            self._activate_configuration_file(plan_id)
        else:
            try:
                self.cu.plan_activation(plan_id)
            except ApiException as err:
                if ApiException(status=409):
                    logging.info("Plan activation failed. "
                                 "HTTP error is raised, just as"
                                 " expected: {}".format(err))
                else:
                    raise WrongApiException("Expected HTTP Status:"
                                            " 409, but received: "
                                            "{}".format(err))

    @login_logout
    def activate_planned_cu_configuration(self, plan_id, bts_id=0):
        """
        Perform gNB CU commissioning without plan validation. Use one
         of SCFs already uploaded to CU.

        :param plan_id: ID of one of the plans already uploaded to CU,
        which is going to be activated
        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        self._activate_configuration_file(plan_id)

    @login_logout
    def delete_planned_cu_configurations(self, bts_id=0):
        """
        Delete current CU's commissioning file

        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        plan_ids = self.cu.get_plan_info()
        for plan in plan_ids:
            self.cu.plan_delete(plan["plan_id"])

    @login_logout
    def get_active_cu_configuration(self, file_path, bts_id=0):
        """
        Download current CU's commissioning file

        :param file_path: path to saved plan file
        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        self.cu.get_current_plan_file(file_path, timeout=100)
        logging.debug("Saved active plan to dir: {}".format(file_path))

    @login_logout
    def get_planned_cu_configuration(self, file_path, plan_id, bts_id=0):
        """
        Download one of the SCFs already uploaded to CU

        :param file_path: path to saved plan file
        :param plan_id: ID of one of available CU's plans, which is
        going to be saved
        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        self.cu.get_plan_file(plan_id, file_path)
        logging.debug("Saved plan with ID: {} to dir: {}".format(
            plan_id, file_path))

    @login_logout
    def get_latest_plan_id(self, bts_id=0):
        """
        Get ID of the plan, that was recently uploaded, and still
        not activated to CU.

        :param bts_id: BTS id - related to Test Line configuration
        :return: plan_id - id of latest plan
        """
        plan_id = self.cu.get_plan_info()[-1]["plan_id"]
        logging.debug("The latest plan uploaded to CU has ID: {}".
                      format(plan_id))
        return plan_id

    @login_logout
    def perform_cu_commissioning(self, file_path,
                                 except_ongoing_operation=False,
                                 bts_id=0):
        """
        Perform full gNB CU commissioning

        :param file_path: path to the CU's commissioning file in XML format
        :param except_ongoing_operation: set to True if you want to
        except test failure due to ongoing operation
        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        plan_id = self._upload_configuration_file(file_path)
        self._validate_configuration_file(plan_id)
        if not except_ongoing_operation:
            self._activate_configuration_file(plan_id)
        else:
            try:
                self.cu.plan_activation(plan_id)
            except ApiException as err:
                if ApiException(status=409):
                    logging.info("Plan activation failed. "
                                 "HTTP error is raised, just"
                                 " as expected: {}".format(err))
                else:
                    raise WrongApiException("Expected HTTP Status:"
                                            " 409, but received: {}".
                                            format(err))

    @login_logout
    def validate_maximum_cu_configuration_uploads(self, scf_path, bts_id=0):
        """
        Verify if a configuration plan conforms to the validation
         rules defined by the BTS object model.
        There can be maximum 3 "staged (working copies)" stored in
        CU WebEM backend server.
        If during load operation there are already 3 "staged (
        working copies)" stored, the oldest one is overwritten

        :param scf_path: path to the SCF file
        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        for i in range(4):
            plans_ids = self.cu.get_plan_info()
            logging.debug("Number of plans uploaded to CU: {}".format(
                len(plans_ids)))
            if len(plans_ids) < 3:
                self._upload_configuration_file(scf_path)
            else:
                try:
                    plan_id = self._upload_configuration_file(scf_path)
                    raise UnexpectedWebemBehavior(
                        "Plan with ID: {} was uploaded to CU, "
                        "although maximum number of uploaded "
                        "CU plans is exceeded".format(plan_id))
                except ApiException as err:
                    if ApiException(status=507):
                        logging.info("Maximum number of uploaded"
                                     " CU plans exceeded. "
                                     "HTTP error is "
                                     "raised, just as expected: "
                                     "{}".format(err))
                    else:
                        raise WrongApiException("Expected HTTP Status:"
                                                " 507, but received:"
                                                " {}".format(err))

    @login_logout
    def validate_cu_configuration(self, file_path, bts_id=0):
        """
        Perform plan validation. Use SCF which is not uploaded to CU.

        :param file_path: path to the CU's commissioning file in XML format
        :return: None
        """
        plan_id = self._upload_configuration_file(file_path)
        self._validate_configuration_file(plan_id)

    @login_logout
    def validate_latest_cu_configuration(self, bts_id=0):
        """
        Perform gNB CU's latest commissioning validation.

        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        plan_id = self.cu.get_plan_info()[-1]["plan_id"]
        self._validate_configuration_file(plan_id)

    @login_logout
    def validate_planned_cu_configuration(self, plan_id, bts_id=0):
        """
        Perform validation of one of the SCFs already uploaded to CU.

        :param plan_id: ID of one of available CU's plans, which is
        going to be saved
        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        self._validate_configuration_file(plan_id)

    @login_logout
    def validate_and_activate_delta_plan(self, bts_id=0):
        """
        Validate and activate delta plan with waiting for success.

        :return: None
        """
        delta_plan_id = self.cu.get_delta_plan_list()[0]["plan_id"]
        validate_dict = self.cu.validate_delta_plan(delta_plan_id)
        action_id = validate_dict["action_id"]
        try:
            self._validate_delta_plan(delta_plan_id, action_id)
        except ValidationError as validation_err:
            if validation_err.errors == 'No content in this plan. :' \
                                        ' No content in this plan.':
                logging.warning("No changes in delta plan. "
                                "Skipping Activation")
                return
            else:
                raise

        activate_dict = self.cu.activate_delta_plan(delta_plan_id)
        activation_id = activate_dict['operation_id']
        self._activate_delta_plan(delta_plan_id, activation_id)

    @login_logout
    def generate_delta_plan(self, plan_name, bts_id=0):
        """
        Generate delta plan via admin API.

        :param plan_name: name of plan, which is going to be created
        :return: None
        """
        gen_delta_action_id = self.cu.generate_delta_plan(
            plan_name)['action_id']
        gen_delta_state = self.cu.get_action_state_of_generating_delta_plan(
            gen_delta_action_id)

        if gen_delta_state['action_id'] == 'success':
            logging.debug('{} delta plan created'.format(
                gen_delta_state['plan_id']))
        else:
            logging.debug('{}'.format(gen_delta_state['error_message']))

    @login_logout
    def update_parameter_of_delta_plan(self, param_name,
                                       param_value,
                                       modify_randomly=0,
                                       bts_id=0):
        """
        Update selected parameter of delta plan.
        Fix: ability to update value of parameter under complex
         structure, where path is e.g: cuOvlHa/0/parameter_name
        We have to provide whole path in param_name.

        :param param_name: name of parameter, which is going to be
        changed in SCF. Can also be a path in case of
                           parameter under complex structure,
                           e.g: cuOvlHa/0/parameter_name
        :param param_value: value of parameter, which is going
        to be changed in SCF
        :param modify_randomly: set to 1 if you want to modify
         the string parameter randomly
        :return: None
        """
        generate_status = self.cu.generate_delta_plan("plan_1")
        self._generate_delta_plan(generate_status)
        only_param_name = param_name.split("/")[-1]
        simple_param = \
            self.cu.search_parameters_of_current_plan(
                only_param_name)['items'][0]['parameter']['simple_parameter']
        if modify_randomly == '1' and simple_param is not None:
            prev_value = simple_param['value']
            param_value = prev_value + '_0'
        self._update_parameters_of_delta_plan(param_name, param_value,
                                              generate_status)

    @login_logout
    def start_cu_configuration_activation_procedure(self, file_path, bts_id=0):
        """
        Start gNB CU plan activation. Use SCF which is not uploaded to CU.

        :param file_path: path to the CU's commissioning file in XML format
        :param bts_id: BTS id - related to Test Line configuration
        :return: action_id - ID of started activation procedure
        """
        plan_id = self._upload_configuration_file(file_path)
        activation_status = self.cu.plan_activation(plan_id)
        operation_id = activation_status["id"]
        return plan_id, operation_id

    @login_logout
    def wait_until_plan_activation_is_completed(self, plan_id,
                                                operation_id, bts_id=0):
        """
        Verify status of ongoing gNB CU activation operation.

        :param plan_id: id of pre-active plan
        :param operation_id: id of ongoing operation
        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        operation_ongoing = True
        while operation_ongoing:
            time.sleep(10)
            status = self.cu.get_operation_state_of_activating_plan(
                plan_id, operation_id)['status']
            logging.info('Activation status: {}'.format(status))
            if status != "ongoing":
                operation_ongoing = False
        if status == "success":
            logging.info("Activation finished with success")
        else:
            raise WrongApiException("Activation failed")

    @login_logout
    def switch_boolean_parameter(self, param_name, bts_id=0):
        """
        Update selected boolean parameter of delta plan.

        :param param_name: name of parameter, which is going to be
        changed in SCF
        :return: None
        """
        generate_status = self.cu.generate_delta_plan("plan_1")
        self._generate_delta_plan(generate_status)

        prev_value = \
            self.cu.search_parameters_of_current_plan(param_name)[
                'items'][0]['parameter']['simple_parameter']['value']
        if prev_value == 'false':
            param_value = 'true'
        else:
            param_value = 'false'

        self._update_parameters_of_delta_plan(param_name, param_value,
                                              generate_status)

    @login_logout
    def delete_delta_plan_from_cu(self, bts_id=0):
        """
        Delete actual delta plan with admin API.

        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        try:
            delta_plan_id = self.cu.get_delta_plan_list()[0]["plan_id"]
            self.cu.delete_delta_plan(delta_plan_id)
        except ApiException as err:
            if ApiException(status=404):
                logging.info("Delta plan already deleted")
            else:
                raise WrongApiException("Expected HTTP Status: 404,"
                                        " but received: {}".format(err))
        except IndexError:
            logging.info("Delta plan already deleted")

    @login_logout
    def reset_cu(self, bts_id=0):
        """
        Trigger CU reset operation

        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        status = self.cu.reset_cu()
        logging.debug("Reset CU with status: {}".format(status))

    @login_logout
    def verify_cu_state_is_disabled(self, bts_id=0):
        """
        Verify if CU operational state is disabled

        :param bts_id: BTS id - related to Test Line configuration
        :return: None
        """
        cu_state = self.cu.get_cu_state()
        logging.debug("CU data state{}".format(cu_state))
        if cu_state['operational_state'] != "disabled":
            raise Exception("CU operational state is not disabled")

    @login_logout
    def verify_f1_link_is_available(self, bts_id=0):
        """
        Verify if F1 link status is available

        :param bts_id: BTS id - related to Test Line configuration
        :return: True or False
        """
        dus_summary = self.cu.get_du_state()
        if dus_summary['f1_link_status'].available:
            logging.debug('F1 link is available')
        else:
            raise F1LinkUnavailable('F1 link is unavailable')

    @login_logout_GUI
    def get_cu_configuration_via_GUI(self, bts_id=0, save_type=0,
                                     plan_name=None):
        """
        Download CU configuration file via GUI

        :param save_type: str, type of save
                0: Save as SCF - BTS configuration only
                1: Save as full BTS runtime configuration
                2: Save BTS runtime information only
        :param bts_id:  BTS ID - related to Test Line configuration
        :param plan_name: name of the plan which is going to be downloaded
        """
        if plan_name is not None:
            self.gui_coam_cu.choose_plan(plan_name)
        return self.gui_coam_cu.save_bts_configuration(
            save_configuration_type=save_type)

    @login_logout_GUI
    def get_cu_parameter_value_via_gui(
            self, dist_name, param_name, param_abbr,
            plan_name="CURRENT_PLAN", bts_id=0, du_id=0):
        """
        Get and return the value of specified parameter.
        :param plan_name: Name of the plan to choose.
        :param param_name: parameter name filter to locate target parameter.
        :param dist_name: dist name to locate the parameter. Please
        use MRBTS-{}/NRBTS-{} format.
        :param param_abbr: abbreviation of the parameter.
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return: value of the specified parameter.
        """
        dist_name = self.adjust_dist_name(dist_name, bts_id, du_id)
        logging.info("Dist name:{}".format(dist_name))
        self.gui_coam_cu.choose_plan(plan_name=plan_name)
        current_value = self.gui_coam_cu.get_parameter_value(
            object_name=dist_name, filter_param=param_name,
            abbreviation=param_abbr)
        return current_value

    @login_logout_GUI
    def verify_cu_configuration_parameter_via_GUI(
            self, plan_name, dist_name, parameter,
            abbreviation, value, bts_id=0):
        """
        Veirfy if given parameter of the CU configuration is equal
         to predicted value.

        :param plan_name:           Name of the plan to choose
        :type plan_name:            str
        :param dist_name:           Destination name of the object
        to be filtered from
        :type dist_name:            str
        :param parameter:           Full name of the parameter
        :type parameter:            str
        :param abbreviation:        Abbreviation of the parameter
        :type abbreviation:         str
        :param value:               Value to be compared
        :type value:                str
        :param bts_id:              BTS ID - related to Test
        Line configuration
        :type bts_id:               int
        """
        self.gui_coam_cu.choose_plan(plan_name=plan_name)
        current_value = self.gui_coam_cu.get_parameter_value(
            object_name=dist_name,
            filter_param=parameter,
            abbreviation=abbreviation)
        if current_value != value:
            raise InvalidParameterValue(
                "Value of the parameter {} is equal to {}. Expected: {}".
                format(parameter, current_value, value))

    @login_logout_GUI
    def modify_cu_configuration_parameters_via_GUI(
            self, dist_name, plan_name="CURRENT_PLAN",
            new_plan_name="NEW_PLAN",
            change_params=None, change_abbreviations=None,
            remove_params=None, remove_abbreviations=None,
            values=None, delta_plan=False,
            activate=True, bts_id=0):
        """
        Change and / or remove CU configuration parameter

        :param dist_name:           Destination name of the object to be
         filtered from
        :type dist_name:            str
        :param plan_name:           Name of the plan to create a copy of
        :type plan_name:            str
        :param new_plan_name:       Name of the new plan to be created
        :type new_plan_name:        str
        :param change_params:       List of the parameters to be modified
        :type change_params:        list
        :param change_abbreviations List of the abbreviations of
        parameters to be changed
        :type change_abbreviations  list
        :param remove_params:       List of the parameters to be removed
        :type remove_params:        list
        :param remove_abbreviations List of the abbreviations
        of parameters to be removed
        :type remove_abbreviations  list
        :param values:              List of the values to modified.
        Corresponds to the change_params
        :type values:               list
        :param delta_plan:          Flag for switching between ordinary
        plan creation and delta plan creation
        :type delta_plan:           bool
        :param activate:            If True, the plan will be activated
        after modification
        :type activate:             bool
        :param bts_id:              BTS ID - related to Test Line configuration
        :type bts_id:               int
        """
        if delta_plan:
            self._create_delta_plan_via_GUI_if_needed(plan_name=new_plan_name)
        else:
            self._create_plan_if_needed(plan_name=plan_name,
                                        new_plan_name=new_plan_name)
        self.gui_coam_cu.choose_plan(plan_name=new_plan_name)

        if change_params:
            for parameter, value, abbreviation in zip(change_params, values,
                                                      change_abbreviations):
                self.gui_coam_cu.set_parameter_value(object_name=dist_name,
                                                     filter_param=parameter,
                                                     abbr=abbreviation,
                                                     new_value=value,
                                                     timeout=180)
                time.sleep(5)
        if remove_params:
            for parameter, abbreviation in zip(
                    remove_params, remove_abbreviations):
                self.gui_coam_cu.delete_parameter(object_name=dist_name,
                                                  filter_param=parameter,
                                                  abbreviation=abbreviation,
                                                  timeout=180)
                time.sleep(5)
        if activate:
            self.gui_coam_cu.activate_plan()

    @login_logout_GUI
    def _create_plan_if_needed(self, plan_name="CURRENT_PLAN",
                               new_plan_name="NEW_PLAN", bts_id=0):
        plans = self.gui_coam_cu.get_all_plans()
        plan_list = [val for val in plans["Planned configurations:"].values()]
        for i in plan_list:
            if not isinstance(i, list):
                plan_list.remove(i)
        if not plan_list[0]:
            self.gui_coam_cu.create_plan(choose_plan=plan_name,
                                         plan_name=new_plan_name)
        else:
            plan_list = list(itertools.chain(*plan_list))
            if new_plan_name not in plan_list:
                self.gui_coam_cu.create_plan(choose_plan=plan_name,
                                             plan_name=new_plan_name)

    @login_logout_GUI
    def _create_delta_plan_via_GUI_if_needed(self, plan_name="NEW_DELTA_PLAN",
                                             bts_id=0):
        """
        Create a delta plan if needed via GUI
        :param plan_name:       Name for new delta plan
        :param bts_id:          BTS id - related to Test Line configuration
        """
        plans = self.gui_coam_cu.get_all_plans()
        plan_list = plans["Delta configurations:"]["plan"]
        if not plan_list:
            self.gui_coam_cu.create_delta_plan(plan_name=plan_name)
        else:
            if plan_name not in plan_list:
                self.gui_coam_cu.create_delta_plan(plan_name=plan_name)

    @login_logout_GUI
    def delete_cu_configuration_plan_via_GUI(self, plan_name, bts_id=0):
        """
        Delete chosen CU configuration plan

        :param plan_name:           Name of the plan to be deleted
        :param plan_name:           str
        :param bts_id:              BTS ID - related to Test
         Line configuration
        :type bts_id:               int
        """
        self.gui_coam_cu.choose_plan(plan_name=plan_name)
        self.gui_coam_cu.delete_plan()

    @load_moler_configuration_from_tl()
    def _download_symptom_report(self, report_file_path, bts_id=0,
                                 log_dir=None, timeout=180):
        """
        Download symptomreport.zip file to log directory on the
         local machine.

        :param report_file_path: path to report file on bts
        :param bts_id: id of bts from which the symptom
         report will be downloaded
        :param log_dir: directory where report will be collected
        :param timeout: timeout for scp.
        """
        if log_dir is None:
            log_dir = get_log_path()

        gnb = DeviceFactory.get_device(format(
            connection_names.ssh_gnb_cu.format(bts_id)))
        gnb.goto_state('FCT')

        mv_cmd = gnb.get_cmd(
            cmd_name='mv',
            cmd_params={'src': os.path.abspath(report_file_path),
                        'dst': "/tmp"})
        mv_cmd()

        download_files(local_dir=log_dir,
                       remote_file=os.path.basename(report_file_path),
                       remote_dir="/tmp",
                       device_name=connection_names.ssh_gnb_cu.format(bts_id),
                       from_state='FCT',
                       timeout=timeout)

    @load_moler_configuration_from_tl()
    def _save_symptom_report(self, bts_id=0, timeout=180):
        """
        Save symptom report.

        :param bts_id: id of bts from which the symptom report will be saved
        :param timeout: timeout for save_symptom_report
        """
        gnb = DeviceFactory.get_device(format(
            connection_names.ssh_gnb_cu.format(bts_id)))
        gnb.goto_state("FSCLISH")
        save_symptom_report_cmd = gnb.get_cmd(cmd_name='save_symptom_report')
        results = save_symptom_report_cmd(timeout)
        log_path = results['PATH']
        logging.info("CU log collected in {}".format(log_path))
        return log_path

    def collect_symptom_report(self, bts_id=0, log_dir=None, timeout=180):
        """
        Save and download symptom report.

        :param bts_id: id of bts from which the symptom report
         will be collected
        :param log_dir: directory where report will be collected
        :param timeout: timeout for _save_symptom_report
        """
        report_file_path = self._save_symptom_report(bts_id=bts_id,
                                                     timeout=timeout)
        self._download_symptom_report(report_file_path=report_file_path,
                                      bts_id=bts_id, log_dir=log_dir)

    @load_moler_configuration_from_tl()
    def crash_process(self, process_name, cu_vm_name, password, bts_id):
        """
        Crash process for VNFC
        :param process_name: Name of process that will be killed
        :param cu_vm_name: Name of VM for which process will be crashed
        :param password: password for user to execute command
        :param bts_id: default id for Cu
        :return: None
        """
        bts = DeviceFactory.get_device(format(
            connection_names.ssh_gnb_cu.format(bts_id)))
        bts.goto_state(cu_vm_name)
        pkill_cmd = bts.get_cmd(
            cmd_name="pkill",
            cmd_params={
                "name": '-f ' + process_name}
        )
        sudo_cmd = bts.get_cmd(
            cmd_name="sudo",
            cmd_params={
                'password': password,
                'cmd_object': pkill_cmd
            }
        )
        sudo_cmd()

    @login_logout_GUI
    def change_service_user_password(self, username, current_password,
                                     new_password, bts_id=0):
        """
        Change password for the chosen service user

        :param username:            Service user name
        :param current_password:    Current password
        :param new_password:        New password
        :param bts_id:              BTS id - related to Test
        Line configuration
        :return status:             Status of the changing password
        """

        status = self.gui_coam_cu.change_service_user_password(
            service_user_name=username,
            current_service_password=current_password,
            new_service_password=new_password)
        logging.info("Status of the change: {}.".format(status))
        return status

    @login_logout_GUI
    def load_cu_configuration_via_GUI(self, file_path,
                                      plan_name="NEW_PLAN",
                                      bts_id=0):
        """
        Loads CU scf to CU-WebEM
        :param file_path:       Local path to the scf file
        :param plan_name:       Name of the plan
        :param bts_id:          BTS id - related to Test
        Line configuration
        :return:                Status of the commissioning
        """

        status = self.gui_coam_cu.load_commissioning_file_and_check_load_status(
            file_path=file_path,
            plan_name=plan_name)
        return status

    @login_logout_GUI
    def activate_cu_configuration_via_GUI(
            self, plan_name="NEW_PLAN", download_plan_without_activation=False,
            activate_plan_despite_reset=False,
            activate_plan_despite_cell_locking=False,
            inactive_configurations=False, bts_id=0):
        """
        Activates the chosen plan via GUI. Some parameters change the
        behaviour of the activation
        :param plan_name:                           Name of the plan to be
        chosen and activated
        :param download_plan_without_activation:    if True, download plan
         without activation will be selected
        :param activate_plan_despite_reset:         if True, activate plan
         despite of reset will be selected
        :param activate_plan_despite_cell_locking:  if True, activate plan
         despite of cell locking will be selected
        :param inactive_configurations:             if True, activated plan
        from Inactive configurations
        :param bts_id:                              BTS id - related to
        Test Line configuration
        :return:                                    Status of the activation
        """
        self.gui_coam_cu.choose_plan(plan_name=plan_name,
                                     inactive_configurations=inactive_configurations)
        status = self.gui_coam_cu.activate_plan(
            download_plan_without_activation=download_plan_without_activation,
            activate_plan_despite_reset=activate_plan_despite_reset,
            activate_plan_despite_cell_locking=activate_plan_despite_cell_locking)
        return status

    @login_logout_GUI
    def get_all_plans(self, bts_id=0):
        """
        Get a list of all loaded plans from CU-WebEM
        :param bts_id:                              BTS id - related to
        Test Line configuration
        :return:                                    Dictionary of all plans
        """
        return self.gui_coam_cu.get_all_plans()

    @login_logout_GUI
    def remove_object_from_configuration(self, object_name, bts_id=0):
        """
        Remove given object from planned configuration
        :param object_name: str, object to remove, e.g. NRDU-1
        :return:
        """
        self.gui_coam_cu.remove_object(object_name=object_name)

    @login_logout
    def download_snapshot_from_cu(self, path, request_timeout=300,
                                  operation_timeout=600, bts_id=0):
        """
        Gets local snapshot and saves it under given directory.
        :param path: absolute directory path where snapshot will be saved
        :param request_timeout: timeout in seconds for sending
        request to OAM, defaults to None
        :param operation_timeout: timeout in seconds for getting
        snapshot, defaults to 600.0
        :param bts_id: ID of BTS
        :return: None
        """
        self.cu.get_local_snapshot(path, request_timeout, operation_timeout)
        logging.debug("Snapshot collected successfully")

    @login_logout_GUI
    def verify_statuses_of_cells_from_cu_webui(self, bts_id=0,
                                               operational_state1="enabled",
                                               operational_state2="enabled",
                                               operational_state3="enabled",
                                               operational_state4="enabled"):
        """
        Verify if statuses of all cells are correct from webui
        :param bts_id: ID of BTS
        :param operational_state1:  Operational state of a cell.
        :param operational_state2:  Operational state of a cell.
        :param operational_state3:  Operational state of a cell.
        :param operational_state4:  Operational state of a cell.
        :return: None
        """
        operational_states = [operational_state1, operational_state2,
                              operational_state3, operational_state4]
        cell_info = self.gui_coam_cu.get_cells_status_info()
        logging.info(cell_info)
        for x in range(len(cell_info)):
            cell_status = cell_info[x]["Operational state"]
            if not cell_status.lower() == operational_states[x].lower():
                logging.info("Cell operational state: {},"
                             " expected {}".format(cell_status,
                                                   operational_states[x]))
                raise Exception("Invalid cells statuses")

    @login_logout
    def get_cu_active_software_version(self, bts_id=0):
        """
        Gets CU active software version.
        :return: string with SW version
        """
        cu_software = self.cu.get_active_software_version()
        logging.info("Cu active software: {}.".format(cu_software))
        return cu_software

    def adjust_dist_name(self, dist_name, bts_id=0, du_id=0):
        """
        Adjust mrbts_id and global bts id (nrbts_id or lnbts_id)
         in given distName.

        :param dist_name:               distName in format
         e.g. MRBTS-{}/NRBTS-{}/NRCELL-1
        :type dist_name:                str
        :param bts_id:                  enb_id or gnb_id, related to test
         line configuration, default set to 0
        :type bts_id:                   int or str
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :type du_id:                    int or str
        :return: distName with proper values
        """
        mrbts_id = tl_config.get_bts_instance_id(
            bts_id=bts_id, du_id=du_id)
        global_bts_id = tl_config.get_global_bts_id(
            bts_id=bts_id, du_id=du_id)
        return dist_name.format(mrbts_id, global_bts_id)

    @login_logout_GUI
    def remove_cell_from_cu_configuration_via_gui(
            self, cell_id_to_remove, cell_group_id=0, plan_name="CURRENT_PLAN",
            new_plan_name="NEW_PLAN", bts_id=0, du_id=0):
        """
        Removes cell with given id from CU configuration.
        :param cell_id_to_remove:        id of cell that will be removed
        :param cell_group_id:            group id of removed cell
        :param plan_name:                name of the plan to create a copy of
        :param new_plan_name:            name of the new plan to be created
        :param bts_id:                   gNB id - related to Test
        Line configuration.
        :param du_id:                    DU id(Distributed Unit) -
        id related to Test Line configuration - gnb.dus[]
        :return: None
        """

        self._create_plan_if_needed(plan_name=plan_name, new_plan_name=new_plan_name)
        self.gui_coam_cu.choose_plan(plan_name=new_plan_name)

        number_of_cells = int(self.gui_coam_cu.get_cells_info())
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}",
                                          bts_id=bts_id, du_id=du_id)

        self.gui_coam_cu.remove_object(object_name='NRCELL-{}'
                                       .format(cell_id_to_remove))

        self.gui_coam_cu.remove_element(
            object_name='NRCELLGRP-{}'.format(cell_group_id),
            filter_param='List of NR cells assigned to cell group',
            abbreviation='nrCellList',
            list_element='#{}'.format(number_of_cells))

        maxNumScellsDl_name = 'Maximum number of secondary cells for' \
                              ' DL carrier aggregation'
        self.gui_coam_cu.set_parameter_value(object_name=dist_name,
                                             filter_param=maxNumScellsDl_name,
                                             abbr='maxNumScellsDl',
                                             new_value=number_of_cells - 2)

        self.gui_coam_cu.validate_plan()
        self.gui_coam_cu.activate_plan()

    @login_logout_GUI
    def add_cell_based_on_existing_cell_to_cu_configuration_via_gui(
            self, cell_parameters, cell_id_to_copy_from,
            cell_group_id=0, plan_name="CURRENT_PLAN",
            new_plan_name="NEW_PLAN", bts_id=0, du_id=0):

        """
         Adds a new cell to configuration based on an existing cell
         :param cell_parameters:          dictionary containing values
         for mandatory parameters:
                                          lcrId, nrarfcn, physCellId
                                             example:
                                             cell_parameters ={
                                                 'lcrId': '4',
                                                 'nrarfcn': '2103311',
                                                 'physCellId': '44'
                                             }
         :param cell_id_to_copy_from:     id of cell that new cell will be
          based on
         :param cell_group_id:            group id of copied cell
         :param plan_name:                name of the plan to create a copy of
         :param new_plan_name:            name of the new plan to be created
         :param bts_id:                   gNB id - related to Test
         Line configuration.
         :param du_id:                    DU id(Distributed Unit) -
          id related to Test Line configuration - gnb.dus[]
         :return: None
         """

        cell_id = cell_parameters['lcrId']
        nrarfcn = cell_parameters['nrarfcn']
        physCellId = cell_parameters['physCellId']
        nrbts_dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}",
                                                bts_id=bts_id, du_id=du_id)
        cell_dist_name = '{}/NRCELL-{}'.format(nrbts_dist_name,
                                               cell_id_to_copy_from)

        self._create_plan_if_needed(plan_name=plan_name,
                                    new_plan_name=new_plan_name)
        self.gui_coam_cu.choose_plan(plan_name=new_plan_name)

        number_of_cells = int(self.gui_coam_cu.get_cells_info())

        self.gui_coam_cu.copy_object(object_name=nrbts_dist_name,
                                     object_class_name='NRCELL',
                                     plan_name=new_plan_name,
                                     object_distinguished_name=cell_dist_name,
                                     copy_object_with_subtree=True,
                                     id_value=cell_id)

        maxNumScellsDl_name = 'Maximum number of secondary cells for DL ' \
                              'carrier aggregation'
        self.gui_coam_cu.set_parameter_value(
            object_name=nrbts_dist_name,
            filter_param=maxNumScellsDl_name,
            abbr='maxNumScellsDl',
            new_value=number_of_cells)

        self.gui_coam_cu.set_parameter_value(
            object_name=cell_dist_name,
            filter_param='Local cell resource ID',
            abbr='lcrId',
            new_value=cell_id)

        self.gui_coam_cu.set_parameter_value(
            object_name=cell_dist_name,
            filter_param='NR Absolute radio frequency channel number',
            abbr='nrarfcn',
            new_value=nrarfcn)

        self.gui_coam_cu.set_parameter_value(
            object_name=cell_dist_name,
            filter_param='Physical cell identifier',
            abbr='physCellId',
            new_value=physCellId)

        self.gui_coam_cu.add_element(
            object_name='NRCELLGRP-{}'.format(cell_group_id),
            filter_param='List of NR cells assigned to cell group',
            abbreviation='nrCellList',
            list_element_value=cell_id)

        self.gui_coam_cu.validate_plan()
        self.gui_coam_cu.activate_plan()

    @login_logout_GUI
    def set_pm_counter_gather_interval_on_cu_to_given_value_via_gui(
            self, cu_id, new_value="5min", plan_name="CURRENT_PLAN",
            new_plan_name="NEW_PLAN",
            dist_name="MRBTS-{}/NRBTS-1/NRPMRNL-1",
            parameter_full_name="NR F1AP Interface Report for CU per DU",
            delete_existing_new_plan=True, bts_id=0):
        """
        Method changes value of PM counter gathering interval on
        gNB CU via GUI using Selenium library.

        :param cu_id:                       gNB CU ID of the CU to change
        the value for,
                                            Used for defining MRBTS value. Found
                                            under tl.gnbs[0].cu.instance_id
        :param new_value:                   New value of gathering interval,
                                            default: 5min
        :param plan_name:                   Name of current plan applied to
                                            CU, default: CURRENT_PLAN
        :param new_plan_name:               Name of new plan under which
                                            changes will be made, default: NEW_PLAN
        :param dist_name:                   Dist name to the parameter,
                                            default: MRBTS-{}/NRBTS-1/NRPMRNL-1
        :param parameter_full_name:         Full parameter name as seen via browser,
                                            example: NR F1AP Interface Report
                                             for CU per
        :param delete_existing_new_plan:    Should existing new plan be removed
                                            before changing the parameter value,
                                            default: True
        :param bts_id:                      gNB id - related to Test Line
                                  configuration.
        """
        try:
            if delete_existing_new_plan:
                self._delete_plan_if_needed_via_gui(new_plan_name)
            self._create_plan_if_needed(plan_name=plan_name, new_plan_name=new_plan_name)
            self.gui_coam_cu.choose_plan(plan_name=new_plan_name)
            status = self._set_single_cu_configuration_parameter_value_via_gui(
                dist_name=dist_name.format(cu_id),
                parameter_full_name=parameter_full_name,
                new_value=new_value)
            if status:
                logging.info("Changes made in plan, activating.")
                self.gui_coam_cu.activate_plan()
            else:
                logging.info("No changes made, value already set, "
                             "skipping activation.")
        except Exception as e:
            raise e
        finally:
            self.logout_gui()

    @load_moler_configuration_from_tl()
    def get_cu_pm_counters(self, counters_id, bts_id=0):
        """
        Get PM counters values from OAM vm file system.

        :param bts_id: ID of BTS
        :param counters_id: general counters ID (e.g. 55110)
        """
        bts = DeviceFactory.get_device(format(
            connection_names.ssh_gnb_cu.format(bts_id)))
        bts.goto_state("OAM")
        result = {}
        pm_data_path = "/var/opt/nokia/performancemanagement/storage/results/{}"
        cat_cmd = bts.get_cmd(
            cmd_name="cat",
            cmd_params={"path": pm_data_path.format("resultMapping.json")})
        try:
            pm_src_file_name = json.loads(
                "".join(cat_cmd()["LINES"]))[counters_id]["filenames"][0]
        except KeyError:
            MolerTest.error("Provided counters_id NOT exist", raise_exception=True)
            return None
        extract_xml_file = bts.get_cmd(cmd_name="run_script", cmd_params={
            "script_command": "sudo cp {} /tmp;sudo chmod 777 /tmp/{};gzip "
                              "-d /tmp/{}; sudo rm /tmp/{}".
                              format(pm_data_path.format(pm_src_file_name),
                                     pm_src_file_name, pm_src_file_name,
                                     pm_src_file_name)})
        extract_xml_file()
        cat_xml_cmd = bts.get_cmd(cmd_name="cat", cmd_params={"path": "/tmp/{}".format(
            pm_src_file_name[:-3])})
        for line in cat_xml_cmd()["LINES"]:
            if counters_id in line:
                match = re.search(r"<(?P<COUNTER_ID>.*)>(?P<VALUE>\d+)<", line)
                result.update({match.group("COUNTER_ID"): match.group("VALUE")})
        bts.get_cmd(cmd_name="rm", cmd_params={"file": "/tmp/{}*".format(
            pm_src_file_name.split(".")[0])})()

        return result

    def _delete_plan_if_needed_via_gui(self, plan_name):
        """
        Method attempts to remove existing plan template.

        :param plan_name:   Name of the plan to remove
        :return:            None
        """
        plans = self.gui_coam_cu.get_all_plans()
        plan_list = [val for val in plans["Planned configurations:"].values()]
        logging.debug("Found plan list: {}".format(plan_list))
        for i in plan_list:
            if not isinstance(i, list):
                plan_list.remove(i)
        logging.debug("Filtered plan list: {}".format(plan_list))
        if not plan_list[0]:
            return
        plan_list = list(itertools.chain(*plan_list))
        if plan_name in plan_list:
            self.gui_coam_cu.choose_plan(plan_name=plan_name)
            self.gui_coam_cu.delete_plan()

    def _set_single_cu_configuration_parameter_value_via_gui(
            self, dist_name, parameter_full_name=None,
            new_value=None):
        """
        Method attempts to change a single parameter value on gNB CU to
        given value. If the value is already set
        method will not attempt to change it.

        :param dist_name:               Dist name path of the parameter,
        example: MRBTS-1/NRBTS-1/NRPMRNL-1
        :param parameter_full_name:     Full parameter name as seen via browser,
                                        example: NR F1AP Interface Report for CU per DU
        :param new_value:               New value of the parameter, example: 5min
        :return:                        True - if changes were made to
        the plan, False - if no changes were made
        """
        current_value = self.gui_coam_cu.get_parameter_value(
            object_name=dist_name, filter_param=parameter_full_name)
        logging.info("Current value of {}: {}".format(
            dist_name + "/" + parameter_full_name, str(current_value)))
        if current_value != new_value:
            self.gui_coam_cu.set_parameter_value(
                object_name=dist_name,
                filter_param=parameter_full_name,
                new_value=new_value, timeout=60)
            time.sleep(3)
            return True
        return False

    @load_moler_configuration_from_tl()
    def get_pid(self, process_name, cu_vm_name, bts_id=0):
        """
        Get PID for given process name
        :param process_name: Name of process
        :param cu_vm_name: Name of VM on CU
        :param bts_id: default id for Cu
        :return: PID: process id
        """
        bts = DeviceFactory.get_device(format(
            connection_names.ssh_gnb_cu.format(bts_id)))
        bts.goto_state(cu_vm_name)
        ps_cmd = bts.get_cmd(
            cmd_name="ps",
            cmd_params={
                "options": '-ef'}
        )
        for process in ps_cmd():
            if process_name in process['CMD']:
                return process['PID']
        raise ValueError("There is no process {} on {} VM.".format(
            process_name, cu_vm_name))

    def get_last_finished_pm_period(self, interval=5):
        date = datetime.now()
        date = date - timedelta(minutes=interval)
        date = date.replace(minute=interval * (date.minute // interval))
        return date.strftime("%Y-%m-%d %H:%M:00")

    @login_logout
    def lock_cells(self, cell_ids=None, bts_id=0):
        """
        Lock cells with specified ids on CU

        :param bts_id:  default id for Cu
        :param cell_ids: list of cells which need to be locked on Cu
        :return:            None
        """
        if cell_ids is None:
            cell_ids = self._get_cells_ids()
            self.cu.lock_cells(cell_ids=cell_ids)
        else:
            if not isinstance(cell_ids, list):
                cell_ids = [cell_ids]
            self.cu.lock_cells(cell_ids=cell_ids)

    @login_logout
    def unlock_cells(self, cell_ids=None, bts_id=0):
        """
        Unlock cells with specified ids on CU

        :param bts_id:  default id for Cu
        :param cell_ids: list of cells which need to be unlocked on CU
        :return:            None
        """
        if cell_ids is None:
            cell_ids = self._get_cells_ids()
            self.cu.unlock_cells(cell_ids=cell_ids)
        else:
            if not isinstance(cell_ids, list):
                cell_ids = [cell_ids]
            self.cu.unlock_cells(cell_ids=cell_ids)

    @login_logout
    def lock_cell_group(self, cell_group_id=0, bts_id=0):
        """
        Lock cell group with specified ids on CU

        :param bts_id:  default id for Cu
        :param cell_group_id: list of str corresponding to CU or
        vDU Cell Groups IDs
        :return:            None
        """
        self.cu.lock_cell_group(cell_group_id=cell_group_id)

    @login_logout
    def unlock_cell_group(self, cell_group_id=0, bts_id=0):
        """
        UnLock cell group with specified ids on CU

        :param bts_id:  default id for Cu
        :param cell_group_id: list of str corresponding to CU or
        vDU Cell Groups IDs
        :return:            None
        """
        self.cu.unlock_cell_group(cell_group_id=cell_group_id)

    @login_logout
    def verify_if_cells_are_disabled(self, cells=None, bts_id=0):
        """
        Verify if provided cells are locked on CU, have operational
         state equal disabled.

        :param bts_id:  default id for Cu
        :param cells:  list of cell ids to be checked if are disabled
        :return: None
        """
        if not self._verify_cells_status(cell_ids=cells, status='disabled'):
            raise NotAllCellsDisabled("Not all provided cells are disabled")

    @login_logout
    def verify_if_cells_are_enabled(self, cells=None, bts_id=0):
        """
        Verify if provided cells are unlocked on CU, have operational
        state equal enabled.

        :param cells:  list of cell ids to be checked if are enabled
        :param bts_id:  default id for Cu
        :return: None
        """
        if not self._verify_cells_status(cell_ids=cells, status='enabled'):
            raise NotAllCellsEnabled("Not all provided cells are enabled")

    def wait_for_cells_to_be_disabled(self, timeout, interval,
                                      cells=None, bts_id=0):
        """
        Wait if all provided cells are locked, have status disabled.

        :param cells:  list of cell ids to be checked if are disabled
        :param timeout:  time in seconds to wait for all cells to be disabled
        :param interval:  time in seconds between each status check
        :param bts_id:  default id for Cu
        :return: None
        """
        start_time = time.time()
        while time.time() < start_time + time_to_seconds(time=timeout):
            try:
                self.verify_if_cells_are_disabled(cells=cells)
                logging.info("All cells are disabled")
                break
            except NotAllCellsDisabled:
                logging.info("Check failed: not all cells are "
                             "disabled - sleeping for {}s".format(interval))
                time.sleep(time_to_seconds(time=interval))
        else:
            raise NotAllCellsDisabled("Timeout passed. Not all"
                                      " provided cells are disabled")

    def wait_for_cells_to_be_enabled(self, timeout, interval,
                                     cells=None, bts_id=0):
        """
        Wait if all provided cells are unlocked, have status enabled.

        :param cells:  list of cell ids to be checked if are enabled
        :param timeout:  time in seconds to wait for all cells to be enabled
        :param interval:  time in seconds between each status check
        :param bts_id:  default id for Cu
        :return: None
        """
        start_time = time.time()
        while time.time() < start_time + time_to_seconds(time=timeout):
            try:
                self.verify_if_cells_are_enabled(cells=cells)
                logging.info("All cells are enabled")
                break
            except NotAllCellsEnabled:
                logging.info("Check failed: not all cells are "
                             "enabled- sleeping for {}s".format(interval))
                time.sleep(time_to_seconds(time=interval))
            except ApiException as e:
                logging.info("ApiException caught while waiting for "
                             "status: {}\n Sleeping for {}".format(e, interval))
                time.sleep(time_to_seconds(time=interval))
            except ProtocolError as e:
                logging.info("ProtocolError caught while waiting for "
                             "status: {}\n Sleeping for {}".format(e, interval))
                time.sleep(time_to_seconds(time=interval))
        else:
            raise NotAllCellsEnabled("Timeout passed. Not all provided "
                                     "cells are enabled")

    def _verify_cells_status(self, status, cell_ids=None):
        """
        Verify if cells with given IDs have given status.
        If cell_ids is None then verify that all cells ids have given status.

        :param cell_ids:  list of cell which status will be checked
        :param status:  provided status of checked cell
        :return:  True/False
        """
        cells_config = self.cu.get_cells_statuses()
        if not cells_config:
            return False

        if cell_ids is None:
            cell_ids = self._get_cells_ids()

        for cell in cells_config:
            if cell['id'] in cell_ids:
                if cell['operational_state'] != status:
                    logging.info("Current cell id: {} status not "
                                 "match:".format(cell['id']))
                    return False
        return True

    def _get_cells_ids(self, bts_id=0):
        """
        Get all cells ids.

        :param bts_id:  default id for Cu
        :return:  cell_ids - list of cell ids
        """
        cells_config = self.cu.get_cells_statuses()
        cell_ids = []
        for cell in cells_config:
            cell_ids.append(cell['id'])
        return cell_ids

    def measure_reset_vCU_time(
            self, runs=1, success_rate=0.99, average_target=600,
            timeout=900, interval=15,
            bts_id=0):
        """
        Perform vCU reset given amount of time and verify if meet average
         time target and success rate ratio.
        :param bts_id:  default id for Cu
        :param runs: Number of runs
        :param success_rate: Target PASSED to RUNS ratio
        :param average_target: Target vCu start-up time in seconds.
        :param timeout:  time in seconds to wait for all cells to be enabled
        :param interval:  time in seconds between each status check
        :return average_time: average time of vCU reset
        """
        passed = 0
        failed = 0
        run_times = []
        for run in range(int(runs)):
            start_run_time = datetime.now()
            logging.info('Run: {}'.format(run))
            run_result = self._measure_reset_vCU_time(
                average_target=average_target, timeout=timeout,
                interval=interval, bts_id=bts_id)
            if isinstance(run_result, float):
                passed += 1
                logging.info('Run: {} passed'.format(run))
                run_times.append(run_result)
            else:
                logging.warning("Run: {} failed, start time "
                                "of run: {}".format(run, start_run_time))
                failed += 1

            time.sleep(10)

        logging.info("Passed/runs ratio: {}".format(passed / float(runs)))
        logging.info("Max reset time: {}".format(max(run_times)))
        if len(run_times) > 0:
            average_startup_time = sum(run_times) / len(run_times)
            logging.info('Start-up time average of '
                         'successful runs: {}'.format(average_startup_time))

            if average_startup_time > average_target:
                raise AverageStartupTargetNotMet("Average startup time {}s "
                                                 "exceed presume value {}s".
                                                 format(average_startup_time, average_target))

        if (passed / float(runs)) < float(success_rate):
            raise StartUpTargetNotMet("Runs: {}, Failed: {}, Target "
                                      "not met".format(runs, failed))

        return average_startup_time

    def _measure_reset_vCU_time(
            self, average_target=600, timeout=1500, interval=15,
            log_path="/home/ute/logs",
            bts_id=0):
        """
        Perform vCU reset and measure duration.
        :param bts_id:  default id for Cu
        :param average_target: Target vCu start-up time in seconds.
        :param timeout:  time in seconds to wait for all cells to be enabled
        :param interval:  time in seconds between each status check
        :param log_path: Path for gather Cu snapshot
        """
        max_time_target = average_target * 1.2
        reset_time = time.time()
        self.reset_cu()
        time.sleep(60)
        self.wait_for_cu_available(timeout=500, interval=20)
        self.wait_for_cells_to_be_enabled(timeout=timeout, interval=interval)
        last_cell_up = time.time()
        start_up_time = last_cell_up - reset_time
        logging.info("Time {}:".format(start_up_time))
        if start_up_time > max_time_target:
            logging.warning("Site start-up time too long({}), "
                            "getting snapshot".format(start_up_time))
            self.download_snapshot_from_cu(path=log_path)
            return
        else:
            return start_up_time

    def wait_for_cu_available(self, timeout, interval):
        """
        Wait for CU to be in available state.
        :param timeout:  time in seconds to wait for possibility
        to connect to CU
        :param interval:  time in seconds between each check
        """
        start_time = time.time()
        while time.time() < start_time + time_to_seconds(time=timeout):
            try:
                self.connect()
                logging.info("Cu state is available")
                self.disconnect()
                break
            except AuthenticationFailed:
                logging.info("Check failed: Cu still not available"
                             "- sleeping for {}s".format(interval))
                time.sleep(time_to_seconds(time=interval))
            except ProtocolError as e:
                logging.info("ProtocolError caught while waiting for"
                             " CU: {}\n Sleeping for {}".format(e, interval))
                time.sleep(time_to_seconds(time=interval))
        else:
            raise CuNotAvailable("Timeout passed. Cu unavailable")

    @login_logout_GUI
    def fix_errors_with_uploaded_configuration(
            self, create_all_missing_mandatory_objects,
            create_all_missing_mandatory_parameters, timeout, choose_plan=True,
            validate_plan=True, bts_id=0):
        """Fix errors with uploaded scf file in webEM Cu, using create
        all missing MOs and parameters
        :param create_all_missing_mandatory_objects: boolean, if True,
        option will be selected
        :param create_all_missing_mandatory_parameters: boolean, if True
        option will be selected
        :param choose_plan: boolean, if True plan will be selected before
         errors fix
        :param validate_plan: boolean, if True plan will be validated
        before activation
        :param timeout: int, timeout for selenium to click element,
         by default 60
        :param bts_id: default id for Cu
        """
        if choose_plan:
            plan_name = self.gui_coam_cu.get_all_plans()
            plan_list = [val for val in
                         plan_name["Planned configurations:"].values()]
            plan_name = str(plan_list[1]).strip("',u,[,]")
            self.gui_coam_cu.choose_plan(plan_name=plan_name)

        self.gui_coam_cu.fix_errors(
            create_all_missing_mandatory_objects=create_all_missing_mandatory_objects,
            create_all_missing_mandatory_parameters=create_all_missing_mandatory_parameters, timeout=timeout)
        if validate_plan:
            self.gui_coam_cu.validate_plan()

    @login_logout
    def get_x2_links_info(self, bts_id=0):
        """
        Get X2 Links info dictionary
        :param bts_id: default id for Cu
        """
        x2_links_dict = self.cu.get_x2_links_info()
        logging.debug("X2 links info: {0}".format(x2_links_dict))
        return x2_links_dict

    def get_x2_link_id(self, enb_id, bts_id=0):
        """
        Get X2 link id of given enb_id
        :param enb_id: (str) LTE eNB id (eg. '77033')
        :param bts_id: default id for Cu
        """
        x2_links_dict = self.get_x2_links_info(bts_id)
        for x2_link in x2_links_dict['created']:
            if x2_link['enb_id'] == str(enb_id):
                return x2_link['id']
        raise InvalidStatuses(
            "X2 link for enb_id: {0} NOT found in x2 links info!".
            format(enb_id))

    def verify_x2_link_status(self, status='available', link_id=1, bts_id=0):
        """
        Verify is given X2 link status is equal to expected value
        :param status: (str) expected status
        :param link_id: (int) LTEENB object id
        :param bts_id: default id for Cu
        """
        x2_links_dict = self.get_x2_links_info(bts_id)
        for x2_link in x2_links_dict['created']:
            if x2_link['id'] == str(link_id):
                if x2_link['x2_link_status'] == status:
                    logging.info(
                        "X2 link id: {0} to eNB: {1} has"
                        " expected status: {2}".
                        format(x2_link['id'], x2_link['enb_id'],
                               x2_link['x2_link_status']))
                    return True
                else:
                    raise InvalidStatuses("X2 link id: {0} "
                                          "to eNB: {1} has unexpected "
                                          "status: {2}".
                                          format(x2_link['id'],
                                                 x2_link['enb_id'],
                                                 x2_link['x2_link_status']))
        raise InvalidStatuses(
            "X2 link id: {0} NOT found in x2 links info!".format(link_id))

    def verify_x2_lock_state(self, state='unlocked', link_id=1, bts_id=0):
        """
        Verify is given X2 link lock state is equal to expected value
        :param state: (str) expected lock state
        :param link_id: (int) LTEENB object id
        :param bts_id: default id for Cu
        """
        x2_links_dict = self.get_x2_links_info(bts_id)
        for x2_link in x2_links_dict['created']:
            if x2_link['id'] == str(link_id):
                if x2_link['x2_link_lock'] == state:
                    logging.info("X2 link id: {0} to eNB: {1} has "
                                 "expected lock state: {2}".
                                 format(x2_link['id'], x2_link['enb_id'],
                                        x2_link['x2_link_lock']))
                    return True
                else:
                    raise InvalidStatuses("X2 link id: {0} to eNB:"
                                          " {1} has unexpected lock "
                                          "state: {2}".
                                          format(x2_link['id'],
                                                 x2_link['enb_id'],
                                                 x2_link['x2_link_lock']))
        raise InvalidStatuses("X2 link id: {0} NOT found in x2 "
                              "links info!".format(link_id))

    @login_logout
    def lock_x2_links(self, link_ids, bts_id=0):
        """
        Trigger X2 links lock operation
        :param list[str] link_ids: list of link ids (eg. ['1',])
        :param bts_id: default id for Cu
        """
        result = self.cu.lock_x2_links(link_ids)
        logging.debug(result)

    @login_logout
    def unlock_x2_links(self, link_ids, bts_id=0):
        """
        Trigger X2 links unlock operation
        :param list[str] link_ids: list of link ids (eg. ['1',])
        :param bts_id: default id for Cu
        """
        result = self.cu.unlock_x2_links(link_ids)
        logging.debug(result)

    def measure_time_cell_lock_or_unlock_vCU(
            self, operation="lock", runs=1, time_target=160, timeout=360,
            bts_id=0):
        """
        Performs cell lock and unlock on vCU given amount of times and
        check if duration of lock
        and unlock is less than the given time value.
        :param operation:  lock or unlock
        :param bts_id: BTS id - related to Test Line configuration.
        :param runs: Number of runs
        :param time_target: Target lock and unlock time in seconds.
        :param timeout: Wait for cell to be enabled or disabled.
        :return: average_time - average time of Cu lock or unlock one cell.
        """

        if operation == "lock":
            runs_time_lock = []
            for run in range(int(runs)):
                logging.info("Run: {} ".format(run))
                lock = \
                    self._measure_time_cell_lock_or_unlock_vCU(
                        operation=operation,
                        time_target=time_target,
                        timeout=timeout, bts_id=bts_id)
                runs_time_lock.append(lock)
            average_time = sum(runs_time_lock) / len(runs_time_lock)
            logging.info("Lock cell. Avg time: {}, Max time: {}, "
                         "Runs: {}".format(average_time, max(runs_time_lock),
                                           len(runs_time_lock)))

        elif operation == "unlock":
            runs_time_unlock = []
            for run in range(int(runs)):
                logging.info("Run: {} ".format(run))
                unlock = self._measure_time_cell_lock_or_unlock_vCU(
                    operation=operation, time_target=time_target,
                    timeout=timeout, bts_id=bts_id)
                runs_time_unlock.append(unlock)
            average_time = sum(runs_time_unlock) / len(runs_time_unlock)
            logging.info("Unlock cell. Avg time: {}, Max time: {}, "
                         "Runs: {}".
                         format(average_time, max(runs_time_unlock),
                                len(runs_time_unlock)))

        return round(average_time, 1)

    def _measure_time_cell_lock_or_unlock_vCU(self, operation="lock",
                                              time_target=160, timeout=360,
                                              bts_id=0):
        """
        Performs cell lock and unlock on vCU and check if duration of lock
        and unlock is less than the given time value.
        :param operation:  lock or unlock  - operation type
        :param bts_id: BTS id - related to Test Line configuration.
        :param time_target: Target lock and unlock time in seconds.
        :param timeout: Wait for cell to be enabled or disabled.
        :return: None
        """
        self.connect()
        cell_ids = self._get_cells_ids()
        logging.info(cell_ids)
        self.disconnect()
        err_message = ""

        if operation == "lock":
            lock_start_time = time.time()
            self.lock_cells(cell_ids=cell_ids[0])
            self.wait_for_cells_to_be_disabled(interval=2, timeout=timeout,
                                               cells=cell_ids[0])
            lock_stop_time = time.time()
            operation_time = lock_stop_time - lock_start_time
            logging.info("Lock one cell duration: {}".format(operation_time))
            self.unlock_cells(cell_ids=cell_ids[0])
            self.wait_for_cells_to_be_enabled(interval=2, timeout=timeout,
                                              cells=cell_ids[0])

            if operation_time > time_target:
                err_message = ("Cell lock time duration {} exceeded max "
                               "expected time {} seconds"
                               .format(operation_time, time_target))

        elif operation == "unlock":
            self.lock_cells(cell_ids=cell_ids[0])
            self.wait_for_cells_to_be_disabled(interval=2, timeout=timeout,
                                               cells=cell_ids[0])
            unlock_start_time = time.time()
            self.unlock_cells(cell_ids=cell_ids[0])
            self.wait_for_cells_to_be_enabled(interval=2, timeout=timeout,
                                              cells=cell_ids[0])
            unlock_stop_time = time.time()
            operation_time = unlock_stop_time - unlock_start_time
            logging.info("Unlock one cell duration: {}".format(operation_time))

            if operation_time > time_target:
                err_message = ("Cell unlock time duration {} exceeded max"
                               " expected time {} seconds"
                               .format(operation_time, time_target))

        if err_message != "":
            raise LockUnlockTargetNotMet(err_message)
        else:
            return operation_time


class GnbCu(GenericCu):
    """Class contains CU(Centralized Unit) keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.
        """
        super(GnbCu, self).__init__(bts_type=GnbCu.bts_type)


class CuAlarm(GnbCu):
    """Class contains Alarm keywords for CU"""

    def __init__(self):
        """
        Constructor of CuAlarm class.

        """
        super(CuAlarm, self).__init__()

    @login_logout
    def verify_alarm_is_active(self, fault_id, fault_name, alarm_id, bts_id=0):
        """
        Verify given fault identified by fault_id/fault_name/alarm_id is active
        :param fault_id: Id of expected fault (for example 4350)
        :param fault_name: Name of expected fault (for example
        'RAP or VM unavailable for Cloud')
        :param alarm_id: Id of expected alarm (for example 7101)
        :param bts_id: ID of BTS
        :return: None
        """
        for alarm in self.cu.get_active_alarms()['alarms']:
            if alarm['fault_id'] == fault_id and \
                    alarm['fault_name'] == fault_name \
                    and alarm['alarm_id'] == int(alarm_id):
                logging.debug("fault_id: %s is active as expected", fault_id)
                return
        raise AlarmIsNotActive("fault_id: {} fault_name: {} alarm_id: {} "
                               "is not active".format(fault_id,
                                                      fault_name,
                                                      alarm_id))

    @login_logout
    def verify_alarm_is_not_active(self, fault_id, fault_name=None,
                                   alarm_id=None, alarm_name=None,
                                   bts_id=0):
        """
        Verify given fault identified by fault_id is (and
        optionally fault_name/alarm_id/alarm_name) not active
        :param fault_id: Id of unwanted fault (for example 4350)
        :param fault_name: Name of unwanted fault (for example
        'RAP or VM unavailable for Cloud')
        :param alarm_id: Id of unwanted alarm (for example 7220)
        :param alarm_name: Id of unwanted alarm (for example
        'BASE STATION SECURITY PROBLEM')
        :param bts_id: ID of BTS
        :return: None
        """
        for alarm in self.cu.get_active_alarms()['alarms']:
            fault_id_match = (alarm['fault_id'] == fault_id)
            fault_name_match = True if (fault_name is None) else \
                (alarm['fault_name'] == fault_name)
            alarm_id_match = True if (alarm_id is None) else \
                (alarm['alarm_id'] == int(alarm_id))
            alarm_name_match = True if (alarm_name is None) else\
                (alarm['alarm_name'] == alarm_name)
            if fault_id_match and fault_name_match and alarm_id_match and\
                    alarm_name_match:
                raise AlarmIsActive("fault_id: {} should not be active".format(
                    fault_id))
        logging.debug("fault_id: %s is not active as expected", fault_id)

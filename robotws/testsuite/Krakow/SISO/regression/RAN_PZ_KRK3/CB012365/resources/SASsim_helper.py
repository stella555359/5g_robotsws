import datetime
import re
import logging
import json
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.tl_config import tl
from taf.ul.moler.converter import add_unix_remote_device_to_already_loaded_configuration
from moler.device import DeviceFactory
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB012365.resources.SAS_messages_exeptions import \
    TooFewMessagesFoundException, MessageNotFoundException, TooManyMessagesFoundException, WrongParameterValueException


class SASsim:
    sas_dir = 'SASSim'
    sas_config = 'SAS_Sim.conf'
    sas_log = 'SAS_Sim.log'
    sas_user = tl.test_pcs[1].default_ssh_connection_details.username
    sas_pass = tl.test_pcs[1].default_ssh_connection_details.password
    sas_addr = tl.test_pcs[1].default_ssh_connection_details.addr
    vm_user = tl.test_pcs[0].default_ssh_connection_details.username
    vm_pass = tl.test_pcs[0].default_ssh_connection_details.password
    vm_addr = tl.test_pcs[0].default_ssh_connection_details.addr
    vm_tmp_dir = '/tmp'

    @load_moler_configuration_from_tl()
    def get_sas_vm_as_device(self):
        return self.get_vm_as_device(device_name='SAS_VM', device_addr=self.sas_addr, device_user=self.sas_user,
                                     device_pass=self.sas_pass)

    @load_moler_configuration_from_tl()
    def get_tl_vm_as_device(self):
        return self.get_vm_as_device(device_name='UnixLocal', device_addr=self.vm_addr, device_user=self.vm_user,
                                     device_pass=self.vm_pass)

    @staticmethod
    def get_vm_as_device(device_name, device_addr, device_user, device_pass):
        try:
            device = DeviceFactory.get_device(name=device_name)
        except KeyError:
            add_unix_remote_device_to_already_loaded_configuration(
                device_name=device_name,
                host=device_addr,
                login=device_user,
                password=device_pass
            )
            device = DeviceFactory.get_device(name=device_name)
        return device

    def start_sas_sim(self):
        sas = self.get_sas_vm_as_device()
        stop_sas = sas.get_cmd(cmd_name='run_script', cmd_params={'script_command': 'pkill -f "python3 SAS_Sim.py"'})
        stop_sas()
        venv_activate_cmd = 'source ~/SASSim/SASsim_venv/bin/activate'
        venv_activate = sas.get_cmd(cmd_name='run_script', cmd_params={'script_command': venv_activate_cmd})
        venv_activate()
        start_sas_cmd = 'cd {} && nohup python3 SAS_Sim.py &'.format(self.sas_dir)
        start_sas = sas.get_cmd(cmd_name='run_script', cmd_params={'script_command': start_sas_cmd})
        start_sas()

    def stop_sas_sim(self):
        sas = self.get_sas_vm_as_device()
        stop_sas = sas.get_cmd(cmd_name='run_script', cmd_params={'script_command': 'pkill -f "python3 SAS_Sim.py"'})
        stop_sas()

    def upload_new_config(self, config_path):
        vm = self.get_tl_vm_as_device()
        copy_sas_config = vm.get_cmd(cmd_name='scp', cmd_params={'source': '{}'.format(config_path),
                                                                 'dest': '{}@{}:{}/{}'.format(self.sas_user,
                                                                                              self.sas_addr,
                                                                                              self.sas_dir,
                                                                                              self.sas_config),
                                                                 'password': '{}'.format(self.sas_pass)})
        copy_sas_config()
        new_config = re.findall("[A-Z0-9_-]*SAS_Sim.conf", config_path)[0]
        logging.warning("New config file was uploaded to SASsim: {}".format(new_config))

    def get_sas_sim_log(self):
        vm = self.get_tl_vm_as_device()
        copy_sas_log = vm.get_cmd(cmd_name='scp', cmd_params={'source': '{}@{}:{}/{}'.format(self.sas_user,
                                                                                             self.sas_addr,
                                                                                             self.sas_dir,
                                                                                             self.sas_log),
                                                              'dest': '{}'.format(self.vm_tmp_dir),
                                                              'password': '{}'.format(self.vm_pass)})
        copy_sas_log()
        with open('{}/{}'.format(self.vm_tmp_dir, self.sas_log)) as sas_log:
            logging.info(">>>>> Full content of 'SAS_Sim.log':\n{}".format(sas_log.read()))

    def find_messages_in_sas_sim_log(self, message_type, expected_messages_num=None):
        messages = list()
        with open('{}/{}'.format(self.vm_tmp_dir, self.sas_log)) as sas_log:
            for line in sas_log:
                if line.__contains__(message_type):
                    messages.append(json.loads(line.strip()))
        self.check_if_correct_num_of_messages_found_in_sas_sim_log(messages_list_from_log=messages,
                                                                   message_type=message_type,
                                                                   expected_messages_num=expected_messages_num)
        return messages

    def check_if_correct_num_of_messages_found_in_sas_sim_log(self, messages_list_from_log, message_type,
                                                              expected_messages_num=None):
        if len(messages_list_from_log) == 0:
            raise MessageNotFoundException("No message of type '{}' was found in {}".format(message_type,
                                                                                            self.sas_log))
        if expected_messages_num:
            if len(messages_list_from_log) > int(expected_messages_num):
                raise TooManyMessagesFoundException(
                    "More than expected messages of type '{}' was found in {}. Expected: {}, "
                    "but found: {}".format(message_type, self.sas_log, expected_messages_num,
                                           len(messages_list_from_log)))
            if len(messages_list_from_log) < int(expected_messages_num):
                raise TooFewMessagesFoundException(
                    "Less than expected messages of type '{}' was found in {}. Expected: {}, "
                    "but found: {}".format(message_type, self.sas_log, expected_messages_num,
                                           len(messages_list_from_log)))

    def get_specific_message_from_sas_sim_log(self, message_type, message_num, expected_messages_num=None):
        messages = self.find_messages_in_sas_sim_log(message_type=message_type,
                                                     expected_messages_num=expected_messages_num)
        if len(messages) < int(message_num):
            raise MessageNotFoundException("There's only {} message(s) of type '{}' in {}, but you're looking for "
                                           "message number {}".format(len(messages), message_type, self.sas_log,
                                                                      message_num))
        message = messages[int(message_num) - 1][message_type]
        return message

    def verify_grant_request_message(self, grant_request_msg, channel_type, cbsd_id, group_id, group_type,
                                     meas_report_elements,
                                     max_eirp_accepted, high_freq, low_freq):
        wrong_params = dict()
        grant_request = self.message_for_grant(channel_type=channel_type, full_message=grant_request_msg)
        if cbsd_id != grant_request['cbsdId']:
            wrong_params.update({'cbsdId': {'expected': cbsd_id, 'actual': grant_request['cbsdId']}})
        if group_id != grant_request['groupingParam'][0]['groupId']:
            wrong_params.update({'groupId': {'expected': group_id,
                                             'actual': grant_request['groupingParam'][0]['groupId']}})
        if group_type != grant_request['groupingParam'][0]['groupType']:
            wrong_params.update({'groupType': {'expected': group_type,
                                               'actual': grant_request['groupingParam'][0]['groupType']}})
        meas_report = grant_request['measReport']['rcvdPowerMeasReports']
        if len(meas_report) != int(meas_report_elements):
            wrong_params.update({'measReport': {'expected': '{} elements'.format(meas_report_elements),
                                                'actual': '{} elements'.format(len(meas_report))}})
        max_eirp = float(grant_request['operationParam']['maxEirp'])
        if max_eirp < float(max_eirp_accepted):
            wrong_params.update({'maxEirp': {'expected': '{} or above'.format(max_eirp_accepted),
                                             'actual': '{}'.format(max_eirp)}})
        high_frequency = grant_request['operationParam']['operationFrequencyRange']['highFrequency']
        if int(high_freq) != high_frequency:
            wrong_params.update({'highFrequency': {'expected': high_freq, 'actual': high_frequency}})
        low_frequency = grant_request['operationParam']['operationFrequencyRange']['lowFrequency']
        if int(low_freq) != low_frequency:
            wrong_params.update({'lowFrequency': {'expected': low_freq, 'actual': low_frequency}})
        self.raise_exception_if_wrong_parameter_values(wrong_params_dict=wrong_params, message_type='grantRequest',
                                                       channel_type=channel_type)

    @staticmethod
    def raise_exception_if_wrong_parameter_values(wrong_params_dict, message_type, channel_type):
        if len(wrong_params_dict) > 0:
            raise WrongParameterValueException(
                "Parameters for {} channels in '{}' message have different values than expected. Total number of wrong"
                " params: {}\n{}".format(channel_type, message_type, len(wrong_params_dict), wrong_params_dict))

    def verify_grant_response_message(self, grant_response_msg, cbsd_id, grant_id, channel_type, response_code,
                                      response_message):
        wrong_params = dict()
        grant_response = self.message_for_grant(channel_type=channel_type, full_message=grant_response_msg)
        if cbsd_id != grant_response['cbsdId']:
            wrong_params.update({'cbsdId': {'expected': cbsd_id, 'actual': grant_response['cbsdId']}})
        if grant_id != grant_response['grantId']:
            wrong_params.update({'grantId': {'expected': grant_id, 'actual': grant_response['grantId']}})
        if channel_type != grant_response['channelType']:
            wrong_params.update({'channelType': {'expected': channel_type, 'actual': grant_response['channelType']}})
        if int(response_code) != grant_response['response']['responseCode']:
            wrong_params.update({'responseCode': {'expected': response_code,
                                                  'actual': grant_response['response']['responseCode']}})
        if response_message != grant_response['response']['responseMessage']:
            wrong_params.update({'responseMessage': {'expected': response_message,
                                                     'actual': grant_response['response']['responseMessage']}})
        heartbeat_interval = grant_response['heartbeatInterval']
        if heartbeat_interval and not isinstance(heartbeat_interval, int):
            wrong_params.update({'heartbeatInterval': {'expected': '0 or above (optional)',
                                                       'actual': heartbeat_interval}})
        grant_expire_time = grant_response['grantExpireTime']
        try:
            datetime.datetime.strptime(grant_expire_time, "%Y-%m-%dT%H:%M:%SZ")
        except ValueError:
            wrong_params.update({'grantExpireTime': {'expected': 'Date in format YYYY-MM-DD  hh:mm:ss '
                                                                 '(i.e. 2024-06-17T08:35:45Z))',
                                                     'actual': grant_expire_time}})
        self.raise_exception_if_wrong_parameter_values(wrong_params_dict=wrong_params, message_type='grantResponse',
                                                       channel_type=channel_type)

    def verify_heartbeat_request_message(self, heartbeat_request_msg, channel_type, cbsd_id, grant_id, group_id,
                                         group_type, meas_report_elements, operation_state):
        wrong_params = dict()
        heartbeat_request = self.message_for_grant(channel_type=channel_type, full_message=heartbeat_request_msg)
        if cbsd_id != heartbeat_request['cbsdId']:
            wrong_params.update({'cbsdId': {'expected': cbsd_id, 'actual': heartbeat_request['cbsdId']}})
        if grant_id != heartbeat_request['grantId']:
            wrong_params.update({'grantId': {'expected': grant_id, 'actual': heartbeat_request['grantId']}})
        if group_id != heartbeat_request['groupingParam'][0]['groupId']:
            wrong_params.update({'groupId': {'expected': group_id,
                                             'actual': heartbeat_request['groupingParam'][0]['groupId']}})
        if group_type != heartbeat_request['groupingParam'][0]['groupType']:
            wrong_params.update({'groupType': {'expected': group_type,
                                               'actual': heartbeat_request['groupingParam'][0]['groupType']}})
        meas_report = heartbeat_request['measReport']['rcvdPowerMeasReports']
        if len(meas_report) != int(meas_report_elements):
            wrong_params.update({'measReport': {'expected': '{} elements'.format(meas_report_elements),
                                                'actual': '{} elements'.format(len(meas_report))}})
        if operation_state != heartbeat_request['operationState']:
            wrong_params.update({'operationState': {'expected': operation_state,
                                                    'actual': heartbeat_request['operationState']}})
        self.raise_exception_if_wrong_parameter_values(wrong_params_dict=wrong_params, message_type='heartbeatRequest',
                                                       channel_type=channel_type)

    def verify_heartbeat_response_message(self, heartbeat_response_msg, channel_type, cbsd_id, grant_id, response_code,
                                          response_message):
        wrong_params = dict()
        heartbeat_response = self.message_for_grant(channel_type=channel_type, full_message=heartbeat_response_msg)
        if cbsd_id != heartbeat_response['cbsdId']:
            wrong_params.update({'cbsdId': {'expected': cbsd_id, 'actual': heartbeat_response['cbsdId']}})
        if grant_id != heartbeat_response['grantId']:
            wrong_params.update({'grantId': {'expected': grant_id, 'actual': heartbeat_response['grantId']}})
        if int(response_code) != heartbeat_response['response']['responseCode']:
            wrong_params.update({'responseCode': {'expected': response_code,
                                                  'actual': heartbeat_response['response']['responseCode']}})
        if response_message != heartbeat_response['response']['responseMessage']:
            wrong_params.update({'responseMessage': {'expected': response_message,
                                                     'actual': heartbeat_response['response']['responseMessage']}})
        grant_expire_time = heartbeat_response['grantExpireTime']
        try:
            datetime.datetime.strptime(grant_expire_time, "%Y-%m-%dT%H:%M:%SZ")
        except ValueError:
            wrong_params.update({'grantExpireTime': {'expected': 'Date in format YYYY-MM-DD hh:mm:ss '
                                                                 '(i.e. 2024-06-17T08:35:45Z))',
                                                     'actual': grant_expire_time}})
        transmit_expire_time = heartbeat_response['grantExpireTime']
        try:
            datetime.datetime.strptime(transmit_expire_time, "%Y-%m-%dT%H:%M:%SZ")
        except ValueError:
            wrong_params.update({'grantExpireTime': {'expected': 'Date in format YYYY-MM-DD hh:mm:ss '
                                                                 '(i.e. 2024-06-17T08:35:45Z))',
                                                     'actual': transmit_expire_time}})
        self.raise_exception_if_wrong_parameter_values(wrong_params_dict=wrong_params, message_type='grantResponse',
                                                       channel_type=channel_type)

    def verify_response_message_with_failure(self, response_msg, message_type, channel_type, cbsd_id, response_code,
                                             response_message, grant_id=None):
        wrong_params = dict()
        grant_response = self.message_for_grant(channel_type=channel_type, full_message=response_msg)
        if cbsd_id != grant_response['cbsdId']:
            wrong_params.update({'cbsdId': {'expected': cbsd_id, 'actual': grant_response['cbsdId']}})
        if grant_id:
            if grant_id != grant_response['grantId']:
                wrong_params.update({'grantId': {'expected': grant_id, 'actual': grant_response['grantId']}})
        if int(response_code) != grant_response['response']['responseCode']:
            wrong_params.update({'responseCode': {'expected': response_code,
                                                  'actual': grant_response['response']['responseCode']}})
        if response_message != grant_response['response']['responseMessage']:
            wrong_params.update({'responseMessage': {'expected': response_message,
                                                     'actual': grant_response['response']['responseMessage']}})
        self.raise_exception_if_wrong_parameter_values(wrong_params_dict=wrong_params, message_type=message_type,
                                                       channel_type=channel_type)

    def verify_relinquishment_message(self, relinquishment_msg, message_type, channel_type, cbsd_id, grant_id,
                                      response_code=None, response_message=None):
        wrong_params = dict()
        if cbsd_id != relinquishment_msg[0]['cbsdId']:
            wrong_params.update({'cbsdId': {'expected': cbsd_id, 'actual': relinquishment_msg[0]['cbsdId']}})
        if grant_id != relinquishment_msg[0]['grantId']:
            wrong_params.update({'grantId': {'expected': grant_id, 'actual': relinquishment_msg[0]['grantId']}})
        if message_type == "relinquishmentResponse":
            if int(response_code) != relinquishment_msg[0]['response']['responseCode']:
                wrong_params.update({'responseCode': {'expected': response_code,
                                                      'actual': relinquishment_msg[0]['response']['responseCode']}})
            if response_message != relinquishment_msg[0]['response']['responseMessage']:
                wrong_params.update({'responseMessage': {'expected': response_message,
                                                         'actual': relinquishment_msg[0]['response']['responseMessage']
                                                         }})
        self.raise_exception_if_wrong_parameter_values(wrong_params_dict=wrong_params, message_type=message_type,
                                                       channel_type=channel_type)

    @staticmethod
    def message_for_grant(channel_type, full_message):
        if channel_type == 'PAL':
            message = full_message[0]
        elif channel_type == 'GAA':
            message = full_message[1]
        return message

# -*- coding: utf-8 -*-
from . import SAS_Manager
import os
import re
import json
import types
import sys
import time
import ConfigParser
from ute_common_store import Store
from cStringIO import StringIO
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from lte4679_SASserver import SASserver

conPath = os.path.dirname(os.path.realpath(__file__))
caseRootPath = os.path.dirname(conPath)
# sys.path.append(caseRootPath)


SAS_SIM_DEF_CFG = caseRootPath + "/SASSim/SAS_Sim.conf"


def _print_to_var(function):
    """
    Non-keyword method
    Decorator redirects output to variable

    :param      function
    :return:    lprint_to_var_wrapper
    """

    def print_to_var_wrapper(self, *args, **kwargs):
        old_stdout = sys.stdout
        sys.stdout = var_stdout = StringIO()
        function(self, *args, **kwargs)
        info = var_stdout.getvalue()
        sys.stdout = old_stdout
        logger.warn("SAS_Manager output: {}".format(info))
        if info.find('fail') >= 0 or info.find('error') >= 0:
            raise Exception("Error: {}".format(info))
        return info

    return print_to_var_wrapper


def _print_to_dict(function):
    """
    Non-keyword method
    Decorator redirects output to variable

    :param      function
    :return:    lprint_to_var_wrapper
    """

    def print_to_var_wrapper(self, *args, **kwargs):
        old_stdout = sys.stdout
        sys.stdout = var_stdout = StringIO()
        function(self, *args, **kwargs)
        info = var_stdout.getvalue()
        l_info = info.split('\n')
        d_info = {}
        lparsed_info = []
        key, value = l_info[0].split(': ')
        d_info[key] = value
        for item in l_info:
            if item == '':
                break
            level = _indent_level(item) / 4
            item = item.lstrip(' ')
            try:
                name, value = item.split(': ')
            except Exception:
                name = item
                value = ''
            lparsed_info.append(dict(name=name, value=value, level=level))
        d_info = _ttree_to_json(lparsed_info)
        sys.stdout = old_stdout
        logger.warn("SAS_Manager output: {}".format(d_info))
        if info.find('fail') >= 0 or info.find('error') >= 0:
            raise Exception("Error: {}".format(info))
        return d_info

    return print_to_var_wrapper


def _ttree_to_json(ttree, level=0):
    result = {}
    for i in range(0, len(ttree)):
        cn = ttree[i]
        try:
            nn = ttree[i + 1]
        except Exception:
            nn = {'level': -1}

        # Edge cases
        if cn['level'] > level:
            continue
        if cn['level'] < level:
            return result

        # Recursion
        if nn['level'] == level:
            dict_insert_or_append(result, cn['name'], cn['value'])
        elif nn['level'] > level:
            rr = _ttree_to_json(ttree[i + 1:], level=nn['level'])
            dict_insert_or_append(result, cn['name'], rr)
        else:
            dict_insert_or_append(result, cn['name'], cn['value'])
            return result
    return result


def _indent_level(astr):
    """Count number of leading spaces in a string
    """
    return len(astr) - len(astr.lstrip(' '))


def dict_insert_or_append(adict, key, val):
    """Insert a value in dict at key if one does not exist
    Otherwise, convert value to list and append
    """
    if key in adict:
        if type(adict[key]) != list:
            adict[key] = [adict[key]]
        adict[key].append(val)
    else:
        adict[key] = val


class lte4679_SASsimInterface(object):
    def __init__(self):
        self.store = Store()

    def start_SAS_server(self, config_name="", **kwargs):
        # currentPath = os.getcwd()
        # sas_server_path = currentPath + "/testsuite/WMP/OAM/LTE3663/SASSim"
        currentPath = os.path.split(os.path.realpath(__file__))[0]
        sas_server_path = currentPath
        if config_name == "":
            config_name = sas_server_path + "/SAS_Sim.conf"
        serverInstance = SASserver(config_name, sas_server_path)
        self.store.add(serverInstance, alias=kwargs.get('alias'))
        self.store.get(alias=kwargs.get('alias')).start_service()
        os.chdir(os.getcwd())

    def kill_process_for_SAS_server(self, **kwargs):
        self.store.get(alias=kwargs.get('alias')).kill_service()
        self.store.remove(alias=kwargs.get('alias'))

    def check_registrationRequest_message(self, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).check_registrationRequest_message()

    def check_registrationResponse_message(self, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).check_registrationResponse_message()

    def check_spectrumInquiryRequest_message(self, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).check_spectrumInquiryRequest_message()

    def check_spectrumInquiryResponse_message(self, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).check_spectrumInquiryResponse_message()

    def check_heartbeatRequest_message(self, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).check_heartbeatRequest_message()

    def check_heartbeatResponse_message(self, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).check_heartbeatResponse_message()

    def check_spectrumGrantRequest_message(self, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).check_spectrumGrantRequest_message()

    def check_spectrumGrantResponse_message(self, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).check_spectrumGrantResponse_message()

    def check_tls_connection(self, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).check_tls_connection()

    def prepare_to_check_message(self, **kwargs):
        self.store.get(alias=kwargs.get('alias')).prepare_to_check_message()

    def find_message(self, messageTag, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).find_message(messageTag)

    def count_message(self, messageTag, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).count_message(messageTag)

    def end_to_check(self, **kwargs):
        self.store.get(alias=kwargs.get('alias')).end_to_check()

    #############################

    def get_keyvalue_on_dict(self, dict, objKey, default=None):
        tempDir = dict
        for key, value in tempDir.items():
            print(key + "----" + value + "\n")
            if key == objKey:
                return value
            else:
                if isinstance(value, dict):
                    result = get_keyvalue_on_dict(value, objKey)
                    if result is not default:
                        return result
        return default

    def check_frequency_in_sas(self, frequency, value):
        for low, hight in frequency:
            if value >= low and value <= high:
                return True
        return False

    ############################

    @_print_to_dict
    def sas_manager_get_cbsd_info(self):
        SAS_Manager.cbsd_func()

    @_print_to_var
    def sas_manager_get_blacklist_info(self):
        SAS_Manager.blist_func()

    @_print_to_var
    def sas_manager_add_to_blacklist(self, cbsd_id='1'):
        SAS_Manager.blist_add_func(cbsd_id)

    @_print_to_var
    def sas_manager_del_from_blacklist(self, cbsd_id='1'):
        SAS_Manager.blist_del_func(cbsd_id)

    @_print_to_var
    def sas_manager_grant_suspend(self, cbsd_id='1', grant_id='1'):
        SAS_Manager.grant_suspend_func(cbsd_id, grant_id)

    @_print_to_var
    def sas_manager_grant_terminate(self, cbsd_id='1', grant_id='1'):
        SAS_Manager.grant_terminate_func(cbsd_id, grant_id)

    @_print_to_var
    def sas_manager_grant_free(self, cbsd_id='1', grant_id='1'):
        SAS_Manager.grant_free_func(cbsd_id, grant_id)

    @_print_to_var
    def sas_manager_grant_renew_enable(self):
        SAS_Manager.grant_renew_func(True)

    @_print_to_var
    def sas_manager_grant_renew_disable(self):
        SAS_Manager.grant_renew_func(False)

    @_print_to_var
    def sas_manager_transmit_renew_enable(self):
        SAS_Manager.transmit_renew_func(True)

    @_print_to_var
    def sas_manager_transmit_renew_disable(self):
        SAS_Manager.transmit_renew_func(False)

    @_print_to_var
    def sas_manager_get_server_version(self):
        SAS_Manager.version_func()

    @_print_to_var
    def sas_manager_server_configuration(self, server_ip, server_port=4433):
        SAS_Manager.server_conf_func(server_ip, server_port)

    @_print_to_var
    def sas_manager_update_option_blocked_request(self, messageTag):
        SAS_Manager.update_option_blocked_request_func(messageTag)

    @_print_to_var
    def sas_manager_update_option_connection_reject(self, ipaddr):
        SAS_Manager.update_option_connection_reject_func(ipaddr)

    @staticmethod
    def load_variables_from_sas_config(sas_sim_conf_file=SAS_SIM_DEF_CFG):
        """
        SPHINX_IGNORE:
        [Documentation] KEYWORD:Load Variables from SAS Sim config
        Metadata:
        | Version | Status  | Date | Author  | Change Notification |
        | 0.1 | DRAFT | 10.05.2017 | Karol Pasek | Init |
        | 0.2 | DRAFT | 19.05.2017 | Karol Pasek | Documentation added |
        | 0.3 | READY_FOR_REVIEW | 24.05.2017 | Karol Pasek | Review request 166 |
        End of Metadata

        Tags:
        RL17SP    TDD    FZM    FZP
        End of Tags
        SPHINX_IGNORE

        Keyword is responsible for reading variables from SAS sim config and loading to Robot as a Test Variables

        :param sas_sim_conf_file:       Path to SAS simulator cfg file
        :return:                        None
        """
        method_reg = 'registration'
        method_dereg = 'deregistration'
        method_inquiry = 'spectruminquiry'
        method_grant = 'grant'
        method_heartbeat = 'heartbeat'
        method_relinquish = 'relinquishment'
        sas_method_t = (method_reg,
                        method_dereg,
                        method_inquiry,
                        method_grant,
                        method_heartbeat,
                        method_relinquish)
        sec = 'conf'
        try:
            config = ConfigParser.ConfigParser()
            config.read(sas_sim_conf_file)
            if config.has_option(sec, 'log_file_name'):
                log_file = config.get(sec, 'log_file_name')
                BuiltIn().set_test_variable("${SAS_LOG_FILE}", log_file)
            logger.debug('reading configuration from SAS_Sim.conf ...')
            if config.has_option(sec, 'port_number'):
                port_num = config.getint(sec, 'port_number')
                logger.debug('service port is configured to %d' % port_num)
                BuiltIn().set_test_variable("${SAS_PORT_NUM}", port_num)
            if config.has_option(sec, 'key_file_name'):
                key_file = config.get(sec, 'key_file_name')
                logger.debug('key file is configured to %s' % key_file)
                BuiltIn().set_test_variable("${SAS_KEY_FILE}", key_file)
            if config.has_option(sec, 'cert_file_name'):
                cert_file = config.get(sec, 'cert_file_name')
                logger.debug('certificate file is configured to %s' % cert_file)
                BuiltIn().set_test_variable("${SAS_CERT_FILE}", cert_file)
            if config.has_option(sec, 'tls_connection'):
                tls_con = config.getboolean(sec, 'tls_connection')
                logger.debug('tls_connection is configured to %s' % tls_con)
                BuiltIn().set_test_variable("${SAS_CONNECT_MODE_TLS}", tls_con)
            if config.has_option(sec, 'heart_beat'):
                heart_beat_dur = config.getint(sec, 'heart_beat')
                logger.debug('heartbeat duration is configured to %d' % heart_beat_dur)
                BuiltIn().set_test_variable("${SAS_HEART_BEAT_DUR}", heart_beat_dur)
            if config.has_option(sec, 'grant_exp'):
                grant_exp_dur = config.getint(sec, 'grant_exp')
                logger.debug('grant duration is configured to %d' % grant_exp_dur)
                BuiltIn().set_test_variable("${SAS_GRANT_EXP_DUR}", grant_exp_dur)
            if config.has_option(sec, 'transmit_exp'):
                transmit_exp_dur = config.getint(sec, 'transmit_exp')
                logger.debug('transmit duration is configured to %d' % transmit_exp_dur)
                BuiltIn().set_test_variable("${SAS_TRANSMIT_EXP_DUR}", transmit_exp_dur)
            if config.has_option(sec, 'disapprove_grant'):
                grant_disapprove_reassign = config.getboolean(sec, 'disapprove_grant')
                logger.debug('disapprove_grant is configured to %s' % grant_disapprove_reassign)
                BuiltIn().set_test_variable("${SAS_GRANT_DISAPPROVE_REASSIGN}", grant_disapprove_reassign)
            if config.has_option(sec, 'suspend_grant'):
                grant_suspend = config.getboolean(sec, 'suspend_grant')
                logger.debug('suspend_grant is configured to %s' % grant_suspend)
                BuiltIn().set_test_variable("${SAS_GRANT_SUSPEND}", grant_suspend)
            if config.has_option(sec, 'terminate_grant'):
                grant_terminate = config.getboolean(sec, 'terminate_grant')
                logger.debug('terminate_grant is configured to %s' % grant_terminate)
                BuiltIn().set_test_variable("${SAS_GRANT_TERMINATE}", grant_terminate)
            if config.has_option(sec, 'suspended_reassign'):
                suspended_reassign = config.getboolean(sec, 'suspended_reassign')
                logger.debug('suspended_reassign is configured to %s' % suspended_reassign)
                BuiltIn().set_test_variable("${SAS_SUSPENDED_REASSIGN}", suspended_reassign)
            if config.has_option(sec, 'terminated_reassign'):
                terminated_reassign = config.getboolean(sec, 'terminated_reassign')
                logger.debug('terminated_reassign is configured to %s' % terminated_reassign)
                BuiltIn().set_test_variable("${SAS_TERMINATED_REASSIGN}", terminated_reassign)
            if config.has_option(sec, 'renew_grant'):
                renew_grant = config.getboolean(sec, 'renew_grant')
                logger.debug('renew_grant is configured to %s' % renew_grant)
                BuiltIn().set_test_variable("${SAS_RENEW_GRANT}", renew_grant)
            if config.has_option(sec, 'renew_transmit'):
                renew_transmit = config.getboolean(sec, 'renew_transmit')
                logger.debug('renew_transmit is configured to %s' % renew_transmit)
                BuiltIn().set_test_variable("${SAS_RENEW_TRANSMIT}", renew_transmit)
            if config.has_option(sec, 'recommend_max_eirp'):
                max_eirp_reassign = config.getint(sec, 'recommend_max_eirp')
                logger.debug('recommended maxEirp is configured to %d' % max_eirp_reassign)
                BuiltIn().set_test_variable("${SAS_MAX_EIRP_REASSIGN}", max_eirp_reassign)
            if config.has_option(sec, 'recommend_low_freq'):
                freq_low_reassign = config.getint(sec, 'recommend_low_freq')
                logger.debug('recommended lowFrequency is configured to %d' % freq_low_reassign)
                BuiltIn().set_test_variable("${SAS_FREQ_LOW_REASSIGN}", freq_low_reassign)
            if config.has_option(sec, 'recommend_high_freq'):
                freq_high_reassign = config.getint(sec, 'recommend_high_freq')
                logger.debug('recommended highFrequency is configured to %d' % freq_high_reassign)
                BuiltIn().set_test_variable("${SAS_FREQ_HIGH_REASSIGN}", freq_high_reassign)
            if config.has_option(sec, 'blocked_request'):
                blocked_request = config.get(sec, 'blocked_request')
                if blocked_request in sas_method_t:
                    logger.debug('blocked_request is configured to %s' % blocked_request)
                    BuiltIn().set_test_variable("${SAS_BLOCKED_REQUEST}", blocked_request)
                else:
                    logger.debug('invalid config value for blocked_request')
            if config.has_option(sec, 'force_sas_method'):
                method = config.get(sec, 'force_sas_method')
                if method in sas_method_t:
                    logger.debug('force_sas_method is configured to %s' % method)
                    BuiltIn().set_test_variable("${SAS_METHOD_FORCE}", method)
                    if config.has_option(sec, 'force_response_code'):
                        response_code_force = config.getint(sec, 'force_response_code')
                        logger.debug('force_response_code is configured to %d' % response_code_force)
                        BuiltIn().set_test_variable("${SAS_RESPONSE_CODE_FORCE}", response_code_force)
                    if config.has_option(sec, 'force_response_data'):
                        response_data_force = config.get(sec, 'force_response_data')
                        logger.debug('force_response_data is configured to %s' % response_data_force)
                        BuiltIn().set_test_variable("${SAS_RESPONSE_DATA_FORCE}", response_data_force)
                    if config.has_option(sec, 'force_exclude_param'):
                        exclude_param_force = config.get(sec, 'force_exclude_param')
                        logger.debug('force_exclude_param is configured to %s' % exclude_param_force)
                        BuiltIn().set_test_variable("${SAS_EXCLUDE_PARAM_FORCE}", exclude_param_force)
                    if config.has_option(sec, 'force_responseCode_invalid'):
                        response_code_invalid_force = config.getboolean(sec, 'force_responseCode_invalid')
                        logger.debug('force_responseCode_invalid is configured to %s' % response_code_invalid_force)
                        BuiltIn().set_test_variable("${SAS_RESPONSE_CODE_INVALID_FORCE}", response_code_invalid_force)
                else:
                    logger.debug('invalid config value for force_sas_method')
        except ConfigParser.MissingSectionHeaderError:
            logger.debug('missing section header in config file. using default configuration.')
        except ConfigParser.Error:
            logger.debug('parsing config file failed. using default configuration.')
        except ValueError:
            logger.debug('parsing config file failed. could not convert data to a specified type.')
        except Exception:
            logger.debug('parsing config file failed. unexpected error.')

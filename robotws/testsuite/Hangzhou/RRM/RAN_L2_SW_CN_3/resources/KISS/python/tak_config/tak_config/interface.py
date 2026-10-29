# -*- coding: utf-8 -*-
"""
:created on: 21-03-2017

:copyright: Nokia
:author: leo wang
:contact: leo.y.wang@nokia.com
"""

import glob
import socket
import os
import sys
import time
from ta_kiss_core.logger import Logger
from robot.libraries.BuiltIn import BuiltIn
from .exception import KissConfigException
from ute_common_validator.validator import Or, IsIpAddress, IsNotEmpty, IsInstance, InRange
from ute_testline_configuration.ute_config import UTE_CONFIG, GROUP_CONFIG
from ute_testline_configuration.schemas.transport import TrsSchemas
from ute_common_config.config import Config


class ta_testline_names(object):
    """for get testline site name and host name.
    """
    def __init__(self, testline_configuration_path="/home/ute/robotlte/"):
        self.logger = Logger()
        self._robot_repo_path = testline_configuration_path
        self._5g_robot_repo_path = "/home/ute/Auto5G/"
        self._robotlte_path = "/home/ute/robotlte/"
        self._testline_config_path = "/home/ute/testline_configuration/"
        self.host_name = ""
        self.host_name_in_config = ""
        self.site_name = ""
        self.config_full_path = ""

    def _search_path(self, config_path):
        sep = os.path.sep
        single_line_host_name_in_config = self.host_name.replace("-", "_")
        host_name_split_list = single_line_host_name_in_config.split('_')
        multi_line_host_name_in_config = '_'.join(host_name_split_list[:-1])
        for _host_name_in_config in (self.host_name, single_line_host_name_in_config, multi_line_host_name_in_config):
            ret = glob.glob("{}{}{}".format(config_path, sep, _host_name_in_config))
            if ret and len(ret) == 1:
                self.config_full_path = ret
                self.host_name_in_config = _host_name_in_config
                return ret

    def _serach_path_and_add_to_path(self, config_path, path):
        ret = self._search_path(config_path)
        if ret:
            sys.path.append(path)
            return True
        else:
            return False

    def _search_config_full_path(self):
        self.host_name = self.get_testline_host_name()
        sep = os.path.sep
        for _path in (self._robot_repo_path, self._5g_robot_repo_path):
            if self._robot_repo_path != self._testline_config_path:
                config_path = os.path.join(_path, "config{}*".format(sep))
            else:
                config_path = _path
            if self._serach_path_and_add_to_path(config_path, _path):
                break
        else:
            config_path = os.path.join(self._robotlte_path, "config{}*".format(sep))
            self._serach_path_and_add_to_path(config_path, self._robotlte_path)

    def get_testline_site_name(self):
        """this keyword used to get testline site name
        """
        sep = os.path.sep
        self._search_config_full_path()
        if self.config_full_path:
            self.site_name = self.config_full_path[0].split(sep)[-2]
            return self.site_name
        else:
            raise KissConfigException("No \"{}\" testline config file is found!".format(self.host_name_in_config))

    def get_testline_host_name(self):
        """this keyword used to get testline host name
        """
        host_name = socket.gethostname()
        self.logger.debug("CLOUD TEST LINE NAME:{}".format(host_name))
        return host_name


class configuration(object):
    """Set configuration name to ${CONFIGURATION}, the format is testLineSiteName.hostName, such as Shanghai.IAV-SH-TBR.
    """
    def __init__(self, testline_configuration_path="/home/ute/robotlte/"):
        self.logger = Logger()
        self.configuration_name = ""
        self.configer = ta_testline_names(testline_configuration_path)

    def __str__(self):
        self._get_configuration()
        self._set_configuration()
        return self.configuration_name

    def _get_configuration(self):
        try:
            BuiltIn().variable_should_exist("${CONFIGURATION}")
            self.configuration_name = BuiltIn().get_variable_value("${CONFIGURATION}")
        except Exception as e:
            self.configer.get_testline_site_name()
            self.configuration_name = "{}.{}".format(self.configer.site_name, self.configer.host_name_in_config)
            self.logger.debug("GET CONFIGURATION EXCEPTION: %s" + str(e))

    def _set_configuration(self):
        BuiltIn().set_global_variable("${CONFIGURATION}", self.configuration_name)


class log_directory(object):
    """Create log directory
    """
    time_stamp = time.strftime("%Y%m%d%H%M%S", time.localtime())

    def __init__(self):
        self.logger = Logger()
        self.suite_name = ""
        self.test_name = ""
        self.output_dir = ""
        self.log_save_path = "/tmp/log_save_path"

    def __str__(self):
        """create and return the log save path
        """
        self._get_suite_name()
        self._get_test_case_name()
        self.output_dir = self._get_robot_variable_value('OUTPUT_DIR')
        self._indicate_log_save_path()
        return self._create_log_save_path()

    def _create_log_save_path(self):
        """create the log saved path
        """
        if not os.path.exists(self.log_save_path):
            os.makedirs(self.log_save_path)
        return self.log_save_path

    def _indicate_log_save_path(self):
        """this keyword need implement by subclass
        """
        pass

    def _make_dir(self, path):
        """none
        """
        if not os.path.exists(path):
            os.makedirs(path)

    def _get_robot_variable_value(self, name):
        """none
        """
        try:
            ret = BuiltIn().get_variable_value('${%s}' % name)
            if not ret:
                ret = "default_kiss"
        except Exception as et:
            ret = "default_kiss"
            self.logger.debug("TEST_NAME EXCEPTION: %s" + str(et))
        finally:
            return ret.strip().replace(" ", "_")

    def _get_test_case_name(self):
        """get test case name
        """
        self.test_name = self._get_robot_variable_value('TEST_NAME')
        return self.test_name

    def _get_suite_name(self):
        """get test suite name
        """
        self.suite_name = self._get_robot_variable_value('SUITE_NAME')
        return self.suite_name


SUITE_ADD_CASE_NAME_MAX_LENGTH = 150


class test_log_dir(log_directory):
    """Create the test log directory for saving TA log. The test case log directory is under ${OUTPUT_DIR}/log/
    ${SUITE_NAME}_timestamp/${TEST_NAME}.
    If the character length of ${SUITE_NAME}_timestamp/${TEST_NAME} is greater than 150, only keep the first
    150 characters.
    """
    def _indicate_log_save_path(self):
        """Give the test log saved path for suite or test case, such as suite_timestamp/test_case_name
        """
        suite_name_with_timestamp = self.suite_name + "_" + test_log_dir.time_stamp
        sep = os.path.sep
        if self.test_name == "default_kiss":
            self.log_save_path = os.path.join(os.path.join(self.output_dir, "log"), suite_name_with_timestamp)
        else:
            path_result = glob.glob("{}{}{}{}{}".format(self.output_dir, sep, "log", sep, suite_name_with_timestamp))
            if path_result:
                self.log_save_path = os.path.join(path_result[0], self.test_name)
            else:
                self.log_save_path = os.path.join(os.path.join(os.path.join(self.output_dir, "log"),
                                                               suite_name_with_timestamp), self.test_name)
            max_path_length = len(self.output_dir+sep + "log" + sep) + SUITE_ADD_CASE_NAME_MAX_LENGTH
            if len(self.log_save_path) > max_path_length:
                self.log_save_path = self.log_save_path[:max_path_length]
        self.log_save_path += sep
        self.log_save_path = (self.log_save_path).replace('[', '_').replace(']', '_')
        self.logger.debug("Test Log Directory: %s", self.log_save_path)


class kiss_debug_log_dir(log_directory):
    """Create the test log directory for saving TA tool debug log. The test debug log directory is under
    ${OUTPUT_DIR}/log/${SUITE_NAME}_timestamp/${TEST_NAME}/kiss_debug_logs.
    """
    def _indicate_log_save_path(self):
        """Give the case log directory for saving TA tool debug log under the suite or test case log directory.
        """
        suite_name_with_timestamp = self.suite_name + "_" + kiss_debug_log_dir.time_stamp
        sep = os.path.sep
        if self.test_name == "default_kiss":
            path_result = glob.glob("{}{}{}{}{}".format(self.output_dir, sep, "log", sep, suite_name_with_timestamp))
            if path_result:
                self.log_save_path = os.path.join(path_result[0], "kiss_debug_logs")
            else:
                self.log_save_path = os.path.join(os.path.join(os.path.join(self.output_dir, "log"),
                                                               suite_name_with_timestamp), "kiss_debug_logs")
        else:
            case_name = self.test_name
            suite_add_case_name = suite_name_with_timestamp + sep + self.test_name
            if len(suite_add_case_name) > SUITE_ADD_CASE_NAME_MAX_LENGTH:
                suite_add_case_name = suite_add_case_name[:SUITE_ADD_CASE_NAME_MAX_LENGTH]
                case_name = suite_add_case_name.split(sep)[-1]
            suite_path_result = glob.glob("{}{}{}{}{}".format(self.output_dir, sep, "log", sep,
                                                              suite_name_with_timestamp))
            if suite_path_result:
                case_path_result = glob.glob("{}{}{}". format(suite_path_result[0], sep, case_name))
                self.log_save_path = os.path.join(case_path_result[0], "kiss_debug_logs") if case_path_result else os.\
                    path.join(os.path.join(suite_path_result[0], case_name), "kiss_debug_logs")
            else:
                self.log_save_path = os.path.join(os.path.join(os.path.join(os.path.join(self.output_dir, "log"),
                                                                            suite_name_with_timestamp), case_name),
                                                  "kiss_debug_logs")
        self.log_save_path += sep
        self.logger.debug("Kiss Debug Log Directory: %s", self.log_save_path)


class UE(Config):
    def __init__(self, addr='192.168.0.1', username='root', password='Si8a&2vV9', h_angle=0, v_angle=0):
        super(UE, self).__init__()

        self._set_attr('addr', addr, IsIpAddress())
        self._set_attr('username', username, IsNotEmpty())
        self._set_attr('password', password, IsNotEmpty())
        self._set_attr('h_angle', h_angle, InRange(-100, 100))
        self._set_attr('v_angle', v_angle, InRange(-100, 100))


class PA(Config):
    def __init__(self, addr='127.0.0.1', username='root', password='Si8a&2vV9'):
        super(PA, self).__init__()

        self._set_attr('addr', addr, IsIpAddress())
        self._set_attr('username', username, IsNotEmpty())
        self._set_attr('password', password, IsNotEmpty())


class TA_CONFIG(UTE_CONFIG):

    def __init__(self, host=None, fsm=None, iphy=None, rf=None, los=None, ue=None, pa=None, **self_defined_args):
        super(TA_CONFIG, self).__init__(host, fsm, iphy, rf, los, ue)
        VALIDATOR = Or(IsInstance(GROUP_CONFIG), IsInstance(type(None)), IsInstance(list), IsInstance(tuple))
        if pa is not None:
            pa = self._convert_to_tuple(pa)
            self._set_attr('pa', pa, VALIDATOR)
        if ue is not None:
            ue = self._convert_to_tuple(ue)
            self._set_attr('ue', ue, VALIDATOR)
        for key, value in self_defined_args.items():
            self._attributes[key] = value

    def _convert_to_tuple(self, item):
        if isinstance(item, TrsSchemas):
            return dict(item)
        elif isinstance(item, (list, tuple)):
            return GROUP_CONFIG(*item)
        elif isinstance(item, GROUP_CONFIG):
            return item
        elif isinstance(item, Config):
            return GROUP_CONFIG(item)
        return ()


class tak_config(configuration, test_log_dir, kiss_debug_log_dir, TA_CONFIG):
    """
    Introduction
    ************

    ta_kiss_config library which can be used to get testline configuration, and create test log directory for
    saving test log .


    Package requirements
    ********************

    * Python 2.7.x
    * setuptools >=3.3
    * pip >= 1.5.4
    * ute_installer >= 0.25

    Installation
    ************

    This section describes how to install **ta_kiss_config** as single library. Below steps are not needed if
    robotlte is installed.

    Installation for UTE test line
    ------------------------------

    ::

        pip install -U ta_kiss_config


    Installation for NON UTE test line
    ----------------------------------

    ::

        pip install -U -i http://pypi.ute.inside.nsn.com:25102 pip
        pip install -U -i http://pypi.ute.inside.nsn.com:25102 setuptools
        pip install -U -i http://pypi.ute.inside.nsn.com:25102 ute_installer
        pip install -U -i http://pypi.ute.inside.nsn.com:25102 ta_kiss_config


    Installation from SVN
    ---------------------

    ::

        pip install svn+https://ca_ute_test:utetest@svne1.access.nsn.com/isource/svnroot/talibs/ta_kiss_config/trunk/
        #egg=ta_kiss_config


    Library description
    *********************

    configuration
    -------------

    get the testline config information, inlcuding self-defined environment variables.

    **Example:**

    ::

        __init__.py file: if the self-defined environment variables needed, please use the TA_CONFIG class.

        from ute_testline_configuration.ute_config import Host, Pdu, FSIH, IPHY
        from ta_kiss_config import TA_CONFIG

        host = [
            Host(addr='127.0.0.1')
        ]
        fsm3 = [
            FSIH(pdu=Pdu('10.68.184.0', 1, 'FACOM'), bbmod1_pdu=Pdu(addr='10.42.50.22', port=2, device='ATEN'),
            bbmod2_pdu=Pdu(addr='10.42.50.22', port=3, device='ATEN'), trs_ip='10.0.1.2', top_ip='10.44.136.254',
            vlan_ids=None)
        ]
        iphy = [
            IPHY(pdu=Pdu('10.68.184.252', 2, 'FACOM'))
        ]
        #BTS_ID:
        BTS_INFO_ID = "4"
        #NetAct_SERVER_URL:
        NETACT_SERVER_URL="clab852lbwas.netact.nsn-rdnet.net/startpage/"

        tl = TA_CONFIG(host=host, fsm=fsm3, iphy=iphy, bts_info_id = BTS_INFO_ID, netact_server = NETACT_SERVER_URL)

    ::

        *** Settings ***
        Variables      ta_kiss_config

        *** Test Cases ***
        test_demo_1
            log    ${tl.bts_info_id}               #print  [ b'4' ]
            log    ${tl.netact_server}             #print  [  b'clab852lbwas.netact.nsn-rdnet.net/startpage/' ]
            Log    ${tl.host[1]}                   #print  dict,    {'addr': '127.0.0.1', 'password': 'ute',
            'username': 'ute'}
            Log    ${tl.host[1].addr}              #print   127.0.0.1
            Log    ${tl.host[1].username}          #        [ b'ute' ]
            Log    ${tl.host[1].password}          #        [ b'ute' ]
            Log    ${tl.host[1].fsm}               #print fsm,      {'bbmod1_pdu': 'None',
                                                   #                 'bbmod2_pdu': 'None',
                                                   #                 'hw_type': 'FSIH',
                                                   #                 'pdu': {'addr': '10.68.184.0', 'device': 'FACOM',
                                                   'port': '1'},
                                                   #                 'top_ip': '10.44.136.254',
                                                   #                 'trs_ip': '10.0.1.2',
                                                   #                 'vlan_ids': 'None'}
            Log    ${tl.fsm[1].hw_type}            #print    FSIH
            Log    ${tl.fsm[1].pdu}                #         {'addr': '10.68.184.0', 'device': 'FACOM', 'port': '1'}
            Log    ${tl.fsm[1].pdu.device}         #         [ b'FACOM' ]
            Log    ${tl.fsm[1].pdu.addr}           #         10.68.184.0
            Log    ${tl.fsm[1].pdu.port}           #         1

        test_demo_2
            Log    ${tl.host[2]}                   #print  dict,    {'addr': '127.0.0.1', 'password': 'ute',
            'username': 'ute'}
            Log    ${tl.host[2].addr}              #print   127.0.0.1
            Log    ${tl.host[2].username}          #        [ b'ute' ]
            Log    ${tl.host[2].password}          #        [ b'ute' ]
            Log    ${tl.fsm[2]}                    #print fsm,      {'bbmod1_pdu': 'None',
                                                   #                 'bbmod2_pdu': 'None',
                                                   #                 'hw_type': 'FSIH',
                                                   #                 'pdu': {'addr': '10.68.184.0', 'device': 'FACOM',
                                                   'port': '1'},
                                                   #                 'top_ip': '10.44.136.254',
                                                   #                 'trs_ip': '10.0.1.2',
                                                   #                 'vlan_ids': 'None'}
            Log    ${tl.fsm[2].hw_type}            #print    FSIH
            Log    ${tl.fsm[2].pdu}                #         {'addr': '10.68.184.0', 'device': 'FACOM', 'port': '1'}
            Log    ${tl.fsm[2].pdu.device}         #         [ b'FACOM' ]
            Log    ${tl.fsm[2].pdu.addr}           #         10.68.184.0
            Log    ${tl.fsm[2].pdu.port}           #         1

    test_log_directory()
    ------------------
    Create and return a test log directory. The test log directory is under ${OUTPUT_DIR}/log/${SUITE_NAME}_timestamp/
    ${TEST_NAME}.

    If the character length of ${SUITE_NAME}_timestamp/${TEST_NAME} is greater than 150, only keep the first 150
    characters.

    **Example:**

    ::

        *** Settings ***
        Variables      ta_kiss_config

        *** Test Cases ***
        Test read test log directory example
            Log    ${test_log_directory()}

    """
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.logger = Logger()
        configuration.__init__(self)
        test_log_dir.__init__(self)
        kiss_debug_log_dir.__init__(self)


def test_log_directory():
    """return a test log directory.

    :return: the test log directory.
    :rtype: string
    """
    return "{}".format(test_log_dir())


def kiss_debug_log_directory():
    """return a test log debug directory.

    :return: the test log debug directory.
    :rtype: string
    """
    return "{}".format(kiss_debug_log_dir())

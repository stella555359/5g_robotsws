"""
Utility functions for reading data from testline's __init__.py and ue_conf.yaml files.

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

import importlib.util
import os
import socket
import sys

from robot.libraries.BuiltIn import RobotNotRunningError
from yaml import load, SafeLoader

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.exceptions import ConfigurationNotLoaded
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger


class TestlineConfiguration:
    _singleton = None
    config_mock = None
    reinitialize = True

    def __new__(cls, *args, **kwargs):
        if cls._singleton is None:
            cls._singleton = super().__new__(cls)
            cls.config_mock = ConfigMock()
        return cls._singleton

    def __init__(self, init_conf=None, yaml_conf=None):
        if TestlineConfiguration.reinitialize:
            self._tl_init = None
            self._tl_init_conf = init_conf
            self._yaml = None
            self._yaml_conf = yaml_conf
            self._yaml_path = None
            TestlineConfiguration.reinitialize = False

    @property
    def tl_init(self):
        if self._tl_init is None:
            self._tl_init = self._load_tl_init(self._tl_init_conf)
        return self._tl_init

    @property
    def yaml(self):
        if self._yaml is None:
            self._yaml, self._yaml_path = self._load_yaml_conf(self._yaml_conf)
        return self._yaml

    @property
    def yaml_path(self):
        if self._yaml_path is None:
            self._yaml, self._yaml_path = self._load_yaml_conf(self._yaml_conf)
        return self._yaml_path

    @staticmethod
    def _load_tl_init(init_conf):
        if init_conf is not None:
            TestlineConfiguration._assert_file_exist(filepath=init_conf)
            tl_init = TestlineConfiguration._load_tl_init_python_file(init_conf)
        else:
            tl_init = TestlineConfiguration._find_init_or_mock()
        return tl_init

    @staticmethod
    def _find_init_or_mock():
        try:
            return TestlineConfiguration._get_init_from_robot_var()
        except RobotNotRunningError:
            try:
                return TestlineConfiguration._get_init_from_default_place()
            except EnvironmentError:
                logger.warn("No testline init conf file loaded!")
                return TestlineConfiguration.config_mock

    @staticmethod
    def _get_init_from_robot_var():
        tl_init = get_robot_variable("tl")
        if tl_init is None:
            raise RobotNotRunningError
        return tl_init

    @staticmethod
    def _get_init_from_default_place():
        default_file = "/home/ute/testline_configuration/{tl_name}/__init__.py" \
                       "".format(tl_name=socket.gethostname().replace('-', '_'))
        TestlineConfiguration._assert_file_exist(filepath=default_file)
        logger.warn("Using default testline init conf file: {}".format(default_file))
        return TestlineConfiguration._load_tl_init_python_file(default_file)

    @staticmethod
    def _assert_file_exist(filepath):
        if not os.path.isfile(filepath):
            raise EnvironmentError("No such file: {}".format(filepath))

    @staticmethod
    def _load_tl_init_python_file(filepath):
        module_name = 'tl_init'
        spec = importlib.util.spec_from_file_location(module_name, filepath)
        module = importlib.util.module_from_spec(spec)
        sys.modules[module_name] = module
        spec.loader.exec_module(module)
        return module.tl

    def _load_yaml_conf(self, yaml_conf_file):
        if yaml_conf_file is not None:
            self._assert_file_exist(filepath=yaml_conf_file)
            yaml_conf = self._load_yaml_file(yaml_conf_file)
        else:
            yaml_conf, yaml_conf_file = self._find_yaml_or_mock()
        return yaml_conf, yaml_conf_file

    def _find_yaml_or_mock(self):
        yaml_conf_file = self._get_yaml_path_from_robot_var() or self._get_yaml_path_from_env_var() or 'not|found'
        try:
            yaml_conf = TestlineConfiguration._load_yaml_file(yaml_conf_file)
        except EnvironmentError:
            try:
                yaml_conf, yaml_conf_file = self._get_yaml_from_default_place()
            except EnvironmentError:
                if self._can_get_yaml_from_init():
                    yaml_conf = self.tl_init.ues[0]
                else:
                    logger.warn("No YAML conf file loaded!")
                    yaml_conf = TestlineConfiguration.config_mock
        return yaml_conf, yaml_conf_file

    @staticmethod
    def _load_yaml_file(filepath):
        with open(filepath) as yaml_file:
            return load(yaml_file, Loader=SafeLoader)

    @staticmethod
    def _get_yaml_from_default_place():
        yaml_conf_file = "/home/ute/testline_configuration/{tl_name}/ue_config.yaml" \
                         "".format(tl_name=socket.gethostname().replace('-', '_'))
        TestlineConfiguration._assert_file_exist(filepath=yaml_conf_file)
        logger.warn("Using default abstract_lib_config file: {}".format(yaml_conf_file))
        return TestlineConfiguration._load_yaml_file(yaml_conf_file), yaml_conf_file

    def _can_get_yaml_from_init(self):
        return not isinstance(self.tl_init, ConfigMock) and len(self.tl_init.ues) and isinstance(self.tl_init.ues[0],
                                                                                                 dict)

    @staticmethod
    def _get_yaml_path_from_robot_var():
        try:
            abstract_lib_config = get_robot_variable('ABSTRACT_LIB_CONFIG')
            if abstract_lib_config is None:
                raise RobotNotRunningError
        except RobotNotRunningError:
            try:
                abstract_lib_config = get_robot_variable('tl.ues[0]')
            except RobotNotRunningError:
                abstract_lib_config = None
        return abstract_lib_config

    @staticmethod
    def _get_yaml_path_from_env_var():
        try:
            abstract_lib_config = os.environ['ABSTRACT_LIB_CONFIG']
        except KeyError:
            abstract_lib_config = None
        return abstract_lib_config

    def get_ue_configuration_from_yaml(self, ue_name=None):
        conf = self.yaml['UE_POOLS']['AndroidUePool']['inline_config']
        ue_name = list(conf.keys())[0] if ue_name is None or ue_name == 0 else ue_name
        conf = conf[ue_name]['CONSTRUCTOR_PARAMETERS']['configuration']
        return conf

    def get_uepc_connection_details(self, ue_id=0):
        try:
            return self.get_uepc_connection_details_from_init(ue_id)
        except (ConfigurationNotLoaded, IndexError, AttributeError):
            return self.get_uepc_connection_details_from_yaml(ue_id)

    def get_uepc_connection_details_from_init(self, ue_id):
        details = self.tl_init.ues[ue_id].ssh_connection_details
        return {'hostname': details.addr, 'username': details.username, 'password': details.password}

    def get_uepc_connection_details_from_yaml(self, ue_name=None):
        conf = self.get_ue_configuration_from_yaml(ue_name)
        return {'hostname': conf['ue_pc_ip'], 'username': conf['login'], 'password': conf['password']}

    def get_uepc_pyro_port(self, ue_name=None):
        conf = self.get_ue_configuration_from_yaml(ue_name)
        return conf['pyro_port']

    def get_python_path(self, ue_name=None):
        conf = self.get_ue_configuration_from_yaml(ue_name)
        return conf['server_python']

    def get_dmc_path(self, ue_name=None):
        conf = self.get_ue_configuration_from_yaml(ue_name)
        return conf['dmc_path']

    def get_elt_database_path(self, ue_name=None):
        conf = self.get_ue_configuration_from_yaml(ue_name)
        return conf.get('elt_database', None)

    def get_diag_com(self, ue_name=None):
        conf = self.get_ue_configuration_from_yaml(ue_name)
        return conf['diag_com']

    def get_gnb_configuration(self, gnb_id=0):
        return self.tl_init.gnbs[gnb_id]

    def get_enb_configuration(self, enb_id=0):
        return self.tl_init.enbs[enb_id]

    def get_gnb_oam_connection_details(self, gnb_id=0):
        try:
            details = self.get_gnb_configuration(gnb_id).cu.oam_http_connection_details
        except ConfigurationNotLoaded:
            return {'hostname': '192.168.255.1', 'username': 'Nemuadmin', 'password': 'nemuuser'}
        return {'hostname': details.addr, 'username': details.username, 'password': details.password}

    def get_du_oam_connection_details(self, gnb_id=0, du_id=0):
        try:
            details = self.get_gnb_configuration(gnb_id).dus[du_id].oam_http_connection_details
        except ConfigurationNotLoaded:
            return {'hostname': '192.168.255.1', 'username': 'Nemuadmin', 'password': 'nemuuser'}
        return {'hostname': details.addr, 'username': details.username, 'password': details.password}

    def get_gnb_ssh_connection_details(self, gnb_id=0):
        try:
            details = self.get_gnb_configuration(gnb_id).cu.oam_ssh_connection_details
        except ConfigurationNotLoaded:
            return {'hostname': '192.168.255.1', 'username': 'toor4nsn', 'password': 'oZPS0POrRieRtu'}
        return {'hostname': details.addr, 'username': details.username, 'password': details.password}

    def get_enb_oam_connection_details(self, enb_id=0):
        enb_addr = self.get_gnb_configuration(enb_id).x2_link_addr.v4
        return {'hostname': enb_addr, 'username': 'Nemuadmin', 'password': 'nemuuser'}

    def get_lte_test_pc_connection_details(self):
        details = self.tl_init.test_pcs[1].default_ssh_connection_details
        return {'hostname': details.addr, 'username': details.username, 'password': details.password}

    def get_nr_test_pc_connection_details(self):
        try:
            details = self.tl_init.test_pc.default_ssh_connection_details
        except ConfigurationNotLoaded:
            return {'hostname': 'localhost', 'username': 'ute', 'password': 'ute'}
        return {'hostname': details.addr, 'username': details.username, 'password': details.password}


def convert_windows_path_to_cygwin(path):
    if len(path) < 3:
        return path
    if path[:2] == 'c:' or path[:2] == 'C:':
        path = '/cygdrive/c' + path[2:]
    return path


def convert_cygwin_path_to_windows(path):
    if len(path) < 11:
        return path
    if path[:11] == '/cygdrive/c':
        path = 'C:' + path[11:]
    return path


class ConfigMock:
    def __getattr__(self, item):
        raise ConfigurationNotLoaded("'{}' is inaccessible".format(item))

    def __getitem__(self, item):
        raise ConfigurationNotLoaded("'{}' is inaccessible".format(item))

    def __call__(self):
        raise ConfigurationNotLoaded

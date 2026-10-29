# -*- coding: utf-8 -*-
"""
Generic keywords for BTS.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
import os
import logging
import re
import inspect
import time

from functools import wraps
from taf.sbts.oam.coam.admin import admin as cadmin
from taf.sbts.oam.coam.admin.exceptions import (
    IncorrectParameterValue, DataNotAvailable, )
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, )
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.selenium.gnb.oam.coam.classical import (
    classical as selenium_coam_classical, )
from taf.selenium.sbts import sbts as selenium_coam_sbts
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.utilities \
    import (get_builtin_value, )
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.helpers \
    import (inspect_args,)
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.helpers \
    import (tl_config, )
from testsuite.Bangalore.ORAN.resources.python.Macro.Python import (
    connection_names, )
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.utilities \
    import (dump_current_disk_space_usage_on_ute_vm, )

from selenium.common.exceptions import (
    ElementClickInterceptedException, TimeoutException, )
from urllib3.util.retry import MaxRetryError


def _get_bts_id_arg_name(func):
    args_names = inspect.getargspec(func)[0]
    if 'gnb_id' in args_names:
        return 'gnb_id'
    elif 'enb_id' in args_names:
        return 'enb_id'
    elif 'bts_id' in args_names:
        return 'bts_id'
    else:
        raise ValueError("One of parameter "
                         "[gnb_id, enb_id, bts_id] is required")


def _convert_id_to_int(arg_name, args, kwargs, fun):
    id_info = inspect_args.get_arg_info(arg_name, args, kwargs, fun)
    id = int(id_info["value"])
    id_info["value"] = id
    args, kwargs = inspect_args.set_arg_value(id_info, args, kwargs)

    return id, args, kwargs


def login_logout(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        bts_id_arg_name = _get_bts_id_arg_name(web_fun)
        bts_id, args, kwargs = _convert_id_to_int(bts_id_arg_name,
                                                  args, kwargs, web_fun)
        du_id, args, kwargs = _convert_id_to_int('du_id',
                                                 args, kwargs, web_fun)

        self.connect(bts_id=bts_id, du_id=du_id)
        try:
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            self.disconnect(bts_id=bts_id, du_id=du_id)

    return wrapper


def login_logout_GUI(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        reconnect = False
        bts_id_arg_name = _get_bts_id_arg_name(web_fun)
        bts_id, args, kwargs = _convert_id_to_int(bts_id_arg_name,
                                                  args, kwargs, web_fun)
        du_id, args, kwargs = _convert_id_to_int('du_id',
                                                 args, kwargs, web_fun)
        if self.gui_coam is None:
            self.login_gui(bts_id=bts_id, du_id=du_id)
        elif self._gui_coam_connection_name == self.gui_alias.format(
                bts_id, du_id):
            self._close_startup_view_if_exists()
            try:
                result = web_fun(self, *args, **kwargs)
                return result
            except Exception as ex:
                reconnect = True
                logging.warning("Cannot call method {}. "
                                "Caught exception: {}".
                                format(web_fun.__name__, repr(ex)))
                logging.warning("Try to login again")
                self.gui_coam.save_screenshot(filename='exception')
        else:
            reconnect = True

        if reconnect:
            self.logout_gui()
            self.login_gui(bts_id=bts_id, du_id=du_id)

        return web_fun(self, *args, **kwargs)

    return wrapper


def convert_id_to_int(fun):
    @wraps(fun)
    def wrapper(*args, **kwargs):
        bts_id_arg_name = _get_bts_id_arg_name(fun)
        bts_id, args, kwargs = _convert_id_to_int(bts_id_arg_name,
                                                  args, kwargs, web_fun)
        du_id, args, kwargs = _convert_id_to_int('du_id',
                                                 args, kwargs, web_fun)

        result = fun(*args, **kwargs)
        return result

    return wrapper


class GenericBts(object):
    """Generic keywords for eNB and gNB"""

    admin = cadmin()

    def __init__(self, bts_type='GNB'):
        """
        Constructor of GenericBts class.

        :param bts_type: GNB|ENB
        """

        self.bts_type = bts_type

        self.rest_alias = connection_names.rest_bts_du.format(
            bts_type, '{}', '{}')
        self.gui_alias = connection_names.gui_bts_du.format(
            bts_type, '{}', '{}')
        self.ssh_alias = connection_names.ssh_bts_du.format(
            bts_type, '{}', '{}')
        self.ssh_cap_unit_alias = connection_names.ssh_cap_unit.format(
            bts_type, '{}', '{}', '{}', '{}')
        self.syslog_alias = connection_names.syslog_bts_du.format(
            bts_type, '{}', '{}')
        self.ssh_ru_alias = connection_names.ssh_bts_du_ru.format(
            bts_type, '{}', '{}', '{}')

        self.ws_du_alias = connection_names.ws_du.format(bts_type, '{}', '{}')

        self.patterns = GnbPatterns if bts_type == 'GNB' else EnbPatterns

        self.gui_coam = None
        self._gui_coam_connection_name = None

    def __del__(self):
        self._teardown_browser()

    def connect(self, bts_id=0, du_id=0, reconnect_attempts=3):
        """
        Connect to BTS
        :param bts_id:      enb_id or gnb_id, related to test
                            line configuration default set to 0
        :param du_id:       DU id(Distributed Unit) - id related to Test Line
                            configuration - gnb.dus[]
        :param reconnect_attempts:  max reconnect attempts

        """
        credentials = tl_config.get_web_credentials_for_du(
            bts_id, du_id, self.bts_type)
        attempt = 0
        admin_exception = None
        while attempt <= reconnect_attempts:
            attempt += 1
            try:
                self.admin.connect_to(bts_host=credentials['ip'],
                                      username=credentials['username'],
                                      password=credentials['password'],
                                      name=self.rest_alias.format(bts_id,
                                                                  du_id),
                                      admin_api_log_dir=get_builtin_value(
                                          'OUTPUT_DIR'))
                break
            except AdminApiConnectionClosedException as e:
                admin_exception = e
                logging.warning("[AdminApiConnectionClosedException]"
                                " cannot connect to bts")
                self.disconnect(bts_id, du_id)
                logging.debug("Dumping current disk space usage on VM")
                dump_current_disk_space_usage_on_ute_vm()
        else:
            if admin_exception:
                raise admin_exception

    def disconnect(self, bts_id=0, du_id=0):
        """
        Disconnect from BTS

        :param bts_id:enb_id or gnb_id, related to test line configuration,
                      default set to 0
        :param du_id:DU id(Distributed Unit) - id related to Test
                     Line configuration - gnb.dus[]
        :return: None
        """
        try:
            name = self.rest_alias.format(bts_id, du_id)
            self.admin.teardown(connection=name)
        except AliasLookupError:
            logging.debug("[{}] Already disconnected".format(name))

    def login_gui(self, bts_id=0, du_id=0):
        """
        Login to BTS via GUI

        :param bts_id:   enb_id or gnb_id, related to test line configuration,
                            default set to 0
        :param du_id:       DU id(Distributed Unit) - id related to Test
                            Line configuration - gnb.dus[]
        :return: None
        """
        if self.is_sbts_software():
            self.gui_coam = selenium_coam_sbts()
        else:
            self.gui_coam = selenium_coam_classical()
        self._gui_coam_connection_name = self.gui_alias.format(
            bts_id, du_id)
        self.gui_coam.enable_virtual_display()
        try:
            self._login_gui(bts_id, du_id)
        except TimeoutException:
            logging.warning("Login failed")

    def _close_startup_view_if_exists(self):
        if self.gui_coam.start_up_view_window_exists():
            self.gui_coam.close_start_up_view_window()

    def _login_gui(self, bts_id=0, du_id=0):
        credentials = tl_config.get_web_credentials_for_du(
            bts_id, du_id, self.bts_type)
        selenium_logs = os.path.join(
            get_builtin_value("OUTPUTDIR"), 'selenium_logs')
        download_folder = os.path.join(selenium_logs, "download")
        if not os.path.exists(download_folder):
            os.makedirs(download_folder)
        try:
            self.gui_coam.login(url='https://{}/'.format(credentials['ip']),
                                username=credentials['username'],
                                password=credentials['password'],
                                screenshot_dir=os.path.join(
                                    selenium_logs, 'screenshot'),
                                version=self._get_proper_coam_selenium_version(
                                    bts_id, du_id))
        except TimeoutException:
            logging.warning("Login failed, Try to use method "
                            "login_after_screen_lock")
            self._login_gui_after_screen_lock(bts_id, du_id)

    def _login_gui_after_screen_lock(self, bts_id=0, du_id=0):
        credentials = tl_config.get_web_credentials_for_du(
            bts_id, du_id, self.bts_type)
        self.gui_coam.login_after_screen_lock(
            passwd=credentials['password'], timeout=60)

    def logout_gui(self):
        """
        Logout from BTS via GUI

        :return: None
        """
        for x in range(3):
            try:
                self.gui_coam.logout()
                break
            except (ElementClickInterceptedException, MaxRetryError):
                time.sleep(5)
        self._teardown_browser()

    def _teardown_browser(self):
        if self.gui_coam:
            self.gui_coam.close_browser()
            self.gui_coam.disable_virtual_display()
            self.gui_coam = None

    def get_bts_instance_id(self, bts_id=0, du_id=0):
        """
        Get BTS Instance id from config file.

        :param bts_id:                  enb_id or gnb_id, related to test line
                                        configuration, default set to 0
        :param du_id:             DU id(Distributed Unit) - id related to Test
                                        Line configuration - gnb.dus[]
        :return: global BTS ID - MRBTS
        """

        return tl_config.get_bts_instance_id(
            bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)

    def get_global_bts_id(self, bts_id=0, du_id=0):
        """
        Get global BTS id from config file.

        :param bts_id:                  enb_id or gnb_id, related to test line
                                        configuration, default set to 0
        :param du_id:                   DU id(Distributed Unit) - id related to
                                        Test Line configuration - gnb.dus[]
        :return: global BTS ID, nrbts_id for GNB or lnbts_id for ENB
        """

        return tl_config.get_global_bts_id(
            bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)

    def get_bts_config(self, bts_id=0):
        """
        Get Bts instance form config file
        :param bts_id:  enb_id or gnb_id, related to test line configuration,
                        default set to 0
        :param du_id:   DU id(Distributed Unit) - id related to Test
                        Line configuration - gnb.dus[]
        :return: instance of bts
        """
        return tl_config._get_bts_object(bts_id=bts_id, bts_type=self.bts_type)

    def _get_object_parameters_dict(self, dist_name, bts_id, du_id):
        """
        Create python dictionary from current scf content.

        :param dist_name:               full class path to target object
                                        e.g "MRBTS-1/NRBTS-1/NRCELL-1"
        :type dist_name:                full class path
        :param bts_id:                  gNB or eNB ID as int
        :param du_id:                   DU id(Distributed Unit) - id related to
                                        Test Line configuration - gnb.dus[]
        :return:                   parameters and values in form of dictionary
        :rtype:                         dict
        """
        bts_configuration = self.admin.get_scf(
            export_type="configurationAndRuntimeObjects",
            connection=self.rest_alias.format(bts_id, du_id))
        ret = str(bts_configuration).partition('distName="{}"'.format(
            dist_name))[2].partition('</managedObject>')[0]
        re_parameter_and_value = r'\s+<p\s\w+=.(?P<KEY>\w+).>(?P<VALUE>.*)</p>'
        ret_dict = dict()
        for line in ret.splitlines():
            determinate_parameter = re.search(re_parameter_and_value, line)
            if determinate_parameter:
                ret_dict[determinate_parameter.group('KEY')] = \
                    determinate_parameter.group('VALUE')
        return ret_dict

    def _verify_configuration_parameters_values(
            self, param_dict, bts_id=0, du_id=0):
        """
        Verify that given parameters have given values.
        :param param_dict: dictionary where the main key is a distNames of the
        managedObject where given parameters are located and the value
        is dictionary with parameters and their expected values,
        e.g. {  distName1: {
                  param1: expected_value1,
                  param2: expected_value2
                },
                distName2: {
                  param1: expected_value1,
                  param2: expected_value2
                }
            }
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id:  DU id(Distributed Unit) - id related to
                       Test Line configuration - gnb.dus[]
        :return: None
        """
        param_dict_with_proper_distnames = dict()
        for dist_name in param_dict.keys():
            proper_dist_name = self.adjust_dist_name(dist_name=dist_name,
                                                     bts_id=bts_id,
                                                     du_id=du_id)
            param_dict_with_proper_distnames[proper_dist_name] =\
                param_dict[dist_name]

        for dist_name in param_dict_with_proper_distnames.keys():
            for param_name in param_dict_with_proper_distnames[dist_name]:
                self._verify_parameter_value(
                    parameter=param_name,
                    expected_value=param_dict_with_proper_distnames[dist_name][param_name],
                    dist_name=dist_name,
                    bts_id=bts_id,
                    du_id=du_id)
        logging.info("All parameters have correct values")

    def _verify_parameter_value(self, parameter, expected_value,
                                dist_name, bts_id, du_id):
        """
        Verify if current value of parameter is consistent with expected value.

        :param parameter:               parameter name
        :type parameter:                str
        :param expected_value:          expected value of parameter
        :type expected_value:           str
        :param dist_name:               full class path to target object
                                        e.g "MRBTS-1/NRBTS-1/NRCELL-1"
        :type dist_name:                full class path
        :param bts_id:                  enb_id or gnb_id, related to test line
                                        configuration, default set to 0
        :type bts_id:                   int or str
        :param du_id:                   DU id(Distributed Unit) - id related
                                        to Test Line configuration - gnb.dus[]
        :type bts_id:                   int or str
        :return
        """
        try:
            value = self._get_object_parameters_dict(
                dist_name=dist_name,  bts_id=bts_id, du_id=du_id)[parameter]
        except KeyError:
            raise DataNotAvailable(
                "'{}' doesn't exist in bts configuration (check if keyword "
                "arguments are correct)".format(parameter))
        if not re.match(expected_value, value, re.I):
            raise IncorrectParameterValue(
                "'{}' should be '{}' but is'{}'".format(parameter,
                                                        expected_value, value))
        else:
            logging.info("Parameter '{}' is '{}'".format(parameter,
                                                         expected_value))

    def adjust_dist_name(self, dist_name, bts_id, du_id=0):
        """
        Adjust mrbts_id and global bts id (nrbts_id or lnbts_id) in given
        distName.

        :param dist_name:               distName in format
                                        e.g. MRBTS-{}/NRBTS-{}/NRCELL-1
        :type dist_name:                str
        :param bts_id:                  enb_id or gnb_id, related to test line
                                        configuration, default set to 0
        :type bts_id:                   int or str
        :param du_id:                   DU id(Distributed Unit) - id related to
                                        Test Line configuration - gnb.dus[]
        :type du_id:                    int or str
        :return: distName with proper values
        """
        mrbts_id = self.get_bts_instance_id(bts_id=bts_id, du_id=du_id)
        global_bts_id = self.get_global_bts_id(bts_id=bts_id, du_id=du_id)
        return dist_name.format(mrbts_id, global_bts_id)

    @login_logout
    def is_sbts_software(self, bts_id=0, du_id=0):
        """
        Verify SBTS software.
        :param bts_id:          BTS id - related to Test Line configuration.
                                Default: 0
        :type bts_id:           int
        :param du_id:           DU id(Distributed Unit) - id related to Test
                                Line configuration- gnb.dus[]
        :return:                True/False
        """
        release = self.admin.get_sw_release_name(
            connection=self.rest_alias.format(bts_id, du_id))
        is_sbts = "SBTS" in release
        return is_sbts

    @login_logout
    def _get_proper_coam_selenium_version(self, bts_id=0, du_id=0):
        version = None
        only_release_number = None
        supported_versions = ["20B", "21A", "21B"]
        current_trunk_releases = ['21B', '22R1']
        release = self.admin.get_sw_release_name(
            connection=self.rest_alias.format(bts_id, du_id))
        logging.debug("[{}] Release version: {}".format(
            self.rest_alias.format(bts_id, du_id), release))

        if release:
            # 5G21A, SBTS21B, 5G22R1
            match = re.search(r'(\d+(?:([A-C])|(R\d+)))', release)
            if match:
                only_release_number = match.group(0)
                logging.debug("[{}] Release number: {}".format(
                    self.rest_alias.format(bts_id, du_id),
                    only_release_number))
            if only_release_number:
                if only_release_number in supported_versions:
                    version = only_release_number
                elif only_release_number in current_trunk_releases:
                    version = supported_versions[-1]

        logging.debug("Selected selenium version: {}".format(version))
        return version


class GenericPatterns(object):
    re_ru_dist_name = r'(?P<RU_DIST_NAME>/MRBTS-\d+/RAT-\d+' \
                      r'/RUNTIME_VIEW-\d+/MRBTS_R-\d+/' \
                      r'EQM_R-\d+/APEQM_R-\d+/RMOD_R-{})'


class EnbPatterns(GenericPatterns):
    bts_dist_name = "MRBTS-{}/LNBTS-{}"
    cell_dist_name = "MRBTS-{}/NRBTS-{}/LNCEL-{}"
    run_time_cell_dist_name = r'(?P<CELL_DIST_NAME>/MRBTS-\d+/RAT-\d+' \
                              r'/RUNTIME_VIEW-\d+/MRBTS_R-\d+/' \
                              r'LNBTS[^/]*/LNCEL_R-{})'
    default_sync_source = "1pps/ToD from external GNSS receiver"
    x2_link_dist_name = 'MRBTS-{}/LNBTS-{}/LNADJGNB-1'


class GnbPatterns(GenericPatterns):
    bts_dist_name = "MRBTS-{}/NRBTS-{}"
    cell_group_dist_name = "MRBTS-{}/NRBTS-{}/NRCELLGRP-{}"
    cell_dist_name = "MRBTS-{}/NRBTS-{}/NRCELL-{}"
    run_time_cell_dist_name = r'(?P<CELL_DIST_NAME>/MRBTS-\d+/RAT-\d+' \
                              r'/RUNTIME_VIEW-\d+/MRBTS_R-\d+/' \
                              r'NRBTS[^/]*/NRCELL_R-{})'
    default_sync_source = "1pps/ToD from Sync Hub Master"
    x2_link_dist_name = 'MRBTS-{}/NRBTS-{}/LTEENB-1'

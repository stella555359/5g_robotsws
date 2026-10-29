# -*- coding: utf-8 -*-
"""
Common Keywords for OAM test cases.


:copyright: Nokia Networks
:author: I_SC_KRK_PROD_NITROGEN_GMS
:contact: I_SC_KRK_PROD_NITROGEN@internal.nsn.com
:maintainer: I_SC_KRK_PROD_NITROGEN_GMS
:contact: I_SC_KRK_PROD_NITROGEN@internal.nsn.com

"""

__author__ = 'Tomasz Krol'
__copyright__ = 'Copyright (C) 2019, Nokia'
__email__ = 'tomasz.krol@nokia.com,'

import os
import re
import json
import taf.ul.sc.tl_config as tl_config
from taf.ul.sc.perf.tc import tc
from taf.ul.sc.gnb.airscale import AirScale
from moler.util.moler_test import MolerTest
from moler.config import read_yaml_configfile
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import is_dry_run

if not is_dry_run():
    ip = tl_config.tl.gnbs[0].cu.oam_http_connection_details.addr
    mrbts_id = tl_config.tl.gnbs[0].instance_id
    nrbts_id = tl_config.tl.gnbs[0].global_bts_id


def load_run_params(tc_params=None, golden_params=None):
    if not tc_params:
        tc_params = load_tc_params()
    if not golden_params:
        golden_params = load_golden_params()

    tc.load_run_params(tc_params=tc_params,
                       golden_params=golden_params)


def load_tc_params(tc_params_file=None):
    tc_params = {}
    if not tc_params_file:
        tc_params_file = BuiltIn().get_variable_value("${TC_PARAMS}")
        # for load few files you need to pass paths to files separated by :
        # eg: -variable TC_PARAMS:/home/ute/common_pet_params.env:/home/ute/tc_params.ev
        tc_params_files = tc_params_file.split(":")
        for tc_file in tc_params_files:
            _load_params_file(tc_params, tc_file)

    return tc_params


def load_golden_params():
    golden_params = {}
    load_procedure_params(golden_params)
    load_environment_params(golden_params)
    load_post_params(golden_params)

    return golden_params


def _load_params_file(golden_params=tc.run_params, params_file=None):
    if params_file:
        params = read_yaml_configfile(path=params_file)
        golden_params.update(params)


def load_procedure_params(golden_params=tc.run_params, procedure_params_file=None):
    if not procedure_params_file:
        procedure_params_file = BuiltIn().get_variable_value("${PROCEDURE_PARAMS}")
    _load_params_file(golden_params, procedure_params_file)


def load_environment_params(golden_params=tc.run_params, env_params_file=None):
    if not env_params_file:
        env_params_file = BuiltIn().get_variable_value("${ENVIRONMENT_PARAMS}")
    _load_params_file(golden_params, env_params_file)


def load_post_params(golden_params=tc.run_params, post_params_file=None):
    if not post_params_file:
        post_params_file = BuiltIn().get_variable_value("${POST_PARAMS}")
    _load_params_file(golden_params, post_params_file)


def set_run_params_as_suite_variable():
    BuiltIn().set_suite_variable("${run_params}", tc.run_params)


def print_test_run_parameters():
    MolerTest.info(msg="Test is running with parameters:", dump=tc.run_params)


def set_test_case_name():
    if 'test_case_name' not in tc.run_params or tc.run_params['test_case_name'] is None:
        test_name = BuiltIn().get_variable_value("${TEST NAME}")
        if test_name is None:
            test_name = _get_tc_name(BuiltIn().get_variable_value("${TC_PARAMS}"))
        if test_name is None:
            test_name = BuiltIn().get_variable_value("${SUITE NAME}")
        tc.run_params['test_case_name'] = test_name


def set_robot_automatic_variables():
    set_test_case_name()
    suite_name = BuiltIn().get_variable_value("${SUITE NAME}")
    tc.run_params['procedure_name'] = suite_name
    output_dir = BuiltIn().get_variable_value("${OUTPUT DIR}")
    tc.run_params['output_dir'] = output_dir
    tc.run_params['test_repository'] = get_test_repository_path()


def get_test_repository_path():
    file_path = os.path.abspath(__file__)

    test_repo_regex = re.compile(r"(?P<TEST_REPOSITORY>.*(robotws5g|Auto5G|test_repository)/)")
    match = test_repo_regex.match(file_path)

    test_repository = match.group('TEST_REPOSITORY')
    # test_repository = os.environ['TEST_REPOSITORY'] if 'TEST_REPOSITORY' in os.environ else None
    return test_repository


def _get_tc_name(tc_params_path):
    if tc_params_path:
        regex = re.compile(r"(.+)/(?P<DIRECTORY_NAME>[^/]+)/(?P<FILE_NAME>[^/]+)")
        match = regex.match(tc_params_path)
        if match:
            return match.group('DIRECTORY_NAME')


def get_oam_variables(directory):
    oam_type = AirScale(autoconnect=True).oam_type
    if oam_type == 'COAM':
        with open(directory + 'coam_variables.json', 'r') as variable_file:
            return json.loads(variable_file.read())
    elif oam_type == 'MZOAM':
        with open(directory + 'mzone_variables.json', 'r') as variable_file:
            return json.loads(variable_file.read())
    else:
        MolerTest.error("Unknown OAM type")


def set_required_suite_variables(required_variables_dict):
    for var_name, var_value in required_variables_dict.items():
        if BuiltIn().get_variable_value(var_name) is None:
            if var_value:
                BuiltIn().set_suite_variable(var_name, *var_value)
            else:
                BuiltIn().set_suite_variable(var_name, '@{EMPTY}')

"""
:copyright: Nokia Networks
:author: Aleksander Kleczek, Dawid Krawczuk, Maciej Pikula
:contact:
:maintainer: None
:contact: None
"""
from __future__ import print_function
from __future__ import absolute_import
from robot.libraries.BuiltIn import BuiltIn
import mock
from robot.running.arguments.argumentvalidator import ArgumentValidator
from robot.api import logger
from robot.libraries.BuiltIn import RobotNotRunningError
from testsuite.Hangzhou.RRM.RAN_L3_SW_CN_LTE.trunk_sbts.CRT.LTE2275.\
    LTE2275_resource.common.robot_managment import *

patcher = mock.patch.object(ArgumentValidator, 'validate', return_value=True)
patcher.start()

try:
    DISPLAY_STEPS = robot_get_variable("${steps}", default=False)
    DISPLAY_TIME = robot_get_variable("${show_time}", default=False)
except RobotNotRunningError:
    DISPLAY_STEPS = False
    DISPLAY_TIME = False

try:
    BuiltIn().import_library('ta_messaging')
    BuiltIn().import_library('ta_measurements')
    BuiltIn().import_library('ta_emss')
    BuiltIn().import_library('ta_egate_cmd_parser')
    BuiltIn().import_library('testsuite/Hangzhou/RRM/RAN_L3_SW_CN_LTE/trunk_sbts/CRT/'
                             'LTE2275/LTE2275_resource/common/Logger.py')
    BuiltIn().import_library('testsuite/Hangzhou/RRM/RAN_L3_SW_CN_LTE/trunk_sbts/CRT/'
                             'LTE2275/LTE2275_resource/common/egate_process_managment.py')
except RobotNotRunningError as e:
    print("Warining! ROBOT FRAMEWORK NOT RUNNING BUT TRYING TO IMPORT LIBRARIES!")


def DUMMY_KEYWORD():
    pass

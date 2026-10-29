"""
:copyright: Nokia Networks
:author: Mateusz Matusik <mateusz.matusik@nokia.com>
:maintainer: Mateusz Matusik <mateusz.matusik@nokia.com>
"""

from robot.libraries.BuiltIn import BuiltIn
import taf.rfrl.utilities.logger.custom_logger as logger
from shutil import copyfile
import json

tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)


def verify_if_parameter_is_set_to_expected_value(moc_data, parameter, value):
    assert moc_data['parameters'][parameter] == value


def copy_and_modify_swconfig(parameters_list=[],
                             source_path="commissionings/Krakow/swconfig/default_swconfig.txt",
                             target_path="custom_swconfig.txt"):
    copyfile(src=source_path, dst=target_path)
    parameters_list = [parameters_list] if isinstance(parameters_list, str) else parameters_list
    for parameter in parameters_list:
        add_param_to_swconfig(parameter, target_path)


def add_param_to_swconfig(parameter, path):
    with open(path, 'r+') as sw_config:
        raw_param = parameter.split("#", 1)[0].strip(" ")                   # drop comments in file
        logger.log_info_to_console(f"Searching {raw_param} in swconfig...")
        param_found = any([raw_param in line for line in sw_config])
        if not param_found:
            logger.log_info_to_console(f"Not found. Adding new {parameter=} to swconfig")
            sw_config.write(f"\n{parameter}\n")
        else:
            logger.log_info_to_console(f"'{parameter=}' already in swconfig, skipping.")

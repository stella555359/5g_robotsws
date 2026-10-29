# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Kamil Bucki
:contact: kamil.bucki@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import \
    copy_files_from_local_to_local
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console
from ute_common_admin.exception import AdminApiProcedureFailureException
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import (
    collect_scf_file, set_mrbts_nrbts_ids_on_delta, perform_recomissioning_with_delta,
    modify_object_operation_state_if_needed
)
from robot.libraries.BuiltIn import BuiltIn
from string import Template
import time
import re
import os


class DeltaRecommissioningFailureException(Exception):
    pass


class CellWithActivatedFeatureNotInExpectedRangeException(Exception):
    pass


class NoValidationError(Exception):
    pass


def __copy_delta_to_dir(delta_file, output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR}')):
    copy_files_from_local_to_local(delta_file, output_dir)
    new_path = os.path.join(output_dir, os.path.basename(delta_file))
    return new_path


def perform_delta_recomissioning(output_dir, delta=None, time_after_recom=120):
    time_after_recom = int(time_after_recom)
    if delta is None:
        delta = BuiltIn().get_variable_value("${DELTA_FILE}")
    scf_path = os.path.join(output_dir, "gnb_scf_coam_default.xml")
    collect_scf_file(final_path=scf_path)

    delta_file = __copy_delta_to_dir(delta_file=delta, output_dir=output_dir)
    cell = __validate_cell_for_delta(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    set_mrbts_nrbts_ids_on_delta(delta_file=delta_file)
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(nrCellId=cell)
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    logger_console("Trying to do recommissioning with {} ...".format(delta_file))

    try:
        perform_recomissioning_with_delta(path_to_delta=delta_file)
    except AdminApiProcedureFailureException as exp:
        BuiltIn().set_suite_variable("${ADMIN_API_ERROR}", exp.message)
        modify_object_operation_state_if_needed(delta_file=delta_file, scf_path=scf_path)
        perform_recomissioning_with_delta(path_to_delta=delta_file)

    logger_console("Sleeping {}s for proper setup rerun after delta...".format(time_after_recom))
    time.sleep(time_after_recom)


def __validate_cell_for_delta(cell):
    cell = int(cell) + 1
    proper_cells = [1, 2, 3, 4]
    if cell not in proper_cells:
        msg = 'Cell {} is not in proper range! Expected: {}'.format(cell, proper_cells)
        raise CellWithActivatedFeatureNotInExpectedRangeException(msg)
    cell = str(cell)
    logger_console("Proper cell {} can be commisioned to delta! Type: {}".format(cell, type(cell)))
    return cell


def perform_delta_recomissioning_with_error(output_dir, delta=None, time_after_recom=120):
    try:
        perform_delta_recomissioning(output_dir, delta, time_after_recom)
    except AdminApiProcedureFailureException as api_error:
        logger_console(type(api_error))
    logger_console("Sleeping {}s to wait for admin log data".format(5))
    time.sleep(120)


def validate_admin_error_in_logs(error_msg):
    admin_log_path = BuiltIn().get_variable_value("${ADMIN_DESTINATION}")
    with open(admin_log_path, 'r') as f:
        content = str(f.read())
        if not re.search(error_msg, content):
            raise NoValidationError


def validate_admin_error(error_msg):
    admin_error_message = BuiltIn().get_variable_value("${ADMIN_API_ERROR}")
    if not re.search(error_msg, admin_error_message):
        raise NoValidationError
    else:
        logger_console("\nError {} found!\n".format(error_msg))


def set_dynamically_quotas_sd_cell_celldeptype_mapping(delta_file, delta_setup):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    logger_console("Delta {} dynamic setup:".format(delta_file))
    with open(delta_file, 'r+') as delta_to_modify:
        delta = delta_to_modify.read()
        for values in delta_setup.values():
            for key, value in values.items():
                if value is not None:
                    if isinstance(value, dict):
                        cell_tech = BuiltIn().get_variable_value('${CELL_TECHNOLOGY}')
                        value = value[cell_tech]
                    key_without_dolar = key[1::]
                    mappings = {key_without_dolar: value}
                    template = Template(delta)
                    delta = template.safe_substitute(**mappings)
        delta_to_modify.seek(0)
        delta_to_modify.write(delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)

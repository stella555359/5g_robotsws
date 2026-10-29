# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Michal Maczek, Kamil Bucki
:contact: michal.maczek@nokia.com, kamil.bucki@nokia.com
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
import os


class DeltaRecommissioningFailureException(Exception):
    pass


class CellWithActivatedFeatureNotInExpectedRangeException(Exception):
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
    set_mrbts_nrbts_ids_on_delta(delta_file=delta_file)
    logger_console("Trying to do recommissioning with {} ...".format(delta_file))

    try:
        perform_recomissioning_with_delta(path_to_delta=delta_file)
    except AdminApiProcedureFailureException:
        modify_object_operation_state_if_needed(delta_file=delta_file, scf_path=scf_path)
        perform_recomissioning_with_delta(path_to_delta=delta_file)

    logger_console("Sleeping {}s for proper setup rerun after delta...".format(time_after_recom))
    time.sleep(time_after_recom)


def __validate_cell_for_delta(cell):
    cell = int(cell) + 1
    proper_cells = [1, 2, 3]
    if cell not in proper_cells:
        msg = 'Cell {} is not in proper range! Expected: {}'.format(cell, proper_cells)
        raise CellWithActivatedFeatureNotInExpectedRangeException(msg)
    cell = str(cell)
    logger_console("Proper cell {} can be commisioned to delta! Type: {}".format(cell, type(cell)))
    return cell


def set_quotas_sd_and_fdm_on_delta(delta_file, quotas, sd, fdm):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    cell = __validate_cell_for_delta(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[0]['max'],
                                          resourceGroup1_minQuota=quotas[0]['min'],
                                          resourceGroup2_maxQuota=quotas[1]['max'],
                                          resourceGroup2_minQuota=quotas[1]['min'],
                                          actfdmstate=fdm,
                                          nrCellId=cell,
                                          cellDepType='SA+NSA',
                                          sdValue1=sd[0],
                                          sdValue2=sd[1])
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)


def set_one_quotas_sd_and_fdm_on_delta(delta_file, quotas, sd, fdm):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    cell = __validate_cell_for_delta(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[0]['max'],
                                          resourceGroup1_minQuota=quotas[0]['min'],
                                          actfdmstate=fdm,
                                          nrCellId=cell,
                                          sdValue1=sd[0])
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)


def set_quotas_on_delta(delta_file, quotas):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    cell = __validate_cell_for_delta(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[0]['max'],
                                          resourceGroup1_minQuota=quotas[0]['min'],
                                          resourceGroup2_maxQuota=quotas[1]['max'],
                                          resourceGroup2_minQuota=quotas[1]['min'],
                                          nrCellId=cell)
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)


def set_quotas_with_resource_dns_on_delta(delta_file, quotas, resource_dns):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    cell = __validate_cell_for_delta(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[0]['max'],
                                          resourceGroup1_minQuota=quotas[0]['min'],
                                          resourceGroup2_maxQuota=quotas[1]['max'],
                                          resourceGroup2_minQuota=quotas[1]['min'],
                                          nrCellId=cell,
                                          resourceGroup1_dn=resource_dns[0],
                                          resourceGroup2_dn=resource_dns[1])
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)


def set_3_quota_on_delta(delta_file, quotas):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[0]['max'],
                                          resourceGroup1_minQuota=quotas[0]['min'],
                                          resourceGroup2_maxQuota=quotas[1]['max'],
                                          resourceGroup2_minQuota=quotas[1]['min'],
                                          resourceGroup3_maxQuota=quotas[2]['max'],
                                          resourceGroup3_minQuota=quotas[2]['min'])
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)


def set_6_quota_on_delta(delta_file, quotas):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[0]['max'],
                                          resourceGroup1_minQuota=quotas[0]['min'],
                                          resourceGroup2_maxQuota=quotas[1]['max'],
                                          resourceGroup2_minQuota=quotas[1]['min'],
                                          resourceGroup3_maxQuota=quotas[2]['max'],
                                          resourceGroup3_minQuota=quotas[2]['min'],
                                          resourceGroup4_maxQuota=quotas[3]['max'],
                                          resourceGroup4_minQuota=quotas[3]['min'],
                                          resourceGroup5_maxQuota=quotas[4]['max'],
                                          resourceGroup5_minQuota=quotas[4]['min'],
                                          resourceGroup6_maxQuota=quotas[5]['max'],
                                          resourceGroup6_minQuota=quotas[5]['min']
                                          )
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)


def set_quotas_fdm_one_slice_delta(delta_file, quotas):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    cell = __validate_cell_for_delta(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[0]['max'],
                                          resourceGroup1_minQuota=quotas[0]['min'],
                                          nrCellId=cell,
                                          cellDepType='SA+NSA')
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)


def set_quotas_sd_with_3slices_on_delta(delta_file, quotas, sd):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    cell = __validate_cell_for_delta(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[0]['max'],
                                          resourceGroup1_minQuota=quotas[0]['min'],
                                          resourceGroup2_maxQuota=quotas[1]['max'],
                                          resourceGroup2_minQuota=quotas[1]['min'],
                                          resourceGroup3_maxQuota=quotas[2]['max'],
                                          resourceGroup3_minQuota=quotas[2]['min'],
                                          nrCellId=cell,
                                          sdValue1=sd[0],
                                          sdValue2=sd[1],
                                          sdValue3=sd[2])
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)


def set_nsa_quotas_sd_with_3slices_on_delta(delta_file, quotas, sd, resourceGroup_dn_list):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    cell = __validate_cell_for_delta(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    cell = int(cell) - 1
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())

        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[resourceGroup_dn_list[0]]['max'],
                                          resourceGroup1_minQuota=quotas[resourceGroup_dn_list[0]]['min'],
                                          resourceGroup2_maxQuota=quotas[resourceGroup_dn_list[1]]['max'],
                                          resourceGroup2_minQuota=quotas[resourceGroup_dn_list[1]]['min'],
                                          resourceGroup3_maxQuota=quotas[resourceGroup_dn_list[2]]['max'],
                                          resourceGroup3_minQuota=quotas[resourceGroup_dn_list[2]]['min'],
                                          resourceGroup1_dn=resourceGroup_dn_list[0],
                                          resourceGroup2_dn=resourceGroup_dn_list[1],
                                          resourceGroup3_dn=resourceGroup_dn_list[2],
                                          nrCellId=cell,
                                          sdValue1=sd[0],
                                          sdValue2=sd[1],
                                          sdValue3=sd[2])
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)


def set_quotas_sd_with_4slices_on_delta(delta_file, quotas, sd):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    cell = __validate_cell_for_delta(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[0]['max'],
                                          resourceGroup1_minQuota=quotas[0]['min'],
                                          resourceGroup2_maxQuota=quotas[1]['max'],
                                          resourceGroup2_minQuota=quotas[1]['min'],
                                          resourceGroup3_maxQuota=quotas[2]['max'],
                                          resourceGroup3_minQuota=quotas[2]['min'],
                                          resourceGroup4_maxQuota=quotas[3]['max'],
                                          resourceGroup4_minQuota=quotas[3]['min'],
                                          nrCellId=cell,
                                          sdValue1=sd[0],
                                          sdValue2=sd[1],
                                          sdValue3=sd[2],
                                          sdValue4=sd[3])
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)


def set_quotas_nsa_sa_slice_delta(delta_file, quotas):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    cell = __validate_cell_for_delta(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[0]['max'],
                                          resourceGroup1_minQuota=quotas[0]['min'],
                                          resourceGroup2_maxQuota=quotas[1]['max'],
                                          resourceGroup2_minQuota=quotas[1]['min'],
                                          resourceGroup3_maxQuota=quotas[2]['max'],
                                          resourceGroup3_minQuota=quotas[2]['min'],
                                          nrCellId=cell)
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)


def set_quotas_6_nsa_slices(delta_file, quotas):
    delta_file = __copy_delta_to_dir(delta_file=delta_file)
    cell = __validate_cell_for_delta(BuiltIn().get_variable_value('${CELL_WITH_ACTIVATED_FEATURE}'))
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(resourceGroup1_maxQuota=quotas[0]['max'],
                                          resourceGroup1_minQuota=quotas[0]['min'],
                                          resourceGroup2_maxQuota=quotas[1]['max'],
                                          resourceGroup2_minQuota=quotas[1]['min'],
                                          resourceGroup3_maxQuota=quotas[2]['max'],
                                          resourceGroup3_minQuota=quotas[2]['min'],
                                          resourceGroup4_maxQuota=quotas[3]['max'],
                                          resourceGroup4_minQuota=quotas[3]['min'],
                                          resourceGroup5_maxQuota=quotas[4]['max'],
                                          resourceGroup5_minQuota=quotas[4]['min'],
                                          resourceGroup6_maxQuota=quotas[5]['max'],
                                          resourceGroup6_minQuota=quotas[5]['min'],
                                          nrCellId=cell)
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    BuiltIn().set_suite_variable("${DELTA_READY_TO_COM}", delta_file)

import os
import random
import time
from taf.config.scf import scf
from robot.api import logger
import testsuite.Wroclaw.RRM.resources.webUI_operations as webui
from testsuite.Wroclaw.RRM.resources.rrm_fixture import (
    get_robot_variable,
    webUI,
)
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id
from ute_admin_infomodel import ute_admin_infomodel
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import get_cells_identifiers


def prepare_cell_deletion_delta(cell_id, scf_obj, actual, target, output_dir):
    delta_filepath = os.path.join(output_dir, f'del_cell_{cell_id}.json')
    scf_obj.calculate_delta_scf(target_scf_path=target, actual_scf_path=actual,
                                delta_scf_path=delta_filepath)
    return delta_filepath


def prepare_cell_addition_delta(cell_id, scf_obj, actual, target, output_dir):
    delta_filepath = os.path.join(output_dir, f'add_cell_{cell_id}.json')
    scf_obj.calculate_delta_scf(target_scf_path=target, actual_scf_path=actual,
                                delta_scf_path=delta_filepath)
    return delta_filepath


def prepare_delta_files(cell_id):
    output_dir = get_robot_variable("${LOG_PATH}")
    modified_scf = os.path.join(output_dir, 'removed_cell.xml')
    original_scf = webui.download_current_scf('original_scf.xml')
    nr_cell_grp = None
    new_scf = scf()
    new_scf.load_scf(original_scf)

    lcrid = new_scf.get_value_from_scf(dist_name=f"MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}", p_name="lcrId")
    new_scf.remove_mo_with_descendant_mos(dist_name=f'MRBTS-{mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{lcrid}')

    new_scf.remove_mo_with_descendant_mos(dist_name=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}')
    delete_cell_relations(lcrid, new_scf)
    disable_energy_saving_for_cell(cell_id, new_scf)

    ref_nr_cell_group_list = new_scf.get_all_values_from_scf(
        dist_name=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1',
        list_name='refNrCellGroup')

    for grp in ref_nr_cell_group_list:
        cell_in_group = new_scf.get_value_from_scf(dist_name=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELLGRP-{grp}',
                                                   list_name='nrCellList')
        if cell_in_group == cell_id:
            nr_cell_grp = grp

    logger.debug(nr_cell_grp)

    new_scf.remove_mo_with_descendant_mos(dist_name=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELLGRP-{nr_cell_grp}')

    ref_nr_cell_index = ref_nr_cell_group_list.index(str(nr_cell_grp))
    new_scf.remove_element_from_scf(dist_name=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1',
                                    list_name='refNrCellGroup',
                                    index=ref_nr_cell_index)

    new_scf.save_scf(modified_scf)
    prepare_cell_deletion_delta(cell_id, new_scf, actual=original_scf, target=modified_scf, output_dir=output_dir)
    prepare_cell_addition_delta(cell_id, new_scf, actual=modified_scf, target=original_scf, output_dir=output_dir)


def delete_cell_relations(cell_id, new_scf):
    admin = ute_admin_infomodel()
    alias = f'del_rel_{cell_id}'
    try:
        admin.setup_infomodel(alias=alias)
        admin.connect_infomodel(alias=alias)
        nrrels = admin.query_infomodel(query=f'get list /MRBTS-*//NRBTS_A-*/NRCELL_A-*/NRREL_A-* is [lcrId={cell_id}]',
                                       allow_negative_result=True, alias=alias)
        for nrrel in nrrels:
            logger.debug(f"NRREL: {nrrel}")
            mrbts_index = nrrel['dist_name'].find('MRBTS_A')
            relation = nrrel['dist_name'][mrbts_index:].replace('_A', '')
            logger.debug(f"Dist name: {relation}")
            new_scf.remove_element_from_scf(dist_name=relation)
    finally:
        admin.teardown_infomodel(alias=alias)


def remove_cell(cell_id):
    output_dir = get_robot_variable("${LOG_PATH}")
    delta_filepath = os.path.join(output_dir, f'del_cell_{cell_id}.json')
    prepare_delta_files(cell_id)
    logger.info(f"Removing cell: {cell_id}")
    with webUI.WebUIOperations() as coam:
        coam.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                           should_activate=True, timeout=300)


def add_cell(cell_id):
    output_dir = get_robot_variable("${LOG_PATH}")
    delta_filepath = os.path.join(output_dir, f'add_cell_{cell_id}.json')
    logger.info(f"Adding cell: {cell_id}")
    with webUI.WebUIOperations() as coam:
        coam.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                           should_activate=True, timeout=300)


def select_random_nr_cell():
    nr_cells = get_cells_identifiers(identifier='globalCellId', cell_type='nr')
    return random.choice(nr_cells)


def disable_energy_saving_for_cell(cell_id, scf_obj):
    nrpgrp_dist_name = f"MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1"
    energy_saving = scf_obj.get_all_values_from_scf(dist_name=f"MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1",
                                                    list_name="lbpsCellList",
                                                    p_name="nrCellId")
    logger.debug(f"Energy saving: {energy_saving}")
    if not energy_saving:
        return

    if len(energy_saving) == 1 and str(cell_id) in energy_saving:
        nr_cells = get_cells_identifiers(identifier='globalCellId', cell_type='nr')
        nr_cells.remove(cell_id)
        other_cell = random.choice(nr_cells)
        scf_obj.modify_scf_element(
            dist_name=nrpgrp_dist_name,
            list_name="lbpsCellList",
            p_name="nrCellId",
            value=other_cell
        )
    elif len(energy_saving) > 1 and str(cell_id) in energy_saving:
        index = energy_saving.index(cell_id)
        logger.debug("INDEX: {}".format(index))
        scf_obj.perform_scf_modification([f'delete:NRPGRP-1:lbpsCellList:{{}}|nrCellId={cell_id}'])
    return scf_obj

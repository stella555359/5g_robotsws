import os
import operator
from typing import List, Union
from robot.api import logger
from database import random_bandwidth, field_info
from collections import defaultdict, OrderedDict
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable
from taf.config.scf import scf
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id
import testsuite.Wroclaw.RRM.resources.webUI_operations as Webui
from parameters import configurations
from rmod_type import Rmod
from cell_type import FddCell, TddCell
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.DynamicRegression.resources.utils import (
    merge_delta, load_json_delta, save_delta_to_json_file)
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession


DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)))


def get_cells() -> List[Union[FddCell, TddCell]]:
    cells = []
    with AdminSession() as admin:
        for cell in admin.get_cell_list()['cells']['nr']:
            if cell['technology'] == 'FDD':
                cells.append(FddCell(cell))
            elif cell['technology'] == 'TDD':
                cells.append(TddCell(cell))
            else:
                logger.error(f"Technology was not found for cell: {cell['globalCellId']}!")
    return cells


def get_rmods() -> List[Rmod]:
    rmods = []
    with AdminSession() as admin:
        for rmod in admin.get_parameters_for_all("RMOD"):
            rmods.append(Rmod(rmod))
    return rmods


def prepare_new_configuration():
    output_dir = get_robot_variable("${LOG_PATH}")
    new_config = defaultdict(lambda: defaultdict(int))
    cell_mapping = get_cell_mapping_per_rmod()

    delta = []
    for cell in cell_mapping:
        logger.info(f"Cell: {cell}, band: {cell.band}", also_console=True)
        bandwidth = random_bandwidth(cell.band)
        logger.info(f"Current bandwidth {cell.chbw}, random bandwidth: {bandwidth}", also_console=True)
        if cell.band in field_info and bandwidth != cell.chbw:
            logger.info(f"Band {cell.band} found in database", also_console=True)
            new_config[cell.band][bandwidth] += 1
            logger.info(f"Selected new configuration: {new_config}", also_console=True)
            current_delta = change_chbw(cell, bandwidth, cell_mapping)
            current_delta = load_json_delta(current_delta)
            delta = merge_delta(delta, current_delta)
            logger.info(f"Bandwidth changed for cell {cell} to {bandwidth}", also_console=True)
        elif cell.chbw == bandwidth:
            new_config[cell.band][bandwidth] += 1
            logger.info("Selected band already set!", also_console=True)
        else:
            logger.warn(f"Band {cell.band} was not found in database!")
    filepath = save_delta_to_json_file(delta, delta_filepath=os.path.join(output_dir, 'new_config.json'))
    if delta:
        activate_new_config(filepath)
    return new_config


def change_chbw(cell, chbw, cell_mapping=None):
    rmod = cell_mapping[cell]
    delta = prepare_delta_for_cell(cell, rmod, chbw)
    return delta


def activate_new_config(delta):
    logger.info(f"Performing delta comissioning {delta}")
    with AdminSession() as admin:
        result = admin.perform_delta_recommissioning(delta_file=delta, skip_parameter_relation_errors=False,
                                                     should_activate=True, timeout=300)
        logger.info(f"RESULT: {result}")
        logger.info("Delta comissioning finished!")
    Webui.wait_for_all_cells_on_air_state(timeout=600)


def get_cell_mapping_per_rmod():
    cell_mapping = {}
    rmods = get_rmods()
    cells = get_cells()
    for rmod in rmods:
        for cell in cells:
            if rmod.rmod_id == cell.rmod_id:
                cell_mapping[cell] = rmod
    cell_mapping = OrderedDict(sorted(cell_mapping.items()))
    logger.info(f"Available RMODS: {cell_mapping.items()}", also_console=True)
    return cell_mapping


def prepare_delta_for_cell(cell, rmod, chbw):
    output_dir = get_robot_variable("${LOG_PATH}")
    current_scf = 'scf_nr.xml'
    target_scf = os.path.join(output_dir, f'scf_nr_{cell}_{rmod}_{chbw}.xml')
    delta_filepath = os.path.join(output_dir, f'delta_nr_{cell}_{rmod}_{chbw}.json')

    current_scf = Webui.download_current_scf(current_scf)

    new_scf = scf()
    new_scf.load_scf(current_scf)
    for param, value in configurations[rmod.name][chbw].items():
        if 'bwpDN' in param:
            set_bwp_distname(cell, new_scf, param, value)
            continue
        if 'chBw' in param:
            set_bandwith(cell, param, value, scf_obj=new_scf)
            continue
        new_scf.modify_scf_element(value=value, dist_name=cell.NRCELL_DISTNAME.format(mrbts_id=mrbts_id,
                                                                                      nrbts_id=nrbts_id,
                                                                                      cell_id=cell.cell_id),
                                   p_name=param)

    new_scf.save_scf(target_scf)
    new_scf.calculate_delta_scf(target_scf_path=target_scf, actual_scf_path=current_scf,
                                delta_scf_path=delta_filepath)

    os.remove(current_scf)
    os.remove(target_scf)
    return delta_filepath


def set_bwp_distname(cell, scf_obj, param, value):
    for index, bwp in enumerate(value):
        bwp_distname = cell.BWP_PROFILE_FORMAT.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id, bwp_id=bwp)
        scf_obj.modify_scf_element(value=bwp_distname, dist_name=cell.NRCELL_DISTNAME.format(mrbts_id=mrbts_id,
                                                                                             nrbts_id=nrbts_id,
                                                                                             cell_id=cell.cell_id),
                                   p_name=param, list_name='cellBwpList', index=index)


def set_bandwith(cell, param, bandwith, scf_obj):
    scf_obj.modify_scf_element(value=bandwith, dist_name=cell.distname_format().format(mrbts_id=mrbts_id,
                                                                                       nrbts_id=nrbts_id,
                                                                                       cell_id=cell.cell_id),
                               p_name=param)

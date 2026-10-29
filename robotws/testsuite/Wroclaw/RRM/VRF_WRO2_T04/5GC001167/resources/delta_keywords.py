import os
import json
from jinja2 import Template
from taf.config.scf import scf
from ute_admin_infomodel import ute_admin_infomodel
import testsuite.Wroclaw.RRM.resources.webUI_operations as webUI
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import get_scf_from_nr
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.delta_utils import get_parameter_value
from robot.api import logger
from keywords_1167 import verify_scell_operational_existence

ALLOWED_NRRELS_IDS = (1, 2)
NRREL_DISTNAME_FORMAT = 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}'
DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_templates')


def load_delta_template(filename):
    delta_filepath = os.path.join(DELTA_DIR, filename)
    with open(delta_filepath) as f:
        return Template(f.read())


def add_nrrel(from_cell, to_cell):
    template = load_delta_template('add_nrrel.json')
    existing_ids = find_existing_nrrels_ids(from_cell)
    nrrel_id = list(set(ALLOWED_NRRELS_IDS).difference(existing_ids)).pop()
    delta = template.render(cell_id=from_cell, target_cell=to_cell, mrbts_id=mrbts_id,
                            nrbts_id=nrbts_id, nrrel_id=nrrel_id)
    __perform_delta(delta)


def remove_nrrel(from_cell, to_cell):
    template = load_delta_template('del_nrrel.json')
    nrrel_id = find_nrrel_id(from_cell, to_cell)
    delta = template.render(cell_id=from_cell, target_cell=to_cell, mrbts_id=mrbts_id,
                            nrbts_id=nrbts_id, nrrel_id=nrrel_id)
    __perform_delta(delta)


def num_of_possible_scells(pcell=1, method='blind'):
    admin = ute_admin_infomodel()
    try:
        admin.setup_infomodel()
        admin.connect_infomodel()
        return len(admin.query_infomodel(
            query='get list /MRBTS-*//NRBTS_A-*/NRCELL_A-{}/NRREL_A-* is [sCellAdditionMethod={}]'
                  .format(pcell, method), allow_negative_result=True))
    finally:
        admin.teardown_infomodel()


def restore_second_scell_if_needed(from_cell=106, to_cell=101):
    if num_of_possible_scells(pcell=1) != 2:
        add_scell_addition_method(from_cell=from_cell, to_cell=to_cell)


def add_scell_addition_method(from_cell, to_cell, add_method='blind', operational_mode='dlOnly'):
    to_cell = to_cell.split(',') if isinstance(to_cell, str) else [to_cell]
    nrrel_ids = []
    for dst_cell in to_cell:
        nrrel_id = find_nrrel_id(from_cell, dst_cell)
        nrrel_ids.append(nrrel_id)
    template = load_delta_template('scell_add.jinja2')
    delta = template.render(cell_id=from_cell, mrbts_id=mrbts_id, nrbts_id=nrbts_id, nrrel_ids=nrrel_ids,
                            add_method=add_method, operational_mode=operational_mode)
    logger.debug(delta)
    __perform_delta(delta)


def remove_scell_addition_method(from_cell, to_cells, revert_delta_filename=None):
    """
    :param from_cell: single value
    :param to_cells: multiple values, separated by comma
    :param revert_delta_filename: filename for revert file
    """
    ca_support_list = get_parameter_value(f"MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1",
                                          parameter='',
                                          list_name='carrierAggregationSupportList')
    logger.debug(ca_support_list)
    to_cells = to_cells.split(',') if isinstance(to_cells, str) else [to_cells]
    nrrel_ids = []
    scell_operationals = []
    scell_operational_ul = False
    for dst_cell in to_cells:
        nrrel_id = find_nrrel_id(from_cell, dst_cell)
        logger.debug(f"Found nrrel id from cell: {from_cell} to cell: {dst_cell} -> {nrrel_id}")
        nrrel_ids.append(nrrel_id)
        scell_operational = verify_scell_operational_existence(from_cell, nrrel_id)
        logger.debug(f"NRREL scell operational: {scell_operational}")
        scell_operationals.append(scell_operational)
    if any('Ul' in element for element in scell_operationals):
        ca_support_list = [f"{item}" for item in ca_support_list if "Ul" not in item]
        scell_operational_ul = True
    template = load_delta_template('scell_del.jinja2')
    delta = template.render(cell_id=from_cell, mrbts_id=mrbts_id, nrbts_id=nrbts_id, nrrel_ids=nrrel_ids,
                            scell_operational_ul=scell_operational_ul, ca_support_list=ca_support_list)
    logger.debug(delta)
    __perform_delta(delta)
    if revert_delta_filename:
        output_dir = get_robot_output_dir()
        scf_before = os.path.join(output_dir, 'sCellOperationalMode.xml')
        scf_after = get_scf_from_nr(output_dir, 'scf_after_delta.xml')
        s = scf()
        s.calculate_delta_scf(target_scf_path=scf_before, actual_scf_path=scf_after,
                              delta_scf_path=f'{output_dir}/{revert_delta_filename}')
        os.remove(scf_before)
        os.remove(scf_after)
        return f'{output_dir}/{revert_delta_filename}'


def __perform_delta(delta_str):
    with webUI.WebUIOperations() as coam:
        coam.perform_delta_recommissioning(delta_file=delta_str, skip_parameter_relation_errors=False,
                                           should_activate=True, timeout=300)


def find_existing_nrrels_ids(cell_id):
    def get_nrrel_id(dist_name):
        return int(dist_name.split('-')[-1])

    admin = ute_admin_infomodel()
    try:
        admin.setup_infomodel()
        admin.connect_infomodel()
        nrrels = admin.query_infomodel(query='get list /MRBTS-*//NRBTS_A-*/NRCELL_A-{}/NRREL_A-*'
                                       .format(cell_id), allow_negative_result=True)
        return [get_nrrel_id(item['dist_name']) for item in nrrels]
    except IndexError:
        raise RuntimeError("There is no NRRELs for cell {}".format(cell_id))
    finally:
        admin.teardown_infomodel()


def find_nrrel_id(from_cell, to_cell):
    admin = ute_admin_infomodel()
    try:
        admin.setup_infomodel()
        admin.connect_infomodel()
        nrrel = admin.query_infomodel(query='get list /MRBTS-*//NRBTS_A-*/NRCELL_A-{}/NRREL_A-* is [lcrId={}]'
                                      .format(from_cell, to_cell), allow_negative_result=True)
        return nrrel[0]['dist_name'].split('-')[-1]
    except IndexError:
        raise RuntimeError("NRREL from cell {} to cell {} was not found!".format(from_cell, to_cell))
    finally:
        admin.teardown_infomodel()


def change_cell_mapping_to_2x2(cell_id):
    template = load_delta_template('2x2.json')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    __perform_delta(delta)


def restore_cell_mapping_to_4x4(cell_id):
    template = load_delta_template('4x4.json')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    __perform_delta(delta)


def restore_revert_delta(delta_filename):
    delta_filepath = os.path.join(get_robot_output_dir(), delta_filename)
    __perform_delta(delta_filepath)

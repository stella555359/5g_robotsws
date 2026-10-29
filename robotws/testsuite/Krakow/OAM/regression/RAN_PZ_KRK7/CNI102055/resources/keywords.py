import os
from random import choice
from robot.libraries.BuiltIn import logger
from typing import Dict, List
from testsuite.Krakow.resources.RAN_PZ_KRK7.tools import keywords
from ute_common_admin.exception import AdminApiProcedureFailureException

SCFs_dir_path = os.path.dirname(os.path.realpath(__file__)) + '/SCF_for_desired_TCs/'

"""
Dedicated keywords for automated test cases of CNI-102055.
"""


def get_scf_path_for_test_case(test_case_name: str, asir: bool = False) -> str:
    """Get path for desired test case.

    :param str test_case_name: _description_
    :param bool asir: _description_
    :raises FileNotFoundError: _description_
    :return str: _description_
    """
    active_release = keywords.get_sw_release_name()
    scf_filename = 'SCF.xml' if not asir else 'ASiR_SCF.xml'
    scf_file_path = SCFs_dir_path + f'/{active_release}/{test_case_name}/{scf_filename}'
    if not os.path.isfile(scf_file_path):
        raise FileNotFoundError(f'There are no ASiR SCF file for TC {test_case_name} for {active_release}')
    return scf_file_path


def block_all_cells_by_cell_type(rat: str):
    """Blocks all cells of desired type.

    :param str rat: RAT technology cells to block. <NR, LTE, WCDMA, GSM, TETRA>
    """
    with keywords.use_admin_connection() as connection:
        try:
            connection.block_all_cells(rat=rat)
        except AdminApiProcedureFailureException as e:
            logger.info(f'Blocking all {rat} cells has raised AdminApiProcedureFailureException: {e}.'
                        f'Checking if all desired cells were blocked...')
#            sleep(10)
            cells = connection.get_cells_info()
            _check_cells_status(cells, 'Blocked')


def unblock_all_cells_by_cell_type(rat: str):
    """Unblocks all cells of desired type.

    :param str rat: RAT technology cells to block. <NR, LTE, WCDMA, GSM, TETRA>
    """
    with keywords.use_admin_connection() as connection:
        try:
            connection.unblock_all_cells(rat=rat)
        except AdminApiProcedureFailureException as e:
            logger.info(f'Unblocking all {rat} cells has raised AdminApiProcedureFailureException: {e}.'
                        f'Checking if all desired cells were blocked...')
            cells = connection.get_cells_info()
            _check_cells_status(cells, 'Unblocked')


def keep_one_random_cell_unlocked(rat: str) -> str:
    """Blocks all cells by given RAT type and keeps one, randomly chosen, to be unlocked.

    :param str rat:
    :return str: dist_name of unlocked cell
    """
    with keywords.use_admin_connection() as connection:
        all_cells = connection.get_cell_list()
        cells_by_given_rat_type = all_cells.get('cells').get(rat.lower())

        block_all_cells_by_cell_type(rat=rat)

        randomly_chosen_cell = choice(cells_by_given_rat_type)
        distname = randomly_chosen_cell.get('id').get('configuration')
        connection.unblock_cell(distname)
        return distname


def _check_cells_status(cells: List[Dict], desired_blocking_state: str):
    """Checks if all given cells has desired blockingState.

    :param List[Dict] cells:
    :param str desired_status: 'Blocked', 'Unblocked'
    """
    for cell in cells:
        blocking_state = cell.get('status').get('blockingState')
        logger.console(blocking_state)
        from pprint import PrettyPrinter
        pp = PrettyPrinter(indent=2)
        if not blocking_state.lower() == desired_blocking_state.lower():
            raise ValueError(f'Cells should be {desired_blocking_state}, but at least one of them are not!'
                             f' The unwanted blockingState is {blocking_state.lower()}'
                             f'All cells: {pp.pformat(cells)}')

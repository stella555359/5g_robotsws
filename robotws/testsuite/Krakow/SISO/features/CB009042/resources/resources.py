"""
Resource file for CB009042 feature testing
Copyright: Nokia
Author: Agnieszka Bylica
Contact: agnieszka.bylica@nokia.com
"""
import logging
from random import shuffle, choice
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations


def get_randomised_list_of_cells_ids():
    gnb_cell = GnbCellOperations()
    all_cells_ids = gnb_cell.get_all_cells_id()
    logging.debug(f'All global cell IDs: {all_cells_ids}')
    all_cells_ids = list(all_cells_ids)
    shuffle(all_cells_ids)
    logging.debug(f'Randomised all global cell IDs: {all_cells_ids}')
    return all_cells_ids


def get_random_value_from_list(list_of_items):
    return choice(list_of_items)

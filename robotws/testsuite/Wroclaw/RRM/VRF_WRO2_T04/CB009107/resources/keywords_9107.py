import re
import time
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator_keywords import set_attenuation, initialise_attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.attenuators import ATTENUATOR
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from robot.api import logger


def trigger_ue_transfer_between_sectors(cell, src_sector, dst_sector, att_value=0, att_id=1):
    initialise_attenuator()
    src_ports = ATTENUATOR[f'NRCELL_{cell}']['ports'][f'S{src_sector}']
    dst_ports = ATTENUATOR[f'NRCELL_{cell}']['ports'][f'S{dst_sector}']
    set_attenuation(int(att_value), port=dst_ports, attenuator_id=att_id)
    time.sleep(1)
    set_attenuation(90, port=src_ports, attenuator_id=att_id)
    time.sleep(3)
    set_attenuation(int(att_value), port=src_ports, attenuator_id=att_id)


def block_cells(cells_list):
    if isinstance(cells_list, str):
        cells_list = [cells_list]
    with AdminSession() as admin:
        nr_cells_distnames = admin.get_ids_for_all('NRCEL')
        ln_cells_distnames = admin.get_ids_for_all('LNCEL')
        all_distnames = nr_cells_distnames + ln_cells_distnames
        for cell in cells_list:
            try:
                distname = [dist for dist in all_distnames if re.search(f'.*CEL.*_R-{cell}', dist)][0]
                admin.block_cell(distname)
            except IndexError:
                raise RuntimeError(f"Distname for cell {cell} was not found!")


def unblock_blocked_cells():
    with AdminSession() as admin:
        nr_cells = admin.get_cells_info(cell_type='nr')
        lte_cells = admin.get_cells_info(cell_type='lte')
        blocked_cells = [cell['id']['internal'] for cell in nr_cells + lte_cells
                         if cell['status']['blockingState'] == 'Blocked']
        logger.info("BLOCKED CELLS..")
        logger.info(blocked_cells, also_console=True)
        for cell_distname in blocked_cells:
            logger.info(f"DISTNAME: {cell_distname}")
            logger.info(cell_distname, also_console=True)
            admin.unblock_cell(dist_name=cell_distname)

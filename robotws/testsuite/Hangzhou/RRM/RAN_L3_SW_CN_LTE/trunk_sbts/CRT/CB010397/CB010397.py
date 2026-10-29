import datetime
# from functools import partial
# from pprint import pformat
# from threading import Event
# import ta_emss
from robot.api import logger
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
# from ta_emss import ta_emss
import time
# from ute_admin import ute_admin
# from ta_uexgate import ta_uexgate
# from ta_emil_parser import ta_emil_parser
# import re
# from telnetlib import Telnet


def get_psgrp_planned_time(offset_h, offset_min):
    """returns current UTC-0 time [day,hr,min] from TL shifted by given offset"""
    current_time = datetime.datetime.utcnow()
    planned_time = current_time + datetime.timedelta(hours=int(offset_h), minutes=int(offset_min))
    planned_day = planned_time.strftime("%a")
    planned_hr = planned_time.strftime(
        "%H",
    )
    planned_min = planned_time.strftime("%M")
    logger.debug("planned day:{}, hour:{}, minute:{}".format(planned_day, planned_hr, planned_min))
    return planned_day, planned_hr, planned_min


@keyword("Get cell-${cell_id} DL stats")
def get_cell_stats(cell_id: str) -> dict:
    uexgate = BuiltIn().get_library_instance("ta_uexgate")
    stats = None
    try:
        stats = uexgate.get_cell_stats(id=cell_id, type="dl_mac", unit="Mbps")
    except Exception as err:
        logger.warn(f"Warning: No cell-{cell_id} stats. err:", type(err))
    else:
        logger.info(f"Current cell-{cell_id} load: {stats['cur']:.2f} Mbps", also_console=True)
    return stats


def check_status_of_cells(timeout: int = 60, interval: int = 10, cell_type="lte", **cells_status: str) -> str:
    '''
    Extracts cells status info using Admin and waits specific timeout until is equal to given values
    type of statuses: 'administrativeState', 'availabilityStatus', 'blockingState', 'operationalState', 'usageState'
    :param **cells_status: LNCEL-1=Blocked,unlocked LNCEL-2=Unblocked,locked LNCEL-3=disabled
    '''
    admin = BuiltIn().get_library_instance("taf.sbts.oam.coam.admin")
    start_time = time.time()
    while (time.time() - start_time < timeout + interval):
        cells_info = admin.get_cells_info(cell_type=cell_type)
        cells_match = 0
        for cell_name, states in cells_status.items():
            logger.debug(cell_name + " -|- " + str(states))
            states = list(st.strip().lower() for st in states.split(","))
            logger.debug(cell_name + " -|- " + str(states))
            try:
                cell_info = list(filter(lambda cell: str(
                    cell["id"]["configuration"]).endswith(cell_name), cells_info))[0]
            except Exception:
                logger.warn(f"Exception: No such {cell_name} info. Probably not exists.")
                continue
            cell_info_status = dict(cell_info["status"])
            logger.debug(cell_info_status)
            state_match = 0
            for state in states:
                if state in [el.lower() for el in cell_info_status.values()]:
                    state_match += 1
                # print(f"{state_match = }")
            if state_match == len(states):
                cells_match += 1
                status = "- *** match ***"
            else:
                status = "- still waiting..."
            logger.info(f"{cell_name} status = {str(list(cell_info_status.values()))[1:-1] + ';':56}" +
                        f"expected = {str(states)[1:-1]:36}{status}")
        if cells_match == len(cells_status):
            logger.info(("All cells in desired statuses. "
                         + f"Time taken: {(time.time() - start_time):.2f} seconds"), also_console=True)
            return
        logger.info("Not all cells in desired statuses. Still waiting...")
        if time.time() - start_time < timeout:
            time.sleep(interval)
        else:
            break
    logger.error(f"Not all cells has reached desired statuses. Time taken: {(time.time() - start_time):.2f} seconds")
    raise ValueError("Not all cells has reached expected statuses. Check debug logs above to see states")


def get_cell_ids(cell_list):
    # return cell_list.split()
    return [(el.strip()) for el in cell_list.split(",")]


@keyword("Unblock cells [${cell_list}]")
def unblock_cells(cell_list):
    """
    Unblocks given cells via ADMIN
    """
    admin = BuiltIn().get_library_instance("taf.sbts.oam.coam.admin")
    cell_list = get_cell_ids(cell_list)
    for cell in cell_list:
        cell = admin.get_cell_id_by_configuration_id("LTE", cell)
        logger.info(f"Unblocking {cell}", also_console=True)
        admin.unblock_cell(cell)

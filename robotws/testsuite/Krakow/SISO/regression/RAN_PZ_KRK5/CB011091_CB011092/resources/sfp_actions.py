from taf.sbts.oam.coam.admin import admin
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.exceptions import IncorrectStatuses
import taf.rfrl.utilities.logger.custom_logger as logger


class NotAllExpectedCellsAreOnAir(Exception):
    pass


def action_with_sfp(action, sfp_id=1, radio_type="asirmod"):
    sfp_pattern = "MRBTS-81073/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-{}/LANE-1".format(sfp_id)
    api = admin()
    connection = api.connect_to()
    if len(connection.get_parameter_by_distname(dist_name=sfp_pattern)) > 0:
        if action == "Lock":
            logger.log_info_to_console(f"Locking SFP id {sfp_id} for {radio_type}", log_hierarchy=2)
            connection.lock(dist_name=sfp_pattern, timeout=60)
        elif action == "Unlock":
            logger.log_info_to_console(f"Unlocking SFP id {sfp_id} for {radio_type}", log_hierarchy=2)
            connection.unlock(dist_name=sfp_pattern, timeout=60)
    else:
        logger.log_warn_to_console(f"Cannot perform action for SFP {sfp_id}. Object does not exist.", log_hierarchy=2)


def verify_expected_alarms_on_cells_and_state_on_rest_cells(impacted_cells, expected_alarms):
    logger.log_info_to_console(f"Veryfying expected alarms on cells ans on air state on other impacted cells",
                               log_hierarchy=2)
    api = admin()
    connection = api.connect_to()
    gnb_cell = GnbCellOperations()
    cell_with_alarm = None
    all_cells_should_be_impacted = False
    all_impacted_cells_statuses = []

    if len(expected_alarms) > 0:
        for expected_alarm in expected_alarms:
            all_active_alarms = connection.get_active_alarms()
            for alarm in all_active_alarms:
                if int(alarm["faultId"]) == int(expected_alarm) and \
                        alarm["faultName"] == expected_alarms[expected_alarm]:
                    cell_with_alarm = alarm["impactedCellsListCliInfo"][0]["NR"][0]["cellName"]
                    if alarm["notifier"] != "-":
                        all_cells_should_be_impacted = True
                        logger.log_info_to_console(f"All passing cells are impacted", log_hierarchy=3)
                    else:
                        logger.log_info_to_console(f"Impacted cells detected: {cell_with_alarm}", log_hierarchy=3)
    for impacted_cell in impacted_cells:
        if cell_with_alarm is None or int(impacted_cell) != int(cell_with_alarm) and \
                all_cells_should_be_impacted is False:
            logger.log_info_to_console(f"Veryfying on air state for impacted cell with id {impacted_cell}",
                                       log_hierarchy=3)
            try:
                gnb_cell.verify_cell_is_onair(cell_id=int(impacted_cell))
                all_impacted_cells_statuses.append(True)
                logger.log_info_to_console(f"Cell id {impacted_cell} is on air", log_hierarchy=4)
            except IncorrectStatuses as e:
                all_impacted_cells_statuses.append(False)
                logger.log_warn_to_console(f"Cell id {impacted_cell} is not on air", log_hierarchy=4)

    if False in all_impacted_cells_statuses:
        raise NotAllExpectedCellsAreOnAir(f"Not all expected cells are on air. Only cell with id {cell_with_alarm} "
                                          f"should be not on air")
    return True

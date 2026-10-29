"""
Operations on gNB Cell.

:copyright: Nokia Networks
:author: Rafal Kawa
:contact: rafal.kawa@nokia.com
:maintainer: rafal.kawa@nokia.com
"""

import logging
import os
import random
import time

from taf.internal.robot_typecasts import time_to_seconds
from taf.rfrl.bts.devices.exceptions import IncorrectStatuses
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.devices.generic_bts import login_logout, login_logout_GUI


class CellOperations(GnbCellOperations):
    """
    Cell operations.

    This class extends the GnbCellOperations class to provide additional functionalities
    for managing cell groups, including locking and unlocking cells, and verifying cell states.
    """

    def __init__(self):
        """
        Initializes the CellOperations class.
        """
        self.cell_ids = None
        self._alarm_operations = None
        super(GnbCellOperations, self).__init__()

    @property
    def alarm_operations(self):
        """
        Returns the GnbAlarmVerification instance.
        If the instance does not exist, it creates a new one and returns it.
        Returns:
            GnbAlarmVerification: The GnbAlarmVerification instance.
        """
        if self._alarm_operations is None:
            self._alarm_operations = GnbAlarmVerification()
        return self._alarm_operations

    @login_logout
    def lock_cell_group(self, cell_group_id=0, administrative_state=True, timeout=120, interval=10, bts_id=0, du_id=0):
        """
        Locks all cells in a specific cell group.

        Args:
            cell_group_id (int, optional): The ID of the cell group. Defaults to 0.
            administrative_state (bool, optional): The administrative state to set. Defaults to True.
            timeout (int, optional): The maximum time to wait for the status in seconds. Defaults to 180.
            interval (int, optional): The interval between status checks in seconds. Defaults to 10.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self.cell_ids = self._get_cell_ids_in_specific_cell_group(cell_group_id=cell_group_id, bts_id=bts_id,
                                                                  du_id=du_id)
        for cell_id in self.cell_ids:
            self.lock_cell(cell_id=cell_id, administrative_state=administrative_state, bts_id=bts_id, du_id=du_id)
            self.wait_for_cell_to_be_locked(bts_id=bts_id, cell_id=cell_id, timeout=timeout, interval=interval,
                                            du_id=du_id)
        logging.info(f"All cells from cell group '{cell_group_id}' was locked")

    @login_logout_GUI
    def lock_cells_from_cell_group_via_gui(self, cell_group_id=0, administrative_state=True, bts_id=0, du_id=0):
        """
        Locks all cells in a specific cell group via GUI.

        Args:
            cell_group_id (int, optional): The ID of the cell group. Defaults to 0.
            administrative_state (bool, optional): The administrative state to set. Defaults to True.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self.cell_ids = self._get_cell_ids_in_specific_cell_group(cell_group_id=cell_group_id, bts_id=bts_id,
                                                                  du_id=du_id)
        for cell_id in self.cell_ids:
            self.lock_cell_via_gui(cell_id=cell_id, administrative_state=administrative_state, bts_id=bts_id,
                                   du_id=du_id)
        self._verify_cell_group_is_locked(bts_id=bts_id, du_id=du_id)

    @login_logout
    def unlock_cell_group(self, cell_group_id=0, administrative_state=True, bts_id=0, du_id=0):
        """
        Unlocks all cells in a specific cell group.

        Args:
            cell_group_id (int, optional): The ID of the cell group. Defaults to 0.
            administrative_state (bool, optional): The administrative state to set. Defaults to True.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self.cell_ids = self._get_cell_ids_in_specific_cell_group(cell_group_id=cell_group_id, bts_id=bts_id,
                                                                  du_id=du_id)
        for cell_id in self.cell_ids:
            self.unlock_cell(cell_id=cell_id, administrative_state=administrative_state, bts_id=bts_id, du_id=du_id)
        self._verify_cell_group_is_unlocked(bts_id=bts_id, du_id=du_id)

    @login_logout_GUI
    def unlock_cells_from_cell_group_via_gui(self, cell_group_id=0, administrative_state=True, bts_id=0, du_id=0):
        """
        Unlocks all cells in a specific cell group via GUI.

        Args:
            cell_group_id (int, optional): The ID of the cell group. Defaults to 0.
            administrative_state (bool, optional): The administrative state to set. Defaults to True.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self.cell_ids = self._get_cell_ids_in_specific_cell_group(cell_group_id=cell_group_id, bts_id=bts_id,
                                                                  du_id=du_id)
        for cell_id in self.cell_ids:
            self.unlock_cell_via_gui(cell_id=cell_id, administrative_state=administrative_state, bts_id=bts_id,
                                     du_id=du_id)
        self._verify_cell_group_is_locked(bts_id=bts_id, du_id=du_id)

    @login_logout
    def block_cell_with_status_check(self, cell_id=1, check_alarm=False, bts_id=0, du_id=0):
        """
        Blocks cell and verify status.

        Args:
            cell_id (int, optional): The ID of the cell. Defaults to 1.
            check_alarm (bool, optional): Check presence of Cell blocked alarm. Defaults to True.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self.block_cell(cell_id=cell_id, bts_id=bts_id, du_id=du_id)
        self.wait_for_cell_statuses(cell_id=cell_id, blocking_state="blocked", operational_state="disabled",
                                    bts_id=bts_id, du_id=du_id)
        if check_alarm:
            self.alarm_operations.wait_for_alarm_activation(fault_id=49, bts_id=bts_id, du_id=du_id)

    @login_logout
    def block_cells_from_cell_group(self, cell_group_id=0, bts_id=0, du_id=0):
        """
        Blocks all cells in a specific cell group.

        Args:
            cell_group_id (int, optional): The ID of the cell group. Defaults to 0.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self.cell_ids = self._get_cell_ids_in_specific_cell_group(cell_group_id=cell_group_id, bts_id=bts_id,
                                                                  du_id=du_id)
        for cell_id in self.cell_ids:
            self.block_cell_with_status_check(cell_id=cell_id, bts_id=bts_id, du_id=du_id)

    @login_logout
    def unblock_cell_with_status_check(self, cell_id=1, check_alarm=False, bts_id=0, du_id=0):
        """
        Unblocks cell and verify status.

        Args:
            cell_id (int, optional): The ID of the cell. Defaults to 1.
            check_alarm (bool, optional): Check presence of Cell blocked alarm. Defaults to False.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self.unblock_cell(cell_id=cell_id, bts_id=bts_id, du_id=du_id)
        self.wait_for_cell_to_be_onair(cell_id=cell_id, bts_id=bts_id, du_id=du_id)
        if check_alarm:
            self.alarm_operations.wait_for_alarm_deactivation(fault_id=49, bts_id=bts_id, du_id=du_id)

    @login_logout
    def unblock_cells_from_cell_group(self, cell_group_id=0, bts_id=0, du_id=0):
        """
        Unblocks all cells in a specific cell group.

        Args:
            cell_group_id (int, optional): The ID of the cell group. Defaults to 0.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        self.cell_ids = self._get_cell_ids_in_specific_cell_group(cell_group_id=cell_group_id, bts_id=bts_id,
                                                                  du_id=du_id)
        for cell_id in self.cell_ids:
            self.unblock_cell_with_status_check(cell_id=cell_id, bts_id=bts_id, du_id=du_id)

    def check_number_of_enabled_cells(self, cell_number, bts_id=0, du_id=0, cell_type='nr'):
        """
        Checks if the number of enabled cells matches the expected number.

        Args:
            cell_number (int): The expected number of enabled cells.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            cell_type (str, optional): The type of the cell. Defaults to 'nr'.

        Raises:
            ValueError: If the number of enabled cells does not match the expected number.
        """
        enabled_cells = self.get_cells_with_status(status_name='operationalState', status_value='enabled',
                                                   bts_id=bts_id, du_id=du_id, cell_type=cell_type)
        if len(enabled_cells) != int(cell_number):
            raise ValueError(f"Incorrect number of enabled cells:'{len(enabled_cells)}', expected:'{cell_number}'."
                             f"'{self._get_all_cells_info(bts_id=bts_id, du_id=du_id, cell_type=cell_type)}'")

    def get_cells_with_status(self, status_name='operationalState', status_value='enabled',
                              bts_id=0, du_id=0, cell_type='nr'):
        """
        Retrieves cells with a specific status.

        Args:
            status_name (str, optional): The name of the status to check. Defaults to 'operationalState'.
            status_value (str, optional): The value of the status to check. Defaults to 'enabled'.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            cell_type (str, optional): The type of the cell. Defaults to 'nr'.

        Returns:
            list: A list of cells with the specified status.
        """
        return [cell for cell in self._get_all_cells_info(bts_id=bts_id, du_id=du_id, cell_type=cell_type) if
                cell['status'].get(status_name) == status_value]

    def get_current_cells_dist_name(self, bts_id=0, du_id=0, cell_type='nr', base_cell_name=False):
        """
        Retrieves the distinguished names of the current cells.

        Args:
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            cell_type (str, optional): The type of the cell. Defaults to 'nr'.
            base_cell_name (bool, optional): Whether to return only the base cell name. Defaults to False.

        Returns:
            list: A list of distinguished names of the current cells.
        """
        return [os.path.basename(cell["id"]["configuration"]) if base_cell_name else cell["id"]["configuration"] for
                cell in self._get_all_cells_info(bts_id=bts_id, du_id=du_id, cell_type=cell_type)]

    def get_specific_cells_dist_name(self, cell_ids, bts_id=0, du_id=0, cell_type='nr'):
        """
        Retrieves the distinguished names of specific cells.

        Args:
            cell_ids (list): A list of cell IDs to retrieve.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            cell_type (str, optional): The type of the cell. Defaults to 'nr'.

        Returns:
            list: A list of distinguished names of the specified cells.
        """
        return [cell["id"]["configuration"] for cell in
                self._get_all_cells_info(bts_id=bts_id, du_id=du_id, cell_type=cell_type) if
                cell["globalCellId"] in cell_ids]

    def get_uplink_cell_ids(self, bts_id=0, du_id=0, configuration_id=True, cell_type='nr'):
        """
        Retrieves the uplink cell IDs.

        This method iterates through all cells and identifies those with an RX direction,
        returning their configuration IDs or global cell IDs based on the configuration_id flag.

        Args:
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            configuration_id (bool, optional): Flag to determine if configuration IDs should be returned.
            Defaults to True.
            cell_type (str, optional): The type of the cell. Defaults to 'nr'.

        Returns:
            list: A list of uplink cell IDs.
        """
        ul_cells = []
        for cell in self._get_all_cells_info(bts_id=bts_id, du_id=du_id, cell_type=cell_type):
            for antenna in cell["carrierList"]:
                if antenna["direction"] == "RX":
                    ul_cells.append(
                        os.path.basename(cell["id"]["configuration"] if configuration_id else cell["globalCellId"]))
                    break
        return ul_cells

    def get_cell_ids_with_specific_channel_direction(self, bts_id=0, du_id=0, direction='RX', configuration_id=True,
                                                     cell_type='nr', cell_group_id=None):
        """
        Retrieves the cell IDs based on channel direction and optionally filters by cell group.

        This method iterates through all cells and identifies those with specified direction,
        returning their configuration IDs or global cell IDs optionally filtered by cell group id.

        Args:
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            direction (str, optional): The direction of channel: RX or TX. Defaults to RX.
            configuration_id (bool, optional): Flag to determine if configuration IDs should be returned.
            Defaults to True.
            cell_type (str, optional): The type of the cell. Defaults to 'nr'.
            cell_group_id (int, optional): The ID of the cell group. Defaults to None.

        Returns:
            list: A list of uplink cell IDs.
        """
        specific_cells = []
        for cell in self._get_all_cells_info(bts_id=bts_id, du_id=du_id, cell_type=cell_type):
            for antenna in cell["carrierList"]:
                if antenna["direction"] == direction:
                    specific_cells.append(
                        os.path.basename(cell["id"]["configuration"] if configuration_id else cell["globalCellId"]))
                    break
        if cell_group_id:
            # Filter cells from cell group
            cells_from_group = list(map(str, self._get_cell_ids_in_specific_cell_group(cell_group_id=cell_group_id,
                                                                                       bts_id=bts_id, du_id=du_id)))
            specific_cells = [cell for cell in specific_cells if cell.split("-")[-1] in cells_from_group]
        return specific_cells

    def get_all_runtime_antenna_lines_dist_name(self, bts_id=0, du_id=0, cell_type='nr', dist_name_type='internal'):
        """
        Retrieves the dist names of all runtime antenna lines.

        This method iterates through all cells and collects the distinguished names of the antenna lines
        based on the specified type.

        Args:
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            cell_type (str, optional): The type of the cell. Defaults to 'nr'.
            dist_name_type (str, optional): The type of dist name to retrieve. Defaults to 'internal'.

        Returns:
            list: A list of unique dist names of the antenna lines.
        """
        ants_dist = []
        for cell in self._get_all_cells_info(bts_id=bts_id, du_id=du_id, cell_type=cell_type):
            ants_dist.extend([ant["antennaLineId"][dist_name_type] for ant in cell["carrierList"]])
        return list(set(ants_dist))

    def wait_for_cell_energy_saving_status(self, cell_id=1, energy_saving_state="notEnergySaving", bts_id=0, du_id=0,
                                           timeout=120, interval=10):
        """
        Waits for a cell to reach a specific energy saving status.

        This method continuously checks the energy saving status of a specified cell until it matches
        the expected status or the timeout is reached.

        Args:
            cell_id (int, optional): The ID of the cell. Defaults to 1.
            energy_saving_state (str, optional): The expected state of the cell. Defaults to "notEnergySaving".
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            timeout (int, optional): The maximum time to wait for the status in seconds. Defaults to 120.
            interval (int, optional): The interval between status checks in seconds. Defaults to 10.

        Raises:
            IncorrectStatuses: If the cell does not reach the expected status within the timeout period.
        """
        start_time = time.time()
        last_exception = None
        end_time = start_time + time_to_seconds(time=timeout)
        interval_in_seconds = time_to_seconds(time=interval)
        while time.time() < end_time:
            try:
                self.verify_cell_energy_saving_state(cell_id=cell_id, energy_saving_state=energy_saving_state,
                                                     bts_id=bts_id,
                                                     du_id=du_id)
                break
            except IncorrectStatuses as e:
                last_exception = e
                time.sleep(interval_in_seconds)
        else:
            last_exception.additional_message = "The timeout has passed, and not all cell statuses are as expected"
            raise last_exception

    def get_cell_group_ids(self, bts_id=0, du_id=0, random_id=False):
        """
        Retrieves cell group IDs, optionally returning a random one.

        Args:
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            random_id (bool, optional): Whether to return a random cell group ID. Defaults to False.

        Returns:
            list or int: A list of cell group IDs or a single random cell group ID.
        """
        cell_group_ids = self._get_all_cell_group_ids(bts_id=bts_id, du_id=du_id)
        return random.choice(cell_group_ids) if random_id else cell_group_ids

    @login_logout
    def _verify_cell_group_is_locked(self, bts_id=0, du_id=0):
        """
        Verifies if all cells in the cell group are locked.

        Args:
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        for cell_id in self.cell_ids:
            self.verify_cell_is_locked(bts_id=bts_id, du_id=du_id, cell_id=cell_id)

    @login_logout
    def _verify_cell_group_is_unlocked(self, bts_id=0, du_id=0):
        """
        Verifies if all cells in the cell group are unlocked.

        Args:
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        for cell_id in self.cell_ids:
            self.verify_cell_is_unlocked(bts_id=bts_id, du_id=du_id, cell_id=cell_id)

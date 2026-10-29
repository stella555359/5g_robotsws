import re

from moler.util.moler_test import MolerTest
from taf.rfrl.bts.devices.du.combined.cell_operations import GnbCombinedCellOperations
from taf.rfrl.bts.devices.generic_bts import login_logout
from taf.rfrl.bts.devices.exceptions import CellNotOnAir, IncorrectStatuses
from taf.rfrl.bts.helpers.compare_statuses import verify_statuses, unify_statuses
from taf.internal.robot_typecasts import time_to_seconds
import logging
import time
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations


class GnbCell(GnbCellOperations):
    def __init__(self):
        super(GnbCell, self).__init__()

    @login_logout
    def verify_cell_is_onair(self, bts_id=0, cell_id=1, du_id=0, dist_name=None):
        """
        Verify 'Operational state' is 'Enabled' and 'Availability status' is 'Online'

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used, default set to 1.
        :param dist_name: optional, gsm cell dist name
        :return:        None
        """
        expected_statuses = {
            "availabilityStatus": "online",
            "operationalState": "enabled",
        }
        if not dist_name:
            dist_name = self._get_runtime_cell_dist_name(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
        if 'WNCEL' not in dist_name:
            expected_statuses.update({"administrativeState": "unlocked"})
        cell_specific_info = self.admin.get_cell_specific_info(cell_id=dist_name,
                                                               connection=self.rest_alias.format(bts_id, du_id))

        unify_statuses(cell_specific_info['status'], required_keys=expected_statuses.keys())
        verify_statuses(expected_statuses=expected_statuses,
                        received_statuses=cell_specific_info['status'],
                        device=dist_name)

        MolerTest.info("cell {} is 'OnAir'".format(dist_name if dist_name else cell_id))

    @login_logout
    def wait_for_cell_to_be_onair(self, bts_id=0, cell_id=1, timeout=120, interval=10, du_id=0, dist_name=None):
        """
        Verify 'Operational state' is 'Enabled' and 'Availability status' is 'Online' during timeout
        :param bts_id:      ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param cell_id:     ID of cell
        :param timeout:     wait for onAir status until timeout
        :param interval:    wait additional time after failed execution, before next attempt
        :param dist_name: optional, gsm cell dist name
        :return:            None
        """
        start_time = time.time()
        while time.time() < start_time + time_to_seconds(time=timeout):
            try:
                self.verify_cell_is_onair(bts_id=bts_id, cell_id=cell_id, du_id=du_id, dist_name=dist_name)
                logging.info("Cell {} is 'OnAir".format(cell_id))
                break
            except IncorrectStatuses:
                time.sleep(time_to_seconds(time=interval))
        else:
            raise CellNotOnAir("Timeout passed. Status in not onAir")

    @login_logout
    def verify_gsm_cell_is_blocked(self, dist_name, bts_id=0, du_id=0):
        """
        Verify gsm cell is blocked.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param dist_name: gsm cell dist name
        :return:        None
        """
        expected_statuses = {
            "blockingState": "blocked",
        }

        cell_specific_info = self.admin.get_cell_specific_info(cell_id=dist_name,
                                                               connection=self.rest_alias.format(bts_id, du_id))
        self._verify_bts_cell_statuses(expected_statuses=expected_statuses,
                                       cell_specific_info=cell_specific_info)
        MolerTest.info("Cell {} is blocked".format(dist_name))


class CellKeywords(GnbCombinedCellOperations):
    def __init__(self):
        super(CellKeywords, self).__init__()
        self.gnb_cell = GnbCell()

    def block_unblock_all_cells(self):
        self.block_unblock_all_cells_for_each_group()
        self.block_unblock_lte_wcdma_gsm_cells()

    @login_logout
    def block_unblock_all_cells_for_each_group(self, bts_id=0, du_id=0):
        """
        Blocks-unblock all cells for each cell group, then blocks-unblock cell group.

        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """

        cell_group_ids = self.cell._get_all_cell_group_ids(bts_id=bts_id, du_id=du_id)
        MolerTest.info("Cell groups:", dump=cell_group_ids)
        cell_dist_names = dict((cell_group_id, None) for cell_group_id in cell_group_ids)
        for cell_group_id in cell_group_ids:
            cell_dist_names[cell_group_id] = (
                self._get_cell_dist_names_in_specific_cell_group(bts_id=bts_id, cell_group_id=cell_group_id,
                                                                 du_id=du_id))
        MolerTest.info("Lock Unlock All Cells For Each Group started")
        for cell_group_id in cell_group_ids:
            MolerTest.info("Group {} started".format(cell_group_id))
            for cell_dist_name in cell_dist_names[cell_group_id]:
                cell_id = int(re.search(r'\d+$', cell_dist_name).group())
                MolerTest.info("Blocking/unblocking cell: {}".format(cell_id))
                self.cell.block_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
                self.cell.verify_cell_is_blocked(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
                self.verify_cell_blocked_alarm_is_active(fault_name='Cell blocked', object_names=[cell_dist_name])
                self.cell.unblock_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
                self.cell.wait_for_cell_to_be_onair(bts_id=bts_id, cell_id=cell_id, du_id=du_id)

    def _get_cell_dist_names_in_specific_cell_group(self, bts_id=0, cell_group_id=0, du_id=0):
        """
        Returns all cell dist names which are assigned to nrcellgrp

        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param cell_group_id:  Id of NRCELLGRP
        :return:    tuple
        """
        cell_groups_info = self.cell._get_cell_groups_info(bts_id=bts_id, du_id=du_id)
        cell_dist_names = []
        for cell_dist_name in [item for item in cell_groups_info
                               if item["name"] == "NRCELLGRP-{}".format(cell_group_id)][0]["nrCellList"]:
            cell_dist_names.append(cell_dist_name)
        MolerTest.info("Cell dist names in Cell group {}:".format(cell_group_id), dump=cell_dist_names)
        return tuple(cell_dist_names)

    @login_logout
    def block_unblock_lte_wcdma_gsm_cells(self, bts_id=0, du_id=0):
        bts_info = self.admin.get_bts_info(connection=self.rest_alias.format(bts_id, du_id))
        cell_types = ['lte', 'wcdma', 'gsm']
        cells_dict = {cell_type: [] for cell_type in cell_types}
        for cell_type in cell_types:
            for cell in bts_info['cells'][cell_type]:
                cells_dict[cell_type].append(cell['id']['configuration'])
                MolerTest.info("Cells to be blocked and unblocked:", dump=cells_dict)
        self.block_unblock_cells(cells_dict=cells_dict, bts_id=bts_id, du_id=du_id)

    def block_unblock_cells(self, cells_dict, bts_id=0, du_id=0):
        for cell_type in cells_dict:
            MolerTest.info("Group {} started".format(cell_type))
            for cell_dist_name in cells_dict[cell_type]:
                MolerTest.info("Blocking/unblocking cell: {}".format(cell_dist_name))
                if cell_type == 'gsm':
                    self.block_unblock_gsm_cell(cell_dist_name=cell_dist_name, bts_id=bts_id, du_id=du_id)
                else:
                    self.block_unblock_lte_or_wcdma_cell(cell_dist_name=cell_dist_name, bts_id=bts_id, du_id=du_id)

    def block_unblock_lte_or_wcdma_cell(self, cell_dist_name, bts_id=0, du_id=0):
        cell_id = int(re.search(r'\d+$', cell_dist_name).group())
        self.gnb_cell.block_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
        self.gnb_cell.verify_cell_is_blocked(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
        self.verify_cell_blocked_alarm_is_active(fault_name='Cell blocked', object_names=[cell_dist_name])
        self.gnb_cell.unblock_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
        self.gnb_cell.wait_for_cell_to_be_onair(bts_id=bts_id, cell_id=cell_id, du_id=du_id)

    def block_unblock_gsm_cell(self, cell_dist_name, bts_id=0, du_id=0):
        self.admin.block_cell(cell_dist_name, timeout=120, connection=self.rest_alias.format(bts_id, du_id))
        self.gnb_cell.verify_gsm_cell_is_blocked(dist_name=cell_dist_name, bts_id=bts_id, du_id=du_id)
        self.verify_cell_blocked_alarm_is_active(fault_name='Cell blocked', object_names=[cell_dist_name])
        self.admin.unblock_cell(cell_dist_name, connection=self.rest_alias.format(bts_id, du_id))
        self.gnb_cell.wait_for_cell_to_be_onair(bts_id=bts_id, du_id=du_id, dist_name=cell_dist_name)

    @login_logout
    def verify_cell_blocked_alarm_is_active(self, fault_name, object_names, bts_id=0, du_id=0):
        MolerTest.sleep(10)
        active_alarms_list = self.admin.get_active_alarms(connection=self.rest_alias.format(bts_id, du_id))
        error_list = object_names.copy()
        for object_name in object_names:
            for active_alarm in active_alarms_list:
                if active_alarm["faultName"] == fault_name and object_name in active_alarm["configObjectName"]:
                    error_list.remove(object_name)
                    break
        if error_list:
            MolerTest.error("Alarm {} is not active on:".format(fault_name), dump=error_list)

# -*- coding: utf-8 -*-
"""
Generic keywords for BTS.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
import re
import time
import logging
from taf.sbts.oam.coam.admin.exceptions\
    import IncorrectParameterValue, DataNotAvailable
from taf.internal.robot_typecasts import time_to_seconds
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.generic_bts\
    import GenericBts, login_logout, login_logout_GUI
from testsuite.Bangalore.ORAN.resources.python.Macro.\
    Python.bts.generic_resources\
    import GnbResources
from testsuite.Bangalore.ORAN.resources.python.\
    Macro.Python.exceptions import (CellNotOnAir,
                                    WrongNrarfcnFrequency,
                                    WrongBasicBeamSet,
                                    LockCellFailure)
from testsuite.Bangalore.ORAN.resources.python.\
    Macro.Python.bts.nrarfcn_calculator import CalculatorResources


class GenericCell(GenericBts):
    """Cell keywords for eNB and gNB"""

    @login_logout
    def verify_cell_statuses(self, bts_id=0, cell_id=1, du_id=0,
                             operational_state="Enabled",
                             procedural_status="configured",
                             availability_status="Online",
                             administrative_state="Unlocked"):
        """
        Verify gnb cell is locked.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used, default set to 1.
        :type cell_id:  int
        :param availability_status: cells availability status (online/offline)
        :param operational_state; cells operational state (enabled/disabled)
        :param procedural_status: cells procedural status
        (configured/dependency/initialization required)
        :param administrative_state: cells administrative state
        (unlocked/locked)
        :return:        None
        """
        expected_statuses = {
            "availabilityStatus": availability_status,
            "operationalState": operational_state,
            "proceduralStatus": procedural_status,
            "administrativeState": administrative_state,
        }

        dist_name = self._get_cell_dist_name(bts_id=bts_id, cell_id=cell_id,
                                             du_id=du_id)
        cell_specific_info = self.admin.get_cell_specific_info(
            cell_id=dist_name,
            connection=self.rest_alias.format(bts_id, du_id))

        self._verify_bts_cell_statuses(expected_statuses=expected_statuses,
                                       cell_specific_info=cell_specific_info)

    @login_logout
    def wait_for_cell_to_be_onair(self, bts_id=0, cell_id=1, timeout=120,
                                  interval=10, du_id=0):
        """
        Verify 'Operational state' is 'Enabled' and 'Availability status' is
        'Online' during timeout
        :param bts_id:      ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id:     ID of cell
        :param timeout:     wait for onAir status until timeout
        :param interval:    wait additional time after failed execution, before
         next attempt
        :return:            None
        """
        start_time = time.time()
        while time.time() < start_time+time_to_seconds(time=timeout):
            try:
                self.verify_cell_is_onair(bts_id=bts_id, cell_id=cell_id,
                                          du_id=du_id)
                logging.info("Cell {} is 'OnAir".format(cell_id))
                break
            except IncorrectParameterValue:
                time.sleep(time_to_seconds(time=interval))
        else:
            raise CellNotOnAir("Timeout passed. Status in not onAir")

    @login_logout
    def verify_cell_is_onair(self, bts_id=0, cell_id=1, du_id=0):
        """
        Verify 'Operational state' is 'Enabled' and 'Availability status' is
        'Online'

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used, default set to 1.
        :return:        None
        """
        expected_statuses = {
            "availabilityStatus": "Online",
            "operationalState": "Enabled",
            "administrativeState": "Unlocked",
        }

        dist_name = self._get_cell_dist_name(bts_id=bts_id, cell_id=cell_id,
                                             du_id=du_id)
        cell_specific_info = self.admin.get_cell_specific_info(
            cell_id=dist_name,
            connection=self.rest_alias.format(bts_id, du_id))

        self._verify_bts_cell_statuses(expected_statuses=expected_statuses,
                                       cell_specific_info=cell_specific_info)
        logging.info("cell {} is 'OnAir'".format(cell_id))

    @staticmethod
    def _verify_bts_cell_statuses(expected_statuses, cell_specific_info):
        """
        Verify bts cell statuses are as expected.

        :param expected_statuses:   dict with expected statuses.
        :return:                    None
        :raise:                     DataNotAvailable
        """

        try:
            for status in expected_statuses:
                if expected_statuses[status] != \
                        cell_specific_info["status"][status]:
                    logging.debug("Expected statuses: {}".format(
                        expected_statuses))
                    logging.debug("Received statuses: {}".format(
                        cell_specific_info["status"]))
                    raise IncorrectParameterValue(
                        "Expected status: {}, but received "
                        "status is: {}".format(
                            expected_statuses[status],
                            cell_specific_info["status"][status]))
        except KeyError as e:
            raise DataNotAvailable(
                "Cannot get expected status info: {}".format(repr(e)))

    @login_logout
    def lock_cell(self, bts_id=0, cell_id=1, du_id=0):
        """
        Lock gNB cell.
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id: cell id, default 1.
        :type cell_id:  int
        :return:        None
        """
        dist_name = self._get_cell_dist_name(bts_id=bts_id, cell_id=cell_id,
                                             du_id=du_id)
        self.admin.lock_cell(dist_name,
                             connection=self.rest_alias.format(bts_id, du_id))

    @login_logout
    def unlock_cell(self, bts_id=0, cell_id=1, du_id=0):
        """
        Unlock gNB cell.
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id: cell id, default 1.
        :type cell_id:  int
        :return:        None
        """
        dist_name = self._get_cell_dist_name(bts_id=bts_id, cell_id=cell_id,
                                             du_id=du_id)
        self.admin.unlock_cell(
            dist_name,
            connection=self.rest_alias.format(bts_id, du_id))

    @login_logout
    def block_cell(self, bts_id=0, cell_id=1, du_id=0):
        """
        Block gNB cell.
        :param bts_id:  BTS id - related to Test Line configuration.
        :type bts_id:   int
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param cell_id: cell id.
        :type cell_id:  int
        :return: None
        """
        dist_name = self._get_cell_dist_name(bts_id=bts_id, du_id=du_id,
                                             cell_id=cell_id)
        self.admin.block_cell(dist_name, connection=self.rest_alias.format(
            bts_id, du_id))

    @login_logout
    def unblock_cell(self, bts_id=0, cell_id=1, du_id=0):
        """
        Unblock gNB cell.
        :param bts_id:  BTS id - related to Test Line configuration.
        :type bts_id:   int
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param cell_id: cell id.
        :type cell_id:  int
        :return: None
        """
        dist_name = self._get_cell_dist_name(
            bts_id=bts_id, du_id=du_id, cell_id=cell_id)
        self.admin.unblock_cell(
            dist_name,
            connection=self.rest_alias.format(bts_id, du_id))

    @login_logout_GUI
    def lock_cell_via_gui(self, bts_id=0, cell_id=1, du_id=0):
        """
        Lock cell using GUI.
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id: cell id, default 1.
        :return:        None
        """
        self.gui_coam.lock_cell(cell_idx=cell_id)

    @login_logout_GUI
    def unlock_cell_via_gui(self, bts_id=0, cell_id=1, du_id=0):
        """
        Unlock cell using GUI.
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param cell_id: cell id, default 1.
        :return:        None
        """
        self.gui_coam.unlock_cell(cell_idx=cell_id)

    @login_logout
    def lock_unlock_cell_via_gui(self, bts_id=0, cell_id=1, du_id=0):
        """
        Lock and then unlock cell using GUI
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param cell_id: cell id, default 1.
        :return:        None
        """
        self.lock_cell_via_gui(bts_id=bts_id, cell_id=cell_id,
                               du_id=du_id)
        self.unlock_cell_via_gui(bts_id=bts_id, cell_id=cell_id,
                                 du_id=du_id)

    @login_logout
    def lock_unlock_all_cells_via_gui(self, bts_id=0, du_id=0):
        """
        Lock and then unlock all cells using GUI
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return:        None
        """
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id,
                                                 du_id=du_id)
        for cell_id in cell_ids:
            self.lock_unlock_cell_via_gui(bts_id=bts_id, cell_id=cell_id,
                                          du_id=du_id)

    @login_logout
    def lock_all_cells(self, bts_id=0, du_id=0):
        """
        Locks all cells
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return:
        """
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id)
        for cell_id in cell_ids:
            self.lock_cell(bts_id=bts_id, du_id=du_id, cell_id=cell_id)

    @login_logout
    def unlock_all_cells(self, bts_id=0, du_id=0):
        """
        Unlocks all cells
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :return:
        """
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id)
        for cell_id in cell_ids:
            self.unlock_cell(bts_id=bts_id, du_id=du_id, cell_id=cell_id)

    @login_logout
    def verify_cell_is_locked(self, bts_id=0, cell_id=1, du_id=0):
        """
        Verify gnb cell is locked.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used, default set to 1.
        :type cell_id:  int
        :return:        None
        """
        expected_statuses = {
            "availabilityStatus": "Offline",
            "operationalState": "Disabled",
            "proceduralStatus": "initialization required",
            "administrativeState": "Locked",
        }

        dist_name = self._get_cell_dist_name(bts_id=bts_id, cell_id=cell_id,
                                             du_id=du_id)
        cell_specific_info = self.admin.get_cell_specific_info(
            cell_id=dist_name,
            connection=self.rest_alias.format(bts_id, du_id))

        self._verify_bts_cell_statuses(expected_statuses=expected_statuses,
                                       cell_specific_info=cell_specific_info)
        logging.info("Cell {} is locked".format(cell_id))

    @login_logout
    def verify_cell_is_unlocked(self, bts_id=0, cell_id=1, du_id=0):
        """
        Verify gnb cell is unlocked.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used, default set to 1.
        :type cell_id:  int
        :return:        None
        """
        expected_statuses = {
            "administrativeState": "Unlocked",
        }

        dist_name = self._get_cell_dist_name(bts_id=bts_id, cell_id=cell_id,
                                             du_id=du_id)
        cell_specific_info = self.admin.get_cell_specific_info(
            cell_id=dist_name,
            connection=self.rest_alias.format(bts_id, du_id))

        self._verify_bts_cell_statuses(expected_statuses=expected_statuses,
                                       cell_specific_info=cell_specific_info)
        logging.info("Cell {} is unlocked".format(cell_id))

    @login_logout
    def verify_cell_is_blocked(self, bts_id=0, cell_id=1, du_id=0):
        """
        Verify gnb cell is blocked.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used, default set to 1.
        :type cell_id:  int
        :return:        None
        """
        expected_statuses = {
            "blockingState": "Blocked",
        }

        dist_name = self._get_cell_dist_name(bts_id=bts_id, cell_id=cell_id,
                                             du_id=du_id)
        cell_specific_info = self.admin.get_cell_specific_info(
            cell_id=dist_name,
            connection=self.rest_alias.format(bts_id, du_id))
        self._verify_bts_cell_statuses(expected_statuses=expected_statuses,
                                       cell_specific_info=cell_specific_info)
        logging.info("Cell {} is blocked".format(cell_id))

    @login_logout
    def verify_cell_is_unblocked(self, bts_id=0, cell_id=1, du_id=0):
        """
        Verify gnb cell is unblocked.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used, default set to 1.
        :type cell_id:  int
        :return:        None
        """
        expected_statuses = {
            "blockingState": "Unblocked",
        }

        dist_name = self._get_cell_dist_name(bts_id=bts_id,
                                             cell_id=cell_id, du_id=du_id)
        cell_specific_info = self.admin.get_cell_specific_info(
            cell_id=dist_name,
            connection=self.rest_alias.format(bts_id, du_id))

        self._verify_bts_cell_statuses(expected_statuses=expected_statuses,
                                       cell_specific_info=cell_specific_info)
        logging.info("Cell {} is unblocked".format(cell_id))

    @login_logout
    def verify_all_cells_are_locked(self, bts_id=0, du_id=0):
        """
        Verify if all cells are locked
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return:        None
        """
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id,
                                                 du_id=du_id)
        for cell_id in cell_ids:
            self.verify_cell_is_locked(bts_id=bts_id, du_id=du_id,
                                       cell_id=cell_id)

    @login_logout
    def verify_all_cells_are_unlocked(self, bts_id=0, du_id=0):
        """
        Verify if all cells are unlocked
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return:        None
        """
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id,
                                                 du_id=du_id)
        for cell_id in cell_ids:
            self.verify_cell_is_unlocked(bts_id=bts_id, du_id=du_id,
                                         cell_id=cell_id)

    @login_logout
    def verify_all_cells_are_unblocked(self, bts_id=0, du_id=0):
        """
        Verify if all cells are unlocked
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return:        None
        """
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id,
                                                 du_id=du_id)
        for cell_id in cell_ids:
            self.verify_cell_is_unblocked(bts_id=bts_id, du_id=du_id,
                                          cell_id=cell_id)

    @login_logout
    def verify_cell_setup(self, bts_id=0, cell_id=1, du_id=0,
                          cell_info=None, verify_bts_status=True,
                          cell_type="nr"):
        """
        Verify cell statues are:
            "availabilityStatus"=="Online",
            "operationalState" == "Enabled",
            "administrativeState" == "Unlocked",
            "blockingState" == "Unblocked",
            "proceduralStatus" == "configured"
            and gNB statuses are:
            "operationalState" == "Enabled",
            "proceduralState" == "OnAir",
            "blockingState" == "Unblocked"

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used,
        default set to 1.
        :param cell_info: dict - output from get_cells_info for
        particular cell.
        :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm",
        "nr" (5G). Default: "nr".
        :param verify_bts_status: True/False - flag to check bts statuses
        :return:        None
        """
        cell_expected_statuses = {
            "availabilityStatus": "Online",
            "operationalState": "Enabled",
            "administrativeState": "Unlocked",
            "blockingState": "Unblocked",
            "proceduralStatus": "configured"
        }
        gnb_expected_statuses = {
            "operationalState": "Enabled",
            "proceduralState": "OnAir",
            "blockingState": "Unblocked",
        }

        if cell_info is None:
            cells_info = self.admin.get_cells_info(
                connection=self.rest_alias.format(bts_id, du_id),
                cell_type=cell_type)
            cell_info = [_cell_info for _cell_info in cells_info
                         if _cell_info['globalCellId'] == cell_id][0]

        self._verify_bts_cell_statuses(
            expected_statuses=cell_expected_statuses,
            cell_specific_info=cell_info)

        if verify_bts_status:
            gnb_statuses = self.admin.get_bts_statuses(
                connection=self.rest_alias.format(bts_id, du_id))
            for expected_status in gnb_expected_statuses.keys():
                if not re.match(gnb_expected_statuses[expected_status],
                                gnb_statuses[expected_status], re.I):
                    raise IncorrectParameterValue(
                        "'{}' should be {} but is {}".format(
                            expected_status,
                            gnb_expected_statuses[expected_status],
                            gnb_statuses[expected_status]))

    @login_logout
    def get_number_of_cells(self, bts_id=0, du_id=0):
        """
        Get number of cells.

        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: number of cells as int
        """
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id,
                                                 du_id=du_id)
        return len(cell_ids)

    def calculate_throughput_for_all_cells_based_on_one_cell(self,
                                                             cell_tput,
                                                             bts_id=0,
                                                             du_id=0):
        """
        Calculate throughput for all cells in setup by multiplying
         cell_throughput by number of cells.

        :param cell_tput: throughput for one cell example "10 Mbits/s"
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :return: throughput or all cells, for example "20 Mbits/s"
        """
        tp_one_cell = 0
        tp_unit = ""
        nr_of_cells = self.get_number_of_cells(bts_id=bts_id, du_id=du_id)
        m = re.search(r"(?P<TPUT>\d+\.\d+)\s+(?P<UNIT>\S+)", cell_tput)
        if m:
            tp_one_cell = float(m.group("TPUT"))
            tp_unit = m.group("UNIT")
        else:
            m = re.search(r"(?P<TPUT>\d+)\s+(?P<UNIT>\S+)", cell_tput)
            if m:
                tp_one_cell = int(m.group("TPUT"))
                tp_unit = m.group("UNIT")
        total_tp = "{} {}".format(tp_one_cell * nr_of_cells, tp_unit)
        return total_tp

    def _get_cell_dist_name(self, bts_id, cell_id, du_id=0):
        """
        Get whole distName for specified cell.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id: ID of cell
        :return:        distName as string
        """
        bts_runtime_info = self.admin.get_bts_info(
            timeout=10, connection=self.rest_alias.format(bts_id, du_id))
        _re_cell_dist_name = self.patterns.run_time_cell_dist_name.format(
            cell_id)
        determine_pattern = re.search(_re_cell_dist_name, str(
            bts_runtime_info))
        if not determine_pattern:
            raise DataNotAvailable("Cell distName not found.")
        else:
            return determine_pattern.group('CELL_DIST_NAME')

    def _get_all_global_cell_ids(self, bts_id=0, du_id=0, radio_id=None):
        """
        Returns global ids of all cells from a bts with given id

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :param radio_id: radio unit ID, if None - cells from all rus
         are returned
        :return:        cell ids as ints in tuple
        """

        cells_info = self.admin.get_cells_info(
            connection=self.rest_alias.format(bts_id, du_id))
        cell_ids = []
        for cell_number in cells_info:
            if radio_id is None or \
                    'RMOD_R-{}'.format(radio_id) in \
                    cell_number['carrierList'][1]['antennaLineId']['internal']:
                cell_ids.append(int(cell_number["globalCellId"]))

        cell_ids.sort(key=int)
        return tuple(cell_ids)

    def _get_all_physical_cell_ids(self, bts_id=0, du_id=0):
        """
        Returns physical ids of all cells from a bts with given id

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to
         Test Line configuration - gnb.dus[]
        :return:        cell ids as ints in tuple
        """
        cells_info = self.admin.get_cells_info(
            connection=self.rest_alias.format(bts_id, du_id))
        cell_ids = []
        for cell_number in cells_info:
            cell_ids.append(int(cell_number["physicalCellId"]))
        return tuple(cell_ids)

    @login_logout
    def verify_setup_of_all_cells(self, bts_id=0, du_id=0,
                                  cell_type="nr"):
        """
        Verify that status of all cells are:
            "availabilityStatus"=="Online",
            "operationalState" == "Enabled",
            "administrativeState" == "Unlocked",
            "blockingState" == "Unblocked",
            "proceduralStatus" == "configured"
        and gNB statuses are:
            "operationalState" == "Enabled",
            "proceduralState" == "OnAir",
            "blockingState" == "Unblocked"

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :param str cell_type: Cell type of given RAT: "lte",
         "wcdma", "gsm", "nr" (5G). Default: "nr".
        :return:        None
        """

        cells_info = self.admin.get_cells_info(
            connection=self.rest_alias.format(bts_id, du_id),
            cell_type=cell_type)
        verify_bts_status = False
        for cell_info in cells_info:
            if cell_info == cells_info[-1]:
                verify_bts_status = True
            self.verify_cell_setup(bts_id=bts_id, du_id=du_id,
                                   cell_id=cell_info['globalCellId'],
                                   cell_info=cell_info,
                                   verify_bts_status=verify_bts_status)

    @login_logout
    def verify_all_cell_status(self, cell_id=None, bts_id=0,
                               cell_status="Enabled", du_id=0):
        """
               Verify all cell statuses on BTS
               :param bts_id:  ID of gNB/eNB, default 0
               :param du_id: DU id(Distributed Unit) - id related to Test
               Line configuration - gnb.dus[]
               :param cell_id: the cell id, if given verify status of only
               one cell, if not, verify all.
               :param cell_status: Status of a cell
               :return: None
               """
        if cell_id is not None:
            self._verify_cell_status(bts_id=bts_id, cell_id=int(cell_id),
                                     cell_status=cell_status)
        else:
            cells_ids_list = self._get_all_cells_id(bts_id)
            for cells_id in cells_ids_list:
                self._verify_cell_status(bts_id=bts_id, cell_id=int(cells_id),
                                         cell_status=cell_status)

    @login_logout
    def _verify_cell_status(self, bts_id=0, cell_id=1, cell_status="Enabled",
                            du_id=0):
        """
        Verify cell status on BTS
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :param cell_id: the cell id, default set to 1.
        :param cell_status: Status of a cell
        :return: None
        """
        cell_expected_statuses = {
            "operationalState": cell_status
        }

        cell_dist_name = self._get_cell_dist_name(bts_id=bts_id,
                                                  du_id=du_id, cell_id=cell_id)
        cell_specific_info = \
            self.admin.get_cell_specific_info(
                cell_id=cell_dist_name,
                connection=self.rest_alias.format(bts_id, du_id))
        self._verify_bts_cell_statuses(
            expected_statuses=cell_expected_statuses,
            cell_specific_info=cell_specific_info)

    def _get_cell_groups_info(self, bts_id=0, du_id=0):
        """
        Returns tuple of objects containing information about cell groups
        Example output:
        [{
            u 'id': {
                u 'internal': u '/MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1/NP-1/
                SCF-4/MRBTS_A-10297/NRBTS_A-297/NRCELLGRP_A-0'
            },
            u 'nrCellList': [u 'NRCELL-1', u 'NRCELL-2', u 'NRCELL-3',
             u 'NRCELL-4'],
            u 'name': u 'NRCELLGRP-0'
        }]
        :param      bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return:    tuple
        """
        cell_groups_info = self.admin.get_bts_info(
            connection=self.rest_alias.format(bts_id, du_id))["cellsGroup"]
        return tuple(cell_groups_info)

    @login_logout_GUI
    def lock_cell_group_via_gui(self, bts_id=0, cell_group_id=1, du_id=0):
        """
        Lock cell group using GUI
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param cell_group_id:  group id, default 1.
        :return:    None
        """
        self.gui_coam.lock_cell_group(cell_group_idx=cell_group_id)
        time.sleep(35)

    @login_logout_GUI
    def unlock_cell_group_via_gui(self, bts_id=0,
                                  cell_group_id=1, du_id=0):
        """
        Unlock cell group using GUI
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param cell_group_id:  group id, default 1.
        :return:    None
        """
        self.gui_coam.unlock_cell_group(cell_group_idx=cell_group_id)
        time.sleep(35)

    @login_logout
    def lock_unlock_cell_group_via_gui(self, bts_id=0,
                                       cell_group_id=1, du_id=0):
        """
        Lock and then unlock cell group using GUI
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_group_id:  group id, default 1.
        :return:    None
        """
        self.lock_cell_group_via_gui(
            bts_id=bts_id, cell_group_id=cell_group_id, du_id=du_id)
        self.unlock_cell_group_via_gui(bts_id=bts_id,
                                       cell_group_id=cell_group_id,
                                       du_id=du_id)

    def _get_all_cell_group_ids(self, bts_id=0, du_id=0):
        """
        Returns all cell groups id
        :param      bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :return:    tuple
        """
        cell_groups_info = self._get_cell_groups_info(bts_id=bts_id,
                                                      du_id=du_id)
        cell_group_ids = []
        for cell_group_info in cell_groups_info:
            cell_group_ids.append(int(
                re.search(r'\d+$', cell_group_info["name"]).group()))
        return tuple(cell_group_ids)

    def _get_cell_ids_in_specific_cell_group(self, bts_id=0,
                                             cell_group_id=0, du_id=0):
        """
        Returns all cells which are assigned to nrcellgrp
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param cell_group_id:  Id of NRCELLGRP
        :return:    tuple
        """
        cell_groups_info = self._get_cell_groups_info(bts_id=bts_id,
                                                      du_id=du_id)
        cell_ids = []
        for cell_id in cell_groups_info[int(cell_group_id)]["nrCellList"]:
            cell_ids.append(int(re.search(r'\d+$', cell_id).group()))
        return tuple(cell_ids)

    @login_logout
    def verify_configuration_parameters_for_cell_groups(self, param_dict,
                                                        cell_group_id=None,
                                                        bts_id=0, du_id=0):
        """
        Verify that given parameters for cell group have given values.
        :param param_dict: dictionary where the main key is a distNames
         of the managedObject
        where given parameters are located and the value is dictionary
         with parameters and their
        expected values,
        e.g. {
                  param1: expected_value1,
                  param2: expected_value2
              }
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :param cell_group_id: if given verify one specific group
         of cell, else verify all groups of cells
        :return: None
        """
        if cell_group_id is None:
            cell_group_ids = self._get_all_cell_group_ids(
                bts_id=bts_id, du_id=du_id)
        else:
            cell_group_ids = (cell_group_id,)
        for group_id in cell_group_ids:
            group_cell_key = "NRCELLGRP-{}".format(group_id)
            param_dictionary = {"MRBTS-{}/NRBTS-{}/" +
                                group_cell_key: param_dict}
            self._verify_configuration_parameters_values(
                param_dict=param_dictionary, bts_id=bts_id, du_id=du_id)

    @login_logout
    def verify_configuration_parameters_for_cell(self, param_dict,
                                                 cell_id=None,
                                                 bts_id=0, du_id=0):
        """
        Verify that given parameters for cell have given values.
        :param param_dict: dictionary where the main key is a distNames
        of the managedObject
        where given parameters are located and the value is dictionary
        with parameters and their
        expected values,
        e.g. {
                  param1: expected_value1,
                  param2: expected_value2
              }
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :param cell_id: if given verify one specific cell, else
        verify all cells
        :return: None
        """
        if cell_id is None:
            cell_ids = self._get_all_global_cell_ids(bts_id=bts_id,
                                                     du_id=du_id)
        else:
            cell_ids = (cell_id,)
        for cell_index in cell_ids:
            cell_key = "NRCELL-{}".format(cell_index)
            param_dictionary = {"MRBTS-{}/NRBTS-{}/" + cell_key: param_dict}
            self._verify_configuration_parameters_values(
                param_dict=param_dictionary, bts_id=bts_id, du_id=du_id)

    @login_logout
    def get_pmax_value(self, cell_id=None, bts_id=0, du_id=0):
        """
        Get value of pMax parameter from configuration and return it as
         dictionary containing dictionary and integer
        value.
        :param cell_id:  if given verify one specific cell, else verify random
        :param bts_id:  BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return: {"dict": {'MRBTS-10297/NRBTS-297/NRCELL-1': {
                                'pMax': param_value
                                }}, "value": 190}
                dict is used as input to keyword Verify gNB Configuration
                 Parameters Have Expected Values
                and value is pMax parameter value
        """
        if cell_id is not None:
            return self._get_pmax_value(cell_id=cell_id,
                                        bts_id=bts_id, du_id=du_id)
        else:
            cell_id_list = self._get_all_global_cell_ids(bts_id=bts_id)
            return self._get_pmax_value(
                cell_id=int(cell_id_list[0]), bts_id=bts_id, du_id=du_id)

    def _get_pmax_value(self, cell_id=None, bts_id=0, du_id=0):
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}",
                                          bts_id, du_id)
        part_dist_name = "MRBTS-{}/NRBTS-{}"
        cell_dst_name = "NRCELL-{}".format(cell_id)
        full_dist_name = "{}/NRCELL-{}".format(dist_name, cell_id)
        param_value = self._get_object_parameters_dict(
            full_dist_name, bts_id=bts_id, du_id=du_id)["pMax"]
        return_value = {"dict": {'{}/{}'.format(part_dist_name,
                                                cell_dst_name): {
                        'pMax': param_value
                        }}, "value": param_value}
        return return_value

    @login_logout
    def get_cell_parameters(self, bts_id=0, cell_id=1, du_id=0):
        """
        Returns dictionary containing all parameters of a cell with given
        cell_id
        :param bts_id:      gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param cell_id:     ID of cell, num 1 to 8 can be used
        :return dict        dictionary containing parameters and values
        """
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}",
                                          bts_id=bts_id, du_id=du_id)
        cell_parameters = self._get_object_parameters_dict(
            dist_name="{}/NRCELL-{}".format(dist_name, cell_id),
            bts_id=bts_id, du_id=du_id)
        return cell_parameters

    def _get_gscn_params(self, cell_parameters):

        logging.debug("Passed cell parametrs: {}".format(cell_parameters))
        gscn = cell_parameters.get('gscn')
        gscn_filter_param = 'Global synchronization channel number'

        if gscn is None:
            gscn = cell_parameters.get('gscnOrSsPbchArfcn')
            gscn_filter_param = 'Synchronization channel number'

        return gscn, gscn_filter_param

    @login_logout_GUI
    def _add_new_cell_based_on_existing_cell_to_configuration_via_gui(
             self, cell_id_to_copy_from, cell_id, nrarfcn, gscn, physCellId,
             type0CoresetConfigurationIndex,
             maxNumScellsDl, dist_name, cell_dist_name,
             cell_group_dist_name,
             mrbts_id, cell_ids_in_group,
             nrcell_include_subobject=False,
             activate_plan_despite_errors=False, bts_id=0, du_id=0,
             gscn_filter_param='Global synchronization channel number'):
        """
        Adds a new cell to configuration based on an existing cell,
        using Selenium

        :param cell_id_to_copy_from:     id of cell that new cell will be
        based on
        :param cell_id:                  id of the new cell
        :param nrarfcn:                  value of nrarfcn parameter of
        new cell
        :param gscn:                     value of gscn parameter of new
        cell
        :param physCellId:               value of physCellId parameter
         of new cell
        :param type0CoresetConfigurationIndex: value of type0Coreset
        ConfigurationIndex parameter of new cell
        :param maxNumScellsDl            new value of maxNumScellsDl
        :param dist_name:                general dist name
        :param cell_dist_name:           new cell dist name
        :param cell_group_dist_name:     cell group dist name
        :param mrbts_id:                 mrbts value
        :param cell_ids_in_group:        ids of cells in cell group
        :param nrcell_include_subobject: whether include subobjects when
         add NRCELL object
        :param activate_plan_despite_errors    activate plan despite errors
         when do activation, by default is False
        :param bts_id:                   gNB id - related to Test Line
         configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: None
        """
        self.gui_coam.add_object(
            object_name=dist_name,
            object_class_name='NRCELL',
            plan_to_copy_from='CURRENT_BTS_CONF-1',
            copy_from=dist_name + '/NRCELL-' + str(cell_id_to_copy_from),
            include_subobject=nrcell_include_subobject,
            id_value=cell_id)
        self.gui_coam.set_parameter_value(dist_name=cell_dist_name,
                                          filter_param='Local cell '
                                                       'resource ID',
                                          new_value=cell_id)
        self.gui_coam.set_parameter_value(dist_name=cell_dist_name,
                                          filter_param='NR Absolute '
                                                       'radio frequency '
                                                       'channel number',
                                          new_value=nrarfcn)
        self.gui_coam.set_parameter_value(dist_name=cell_dist_name,
                                          filter_param=gscn_filter_param,
                                          new_value=gscn)
        self.gui_coam.set_parameter_value(dist_name=cell_dist_name,
                                          filter_param='Physical cell '
                                                       'identifier',
                                          new_value=physCellId)
        self.gui_coam.set_parameter_value(
            dist_name=cell_dist_name,
            filter_param='Coreset configuration Index',
            new_value=type0CoresetConfigurationIndex)

        self.gui_coam.add_element(dist_name=cell_group_dist_name,
                                  filter_param='List of NR cells assigned'
                                               ' to cell group')
        self.gui_coam.set_parameter_value(dist_name=cell_group_dist_name,
                                          filter_param='List of NR cells '
                                                       'assigned to '
                                                       'cell group',
                                          node_index=len(cell_ids_in_group),
                                          new_value=cell_id)

        self.gui_coam.add_object(object_name='MRBTS-' + str(mrbts_id) +
                                             '/MNL-1/MNLENT-1/CELLMAPPING-1',
                                 object_class_name='LCELNR',
                                 plan_to_copy_from='CURRENT_BTS_CONF-1',
                                 copy_from='MRBTS-' + str(mrbts_id) +
                                           '/MNL-1/MNLENT-1/CELLMAPPING-1'
                                           '/LCELNR-'
                                           + str(cell_id_to_copy_from),
                                 include_subobject=True,
                                 id_value=cell_id)

        self.gui_coam.set_parameter_value(
            dist_name=dist_name,
            filter_param='Maximum number of secondary cells for DL '
                         'carrier aggregation',
            new_value=maxNumScellsDl)

        self.gui_coam.validate_plan()
        self.gui_coam.activate_plan(
            activate_plan_despite_errors=activate_plan_despite_errors)

    @login_logout
    def add_new_cell_based_on_existing_cell_to_configuration(
            self, cell_parameters,
            cell_id_to_copy_from,
            nrcell_include_subobject=False,
            activate_plan_despite_errors=False,
            group_id=0,
            bts_id=0,
            du_id=0):
        """
        Adds a new cell to configuration based on an existing cell
        :param cell_parameters:          dictionary containing values for
        mandatory parameters:
                                         lcrId, nrarfcn, gscn, physCellId
                                            example:
                                            cell_parameters =[{
                                                'lcrId': '4',
                                                'nrarfcn': '2103311',
                                                'gscn': '22558',
                                                'physCellId': '44'
                                            }]
        :param cell_id_to_copy_from:     id of cell that new cell will be
         based on
        :param group_id:                 group id of copied cell
        :param nrcell_include_subobject: whether include subobjects
        when add NRCELL object
        :param activate_plan_despite_errors    activate plan despite errors
         when do activation, by default is False
        :param bts_id:                   gNB id - related to Test Line
        configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :return: None
        """

        gscn, gscn_filter_param = self._get_gscn_params(cell_parameters)
        cell_id = cell_parameters['lcrId']
        nrarfcn = cell_parameters['nrarfcn']
        physCellId = cell_parameters['physCellId']
        type0CoresetConfigurationIndex = \
            cell_parameters['type0CoresetConfigurationIndex']
        maxNumScellsDl = len(self._get_all_global_cell_ids(
            bts_id=bts_id, du_id=du_id))

        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}",
                                          bts_id=bts_id, du_id=du_id)
        cell_dist_name = dist_name + '/NRCELL-' + str(cell_id)
        cell_group_dist_name = dist_name + '/NRCELLGRP-' + str(group_id)
        mrbts_id = self.get_bts_instance_id(bts_id=bts_id, du_id=du_id)

        cell_ids_in_group = self._get_cell_ids_in_specific_cell_group(
            bts_id=bts_id, du_id=du_id, cell_group_id=group_id)

        self._add_new_cell_based_on_existing_cell_to_configuration_via_gui(
            cell_id_to_copy_from,
            cell_id,
            nrarfcn,
            gscn,
            physCellId,
            type0CoresetConfigurationIndex,
            maxNumScellsDl,
            dist_name,
            cell_dist_name,
            cell_group_dist_name,
            mrbts_id,
            cell_ids_in_group,
            nrcell_include_subobject,
            activate_plan_despite_errors,
            bts_id,
            du_id,
            gscn_filter_param)

    def _set_new_beamset_value_via_gui(self, basicBeamSet,
                                       cell_id=None, bts_id=0, du_id=0):
        """
        Set a new basicBeamSet value using Selenium without activating plan.
         If there is no cell_id, set for all cells.
        If basicBeamSet is a dict allows to set also all angles for
         selected beam set

        :param basicBeamSet              value of basicBeamSet or dict
        with beam set and angles e.g.
                                         basicBeamSet = {
                                        "Basic Beam Set": "beamSetFR2_6_6_4
                                        _2P",
                                        "Left Cell Edge Angle": "90",
                                        "Lower Cell Edge Angle": "110",
                                        "Right Cell Edge Angle": "90",
                                        "Upper Cell Edge Angle": "90"
                                        }

        :param cell_id                   cell id value
        :param bts_id:                   gNB id - related to Test
         Line Configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param activate_plan_despite_errors     allow to activate plan
        despite validation errors
        :return: None
        """
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}",
                                          bts_id=bts_id, du_id=du_id)
        if cell_id is None:
            cells_ids_list = self._get_all_cells_id(bts_id=bts_id,
                                                    du_id=du_id)
            for single_cell_id in cells_ids_list:
                cell_dist_name = "{}/NRCELL-{}".format(dist_name,
                                                       str(single_cell_id))
                if not isinstance(basicBeamSet, dict):
                    self.gui_coam.set_parameter_value(
                        cell_dist_name,
                        filter_param='Basic Beam Set',
                        new_value=basicBeamSet)
                else:
                    for key in basicBeamSet.keys():
                        self.gui_coam.set_parameter_value(
                            cell_dist_name,
                            filter_param=key,
                            new_value=basicBeamSet[key])

        else:
            cell_dist_name = "{}/NRCELL-{}".format(dist_name, str(cell_id))
            if not isinstance(basicBeamSet, dict):
                self.gui_coam.set_parameter_value(
                    cell_dist_name,
                    filter_param='Basic Beam Set',
                    new_value=basicBeamSet)
            else:
                for key in basicBeamSet.keys():
                    self.gui_coam.set_parameter_value(
                        cell_dist_name,
                        filter_param=key,
                        new_value=basicBeamSet[key])

        self.gui_coam.validate_plan()

    @login_logout_GUI
    def set_new_beamset_value_via_gui(self, basicBeamSet,
                                      cell_id=None,
                                      activate_plan_despite_errors=False,
                                      bts_id=0,
                                      du_id=0):
        """
        Set a new basicBeamSet value using Selenium. If there is no cell_id,
         set for all cells.
        If basicBeamSet is a dict allows to set also all angles for selected
        beam set

        :param basicBeamSet              value of basicBeamSet or dict with
                                        beam set and angles e.g.
                                         basicBeamSet = {
                                        "Basic Beam Set": "beamSetFR2_6_6_
                                        4_2P",
                                        "Left Cell Edge Angle": "90",
                                        "Lower Cell Edge Angle": "110",
                                        "Right Cell Edge Angle": "90",
                                        "Upper Cell Edge Angle": "90"
                                        }

        :param cell_id                   cell id value
        :param bts_id:                   gNB id - related to Test
        Line Configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param activate_plan_despite_errors     allow to activate
        plan despite validation errors
        :return: None
        """
        self._set_new_beamset_value_via_gui(basicBeamSet, cell_id=cell_id,
                                            bts_id=bts_id, du_id=du_id)
        self.gui_coam.activate_plan(
            activate_plan_despite_errors=activate_plan_despite_errors)

    @login_logout
    def _get_all_cells_id(self, bts_id=0, du_id=0):
        cell_list = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id)
        return cell_list

    @login_logout
    def verify_nrarfcn(self, bts_id=0, du_id=0):
        """
        Verify if nrarfcn is in the range minimum and maximum value
        according to bandwith and frequency
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :return:  None
        """
        bands = CalculatorResources.bands
        dist_name = self.adjust_dist_name(
            "MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
        group_ids = self._get_all_cell_group_ids(bts_id=bts_id, du_id=du_id)
        for group_id in group_ids:
            nrcell_ids = self._get_cell_ids_in_specific_cell_group(
                bts_id=bts_id, du_id=du_id, cell_group_id=group_id)
            for cell_id in nrcell_ids:
                full_dist_name = "{}/NRCELL-{}".format(dist_name, cell_id)
                nrcell_info = self._get_object_parameters_dict(
                    dist_name=full_dist_name, bts_id=bts_id, du_id=du_id)
                band_id = nrcell_info["freqBandIndicatorNR"]
                nrarfcn = int(nrcell_info["nrarfcn"])
                min_value = int(bands[band_id]['nrarfcn']['min'])
                max_value = int(bands[band_id]['nrarfcn']['max'])
                if not (min_value < nrarfcn < max_value):
                    raise WrongNrarfcnFrequency(
                        "Nrarfcn value should be between: {} - {} but is: {}".
                        format(min_value, max_value, nrarfcn))

    @login_logout
    def verify_basic_beam_set(self, beam_set, bts_id=0, du_id=0):
        """
        Verify if basic beam set have proper value
        :param beam_set: list of allowed beam set values
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: None
        """
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}",
                                          bts_id=bts_id, du_id=du_id)
        nrcell_ids = self._get_all_global_cell_ids(
            bts_id=bts_id, du_id=du_id)
        for cell_id in nrcell_ids:
            full_dist_name = "{}/NRCELL-{}".format(dist_name, cell_id)
            bts_info = self._get_object_parameters_dict(
                dist_name=full_dist_name, bts_id=bts_id, du_id=du_id)
            basic_beam_set = bts_info["basicBeamSet"]
            if basic_beam_set in beam_set:
                logging.info("Beam set value is right")
            else:
                raise WrongBasicBeamSet(
                    "Beam set value shoud be: {} but is: {}".format(
                        beam_set, basic_beam_set))

    @login_logout
    def verify_cell_energy_saving_state(self, cell_id=1,
                                        energy_saving_state="notEnergySaving",
                                        bts_id=0, du_id=0):
        """
        Verify cell energy saving state

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used, default set to 1.
        :type cell_id: int
        :param energy_saving_state: cells energy saving state
        :return: None
        """
        expected_statuses = {
            "energySavingState": energy_saving_state,
        }

        dist_name = self._get_cell_dist_name(bts_id=bts_id, cell_id=cell_id,
                                             du_id=du_id)
        cell_specific_info = self.admin.get_cell_specific_info(
            cell_id=dist_name,
            connection=self.rest_alias.format(bts_id, du_id))

        try:
            wrong_statuses = [status for status in expected_statuses if
                              expected_statuses[status] !=
                              cell_specific_info[status]]
            logging.debug("Expected statuses: {}".format(expected_statuses))
            logging.debug("Received statuses: {}".format(cell_specific_info))
            if wrong_statuses:
                raise IncorrectParameterValue(
                    "Wrong cell energy saving status:  {}".
                    format(wrong_statuses))
        except KeyError as e:
            raise DataNotAvailable(
                "Cannot get expected status info: {}".format(repr(e)))

    @login_logout_GUI
    def add_new_cell_to_power_group(self, power_group_id, cell_id,
                                    cell_switch_off_order, node_index,
                                    activate_plan_despite_errors=False,
                                    bts_id=0, du_id=0):
        """
        Add new cell to power group.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id: the cell id, num 1 to 8 can be used
        :type cell_id: int
        :param power_group_id: power group id
        :type power_group_id: int
        :param cell_switch_off_order: cell switch off order
        :type cell_switch_off_order: int
        :param node_index: node index
        :type node_index: int
        :param activate_plan_despite_errors: allow to activate plan
        despite validation errors
        :return: None
        """
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}",
                                          bts_id=bts_id, du_id=du_id)
        power_group_dist_name = "{}/NRPGRP-{}".format(dist_name,
                                                      str(power_group_id))
        self.gui_coam.add_element(
            dist_name=power_group_dist_name,
            filter_param='Load-based power saving cell list',
            abbr='lbpsCellList')
        self.gui_coam.set_parameter_value(
            dist_name=power_group_dist_name,
            filter_param='Load-based power saving cell switch off order',
            new_value=cell_switch_off_order,
            node_index=int(node_index))
        self.gui_coam.set_parameter_value(
            dist_name=power_group_dist_name,
            filter_param='NR cell configuration identifier',
            new_value=cell_id,
            node_index=int(node_index))

        self.gui_coam.validate_plan()
        self.gui_coam.activate_plan(
            activate_plan_despite_errors=activate_plan_despite_errors)

    def _get_global_cell_id_for_physical_cell_id(
            self, bts_id=0, du_id=0, cell_id=1, cells_info=None):
        """
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param cell_id: physical cell id.
        :param cells_info: cells INFO - if not passed get automatically
        from API
        :return: global_cel_id
        """
        if not cells_info:
            cells_info = self.admin.get_cells_info(
                connection=self.rest_alias.format(bts_id, du_id))

        for cell_info in cells_info:
            if int(cell_info['physicalCellId']) == int(cell_id):
                return cell_info['globalCellId']

    @login_logout
    def wait_for_cell_to_be_locked(self, bts_id=0, cell_id=1,
                                   timeout=120, interval=10, du_id=0):
        """
        Verify 'Operational state' is 'disabled' and 'Administrative state'
         is 'Locked' when cell to be locked.
        :param bts_id:      ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param cell_id:     ID of cell
        :param timeout:     wait for disabled status until timeout
        :param interval:    wait additional time after failed execution,
         before next attempt
        :return:            None
        """
        start_time = time.time()
        while time.time() < start_time + time_to_seconds(time=timeout):
            try:
                self.verify_cell_is_locked(
                    bts_id=bts_id, cell_id=cell_id, du_id=du_id)
                logging.info("Cell {} is 'locked".format(cell_id))
                break
            except IncorrectParameterValue:
                time.sleep(time_to_seconds(time=interval))
        else:
            raise LockCellFailure("Timeout passed. Status cell in not locked")


class EnbCell(GenericCell):
    """Class contains Cell keywords for eNB"""

    bts_type = 'ENB'

    def __init__(self):
        """
        Constructor of Enb class.

        """

        super(EnbCell, self).__init__(bts_type=EnbCell.bts_type)


class GnbCell(GenericCell):
    """Class contains Cell keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.

        """
        self.nr_frequency_bands = GnbResources().nr_frequency_bands
        super(GnbCell, self).__init__(bts_type=GnbCell.bts_type)

    @login_logout
    def get_random_cell_dist_name(self, bts_id=0, du_id=0):
        """
        Get random cell dist name
        :param bts_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :param return: i.e: MRBTS-{}/NRBTS-{}/NRCELL-1
        """
        random_cell_id = self._get_all_global_cell_ids(bts_id=bts_id,
                                                       du_id=du_id)[0]
        dist_name = "MRBTS-{}/NRBTS-{}/"
        return_cell_dist_name = "{}NRCELL-{}".format(dist_name,
                                                     random_cell_id)
        return return_cell_dist_name

    def _get_rmod_id_related_to_cell_id(self, bts_id=0, du_id=0, cell_id=1,
                                        cell_id_type='physical',
                                        bts_info=None):
        """
        Get RMOD ID related to cell_id.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param cell_id: cell id.
        :param cell_id_type: 'physical' or 'global'
        :param bts_info:  results of method get_bts_info - it obtain
        automatically if
         not passed
        :return: RMOD info
        """
        if not bts_info:
            bts_info = self.admin.get_bts_info(
                connection=self.rest_alias.format(bts_id, du_id))
        cell_id_key = 'physicalCellId' if cell_id_type == 'physical'\
            else 'globalCellId'

        # "MRBTS-76019/EQM-1/APEQM-1/RMOD-1/PHYANT-1",
        rmod_regex = re.compile(r'RMOD-(?P<RMOD_ID>\d+)')

        for cell_info in bts_info['cells']['nr']:
            if cell_info[cell_id_key] == int(cell_id):
                for carrier_info in cell_info['carrierList']:
                    rmod_match = rmod_regex.search(
                        carrier_info['antennaLineId']['configuration'])
                    if rmod_match:
                        return rmod_match.group('RMOD_ID')

    @login_logout
    def get_cell_group_id_linked_to_cell_id(self, bts_id=0, du_id=0,
                                            cell_id=1,
                                            cell_id_type='physical'):
        """
        Get RMOD information linked to cell_id.

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param cell_id: cell id.
        :param cell_id_type: 'physical' or 'global'
        :return: RMOD info
        """
        _id_regex = re.compile(r'-(?P<ID>\d+)$')
        cell_groups_info = self._get_cell_groups_info(bts_id, du_id)
        global_cell_id = cell_id if cell_id_type == 'global' else \
            self._get_global_cell_id_for_physical_cell_id(bts_id, du_id,
                                                          cell_id)

        global_cell_name = "NRCELL-{}".format(global_cell_id)
        for cell_group_info in cell_groups_info:
            if global_cell_name in cell_group_info['nrCellList']:
                group_cell_name = cell_group_info['name']
                match = _id_regex.search(group_cell_name)
                return {'NAME': group_cell_name, 'ID': match.group('ID')}


class NrCellIdentityCalculator(object):
    """
    Examople usage:
    ncic = NrCellIdentityCalculator()
    nrcellid = ncic.calculate_nr_cell_identity(8, 1)
    global_cell_id = ncic.calculate_global_cell_id(131074)
    nrbts_id = ncic.calculate_nrbts_id(131074)
    """
    total_bit_length = 36

    def __init__(self, gnb_id_bit_length=22):
        """
        :param gnb_id_bit_length: Could be from 22 to 32. Default 22
        """
        self.gnb_id_bit_length = gnb_id_bit_length

    def calculate_nr_cell_identity(self, nrbts, global_cell_id):
        """
        Calculate NR Cell Identity based on nrbts and global cell id
        :param nrbts: NRBTS ID(global TS id) eg: 8
        :param global_cell_id: global Cell ID eg: 2
        :return: NR Cell Identity eg: 131074
        """
        nrbts_bin = bin(nrbts)[2:].zfill(self.gnb_id_bit_length)
        cell_id_bin = bin(global_cell_id)[2:].zfill(
            self.total_bit_length - self.gnb_id_bit_length)

        return int('{}{}'.format(nrbts_bin, cell_id_bin), 2)

    def calculate_global_cell_id(self, nr_cell_id):
        """
        Calculate global CELL ID based on NR Cell ID
        :param nr_cell_id: NR Cell ID eg: 131074
        :return: global_cell_id: global Cell ID eg: 2
        """
        nr_cell_id_bin = bin(nr_cell_id)[2:].zfill(self.total_bit_length)
        global_cell_id_bin = nr_cell_id_bin[self.gnb_id_bit_length:]
        return int(global_cell_id_bin, 2)

    def calculate_nrbts_id(self, nr_cell_id):
        """
        Calculate NRBTS ID(Global BTS ID) based on NR Cell ID
        :param nr_cell_id: NR Cell ID eg: 131074
        :return: nrbts: NRBTS ID(global TS id) eg: 8
        """

        nr_cell_id_bin = bin(nr_cell_id)[2:].zfill(self.total_bit_length)
        nrbts_id_bin = nr_cell_id_bin[:self.gnb_id_bit_length]
        return int(nrbts_id_bin, 2)

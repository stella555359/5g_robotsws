# -*- coding: utf-8 -*-
"""
Author: Grzegorz Kaczor
"""

import logging
from taf.internal.robot_typecasts import time_to_seconds
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations as GnbCell
from taf.rfrl.bts.devices.generic_bts import login_logout, login_logout_GUI
from taf.rfrl.bts.devices.exceptions import BadCellsNumber, IncorrectStatuses, IncorrectCellsStatuses, \
    CellsInfoNotAvailable
from taf.rfrl.bts.helpers.compare_statuses import verify_statuses


class GnbCellCustom(GnbCell):

    def __init__(self):
        super(GnbCellCustom, self).__init__()
        self.cells_info = []
        self.nbiot_cells_info = []

    def login_gui_extended(self, bts_id=0, du_id=0):
        self.login_gui(bts_id=bts_id, du_id=du_id)
        self._close_startup_view_if_exists()

    def get_all_global_cell_infos_with_nbiot(self, bts_id=0, du_id=0, radio_id=None, cell_type='all'):
        cells_info = self._get_all_cells_info(bts_id=bts_id, du_id=du_id, cell_type=cell_type)
        cell_infos = []
        nbiot_cell_infos = []
        for cell_info in cells_info:
            cell_id_key = self._get_proper_cell_id_key(cell_info)
            if self.is_nb_iot_cell(cell_info):
                logging.info("NB-IoT cell with id:{} found.".format(int(cell_info[cell_id_key])))
                nbiot_cell_infos.append(cell_info)
                continue
            if radio_id is None or \
                    'RMOD_R-{}'.format(radio_id) in cell_info['carrierList'][1]['antennaLineId']['internal']:
                cell_infos.append(cell_info)

        cells = {"cells": tuple(cell_infos),
                 "nbiot_cells": tuple(nbiot_cell_infos)}
        return cells

    @login_logout
    def get_all_cell_infos(self, bts_id=0, du_id=0, cell_type="all"):
        cells = self.get_all_global_cell_infos_with_nbiot(bts_id=bts_id, du_id=du_id, cell_type=cell_type)
        self.cells_info = cells["cells"]
        self.nbiot_cells_info = cells["nbiot_cells"]

    def verify_dependency_status(self, bts_id=0, du_id=0, verify_bts_status=False,
                                 exptected_cell_amount=None,
                                 availability_status="Dependency",
                                 operational_state="Disabled",
                                 administrative_state="Unlocked",
                                 blocking_state="Unblocked",
                                 usage_state=None,
                                 procedural_status="configured",
                                 barring_status="unbarred"):
        cells_info = self.cells_info
        if not len(cells_info):
            raise BadCellsNumber("Actual cells number is: {}, should be greater than 0".format(len(cells_info)))
        if exptected_cell_amount is not None and exptected_cell_amount != len(cells_info):
            raise BadCellsNumber("Actual cells number is: {}, should be {}".format(len(cells_info),
                                                                                   exptected_cell_amount))
        bts_status_should_be_verified = False
        for cell_info in cells_info:
            if cell_info == cells_info[-1] and verify_bts_status:
                bts_status_should_be_verified = True
            cell_id_key = self._get_proper_cell_id_key(cell_info)
            cell_id = cell_info[cell_id_key]
            self.verify_cell_setup(bts_id=bts_id, du_id=du_id, cell_id=cell_id, cell_info=cell_info,
                                   verify_bts_status=bts_status_should_be_verified, blocking_state=blocking_state,
                                   availability_status=availability_status, operational_state=operational_state,
                                   administrative_state=administrative_state, procedural_status=procedural_status,
                                   usage_state=usage_state, barring_status=barring_status)

    def verify_nbiot_status_for_locked_bbmod(self, bts_id=0, du_id=0, verify_bts_status=False,
                                             exptected_cell_amount=None,
                                             availability_status="offline",
                                             operational_state="Disabled",
                                             administrative_state="Unlocked",
                                             blocking_state="Unblocked",
                                             usage_state=None,
                                             procedural_status="configured",
                                             barring_status="unbarred"):
        cells_info = self.nbiot_cells_info
        if not len(cells_info):
            raise BadCellsNumber("Actual NBIoT cells number is: {}, should be greater than 0".format(len(cells_info)))
        if exptected_cell_amount is not None and exptected_cell_amount != len(cells_info):
            raise BadCellsNumber("Actual NBIoT cells number is: {}, should be {}".format(len(cells_info),
                                                                                         exptected_cell_amount))
        bts_status_should_be_verified = False
        for cell_info in cells_info:
            if cell_info == cells_info[-1] and verify_bts_status:
                bts_status_should_be_verified = True
            cell_id_key = self._get_proper_cell_id_key(cell_info)
            cell_id = cell_info[cell_id_key]
            self.verify_cell_setup(bts_id=bts_id, du_id=du_id, cell_id=cell_id, cell_info=cell_info,
                                   verify_bts_status=bts_status_should_be_verified, blocking_state=blocking_state,
                                   availability_status=availability_status, operational_state=operational_state,
                                   administrative_state=administrative_state, procedural_status=procedural_status,
                                   usage_state=usage_state, barring_status=barring_status)

    @login_logout
    def verify_all_cells_failed_statuses(self, bts_id=0, du_id=0, cell_type='all',
                                         availability_status=None,
                                         operational_state=None,
                                         administrative_state=None,
                                         blocking_state=None,
                                         procedural_status=None,
                                         usage_state=None,
                                         barring_status=None,
                                         expected_cell_amount=None):
        """
        Verify BTS cell statuses for all cells.
        If you would like to omit checking certain status/state, please provide None value.
        You can also provide status/state as regex eg re.compile(r'online|degraded')

        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" or "all" if you want to
                              include all RATs. Default: "all".
        :param availability_status:     expected cell availability status (online/offline)
        :param operational_state:       expected cell operational state (enabled/disabled)
        :param administrative_state:    expected cell administrative state (unlocked/locked)
        :param procedural_status:       expected cell procedural status (configured/dependency/initialization required)
        :param blocking_state:          expected cell blocking state
        :param usage_state:             expected cell usage state
        :param barring_status:          expected cell barring status
        :param expected_cell_amount:    number of cell expected on TL
        :return:        None
        """
        cells_info = self._get_all_cells_info(bts_id=bts_id, du_id=du_id, cell_type=cell_type)
        if not cells_info:
            raise CellsInfoNotAvailable("Cells info is not available: {}".format(cells_info))
        if expected_cell_amount is not None and expected_cell_amount != len(cells_info):
            raise BadCellsNumber("Actual cells number is: {}, should be {}".format(len(cells_info),
                                                                                   expected_cell_amount))

        all_cells_incorrect_statuses = []
        for cell_info in cells_info:
            if 'NB-IoT' in cell_info['technology']:
                continue

            cell_id_key = self._get_proper_cell_id_key(cell_info)

            try:
                self.verify_cell_statuses(bts_id=bts_id, du_id=du_id, cell_id=cell_info[cell_id_key],
                                          cell_info=cell_info,
                                          blocking_state=blocking_state,
                                          availability_status=availability_status,
                                          operational_state=operational_state,
                                          administrative_state=administrative_state,
                                          procedural_status=procedural_status,
                                          usage_state=usage_state,
                                          barring_status=barring_status)
            except IncorrectStatuses as e:
                all_cells_incorrect_statuses.append(e)
                logging.debug(e)

        if all_cells_incorrect_statuses:
            all_dist_names = [e.device for e in all_cells_incorrect_statuses]
            logging.info("Cells with wrong statuses: {}".format(sorted(all_dist_names)))
            raise IncorrectCellsStatuses(all_cells_incorrect_statuses)

        logging.info("All cells statuses are as expected")

    @login_logout
    def block_cell_and_return_dist_name(self, bts_id=0, cell_id=1, du_id=0, timeout=60):
        dist_name = self._get_runtime_cell_dist_name(bts_id=bts_id, du_id=du_id, cell_id=cell_id)
        self.admin.block_cell(dist_name, time_to_seconds(time=timeout),
                              connection=self.rest_alias.format(bts_id, du_id))
        return dist_name

    @login_logout
    def block_all_cells_and_return_blocked_cell_count(self, bts_id=0, du_id=0, cell_type='all'):
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, cell_type=cell_type)
        for cell_id in cell_ids:
            self.block_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
        return len(cell_ids)

    @login_logout
    def block_all_cells_on_all_asirhubs_and_return_blocked_cell_count(self, bts_id=0, du_id=0, cell_type='all'):
        hubs_info = self._get_all_asirhub_info()
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, cell_type=cell_type)
        hubs_cell_count = 0
        for cell_id in cell_ids:
            dist_name = self.block_cell_and_return_dist_name(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
            if self._check_cell_presence_on_asirhub(bts_hubs_info=hubs_info, dist_name=dist_name):
                hubs_cell_count += 1
        return hubs_cell_count

    @login_logout_GUI
    def block_cell_via_gui(self, bts_id=0, cell_id=1, technology="NR", du_id=0):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.block_cell(cell_idx=cell_id, technology=technology, sbts=gui_alias)

    @login_logout_GUI
    def verify_cell_is_blocked_via_gui(self, bts_id=0, cell_id=1, technology="NR", du_id=0):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        cell_status = self.gui_coam.get_cell_info(cell_idx=cell_id, technology=technology, sbts=gui_alias)
        logging.debug(f"Cell info: {cell_status}")
        if cell_status.get("status"):
            status = cell_status.get("status")
            expected_statuses = {
                "blockingState": "blocked",
            }
        else:
            status = cell_status.get("Status")
            expected_statuses = {
                "Blocking state": "Blocked",
            }
        if status is None:
            raise AttributeError(f"Status for cell not found in response: {cell_status}")
        verify_statuses(expected_statuses=expected_statuses, received_statuses=status)
        logging.info("Cell {} is blocked".format(cell_id))

    @login_logout_GUI
    def unblock_cell_via_gui(self, bts_id=0, cell_id=1, technology="NR", du_id=0):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.unblock_cell(cell_idx=cell_id, technology=technology, sbts=gui_alias)

    @login_logout_GUI
    def verify_cell_is_unblocked_via_gui(self, bts_id=0, cell_id=1, technology="NR", du_id=0):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        cell_status = self.gui_coam.get_cell_info(cell_idx=cell_id, technology=technology, sbts=gui_alias)
        logging.debug(f"Cell info: {cell_status}")
        if cell_status.get("status"):
            status = cell_status.get("status")
            expected_statuses = {
                "blockingState": "unblocked",
            }
        else:
            status = cell_status.get("Status")
            expected_statuses = {
                "Blocking state": "Unblocked",
            }
        if status is None:
            raise AttributeError(f"Status for cell not found in response: {cell_status}")
        verify_statuses(expected_statuses=expected_statuses, received_statuses=status)
        logging.info("Cell {} is unblocked".format(cell_id))

    def _get_all_asirhub_info(self, bts_id=0, du_id=0):
        bts_hubs_info = self.admin.get_bts_info(
            timeout=10, connection=self.rest_alias.format(bts_id, du_id))["radioModules"]["asirmod"]
        return bts_hubs_info

    @staticmethod
    def _check_cell_presence_on_asirhub(bts_hubs_info, dist_name):
        logging.debug("Checking if cell {} is located on ASiR Hub". format(dist_name))
        extracted_cell_id = dist_name.split("/")[-1]
        extracted_cell_id = extracted_cell_id.replace("_R", "")
        logging.debug("Modified cell info to matchable format: {}".format(extracted_cell_id))
        for hub in bts_hubs_info:
            carrier_list = hub["carrierList"]
            for carrier in carrier_list:
                if extracted_cell_id in carrier["id"]["configuration"]:
                    logging.debug("Found cell {} on hub configuration: {}".format(extracted_cell_id, hub))
                    return True
        logging.debug("Cell {} not found on any of the hubs: {}".format(extracted_cell_id, bts_hubs_info))
        return False

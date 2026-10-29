"""
Procedures to handle tests for CB0079389.
author: Magda Chrostek
email: magda.chrostek@nokia.com
"""
import os
import collections
import logging
import re
import shutil
from taf.rfrl.bts.devices.du.commissioning import GenericCommissioning, login_logout
from taf.rfrl.utilities import tl_config
from taf.internal.sbts.admin.exceptions import AdminApiProcedureTimeoutException


class NotFullConfigruation(Exception):
    pass


class SomeCellsSleepsAfterTest(Exception):
    pass


class Procedures(GenericCommissioning):

    def __init__(self):
        super(Procedures, self).__init__()

    @login_logout
    def bts_commissioning(self, scf_path, bts_id=0, skip_parameter_relation_errors=False, should_activate=True,
                          validate_scf=True, timeout=300, du_id=0):
        """
        Commissioning SBTS after configuration reset
        @param scf_path: str, scf location
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        @param skip_parameter_relation_errors:
        @param should_activate: bool, flag for operation
        @param validate_scf: bool, flag for operation
        @param timeout: int, timeout for operation
        """
        connection = self.rest_alias.format(bts_id, du_id)
        self.admin.perform_commissioning(scf_file=scf_path,
                                         skip_parameter_relation_errors=skip_parameter_relation_errors,
                                         should_activate=should_activate,
                                         validate_scf=validate_scf,
                                         timeout=timeout, connection=connection)

    @login_logout
    def lock_radios(self, ue_radio_number, bts_id=0, du_id=0):
        """
        Lock every specific radio from operate radios list
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        @type ue_radio_number: int, radio number for which ue is attached
        """
        connection = self.rest_alias.format(bts_id, du_id)
        radio_list_to_lock = self.get_radios_list_to_operate(ue_radio_number=ue_radio_number)

        for radio in radio_list_to_lock:
            self.admin.lock(dist_name=str(radio), timeout=60, connection=connection)

    @login_logout
    def unlock_radios(self, ue_radio_number, bts_id=0, du_id=0):
        """
        Lock every specific radio from operate radios list
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        @type ue_radio_number: int, radio number for which ue is attached
        """
        connection = self.rest_alias.format(bts_id, du_id)
        radio_list_to_unlock = self.get_radios_list_to_operate(ue_radio_number=ue_radio_number)

        for radio in radio_list_to_unlock:
            self.admin.unlock(dist_name=str(radio), timeout=60, connection=connection)

    def get_radios_list_to_operate(self, ue_radio_number, bts_id=0, du_id=0):
        """
        Get radios list to perform operation in test
        @param ue_radio_number: int, radio number for which ue is attached
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        @return: list, list of radio w/o radio witch attached UE

        """
        number_of_ru = self._get_rmod_distname(bts_id=bts_id, du_id=du_id)
        regex_radios = re.compile('(RMOD_R-{})'.format(int(ue_radio_number)))
        radio_list_to_operate = []

        for radio in number_of_ru:
            if collections.Counter(re.findall(regex_radios, radio)):
                logging.info("This is UE radio: " + radio)
            else:
                radio_list_to_operate.append(radio)

        return radio_list_to_operate

    @login_logout
    def verify_there_is_no_disabled_cells(self, cell_type, bts_id=0, du_id=0):
        """
        Verify there is no disabled cell on sBTS
        @param cell_type: str, type of cell e.g. lte / nr
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        @return: bool, status from operation
        """
        connection = self.rest_alias.format(bts_id, du_id)
        get_cells_info = self.admin.get_cells_info(cell_type=str(cell_type).strip().lower(), timeout=10,
                                                   connection=connection)
        cells_status, cells_dit_name = self._unpack_cells_info(get_cells_info)

        if len(cells_status) != len(cells_dit_name):
            raise SomeCellsSleepsAfterTest("Fail. Some cells sleeps.")
        return True

    @login_logout
    def block_cell(self, cell_type, ue_cell_number, bts_id=0, du_id=0):
        """
        Block  every cell not used by UE
        @param cell_type: str, type of cell e.g. LTE / NR
        @param ue_cell_number: int, cell used by UE
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        @return: none
        """
        connection = self.rest_alias.format(bts_id, du_id)
        get_cells_info = self.admin.get_cells_info(str(cell_type).lower().strip(), timeout=10, connection=connection)
        cells_status, cells_dit_name = self._unpack_cells_info(get_cells_info)
        cells = self._determine_cells_to_operation(cell_type, cells_dit_name, ue_cell_number)

        for elem in cells:
            self.admin.block_cell(str(elem), timeout=60, connection=connection)

    @login_logout
    def unblock_cell(self, cell_type, ue_cell_number, bts_id=0, du_id=0):
        """
        Unblock  every cell not used by UE
        @param cell_type: str, type of cell e.g. LTE / NR
        @param ue_cell_number: int, cell used by UE
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        @return: none
        """
        connection = self.rest_alias.format(bts_id, du_id)
        get_cells_info = self.admin.get_cells_info(str(cell_type).lower().strip(), timeout=10, connection=connection)
        cells_status, cells_dit_name = self._unpack_cells_info(get_cells_info)
        cells = self._determine_cells_to_operation(cell_type, cells_dit_name, ue_cell_number)

        for elem in cells:
            self.admin.unblock_cell(str(elem), timeout=60, connection=connection)

    @login_logout
    def block_sbts(self, rat, bts_id=0, du_id=0):
        """
        Block sbts
        :param rat: str, type of rat e.g LTE / NR
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: id related to Test Line configuration, default 0
        :return: none
        """
        connection = self.rest_alias.format(bts_id, du_id)
        self.admin.block_rat(rat=str(rat).upper(), timeout=60, connection=connection)

    @login_logout
    def unblock_sbts(self, rat, bts_id=0, du_id=0):
        """
        Unblock sbts
        :param rat: str, type of rat e.g LTE / NR
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: id related to Test Line configuration, default 0
        :return: none
        """
        connection = self.rest_alias.format(bts_id, du_id)
        self.admin.unblock_rat(rat=str(rat).upper(), timeout=60, connection=connection)

    @login_logout
    def reset_radios(self, ue_radio_number, bts_id=0, du_id=0):
        """
        Lock every specific radio from operate radios list
        @param bts_id: ID of gNB/eNB, default 0
        @param du_id: id related to Test Line configuration, default 0
        @type ue_radio_number: int, radio number for which ue is attached
        """
        connection = self.rest_alias.format(bts_id, du_id)
        dist_names = self.get_radios_list_to_operate(ue_radio_number, bts_id, du_id)
        for radio in dist_names:
            try:
                self.admin.reset_unit(dist_name=str(radio), reset_type="Soft", force_radio_reset=True, timeout=100,
                                      connection=connection)
            except AdminApiProcedureTimeoutException:
                logging.info("Expected. Radio will respond after initialization. Some kind of radios doesn't come "
                             "back in 100 sec as taf has appointed.")

    @staticmethod
    def remove_files(log_dir):
        """
        Remove temporary folder for snapshot collection
        @param log_dir: str, path to temporary folder
        @return: none
        """
        shutil.rmtree(log_dir)

    @staticmethod
    def determine_snapshot_path(log_dir):
        """
        Determine path for collected snapshot
        :param log_dir: str, path to temporary directory with snapshot
        :return: str, path with snapshot name
        """
        regex_snap = re.compile('(.*zip$)')

        for root, dirs, files in os.walk(log_dir):
            for file in files:
                if regex_snap.match(file):
                    path = os.path.join(log_dir, file)

        return path

    @staticmethod
    def _unpack_cells_info(get_cells_info):
        """
        Unpack cells information from sBTS @param get_cells_info: full tree like respond in bts_info() with managed
        objects for each cell. I take from it:
        for cell_statuses: {'administrativeState': 'unlocked',
        'operationalState': 'enabled', 'usageState': 'Idle', 'blockingState': 'Unblocked'}
        for cells_distname:  {'internal': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-77079/LNCEL_R-0',
         'configuration': 'MRBTS-77079/LNBTS-77079/LNCEL-0'}
        @return: list, cells statuses and dist_names e.g.
        cell_distname == MRBTS-77079/LNBTS-77079/LNCEL-8 c
        ell_statuses == ['enabled, enabled, enabled, ... ]
        """
        cells_status = []
        cells_dit_name = []
        for cell_info in get_cells_info:
            for cell in cell_info.values():
                if type(cell) == dict:
                    for key, values in cell.items():
                        if str(values) == "enabled":
                            cells_status.append(values)
                        elif str(values).startswith("MRBTS"):
                            cells_dit_name.append(values)

        return cells_status, cells_dit_name

    @staticmethod
    def _determine_cells_to_operation(cell_type, cells_dist_name, ue_cell_number):
        """
        Determine dist name for cells not used by UE
        @param cells_dist_name: str, managed objects for cells
        @param ue_cell_number: int, cell used by UE
        @return: list with cells managed objects
        """
        matches = []

        if str(cell_type).strip().lower() == "lte".strip():
            pattern = "LNCEL"
        else:
            pattern = "NRCELL"

        regex = (pattern + '-[0-9]+')
        for elem in cells_dist_name:
            matches.append(str(elem))

        cells = []
        pattern = [pattern.strip() + "-".strip() + str(ue_cell_number).strip()]

        for elem in matches:
            if collections.Counter(re.findall(regex, elem)) != collections.Counter(pattern):
                cells.append(elem)
        cells = list(dict.fromkeys(cells))
        return cells

    @login_logout
    def _get_rmod_distname(self, bts_id=0, du_id=0):
        """
        Get dist name for RMODs from bts_info()
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id:  id related to Test Line configuration, default 0
        @return: list with dist names for RMODs
        """
        connection = self.rest_alias.format(bts_id, du_id)
        runtime_info = self.admin.get_bts_info(timeout=10, connection=connection)
        number_of_ru = tl_config.get_count_of_radios(bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)
        ru_distname = []
        found_rmods = []

        for ru_id in range(1, number_of_ru + 1):
            ru_distname.append(self.patterns.re_ru_dist_name.format(ru_id))

        for ru_id in range(0, len(ru_distname)):
            found_rmod = re.search(ru_distname[ru_id], str(runtime_info))
            found_rmods.append(found_rmod.group())

        if len(found_rmods) != number_of_ru:
            raise NotFullConfigruation("Maximum of radios not used in SCF! Use maximum configuration.")
        else:
            return found_rmods

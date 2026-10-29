"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com
"""
import logging
import re
import random
import time
from taf.internal.robot_typecasts import time_to_seconds
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu
from taf.rfrl.bts.devices.generic_bts import login_logout, login_logout_GUI
from taf.rfrl.bts.devices.exceptions import ParameterChangingError, IncorrectStatuses
from taf.sbts.oam.coam.admin.exceptions import IncorrectParameterValue
from taf.internal.sbts.admin.exceptions import (AdminApiConnectionClosedException, AdminApiProcedureTimeoutException,
                                                AdminApiProcedureFailureException)


class GnbCustomDu(GnbBbu):

    dist_name_lte = "MRBTS-{}/LNBTS-{}/LNCEL-{}/SIB-0"
    dist_name_nr = "MRBTS-{}/NRBTS-{}/NRCEL-{}"
    parameter_name_lte = "Cell barred flag"
    parameter_name_nr = "Cell Barred"

    def __init__(self):
        super(GnbCustomDu, self).__init__()

    @login_logout
    def lock_all_bbmod_units(self, bts_id=0, du_id=0):
        bbmod_ids = self._get_all_bbmod_ids(bts_id=bts_id, du_id=du_id)
        logging.debug('bbmod_ids - {}'.format(bbmod_ids))
        for bbmod_id in bbmod_ids:
            self.lock_bbmod(bts_id=bts_id, du_id=du_id, bbmod_id=bbmod_id)

    def get_all_bbmod_ids(self, bts_id=0, du_id=0):
        return self._get_all_bbmod_ids(bts_id=bts_id, du_id=du_id)

    def _get_all_bbmod_ids(self, bts_id=0, du_id=0):
        """
        Get list of BBMOD ids based on RUNTIME dist name
        :param bts_id:      BTS id - related to Test Line configuration. Default: 0
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:            list of all available RUNTIME BBMOD unit IDs
        """
        bbmod_ids = list()
        bts_info = self.admin.get_bts_info(connection=self.rest_alias.format(bts_id, du_id))
        for bbmod_info in bts_info['basebandModules']:
            dist_name = bbmod_info['id']['internal']
            match = re.search(r'(?P<BBMOD_ID>\d+)$', dist_name)
            if match and bbmod_info['status']['usageState'] == 'Active':
                bbmod_id = match.group("BBMOD_ID")
                bbmod_ids.append(int(bbmod_id))

        return bbmod_ids

    @login_logout
    def lock_all_bbmod_units(self, bts_id=0, du_id=0):
        bbmod_ids = self._get_all_bbmod_ids(bts_id=bts_id, du_id=du_id)
        for bbmod_id in bbmod_ids:
            self.lock_bbmod(bts_id=bts_id, du_id=du_id, bbmod_id=bbmod_id)

    @login_logout
    def unlock_all_bbmod_units(self, bts_id=0, du_id=0):
        bbmod_ids = self._get_all_bbmod_ids(bts_id=bts_id, du_id=du_id)
        for bbmod_id in bbmod_ids:
            self.unlock_bbmod(bts_id=bts_id, du_id=du_id, bbmod_id=bbmod_id)

    @login_logout
    def reset_all_bbmod_units(self, bts_id=0, du_id=0):
        bbmod_ids = self._get_all_bbmod_ids(bts_id=bts_id, du_id=du_id)
        for bbmod_id in bbmod_ids:
            self.reset_bbmod(bts_id=bts_id, du_id=du_id, bbmod_id=bbmod_id)

    @login_logout
    def verify_all_bbmods_locked_status(self, bts_id=0, du_id=0):
        bbmod_ids = self._get_all_bbmod_ids(bts_id=bts_id, du_id=du_id)
        for bbmod_id in bbmod_ids:
            self.verify_bbmod_locked_status(bts_id=bts_id, du_id=du_id, bbmod_id=bbmod_id)

    @login_logout
    def wait_until_all_bbmods_are_online(self, bts_id=0, du_id=0):
        bbmod_ids = self._get_all_bbmod_ids(bts_id=bts_id, du_id=du_id)
        for bbmod_id in bbmod_ids:
            self.wait_until_bbmod_is_online(bts_id=bts_id, du_id=du_id, bbmod_id=bbmod_id)

    def _get_bbmod_dist_name(self, bts_id=0, du_id=0, bbmod_id=1):
        """
        Get RUNTIME BBMOD dist_anme
        :param bts_id:      BTS id - related to Test Line configuration. Default: 0
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param bbmod_id:    RUNTIME BBMOD id
        :return:            RUNTIME dist_name
        """
        bts_info = self.admin.get_bts_info(connection=self.rest_alias.format(bts_id, du_id))
        for bbmod_info in bts_info['basebandModules']:
            try:
                logging.debug('bbmod info baseband: {}'.format(bbmod_info))
                dist_name = bbmod_info['id']['configuration']
                logging.debug('dist name config: {}'.format(dist_name))
                match = re.search(r'-{}$'.format(bbmod_id), dist_name)
                if match:
                    return dist_name
            except KeyError:
                continue

    def _verify_capacity_unit_state(self, bts_id=0, ops="enabled", avs="online", admin_state="unlocked",
                                    proc_state="configured", skip_not_installed=False, timeout=30, du_id=0,
                                    bbmod_id=None):
        """
        Get Capacity Unit state and verify against the state that tester demands

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param ops: operationalState of Common Unit
        :param avs: availabilityStatus of Common Unit
        :param admin_state: administrativeState of Common Unit
        :param proc_state: proceduralStatus of Common Unit
        :param timeout: timeout for positive procedure result
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param bbmod_id: id of BBMOD managedObjet; if None all BBMODs are checked
        :return: None
        """
        bbmods_info = self.get_bts_info(bts_id=bts_id, du_id=du_id, timeout=timeout)['basebandModules']
        bbmods_status = dict()
        logging.debug("BBMOD info: {}".format(bbmods_info))
        for bbmod_info in bbmods_info:
            try:
                _bbmod_id = re.search(r'BBMOD-(\d+)', bbmod_info['id']['configuration']).group(1)
                bbmods_status[int(_bbmod_id)] = bbmod_info['status']
            except KeyError:
                continue

        if bbmod_id is not None:
            bbmod_id = int(bbmod_id)
            if bbmod_id not in bbmods_status.keys():
                raise IncorrectParameterValue('Given bbmod_id value ({}) is incorrect'.format(bbmod_id))
            else:
                bbmod_status = bbmods_status[bbmod_id]
                self._check_bbmod_statuses(bbmod_id=bbmod_id, status_dict=bbmod_status, ops=ops, avs=avs,
                                           admin_state=admin_state, proc_state=proc_state)
        else:
            for bbmod_id in bbmods_status.keys():
                bbmod_status = bbmods_status[bbmod_id]
                if skip_not_installed and bbmod_status['proceduralStatus'] == 'not initialized':
                    logging.debug("Skipping not installed BBMOD-{}".format(bbmod_id))
                    continue
                self._check_bbmod_statuses(bbmod_id=bbmod_id, status_dict=bbmod_status, ops=ops, avs=avs,
                                           admin_state=admin_state, proc_state=proc_state)

    def lock_bbmod(self, bts_id=0, du_id=0, bbmod_id=1):
        dist_name = self._get_bbmod_dist_name(bts_id=bts_id, du_id=du_id, bbmod_id=bbmod_id)
        self.admin.lock(dist_name=dist_name, timeout=90, connection=self.rest_alias.format(bts_id, du_id))

    def unlock_bbmod(self, bts_id=0, du_id=0, bbmod_id=1):
        dist_name = self._get_bbmod_dist_name(bts_id=bts_id, du_id=du_id, bbmod_id=bbmod_id)
        self.admin.unlock(dist_name=dist_name, connection=self.rest_alias.format(bts_id, du_id), )

    def verify_bbmod_locked_status(self, bts_id=0, du_id=0, bbmod_id=1, skip_not_installed=False):
        self._verify_capacity_unit_state(bts_id=bts_id, du_id=du_id, bbmod_id=bbmod_id, ops='enabled', avs='online',
                                         admin_state='locked', proc_state='configured',
                                         skip_not_installed=skip_not_installed, timeout=30)

    def verify_bbmod_unlocked_status(self, bts_id=0, du_id=0, bbmod_id=1, skip_not_installed=False):
        self._verify_capacity_unit_state(bts_id=bts_id, du_id=du_id, bbmod_id=bbmod_id, ops='enabled', avs='online',
                                         admin_state='unlocked', proc_state='configured',
                                         skip_not_installed=skip_not_installed, timeout=30)

    def change_parameter_value_to_random_one_excluding_current_value_via_gui(self, dist_name, parameter,
                                                                             param_abbr, values_list,
                                                                             node_index=0, bts_id=0, du_id=0):
        current_value = self.get_gnb_parameter_value_via_gui(dist_name=dist_name, param_name=parameter,
                                                             param_abbr=param_abbr, bts_id=bts_id, du_id=du_id)
        try:
            values_list.remove(str(current_value))
            logging.debug("Current value {} found in value list, after removing it current list status {}".format(
                current_value, values_list))
        except ValueError:
            logging.debug("Current value {} not in given value list {}, picking random value from full list".format(
                current_value, values_list))
        value = random.choice(values_list)
        self.verify_if_parameter_changed_to_correct_value_via_gui(dist_name=dist_name, parameter=parameter,
                                                                  value=value, node_index=node_index,
                                                                  bts_id=bts_id, du_id=du_id)
        return value

    @login_logout_GUI
    def change_prach_and_lte_frame_shift_parameter_via_gui(self, dist_name, parameter_prach, parameter_frame,
                                                           param_abbr_prach, param_abbr_frame, value_prach, value_frame,
                                                           node_index=0, bts_id=0, du_id=0, timeout=120):
        current_value_prach = self.get_gnb_parameter_value_via_gui(dist_name=dist_name, param_name=parameter_prach,
                                                                   param_abbr=param_abbr_prach, bts_id=bts_id,
                                                                   du_id=du_id)
        if type(value_prach) is list:
            try:
                value_prach.remove(str(current_value_prach))
                logging.debug("Current value {} found in value list, after removing it current list status {}".format(
                    current_value_prach, value_prach))
            except ValueError:
                logging.debug("Current value {} not in given value list {}, picking random value from full list".format(
                    current_value_prach, value_prach))
            value = random.choice(value_prach)
            self.change_parameter_via_gui(dist_name, parameter_prach, value, int(node_index), bts_id, du_id=du_id)
        elif value_prach != current_value_prach:
            self.change_parameter_via_gui(dist_name, parameter_prach, value_prach, int(node_index), bts_id, du_id=du_id)
        else:
            logging.debug('Current value of PRACH has same value as given, parameter not changed')

        current_value_frame = self.get_gnb_parameter_value_via_gui(dist_name=dist_name, param_name=parameter_frame,
                                                                   param_abbr=param_abbr_frame, bts_id=bts_id,
                                                                   du_id=du_id)
        if current_value_frame != value_frame:
            self.change_parameter_via_gui(dist_name, parameter_frame, value_frame, int(node_index), bts_id, du_id=du_id)
        else:
            logging.debug('Current value of LTE Frame Shift has same value as given, parameter not changed')
        if not self.gui_coam.activate_plan(activate_plan_despite_errors=True, timeout=timeout,
                                           sbts=self.gui_alias.format(bts_id, du_id)):
            raise ParameterChangingError("Value wasn't out of range, plan not activated")

    def _barr_cell(self, dist_name, parameter_name, parameter_abbr="cellBarred", bts_id=0, du_id=0):
        current_value = self.get_gnb_parameter_value_via_gui(dist_name=dist_name, param_name=parameter_name,
                                                             param_abbr=parameter_abbr,
                                                             bts_id=bts_id, du_id=du_id)
        if current_value == "barred":
            logging.info("Cell {} is already barred, skipping".format(dist_name))
        else:
            self.change_parameter_via_gui(dist_name=dist_name, parameter=parameter_name, value="barred")

    def _unbarr_cell(self, dist_name, parameter_name, parameter_abbr="cellBarred", bts_id=0, du_id=0):
        current_value = self.get_gnb_parameter_value_via_gui(dist_name=dist_name, param_name=parameter_name,
                                                             param_abbr=parameter_abbr,
                                                             bts_id=bts_id, du_id=du_id)
        if current_value == "notBarred":
            logging.info("Cell {} is already barred, skipping".format(dist_name))
        else:
            self.change_parameter_via_gui(dist_name=dist_name, parameter=parameter_name, value="notBarred")

    @login_logout_GUI
    def barr_all_cells(self, bts_cells_lte, bts_cells_nr, mrbts_id, bts_id=0, du_id=0):
        for cell in bts_cells_lte:
            self._barr_cell(dist_name=self.dist_name_lte.format(mrbts_id, mrbts_id, cell),
                            parameter_name=self.parameter_name_lte,
                            bts_id=bts_id, du_id=du_id)
        for cell in bts_cells_nr:
            self._barr_cell(dist_name=self.dist_name_nr.format(mrbts_id, mrbts_id, cell),
                            parameter_name=self.parameter_name_nr,
                            bts_id=bts_id, du_id=du_id)

    @login_logout_GUI
    def unbarr_all_cells(self, bts_cells_lte, bts_cells_nr, mrbts_id, bts_id=0, du_id=0):
        for cell in bts_cells_lte:
            self._unbarr_cell(dist_name=self.dist_name_lte.format(mrbts_id, mrbts_id, cell),
                              parameter_name=self.parameter_name_lte,
                              bts_id=bts_id, du_id=du_id)
        for cell in bts_cells_nr:
            self._unbarr_cell(dist_name=self.dist_name_nr.format(mrbts_id, mrbts_id, cell),
                              parameter_name=self.parameter_name_nr,
                              bts_id=bts_id, du_id=du_id)

    @login_logout_GUI
    def unbarr_selected_cell(self, cell_id, cell_type, mrbts_id, bts_id=0, du_id=0):
        if cell_type == "lte":
            self._unbarr_cell(dist_name=self.dist_name_lte.format(mrbts_id, mrbts_id, cell_id),
                              parameter_name=self.parameter_name_lte,
                              bts_id=bts_id, du_id=du_id)
        elif cell_type == "nr":
            self._unbarr_cell(dist_name=self.dist_name_nr.format(mrbts_id, mrbts_id, cell_id),
                              parameter_name=self.parameter_name_nr,
                              bts_id=bts_id, du_id=du_id)
        else:
            raise AttributeError("Wrong cell_type given, expected 'nr' or 'lte', got: {}".format(cell_type))

    @login_logout
    def verify_procedural_state(self, procedural_states=(), bts_id=0, timeout=30, du_id=0):
        bts_status = self.admin.get_bts_statuses(connection=self.rest_alias.format(bts_id, du_id),
                                                 timeout=timeout)
        assert bts_status['proceduralState'] in procedural_states, \
            'Incorrect procedural state: {} != {}'.format(bts_status['proceduralState'], procedural_states)
        logging.info("Correct procedural and blocking state")

    def wait_for_site_to_be_not_onair(self, bts_id=0, timeout=120, interval=10, du_id=0):
        start_time = time.time()
        end_time = start_time + time_to_seconds(time=timeout)
        interval_in_seconds = time_to_seconds(time=interval)
        procedural_states = ["Configured", "Commissioned", "IntegratedToRan"]
        while time.time() < end_time:
            try:
                self.verify_procedural_and_blocking_state(procedural_states=procedural_states, bts_id=bts_id,
                                                          du_id=du_id, timeout=timeout)
                logging.info("Bts is not 'OnAir")
                break
            except (AdminApiConnectionClosedException, AdminApiProcedureFailureException):
                break
            except (IncorrectStatuses, AdminApiProcedureTimeoutException, AssertionError):
                time.sleep(interval_in_seconds)
        else:
            raise SiteOnAir("Timeout passed. Bts status in onAir")


class SiteOnAir(Exception):
    pass

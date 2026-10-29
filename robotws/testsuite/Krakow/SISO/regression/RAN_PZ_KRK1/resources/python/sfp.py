import time
import logging
from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout_GUI, login_logout
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.devices.exceptions import IncorrectStatuses, CellNotOnAir
from taf.internal.robot_typecasts import time_to_seconds
from common import load_variables_for_configuration, check_alarms_and_affected_cells
from exceptions import CellInitializationNotFinished


class SFP(GenericBts):

    bts_type = 'GNB'

    def __init__(self):
        self.gnb_scf_obj = GnbCommissioning()
        self.gnb_du_obj = GnbDuOperations()
        self.gnb_cell_obj = GnbCellOperations()
        self.gnb_alarm_obj = GnbAlarmVerification()

    @login_logout_GUI
    def create_cablink_instance(self, instance_id, cablink_params, bts_id=0, du_id=0):
        """
        Create cablink object
        :param instance_id:     id of cablink instance
        :param cablink_params:  dictionary of mandatory cablink parameters and their values
        :param activate:        answer if configuration should be activated
        :param bts_id:          BTS id
        :param du_id:           DU id
        """
        self.create_ethif_instance(int(cablink_params['ethIfId']),
                                   self.adjust_dist_name(cablink_params['linkSelectorDN'],
                                                         bts_id=bts_id, du_id=du_id))
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/EQM-1/HWTOP-1", bts_id=bts_id, du_id=du_id)
        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='CABLINK',
                                 id_value=instance_id,
                                 is_load_default_values=True,
                                 sbts=gui_alias)
        dist_name = "{}/CABLINK-{}".format(dist_name, str(instance_id))
        for key, value in cablink_params['parameters'].items():
            self.gui_coam.set_parameter_value(dist_name=dist_name,
                                              filter_param=key,
                                              new_value=value,
                                              sbts=gui_alias)

    @login_logout_GUI
    def delete_cablink_instance(self, instance_id, ethif_id=1, activate=True, activate_plan_despite_errors=False,
                                bts_id=0, du_id=0):
        """
        Delete cablink object
        :param instance_id:                     id of cablink instance
        :param ethif_id:                        id of ethif instance
        :param activate:                        if True configuration is activated
        :param activate_plan_despite_errors:    activate plan despite validation errors
        :param bts_id:                          BTS id
        :param du_id:                           DU id
        """
        self.delete_ethif_instance(ethif_id)
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/EQM-1/HWTOP-1", bts_id=bts_id, du_id=du_id)
        dist_name = "{}/CABLINK-{}".format(dist_name, str(instance_id))

        self.gui_coam.remove_object(object_name=dist_name, sbts=gui_alias)
        if activate:
            self.gui_coam.validate_plan(sbts=gui_alias)
            self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors, sbts=gui_alias)

    def delete_ethif_instance(self, instance_id, bts_id=0, du_id=0):
        """
        Delete ethif object
        :param instance_id:     id of ethif instance
        :param bts_id:          BTS id
        :param du_id:           DU id
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1", bts_id=bts_id, du_id=du_id)
        dist_name = "{}/ETHIF-{}".format(dist_name, str(instance_id))
        self.gui_coam.remove_object(object_name=dist_name, sbts=gui_alias)

    def create_ethif_instance(self, instance_id, linkSelectorDN, bts_id=0, du_id=0):
        """
        Create ethif object
        :param instance_id:     id of ethif instance
        :param linkSelectorDN:  value of linkSelectorDN for ethif instance
        :param bts_id:          BTS id
        :param du_id:           DU id
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1", bts_id=bts_id, du_id=du_id)
        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='ETHIF',
                                 id_value=instance_id,
                                 is_load_default_values=False,
                                 sbts=gui_alias)
        dist_name = "{}/ETHIF-{}".format(dist_name, str(instance_id))
        self.gui_coam.set_parameter_value(dist_name=dist_name,
                                          filter_param='Ethernet interface object identifier',
                                          new_value=1,
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=dist_name,
                                          filter_param='Reference to an external or internal bridge port',
                                          new_value=self.adjust_dist_name(linkSelectorDN, bts_id=bts_id, du_id=du_id),
                                          sbts=gui_alias)
        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='VLANIF',
                                 id_value=1,
                                 is_load_default_values=True,
                                 sbts=gui_alias)
        dist_name = "{}/VLANIF-1".format(dist_name)
        self.gui_coam.set_parameter_value(dist_name=dist_name,
                                          filter_param='VLAN ID',
                                          new_value=100,
                                          sbts=gui_alias)

    @staticmethod
    def load_delta_adding_sfp_lane(prefix_tag):
        """
        Import variable file with delta containing SFP and LANE objects based on prefix_tag.
        Filename in format {prefix_tag}_delta_sfp_lane.py
        Author/Contact: agnieszka.bylica@nokia.com
        :param prefix_tag: prefix_tag of configuration from commissionings directory
        :return: None
        """
        logging.info("Loading delta for SFP and LANE objects addition...")
        load_variables_for_configuration(f'{prefix_tag}_delta_sfp_lane')
        logging.info("Delta successfully loaded")

    @staticmethod
    def load_sfp_lock_config(prefix_tag):
        """
        Import variable file with configuration for SFP lock and unlock based on prefix_tag.
        Filename in format {prefix_tag}_sfp_lock.py
        Config in format:
            sfp_lock_unlock_config = {
                "MRBTS-{}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1": {
                    "expected_alarms": [
                        {
                            'fault_id': 10,
                            'fault_name': 'No connection to unit',
                            'reason': 'RU not detected after BTS startup'},
                        {
                            'fault_id': 1868,
                            'fault_name': 'BTS configuration error (not enough HW for LCR)'},
                    ],
                    "need_unlock_to_on_air": True,
                    "impacted_cells": [0, 3],
                    "timeout_for_cells_initialization": "20 min",
                    "timeout_for_cells_onair_after_unlock": "6min"
                },
            }
        Author/Contact: agnieszka.bylica@nokia.com
        :param prefix_tag: prefix_tag of configuration from commissionings directory
        :return: None
        """
        logging.info("Loading configuration for SFP lock and verification...")
        load_variables_for_configuration(f'{prefix_tag}_sfp_lock')
        logging.info("Configuration successfully loaded")

    def lock_sfp(self, sfp_lock_record, reset_site=False, time_for_site_available=600, time_cells_onair=600,
                 bts_id=0, du_id=0):
        """
        Lock SFP
        :param sfp_lock_record: tuple/list in format:
           ("MRBTS-{}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1",
             {
                 "expected_alarms": [
                     {
                         'fault_id': 10,
                         'fault_name': 'No connection to unit',
                         'reason': 'RU not detected after BTS startup'},
                     {
                         'fault_id': 1868,
                         'fault_name': 'BTS configuration error (not enough HW for LCR)'},
                 ],
                 "need_unlock_to_on_air": True,
                 "impacted_cells": [0, 3],
                 "timeout_for_cells_initialization": "20 min",
                 "timeout_for_cells_onair_after_unlock": "6min"},
            )
        :param reset_site: if True reset site after SFP lock
        :param time_for_site_available: max time of waiting for site availability after reset (not to onAir!)
        :param time_cells_onair: max time of waiting for all cells to be onAir after reset
               (from when the site becomes available)
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        logging.debug(f'Lock Record: {sfp_lock_record}')
        lane_dist_name = sfp_lock_record[0]
        lock_config = sfp_lock_record[1]

        self._allow_expected_alarms(sfp_lock_record=sfp_lock_record)

        logging.info(f'Start lock of obj: {lane_dist_name}')
        self.gnb_scf_obj.perform_configuration_parameter_recommissioning(
            dist_name=self.adjust_dist_name(dist_name=lane_dist_name, bts_id=bts_id, du_id=du_id),
            parameter='administrativeState', operation='update', value='Locked', skip_parameter_relation_errors=False,
            should_activate=True, timeout=60)

        if reset_site:
            logging.info('Resetting site')
            self.gnb_du_obj.reset_bts()
            logging.info('Waiting for site availability')
            self.gnb_du_obj.wait_for_site_to_be_available(timeout=time_for_site_available, interval=30)

        logging.info('Waiting for impacted cells initialization')
        for cell in lock_config['impacted_cells']:
            self._wait_for_cell_initialization_end(cell_id=cell,
                                                   timeout=lock_config['timeout_for_cells_initialization'], interval=30)

        logging.info('Verifying alarms on impacted cells')
        for alarm in lock_config['expected_alarms']:
            check_alarms_and_affected_cells(fid=alarm['fault_id'], affected_cells=lock_config['impacted_cells'])

        if not lock_config['need_unlock_to_on_air']:
            logging.info('Waiting for all cells to be onAir')
            self.gnb_cell_obj.wait_for_all_cells_to_be_onair(timeout=time_cells_onair, interval=30)

    def _wait_for_cell_initialization_end(self, cell_id, timeout=120, interval=10):

        start_time = time.time()
        end_time = start_time + time_to_seconds(time=timeout)
        interval_in_seconds = time_to_seconds(time=interval)
        while time.time() < end_time:
            try:
                self.gnb_cell_obj.verify_cell_statuses(cell_id=cell_id, procedural_status='initializing')
                time.sleep(interval_in_seconds)
            except IncorrectStatuses as e1:
                logging.info(f'CELL-{cell_id} not in the initializing state: {repr(e1)}')
                break
        else:
            raise CellInitializationNotFinished(f'The timeout={timeout} has passed and CELL-{cell_id} '
                                                f'is still in the initializing state')

    def _allow_expected_alarms(self, sfp_lock_record):
        expected_alarms = sfp_lock_record[1]["expected_alarms"]
        self.gnb_alarm_obj.allow_alarm(alarm=expected_alarms)
        logging.info(f'Alarms added to allowed: {expected_alarms}')

    def _disallow_expected_alarms(self, sfp_unlock_record):
        expected_alarms = sfp_unlock_record[1]["expected_alarms"]
        self.gnb_alarm_obj.disallow_alarm(alarm=expected_alarms)
        logging.info(f'Alarms removed from allowed: {expected_alarms}')

    def unlock_sfp(self, sfp_unlock_record, time_cells_onair_after_reset=600, time_cells_onair=900, bts_id=0, du_id=0):
        """
        Unlock SFP
        :param sfp_unlock_record: tuple/list in format:
            ("MRBTS-{}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1",
             {
                 "expected_alarms": [
                     {
                         'fault_id': 10,
                         'fault_name': 'No connection to unit',
                         'reason': 'RU not detected after BTS startup'},
                     {
                         'fault_id': 1868,
                         'fault_name': 'BTS configuration error (not enough HW for LCR)'},
                 ],
                 "need_unlock_to_on_air": True,
                 "impacted_cells": [0, 3],
                 "timeout_for_cells_initialization": "20 min",
                 "timeout_for_cells_onair_after_unlock": "6min"},
            )
        :param time_for_site_available: max time of waiting for site availability after reset (not to onAir!)
        :param time_cells_onair: max time of waiting for all cells to be onAir after reset
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        logging.debug(f'Unlock Record: {sfp_unlock_record}')
        lane_dist_name = sfp_unlock_record[0]
        unlock_config = sfp_unlock_record[1]
        logging.info(f'Start unlock of obj: {lane_dist_name}')
        self.gnb_scf_obj.perform_configuration_parameter_recommissioning(
            dist_name=self.adjust_dist_name(lane_dist_name, bts_id=bts_id, du_id=du_id),
            parameter='administrativeState',
            operation='update',
            value='Unlocked',
            skip_parameter_relation_errors=False,
            should_activate=True, timeout=60)

        if unlock_config['need_unlock_to_on_air']:
            try:
                logging.info('Waiting for all cells to be onAir')
                self.gnb_cell_obj.wait_for_all_cells_to_be_onair(
                    timeout=unlock_config['timeout_for_cells_onair_after_unlock'], interval=30)
            except CellNotOnAir as e:
                logging.warning(e)
                logging.warning("Doing additional site reset because cell hasn't recovered after SFP unlock "
                                "(refer to PR729516/PR748050)")
                self.gnb_du_obj.reset_bts()
                self.gnb_cell_obj.wait_for_all_cells_to_be_onair(timeout=time_cells_onair, interval=30)
            finally:
                self._disallow_expected_alarms(sfp_unlock_record=sfp_unlock_record)

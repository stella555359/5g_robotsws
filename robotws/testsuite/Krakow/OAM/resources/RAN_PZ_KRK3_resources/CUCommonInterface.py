"""
Interface for customizing CU.py functions from common keywords.

:copyright: Nokia Networks
:author: Lukasz Rzodeczko
:contact: lukasz.rzodeczko@nokia.com
:maintainer: Lukasz Rzodeczko
:contact: lukasz.rzodeczko@nokia.com

"""
from datetime import datetime
from moler.device import DeviceFactory
from taf.rfrl.bts.connections import device_aliases
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.cu.cu_operations import CuOperations, login_logout_GUI


class CUCommonInterface(CuOperations):
    """Class contains CU(Centralized Unit) keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.
        """
        super(CUCommonInterface, self).__init__(bts_type=CUCommonInterface.bts_type)

    def _load_current_scf(self, path_to_scf, plan_name):
        """
        Loads current CU commissioning.
        :param path_to_scf: path to store CU scf
        :type path_to_scf: str
        :param plan_name: name of scf
        :type plan_name: str
        """
        path_to_scf_with_name = "{}/{}".format(path_to_scf, plan_name)
        self.get_active_cu_configuration(path_to_scf_with_name)
        self.gui_coam_cu.load_commissioning_file_and_check_load_status(path_to_scf_with_name,
                                                                       plan_name,
                                                                       validate_plan='no')

    @login_logout_GUI
    def load_current_scf_and_return_end_time(self, path_to_scf, plan_name, bts_id=0):
        """
        Loads current CU commissioning, checks if it didn't crash CU and return time when operation finished.
        :param path_to_scf: path to store CU scf
        :type path_to_scf: str
        :param plan_name: name of scf
        :type plan_name: str
        :param bts_id: BTS id - related to Test Line configuration
        :type bts_id: int
        :return load_finished: time when loading scf finished
        :type load_finished: datetime
        """
        self.verify_if_cells_are_enabled()
        self._load_current_scf(path_to_scf, plan_name)
        load_finished = datetime.now()
        self.gui_coam_cu.choose_plan(plan_name)
        self.gui_coam_cu.delete_plan()
        self.verify_if_cells_are_enabled()
        return load_finished

    @login_logout_GUI
    def load_current_scf_and_provision_it(self, path_to_scf, plan_name, bts_id=0):
        """
        Loads current CU commissioning and activates it.
        :param path_to_scf: path to store CU scf
        :type path_to_scf: str
        :param plan_name: name of scf
        :type plan_name: str
        :param bts_id: BTS id - related to Test Line configuration
        :type bts_id: int
        :return provision_started: time when provision has started.
        :type provision_started: datetime
        :return provision_finished: time when provision has finished.
        :type provision_finished: datetime
        """

        self.verify_if_cells_are_enabled()
        self._load_current_scf(path_to_scf, plan_name)
        provision_started = datetime.now()
        status = self.gui_coam_cu.activate_plan(timeout=300)
        provision_finished = datetime.now()
        if status != 'Plan activation has finished successfully':
            raise ValueError('Activation failed ' + status)
        return provision_started, provision_finished

    @load_moler_configuration_from_tl()
    def turn_off_tls_on_cu(self, bts_id=0):
        """
        Turning off tls connection type on CU to allow it reintegrate with Netact.
        :type bts_id: int
        """
        cu = DeviceFactory.get_device(format(device_aliases.ssh_gnb_cu.format(bts_id)))
        cu.goto_state("OAM")
        cmd = ' fsclish -c "set mgmt-service ne3s-ws config common connection-mode clear-text"'
        cu.get_cmd(cmd_name="sudo", cmd_params={"sudo_params": cmd})()

"""
Interface for customizing DU.py functions from common keywords.

:copyright: Nokia Networks
:author: Lukasz Rzodeczko
:contact: lukasz.rzodeczko@nokia.com
:maintainer: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com

"""
import os
from datetime import datetime
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations, login_logout_GUI
from taf.rfrl.bts.devices.du.logs_collecting.btslog_collector import GenericBtslogCollector


class DuCommonInterface(GenericDuOperations):
    """Class contains DU scf keywords for gNB"""

    bts_type = 'GNB'
    syslog = GenericBtslogCollector()

    def __init__(self):
        """
        Constructor of Gnb class.
        """
        super(DuCommonInterface, self).__init__(bts_type=DuCommonInterface.bts_type)

    @login_logout_GUI
    def load_current_scf_download_it_and_activate(self, bts_id=0, du_id=0):
        """
        Loads current DU commissioning, downloads it, then activates it.
        :param bts_id: BTS id - related to Test Line configuration
        :type bts_id: int
        :param du_id: default DU id
        :type du_id: int
        :return operation_begins: time when activation begins
        :type operation_begins: datetime
        :return close_click: time when activation ends
        :type close_click: datetime
        """
        self.__load_current_scf()
        self.__activate_plan(download_plan_without_activation=True)
        self.syslog.start_collecting_btslog()
        operation_begins = datetime.now()
        self.__activate_plan(activate_inactive_plan=True)
        close_click = datetime.now()
        self.syslog.stop_collecting_btslog()
        return operation_begins, close_click

    @login_logout_GUI
    def load_current_scf_validate_it_and_provision(self, bts_id=0, du_id=0):
        """
        Loads current DU commissioning, validates it, then provisions it.
        :param bts_id: BTS id - related to Test Line configuration
        :type bts_id: int
        :param du_id: default DU id
        :type du_id: int
        :return validation_click: time when validation begins
        :type validation_click: datetime
        :return validation_end: time when validation ends
        :type validation_end: datetime
        :return operation_begins: time when provisioning begins
        :type operation_begins: datetime
        :return close_click: time when provisioning ends
        :type close_click: datetime
        """
        self.__load_current_scf()
        validation_click, validation_end = self.__validate_plan()
        operation_begins = datetime.now()
        self.__activate_plan()
        close_click = datetime.now()
        return validation_click, validation_end, operation_begins, close_click

    @login_logout_GUI
    def load_scf_with_err_and_validate_it(self, bts_id=0, du_id=0):
        """
        Loads DU commissioning wit error and validates it, expects relational error.
        :param bts_id: BTS id - related to Test Line configuration
        :type bts_id: int
        :param du_id: default DU id
        :type du_id: int
        :return validation_click: time when validation begins
        :type validation_click: datetime
        :return validation_end: time when validation ends
        :type validation_end: datetime
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        path_to_scf = self.gui_coam.backup_bts_site_configuration(sbts=gui_alias)
        os.system("sed -i 's/\"gNbCuType\">NSA/\"gNbCuType\">SA/' " + path_to_scf)
        status = self.gui_coam.load_commissioning_file_and_check_load_status(path_to_scf, sbts=gui_alias)
        os.remove(path_to_scf)
        if not status:
            raise ValueError('loading scf failed')
        validation_click = datetime.now()
        self.gui_coam.validate_plan(sbts=gui_alias)
        validation_end = datetime.now()
        status = self.gui_coam.get_definition_status(sbts=gui_alias)
        if status != 'NIDD validation succeeded.':
            raise ValueError('definition errors occurred ' + status)
        status = self.gui_coam.get_hardware_errors(sbts=gui_alias)
        if status:
            raise ValueError('harware errors occurred ' + status)
        status = self.gui_coam.get_relation_errors(sbts=gui_alias)
        if not status:
            raise ValueError('no relation errors occurred when it should occur')
        return validation_click, validation_end,

    def login_gui(self, bts_id=0, du_id=0):
        super(DuCommonInterface, self).login_gui(bts_id=bts_id, du_id=du_id)
        self._close_startup_view_if_exists()

    def __load_current_scf(self, bts_id=0, du_id=0):
        """
        Loads current DU commissioning
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self._close_startup_view_if_exists()
        path_to_scf = self.gui_coam.backup_bts_site_configuration(sbts=gui_alias)
        status = self.gui_coam.load_commissioning_file_and_check_load_status(path_to_scf, sbts=gui_alias)
        if not status:
            raise ValueError('loading scf failed')
        os.remove(path_to_scf)

    def __activate_plan(self, activate_inactive_plan=False, download_plan_without_activation=False, bts_id=0, du_id=0):
        """
        Activates DU commissioning.
        :param activate_inactive_plan: activates inactive configuration
        :type activate_inactive_plan: bool
        :param download_plan_without_activation: downloads plan without activation
        :type download_plan_without_activation: bool
        """
        status = self.gui_coam.activate_plan(download_plan_without_activation=download_plan_without_activation,
                                             sbts=self.gui_alias.format(bts_id, du_id))
        if not status:
            raise ValueError('activating scf failed')

    def __validate_plan(self, bts_id=0, du_id=0):
        """
        Validates plan and checks if there is no errors.
        :return validation_click: time when validation begins
        :type validation_click: datetime
        :return validation_end: time when validation ends
        :type validation_end: datetime

        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        validation_click = datetime.now()
        self.gui_coam.validate_plan(sbts=gui_alias)
        validation_end = datetime.now()
        status = self.gui_coam.get_definition_status(sbts=gui_alias)
        if status != 'NIDD validation succeeded.':
            raise ValueError('definition errors occurred ' + status)
        status = self.gui_coam.get_hardware_errors(sbts=gui_alias)
        if status:
            raise ValueError('harware errors occurred ' + status)
        status = self.gui_coam.get_relation_errors(sbts=gui_alias)
        if status:
            raise ValueError('relation errors occurred ' + status)
        return validation_click, validation_end,

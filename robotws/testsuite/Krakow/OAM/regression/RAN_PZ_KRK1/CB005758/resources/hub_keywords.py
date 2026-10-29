import logging
import re

from moler.device import DeviceFactory
from moler.exceptions import CommandFailure
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations


class hub_keywords(object):

    def __init__(self, hub_name='GNB0_DU0_RU0', config_file='/opt/RFSW/etc/cfg/asir_config.xml',
                 modified_temperature=10.0):
        self.hub_name = hub_name
        self.config_file = config_file
        self.backup_file = config_file.split('.')[0] + '_backup.' + config_file.split('.')[1]
        self.modified_temperature = modified_temperature
        self.asir = GnbAsirHubOperations()

    @load_moler_configuration_from_tl()
    def _verify_file_exists(self, file_path):
        """
        Verify if file is present on gNB in given directory.

        :param str file_path: path to the file being checked
        :return:  True if file exist, else False
        """
        hub = DeviceFactory.get_device(name=self.hub_name)
        hub.goto_state("RU")
        ls_cmd = hub.get_cmd(cmd_name='ls',
                             cmd_params={'options': ' {}'.format(file_path)})
        try:
            ls_cmd()
        except CommandFailure:
            return False
        else:
            return True

    @load_moler_configuration_from_tl()
    def _verify_file_has_not_modify_value(self, file_path):
        """
        Check that the file does not contain changed values

        :param str file_path: path to the file being checked
        :return: True if file does not contain changed values, else False
        """
        hub = DeviceFactory.get_device(name=self.hub_name)
        hub.goto_state("RU")
        grep_cmd = hub.get_cmd(cmd_name="grep",
                               cmd_params={"options": "-owE '<high>[0-9]*.[0-9]</high>|" +
                                                      "<critical>[0-9]*.[0-9]</critical>'" + " " + file_path})
        grep_result = grep_cmd()
        grep_result = list(filter(None, grep_result['LINES']))
        temperatures = []
        for line in grep_result:
            temperatures.append(float(re.findall(r'(\d*\.?\d+)', line)[0]))
        result = not all(element == self.modified_temperature for element in temperatures)
        return result

    def _create_backup_hub_config(self):
        """
        Create backup of configuration file

        :return: None
        """
        hub = DeviceFactory.get_device(name=self.hub_name)
        hub.goto_state("RU")
        cp_cmd = hub.get_cmd(cmd_name="cp", cmd_params={'src': self.config_file,
                                                        'dst': self.backup_file})
        cp_cmd()
        logging.info("Config file has been successfully backed up")

    @load_moler_configuration_from_tl()
    def verify_and_back_up_hub_config(self):
        """
        Verify that the configuration file is correct and back it up

        :return: None
        """
        if self._verify_file_has_not_modify_value(file_path=self.config_file):
            self._create_backup_hub_config()
        else:
            logging.info("The config file has been already changed! Trying to find a backup of a file.")
            self.restore_hub_config()
            self._create_backup_hub_config()

    @load_moler_configuration_from_tl()
    def restore_hub_config(self):
        """
        Restore the original configuration

        :return: None
        """
        hub = DeviceFactory.get_device(name=self.hub_name)
        hub.goto_state("RU")
        if self._verify_file_exists(file_path=self.backup_file) and \
                self._verify_file_has_not_modify_value(file_path=self.backup_file):
            mv_cmd = hub.get_cmd(cmd_name="mv", cmd_params={'src': self.backup_file, 'dst': self.config_file})
            mv_cmd()
            logging.info("The configuration file has been successfully restored from the backup file")
        else:
            logging.info("Config file backup does not exist or does not contain correct values! Hub reset started.")
            self.asir.reset_hub()
            hub.goto_state("RU")

    @load_moler_configuration_from_tl()
    def decrease_temperature_threshold(self):
        """
        Decrease the acceptable temperature values.

        :return: None
        """
        hub = DeviceFactory.get_device(name=self.hub_name)
        hub.goto_state("RU")
        sed_cmd = hub.get_cmd(cmd_name="sed",
                              cmd_params={'input_files': [self.config_file],
                                          'options': "-i -e 's_<high>[0-9]*.[0-9]</high>_<high>{}</high>_'"
                                          .format(self.modified_temperature) +
                                          " -e 's_<critical>[0-9]*.[0-9]</critical>_<critical>{}</critical>_'"
                                          .format(self.modified_temperature)})
        sed_cmd()
        logging.info("The temperature thresholds have been successfully lowered")

from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout, login_logout_GUI
from robot.libraries.BuiltIn import BuiltIn, logger
from pprint import pformat
import time

from taf.selenium.sbts import sbts as selenium_coam_sbts
from selenium.common.exceptions import ElementClickInterceptedException, TimeoutException
from taf.rfrl.utilities import tl_config
from taf.rfrl.utilities.test_config import get_log_path
from taf.selenium.sbts.common.debug import catch_interface_exception, catch_intercepted_click_exception
from taf.internal.aliasing import LookupHandler
from taf.selenium.sbts.facade import Sbts
import os


class commissioning_custom(GnbCommissioning):
    lookup_handler = LookupHandler("sbts", Sbts)
    SCF_DIR = BuiltIn().get_variable_value('${OUTPUT DIR}') + '/scf'
    SCF_CURRENT = 'current_scf.xml'
    SCF_MODIFIED = 'new_scf.xml'

    def __init__(self):
        super().__init__()

    @catch_interface_exception
    @lookup_handler.implicit_lookup
    def press_enter_on_element(self, sbts=None):
        sbts.configuration.press_enter_on_element('')

    @login_logout_GUI
    def change_parameter_custom(self, dist_name, parameter, value, bts_configuration='Current',
                                configuration_name=None, timeout=600,
                                bts_id=0, du_id=0):
        """
        Change parameter via GUI on bts.
        :param dist_name:object dist name ie. "MRBTS-{}/EQM-{}/APEQM-{}/ASIRMOD-1"
        :type  dist_name: str
        :param parameter: parameter name ie. "Administrative state"
        :type  parameter: str
        :param value: parameter value ie. "Locked" or "Unlocked"
        :type  value: str
        :param bts_configuration: optional, "Current" or "Planned" bts configuration can be used
        :type bts_configuration: str
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration, default 0
        :type  bts_id: int
        :param du_id: DU id - related to Test Line configuration, default 0
        :type  du_id: int
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        if configuration_name:
            logger.info(f'change_parameter_custom; {timeout=} Prepare to create plan...')
            self.gui_coam.create_plan(copy_configuration_from='CURRENT_BTS_CONF-1',
                                      configuration_name=configuration_name,
                                      sbts=gui_alias)
            logger.info('change_parameter_custom; ... Plan created')
            self.gui_coam.save_screenshot(filename='create_plan', sbts=gui_alias)
        self.gui_coam.set_parameter_value(
            dist_name=self.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id),
            filter_param=parameter,
            new_value=value,
            bts_configuration=bts_configuration,
            timeout=timeout,
            sbts=gui_alias)
        logger.info("Parameter was set...")
        self.gui_coam.save_screenshot(filename='set_parameter_value', sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.save_screenshot(filename='validate_plan', sbts=gui_alias)
        time.sleep(10)
        self.gui_coam.save_screenshot(filename='validate_plan_after_sleep', sbts=gui_alias)
        logger.info("Plan Validated, going to activate...")
        self.gui_coam.activate_plan(sbts=gui_alias, activate_inactive_plan=False)
        self.gui_coam.save_screenshot(filename='after_activate_plan', sbts=gui_alias)
        logger.info("Waiting for activation")
        time.sleep(60)

    def change_parameter_custom_2(self, dist_name, parameter, value, bts_configuration='Current',
                                  configuration_name=None, timeout=600,
                                  bts_id=0, du_id=0):
        """
        Change parameter via GUI on bts.
        :param dist_name:object dist name ie. "MRBTS-{}/EQM-{}/APEQM-{}/ASIRMOD-1"
        :type  dist_name: str
        :param parameter: parameter name ie. "Administrative state"
        :type  parameter: str
        :param value: parameter value ie. "Locked" or "Unlocked"
        :type  value: str
        :param bts_configuration: optional, "Current" or "Planned" bts configuration can be used
        :type bts_configuration: str
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration, default 0
        :type  bts_id: int
        :param du_id: DU id - related to Test Line configuration, default 0
        :type  du_id: int
        :return: None
        """
        log_dir = None
        self.gui_coam = selenium_coam_sbts()
        logger.debug("Enable Virtual Display")
        self.gui_coam.enable_virtual_display()
        logger.debug("[{}] New GUI connection".format('aaasssdddfff'))
        credentials = tl_config.get_web_credentials_for_du(bts_id, du_id, self.bts_type)
        if log_dir is None:
            log_dir = os.path.join(get_log_path(), 'selenium_logs', 'aaasssdddfff')
        download_folder = os.path.join(log_dir, "download")
        if not os.path.exists(download_folder):
            os.makedirs(download_folder)
        try:
            self.gui_coam.login(url='https://{}/'.format(credentials['ip']),
                                username=credentials['username'],
                                password=credentials['password'],
                                screenshot_dir=os.path.join(log_dir, 'screenshot'),
                                download_dir=download_folder,
                                version=self._get_proper_coam_selenium_version(bts_id, du_id),
                                alias='aaasssdddfff',
                                timeout=timeout)
        except TimeoutException:
            logger.warning("Login failed, Try to use method login_after_screen_lock")
            self._login_gui_after_screen_lock(bts_id, du_id)

        if configuration_name:
            logger.info(f'change_parameter_custom; {timeout=} Prepare to create plan...')
            self.gui_coam.create_plan(copy_configuration_from='CURRENT_BTS_CONF-1',
                                      configuration_name=configuration_name,
                                      sbts='aaasssdddfff')
            logger.info('change_parameter_custom; ... Plan created')
        self.gui_coam.set_parameter_value(
            dist_name=self.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id),
            filter_param=parameter,
            new_value=value,
            bts_configuration=bts_configuration,
            timeout=timeout,
            sbts='aaasssdddfff')
        self.gui_coam.validate_plan(sbts='aaasssdddfff')
        self.gui_coam.activate_plan(sbts='aaasssdddfff', activate_inactive_plan=True)
        logger.info("Waiting for activation")
        time.sleep(120)

    @login_logout
    def get_current_scf_file(self, local_dir_path=SCF_DIR, file_name=SCF_CURRENT, timeout=120, bts_id=0, du_id=0):
        connection = self.rest_alias.format(bts_id, du_id)
        return self.admin.get_current_scf_file(local_dir_path, file_name, timeout, connection)

    def change_object_id_and_generate_new_scf_config(self, dist_name: str, new_id, in_scf, out_scf):
        with open(out_scf, 'w') as out_file:
            out = ''
            new_dist_name = dist_name.rsplit('-', 1)[0] + '-' + str(new_id)
            with open(in_scf) as in_file:
                idx1 = 0
                l_idx = 1
                while True:
                    line = in_file.readline()
                    if not line:
                        logger.info(f'Dist Name replaced {idx1} times')
                        break  # Stop when end of file is reached
                    if dist_name in line:
                        idx1 += 1
                        logger.debug(f'{idx1}. Line {l_idx}: Found {dist_name}, replacing in line with {new_dist_name}')
                        out += line.replace(dist_name, new_dist_name)
                    else:
                        out += line
                    l_idx += 1
            out_file.write(out)
        return out_scf

    def exchange_objects_and_generate_new_scf_config(self, dist_name1: str, dist_name2: str, in_scf, out_scf):
        logger.debug(f'exchange_objects_and_generate_new_scf_config {dist_name1=} {dist_name2=}')
        with open(out_scf, 'w') as out_file:
            out = ''
            with open(in_scf) as in_file:
                idx1 = 0
                idx2 = 0
                l_idx = 1
                while True:
                    line = in_file.readline()
                    if not line:
                        logger.info(f'Dist Name replaced {idx1 + idx2} times')
                        break  # Stop when end of file is reached
                    if dist_name1 in line:
                        idx1 += 1
                        logger.debug(f'{idx1}. Line {l_idx}: Found {dist_name1}, replacing in line with {dist_name2}')
                        out += line.replace(dist_name1, dist_name2)
                    elif dist_name2 in line:
                        idx2 += 1
                        logger.debug(f'{idx2}. Line {l_idx}: Found {dist_name2}, replacing in line with {dist_name1}')
                        out += line.replace(dist_name2, dist_name1)
                    else:
                        out += line
                    l_idx += 1
            out_file.write(out)
        return out_scf

    def change_object_id(self, dist_name, new_id, timeout=300, bts_id=0, du_id=0):
        file_path = self.get_current_scf_file(self.SCF_DIR, self.SCF_CURRENT)
        out_scf = os.path.join(self.SCF_DIR, self.SCF_MODIFIED)
        self.change_object_id_and_generate_new_scf_config(dist_name, new_id, file_path, out_scf)
        self.perform_bts_full_commissioning(scf_file=out_scf, timeout=timeout, bts_id=bts_id, du_id=du_id)

    def exchange_objects(self, dist_name, dist_name2, timeout=300, bts_id=0, du_id=0):
        file_path = self.get_current_scf_file(self.SCF_DIR, self.SCF_CURRENT)
        out_scf = os.path.join(self.SCF_DIR, self.SCF_MODIFIED)
        self.exchange_objects_and_generate_new_scf_config(dist_name, dist_name2, file_path, out_scf)
        self.perform_bts_full_commissioning(scf_file=out_scf, timeout=timeout, bts_id=bts_id, du_id=du_id)

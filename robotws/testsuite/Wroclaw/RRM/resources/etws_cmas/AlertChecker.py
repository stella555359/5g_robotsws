import os
import re
from datetime import datetime
from lxml import etree
from taf.transport.ssh import ssh
from robot.api import logger

from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.resources.etws_cmas.yaml_loader import load_ues


class XmlFileDoesNotExist(Exception):
    pass


class UnknownAlertType(Exception):
    pass


class AlertDoesNotExist(Exception):
    pass


def alert_element(func):
    def inner_func(*args, **kwargs):
        logger.debug("Checking alert element..")
        try:
            return func(*args, **kwargs)
        except RuntimeError:
            raise AlertDoesNotExist("Alert was not found!")
    return inner_func


class AlertTypes:
    Earthquake = 'Earthquake warning'
    Tsunami = 'Tsunami warning'
    Presidential = 'Presidential alert'
    Extreme = 'Emergency alert: Extreme'
    Severe = 'Emergency alert: Severe'
    Child = r'Child abduction \(Amber alert\)'
    National = r'National alert'

    @classmethod
    def check_type(cls, alert_type):
        try:
            return getattr(cls, alert_type)
        except AttributeError:
            raise UnknownAlertType("Alert type {} does not exist!".format(alert_type))


class AdbCommandExecutor:
    def __init__(self, hostname=None, user=None, password=None, serial_number=None):
        self.hostname = hostname
        self.user = user
        self.password = password
        self.serial_number = serial_number
        self.client = ssh()

    def _adb_shell(self, command):
        output = self.client.execute('adb -s {} shell {}'.format(self.serial_number, command),
                                     connection=self.serial_number)
        logger.debug(output)
        return output

    def connect(self):
        self.client.connect_to(self.hostname, self.user, self.password, alias=self.serial_number)

    def dump_screen_to_xml(self, filename):
        return self._adb_shell('uiautomator dump /sdcard/{}'.format(filename))

    def capture_screenshot(self, filename):
        output = self._adb_shell('screencap /sdcard/{}'.format(filename))
        logger.debug(output)
        return output

    def download_file(self, filename, destination):
        remote_path = '/home/{}/{}'.format(self.user, filename)
        self.client.execute('adb -s {} pull /sdcard/{}'.format(self.serial_number, filename),
                            connection=self.serial_number)
        self.client.download_file(remote_path, destination, connection=self.serial_number)
        self.client.execute('rm {}'.format(remote_path), connection=self.serial_number)
        self._adb_shell('rm /sdcard/{}'.format(filename))

    def click(self, x, y):
        logger.debug("Click on {} {}".format(x, y), html=True)
        self._adb_shell('input tap {} {}'.format(x, y))

    def disconnect(self):
        self.client.disconnect(self.serial_number)


class AlertChecker:
    ALERT_TITLE = './/node[contains(@resource-id, "alertTitle")]'
    ALERT_MSG = './/node[contains(@resource-id, "message")]'
    ALERT_BUTTON = './/node[contains(@resource-id, "dismissButton")]'

    ROBOT_LIBRARY_SCOPE = 'TEST CASE'

    def __init__(self, serial_number, output_dir=None):
        self.serial_number = serial_number
        self.adb_client = None
        self.output_dir = output_dir or get_robot_variable('${OUTPUT_DIR}')
        self._xml_file = None

    def configure_adb_client(self):
        if not self.adb_client:
            self.adb_client = AdbCommandExecutor(*self.__get_ssh_details_for_ue(), serial_number=self.serial_number)

    def __get_ssh_details_for_ue(self):
        ues = load_ues()
        try:
            ue_details = [ue for ue in ues if ue.serial_number == self.serial_number][0]
        except IndexError:
            logger.warn("UE with serial number {} was not found in tl configuration!".format(self.serial_number))
            return '', '', ''
        ssh_details = ue_details.ssh_connection_details
        return ssh_details.addr, ssh_details.username, ssh_details.password

    @staticmethod
    def _load_xml_file(xml_file):
        try:
            return etree.parse(xml_file, parser=etree.XMLParser(remove_comments=True, remove_blank_text=True))
        except IOError:
            raise XmlFileDoesNotExist('File {} does not exist. Please set correct path to the file.'.format(xml_file))

    def __find_xml_element(self, xpath):
        try:
            return self._xml_file.getroot().xpath(xpath)[0]
        except IndexError:
            raise RuntimeError("Element with xpath {} was not found!".format(xpath))

    @alert_element
    def __get_type(self):
        elem_title = self.__find_xml_element(self.ALERT_TITLE)
        return elem_title.get('text')

    @alert_element
    def __get_message(self):
        elem_msg = self.__find_xml_element(self.ALERT_MSG)
        return elem_msg.get('text')

    @alert_element
    def __get_button_coords(self):
        elem_btn = self.__find_xml_element(self.ALERT_BUTTON)
        bounds = elem_btn.get('bounds')
        coords = re.findall(r'\d+', bounds)
        x = (int(coords[2]) - int(coords[0])) / 2 + int(coords[0])
        y = (int(coords[3]) - int(coords[1])) / 2 + int(coords[1])
        logger.debug("OK button coords: {} {}".format(x, y))
        return x, y

    def is_any_alert_visible(self):
        alert_title = self._xml_file.getroot().xpath(self.ALERT_TITLE)
        if alert_title:
            logger.info("Alert found: {}".format(alert_title[0].get('text')), also_console=True)
        return bool(alert_title)

    def save_screenshot(self, filename):
        destination = os.path.join(self.output_dir, filename)
        logger.info('Saving screenshot to {}'.format(destination))
        self.adb_client.capture_screenshot(filename)
        self.adb_client.download_file(filename, destination)

    def get_current_screen(self, filename):
        destination = os.path.join(self.output_dir, filename)
        self.adb_client.dump_screen_to_xml(filename)
        self.adb_client.download_file(filename, destination)
        self._xml_file = self._load_xml_file(destination)

    def clear_all_alerts(self):
        self.configure_adb_client()
        filename = 'cleanup_{}.xml'.format(self.serial_number)
        self.adb_client.connect()
        self.get_current_screen(filename)
        while self.is_any_alert_visible():
            coords = self.__get_button_coords()
            self.close_alert(coords)
            self.get_current_screen(filename)
        self.adb_client.disconnect()
        os.remove(os.path.join(self.output_dir, filename))

    def close_alert(self, coords):
        self.adb_client.click(*coords)
        logger.debug('Alert closed.', html=True)

    def is_alert_visible_on_the_screen(self, alert_type, message=None, filename=None):
        """
        :param alert_type: AlertTypes
        :param message: message in alert
        :param filename: log name
        :return:
        """
        self.configure_adb_client()
        if not filename:
            filename = re.split(r'-|_', get_robot_variable("${TEST_NAME}"), maxsplit=1)[1]
            filename = self.__timestamped_filename(filename)
        self.adb_client.connect()
        alert_type = AlertTypes.check_type(alert_type)
        self.get_current_screen('{}.xml'.format(filename))
        current_alert_type = self.__get_type()
        try:
            assert re.match('{}.*'.format(alert_type.lower()), current_alert_type.lower()), \
                'Alert is different than expected! Current: {}, expected: {}'.format(current_alert_type, alert_type)
            if message:
                assert self.__get_message() == message
            logger.info("Alert found: {}".format(current_alert_type), also_console=True)
            self.save_screenshot('{}.png'.format(filename))
            self.close_alert(self.__get_button_coords())
        finally:
            self.adb_client.disconnect()

    def __timestamped_filename(self, filename):
        timestr = datetime.now().strftime("%Y_%m_%d-%I_%M_%S")
        return filename + '_{}'.format(self.serial_number) + '_{}'.format(timestr)

import logging

from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from taf.ul.moler.converter.moler_converter import MolerConverter
from taf.ul.moler.converter.interface import add_device_to_already_loaded_configuration
from taf.rfrl.ue.connections.device_aliases import ue_pc
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.HpePdu import HpePdu


class MediaTek(object):
    """
    A class representing a MediaTek device.

    Attributes:
        tl (object): The tl object.
        at_device_name (str): The name of the AT device.
        at_device (object): The AT device.
        timeout (int): The timeout value in seconds.

    Methods:
        attach(ue_id, serial_com, attempts): Attach the UE to the network.
        detach(ue_id, serial_com): Detach the UE from the network.
        reboot(expected_state, pdu_id=0, port_id): Reboots the UE from PDU.
        _load_at_device(ue_id, serial_com): Load AT device for the specified UE ID and serial communication port.
        _verify_ue_state(expected_state): Verify the state of the UE.
    """
    def __init__(self):
        """
        Initializes an instance of the MediaTek class.
        """
        self.tl = get_builtin_value("tl")
        self.at_device_name = None
        self.at_device = None
        self._pdu = None
        self.timeout = 180

    @property
    def pdu(self):
        """
        Returns the HpePdu object.

        If the HpePdu object is not already created, it creates a new instance and returns it.

        Returns:
            HpePdu: The HpePdu object.
        """
        if self._pdu is None:
            self._pdu = HpePdu()
        return self._pdu

    @load_moler_configuration_from_tl()
    def attach(self, ue_id=0, serial_com="69", attempts=3):
        """
        Attach the UE to the network.

        Args:
            ue_id (int): The ID of the UE.
            serial_com (str): The serial communication port.
            attempts (int): The maximum number of attach attempts.

        Raises:
            MediaTekUeAttachFailedException: If the UE attach fails after the maximum number of attempts.

        Returns:
            None
        """
        if attempts <= 0:
            raise MediaTekUeAttachFailedException(f"Error: UE '{ue_id}' attach failed. "
                                                  f"Maximum number of attach attempts reached.")
        self._load_at_device(ue_id=ue_id, serial_com=serial_com)
        self.at_device.goto_state('AT_REMOTE', rerun=3)
        attach_cmd = self.at_device.get_cmd(cmd_name='attach')
        attach_cmd.command_string = "AT+EFUN=1"
        attach_cmd(timeout=self.timeout)
        MolerTest.sleep(3)  # Wait for attach procedure finish
        try:
            self._verify_ue_state(expected_state="attached")
        except MediaTekUeWrongStateException as e:
            logging.warning(f"UE attach attempt failed: {str(e)}")
            return self.attach(ue_id=ue_id, serial_com=serial_com, attempts=attempts - 1)
        self.at_device.goto_state('UNIX_REMOTE')

    @load_moler_configuration_from_tl()
    def detach(self, ue_id=0, serial_com="69"):
        """
        Detaches the UE from the network.

        Args:
            ue_id (int): The ID of the UE. Default is 0.
            serial_com (str): The serial communication port. Default is "69".
        """
        self._load_at_device(ue_id=ue_id, serial_com=serial_com)
        self.at_device.goto_state('AT_REMOTE', rerun=3)
        detach_cmd = self.at_device.get_cmd(cmd_name='detach')
        detach_cmd.command_string = "AT+EFUN=0"
        detach_cmd(timeout=self.timeout)
        MolerTest.sleep(5)  # Wait for detach procedure finish
        self._verify_ue_state(expected_state="detached")
        self.at_device.goto_state('UNIX_REMOTE')

    def _load_at_device(self, ue_id, serial_com):
        """
        Load AT device for the specified UE ID and serial communication port.

        Args:
            ue_id (int): The ID of the UE.
            serial_com (str): The serial communication port.

        Returns:
            None
        """
        if not self.at_device_name:
            self.at_device_name = ue_pc.format(f"_AT_{ue_id}")
            mc = MolerConverter()
            all_devices = mc.moler_devices.get_moler_device_config()['DEVICES']
            mc.moler_devices.add_at_remote_configuration(
                device_name=self.at_device_name,
                host=self.tl.ues[ue_id].ssh_connection_details.addr,
                login=self.tl.ues[ue_id].ssh_connection_details.username,
                password=self.tl.ues[ue_id].ssh_connection_details.password,
                serial_com=serial_com,
                unix_remote_prompt=r".*user-lab0@.*",
                proxy_pc_host=None,
                proxy_pc_login=None,
                proxy_pc_password=None,
                allowed_newline_after_prompt=True)
            add_device_to_already_loaded_configuration(config=all_devices)
            self.at_device = DeviceFactory.get_device(name=self.at_device_name, initial_state='UNIX_REMOTE')

    def reboot(self, expected_state="off", pdu_id=0, port_id=0):
        """
        Reboots the UE from PDU.

        Args:
            expected_state (str, optional): The expected state of the pdu port. Defaults to "off".
            pdu_id (int, optional): The ID of the PDU. Defaults to 0.
            port_id (int, optional): The ID of the port. Defaults to 0.
        """
        self.pdu.reset_pdu_port(expected_state=expected_state, pdu_id=pdu_id, port_id=port_id)
        MolerTest.sleep(90)  # Wait until reboot procedure finished

    def _verify_ue_state(self, expected_state="attached"):
        """
        Verify the state of the UE.

        Args:
            expected_state (str): The expected state of the UE. Defaults to "attached".

        Raises:
            MediaTekUeWrongStateException: If the UE state is not the expected state.

        Returns:
            None
        """
        self.at_device.goto_state('AT_REMOTE', rerun=3)
        cgatt_cmd = self.at_device.get_cmd(cmd_name='get_attach_state')
        cgatt_state = cgatt_cmd(timeout=self.timeout)['state']
        if cgatt_state == expected_state:
            logging.info(f"UE {expected_state}. 'AT+CGATT?' output: {cgatt_state}")
        else:
            raise MediaTekUeWrongStateException(f"UE not {expected_state}. 'AT+CGATT?' output: {cgatt_state}")


class MediaTekUeWrongStateException(Exception):
    """
    Exception raised when the MediaTek UE is in the wrong state.
    """
    pass


class MediaTekUeAttachFailedException(Exception):
    """
    Exception raised when the UE attach process fails in a MediaTek device.
    """
    pass

from moler.util.moler_test import MolerTest
from taf.hw.pdu.interface import pdu
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


class HpePdu(object):
    """
    Represents an HPE PDU (Power Distribution Unit).

    This class provides methods to connect to the PDU, get the status of a PDU port,
    power on/off a PDU port, and reset a PDU port to the expected state.
    """

    def __init__(self):
        """
        Initializes an instance of the HpePdu class.
        """
        self.tl = get_builtin_value("tl")
        self.exec_time = 5
        self.pdu_id = None
        self.pdu_address = None
        self.snmp_user = None
        self.port_id = None
        self.pdu = pdu()

    def _connect_pdu(self):
        """
        Connects to the HPE PDU.

        This method sets up the HPE PDU by providing the model, host address, SNMP user, and timeout.

        Parameters:
        - model (str): The model of the PDU.
        - host (str): The IP address or hostname of the PDU.
        - snmp_user (str): The SNMP user for authentication.
        - timeout (int): The timeout value in seconds.

        Returns:
        None
        """
        self.pdu.setup_pdu(model="HPE", host=self.pdu_address, snmp_user=self.snmp_user, timeout=20)

    def _get_pdu_port_status(self):
        """
        Get the status of the PDU port.

        Returns:
            str: The status of the PDU port.
        """
        status = self.pdu.get_port_status(port=self.port_id)
        MolerTest.info(f"PDU port '{self.port_id}' status: '{status}'")

    def _power_on_pdu_port(self):
        """
        Power on the PDU port.

        This method is responsible for powering on the PDU port specified by `port_id`.
        It uses the `pdu` object to perform the power on operation and waits for `exec_time`
        seconds before returning.

        """
        self.pdu.power_on(port=self.port_id)
        MolerTest.sleep(self.exec_time)

    def _power_off_pdu_port(self):
        """
        Power off the PDU port.

        This method is responsible for powering off the PDU port specified by `port_id`.
        It uses the `power_off` method of the `pdu` object and sleeps for `exec_time` seconds.

        """
        self.pdu.power_off(port=self.port_id)
        MolerTest.sleep(self.exec_time)

    def _load_pdu_data(self, pdu_id=0, port_id=0):
        """
        Load PDU data for the given pdu_id and port_id.

        Args:
            pdu_id (int): The ID of the PDU.
            port_id (int): The ID of the port.

        Returns:
            None
        """
        self.pdu_id = pdu_id
        self.pdu_address = self.tl.pdus[pdu_id].addr
        self.snmp_user = self.tl.pdus[pdu_id].snmp_user
        self.port_id = self.tl.pdus[pdu_id].port_numbers[port_id]

    @load_moler_configuration_from_tl()
    def reset_pdu_port(self, expected_state="off", pdu_id=0, port_id=0):
        """
        Resets the PDU port to the expected state.

        Args:
            expected_state (str): The expected state of the PDU port. Default is "off".
            pdu_id (int): The ID of the PDU. Default is 0.
            port_id (int): The ID of the port. Default is 0.

        Raises:
            WrongPduStateException: If the given unsupported state is provided.

        """
        self._load_pdu_data(pdu_id=pdu_id, port_id=port_id)
        self._connect_pdu()
        self._get_pdu_port_status()
        if expected_state == "off":
            self._power_on_pdu_port()
            self._power_off_pdu_port()
        elif expected_state == "on":
            self._power_off_pdu_port()
            self._power_on_pdu_port()
        else:
            raise WrongPduStateException(f"Error: Given unsupported state: '{expected_state}'. "
                                         f"Supported states: 'on', 'off'")


class WrongPduStateException(Exception):
    """
    Exception raised when the PDU is in an incorrect state.
    """
    pass

from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
from taf.hw.pdu.interface import pdu


class HpPdu(object):
    def __init__(self, pdu_id=0):
        """
        Library provides basic HPE pdu operations.

        Example __init__.py configuration of HPE PDU:
        _pdu = HPE(
            addr="aa00.mgt.ska-lab.nsn-rdnet.net",
            port_numbers=[10, 15, 20],
            snmp_user={"userName": "user",
                       "authKey": "key",
                       "privKey": "key",
                       "authProtocol": "MD5",
                       "privProtocol": "DES",
                       },
        )

        :param pdu_id:     pdu identifier from __init__.py configuration
        :type  pdu_id:     int
        """
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.pdu = pdu()
        self.exec_time = 5
        self.pdu_id = pdu_id
        self.pdu_port_id = None
        self.address = tl.pdus[pdu_id].addr
        self.user = tl.pdus[pdu_id].snmp_user
        self.pdu_port_numbers = tl.pdus[pdu_id].port_numbers

    def _connect_pdu(self):
        self.pdu.setup_pdu(model="HPE", host=self.address, snmp_user=self.user, timeout=20)

    def _get_pdu_port_status(self):
        status = self.pdu.get_port_status(port=self.pdu_port_id)
        MolerTest.info("PDU port '{}' status: '{}'".format(self.pdu_port_id, status))

    def _power_on_pdu_port(self):
        self.pdu.power_on(port=self.pdu_port_id)
        MolerTest.sleep(self.exec_time)
        self._get_pdu_port_status()

    def _power_off_pdu_port(self):
        self.pdu.power_off(port=self.pdu_port_id)
        MolerTest.sleep(self.exec_time)
        self._get_pdu_port_status()

    @MolerTest.raise_background_exceptions()
    def reset_pdu_port(self, port_index=0):
        """
        Perform pdu port reset with status check at each step.

        :param port_index: index of the port_numbers list element from
        _init__.py pdu object configuration pointing to the pdu port identifier
        :type  port_index: int
        :return:           None
        """
        self.pdu_port_id = self.pdu_port_numbers[int(port_index)]
        self._connect_pdu()
        self._get_pdu_port_status()
        self._power_off_pdu_port()
        self._power_on_pdu_port()

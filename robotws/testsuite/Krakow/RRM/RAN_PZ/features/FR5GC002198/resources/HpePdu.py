from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
from taf.hw.pdu.interface import pdu


class HpePdu(object):
    def __init__(self, pdu_id=0, ue_port=0):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.pdu = pdu()
        self.exec_time = 5
        self.pdu_id = pdu_id
        self.address = tl.pdus[pdu_id].addr
        self.user = tl.pdus[pdu_id].snmp_user
        self.ue_port_id = tl.pdus[pdu_id].port_numbers[ue_port]

    def _connect_pdu(self):
        self.pdu.setup_pdu(model="HPE", host=self.address, snmp_user=self.user, timeout=20)

    def _get_pdu_ue_port_status(self):
        status = self.pdu.get_port_status(port=self.ue_port_id)
        MolerTest.info("PDU port '{}' status: '{}'".format(self.ue_port_id, status))

    def _power_on_pdu_ue_port(self):
        self.pdu.power_on(port=self.ue_port_id)
        MolerTest.sleep(self.exec_time)
        self._get_pdu_ue_port_status()

    def _power_off_pdu_ue_port(self):
        self.pdu.power_off(port=self.ue_port_id)
        MolerTest.sleep(self.exec_time)
        self._get_pdu_ue_port_status()

    @MolerTest.raise_background_exceptions()
    def reboot_mtk_ue(self, mtk_ports_startup_time=90):
        self._connect_pdu()
        self._get_pdu_ue_port_status()
        self._power_on_pdu_ue_port()
        self._power_off_pdu_ue_port()
        MolerTest.sleep(mtk_ports_startup_time)  # Wait until mtk ports up

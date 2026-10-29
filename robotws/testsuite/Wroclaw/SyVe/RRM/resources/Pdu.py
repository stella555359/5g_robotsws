from taf.hw.pdu import pdu
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env


class Pdu(object):
    def __init__(self, pdu_id=0):
        self.pdu = pdu()
        self.pdu_id = pdu_id
        self._setup_pdu()

    def perform_gnb_power_reset(self):
        Logger.warning(f"Resetting MRBTS-{Env.GNB_ID} with PDU: {self.model} {self.version}")
        self.pdu.reset_ports(ports=[self.gnb_port])

    def switch_off_pdu_port(self, port):
        if self.get_pdu_port_state(port) == "on":
            Logger.info(f"Switching off PDU {self.model} {self.version} port: {port}")
            self.pdu.power_off(port=port)

    def switch_on_pdu_port(self, port):
        if self.get_pdu_port_state(port) == "off":
            Logger.info(f"Switching on PDU {self.model} {self.version} port: {port}")
            self.pdu.power_on(port=port)

    def restart_pdu_port(self, port):
        Logger.info(f"Restarting PDU {self.model} {self.version} port: {port}")
        if self.get_pdu_port_state(port) == "off":
            self.pdu.power_on(port=port)
        else:
            self.pdu.reset_ports(ports=[port])

    def get_pdu_port_state(self, port):
        if not Env().is_it_dryrun_check():
            return self.pdu.get_port_status(port=port).lower()

    @property
    def ip(self):
        return Env.PDUS[self.pdu_id].addr

    @property
    def model(self):
        return Env.PDUS[self.pdu_id].vendor

    @property
    def version(self):
        return Env.PDUS[self.pdu_id].version

    @property
    def gnb_port(self):
        return Env.GNB_PDU_PORT_LIST.port_no

    def _setup_pdu(self):
        if not Env().is_it_dryrun_check():
            self.pdu.setup_pdu(model=self.model, host=self.ip, version=self.version)

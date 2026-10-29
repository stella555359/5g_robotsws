from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


class pdu_control:

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
    sms_pdus = []
    rus_pdus = []

    def __init__(self):
        pass

    def get_bts_pdus_infos(self, enb_pdus=False):

        if hasattr(self.tl, 'enbs'):
            if enb_pdus and self.tl.enbs is not None:
                self.process_enbs()

        if hasattr(self.tl, 'gnbs'):
            if self.tl.gnbs is not None:
                self.process_gnbs()

        return {'sms_pdus': self.sms_pdus, 'rus_pdus': self.rus_pdus}

    def process_enbs(self):
        for enb in self.tl.enbs:
            self.process_units(enb.system_module.common_units)
            if enb.rms:
                self.get_rus_pdu_infos(enb.rms)

    def process_gnbs(self):
        for gnb in self.tl.gnbs:
            for du in gnb.dus:
                self.process_units(du.airscale.common_units)
                if du.rus:
                    self.get_rus_pdu_infos(du.rus)

    def process_units(self, units):
        for unit in units:
            self.get_bts_sms_pdu_infos(unit)
            if unit.rus:
                self.get_rus_pdu_infos(unit.rus)
            for capacity_unit in unit.capacity_units:
                if capacity_unit.rus:
                    self.get_rus_pdu_infos(capacity_unit.rus)

    def get_bts_sms_pdu_infos(self, sm):
        logger.trace(sm)
        if sm.pdu_port:
            if not any(d['ip_addr'] == sm.pdu_port.pdu.addr and d['port_no'] == sm.pdu_port.port_no for d in
                       self.sms_pdus):
                self.sms_pdus.append(
                    {
                        "vendor": sm.pdu_port.pdu.vendor,
                        "ip_addr": sm.pdu_port.pdu.addr,
                        "port_no": sm.pdu_port.port_no
                    }
                )

    def get_rus_pdu_infos(self, rus):
        for ru in rus:
            if not any(d['ip_addr'] == ru.pdu_port.pdu.addr and d['port_no'] == ru.pdu_port.port_no for d in
                       self.rus_pdus):
                self.rus_pdus.append(
                    {
                        "vendor": ru.pdu_port.pdu.vendor,
                        "ip_addr": ru.pdu_port.pdu.addr,
                        "port_no": ru.pdu_port.port_no
                    }
                )

from robot.libraries.BuiltIn import BuiltIn
import taf.hw.pdu as tafpdu


def power_on_testline():
    tl = BuiltIn().get_variable_value("${tl}")
    p = tafpdu.pdu()
    for pdu in tl.pdus:
        p.setup_pdu(pdu.model, host=pdu.addr, version=pdu.version)
        for port in pdu.port_numbers:
            p.power_on(port)


def power_off_testline():
    tl = BuiltIn().get_variable_value("${tl}")
    p = tafpdu.pdu()
    for pdu in tl.pdus:
        p.setup_pdu(pdu.model, host=pdu.addr, version=pdu.version)
        for port in pdu.port_numbers:
            p.power_off(port)

__maintainer__ = "UTE team"
__team__ = "UTE team"
__email__ = "ute@nokia.com"
__owner_email__ = "UTE Lab Team"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.connection_details import TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline import Connection
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import FACOM, FPFH, HBTE, TopYoung

pb = {
    'gnb': FPFH(addr="10.56.17.11", port_numbers=[1]),
    'rru1': FPFH(addr="10.56.17.12", port_numbers=[3]),
}

_rru1 = RU(
    ru_hw_group="AZNA",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q171910680",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.1", port=2323
    ),
    pdu_port=pb['rru1'].pdu_ports[3],
)

_bbu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIA", rus=[_rru1])
    ],
    pdu_port=pb['gnb'].pdu_ports[1],
    hardware_type="ASIA",
)

_enb = RealEnb(
    system_module=Airscale(common_units=[_bbu])
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.17.121", username="ute", password="uteUTE!"
    ),
    connections=[_bbu],
)


tl = TestLine(
    test_pc=_test_pc,
    enbs=[_enb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROIDX2_CA_ASIA_ABIAL_FHEL",
    ues=[],
    pdus=[],
)

__all__ = ["tl"]
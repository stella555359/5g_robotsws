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
    'gnb': TopYoung(addr="10.56.201.30", port_numbers=[3]),
    'rru1': TopYoung(addr="10.56.201.29", port_numbers=[6]),
}

_rru1 = RU(
    ru_hw_group="AEQB",
    radio_type=RadioTypes.AEQB.value,
    serial_number="1M194609521",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.1", port=2323
    ),
    pdu_port=pb['rru1'].pdu_ports[6],
)

_bbu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIL", rus=[_rru1])
    ],
    pdu_port=pb['gnb'].pdu_ports[3],
    hardware_type="ASIK",
)

_enb = RealEnb(
    system_module=Airscale(common_units=[_bbu])
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.17.123", username="ute", password="uteUTE!"
    ),
    connections=[_bbu],
)


tl = TestLine(
    test_pc=_test_pc,
    enbs=[_enb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_CA_ASIK_ABIL_AZQI",
    ues=[],
    pdus=[],
)

__all__ = ["tl"]
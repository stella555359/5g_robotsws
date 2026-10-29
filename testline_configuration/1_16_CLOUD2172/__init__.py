__maintainer__ = ""
__owner_email__ = ""
__email__ = ""

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.175", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu = Gude(
    addr="10.42.169.142",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="APC",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="K9173643971",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173117555",
    capacity_units=[_fsp_1],
)

_smod = Flexi([_fct_1])

_rmod_1 = RU(ru_hw_group="", serial_number="L1102606866", pdu_port=_pdu.pdu_ports[5])

_rmod_2 = RU(ru_hw_group="", serial_number="RY114206866", pdu_port=_pdu.pdu_ports[6])

_enb_sbts = RealEnb(
    instance_id=251,
    oam_ip=[NetworkAddress(v4="10.42.177.25")],
    system_module=_smod,
    rms=[_rmod_1, _rmod_2],
)

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_AIR_B4_2722_1a3_2xFRGP",
)
__all__ = ["tl"]

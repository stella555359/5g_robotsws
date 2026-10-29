__maintainer__ = "Henry Wang"
__email__ = "henry.1.wang@nokia-sbell.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = HBTE(
    addr="10.106.205.50",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_2 = FACOM(
    addr="10.108.151.127",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA212650633",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="DH212563566",
)
_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA212650631",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="EA194155755",
)

_rmod_1 = RU(
    ru_hw_group="5Ggen3_LowF_64T64R",
    radio_type=RadioTypes.AEQA,
    serial_number="6Q193904511",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="5Ggen3_LowF_64T64R",
    radio_type=RadioTypes.AEQA,
    serial_number="6Q194202507",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="5Ggen3_LowF_64T64R",
    radio_type=RadioTypes.AEQA,
    serial_number="6Q192808876",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_smod_1 = Airscale([_fct_1])
_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1, _rmod_2, _rmod_3
    ],
    oam_ip=NetworkAddress("10.106.205.198"),
    instance_id=10840,
)
_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.151.250", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_N_ASIKL_3xABIL_3xAEQA",
)

__all__ = ["tl"]

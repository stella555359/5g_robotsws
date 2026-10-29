__maintainer__ = "nanli"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "nan.3.li@nokia-sbell.com"
__owner_email__ = "nan.3.li@nokia-sbell.com"


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
    addr="10.56.206.166",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="HBTE",
)
_pdu_2 = FPFH(
    addr="10.56.206.164",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)


_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.FXED.value,
    serial_number="1M180417864",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.FXED.value,
    serial_number="1M180417863",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS202612749",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.125", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS202612714",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.126", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA213850687",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="EA194155765",
)


_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.97.125.66"),
    instance_id=37111,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.229.9", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_N_ASIK_ABIL_AHLOA_HZ_OAM",
)

__all__ = ["tl"]

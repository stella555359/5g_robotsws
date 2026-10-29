# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "zhlu"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "zhonggenn.lu@nokia-sbell.com"
__owner_email__ = "zhonggenn.lu@nokia-sbell.com"

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
    addr="10.106.245.174",
    port_numbers=[1, 2, 3, 4, 5, 6],
)
_pdu_2 = TopYoung(
    addr="10.106.161.162",
    port_numbers=[1, 2, 3, 4, 5, 6],
)
_pdu_3 = FACOM(
    addr="10.106.245.168",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)
_pdu_4 = FACOM(
    addr="10.108.153.134",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)
_pdu_5 = FACOM(
    addr="10.108.161.144",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)


_rmod_1 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="1M222529142",
    radio_type=RadioTypes.AZHM,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)


_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA220857473",
    radio_type=RadioTypes.AHEGC,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    serial_number="6Q180811675",
    radio_type=RadioTypes.AZNC,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    serial_number="AH203500433",
    radio_type=RadioTypes.AHIB,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[7],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="F7183109055",
    radio_type=RadioTypes.FXDD,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1214502593",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIQ",
    hardware_version="476397A.101",
    serial_number="L1232102388",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="DH220846009",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907570",
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172230611",
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170317775",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_4.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.Y13",
    serial_number="L1223306888",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_5.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="A.Y13",
    serial_number="L1223202178",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.108.153.228"),
    instance_id=11266,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_4, _rmod_5], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.152.151", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.108.152.152", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_2ASIM_2ABIA_1ABIP_2ABIO_1ABIN_1AZHM_1AHEGC_1AZNC_1AHIB_1FXDD",
)

__all__ = ["tl"]

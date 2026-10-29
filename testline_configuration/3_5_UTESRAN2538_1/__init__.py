__maintainer__ = "haifhuan"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "haifeng.huang@nokia-sbell.com"
__owner_email__ = "haifeng.huang@nokia-sbell.com"


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

_pdu_1 = TopYoung(
    addr="10.56.206.182",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="TopYoung",
)
_pdu_2 = HBTE(
    addr="10.56.206.179",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="HBTE",
)
_pdu_3 = TopYoung(
    addr="10.56.206.181",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="TopYoung",
)
_pdu_4 = HBTE(
    addr="10.56.206.180",
    port_numbers=[1, 2, 3, 4, 5, 6,7,8],
    model="HBTE",
)
_pdu_5 = HBTE(
    addr="10.56.206.179",
    port_numbers=[1, 2, 3, 4, 5, 6,7,8],
    model="HBTE",
)
_pdu_6 = HBTE(
    addr="10.56.206.179",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="HBTE",
)
_pdu_7 = HBTE(
    addr="10.56.206.180",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="HBTE",
)
_pdu_8 = FPFH(
    addr="10.108.166.200",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FPFH",
)

_rmod_1 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M211807080",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.2", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
 )
_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AZQP.value,
    serial_number="1M204456938",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHPD.value,
    serial_number="RW222900576",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2051G1TP2",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[2],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="EA221152097",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_7.pdu_ports[3],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS202612759",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_6.pdu_ports[3],
)
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104U",
    serial_number="DH221441235",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213014377",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIQ",
    hardware_version="476397A.101",
    serial_number="L1232102403",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1174603754",
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508130",
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907576",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233402436",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="DH232141965",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1, _rmod_2, _rmod_5, _rmod_6
    ],
    oam_ip=NetworkAddress("10.106.170.69"),
    instance_id=2458,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3, _rmod_4], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.229.40", username="ute"
    ),
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
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.229.41", username="ute"
    ),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIM_1ASIL_2ABIO_1ABIN_1ABIA_1ABIQ_1ABIP_1AEQE_1AZQP_1AHPD_1AHLOA_1AHEGB_1AHFIB",
)

__all__ = ["tl"]

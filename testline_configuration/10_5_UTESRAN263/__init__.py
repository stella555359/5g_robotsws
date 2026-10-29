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

_pdu_1 = FPFH(
    addr="10.108.153.152",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_2 = FPFH(
    addr="10.106.245.148",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",    
    model="FPFH",
)
_pdu_3 = FPFH(
    addr="10.108.153.97",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_4 = FPFH(
    addr="10.108.153.109",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
_pdu_5 = HBTE(
    addr="10.106.245.174",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model="HBTE",
)
_pdu_6 = FACOM(
    addr="10.108.153.142",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)
_pdu_7 = FACOM(
    addr="10.108.153.108",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="FACOM",
)
_pdu_8 = FPFH(
    addr="10.106.245.147",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)
_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q190504696",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_7.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q184609754",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_6.pdu_ports[8],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q191107756",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M192827842",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M242008669",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHGB.value,
    serial_number="EB222760252",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.133", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[6],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_8T8R",
    radio_type=RadioTypes.AZHM.value,
    serial_number="1M224850918",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[4],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M172127720",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.136", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[3],
)
_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.FRGY.value,
    serial_number="EA155231714",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.137", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_10 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.FRGY.value,
    serial_number="EA172334676",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.138", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_11 = RU(
    ru_hw_group="FRMr5.1a_8T8R",
    radio_type=RadioTypes.AZQP.value,
    serial_number="1M210729883",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.139", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_12 = RU(
    ru_hw_group="FRMr5.1a_8T8R",
    radio_type=RadioTypes.AZQP.value,
    serial_number="1M210729881",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.139", port=2323
    ),
    pdu_port=_pdu_8.pdu_ports[3],
)
_rmod_13 = RU(
    ru_hw_group="FRMr5.1a_8T8R",
    radio_type=RadioTypes.AZQP.value,
    serial_number="1M210331178",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.139", port=2323
    ),
    pdu_port=_pdu_8.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIQ",
    hardware_version="476397A.101",
    serial_number="L1232005569",
    rus=[_rmod_6, _rmod_9, _rmod_13],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907567",
    rus=[_rmod_4, _rmod_7, _rmod_8, _rmod_12],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214502593",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1174603756",
    rus=[_rmod_10],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1220506965",
    rus=[_rmod_11],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233400601",
    rus=[_rmod_5],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_7.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233402437",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_7.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="DH233641159",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_12,
        _rmod_13,
    ],
    oam_ip=NetworkAddress("10.108.153.217"),
    instance_id=2515,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_5, _rmod_10, _rmod_11], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.161.195", username="ute"),
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
    SshServiceDetails(addr="10.108.161.196", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIM_1ABIQ_1ABIP_1ABIO_1ASIM_1ABIA_1ABIN_1ABIP_1AZHM_1AVQC_3AZQP_1FXDB_2515",
)

__all__ = ["tl"]

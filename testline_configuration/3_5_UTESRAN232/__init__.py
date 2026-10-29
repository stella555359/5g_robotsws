# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "amli"
__email__ = "amaand.li@nokia-sbell.com"
__owner_email__ = "amaand.li@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import FACOM, HBTE, TopYoung,FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection,TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress


_pdu_1 = FPFH(
    addr="10.108.161.145",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)

_pdu_2 = TopYoung(
    addr="10.108.190.134",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="TopYoung",
)

_pdu_3 = FACOM(
    addr="10.106.245.168",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
	model="FACOM",
)


_pdu_4 = FPFH(
    addr="10.108.161.167",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)

_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213709054",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172230571",
)
_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183242288",
)
_fsp_4 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="EA200950283",
)
_fsp_5 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="DH200160130",
)
_fsp_6 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="DH214748613",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH202364414",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.101",
    serial_number="L1192606043",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA,
    serial_number="BL2027G1AS6",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXDB,
    serial_number="1M170601983",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="cMAA_Gen4.0_8T8R_eCPRI",
    radio_type=RadioTypes.AZQL,
    serial_number="EA205151069",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.2", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[5],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA,
    serial_number="1M193000201",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_2, _rmod_4],
    oam_ip=NetworkAddress("10.108.153.153"),
    instance_id=6475,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_1, _rmod_3], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2
_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.106.245.179", username="ute"),
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
    SshServiceDetails(addr="10.106.245.180", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIN_1ASIB_2ABIL_1ABIO_1AHLOA_1FXDB_1AZQL_1AHCA",
)

__all__ = ["tl"]

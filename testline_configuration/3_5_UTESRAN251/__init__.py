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
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, TopYoung, FACOM,HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = TopYoung(
    addr="10.56.206.182",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model='TopYoung',
)
_pdu_2 = TopYoung(
    addr="10.56.206.181",
    port_numbers=[1, 2, 3, 4, 5, 6],
    model='TopYoung',
)

_pdu_3 = HBTE(
    addr="10.56.206.179",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model='HBTE',
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type=RadioTypes.FXCA.value,
    serial_number="L6122415466",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.202", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA210555996",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHPD.value,
    serial_number="6Q203001054",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170306532",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211511290",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1214006713",
)
_fsp_4 = CapacityUnit(
    addr="none",
    hardware_type="FBBA",
    hardware_version="472182A.102",
    serial_number="L6132218051",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1221505191",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="084792A.105",
    serial_number="EA173863758",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Flexi([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.106.170.74"),
    instance_id=10034,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.229.44", username="ute"
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
        addr="10.108.229.45", username="ute"
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIO_1FSMF_1FBBA_1FXCA_1AHEGC_1AHPD",
)

__all__ = ["tl"]

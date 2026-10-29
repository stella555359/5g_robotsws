# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "hanjia"
__team__ = "MN_RAN_PZ_1_HAZ_05"
__email__ = "jia.han@nokia-sbell.com"
__owner_email__ = "jia.han@nokia-sbell.com"

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


_pdu_2 = FACOM(
    addr="10.97.97.148",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_3 = TopYoung(
    addr="10.97.97.146",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_4 = FPFH(
    addr="10.97.92.210",
    port_numbers=[1, 2, 3, 4, 5, 6],
)


_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    serial_number="1M162200265",
    radio_type=RadioTypes.FXDB,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.18", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)


_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9191032025",
    radio_type=RadioTypes.AHEGB,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    serial_number="6Q190715955",
    radio_type=RadioTypes.AZNA,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233003870",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214610591",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213709056",
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q174907896",
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA190573027",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_3.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1240607104",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_3.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212562865",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
    ],
    oam_ip=NetworkAddress("10.97.91.52"),
    instance_id=22261,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_1, _rmod_2], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.56.197.180", username="ute"),
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
    SshServiceDetails(addr="10.56.197.181", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_ASIM_ASIB_ABIN_2ABIA_1AHEGB_1FXDB_1AZNA",
)

__all__ = ["tl"]

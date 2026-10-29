__maintainer__ = "Piotr Lukaszewicz"
__email__ = "piotr.lukaszewicz@nokia.com"

from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.airscale import Airscale
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = Gude(
    addr="10.42.80.194",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
)

_pdu_2 = Gude(
    addr="10.42.80.21",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AZQC",
    serial_number="AH204301193",
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AZQC",
    serial_number="1M184800067",
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="Unk",
    radio_type="AHFIB",
    serial_number="BL1911V00BI",
    pdu_port=_pdu_2.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1162615849",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1162608202",
    rus=[_rmod_2],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1172909010",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173801607",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173006406",
)

_enb_sbts_1 = RealEnb(system_module=Airscale(common_units=[_fct_1]), rms=[_rmod_1])

_enb_sbts_2 = RealEnb(system_module=Airscale(common_units=[_fct_2]), rms=[_rmod_2, _rmod_3])

_enb_sbts_2.oam_ip = NetworkAddress(
    v6="2A00:8A00:6000:6033:daef:cdff:fe29:dbb3/64",
    v4="10.42.183.70/25",
    vlan_id=267,
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.42.133.106", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.42.133.107", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_RF_AIL_B3_AZQC-AIR_B6_AZQC_CBRS_3",
    pdus=[_pdu_1, _pdu_2],
)

__all__ = ["tl"]

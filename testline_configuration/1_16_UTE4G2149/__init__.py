__maintainer__ = "Aleksandra Chudzik"
__email__ = "aleksandra.chudzik@nokia.com"
__owner_email__ = "aleksandra.chudzik@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = Gude(
    addr="10.42.60.95",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
)

_pdu_2 = Gude(
    addr="10.42.80.20",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.42.80.21",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
	radio_type="AHBCC",
    serial_number="BL2047Y22LL",
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
	radio_type="AHBCC",
    serial_number="BL2047Y22LN",
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
	radio_type="AHBCC",
    serial_number="BL2047Y22OR",
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
	radio_type="AHFIC",
    serial_number="DC1946001AW",
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
	radio_type="AHFIC",
    serial_number="DC1946001AV",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
	radio_type="AHFIC",
    serial_number="BL2037K2091",
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
	radio_type="AZQC",
    serial_number="AH204301191",
    pdu_port=_pdu_3.pdu_ports[8],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
	radio_type="AZQC",
    serial_number="AH202500159",
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
	radio_type="AZQC",
    serial_number="AH204301188",
    pdu_port=_pdu_3.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171212678",
	rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171309132",
	rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173703915",
	rus=[_rmod_7, _rmod_9],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162818410",
	rus=[_rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="DH192553438",
    capacity_units=[_fsp_1, _fsp_2],
)

_fct_2 = CommonUnit(
    SshServiceDetails(addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"),
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1171214639",
    capacity_units=[_fsp_3, _fsp_4],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.42.20.193"),
    instance_id=1913,
)

_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_7, _rmod_8, _rmod_9, ], master=_enb_sbts_1)


_pdus = [_pdu_1, _pdu_2, _pdu_3]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.193", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.192", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"),
    ],
)

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_RF_AILR_B1-B2_B4-B5_3AHBCC_3AHFIC_3AZQC_CBRS_16",
)

__all__ = ["tl"]

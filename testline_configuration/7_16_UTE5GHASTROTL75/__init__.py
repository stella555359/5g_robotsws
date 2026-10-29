__maintainer__ = "Radoslaw Skrodzki"
__team__ = "RRM team"
__email__ = "radoslaw.skrodzki@nokia.com"
__owner_email__ = "radoslaw.skrodzki@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.flexi import Flexi
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.ue import Android
from taf.config.testline.attenuator import TopYoung


_pdu_gnb = ATEN(addr="10.44.206.185", port_numbers=[8])

_pdu_gnb_ru_1 = ATEN(addr="10.44.205.252", port_numbers=[3, 7, 8])

_pdu_gnb_ru_2 = Gude(
    addr="10.44.177.82",
    port_numbers=[6],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_3 = ATEN(addr="10.44.177.90", port_numbers=[1])

_pdu_gnb_ru_4 = Gude(
    addr="10.44.206.170",
    port_numbers=[9],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2, _pdu_gnb_ru_3, _pdu_gnb_ru_4]

_attenuator = TopYoung(
    ip_addr="10.42.54.159",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.65.78/26",
        v6=None,
        vlan_id=459,
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.65.78/26",
        v6=None,
        vlan_id=459,
    ),
    x2u=NetworkAddress(
        v4="10.44.65.78/26",
        v6=None,
        vlan_id=459,
    ),
    s1u=NetworkAddress(
        v4="10.44.65.78/26",
        v6=None,
        vlan_id=459,
    ),
    xnc=NetworkAddress(
        v4="10.44.65.78/26",
        v6=None,
        vlan_id=459,
    ),
    xnu=NetworkAddress(
        v4="10.44.65.78/26",
        v6=None,
        vlan_id=459,
    ),
    ngc=NetworkAddress(
        v4="10.44.65.78/26",
        v6=None,
        vlan_id=459,
    ),
    ngu=NetworkAddress(
        v4="10.44.65.78/26",
        v6=None,
        vlan_id=459,
    ),
)

_cu_gnb_1.m = NetworkAddress(
    v4="https://10.44.65.78",
    v6=None,
    vlan_id=459,
)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2217N4035",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[3],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2243D50VX",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_3.pdu_ports[1],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2043V0PX5",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[6],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AZHL",
    serial_number="AH222703336",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[8],
)

_gnb_ru_5 = RU(
    ru_hw_group="",
    radio_type="AZHL",
    serial_number="AH212600316",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[7],
)

_gnb_ru_6 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="K9221730211",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_4.pdu_ports[9],
)

_bbmod_1_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400368",
    rus=[_gnb_ru_4, _gnb_ru_5, _gnb_ru_6],
)

_bbmod_2_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222310836",
    rus=[_gnb_ru_1, _gnb_ru_3],
)

_bbmod_3_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004071",
    rus=[_gnb_ru_2],
)

_smod_gnb_1 = CommonUnit(
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224102540",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1_gnb_1, _bbmod_2_gnb_1, _bbmod_3_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[8],
)

_airscale_gnb_1 = Airscale([_smod_gnb_1])

_du_1_gnb = DU(
    _airscale_gnb_1,
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5, _gnb_ru_6],
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb], instance_id=50898, global_bts_id=50898
)

_enb_1 = RealEnb(
    system_module=_airscale_gnb_1,
    instance_id=50898,
    global_bts_id=50898,
    x2_link_addr=NetworkAddress(
        v4="10.44.90.60/26",
        v6=None,
        vlan_id=486,
    ),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.83", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL75_ASIL_ABIO_ABIP_AHFII_AHLOB_AHFIB_2xAZHL_AEHC_MRAT",
    core=_core,
    pdus=_pdus,
    enbs=[_enb_1],
    ues=[_ues],
    attenuator=_attenuator,
    test_pcs=[_lmp_vm_gnb_1],
)

__all__ = ["tl"]

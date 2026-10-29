__maintainer__ = "Bartlomiej Gabrys"
__team__ = "VRF_WRO2_T04"
__email__ = "bartlomiej.gabrys@nokia.com"
__owner_email__ = "bartlomiej.gabrys@nokia.com"

import os
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.ue import MediaTek
from taf.config.testline.connection_details import (
    SshServiceDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.appserver import AppServer
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.core import RealCore
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb


_pdu_1 = ATEN(addr="10.44.205.204", port_numbers=[2])

_pdu_2 = Gude(
    addr="10.44.177.140",
    port_numbers=[10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.44.206.143",
    port_numbers=[5, 6],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_attenuator = TopYoung(
    ip_addr="10.42.221.144",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.88.154/26", v6=None, vlan_id=480),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.89.150/26", v6=None, vlan_id=485),
    x2u=NetworkAddress(v4="10.44.89.150/26", v6=None, vlan_id=485),
    s1u=NetworkAddress(v4="10.44.89.150/26", v6=None, vlan_id=485),
    xnc=NetworkAddress(v4="10.44.89.150/26", v6=None, vlan_id=485),
    xnu=NetworkAddress(v4="10.44.89.150/26", v6=None, vlan_id=485),
    ngc=NetworkAddress(v4="10.44.89.150/26", v6=None, vlan_id=485),
    ngu=NetworkAddress(v4="10.44.89.150/26", v6=None, vlan_id=485),
)

_cu_gnb.m = NetworkAddress(v4="https://10.44.88.154", v6=None, vlan_id=480)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2217N4024",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_2.pdu_ports[11],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1203007291",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_2.pdu_ports[12],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2229D5033",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_2.pdu_ports[10],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AVQQA",
    serial_number="L1243606655",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_3.pdu_ports[5],
)

_gnb_ru_5 = RU(
    ru_hw_group="",
    radio_type="AZHA",
    serial_number="6Q190128937",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_3.pdu_ports[6],
)


_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907505",
    rus=[_gnb_ru_5],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907506",
    rus=[_gnb_ru_2, _gnb_ru_4],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907507",
    rus=[_gnb_ru_1, _gnb_ru_3],
)

_smod_gnb_master_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2, _bbmod_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234311030",
)

_smod_1 = Airscale([_smod_gnb_master_left])

_du_1_gnb = DU(_smod_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5])

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=51667, global_bts_id=51667
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.43", username="ute", password="ute"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.111", username="wro5grrm", password="5gpass!1"
)

_ue_config = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "nokia_ue.yaml"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master],
    gnbs=[_cbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL74_ASIM_ABIP_AHFII_AEHC_AHLOB_AVQQA_AZHA_MRAT",
    core=_core,
    pdus=_pdus,
    ues=[_ue_config],
    attenuator=_attenuator,
    attenuators=[_attenuator],
)

__all__ = ["tl"]

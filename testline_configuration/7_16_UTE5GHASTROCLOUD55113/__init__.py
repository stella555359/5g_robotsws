__maintainer__ = "Lukasz Topa"
__team__ = "RRM team"
__email__ = "lukasz.topa@nokia.com"
__owner_email__ = "lukasz.topa@nokia.com"

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


_pdu_gnb = ATEN(addr="10.44.206.102", port_numbers=[5, 6])

_pdu_gnb_ru_1 = Gude(
    addr="10.44.206.190",
    port_numbers=[3, 7],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru_2 = ATEN(addr="10.44.206.214", port_numbers=[1, 2, 5])

_pdus = [_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2]

_attenuator = TopYoung(
    ip_addr="10.42.54.176",
    port=3001,
    attenuation_port_numbers=[1, 2, 5, 6, 7, 8, 9, 10, 11, 12],
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.80.150/26", v6=None, vlan_id=454),
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
        v4=None,
        v6="2a00:8a00:6000:607c::5642",
        vlan_id=455,
    ),
    x2u=NetworkAddress(
        v4=None,
        v6="2a00:8a00:6000:607c::5744",
        vlan_id=456,
    ),
    s1u=NetworkAddress(
        v4=None,
        v6="2a00:8a00:6000:607c::5845",
        vlan_id=457,
    ),
    xnc=NetworkAddress(
        v4=None,
        v6="2a00:8a00:6000:607c::5642",
        vlan_id=455,
    ),
    xnu=NetworkAddress(
        v4=None,
        v6="2a00:8a00:6000:607c::5744",
        vlan_id=456,
    ),
    ngc=NetworkAddress(
        v4=None,
        v6="2a00:8a00:6000:607c::1:6645",
        vlan_id=893,
    ),
    ngu=NetworkAddress(
        v4=None,
        v6="2a00:8a00:6000:607c::5845",
        vlan_id=457,
    ),
)

_cu_gnb_1.m = NetworkAddress(
    v4="https://10.44.80.150",
    v6=None,
    vlan_id=454,
)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2217N4036",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[7],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2229D5037",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[3],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AQQQA",
    serial_number="BL2330G603H",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[1],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="AH231900714",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[5],
)


_bbmod_1_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907574",
    rus=[_gnb_ru_1, _gnb_ru_2],
)

_bbmod_2_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.Y16",
    serial_number="L1230201249",
    rus=[_gnb_ru_3, _gnb_ru_4],
)

_smod_gnb_1 = CommonUnit(
    hardware_type="ASIM",
    hardware_version="475765A.Y13",
    serial_number="L1223306843",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1_gnb_1, _bbmod_2_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[6],
)

_airscale_gnb_1 = Airscale([_smod_gnb_1])

_du_1_gnb = DU(_airscale_gnb_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb], instance_id=55113, global_bts_id=55113
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.171", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

# _ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
#    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
# )

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIM_ABIP_AHFII_AHLOB_AQQQA_AEHC_RFS",
    core=_core,
    pdus=_pdus,
    #    ues=[_ues],
    attenuator=_attenuator,
    test_pcs=[_lmp_vm_gnb_1],
)

__all__ = ["tl"]

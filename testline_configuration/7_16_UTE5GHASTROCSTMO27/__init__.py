__maintainer__ = "Michal Jaskolski"
__team__ = "VRF_WRO2_T04"
__email__ = "michal.jaskolski@nokia.com"
__owner_email__ = "michal.jaskolski@nokia.com"

import os
import yaml
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.attenuator import TopYoung


_pdu_gnb = Gude(
    addr="10.44.177.192",
    port_numbers=[1],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru = Gude(
    addr="10.44.177.193",
    port_numbers=[4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_gnb_ru]

_attenuator = TopYoung(
    ip_addr="10.42.221.129",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24GD_NSW_07_07_07",
)

_bbmod_1_master = CapacityUnit(addr="192.168.253.20")
_bbmod_1_slave = CapacityUnit(addr="192.168.253.21")
_bbmod_1_loner = CapacityUnit(addr="192.168.253.22")

_bbmod_2_master = CapacityUnit(addr="192.168.253.24")
_bbmod_2_slave = CapacityUnit(addr="192.168.253.25")
_bbmod_2_loner = CapacityUnit(addr="192.168.253.26")

_bbmod_3_master = CapacityUnit(addr="192.168.253.28")
_bbmod_3_slave = CapacityUnit(addr="192.168.253.29")
_bbmod_3_loner = CapacityUnit(addr="192.168.253.30")

_bbmod_4_master = CapacityUnit(addr="192.168.253.36")
_bbmod_4_slave = CapacityUnit(addr="192.168.253.37")
_bbmod_4_loner = CapacityUnit(addr="192.168.253.38")

_bbmod_5_master = CapacityUnit(addr="192.168.253.39")
_bbmod_5_slave = CapacityUnit(addr="192.168.253.40")
_bbmod_5_loner = CapacityUnit(addr="192.168.253.41")

_smod_gnb_1_master = CommonUnit(
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="DH220345501",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _bbmod_1_master,
        _bbmod_1_slave,
        _bbmod_1_loner,
        _bbmod_2_master,
        _bbmod_2_slave,
        _bbmod_2_loner,
        _bbmod_3_master,
        _bbmod_3_slave,
        _bbmod_3_loner,
    ],
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_smod_gnb_1_slave = CommonUnit(
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1213103083",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _bbmod_4_master,
        _bbmod_4_slave,
        _bbmod_4_loner,
        _bbmod_5_master,
        _bbmod_5_slave,
        _bbmod_5_loner,
    ],
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_airscale_1_gnb = Airscale([_smod_gnb_1_master])

_airscale_2_gnb = Airscale([_smod_gnb_1_slave])

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.231.198/26",
        v6=None,
        vlan_id=707,
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
        v4="10.44.232.6/26",
        v6=None,
        vlan_id=708,
    ),
    x2u=NetworkAddress(
        v4="10.44.232.70/26",
        v6=None,
        vlan_id=709,
    ),
    s1u=NetworkAddress(
        v4="10.44.232.134/26",
        v6=None,
        vlan_id=710,
    ),
    xnc=NetworkAddress(
        v4="10.44.232.6/26",
        v6=None,
        vlan_id=708,
    ),
    xnu=NetworkAddress(
        v4="10.44.232.70/26",
        v6=None,
        vlan_id=709,
    ),
    ngc=NetworkAddress(
        v4="10.44.233.6/26",
        v6=None,
        vlan_id=712,
    ),
    ngu=NetworkAddress(
        v4="10.44.232.134/26",
        v6=None,
        vlan_id=710,
    ),
)

_cu_gnb.m = NetworkAddress(
    v4="https://10.44.231.198",
    v6=None,
    vlan_id=707,
)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2217N4031",
    pdu_port=_pdu_gnb_ru.pdu_ports[7],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2315N44LB",
    pdu_port=_pdu_gnb_ru.pdu_ports[8],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2239N42IB",
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="K9221231671",
    pdu_port=_pdu_gnb_ru.pdu_ports[10],
)
_gnb_ru_5 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="K9220703797",
    pdu_port=_pdu_gnb_ru.pdu_ports[11],
)

_gnb_ru_6 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1204708728",
    pdu_port=_pdu_gnb_ru.pdu_ports[12],
)

_gnb_ru_7 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2243D50VK",
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
)

_gnb_ru_8 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2243D50VU",
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)

_gnb_ru_9 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2229D5030",
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
)

_du_1_gnb = DU(
    _airscale_1_gnb,
    rus=[
        _gnb_ru_1,
        _gnb_ru_2,
        _gnb_ru_3,
        _gnb_ru_4,
        _gnb_ru_5,
        _gnb_ru_6,
        _gnb_ru_7,
        _gnb_ru_8,
        _gnb_ru_9,
    ],
)

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=50890, global_bts_id=50890
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.180.181", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master],
    gnbs=[_cbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASIL_ABIO4_ABIA1_3xAHLOB_3xAHFII_3xAEHC",
    core=_core,
    pdus=_pdus,
    ues=[_ues],
    attenuator=_attenuator,
)

__all__ = ["tl"]

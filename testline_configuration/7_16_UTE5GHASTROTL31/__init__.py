__maintainer__ = "Tomasz Niedzwiedzki"
__team__ = "VRF_WRO2_T04"
__email__ = "tomasz.niedzwiedzki@nokia.com"
__owner_email__ = "tomasz.niedzwiedzki@nokia.com"

import os
import yaml
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, CoreUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline import NetworkAddress
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.attenuator import TopYoung


_pdu_gnb = Gude(addr="10.44.177.157", port_numbers=[9], model="EPC", version="8221-1")

_pdu_gnb_ru_1 = Gude(
    addr="10.44.177.226", port_numbers=[4], model="EPC", version="8221-1"
)

_pdu_gnb_ru_2 = Gude(
    addr="10.44.206.212", port_numbers=[8], model="EPC", version="8226-1"
)

_pdu_gnb_ru_3 = Gude(
    addr="10.44.205.116", port_numbers=[6], model="EPC", version="8221-1"
)

_pdu_gnb_ru_4 = Gude(
    addr="10.44.177.79", port_numbers=[7], model="EPC", version="8221-1"
)

_pdus = [_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2, _pdu_gnb_ru_3, _pdu_gnb_ru_4]

_attenuator = TopYoung(
    ip_addr="10.42.61.251",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.41.52/26", v6=None, vlan_id=540),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.42.41.118/26", v6=None, vlan_id=541),
    x2u=NetworkAddress(v4="10.42.41.182/26", v6=None, vlan_id=542),
    s1u=NetworkAddress(v4="10.42.41.210/26", v6=None, vlan_id=543),
    xnc=NetworkAddress(v4="10.42.41.118/26", v6=None, vlan_id=541),
    xnu=NetworkAddress(v4="10.42.41.182/26", v6=None, vlan_id=542),
    ngc=NetworkAddress(v4="10.42.65.246/26", v6=None, vlan_id=545),
    ngu=NetworkAddress(v4="10.42.41.210/26", v6=None, vlan_id=543),
)

_cu_gnb.m = NetworkAddress(v4="https://10.42.41.52", v6=None, vlan_id=540)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1245003394",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[4],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AVQL",
    serial_number="L1243807763",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[8],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AVQL",
    serial_number="L1243807764",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_3.pdu_ports[6],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="6Q183336320",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru_4.pdu_ports[7],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233001961",
    rus=[_gnb_ru_1],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="	L1231803506",
    rus=[_gnb_ru_2, _gnb_ru_3],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABI0",
    hardware_version="475266A.104",
    serial_number="L1222302114",
    rus=[_gnb_ru_4],
)

_smod_gnb_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2, _bbmod_3],
    pdu_port=_pdu_gnb.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1241103982",
)

_smod = Airscale([_smod_gnb_right])

_du_gnb = DU(_smod, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4])

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_gnb], instance_id=55187, global_bts_id=55187
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.120", username="ute", password="ute"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_core = RealCore5G(mcc=310, mnc=260)

_enb_1 = RealEnb(
    system_module=None,
    rms=None,
    instance_id=55187,
    global_bts_id=45187,
    x2_link_addr=NetworkAddress(v4="10.42.90.67/26", v6=None, vlan_id=547),
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL31_ASIM_ABIQ_ABIP_ABIO_AVHA_2xAVQL_AHEC_MRAT",
    core=_core,
    enbs=[_enb_1],
    pdus=_pdus,
    ues=[_ues],
    attenuator=_attenuator,
)

__all__ = ["tl"]

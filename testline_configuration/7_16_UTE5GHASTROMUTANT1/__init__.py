__maintainer__ = "Pawel Zabawczuk"
__team__ = "VRF_WRO2_T04"
__email__ = "pawel.k.zabawczuk@nokia.com"
__owner_email__ = "pawel.k.zabawczuk@nokia.com"

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


_pdu_gnb = Gude(
    addr="10.44.200.148", port_numbers=[5, 6], model="EPC", version="8221-1"
)

_pdu_gnb_ru = Gude(
    addr="10.44.200.152",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_gnb_ru]

_attenuator = TopYoung(
    ip_addr="10.42.61.251",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.84.21/26", v6=None, vlan_id=517),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.42.85.21/26", v6=None, vlan_id=518),
    x2u=NetworkAddress(v4="10.42.85.85/26", v6=None, vlan_id=519),
    s1u=NetworkAddress(v4="10.42.85.149/26", v6=None, vlan_id=520),
    xnc=NetworkAddress(v4="10.42.85.21/26", v6=None, vlan_id=518),
    xnu=NetworkAddress(v4="10.42.85.85/26", v6=None, vlan_id=519),
    ngc=NetworkAddress(v4="10.42.86.21/26", v6=None, vlan_id=522),
    ngu=NetworkAddress(v4="10.42.85.149/26", v6=None, vlan_id=520),
)

_cu_gnb.sync = NetworkAddress(v4="10.42.85.213/26", v6=None, vlan_id=521)

_cu_gnb.m = NetworkAddress(v4="https://10.42.84.21", v6=None, vlan_id=517)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2340N4A0J",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2339N49V0",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2340N49Z0",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="AH231800621",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
)

_gnb_ru_5 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1213401834",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)

_gnb_ru_6 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1213401826",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
)

_gnb_ru_7 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2243D50X0",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[7],
)

_gnb_ru_8 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2228D500H",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[8],
)

_gnb_ru_9 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2243D50X3",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508259",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="	L1211508029",
    rus=[_gnb_ru_7, _gnb_ru_8, _gnb_ru_9],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="RW192200210",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3],
)

_bbmod_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400393",
    rus=[_gnb_ru_4, _gnb_ru_5, _gnb_ru_6],
)

_bbmod_5 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1234308969",
    rus=[_gnb_ru_4, _gnb_ru_5, _gnb_ru_6],
)

_smod_gnb_master_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2, _bbmod_3],
    pdu_port=_pdu_gnb.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1223402804",
)

_smod_gnb_slave_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_4, _bbmod_5],
    pdu_port=_pdu_gnb.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1223402802",
)

_smod_1 = Airscale([_smod_gnb_master_left])

_smod_2 = Airscale([_smod_gnb_slave_right])

_du_1_gnb = DU(
    _smod_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_7, _gnb_ru_8, _gnb_ru_9]
)

_du_2_gnb = DU(_smod_2, rus=[_gnb_ru_4, _gnb_ru_5, _gnb_ru_6])

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=55130, global_bts_id=55130
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.48", username="ute", password="ute"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_2_gnb], instance_id=55130, global_bts_id=55130
)

_lmp_vm_gnb_1_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.49", username="ute", password="ute"
    ),
    connections=[_cbts_2.dus[0].airscale.common_units[0]],
)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_core = RealCore5G(mcc=310, mnc=260)

_enb_1 = RealEnb(
    system_module=None,
    rms=None,
    instance_id=55130,
    global_bts_id=55130,
    x2_link_addr=NetworkAddress(v4="10.42.87.83/26", v6=None, vlan_id=527),
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master, _lmp_vm_gnb_1_slave],
    gnbs=[_cbts_1, _cbts_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROMUTANT1_FULLRACK_ASIL_ABIO_ABIA_3xAHFII_3xAHLOB_3xAEHC_MRAT",
    core=_core,
    enbs=[_enb_1],
    pdus=_pdus,
    ues=[_ues],
    attenuator=_attenuator,
)

__all__ = ["tl"]


# ############## ADDITIONAL PARAMS ###############
#
# 5G SWITCH DATA: http://cisco-tool.wroclaw.nsn-rdnet.net/cisco_get_cmd.py?&option=ports&ip=10.42.186.124&type=quanta
# 5G SWITCH MGMT: http://cisco-tool.wroclaw.nsn-rdnet.net/cisco_get_cmd.py?&option=ports&ip=10.42.186.188&type=cisco
#
# POD ID: X
# RACK: 1995

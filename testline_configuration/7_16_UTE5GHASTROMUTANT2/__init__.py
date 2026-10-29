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
    addr="10.44.200.148", port_numbers=[1, 3, 4], model="EPC", version="8221-1"
)

_pdu_gnb_ru = Gude(
    addr="10.44.200.151",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
    model="EPC",
    version="8220-1",
)

_pdu_gnb_ru_2 = Gude(
    addr="10.44.177.55",
    port_numbers=[11, 12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_gnb_ru, _pdu_gnb_ru_2]

_attenuator = TopYoung(
    ip_addr="10.42.66.243",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_attenuator_2 = TopYoung(
    ip_addr="10.42.54.225",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.85.20/26", v6=None, vlan_id=517),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.42.84.20/26", v6=None, vlan_id=518),
    x2u=NetworkAddress(v4="10.42.84.20/26", v6=None, vlan_id=518),
    s1u=NetworkAddress(v4="10.42.85.84/26", v6=None, vlan_id=519),
    xnc=NetworkAddress(v4="10.42.84.20/26", v6=None, vlan_id=518),
    xnu=NetworkAddress(v4="10.42.84.20/26", v6=None, vlan_id=518),
    ngc=NetworkAddress(v4="10.42.85.84/26", v6=None, vlan_id=519),
    ngu=NetworkAddress(v4="10.42.85.84/26", v6=None, vlan_id=519),
)

_cu_gnb.sync = NetworkAddress(v4="10.42.85.212/26", v6=None, vlan_id=521)

_cu_gnb.m = NetworkAddress(v4="https://10.42.85.20", v6=None, vlan_id=517)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2218G1721",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2218G1742",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2218G1724",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AHFIG",
    serial_number="BL2245W2MLR",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
)

_gnb_ru_5 = RU(
    ru_hw_group="",
    radio_type="AHFIG",
    serial_number="BL2246W2MRW",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)

_gnb_ru_6 = RU(
    ru_hw_group="",
    radio_type="AHFIG",
    serial_number="BL2245W2MJH",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
)

_gnb_ru_7 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="K9221730211",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[7],
)

_gnb_ru_8 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1213401828",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[8],
)

_gnb_ru_9 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1211203216",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266B.102",
    serial_number="L1241211022",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="	L1170105504",
    rus=[_gnb_ru_4, _gnb_ru_5, _gnb_ru_6],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233803018",
    rus=[_gnb_ru_7, _gnb_ru_8, _gnb_ru_9],
)

_bbmod_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004112",
    rus=[_gnb_ru_4, _gnb_ru_5, _gnb_ru_6],
)

_smod_gnb_master_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2],
    pdu_port=_pdu_gnb.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1240406551",
)

_smod_gnb_slave_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_3, _bbmod_4],
    pdu_port=_pdu_gnb.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234305468",
)

_smod_1 = Airscale([_smod_gnb_master_left])

_smod_2 = Airscale([_smod_gnb_slave_right])

_du_1_gnb = DU(
    _smod_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5, _gnb_ru_6]
)

_du_2_gnb = DU(
    _smod_2, rus=[_gnb_ru_4, _gnb_ru_5, _gnb_ru_6, _gnb_ru_7, _gnb_ru_8, _gnb_ru_9]
)

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=55131, global_bts_id=55131
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.114", username="ute", password="ute"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_2_gnb], instance_id=55131, global_bts_id=55131
)

_lmp_vm_gnb_1_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.115", username="ute", password="ute"
    ),
    connections=[_cbts_2.dus[0].airscale.common_units[0]],
)

# ********************************* gNB2************************************
_cu_gnb_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.84.45/26", v6=None, vlan_id=517),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.42.85.38/26", v6=None, vlan_id=518),
    x2u=NetworkAddress(v4="10.42.85.102/26", v6=None, vlan_id=519),
    s1u=NetworkAddress(v4="10.42.85.164/26", v6=None, vlan_id=520),
    xnc=NetworkAddress(v4="10.42.85.38/26", v6=None, vlan_id=518),
    xnu=NetworkAddress(v4="10.42.85.102/26", v6=None, vlan_id=519),
    ngc=NetworkAddress(v4="10.42.86.36/26", v6=None, vlan_id=519),
    ngu=NetworkAddress(v4="10.42.85.164/26", v6=None, vlan_id=522),
)

_cu_gnb_2.m = NetworkAddress(v4="https://10.42.84.45", v6=None, vlan_id=517)

_gnb_2_ru_1 = RU(
    ru_hw_group="",
    radio_type="AZHL",
    serial_number="AH225102189",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[11],
)

_gnb_2_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2217N4028",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[10],
)

_bbmod_21 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1205002456",
    rus=[],
)

_bbmod_22 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="473096A.103",
    serial_number="	L1211302998",
    rus=[_gnb_2_ru_1],
)

_bbmod_23 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475792A.103",
    serial_number="L1211506424",
    rus=[_gnb_2_ru_2],
)

_smod_gnb_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_21, _bbmod_22, _bbmod_23],
    pdu_port=_pdu_gnb.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1203606154",
)

_smod_21 = Airscale([_smod_gnb_2])

_du_1_gnb_2 = DU(_smod_21, rus=[_gnb_2_ru_1, _gnb_2_ru_2])

_cbts_3 = ClassicalBts(
    cu=_cu_gnb_2, dus=[_du_1_gnb_2], instance_id=50004, global_bts_id=50004
)

_lmp_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.54", username="ute", password="ute"
    ),
    connections=[_cbts_3.dus[0].airscale.common_units[0]],
)

# *******************************************************************************

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_core = RealCore5G(mcc=310, mnc=260)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master, _lmp_vm_gnb_1_slave, _lmp_vm_gnb_2],
    gnbs=[_cbts_1, _cbts_2, _cbts_3],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROMUTANT2_FULLRACK_ASIM_ABIP_ABIO_ABIA_3xAHFIG_3xAHLOA_3xAEHC_MRAT",
    core=_core,
    pdus=_pdus,
    ues=[_ues],
    attenuator=_attenuator,
    attenuators=[_attenuator, _attenuator_2],
)

__all__ = ["tl"]


# ############## ADDITIONAL PARAMS ###############
#
# 5G SWITCH DATA: http://cisco-tool.wroclaw.nsn-rdnet.net/cisco_get_cmd.py?&option=ports&ip=10.42.186.124&type=quanta
# 5G SWITCH MGMT: http://cisco-tool.wroclaw.nsn-rdnet.net/cisco_get_cmd.py?&option=ports&ip=10.42.186.188&type=cisco
#
# POD ID: X
# RACK: 1995

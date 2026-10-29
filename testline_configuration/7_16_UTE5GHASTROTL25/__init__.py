__maintainer__ = "Tomasz Mozola"
__team__ = "RAN_PZ_WRO_2_SG04"
__email__ = "tomasz.mozola@nokia.com"
__owner_email__ = "tomasz.mozola@nokia.com"

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


_pdu_gnb = ATEN(addr="10.44.205.223", port_numbers=[1, 2, 3, 5, 6])

_pdu_gnb_ru = ATEN(addr="10.44.206.25", port_numbers=[1, 3, 4, 7])

_pdu1 = Gude(
    addr="10.44.206.149", port_numbers=[2, 3, 5], model="EPC", version="8221-1"
)

_pdu2 = ATEN(addr="10.42.61.80", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdu3 = Gude(addr="10.44.177.39", port_numbers=[3], model="EPC", version="8221-1")

_pdus = [_pdu_gnb, _pdu_gnb_ru, _pdu1, _pdu2, _pdu3]

_attenuator = TopYoung(
    ip_addr="10.42.221.241",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.85.92/26", v6=None, vlan_id=820),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.85.92/26", v6=None, vlan_id=820),
    x2u=NetworkAddress(v4="10.44.85.92/26", v6=None, vlan_id=820),
    s1u=NetworkAddress(v4="10.44.85.92/26", v6=None, vlan_id=820),
    xnc=NetworkAddress(v4="10.44.85.92/26", v6=None, vlan_id=820),
    xnu=NetworkAddress(v4="10.44.85.92/26", v6=None, vlan_id=820),
    ngc=NetworkAddress(v4="10.44.85.92/26", v6=None, vlan_id=820),
    ngu=NetworkAddress(v4="10.44.85.92/26", v6=None, vlan_id=820),
)

_cu_gnb.m = NetworkAddress(v4="https://10.44.85.92", v6=None, vlan_id=820)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2040G1M4W",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
    ],
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2040G1M4X",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu1.pdu_ports[5],
)

_gnb_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2040G1M4U",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu1.pdu_ports[2],
)

_gnb_ru_4 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2032V0HMG",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
    ],
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
)

_gnb_ru_5 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="K9222600540",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[13],
        _attenuator.attenuator_ports[14],
        _attenuator.attenuator_ports[15],
        _attenuator.attenuator_ports[16],
    ],
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
)

_gnb_ru_6 = RU(
    ru_hw_group="",
    radio_type="AZQI",
    serial_number="1M203944681",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[21],
        _attenuator.attenuator_ports[22],
        _attenuator.attenuator_ports[23],
        _attenuator.attenuator_ports[24],
    ],
    pdu_port=_pdu2.pdu_ports[6],
)

_gnb_ru_7 = RU(
    ru_hw_group="",
    radio_type="AHPF",
    serial_number="EA211653124",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[17],
        _attenuator.attenuator_ports[18],
        _attenuator.attenuator_ports[19],
        _attenuator.attenuator_ports[20],
    ],
    pdu_port=_pdu1.pdu_ports[3],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1184319612",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="	L1184319610",
    rus=[_gnb_ru_4],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1192614807",
    rus=[_gnb_ru_6],
)

_bbmod_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIL",
    hardware_version="474020A.101",
    serial_number="L1183115033",
    rus=None,
)

_bbmod_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="	L1183413592",
    rus=[_gnb_ru_5],
)

_bbmod_6 = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203611758",
    rus=[_gnb_ru_7],
)

_smod_gnb_master_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2, _bbmod_3],
    pdu_port=_pdu_gnb.pdu_ports[5],
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="EA202458832",
)

_smod_gnb_slave_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_4, _bbmod_5, _bbmod_6],
    pdu_port=_pdu_gnb.pdu_ports[6],
    hardware_type="ASIK",
    hardware_version="474021A.101",
    serial_number="L1183412869",
)

_smod_1 = Airscale([_smod_gnb_master_left])

_smod_2 = Airscale([_smod_gnb_slave_right])

_du_1_gnb = DU(_smod_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_6])

_du_2_gnb = DU(_smod_2, rus=[_gnb_ru_5, _gnb_ru_7])

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=50123, global_bts_id=50123
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.224", username="ute", password="ute"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_2_gnb], instance_id=50123, global_bts_id=50123
)

_lmp_vm_gnb_1_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.69", username="ute", password="ute"
    ),
    connections=[_cbts_2.dus[0].airscale.common_units[0]],
)

# ************************************ LTE 1 ASIA ************************

_enb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2032V0HMH",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu3.pdu_ports[3],
)

_bbmod_enb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163606703",
    rus=[_enb_ru_1],
)

_smod_enb_1_master = CommonUnit(
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="DH202961205",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_enb_1],
    pdu_port=_pdu_gnb.pdu_ports[3],
)

_airscale_enb_1 = Flexi([_smod_enb_1_master])

_enb_1_Master = RealEnb(
    system_module=_airscale_enb_1,
    rms=[_enb_ru_1],
    global_bts_id=40888,
    instance_id=40888,
    x2_link_addr=NetworkAddress(v4="10.44.85.93/26", v6=None, vlan_id=820),
)

_enb_1_Master.m = NetworkAddress(v4="https://10.44.85.93", v6=None, vlan_id=820)

_lmp_vm_enb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.225", username="ute", password="ute"
    ),
    connections=[_enb_1_Master.system_module.common_units[0]],
)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_core = RealCore5G(mcc=310, mnc=260)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master, _lmp_vm_gnb_1_slave, _lmp_vm_enb_1_master],
    gnbs=[_cbts_1, _cbts_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASIK_ABIL_3xAHLOA_AHFIB_AEHC_AZQI_AHPF",
    core=_core,
    pdus=_pdus,
    enbs=[_enb_1_Master],
    ues=[_ues],
    attenuator=_attenuator,
)

__all__ = ["tl"]


# ############## ADDITIONAL PARAMS ###############
#
# 5G SWITCH DATA: http://cisco-tool.wroclaw.nsn-rdnet.net/cisco_get_cmd.py?&option=ports&ip=10.42.186.124&type=quanta
# 5G SWITCH MGMT: http://cisco-tool.wroclaw.nsn-rdnet.net/cisco_get_cmd.py?&option=ports&ip=10.42.186.188&type=cisco
#
# POD ID: 7
# RACK: 844

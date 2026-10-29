import os
import re

# from taf.config.testline.connection_details import (SshServiceDetails, HttpConnectionDetails)
# from taf.config.testline.testpc import TestPc
# from taf.config.testline.core import RealCore
# from taf.config.testline import RU, DU
# from taf.config.testline.pdu import FACOM
# from taf.config.testline.testline import TestLine
# from taf.config.testline.ue import Android
# from taf.config.testline.gnb import CU, ClassicalBts
# from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
# from taf.config.testline import RealEnb
# from taf.compatibility.configuration import TestlineWrapper
# from taf.config.testline.switch import DellS4048ONSwitch, DellS4048TONSwitch
# from taf.config.testline.radio import RadioTypes, SCRadioTypes, RU, SC5GRadio, SC4GRadio, RadioModule
# from taf.config.testline.attenuator import AttenuationPort,TopYoung
# from taf.config.testline import NetworkAddress, RoutingInformation
# from taf.config.testline.ue import Qualcomm, QualcommUeType
# from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
import yaml


# from typing import Optional, List, Union
# from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline import DU
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import EPC
from taf.config.testline.pdu import FACOM, HBTE
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


__maintainer__ = "Zhou Qiang"  # TL owner name
__team__ = "I_MN_SRAN_PROD_HZH_SISO_2_VRF_GMS <I_MN_SRAN_PROD_HZH_SISO_2_VRF@internal.nsn.com>"  # TL owner's team
__email__ = "qiang.1.zhou@nokia-sbell.com"  # TL owner's email


# test pc
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.94.121", username="ute", password="ute"
    )
)
# _test_pc_enb = TestPc(default_ssh_connection_details=SshServiceDetails(addr='10.68.94.120', username='ute', password='ute'), connections=[_lte_real_enb])
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.94.120", username="ute", password="ute"
    )
)

# pdu
_pdu_1 = FACOM(addr="10.69.66.100", port_numbers=[4, 5], model="facom")
_pdu_2 = FACOM(addr="10.56.7.146", port_numbers=[2, 3, 7], model="facom")
_pdu_3 = FACOM(addr="10.56.7.232", port_numbers=[1], model="facom")
_pdu_4 = FACOM(addr="10.69.66.111", port_numbers=[1, 2, 5, 6], model="facom")
_pdu_5 = FACOM(addr="10.106.211.91", port_numbers=[4, 5], model="facom")
_pdu_6 = FACOM(addr="10.69.66.102", port_numbers=[4], model="facom")
# ABIL
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="DH202663495",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="EA200259819",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="EA200259811",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1203700846",
)

_airscale = Airscale([_fct_1])

_cu = CU(
    backhaul_site_oam_ip="10.68.94.103",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.94.103", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.68.94.103", username="Nemuadmin", password="nemuuser"
    ),
)

# RU_info
_ru_1 = RU(
    ru_hw_group="UHFA:Below6GHz",
    serial_number="LBALLU-YD17100HH4Q",
    pdu_port=_pdu_2.pdu_ports[3],
)
_ru_2 = RU(
    ru_hw_group="UHFA:Below6GHz",
    serial_number="LBALLU-YD154602HLK",
    pdu_port=_pdu_3.pdu_ports[1],
)
_ru_3 = RU(
    ru_hw_group="UHFA:Below6GHz",
    serial_number="LBALLU-YD17440NX1D",
    pdu_port=_pdu_2.pdu_ports[7],
)
_ru_4 = RU(
    ru_hw_group="UHIE:Below6GHz",
    serial_number="LBALLU-YD17450P3FG",
    pdu_port=_pdu_4.pdu_ports[6],
)
_ru_5 = RU(
    ru_hw_group="UHIE:Below6GHz",
    serial_number="LBALLU-YD17440NXQU",
    pdu_port=_pdu_4.pdu_ports[2],
)
_ru_6 = RU(
    ru_hw_group="UHIE:Below6GHz",
    serial_number="LBALLU-YD17440NXT7",
    pdu_port=_pdu_4.pdu_ports[5],
)
_ru_7 = RU(
    ru_hw_group="AHFIB:Below6GHz",
    serial_number="BL1945V00LL",
    pdu_port=_pdu_4.pdu_ports[1],
)
_ru_8 = RU(
    ru_hw_group="AHFIB:Below6GHz",
    serial_number="BL1945V00IB",
    pdu_port=_pdu_5.pdu_ports[4],
)
_ru_9 = RU(
    ru_hw_group="AHFIB:Below6GHz",
    serial_number="K9183736390",
    pdu_port=_pdu_5.pdu_ports[5],
)
_rm_1 = RU(
    ru_hw_group="AHFIB:Below6GHz",
    serial_number="K9183736591",
    pdu_port=_pdu_6.pdu_ports[4],
)
_rm_2 = RU(
    ru_hw_group="UHFA:Below6GHz",
    serial_number="LBALLU-YD17440NX1L",
    pdu_port=_pdu_2.pdu_ports[2],
)

_du = DU(
    airscale=_airscale,
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7, _ru_8, _ru_9],
)
_classical_bts = ClassicalBts(cu=_cu, dus=[_du])

_capacity_unit_3 = CapacityUnit(
    addr="192.168.253.20", pdu_port=_pdu_1.pdu_ports[5], serial_number="AH173607817"
)
#
_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.68.94.102", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit_3],
    pdu_port=_pdu_1.pdu_ports[5],
    serial_number="6Q174523121",
)
#
_real_enb = Airscale(common_units=[_common_unit_2])
#
_lte_real_enb = RealEnb(airscale=_real_enb, rms=[_rm_1, _rm_2])

# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_capacity_unit_0 = CapacityUnit(
    addr="192.168.253.20", pdu_port=_pdu_1.pdu_ports[4], serial_number="DH202663495"
)
_capacity_unit_1 = CapacityUnit(
    addr="192.168.253.20", pdu_port=_pdu_1.pdu_ports[4], serial_number="EA200259819"
)
_capacity_unit_2 = CapacityUnit(
    addr="192.168.253.20", pdu_port=_pdu_1.pdu_ports[4], serial_number="EA200259811"
)
_gnb_pdu = FACOM(addr="10.69.66.100", port_numbers=[4])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0, _capacity_unit_1, _capacity_unit_2],
    pdu_port=_pdu_1.pdu_ports[4],
    serial_number="L1203700846",
)

_airscale = Airscale(common_units=[_common_unit_0])

_du = DU(
    airscale=_airscale,
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7, _ru_8, _ru_9],
    f1_m_ip_addr="10.68.94.103",
)

_cu = CU(
    backhaul_site_oam_ip="10.68.94.103",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.94.103", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.68.94.103", username="Nemuadmin", password="nemuuser"
    ),
)


# cloud_topology
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIL_ABILB1_UHFA"

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=6165, global_bts_id=6165)


# switch Dtor
_dell_s4048on_ssh = SshServiceDetails(
    addr="0.0.0.0", port="1", username="5gran", password="nokia123"
)  # EIF1 Port
# _dell_s4048on_switch = DellS4048ONSwitch(_dell_s4048on_ssh)

# switch Mtor
_dell_s4048ton_ssh = SshServiceDetails(
    addr="0.0.0.0", port="1", username="5gran", password="nokia123"
)
# _dell_s4048ton_switch = DellS4048TONSwitch(_dell_s4048ton_ssh)


_appserver_ssh = SshServiceDetails(
    addr="10.69.64.197", username="tdlte-tester", password="btstest"
)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
_ue_config_path = os.path.join(_cfg_dir, "askey_ue_data.yml")
if os.path.isfile(_ue_config_path):
    with open(_ue_config_path) as f:
        _ue_askey = f.read()
        qci_port = re.findall("(_iperf.*?port)", _ue_askey)
        for item in qci_port:
            _ue_askey = _ue_askey.replace(item, str(eval(item)))
        _ue_config = yaml.load(_ue_askey, Loader=yaml.FullLoader)
else:
    _ue_config = ""


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classical_bts],
    enbs=[_lte_real_enb],
    ues=[_ue_config],
)


__all__ = ["tl"]

# _ru_0 = RU(
#     ru_hw_group='Below6GHz',
#     default_ssh_connection_details=SshServiceDetails(
#         addr='192.168.254.52',
#         username='asb',
#         password='asb#1234'),
#     lmp_connection=SshServiceDetails(
#         addr='192.168.254.52',
#         username='root',
#         password='root'),
#     pdu_port=_ru_pdu.pdu_ports[3],
#     radio_type=RadioTypes.UHFA.value,
#     signal_analyzer=None,
#     attenuation_ports=[],
#     serial_number="LBALLU-YD17100HH4Q"
# )

# _iperf = IperfDataTransferDetails(
#     ssh_connection_details=_appserver_ssh,
#     network_interface_address='10.69.64.196',
#     iperf_path='iperf',
# )
#
# _askey_ue = Qualcomm(
#     ssh_connection_details=SshServiceDetails(
#         addr='10.68.94.93', username='siso2-tester', password='Nokia123!'),
#     serial_number='abcd',
#     qxdm_version=4,
#     ue_type=QualcommUeType.android,
#     com_port=9857,
#     heartbeat_port=6005,
#     server_command_input_port=6007,  ## type: int
#     server_qxdm_messages_port=6008,  ## type: int
#     server_command_output_port=6009,  ## type: int
#     message_stream_port=6010,  ## type: int
#     iperf_details=_iperf,  ## type: Optional[IperfDataTransferDetails]
#     capabilities=['REAL_UE', 'REAL_QUALCOMM_UE']  ## type: Optional[List[str]]
# )
# _cfg_dir = os.path.dirname(os.path.abspath(__file__))
# ue_config_path = os.path.join(_cfg_dir, './askey_ue_data.yml')
# if os.path.isfile(ue_config_path):
#     with open(ue_config_path) as f:
#         _ue_askey = f.read()
#         qci_port = re.findall("(_iperf.*?port)", _ue_askey)
#         for item in qci_port:
#             _ue_askey = _ue_askey.replace(item, str(eval(item)))
#         _ue_config = yaml.load(_ue_askey)
# else:
#     _ue_config = ""
#
#

# _appserver = AppServer(iperf_details=_iperf)
# tl = TestLine(
#     test_pc=_test_pc,
#     test_pcs=[_test_pc, _test_pc_enb],
#     gnbs=[_classical_bts],
#     enbs=[_lte_real_enb],
#     core=RealCore(mcc=262, mnc=3),
#     tl_cloud_topology=_tl_cloud_topology,
#     attenuator=_attenuator,
#     ues=[ue_config],
#     appserver=_appserver
#     #switches=[_dell_s4048on_switch, _dell_s4048ton_switch]
# )

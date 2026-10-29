__maintainer__ = "Pawel Wisniewski, Wiktor Jarosinski"
__email__ = "pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.attenuator import JFW
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.lmi import SerialOverTcp, Remote
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import (
    NetworkAddress,
    RoutingInformation,
    TafUeDataTransferProtocol,
)
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import RRB
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.pdn import PDNTafUeAndroidDetails

# *** UEs ***  DONE
_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
    expected_prompt="dummy_prompt",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2  # OPTIONAL
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    version=2,
    interface_name="n26wro",  # OPTIONAL
)

_ue1 = TafUeAndroid(
    serial_number="RFCW20EQWYA",
    capabilities=[
        "REAL_UE",
        "RFCW20EQWYA",
    ],
    ue_pc_address="10.42.224.33",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.33", username="plwr4gsfe", password="ltesfe4@"
    ),
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Off|On",
)

_pdn1 = PDNTafUeAndroidDetails(
    entryName="APN", apnName="internet", apnType=["DEFAULT"], protocol="IPV4"
)

_ue2 = TafUeAndroid(
    serial_number="RFCW216W9EY",
    capabilities=[
        "REAL_UE",
        "RFCW216W9EY",
    ],
    ue_pc_address="10.42.224.33",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.33", username="plwr4gsfe", password="ltesfe4@"
    ),
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Off|On",
)

_attenuator = JFW(
    ip_addr="10.42.221.80",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
) # --> Model do ewentualnej zmiany, skopiowany z T151

# PDUs definition - DONE
_pdu1 = Gude(
    addr="10.44.200.187", port_numbers=[1, 2, 5, 7], model="EPC", version="8041-1"
)  # --> AHFIB,AHFIB,AEHC,AHFIB
_pdu2 = Gude(
    addr="10.44.200.183", port_numbers=[1,2,5,6,7], model="EPC", version="8041-1"
)  # --> AHLOA,AHLOA,AEHC,AEHC,AHLOA
_pdu3 = Gude(
    addr="10.44.200.190", port_numbers=[5,6,7], model="EPC", version="8041-1"
)  # --> ASIL R, ASIL L, ASIB 4G
_pdus = [_pdu1, _pdu2, _pdu3]

# RUs definition 
_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2004G104L",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2003G10XE",
    pdu_port=_pdu2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1930G11OX",
    pdu_port=_pdu2.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1913VV008L",
    pdu_port=_pdu1.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL19110V00UF",
    pdu_port=_pdu1.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2051V0WQ7",
    pdu_port=_pdu1.pdu_ports[7],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="AH231900718",
    pdu_port=_pdu1.pdu_ports[5],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9223130065",
    pdu_port=_pdu2.pdu_ports[5],
)
_rmod_9 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="AH234900453",
    pdu_port=_pdu2.pdu_ports[6],
)
# BBMODs definition - DONE
_fsp_5g_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1184411870",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_5g_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1185109743",
    rus=[_rmod_4, _rmod_5],
)
_fsp_5g_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203802108",
    rus=[_rmod_6],
)
_fsp_5g_4 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224206414",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)
_fsp_lte_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173824765",
    rus=[_rmod_4, _rmod_5],
)

_fsp_lte_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173824770",
    rus=[_rmod_6],
)

_fsp_lte_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162608178",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

# SMOD definition - DONE
_fct_5g_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5g_1, _fsp_5g_2, _fsp_5g_3],
    pdu_port=_pdu3.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1224815346",
)

_fct_5g_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5g_4],
    pdu_port=_pdu3.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1224209038",
)

_fct_lte = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_lte_1, _fsp_lte_2, _fsp_lte_3],
    pdu_port=_pdu3.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1191304511",
)

_smods = Airscale([_fct_5g_left, _fct_5g_right])
_smod_4g = Airscale([_fct_lte])

# IPs and network - DONE 
_du = DU(_smods)

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.88.13"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

# Real BTS definition - DONE
_gnb = ClassicalBts(cu=_cu_1, dus=[_du], global_bts_id=55267, instance_id=55267)

_enb_sbts = RealEnb(
    system_module=_smod_4g,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.42.88.11"),  # 4G M-plane
    global_bts_id=8816,
    instance_id=8816,
)

_enb_sbts.m = NetworkAddress("10.42.88.11")

# VirtualMachines definition - DONE
_test_pc_5g = TestPc(
    SshServiceDetails(addr="10.42.194.143", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_5g_second = TestPc(
    SshServiceDetails(addr="10.42.194.151", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb.dus[0].airscale.common_units[1],
            interface_type="lmp",
        ),
    ],
)

_test_pc_lte = TestPc(
    SshServiceDetails(addr="10.42.209.39", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

# ALL Test Line - DONE
tl = TestLine(
    test_pc=_test_pc_5g,
    test_pcs=[_test_pc_5g, _test_pc_5g_second, _test_pc_lte],
    gnbs=[_gnb ],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_10_16_8816_55267_MRBTS_55267_TMO_TOL",
    ues=[_ue1, _ue2],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]

__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "piotr.linek@nokia.com"
__customer__ = "Generic"
__bucket__ = "ORAN"
__rack__ = "GTA-366"

import os
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import Gude, ATEN, EPC
from taf.config.testline.radio import RU, RadioTypes, FujitsuRadioTypes, FujitsuRU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection, TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote, Local, SerialOverHost
from taf.config.testline.connection_details import SshServiceDetails, HttpConnectionDetails, TelnetConnectionDetails
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress


# cfg_dir = os.path.dirname(os.path.abspath(__file__))

# _cu_gnb = CU(
#     backhaul_site_oam_ip=NetworkAddress(
#         v4="10.42.150.115",
#         vlan_id=150,
#         routing_v4=RoutingInformation(gateway="10.42.150.1/24"),
#     ),
#     oam_ssh_connection_details=SshServiceDetails(
#         addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
#     ),
#     oam_http_connection_details=HttpConnectionDetails(
#         addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
#     ),
#     x2c=NetworkAddress(
#         v4="10.42.149.114",
#         vlan_id=149,
#         routing_v4=RoutingInformation(gateway="10.42.149.1/24"),
#     ),
#     x2u=NetworkAddress(
#         v4="10.42.148.224",
#         vlan_id=148,
#         routing_v4=RoutingInformation(gateway="10.42.148.1/24"),
#     ),
#     s1u=NetworkAddress(
#         v4="10.42.148.224",
#         vlan_id=148,
#         routing_v4=RoutingInformation(gateway="10.42.148.1/24"),
#     ),
#     ngu=NetworkAddress(
#         v4="10.42.148.224",
#         vlan_id=148,
#         routing_v4=RoutingInformation(gateway="10.42.148.1/24"),
#     ),
#     ngc=NetworkAddress(
#         v4="10.42.149.114",
#         vlan_id=149,
#         routing_v4=RoutingInformation(gateway="10.42.149.1/24"),
#     ),
#     xnc=NetworkAddress(
#         v4="10.42.149.114",
#         vlan_id=149,
#         routing_v4=RoutingInformation(gateway="10.42.149.1/24"),
#     ),
#     xnu=NetworkAddress(
#         v4="10.42.148.224",
#         vlan_id=148,
#         routing_v4=RoutingInformation(gateway="10.42.148.1/24"),
#     ),
# )

# smod1 port 9
# smod2 port 10
# AWHQN port 8
# OFEGSA port 1
# TPS port 6
_pdu_1 = Gude(
    addr="10.42.80.138",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

# _lab_pc = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="10.42.199.76",
#         username="NOKLAB\\plwr4goam",
#         password="oampass12",
#         port="9092",
#     )
# )

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2", username="root", password="umniedziala"
    ),
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type="AWHQN",
    serial_number="AH242307926",
    product_code="475701A.103",
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_2 = FujitsuRU(
    netconf_ssh_configuration=SshServiceDetails(
        addr="172.16.37.135", username="fjncuser0", password="ncCl2fjRu+autH0"
    ),
    radio_type=FujitsuRadioTypes.OFEGSA,
    serial_number="00474",
    product_code="TA08029-B312/01",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1241408093",
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231807402",
    rus=[],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233005562",
    rus=[_rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1240607087",
)

_fct_2 = CommonUnit(
    SshServiceDetails(addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503184",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1],
    instance_id=8946, global_bts_id=8946)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_pdus = [_pdu_1]

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.73", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.79", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_N_2ASIM_2ABIQ_1ABIP_1AWHQN_1OFEGSA_1_UUFWRO",
)

__all__ = ["tl"]

__maintainer__ = "Daniel Grzesik"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "daniel.grzesik@nokia.com"

import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)


_pdu_2 = Gude(addr="10.44.205.214",  port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8221-1")
_pdu_3 = Gude(addr="10.44.205.215", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8221-1")
_pdu_4 = Gude(addr="10.44.206.104",  port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8221-1")
_pdu_5 = Gude(addr="10.44.205.222", port_numbers=[1,2,3,4,5,6,7,8,9,10,11,12], model="EPC", version="8221-1")

_pdus = [_pdu_2, _pdu_3, _pdu_4, _pdu_5]


_RU_1 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDB",
    serial_number="AS220508634",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[2],
)

_RU_2 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDB",
    serial_number="AS214500207",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="1172.16.33.129", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[1],
)

_RU_3 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDB",
    serial_number="AS213313837",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[3],
)

_RU_4 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type="AHEGHA",
    serial_number="BL2334H60MB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.135", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)

_RU_5 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type="AHEGHA",
    serial_number="BL2351H69X6",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.134", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)

_RU_6 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type="AHEGHA",
    serial_number="K9241220034",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.136", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)

_RU_7 = RU(
    ru_hw_group="cMAAr7.1_32T32R_2M",
    radio_type="AVQQ",
    serial_number="	1M243613567",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_RU_8 = RU(
    ru_hw_group="cMAAr7.1_32T32R_2M",
    radio_type="AVQQ",
    serial_number="	1M243613563",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_RU_9 = RU(
    ru_hw_group="cMAAr7.1_32T32R_2M",
    radio_type="AVQQ",
    serial_number="	1M243613566",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)


_RU_10 = RU(
    ru_hw_group="FRMr5.1_1_2T0R",
    radio_type="AHSA",
    serial_number="RW224600320",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.134", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[7],
)

_RU_11 = RU(
    ru_hw_group="FRMr5.1_1_2T0R",
    radio_type="AHSA",
    serial_number="RW224600386",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.135", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[8],
)

_RU_12 = RU(
    ru_hw_group="FRMr5.1_1_2T0R",
    radio_type="AHSA",
    serial_number="RW224600400",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.137", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[9],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183143050",
    rus=[_RU_1, _RU_2, _RU_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223310011",
    rus=[_RU_10, _RU_11, _RU_12, _RU_1, _RU_2, _RU_3],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.37",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233206255",
    rus=[_RU_4, _RU_5, _RU_6, _RU_7, _RU_8, _RU_9],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_3.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503180",
)

_smod_gnb = Airscale(common_units=[_fct_1])

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.84.81",
        vlan_id=517,
        routing=RoutingInformation(gateway="10.44.84.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.42.85.18", vlan_id=518),
    x2u=NetworkAddress(v4="10.42.85.82",  vlan_id=519),
    s1u=NetworkAddress(v4="10.42.85.190", vlan_id=520),
)

_du_gnb = DU(
    airscale=_smod_gnb, 
    rus=[_RU_1, _RU_2, _RU_3, _RU_4, _RU_5, _RU_6, _RU_7, _RU_8, _RU_9, _RU_10, _RU_11, _RU_12],
)

_cbts = ClassicalBts(cu=_cu_gnb, dus=[_du_gnb], global_bts_id=40253, instance_id=40253)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.167", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_smod_gnb.common_units[0],   
            interface_type="lmp",
        )
    ],
)

_ue_pc_ssh = SshServiceDetails(
    "10.44.72.242", "NOKLAB\plwrtrssec", password="tr55ec123"
)

_android_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_conf.yaml"
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_cbts],
    pdus=_pdus,
    ues=[_android_ue],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIM_ABIQ_WRO_TRS_369",
)

__all__ = ["tl"]

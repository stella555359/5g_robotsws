__maintainer__ = "Pawel Sniady"
__team__ = "MN RAN RD VRF WRO2 5"
__email__ = "I_MN_RAN_RD_VRF_WRO2_5@nokia.com"
__owner_email__ = "pawel.sniady@nokia.com"

import os
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.dcap import DcapBasic
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RoutingInformation
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.radio import RU, Positioner1DKrk
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue.yaml"
)
_vm_1_ssh = SshServiceDetails(addr="10.45.172.7", username="ute", password="ute")
_vm_2_ssh = SshServiceDetails(addr="10.44.236.145", username="ute", password="ute")
_lmp_1_ssh = SshServiceDetails(
    addr="192.168.255.129",
    username="toor4nsn",
    password="oZPS0POrRieRtu",
    proxy=_vm_1_ssh,
)
_lmp_2_ssh = SshServiceDetails(
    addr="192.168.255.129",
    username="toor4nsn",
    password="oZPS0POrRieRtu",
    proxy=_vm_2_ssh,
)
_lmp_http = HttpConnectionDetails(
    addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
)
_appserver_ssh = SshServiceDetails(
    addr="10.42.61.65", username="5g", password="2019H@slo"
)
_ue_pc_ssh = SshServiceDetails("10.44.234.173", "wro5grrm", password="5gpass!1")
_utf_http = HttpConnectionDetails(
    addr="10.45.176.183", username="utfuser", password="utfadmin!"
)
_utf = DcapBasic(connection_details=_utf_http)
_pdu_1 = Gude("10.45.177.21", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.45.177.18", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.45.172.130", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8041-1")
_pdu_4 = Gude("10.45.177.29", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_attenuator_1 = TopYoung(
    ip_addr="10.44.234.4",
    port=3001,
    attenuation_port_numbers=[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
    ],
)
_positioner = Positioner1DKrk(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.234.247", username="user-lab0", password="NokiaBts2003"
    )
)
_rmod_1 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.14",
        username="serviceuser",
        password="7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g=",
    ),
    attenuation_ports=[
        _attenuator_1.attenuator_ports[1],
        _attenuator_1.attenuator_ports[2],
        _attenuator_1.attenuator_ports[3],
        _attenuator_1.attenuator_ports[4],
    ],
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128",
        username="root",
        password="",
    ),
    attenuation_ports=[
        _attenuator_1.attenuator_ports[21],
        _attenuator_1.attenuator_ports[22],
        _attenuator_1.attenuator_ports[23],
        _attenuator_1.attenuator_ports[24],
    ],
#    pdu_port=_pdu_1.pdu_ports[3],
    pdu_port=_pdu_3.pdu_ports[9],
)
_rmod_3 = RU(
    ru_hw_group="5Ggen5_2T2R",
    radio_type="AWGUD",
    serial_number="AH221000464",
    product_code="475947A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2",
        username="serviceuser",
        password="tC0p5lpI9l/jX3RLphVLv+nxJ4P32DnqZlLyU9wkmeQ=",
    ),
    pdu_port=_pdu_1.pdu_ports[12],
    positioner=_positioner,
)
_rmod_4 = RU(
    ru_hw_group="5Ggen5_2T2R",
    radio_type="AWGUD",
    serial_number="AH220542209",
    product_code="475947A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.154",
        username="serviceuser",
        password="tC0p5lpI9l/jX3RLphVLv+nxJ4P32DnqZlLyU9wkmeQ=",
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_5 = RU(
    ru_hw_group="5Ggen5_2T2R",
    radio_type="AWEWB",
    serial_number="AH223904636",
    product_code="475171A.103",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.26",
        username="serviceuser",
        password="tC0p5lpI9l/jX3RLphVLv+nxJ4P32DnqZlLyU9wkmeQ=",
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_6 = RU(
    ru_hw_group="5Ggen5_2T2R",
    radio_type="AWEWB",
    serial_number="AH224200142",
    product_code="475171A.103",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.6",
        username="serviceuser",
        password="tC0p5lpI9l/jX3RLphVLv+nxJ4P32DnqZlLyU9wkmeQ=",
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)

# Master Node

_fsp_1 = CapacityUnit(
    addr="fsp1s0icom",
    hardware_type="ABIO",
    hardware_version="A.102",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="fsp2s0icom",
    hardware_type="ABIO",
    hardware_version="A.103",
    rus=[_rmod_6],
)
_fct_0 = CommonUnit(
    lmp_connection=_lmp_1_ssh,
    capacity_units=[_fsp_1, _fsp_2],
    hardware_type="ASIM",
    hardware_version="A.104",
    pdu_port=_pdu_1.pdu_ports[6],
)
_airscale_1 = Airscale(common_units=[_fct_0])
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.45.173.3",
        routing_v4=RoutingInformation(gateway="10.45.173.1/26"),
        v6="2a00:8a00:6000:607c::a:9d",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:81/122"),
        vlan_id=105,
    ),
    oam_ssh_connection_details=_lmp_1_ssh,
    oam_http_connection_details=_lmp_http,
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.45.173.67",
        routing_v4=RoutingInformation(gateway="10.45.173.65/26"),
        v6="2a00:8a00:6000:607c::a:dd",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:c1/122"),
        vlan_id=106,
    ),
    x2u=NetworkAddress(
        v4="10.45.173.131",
        routing_v4=RoutingInformation(gateway="10.45.173.129/26"),
        v6="2a00:8a00:6000:607c::a:11d",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:101/122"),
        vlan_id=107,
    ),
    s1u=NetworkAddress(
        v4="10.45.173.195",
        routing_v4=RoutingInformation(gateway="10.45.173.193/26"),
        v6="2a00:8a00:6000:607c::a:15d",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:141/122"),
        vlan_id=108,
    ),
    xnc=NetworkAddress(
        v4="10.45.173.67",
        routing_v4=RoutingInformation(gateway="10.45.173.65/26"),
        v6="2a00:8a00:6000:607c::a:dd",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:c1/122"),
        vlan_id=106,
    ),
    xnu=NetworkAddress(
        v4="10.45.173.131",
        routing_v4=RoutingInformation(gateway="10.45.173.129/26"),
        v6="2a00:8a00:6000:607c::a:11d",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:101/122"),
        vlan_id=107,
    ),
    ngc=NetworkAddress(
        v4="10.45.175.195",
        routing_v4=RoutingInformation(gateway="10.45.175.193/26"),
        v6="2a00:8a00:6000:607c::a:21d",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:201/122"),
        vlan_id=120,
    ),
    ngu=NetworkAddress(
        v4="10.45.173.195",
        routing_v4=RoutingInformation(gateway="10.45.173.193/26"),
        v6="2a00:8a00:6000:607c::a:15d",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:141/122"),
        vlan_id=108,
    ),
)
_du_1 = DU(_airscale_1, rus=[_rmod_1, _rmod_2, _rmod_6])
_cbts_1 = ClassicalBts(
    cu=_cu_1, dus=[_du_1], global_bts_id=50895, instance_id=50895, dcap=_utf
)
_vm_1_lmp_connection = Connection(
    interface="eth1",
    device=_cbts_1.dus[0].airscale.common_units[0],
    interface_type="lmp",
)
_vm_1 = TestPc(
    default_ssh_connection_details=_vm_1_ssh, connections=[_vm_1_lmp_connection]
)

# Secondary Node

_fsp_5 = CapacityUnit(
    addr="fsp1s0icom",
    hardware_type="ABIP",
    hardware_version="A.102",
    rus=[_rmod_5],
)
_fsp_6 = CapacityUnit(
    addr="fsp2s0icom",
    hardware_type="ABIO",
    hardware_version="A.102",
    rus=[_rmod_3, _rmod_4],
)
_fct_4 = CommonUnit(
    lmp_connection=_lmp_2_ssh,
    capacity_units=[_fsp_5, _fsp_6],
    hardware_type="ASIM",
    hardware_version="A.104",
    pdu_port=_pdu_4.pdu_ports[1],
)
_airscale_2 = Airscale(common_units=[_fct_4])
_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.47.12",
        routing_v4=RoutingInformation(gateway="10.42.47.1/26"),
        v6="2a00:8a00:6000:607c::a:384",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:381/122"),
        vlan_id=150,
    ),
    oam_ssh_connection_details=_lmp_2_ssh,
    oam_http_connection_details=_lmp_http,
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.42.47.76",
        routing_v4=RoutingInformation(gateway="10.42.47.65/26"),
        v6="2a00:8a00:6000:607c::a:3c4",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:3c1/122"),
        vlan_id=151,
    ),
    x2u=NetworkAddress(
        v4="10.42.47.140",
        routing_v4=RoutingInformation(gateway="10.42.47.129/26"),
        v6="2a00:8a00:6000:607c::a:404",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:401/122"),
        vlan_id=152,
    ),
    s1u=NetworkAddress(
        v4="10.42.47.204",
        routing_v4=RoutingInformation(gateway="10.42.47.193/26"),
        v6="2a00:8a00:6000:607c::a:444",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:441/122"),
        vlan_id=153,
    ),
    xnc=NetworkAddress(
        v4="10.42.47.76",
        routing_v4=RoutingInformation(gateway="10.42.47.65/26"),
        v6="2a00:8a00:6000:607c::a:3c4",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:3c1/122"),
        vlan_id=151,
    ),
    xnu=NetworkAddress(
        v4="10.42.47.140",
        routing_v4=RoutingInformation(gateway="10.42.47.129/26"),
        v6="2a00:8a00:6000:607c::a:404",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:401/122"),
        vlan_id=152,
    ),
    ngc=NetworkAddress(
        v4="10.44.198.204",
        routing_v4=RoutingInformation(gateway="10.44.198.193/26"),
        v6="2a00:8a00:6000:607c::a:4c4",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:4c1/122"),
        vlan_id=155,
    ),
    ngu=NetworkAddress(
        v4="10.42.47.204",
        routing_v4=RoutingInformation(gateway="10.42.47.193/26"),
        v6="2a00:8a00:6000:607c::a:444",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:441/122"),
        vlan_id=153,
    ),
)
_du_2 = DU(_airscale_2, rus=[_rmod_3, _rmod_4, _rmod_5])
_cbts_2 = ClassicalBts(
    cu=_cu_2, dus=[_du_2], global_bts_id=55107, instance_id=55107, dcap=_utf
)
_vm_2_lmp_connection = Connection(
    interface="eth1",
    device=_cbts_2.dus[0].airscale.common_units[0],
    interface_type="lmp",
)
_vm_2 = TestPc(
    default_ssh_connection_details=_vm_2_ssh, connections=[_vm_2_lmp_connection]
)

tl = TestLine(
    test_pc=_vm_1,
    test_pcs=[_vm_1, _vm_2],
    gnbs=[_cbts_1, _cbts_2],
    tl_cloud_topology="CLOUD_5G_NRDC_ASIML_ABIOB1_AEHC_AHLOA_ASIMR_ABIPB5_ABIOB6_2xAEWB_2xAWGUD",
    ues=[_ues],
    attenuators=[_attenuator_1],
    pdus=[_pdu_1, _pdu_2, _pdu_3, _pdu_4],
)

__all__ = ["tl"]

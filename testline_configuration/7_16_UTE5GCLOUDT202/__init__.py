__maintainer__ = "Pawel Sniady"
__team__ = "MN RAN RD VRF WRO2 5"
__email__ = "I_MN_RAN_RD_VRF_WRO2_5@nokia.com"
__owner_email__ = "pawel.sniady@nokia.com"

import os
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId
from taf.config.testline.dcap import DcapBasic
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RoutingInformation
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.radio import RU
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue.yaml"
)
_vm_1_1_ssh = SshServiceDetails(
    addr="10.45.172.94", username="ute", password="UTE.debian12"
)
_vm_1_2_ssh = SshServiceDetails(
    addr="10.45.172.112", username="ute", password="UTE.debian12"
)
_vm_2_ssh = SshServiceDetails(
    addr="10.44.236.155", username="ute", password="UTE.debian12"
)
_lmp_1_1_ssh = SshServiceDetails(
    addr="192.168.255.129",
    username="toor4nsn",
    password="oZPS0POrRieRtu",
    proxy=_vm_1_1_ssh,
)
_lmp_1_2_ssh = SshServiceDetails(
    addr="192.168.255.129",
    username="toor4nsn",
    password="oZPS0POrRieRtu",
    proxy=_vm_1_2_ssh,
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
_ue_pc_ssh = SshServiceDetails("10.44.234.144", "wro5grrm", password="5gpass!1")
_utf_http = HttpConnectionDetails(
    addr="10.45.176.183", username="utfuser", password="utfadmin!"
)

_utf = DcapBasic(connection_details=_utf_http)
_pdu_1 = Gude("10.45.172.140", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.45.177.14", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.45.177.15", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_4 = Gude("10.45.177.28", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_5 = Gude("10.45.177.29", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_6 = Gude("10.45.172.157", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_attenuator_1 = TopYoung(
    ip_addr="10.45.176.181",
    port=3001,
    attenuation_port_numbers=list(range(1, 25)),
    model="TAS_24T24_02G6_90_1C_EJS",
)
_attenuator_2 = TopYoung(
    ip_addr="10.45.176.182",
    port=3001,
    attenuation_port_numbers=list(range(1, 25)),
    model="TAS_24T24_02G6_90_1C_EJS",
)
_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245001134",
    product_code="475656A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.130",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
    ),
    attenuation_ports=[
        _attenuator_1.attenuator_ports[9],
        _attenuator_1.attenuator_ports[10],
        _attenuator_1.attenuator_ports[11],
        _attenuator_1.attenuator_ports[12],
    ],
    pdu_port=_pdu_3.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245001224",
    product_code="475656A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
    ),
    attenuation_ports=[
        _attenuator_2.attenuator_ports[21],
        _attenuator_2.attenuator_ports[22],
        _attenuator_2.attenuator_ports[23],
        _attenuator_2.attenuator_ports[24],
    ],
    pdu_port=_pdu_3.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9245001206",
    product_code="475656A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
    ),
    attenuation_ports=[
        _attenuator_2.attenuator_ports[5],
        _attenuator_2.attenuator_ports[6],
        _attenuator_2.attenuator_ports[7],
        _attenuator_2.attenuator_ports[8],
    ],
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="BL2243D50WE",
    product_code="475910A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
    ),
    attenuation_ports=[
        _attenuator_2.attenuator_ports[1],
        _attenuator_2.attenuator_ports[2],
        _attenuator_2.attenuator_ports[3],
        _attenuator_2.attenuator_ports[4],
    ],
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="BL2243D50WG",
    product_code="475910A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
    ),
    attenuation_ports=[
        _attenuator_1.attenuator_ports[5],
        _attenuator_1.attenuator_ports[6],
        _attenuator_1.attenuator_ports[7],
        _attenuator_1.attenuator_ports[8],
    ],
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="BL2243D50W9",
    product_code="475910A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
    ),
    attenuation_ports=[
        _attenuator_2.attenuator_ports[17],
        _attenuator_2.attenuator_ports[18],
        _attenuator_2.attenuator_ports[19],
        _attenuator_2.attenuator_ports[20],
    ],
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_7 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1243509220",
    product_code="476541A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    attenuation_ports=[
        _attenuator_2.attenuator_ports[9],
        _attenuator_2.attenuator_ports[10],
        _attenuator_2.attenuator_ports[11],
        _attenuator_2.attenuator_ports[12],
    ],
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_8 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251101941",
    product_code="476541A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.18",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    attenuation_ports=[
        _attenuator_2.attenuator_ports[13],
        _attenuator_2.attenuator_ports[14],
        _attenuator_2.attenuator_ports[15],
        _attenuator_2.attenuator_ports[16],
    ],
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_9 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251001337",
    product_code="476541A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.10",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    attenuation_ports=[
        _attenuator_1.attenuator_ports[1],
        _attenuator_1.attenuator_ports[2],
        _attenuator_1.attenuator_ports[3],
        _attenuator_1.attenuator_ports[4],
    ],
    pdu_port=_pdu_3.pdu_ports[6],
)
#
# _rmod_10, _rmod_11 are not connected via PDU
# pdu_port must be defined for RU
#
# _rmod_10 = RU(
#     ru_hw_group="mmWRF7.1_8T8R_1D0L",
#     radio_type="AWKUD",
#     serial_number="AH250201546",
#     product_code="476240A.102",
#     default_ssh_connection_details=SshServiceDetails(
#         addr="172.22.0.2",
#         username="serviceuser",
#         password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
#     ),
#     # pdu_port=_pdu_1.pdu_ports[3],
# )
# _rmod_11 = RU(
#     ru_hw_group="mmWRF7.1_8T8R_1D0L",
#     radio_type="AWKUD",
#     serial_number="AH250201543",
#     product_code="476240A.102",
#     default_ssh_connection_details=SshServiceDetails(
#         addr="172.22.0.158",
#         username="serviceuser",
#         password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
#     ),
#     # pdu_port=_pdu_1.pdu_ports[3],
# )
_rmod_12 = RU(
    ru_hw_group="mmWRF7.1_8T8R_1D0L",
    radio_type="AWKUD",
    serial_number="AH251701881",
    product_code="476240A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    pdu_port=_pdu_6.pdu_ports[3],
)
# Master Node

_fsp_1 = CapacityUnit(
    addr="fsp1s0icom",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1234003106",
    product_code="475792A.102",
    slot_id=SlotId.B1,
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="fsp4s0icom",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1234003098",
    product_code="475792A.102",
    slot_id=SlotId.B4,
    rus=[_rmod_7, _rmod_8, _rmod_9],
)
_fsp_3 = CapacityUnit(
    addr="fsp5s0icom",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1234003092",
    product_code="475792A.102",
    slot_id=SlotId.B5,
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fct_0 = CommonUnit(
    lmp_connection=_lmp_1_1_ssh,
    capacity_units=[_fsp_1],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1240903552",
    mac_addr="28:74:f5:21:31:95",
    slot_id=SlotId.C1,
    pdu_port=_pdu_4.pdu_ports[8],
)
_fct_1 = CommonUnit(
    lmp_connection=_lmp_1_2_ssh,
    capacity_units=[_fsp_2, _fsp_3],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1240803048",
    mac_addr="28:74:f5:21:31:95",
    slot_id=SlotId.C2,
    pdu_port=_pdu_5.pdu_ports[8],
)
_airscale_1 = Airscale(common_units=[_fct_0, _fct_1])
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.45.173.40",
        routing_v4=RoutingInformation(gateway="10.45.173.1/26"),
        v6="2a00:8a00:6000:607c::a:92",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:81/122"),
        vlan_id=105,
    ),
    oam_ssh_connection_details=_lmp_1_1_ssh,
    oam_http_connection_details=_lmp_http,
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.45.173.104",
        routing_v4=RoutingInformation(gateway="10.45.173.65/26"),
        v6="2a00:8a00:6000:607c::a:d2",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:c1/122"),
        vlan_id=106,
    ),
    x2u=NetworkAddress(
        v4="10.45.173.168",
        routing_v4=RoutingInformation(gateway="10.45.173.129/26"),
        v6="2a00:8a00:6000:607c::a:112",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:101/122"),
        vlan_id=107,
    ),
    s1u=NetworkAddress(
        v4="10.45.173.228",
        routing_v4=RoutingInformation(gateway="10.45.173.193/26"),
        v6="2a00:8a00:6000:607c::a:152",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:141/122"),
        vlan_id=108,
    ),
    xnc=NetworkAddress(
        v4="10.45.173.104",
        routing_v4=RoutingInformation(gateway="10.45.173.65/26"),
        v6="2a00:8a00:6000:607c::a:d2",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:c1/122"),
        vlan_id=106,
    ),
    xnu=NetworkAddress(
        v4="10.45.173.168",
        routing_v4=RoutingInformation(gateway="10.45.173.129/26"),
        v6="2a00:8a00:6000:607c::a:112",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:101/122"),
        vlan_id=107,
    ),
    ngc=NetworkAddress(
        v4="10.45.175.227",
        routing_v4=RoutingInformation(gateway="10.45.175.193/26"),
        v6="2a00:8a00:6000:607c::a:212",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:201/122"),
        vlan_id=120,
    ),
    ngu=NetworkAddress(
        v4="10.45.173.228",
        routing_v4=RoutingInformation(gateway="10.45.173.193/26"),
        v6="2a00:8a00:6000:607c::a:152",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:141/122"),
        vlan_id=108,
    ),
)
_du_1 = DU(
    _airscale_1,
    rus=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
)

_cbts_1 = ClassicalBts(
    cu=_cu_1, dus=[_du_1], global_bts_id=50894, instance_id=50894, dcap=_utf
)
_vm_1_1_lmp_connection = Connection(
    interface="eth1",
    device=_cbts_1.dus[0].airscale.common_units[0],
    interface_type="lmp",
)
_vm_1_2_lmp_connection = Connection(
    interface="eth1",
    device=_cbts_1.dus[0].airscale.common_units[1],
    interface_type="lmp",
)
_vm_1_1 = TestPc(
    default_ssh_connection_details=_vm_1_1_ssh, connections=[_vm_1_1_lmp_connection]
)
_vm_1_2 = TestPc(
    default_ssh_connection_details=_vm_1_2_ssh, connections=[_vm_1_2_lmp_connection]
)

# Secondary Node

_fsp_4 = CapacityUnit(
    addr="fsp2s0icom",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1205002515",
    product_code="475266A.102",
    slot_id=SlotId.B1,
    #    rus=[_rmod_10, _rmod_11],
)
_fsp_5 = CapacityUnit(
    addr="fsp2s0icom",
    hardware_type="ABIO",
    hardware_version="A.104U",
    serial_number="DH222549027",
    product_code="475266A.104U",
    slot_id=SlotId.B2,
    rus=[_rmod_12],
)
_fct_3 = CommonUnit(
    lmp_connection=_lmp_2_ssh,
    capacity_units=[_fsp_4, _fsp_5],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1213615448",
    mac_addr="c0:41:21:e8:3e:7",
    slot_id=SlotId.C1,
    pdu_port=_pdu_4.pdu_ports[1],
)
_airscale_2 = Airscale(common_units=[_fct_3])
_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.47.14",
        routing_v4=RoutingInformation(gateway="10.42.47.1/26"),
        v6="2a00:8a00:6000:607c::a:387",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:381/122"),
        vlan_id=150,
    ),
    oam_ssh_connection_details=_lmp_2_ssh,
    oam_http_connection_details=_lmp_http,
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.42.47.78",
        routing_v4=RoutingInformation(gateway="10.42.47.65/26"),
        v6="2a00:8a00:6000:607c::a:3c7",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:3c1/122"),
        vlan_id=151,
    ),
    x2u=NetworkAddress(
        v4="10.42.47.142",
        routing_v4=RoutingInformation(gateway="10.42.47.129/26"),
        v6="2a00:8a00:6000:607c::a:407",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:401/122"),
        vlan_id=152,
    ),
    s1u=NetworkAddress(
        v4="10.42.47.206",
        routing_v4=RoutingInformation(gateway="10.42.47.193/26"),
        v6="2a00:8a00:6000:607c::a:447",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:441/122"),
        vlan_id=153,
    ),
    xnc=NetworkAddress(
        v4="10.42.47.78",
        routing_v4=RoutingInformation(gateway="10.42.47.65/26"),
        v6="2a00:8a00:6000:607c::a:3c7",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:3c1/122"),
        vlan_id=151,
    ),
    xnu=NetworkAddress(
        v4="10.42.47.142",
        routing_v4=RoutingInformation(gateway="10.42.47.129/26"),
        v6="2a00:8a00:6000:607c::a:407",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:401/122"),
        vlan_id=152,
    ),
    ngc=NetworkAddress(
        v4="10.44.198.206",
        routing_v4=RoutingInformation(gateway="10.44.198.193/26"),
        v6="2a00:8a00:6000:607c::a:4c7",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:4c1/122"),
        vlan_id=155,
    ),
    ngu=NetworkAddress(
        v4="10.42.47.206",
        routing_v4=RoutingInformation(gateway="10.42.47.193/26"),
        v6="2a00:8a00:6000:607c::a:447",
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::a:441/122"),
        vlan_id=153,
    ),
)
# _du_2 = DU(_airscale_2, rus=[_rmod_10, _rmod_11, _rmod_12])
_du_2 = DU(_airscale_2, rus=[_rmod_12])

_cbts_2 = ClassicalBts(
    cu=_cu_2, dus=[_du_2], global_bts_id=55170, instance_id=55170, dcap=_utf
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
    test_pc=_vm_1_1,
    test_pcs=[_vm_1_1, _vm_1_2, _vm_2],
    gnbs=[_cbts_1, _cbts_2],
    tl_cloud_topology="CLOUD_5G_NRDC_1ASIML_1ABIPB1_1ASIMR_1ABIPB5_1ABIPB6_2ASIML_2ABIPB1",
    ues=[_ues],
    attenuators=[_attenuator_1, _attenuator_2],
    pdus=[_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5, _pdu_6],
)

__all__ = ["tl"]

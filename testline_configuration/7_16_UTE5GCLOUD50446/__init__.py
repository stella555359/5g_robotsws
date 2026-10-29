__maintainer__ = "Sebastian Lupkowski"
__team__ = "MN 5G&SC Pz 5G I&V 1 WRO 8 SG"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "sebastian.lupkowski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=540, mnc=1)

_pdu_1 = Gude(addr="10.44.177.196", port_numbers=[1, 3, 4], model="EPC", version="8221-1")

_pdu_2 = Gude(addr="10.44.205.68", port_numbers=[7], model="EPC", version="8221-1")

_pdu_3 = Gude(addr="10.44.177.229", port_numbers=[3], model="EPC", version="8221-1")

_rmod_1 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQE.value,
    serial_number="L1221501165",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="serviceuser", password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M190413166",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQE.value,
    serial_number="1M220811231",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="serviceuser", password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214208572",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172902444",
    rus=[_rmod_2],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1214511931",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH200865531",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1214809737",
)

_smod_1 = Airscale([_fct_1])

_smod_2 = Airscale([_fct_2])

_du_1 = DU(_smod_1)

_du_2 = DU(_smod_2)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.66.184",
        vlan_id=464,
        routing_v4=RoutingInformation(gateway="10.44.66.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.66.184", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.66.184", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.66.246",
        vlan_id=465,
        routing_v4=RoutingInformation(gateway="10.44.66.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.67.33",
        vlan_id=466,
        routing_v4=RoutingInformation(gateway="10.44.67.1", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.67.96",
        vlan_id=467,
        routing_v4=RoutingInformation(gateway="10.44.67.65", ip_prefix_length=26),
    ),
)

_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.66.183",
        vlan_id=464,
        routing_v4=RoutingInformation(gateway="10.44.66.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.66.183", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.66.183", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.66.245",
        vlan_id=465,
        routing_v4=RoutingInformation(gateway="10.44.66.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.67.32",
        vlan_id=466,
        routing_v4=RoutingInformation(gateway="10.44.67.1", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.67.95",
        vlan_id=467,
        routing_v4=RoutingInformation(gateway="10.44.67.65", ip_prefix_length=26),
    ),
)

_cbts = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=50446, instance_id=50446)

_cbts_2 = ClassicalBts(cu=_cu_2, dus=[_du_2], global_bts_id=50445, instance_id=50445)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.67", username="ute"),
    connections=[_fct_1
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.156.64", username="ute"),
    connections=[_fct_2
    ],
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.42.224.38", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(
	app_server_name="APP_1",
	bind_interface_ip="10.45.168.53",
        address="10.45.168.53", user="5g", password="2019H@slo",)

_android0 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.224.38",
    serial_number="af29d3ea",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name='iperf',
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.44.43.51",
        interval=1,
     ),
)

_android1 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.224.38",
    serial_number="b44a72f9",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name='iperf',
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.44.43.51",
        interval=1,
     ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    ues=[_android0, _android1],
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts, _cbts_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIO_ABIA_AQQE_AHCA_UE",
    core=_core,
    pdus=[_pdu_1, _pdu_2, _pdu_3],
)

__all__ = ["tl"]


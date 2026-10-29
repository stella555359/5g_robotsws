__maintainer__ = "Sylwia Pawlak"
__team__ = "MN_RAN_RD_VRF_WRO1_4"
__email__ = "sylwia.pawlak@nokia.com"
__owner_email__ = "sylwia.pawlak@nokia.com"

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
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=540, mnc=1)

_pdu_sm = Gude(addr="10.44.177.44", port_numbers=[1, 4], model="EPC", version="8221-1")

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1932G1YIL",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu_sm.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104770",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_sm.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1192010994",
)

_smod_1 = Airscale([_fct_1])

_du_1 = DU(_smod_1)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.187",
        vlan_id=903,
        routing_v4=RoutingInformation(
            gateway="10.44.68.129", destIpAddr="255.255.255.192"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.68.253",
        vlan_id=904,
        routing_v4=RoutingInformation(
            gateway="10.44.68.193", destIpAddr="255.255.255.192"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.61",
        vlan_id=905,
        routing_v4=RoutingInformation(
            gateway="10.44.70.1", destIpAddr="255.255.255.192"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.123",
        vlan_id=906,
        routing_v4=RoutingInformation(
            gateway="10.44.70.65", destIpAddr="255.255.255.192"
        ),
    ),
)

_cbts = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=50441, instance_id=50441)

_attenuator = JFW(
    ip_addr="10.42.221.94", port=3001, attenuation_port_numbers=[1, 2, 3, 4]
)

_test_pc = TestPc(
    SshServiceDetails(addr="10.44.178.70", username="uteUTE!"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_cbts.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.42.22.176", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_android0 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.176",
    serial_number="R5CR5159S7Y",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name="iperf",
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.45.168.53",
        interval=1,
    ),
)

_android1 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="R5CR5159VKH",
    ue_pc_address="10.42.22.176",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name="iperf",
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.45.168.53",
        interval=1,
    ),
)

tl = TestLine(
    test_pc=_test_pc,
    ues=[_android0, _android1],
    test_pcs=[_test_pc],
    gnbs=[_cbts],
    attenuator=[_attenuator],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_2xANDROID_ASIBL_ABIOB1_AHLOA",
    core=_core,
    pdus=[_pdu_sm],
)

__all__ = ["tl"]

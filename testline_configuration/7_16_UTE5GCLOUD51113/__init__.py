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
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=540, mnc=1)

_pdu_sm = Gude(
    addr="10.44.177.67", port_numbers=[9, 10], model="EPC", version="8221-1"
)

_pdu_rm = Gude(
    addr="10.44.177.9", port_numbers=[9, 10], model="EPC", version="8221-1"
)

_rmod_1 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQO.value,
    serial_number="1M203917151",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu_rm.pdu_ports[9],
)

_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQO.value,
    serial_number="1M203309971",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu_rm.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1210901803",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508287",
    rus=[_rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_sm.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="A.Y13",
    serial_number="L1223318000",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_sm.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="A.Y13",
    serial_number="L1223408437",
)

_smod_1 = Airscale([_fct_1])

_smod_2 = Airscale([_fct_2])

_du_1 = DU(_smod_1)

_du_2 = DU(_smod_2)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.45.178.4",
        vlan_id=851,
        routing_v4=RoutingInformation(gateway="10.45.178.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.45.178.68",
        vlan_id=852,
        routing_v4=RoutingInformation(gateway="10.45.178.65", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.45.178.132",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.45.178.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.45.178.196",
        vlan_id=854,
        routing_v4=RoutingInformation(gateway="10.45.178.193", ip_prefix_length=26),
    ),
)

_cu2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.45.178.5",
        vlan_id=851,
        routing_v4=RoutingInformation(gateway="10.45.178.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.45.178.5", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.45.178.5", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.45.178.69",
        vlan_id=852,
        routing_v4=RoutingInformation(gateway="10.45.178.65", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.45.178.133",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.45.178.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.45.178.197",
        vlan_id=854,
        routing_v4=RoutingInformation(gateway="10.45.178.193", ip_prefix_length=26),
    ),
)

_cbts = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=51113, instance_id=51113)

_cbts2 = ClassicalBts(cu=_cu2, dus=[_du_2], global_bts_id=51114, instance_id=51114)

_attenuator = JFW(
    ip_addr="10.42.221.175", port=3001, attenuation_port_numbers=[1, 2, 3, 4]
)

_test_pc_target = TestPc(
    SshServiceDetails(addr="10.44.156.230", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_cbts.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_source = TestPc(
    SshServiceDetails(addr="10.44.156.231", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_cbts2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.228", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(app_server_name="APP_1",
                                address="10.42.61.65",
                                user="5g",
                                password="2019H@slo",
                                bind_interface_ip="10.44.43.51")

_android0 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.44.72.228",
    serial_number="83194d50",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name='iperf',
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.44.43.51",
        interval=1,
     ),
)

tl = TestLine(
    test_pc=_test_pc_source,
    ues=[_android0],
    test_pcs=[_test_pc_source, _test_pc_target],
    gnbs=[_cbts, _cbts2],
    attenuator=[_attenuator],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ANDROID_ASIML_ABIOB1_AZQO",
    core=_core,
    pdus=[_pdu_sm, _pdu_rm],
)

__all__ = ["tl"]

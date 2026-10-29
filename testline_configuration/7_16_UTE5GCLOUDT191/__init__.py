__maintainer__ = "Maciej Cupial"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_7@internal.nsn.com"
__owner_email__ = "maciej.cupial@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import JFW
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import (
    NetworkAddress,
    RoutingInformation,
    TafUeDataTransferProtocol,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)

_attenuator = JFW(
    ip_addr="10.42.221.100",
    port=3001,
    attenuation_port_numbers=range(1, 8),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

_pdu1 = Gude(addr="10.44.205.96", port_numbers=[1, 12], model="EPC", version="8221-1")

_pdu2 = Gude(addr="10.44.205.104", port_numbers=[1, 2], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu2.pdu_ports[1],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.143",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.68.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.68.207",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.15",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.79",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65", ip_prefix_length=26),
    ),
    tracing=None,
)

_cu.sync = NetworkAddress(
    v4="10.44.70.143",
    vlan_id=907,
    routing_v4=RoutingInformation(gateway="10.44.70.129", ip_prefix_length=26),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.2.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[12],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[1],
    ru_hw_group="",
    radio_type="AEQN",
)

_du = DU(_airscale, rus=[_ru_1, _ru_3])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=1, instance_id=50806)

_core = RealCore5G(mcc=555, mnc=10)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abil_loner], pdu_port=_pdu2.pdu_ports[2]
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.37", username="ute", password="ute"
    )
)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.79.7",
        vlan_id=910,
        routing_v4=RoutingInformation(gateway="10.44.79.1", ip_prefix_length=26),
    ),
    global_bts_id=40804,
    instance_id=40804,
)

_lte.m = NetworkAddress(
    v4="10.44.78.206",
    vlan_id=909,
    routing_v4=RoutingInformation(gateway="10.44.78.193", ip_prefix_length=26),
)

_app_server = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server, interval=1, version=3
)

_android = TafUeAndroid(
    serial_number="HZQN1876AAKA2801522",
    ue_pc_address="10.42.22.219",
    ue_pc_port="80",
    data_transfer=[_data_transfer_iperf],
    service_call_detach=16,
    service_call_attach=14,
    network_mode_switch_method="ADB",
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.36", username="ute", password="ute"
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    # test_pcs=_lte_test_pc,
    gnbs=[_cbts],
    enbs=[_lte],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQN_ENB",
    ues=[_qualcomm_ue],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]

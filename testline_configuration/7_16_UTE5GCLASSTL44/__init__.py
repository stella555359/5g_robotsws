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
from taf.config.testline import RealEnb

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=555, mnc=10)

_pdu_1 = Gude(addr="10.44.206.99", port_numbers=[3, 4, 5, 7], model="EPC", version="8220-1")

_pdu_2 = Gude(addr="10.44.206.100", port_numbers=[7, 8], model="EPC", version="8220-1")

#TL44 5G 50431
_rmod_1 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQO.value,
    serial_number="1M203509821",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

#TL11 5G 51108
_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQO.value,
    serial_number="1M203917004",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

#TL12 4G 41109
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7180222738",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

#TL44 5G
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222310861",
    rus=[_rmod_1],
)

#TL11 5G
_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.101",
    serial_number="L1182710213",
    rus=[_rmod_2],
)

#TL12 4G
_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1180418004",
    rus=[_rmod_3],
)

#TL44 5G
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.Y13",
    serial_number="L1223202202",
)

#TL11 5G
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="EA194051774",
)

#TL12 4G
_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1172606187",
)

_smod_1 = Airscale([_fct_1])

_smod_2 = Airscale([_fct_2])

_smod_3 = Airscale([_fct_3])

_du_1 = DU(_smod_1)

_du_2 = DU(_smod_2)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.90.131",
        vlan_id=488,
        routing_v4=RoutingInformation(gateway="10.44.90.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.90.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.90.131", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.90.195",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.91.3",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.91.94",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
)

_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.90.155",
        vlan_id=488,
        routing_v4=RoutingInformation(gateway="10.44.90.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.90.155", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.90.155", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.90.222",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.91.31",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.91.95",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
)

_cbts = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=50431, instance_id=50431)

_cbts_2 = ClassicalBts(cu=_cu_2, dus=[_du_2], global_bts_id=51108, instance_id=51108)

_enb_1 = RealEnb(
    system_module=_smod_3,
    rms=[_rmod_3],
    instance_id=41109,
    global_bts_id=41109,
    oam_ip=NetworkAddress(v4="10.44.92.30"),
    x2_link_addr=NetworkAddress(
        v4="10.44.92.93",
        vlan_id=495,
        routing_v4=RoutingInformation(
            gateway="10.44.92.1", destIpAddr="255.255.255.192"
        ),
    ),
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.227", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_cbts.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.178.39", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_cbts_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_enb = TestPc(
    SshServiceDetails(addr="10.44.178.42", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.42.22.227", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(app_server_name="APP_1",
                                address="10.42.61.65",
                                user="5g",
                                password="2019H@slo",
                                bind_interface_ip="10.44.43.51")

_android0 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.227",
    serial_number="8d65a719",
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
    ues=[_android0],
    test_pcs=[_test_pc_1, _test_pc_enb, _test_pc_2],
    gnbs=[_cbts, _cbts_2],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIMR_ABIOB1_AZQO_FXED",
    core=_core,
    pdus=[_pdu_1, _pdu_2],
)

__all__ = ["tl"]

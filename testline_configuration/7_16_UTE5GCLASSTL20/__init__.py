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
from taf.config.testline.attenuator import JFW

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=540, mnc=1)

_pdu_1 = Gude(addr="10.44.206.99", port_numbers=[1, 2, 9, 11], model="EPC", version="8220-1")

#TL20 5G 50438
_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1933G10P5",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

#TL21 5G 50439
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1933G10Q4",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

#TL20 5G
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204907586",
    rus=[_rmod_1],
)

#TL21 5G
_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.101",
    serial_number="L1182809762",
    rus=[_rmod_2],
)

#TL20 5G
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1202502808",
)

#TL21 5G
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIK",
    hardware_version="A.101",
    serial_number="L1182603140",
)

_smod_1 = Airscale([_fct_1])

_smod_2 = Airscale([_fct_2])

_du_1 = DU(_smod_1)

_du_2 = DU(_smod_2)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.90.164",
        vlan_id=488,
        routing_v4=RoutingInformation(gateway="10.44.90.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.90.164", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.90.164", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.90.210",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.90.210",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.90.210",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
)

_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.90.165",
        vlan_id=488,
        routing_v4=RoutingInformation(gateway="10.44.90.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.90.165", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.90.165", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.90.211",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.90.211",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.90.211",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
)

_cbts = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=50438, instance_id=50438)

_cbts_2 = ClassicalBts(cu=_cu_2, dus=[_du_2], global_bts_id=50439, instance_id=50439)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.178.72", username="ute"),
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
    SshServiceDetails(addr="10.44.178.74", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_cbts_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.132", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(app_server_name="APP_1",
                                address="10.42.61.65",
                                user="5g",
                                password="2019H@slo",
                                bind_interface_ip="10.44.43.51")

_android0 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.44.72.132",
    serial_number="59eb80de",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name='iperf',
        app_server=_appserver_ssh,
        binary_path="/usr/bin/iperf3",
        bind_ue_ip="10.44.43.51",
        interval=1,
     ),
)

_attenuator = JFW(
    ip_addr="10.42.221.166", port=3001, attenuation_port_numbers=range(1, 8)
)

tl = TestLine(
    test_pc=_test_pc_1,
    ues=[_android0],
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts, _cbts_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASILL_ABINB1_AHLOA",
    core=_core,
    pdus=[_pdu_1],
    attenuator=[_attenuator],
)

__all__ = ["tl"]

__maintainer__ = "Karolina Wojtaczka"
__team__ = "MN RAN RD VRF WRO1 4"
__owner__ = "Karolina Wojtaczka"
__email__ = "karolina.wojtaczka@nokia.com"

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
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import RealEnb

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=555, mnc=10)

_pdu_1 = Gude(addr="10.44.206.99", port_numbers=[2, 6], model="EPC", version="8220-1")


#TL12 5G 51109
_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQO.value,
    serial_number="1M203917124",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

#TL12 5G
_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104687",
    rus=[_rmod_2],
)

#TL12 5G
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1212512852",
)

_smod_2 = Airscale([_fct_2])

_du_2 = DU(_smod_2)



_cu2 = CU(
    backhaul_site_oam_ip="10.44.90.156",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(
        v4="10.44.90.223",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.90.223",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.90.223",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.90.193", ip_prefix_length=26),
    ),
)

_cbts2 = ClassicalBts(cu=_cu2, dus=[_du_2], global_bts_id=1, instance_id=51109) #TL12 5G


#VM TL12 5G
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.178.41", username="ute"),
   connections=[_fct_2
    ],
)

#TEST PC
_ue_pc_ssh = SshServiceDetails(
    addr="10.42.22.227", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(app_server_name="APP_1",
                                address="10.45.168.53",
                                user="5g",
                                password="2019H@slo",
                                bind_interface_ip="10.45.168.53")

#UE
_android0 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.227",
    serial_number="8d65a719",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name='iperf',
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.45.168.53",
        interval=1,
     ),
)

tl = TestLine(
    test_pc=_test_pc_2,
    test_pcs=[_test_pc_2],
    ues=[_android0],
    gnbs=[_cbts2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AZQO",
    core=_core,
    pdus=[_pdu_1],
)

__all__ = ["tl"]

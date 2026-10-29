__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId
from taf.config.testline.pdu import ENICS, PduPort
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol

###############################################
# UTE Oulu 5G Classical BTS SA configuration  #
###############################################

# General
cfg_dir = os.path.dirname(os.path.abspath(__file__))

# Power breakers
_pdu_du = ENICS(addr="172.31.1.85", port_numbers=[12])
_pdu_ru_gnb = ENICS(addr="172.31.1.104", port_numbers=[2])
_pdu_ue_dummy = ENICS(addr="0.0.0.0", port_numbers=[1, 2])

# 5G Radio units
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="NR_RADIO",
    radio_type="AVQL",
    pdu_port=_pdu_ru_gnb.pdu_ports[2],
    serial_number="L1232910459",
    product_code="475976A.101",
)
_radio_units_gnb = [_ru_1]

# 5G Cloud unit
_cloud_unit_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.35.217.83/26",
        routing_v4=RoutingInformation(gateway="10.35.217.65"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
)

# 5G Distributed unit
_du0_master_capacity_unit_L_0 = CapacityUnit(
    addr="fsp-1a",
    hardware_type="ABIO",
    product_code="475266A.103",
    serial_number="L1213006720",
    rus=[_ru_1],
    slot_id=SlotId.B2,
)

_common_unit_0_L = CommonUnit(
    hardware_type="ASIB",
    serial_number="DH223243221",
    slot_id=SlotId.C1,
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _du0_master_capacity_unit_L_0,
    ],
    pdu_port=_pdu_du.pdu_ports[12],
)

_airscale = Airscale(common_units=[_common_unit_0_L], product_code="473764A.102")

_ru0_cablink = [
    Cablink(
        source=Endpoint(unit=_du0_master_capacity_unit_L_0, label="SFP", port_id="1"),
        target=Endpoint(unit=_ru_1, label="SFP", port_id="1"),
    ),
]

_distributed_unit_gnb = DU(
    airscale=_airscale, rus=_radio_units_gnb, cablinks=_ru0_cablink
)

# 5G Classical BTS
_classical_bts_gnb = ClassicalBts(
    cu=_cloud_unit_gnb,
    dus=[_distributed_unit_gnb],
    instance_id=38217,
    global_bts_id=38217,
)

# gnb virtual machine
_lmp_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.3", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_common_unit_0_L, interface_type="lmp")
    ],
)

# Velocity
_velocity = Velocity(
    addr=NetworkAddress(
        v4="velocityoulu.ou.nsn-rdnet.net",
        v6="None",
        routing_v4=None,
        routing_v6=None,
    ),
    topology_name="OTAChamber3.4 OTA4.1 UTE",
)

# Data transfer
_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.35.102.96",
    user="srn",
    password="!!IperfUser@25",
    bind_interface_ip="10.35.102.96",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=2
)

# Android UE
# _android1 = TafUeAndroid(
#    capabilities=["REAL_UE1"],
#    serial_number="0123456789ABCDEF",
#    ue_pc_address="10.33.10.21",
    #ue_pc_port="80",
    #proxy_mngr_port=9955,
#    data_transfer=[
#        _data_transfer_iperf,
#    ],
#    ssh_connection_details=SshServiceDetails(
#        addr="10.33.10.21", username="fiousrusr", password="!SRkuivasranta2"
#    ),
#    imei="351901031112489",
#    imsi="244091100099888",
#    pdu_port=_pdu_ue_dummy.pdu_ports[1],
#)

_android_5G = TafUeAndroid(
    capabilities=['_5G'],
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.35.48.107",
    #ue_pc_port="8080",
    proxy_mngr_port='80',
    data_transfer=[
        _data_transfer_iperf,
    ],
    ssh_connection_details=SshServiceDetails(
        addr="10.35.48.107", username="fiousrusr", password="!SRkuivasranta2"
    ),
    imei="004400542316789",
    imsi="244091100099868",
    pdu_port=_pdu_ue_dummy.pdu_ports[1],
)
_android_5G.ue_type = "android"

# Testline
tl = TestLine(
    test_pc=_lmp_vm,
    test_pcs=[_lmp_vm],
    gnbs=[_classical_bts_gnb],
    tl_cloud_topology="CLOUD_OTA_41",
    velocity=_velocity,
    ues=[_android_5G],
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180", #seconds
    "MIN_DL": "240", #Mbits/sec
    "MAX_DL": "300", #Mbits/sec
    "MAX_UL": "30", #Mbits/sec
    "MIN_UL": "24", #Mbits/sec
    "cell_id_rf1": "611477",
}

__all__ = ["tl"]
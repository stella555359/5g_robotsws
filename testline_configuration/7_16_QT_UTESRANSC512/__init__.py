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
from taf.config.testline.pdu import ENICS, ORBIS
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
_pdu_du = ENICS(addr="10.35.50.72", port_numbers=[2])
_pdu_ru_gnb = ORBIS(addr="192.168.1.20:5000", port_numbers=[3])


# 5G Radio units
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    ru_hw_group="NR_RADIO",
    radio_type="AKQJ",
    pdu_port=_pdu_ru_gnb.pdu_ports[3],
    serial_number="1M220107682",
    product_code="475824A.101",
)
_radio_units_gnb = [_ru_1]

# 5G Cloud unit
_cloud_unit_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.33.96.8/26",
        routing_v4=RoutingInformation(gateway="10.33.96.1"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(
        v4="10.33.96.8/26",
        routing_v4=RoutingInformation(gateway="10.33.96.1"),
    ),
    x2u=NetworkAddress(
        v4="10.33.96.8/26",
        routing_v4=RoutingInformation(gateway="10.33.96.1"),
    ),
    s1u=NetworkAddress(
        v4="10.33.96.8/26",
        routing_v4=RoutingInformation(gateway="10.33.96.1"),
    ),
)

# 5G Distributed unit
_abil_master = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    rus=_radio_units_gnb,
    product_code="475266A.103",
    serial_number="L1211201001",
    slot_id=SlotId.B1,
)

_capacity_units_gnb = [_abil_master]

_common_unit_gnb = CommonUnit(
    hardware_type="ASIM",
    serial_number="L1243110729",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=_capacity_units_gnb,
    pdu_port=_pdu_du.pdu_ports[2],
    slot_id=SlotId.C1,
)

_airscale_gnb = Airscale(common_units=[_common_unit_gnb], product_code="474021A.102")

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil_master, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_1, label="SFP", port_id=1),
    ),
]

_distributed_unit_gnb = DU(
    airscale=_airscale_gnb, rus=_radio_units_gnb, cablinks=_ru_cablinks
)

# 5G Classical BTS
_classical_bts_gnb = ClassicalBts(
    cu=_cloud_unit_gnb,
    dus=[_distributed_unit_gnb],
    instance_id=1900,
    global_bts_id=1900,
)

# gnb virtual machine
_lmp_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.157", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_common_unit_gnb, interface_type="lmp")
    ],
)

# Core network
_amf_oam_ssh_connection_details = SshServiceDetails(
    addr=None, username=None, password=None
)
_n2_address = NetworkAddress(v4="10.35.108.72", v6="2a00:8a00:4000:4a22::8086")
_amf = AMF(oam_ssh_connection_details=_amf_oam_ssh_connection_details, n2=_n2_address)
_real_5g_core_details = RealCore5GDetails(amf=_amf, tac=8000)
_core = RealCore(mcc=244, mnc=9, five_g=_real_5g_core_details)

_velocity = Velocity(
    addr=NetworkAddress(
        v4="velocityoulu.ou.nsn-rdnet.net",
        v6="None",
        routing_v4=None,
        routing_v6=None,
    ),
    topology_name="OTAChamber5.12 VEM PC UTE",
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

_android_5G = TafUeAndroid(
    capabilities=['_5G'],
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.33.92.198",
    #ue_pc_port="8080",
    proxy_mngr_port='80',
    data_transfer=[
        _data_transfer_iperf,
    ],
    ssh_connection_details=SshServiceDetails(
        addr="10.33.92.198", username="FIOUSRUSR", password="!SRkuivasranta2"
    ),
    imei="351901031111077",
    imsi="001011101136840",
)
_android_5G.ue_type = "android"

# Testline
tl = TestLine(
    test_pc=_lmp_vm,
    test_pcs=[_lmp_vm],
    gnbs=[_classical_bts_gnb],
    core=_core,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIM_ABIO_AKQJ_OTA",
    velocity=_velocity,
    ues=[_android_5G],
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180", #seconds
    "MIN_DL": "240", #Mbits/sec
    "MAX_DL": "300", #Mbits/sec
    "MAX_UL": "30", #Mbits/sec
    "MIN_UL": "24", #Mbits/sec
    "cell_id_rf1": "31129600",
}

__all__ = ["tl"]

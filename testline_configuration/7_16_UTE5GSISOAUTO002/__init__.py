__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__owner__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__maintainer__ = "Adrian Karas"
__email__ = "adrian.karas@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb, Leoni
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ald import KA_RCU
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer

__all__ = ["tl"]

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_iperf = TafUeDataTransferProtocol(
    app_server=_appserver_ssh, protocol_name="iperf", version=3
)

_android = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.68", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="cba06003",
    ue_pc_address="10.42.22.68",
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    airplane_mode_switcher_text="Tryb samolotowy",
    data_transfer=[_iperf],
    # is_rooted=True,
    # qualcomm_prototype=False,
    # service_call_attach=16,
    # service_call_detach=16,
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.251.11",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::fa06", vlan_id=38),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::fa06", vlan_id=38),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::fa06", vlan_id=38),
)

_pdu_gnb = Gude(addr="10.44.177.144", port_numbers=[9], model="EPC", version="8221-1")

_pdu_gnb_ru1 = Gude(
    addr="10.44.177.81", port_numbers=[12], model="EPC", version="8221-1"
)

_pdu_enb = Gude(addr="10.44.177.144", port_numbers=[7], model="EPC", version="8221-1")

_pdu_enb_ru1 = Gude(
    addr="10.44.177.144", port_numbers=[1], model="EPC", version="8221-1"
)

_optical_switch = Leoni(addr="10.42.61.240", model="mol 6x(2x6)", port=3001)

rcu = KA_RCU(
    serial_number="CSG0315156",
    aisg_protocol="2.0",
    antenna_id=1,
)

_gnb_ru1 = RU(
    ru_hw_group="5Ggen4_HighF_2T2R",
    radio_type="AQQE",
    serial_number="L1214308075",
    product_code="475544A.101",
    lmp_connection=SshServiceDetails(
        addr="10.255.33.175",
        port=3000,
        username=""
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[12],
    alds=[rcu],
)

_abio1_gnb_1_loner = CapacityUnit(
    addr="172.22.48.2", hardware_type="ABIO", serial_number="L1210903882",
    rus=[_gnb_ru1]
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[9],
    hardware_type="ASIB",
    serial_number="L1190601911",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.128", username="ute", password="ute"
    ),
    connections=[_asib_gnb_1],
)

_airscale_gnb_1 = Airscale([_asib_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1])

_abia_enb_1 = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIA", serial_number="L1173610659"
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    hardware_type="ASIA",
    pdu_port=_pdu_enb.pdu_ports[7],
    serial_number="L1173213286",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50191
)

_core = RealCore5G()

_rmod_1 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHC",
    serial_number="F7181503442",
    pdu_port=_pdu_enb_ru1.pdu_ports[1],
)

_enb_1 = RealEnb(
    rms=[_rmod_1],
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    global_bts_id=40191,
    instance_id=40191,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:607c::fa07", vlan_id=38
    ),
    oam_ip=NetworkAddress(v4="10.44.251.203"),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.236", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_android],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AQQE_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru1, _pdu_enb, _pdu_enb_ru1],
    optical_switches=[_optical_switch],
)

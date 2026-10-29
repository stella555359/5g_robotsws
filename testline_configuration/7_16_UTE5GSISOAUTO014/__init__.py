__maintainer__ = "Karolina Wojtaczka"
__team__ = "MN RAN RD VRF WRO1 4"
__owner__ = "Karolina Wojtaczka"
__email__ = "karolina.wojtaczka@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

__all__ = ["tl"]

_attenuator = TopYoung(
    ip_addr="10.42.75.96", port=3001, attenuation_port_numbers=range(1, 24)
)

_attenuator.serial_number = "30022041944"

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.209",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:291f", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:291f", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:291f", vlan_id=401),
)

_pdu_gnb = Gude(addr="10.44.205.26", port_numbers=[11], model="EPC", version="8221-1")

_pdu_gnb_ru1 = Gude(
    addr="10.44.205.57", port_numbers=[7,8,9], model="EPC", version="8221-1"
)

_pdu_enb = Gude(addr="10.44.205.26", port_numbers=[12], model="EPC", version="8221-1")

_pdu_enb_ru = Gude(addr="10.44.205.28", port_numbers=[4], model="EPC", version="8221-1")

_gnb_ru1 = RU(
    ru_hw_group="5Ggen4_LowF_8T8R",
    radio_type="AZHL",
    serial_number="YK203400022",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.154",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[7],
)

_gnb_ru2 = RU(
    ru_hw_group="5Ggen4_LowF_8T8R",
    radio_type="AZHL",
    serial_number="AH211400592",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.158",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[8],
)

_gnb_ru3 = RU(
    ru_hw_group="5Ggen4_LowF_8T8R",
    radio_type="AZHL",
    serial_number="AH211400599",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.162",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[9],
)

_abio1_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22", 
    hardware_type="ABIO", 
    serial_number="DH222244314", 
    product_code="475266A.104",
)

_abio2_gnb_2_loner = CapacityUnit(
    addr="192.168.253.22", 
    hardware_type="ABIO", 
    serial_number="L1204104952", 
    product_code="475266A.101",
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_gnb_1_loner, _abio2_gnb_2_loner],
    pdu_port=_pdu_gnb.pdu_ports[11],
    hardware_type="ASIB",
    serial_number="DH204760170",
    product_code="473764A.102",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.157", username="ute", password="ute"
    ),
    connections=[_asib_gnb_1],
)

_airscale_gnb_1 = Airscale(
    common_units=[_asib_gnb_1],
    product_code="473098A",
)

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3])

_abia_enb_1 = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIA", serial_number="L1171613240"
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    hardware_type="ASIA",
    pdu_port=_pdu_enb.pdu_ports[12],
    serial_number="DH192354876",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50179
)

_core = RealCore5G()

_ru_lte = RU(
    ru_hw_group="5Ggen4_LowF_6T6R",
    radio_type="FRGU",
    serial_number="AS193612030",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_enb_ru.pdu_ports[4],
)

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    rms=[_ru_lte],
    global_bts_id=40564,
    instance_id=40564,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:607c:0000:0000:0000:29ff", vlan_id=401
    ),
    oam_ip=NetworkAddress(v4="10.44.67.239"),
)

_enb_1.u_plane = NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:29ff")

_enb_1.c_plane = NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:29ff")

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.248", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    bind_interface_ip="10.45.168.53",
    address="10.45.168.53", user="5g", password="2019H@slo")

_qualcomm_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_xiaomi = TafUeAndroid(
    ue_pc_address="10.42.22.24",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.24", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    serial_number="730ffe9e",
    data_transfer=[_qualcomm_iperf],
    is_rooted="yes",
    airplane_mode_switcher_text="Aeroplane mode",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_xiaomi],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBR_ABIO_3xAZHL_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru1, _pdu_enb_ru, _pdu_enb],
    attenuators=[_attenuator],
)
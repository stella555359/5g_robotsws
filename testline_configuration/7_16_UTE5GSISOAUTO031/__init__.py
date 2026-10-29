__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__owner__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__maintainer__ = "Nicol Swierczynska"
__email__ = "nicol.swierczynska@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
    IperfDataTransferIperfOptions,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
import os


__all__ = ["tl"]

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_iperf_options = IperfDataTransferIperfOptions(packet=1200, max_segment_size=1400)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
    version=3,
    bind_ue_ip="10.45.168.53",
)

_android = TafUeAndroid(
    serial_number="M9AIKN01N652H23",
    ue_pc_address="10.42.224.114",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.114", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    data_transfer=[_iperf],
    airplane_mode_switcher_text="Airplane mode",
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.207",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::2941", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::2941", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::2941", vlan_id=401),
)

_pdu_gnb = Gude(addr="10.44.205.37", port_numbers=[2], model="EPC", version="8221-1")
_pdu_gnb_ru1 = Gude(
    addr="10.44.205.80", port_numbers=[2], model="EPC", version="8221-1"
)
_pdu_gnb_ru2 = Gude(
    addr="10.44.205.57", port_numbers=[11], model="EPC", version="8221-1"
)
_pdu_enb = Gude(addr="10.44.205.37", port_numbers=[4], model="EPC", version="8221-1")
_pdu_enb_ru1 = Gude(
    addr="10.44.205.80", port_numbers=[3], model="EPC", version="8221-1"
)

_gnb_ru1 = RU(
    ru_hw_group="RRH6.2",
    radio_type="AHFII",
    serial_number="BL2222N407X",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[2],
)

_gnb_ru2 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type="AHEGHA",
    serial_number="BL2333H60IG",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[11],
)

_asoe_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[2],
    serial_number="DH241919611",
    hardware_type="ASOE",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.163", username="ute", password="ute"
    ),
    connections=[_asoe_gnb_1],
)

_airscale_gnb_1 = Airscale([_asoe_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2])

_abia_enb_1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    hardware_type="ASIA",
    pdu_port=_pdu_enb.pdu_ports[4],
    serial_number="L1172900629",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50594, instance_id=50594
)

_core = RealCore5G()

_rmod_1 = RU(
    ru_hw_group="5Ggen4_HighF_2T2R",
    radio_type="FRBG",
    serial_number="K9172901377",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.161", port=2323
    ),
    pdu_port=_pdu_enb_ru1.pdu_ports[3],
)

_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    airscale=_airscale_enb_1,
    global_bts_id=40594,
    instance_id=40594,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::2941", vlan_id=401),
    oam_ip=NetworkAddress(v4="10.44.67.237"),
    rms=[_rmod_1],
)

_enb_1.u_plane = NetworkAddress(v6="2a00:8a00:6000:607c::2942")

_enb_1.c_plane = NetworkAddress(v6="2a00:8a00:6000:607c::2942")

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.164", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_android],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_AHFII_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru1, _pdu_enb, _pdu_enb_ru1, _pdu_gnb_ru2],
)

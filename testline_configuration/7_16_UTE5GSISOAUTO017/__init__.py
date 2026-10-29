__maintainer__ = "Jakub Rychlik"
__team__ = "MN RAN Pz 1 WRO 4 SG"
__email__ = "jakub.rychlik@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline import NetworkAddress
from taf.config.testline.connection_details import IperfDataTransferDetails
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdu import Gude, ATEN

__all__ = ["tl"]
_pdu_gnb = Gude(addr="10.44.205.41", port_numbers=[3], model="EPC", version="8221-1")
_pdu_gnb_ru_1 = Gude(addr="10.44.205.80", port_numbers=[8], model="EPC", version="8221-1")
_pdu_gnb_ru_2 = Gude(addr="10.44.205.43", port_numbers=[10, 11], version="8221-1", model="EPC")
_pdu_enb = Gude(addr="10.44.205.41", port_numbers=[10], model="EPC", version="8221-1")
_pdu_enb_ru = Gude(addr="10.44.205.41", port_numbers=[7], model="EPC", version="8221-1")

_gnb_ru_1 = RU(
    ru_hw_group="5Ggen4_LowF_4T4R",
    radio_type="AZTA",
    serial_number="1M214914361",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.100.1", username="root", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.100", port=3000, username=""),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[8],
)

_gnb_ru_2 = RU(
    ru_hw_group="5Ggen3_LowF_2T2R",
    radio_type="AZQU",
    serial_number="4H210530085",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.101", port=3000, username=""),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[11],
)

_gnb_ru_3 = RU(
    ru_hw_group="5Ggen3_LowF_2T2R",
    radio_type="AZQU",
    serial_number="4H210730013",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.102", port=3000, username=""),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[10],
)

_abil1_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204008494",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3],
)

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A102",
    serial_number="L1193207296",
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.242",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::1:a2ce", vlan_id=370),
    x2u=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::1:a2ce", vlan_id=370),
    s1u=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::1:a2ce", vlan_id=370),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], instance_id=50184, global_bts_id=1
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.128", username="ute", password="nierobieCITbokawa1!"
    ),
    connections=[_asik_gnb_1],
)

_enb_ru = RU(
   ru_hw_group="FRMr5.1_1_6T6R",
   radio_type="AREA",
   serial_number="EA201653420",
   pdu_port=_pdu_enb_ru.pdu_ports[7],
)

_abia_enb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A103",
    serial_number="L1181620148",
    rus=[_enb_ru]
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    hardware_type="ASIA",
    pdu_port=_pdu_enb.pdu_ports[10],
    serial_number="AH184013244",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:607c:0000:0000:0000:2926", vlan_id=401
    ),
    rms=[_enb_ru],
    global_bts_id=40121,
    instance_id=40184,
    oam_ip=NetworkAddress(v4="10.44.67.212"),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.129", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_core = RealCore5G()

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53", user="5g", password="2019H@slo",
    bind_interface_ip="10.45.168.53"
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_xiaomi = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.54.208", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="217872bb",
    ue_pc_address="10.42.22.210",
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
    ue_pc_port="80",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_xiaomi],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIOB1_AZTA_AZQU",
    pdus=[_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2, _pdu_enb_ru, _pdu_enb],
    core=_core,
)

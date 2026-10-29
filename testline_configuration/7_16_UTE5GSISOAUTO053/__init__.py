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
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid

__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.205.90", port_numbers=[11], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.205.90", port_numbers=[2,3,10], model="EPC", version="8221-1")

_ru_1 = RU(
    ru_hw_group="",
    radio_type="AWHQN",
    serial_number="AH242903774",
    product_code="475701A.103",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type="AKQJ",
    serial_number="1M222600296",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.6",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)

_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHEJ",
    serial_number="EB192761181",
    product_code="474514A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128",
        username="",
        password="",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[10],
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[11],
    hardware_type="ASOH",
    hardware_version="A103",
    serial_number="L1242306626",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.88.177",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:b71f", vlan_id=481),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b71f", vlan_id=481),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b71f", vlan_id=481),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50439
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.28", username="ute", password="ute"
    ),
    connections=[_asil_gnb_1],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    bind_interface_ip="10.45.168.53",
    address="10.45.168.53", user="5g", password="2019H@slo")

_nokia_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh)

#OnePlus12
_asus = TafUeAndroid(
    serial_number="d70d68ed",
    ue_pc_address="10.42.224.241",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.241", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_nokia_iperf],
    network_mode_switch_method="adb",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    ues=[_asus],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOH_AWHQN_AKQJ_AHEJ_SA",
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)

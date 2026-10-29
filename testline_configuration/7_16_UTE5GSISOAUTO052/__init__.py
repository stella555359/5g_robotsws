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

_pdu_gnb = Gude(addr="10.44.205.90", port_numbers=[12], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.205.90", port_numbers=[1,4,9], model="EPC", version="8221-1")

_ru_1 = RU(
    ru_hw_group="",
    radio_type="AWHQN",
    serial_number="AH242903773",
    product_code="475701A.103",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type="AKQJ",
    serial_number="1M222600285",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="fd5f:4268:2387:87c1:0000:0000:0000:0806",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)

_ru_3 = RU(
    ru_hw_group="",
    radio_type="AHGB",
    serial_number="EB211660385",
    product_code="474514A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128",
        username="",
        password="",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_abip_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22", hardware_type="ABIP", serial_number="L1241505020"
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[12],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1212705928",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.90.23",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:bd45", vlan_id=487),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:bd45", vlan_id=487),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:bd45", vlan_id=487),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50438
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.22", username="ute", password="ute"
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
    serial_number="d18d55c8",
    ue_pc_address="10.44.72.132",
    ssh_connection_details=SshServiceDetails(
        addr="10.44.72.132", username="wro5gcloud", password="Secret2.022!"
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIP_AWHQN_AKQJ_AHGB_SA",
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)

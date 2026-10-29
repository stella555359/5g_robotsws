__maintainer__ = "Karolina Wojtaczka"
__team__ = "MN RAN RD VRF WRO1 4"
__owner__ = "Karolina Wojtaczka"
__email__ = "karolina.wojtaczka@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit
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

_pdu_gnb = Gude(addr="10.45.167.61", port_numbers=[8], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.167.208", port_numbers=[1, 5, 2], model="EPC", version="8220-1")
_pdu_gnb_ru_1 = Gude(
    addr="10.42.226.55", port_numbers=[9], model="EPC", version="8220-1")

_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AQQE",
    serial_number="L1214604779",
    product_code="475544A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="rfsw",
        password="3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
    ),
    lmp_connection=SshServiceDetails(
	addr="10.255.31.54",
	port=3000,
	username=""
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)

_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQJ",
    serial_number="1M222400725",
    product_code="475244A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.6",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    lmp_connection=SshServiceDetails(
	addr="10.255.31.55",
	port=3000,
	username=""
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)

_ru_3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AQQE",
    serial_number="L1214705938",
    product_code="475544A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.10",
        username="rfsw",
        password="3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
    ),
    lmp_connection=SshServiceDetails(
	addr="10.255.31.53",
	port=3000,
	username=""
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)

_ru_4 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AKQJ",
    serial_number="1M222600193",
    product_code="475544A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.10",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    lmp_connection=SshServiceDetails(
	addr="10.255.31.52",
	port=3000,
	username=""
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[9],
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[8],
    hardware_type="ASOE",
    hardware_version="A101",
    serial_number="EA211854210",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3, _ru_4])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.25.249",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef8", vlan_id=343),
    x2u=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef8", vlan_id=343),
    s1u=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef8", vlan_id=343),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50613
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.40.29", username="ute", password="ute"
    ),
    connections=[_asil_gnb_1],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_Server_WG",
    bind_interface_ip="10.44.184.246",
    address="10.44.184.246", user="ranpz", password="Pass4Testers!")

_nokia_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh)

# ASUS
_asus = TafUeAndroid(
    serial_number="MAAIKN00P883D25",
    ue_pc_address="10.42.36.151",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.36.151", username="wro5gsiso", password="oZPS0POrRieRtu"
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_2xAQQE_AZQJ_AKQJ_SA",
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)

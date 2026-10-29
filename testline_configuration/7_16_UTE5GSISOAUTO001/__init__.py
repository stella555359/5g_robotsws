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
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb, Leoni, SwitchChannel, SwitchModule
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.196",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2905", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2905", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2905", vlan_id=401),
)

_pdu_gnb = Gude(addr="10.44.205.26", port_numbers=[3], model="EPC", version="8221-1")

_pdu_gnb_ru = Gude(
    addr="10.44.205.162", port_numbers=[7], model="EPC", version="8221-1"
)

_pdu_enb_ru = Gude(
    addr="10.44.205.162", port_numbers=[5], model="EPC", version="8221-1"
)

_pdu_enb = Gude(addr="10.44.205.26", port_numbers=[4], model="EPC", version="8221-1")

_optical_switch = Leoni(addr="10.42.75.209", model="mol 6x(2x6)", port=3001)

_gnb_ru = RU(
    ru_hw_group="5Ggen4_HighF_2T2R",
    radio_type="AZQI",
    serial_number="YK202400054",
    product_code="475243A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc="
    ),
    lmp_connection=SshServiceDetails(
	addr="10.255.33.98",
	port=3000,
	username=""
    ),
    optical_switch_channels=[
        SwitchChannel(optical_switch=_optical_switch,
                      switch_module=SwitchModule(optical_switch=_optical_switch,
                                                 module_no=5,
                                                 channel_amount=4),
                      channel_no=1),
        SwitchChannel(optical_switch=_optical_switch,
                      switch_module=SwitchModule(optical_switch=_optical_switch,
                                                 module_no=2,
                                                 channel_amount=4),
                      channel_no=1),
    ],
    pdu_port=_pdu_gnb_ru.pdu_ports[7],
)

_abio1_gnb_1_loner = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0106",
    hardware_type="ABIO",
    serial_number="L1205102683",
    rus=[_gnb_ru],
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[3],
    hardware_type="ASIB",
    serial_number="L1203802343",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.129", username="ute", password="ute"
    ),
    connections=[_asib_gnb_1],
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_enb_ru = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="K9200617292",
    pdu_port=_pdu_enb_ru.pdu_ports[5],
)


_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru])

_abia_enb_1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    hardware_type="ASIA",
    serial_number="DH192450014",
    pdu_port=_pdu_enb.pdu_ports[4],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    global_bts_id=40177,
    instance_id=40177,
    rms=[_enb_ru],
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:607c:0000:0000:0000:2905", vlan_id=401
    ),
    oam_ip=NetworkAddress(v4="10.44.67.226"),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.235", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_enb_1.u_plane = NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2906")

_enb_1.c_plane = NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2906")

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50177
)

_core = RealCore5G()

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.80", username="wro5gsiso", password="oZPS0POrRieRtu"
)


_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    bind_interface_ip="10.45.168.53",
    address="10.45.168.53", user="5g", password="2019H@slo")

_nokia_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh)

_asus = TafUeAndroid(
    serial_number="NAAIOC1902268L4",
    ue_pc_address="10.44.72.80",
    ssh_connection_details=SshServiceDetails(
        addr="10.44.72.80", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_nokia_iperf],
    network_mode_switch_method="adb",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_asus],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AZQI_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb, _pdu_enb_ru],
    optical_switches=[_optical_switch],
)
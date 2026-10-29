__maintainer__ = "Adrian Karas"
__email__ = "adrian.karas@nokia.com"

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
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.attenuator import JFW
from taf.config.testline.lmi import SerialOverTcp, Remote

__all__ = ["tl"]

_attenuator = JFW(
    ip_addr="10.42.221.200",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="50PA-528",
    serial_number="573514",
)

_pdu_gnb = Gude(addr="10.44.205.37", port_numbers=[8], model="EPC", version="8221-1")

_pdu_gnb_ru = Gude(addr="10.44.205.35", port_numbers=[4], model="EPC", version="8221-1")

_ru_1 = RU(
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251205196",
    product_code="476541A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.208", port=3000),
        ]
    ),
)
_abip_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907422",
    rus=[_ru_1],
)

_asim_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="A102",
    serial_number="L1233503494",
)

_airscale_gnb_1 = Airscale(common_units=[_asim_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::292c", vlan_id=370),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::292c", vlan_id=370),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::292c", vlan_id=370),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50520, instance_id=50520
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.58", username="ute", password="ute"
    ),
    connections=[_asim_gnb_1],
)

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

_asus = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.72.65", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="MAAIKN00P719YWB",
    ue_pc_address="10.44.72.65",
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
    ue_pc_port="80",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    ues=[_asus],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIML_ABIPL_AVHA",
    pdus=[_pdu_gnb, _pdu_gnb_ru],
    attenuators=[_attenuator],
)

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
from taf.config.testline.lmi import SerialOverTcp, Remote

__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.205.37", port_numbers=[9], model="EPC", version="8221-1")

_pdu_gnb_ru = Gude(addr="10.44.205.35", port_numbers=[2], model="EPC", version="8221-1")

_ru_1 = RU(
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251205195",
    product_code="476541A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.6",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.99", port=3000, username=""),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)

_abip_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1241505017",
    rus=[_ru_1],
)

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABI0",
    hardware_version="475266A.102",
    serial_number="L1205102686",
    rus=[_ru_1],
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABI0",
    hardware_version="475266A.101",
    serial_number="L1204104913",
    rus=[_ru_1],
)

_asim_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_gnb_1, _abio_gnb_1, _abio_gnb_2],
    pdu_port=_pdu_gnb.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="A102",
    serial_number="L1230613814",
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
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::290b", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::290b", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::290b", vlan_id=401),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50146, instance_id=50146
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.156", username="ute", password="ute"
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

_nokia = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.180", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="HZQN1876AAK82901931",
    ue_pc_address="10.42.22.180",
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
    ues=[_nokia],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIML_ABIPL_ABIOL_AVHA",
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)

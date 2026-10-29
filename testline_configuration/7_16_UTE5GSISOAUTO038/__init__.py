__maintainer__ = "Zuzanna Wielkoszynska"
__team__ = "MN 5G&SC 5G Pz 1 WRO 9"
__email__ = "zuzanna.wielkoszynska@nokia.com"

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
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.core import RealCore5G
from taf.config.testline.ue import Android, PluginAndroidClassType
from taf.config.testline.connection_details import IperfDataTransferDetails
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol


__all__ = ["tl"]


_pdu_gnb = Gude(addr="10.45.167.61", port_numbers=[12], model="EPC", version="8221-1")

_pdu_gnb_ru_1 = Gude(
    addr="10.44.167.207", port_numbers=[5], model="EPC", version="8221-1"
)


_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AQQL",
    serial_number="L1230314343",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[5],
)


_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1204701022",
    rus=[_ru_1],
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[12],
    hardware_type="ASIL",
    serial_number="L1224209085",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1])


_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.25.248",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef7", vlan_id=343),
    x2u=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef7", vlan_id=343),
    s1u=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef7", vlan_id=343),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=40612, instance_id=40612
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.40.130", username="ute", password="ute"
    ),
    connections=[_asil_gnb_1],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_nokia_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_xiaomi = TafUeAndroid(
    serial_number="4d8e9c1a",
    ue_pc_address="10.45.165.137",
    ssh_connection_details=SshServiceDetails(
        addr="10.45.165.137", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    data_transfer=[_nokia_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    network_mode_switch_method="adb",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    ues=[_xiaomi],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILR_ABIORB4_AQQL_SA",
    pdus=[_pdu_gnb, _pdu_gnb_ru_1],
)

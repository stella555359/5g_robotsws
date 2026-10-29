__maintainer__ = "Michal Stasiak"
__team__ = "MN RAN RD VRF WRO1 4"
__email__ = "michal.stasiak@nokia.com"

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
from taf.config.testline.appserver import AppServer

__all__ = ["tl"]

_appserver_siso_ssh = SshServiceDetails(
    addr="10.42.54.121", username="ute", password="oZPS0POrRieRtu"
)

_iperf_siso = IperfDataTransferDetails(ssh_connection_details=_appserver_siso_ssh)
_appserver_siso = AppServer(iperf_details=_iperf_siso)

_pdu_gnb = Gude(addr="10.44.206.75", port_numbers=[10], model="EPC", version="8221-1")
_pdu_gnb_ru_1 = Gude(addr="10.44.206.168", port_numbers=[11], model="EPC", version="8221-1")

_gnb_ru_1 = RU(
    radio_type="AVHA",
    serial_number="L1251205194",
    ru_hw_group="",
    product_code="476541A.101",
    lmp_connection=SshServiceDetails(
    addr="10.255.33.114",
    port=3000,
    username="3001"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username={"SBTS25R1": "rfsw",
                  "SBTS25R2": "rfsw",
                  "SBTS25R3": "rfsw",
                  "SBTS26R1": "serviceuser",
                  "SBTS26R2": "serviceuser"},
        password={"SBTS25R1": "f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
                  "SBTS25R2": "f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
                  "SBTS25R3": "f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
                  "SBTS26R1": "kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
                  "SBTS26R2": "kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og="}
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[11],
)

_abip1_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1232907424",
    rus=[_gnb_ru_1],
)

_asim_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="A104",
    serial_number="L1233503557",
)

_airscale_gnb_1 = Airscale(common_units=[_asim_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru_1])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.207.24",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::320b", vlan_id=723),
    x2u=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::320b", vlan_id=723),
    s1u=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::320b", vlan_id=723),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], instance_id=50163, global_bts_id=55196
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.102", username="ute", password="nierobieCITbokawa1!"
    ),
    connections=[_asim_gnb_1],
)


_core = RealCore5G()

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.197.170",
    user="syslab",
    password="system",
    bind_interface_ip="10.42.197.170",
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_asus = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.42", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="M9AIKN01N530MBX",
    ue_pc_address="10.42.22.42",
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
    ue_pc_port="80",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    ues=[_asus],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ABIOL_ABIPL_AVHA",
    pdus=[_pdu_gnb, _pdu_gnb_ru_1],
    appservers=[_appserver_siso],
    core=_core,
)

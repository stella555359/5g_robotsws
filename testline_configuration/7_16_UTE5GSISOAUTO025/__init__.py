__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__owner__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__maintainer__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__email__ = "I_EXT_5G_SISO_CRT@internal.nsn.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb, Leoni
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    IperfDataTransferDetails,
    IperfDataTransferIperfOptions,
)
from taf.config.testline.ue import Android
from taf.config.testline.appserver import AppServer
import os


__all__ = ["tl"]

# AppServer to download BSR Package
_appserver_siso_ssh = SshServiceDetails(
    addr="10.42.54.121", username="ute", password="oZPS0POrRieRtu"
)
_iperf_siso = IperfDataTransferDetails(ssh_connection_details=_appserver_siso_ssh)

_appserver_siso = AppServer(iperf_details=_iperf_siso)

# Basic iperf AppServer
_appserver_ssh = SshServiceDetails(
    addr="10.45.168.53", username="5g", password="2019H@slo"
)
_iperf_options = IperfDataTransferIperfOptions(packet=1300)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.45.168.53",
    iperf_path="/data/data/com.nokia.android.application",
    iperf_options=_iperf_options,
    iperf_version=3,
)

_asus = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.67", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="M6AIKN0088562TP",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python36/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    clear_server_files=True,
    clear_logs=True,
    service_call_detach=14,
    service_call_attach=14,
)

_nokia1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.67", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="HZQN1876AAK90100042",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python36/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    clear_server_files=True,
    clear_logs=True,
)

_nokia2 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.67", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="HZQN1876AAKA1500016",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python36/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    clear_server_files=True,
    clear_logs=True,
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.84.14",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:600c:0000:0000:0000:1d09", vlan_id=519),
    x2u=NetworkAddress(v6="2a00:8a00:6000:600c:0000:0000:0000:1d09", vlan_id=519),
    s1u=NetworkAddress(v6="2a00:8a00:6000:600c:0000:0000:0000:1d09", vlan_id=519),
)

_pdu_gnb = Gude(addr="10.44.177.218", port_numbers=[2], model="EPC", version="8221-1")

_pdu_gnb_ru_1 = Gude(
    addr="10.44.200.120", port_numbers=[6], model="EPC", version="8221-1"
)

_pdu_gnb_ru_2 = Gude(
    addr="10.44.200.120", port_numbers=[5], model="EPC", version="8221-1"
)

_pdu_enb = Gude(addr="10.44.177.218", port_numbers=[1], model="EPC", version="8221-1")

_pdu_enb_ru = Gude(
    addr="10.44.177.218", port_numbers=[7], model="EPC", version="8221-1"
)

_optical_switch = Leoni(addr="10.42.54.76", model="mol 6x(2x6)", port=3001)

_abio1_gnb_1_loner = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0106",
    hardware_type="ABIO",
    serial_number="L1222103050",
    product_code="475266A.104",
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[2],
    hardware_type="ASIB",
    serial_number="L1204214359",
    product_code="473764A.102",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.165", username="ute", password="ute"
    ),
    connections=[_asib_gnb_1],
)

_airscale_gnb_1 = Airscale(
    common_units=[_asib_gnb_1],
    product_code="473098A",
)

_gnb_ru_1 = RU(
    ru_hw_group="5Ggen4_HighF_2T2R",
    radio_type="AKQJ",
    serial_number="1M220223974",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[6],
)

_gnb_ru_2 = RU(
    ru_hw_group="cMAAr5.1_1_16T16R",
    radio_type="AZQS",
    serial_number="1M212807173",
    product_code="475664A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2",
        username="rfsw",
        password="dV0s7Yk/kE100lIN53JdoX/bjZ+J3kXU4g4HMXda+ew=",
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[5],
)

_enb_ru = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="FRGU",
    serial_number="K92170937156",
    pdu_port=_pdu_enb_ru.pdu_ports[7],
)

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru_1, _gnb_ru_2])

_abia_enb_1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    hardware_type="ASIA",
    serial_number="L1163102222",
    pdu_port=_pdu_enb.pdu_ports[1],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    airscale=_airscale_enb_1,
    global_bts_id=40174,
    instance_id=40174,
    rms=[_enb_ru],
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:600c::2208", vlan_id=519),
    oam_ip=NetworkAddress(v4="10.42.86.142"),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.166", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50174
)

_core = RealCore5G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_asus, _nokia1, _nokia2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AKQJ_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2, _pdu_enb, _pdu_enb_ru],
    optical_switches=[_optical_switch],
    appservers=[_appserver_siso],
)

__maintainer__ = "Adrian Karas"
__email__ = "adrian.karas@nokia.com"

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
from taf.config.testline.appserver import AppServer
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import Android, PluginAndroidClassType
from taf.config.testline.connection_details import IperfDataTransferDetails


__all__ = ["tl"]

# APPSERVER - BSR PACKAGE
_appserver_siso_ssh = SshServiceDetails(
    addr="10.42.54.121", username="ute", password="oZPS0POrRieRtu"
)

_iperf_siso = IperfDataTransferDetails(ssh_connection_details=_appserver_siso_ssh)

_appserver_siso = AppServer(iperf_details=_iperf_siso)

# NORMAL APPSERVER
_appserver_ssh = SshServiceDetails(
    addr="10.45.168.53", username="5g", password="2019H@slo"
)
_askey_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.45.168.53",
    iperf_path="/usr/bin/",
)

# ASKEY UE
_askey = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.40", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    class_name=PluginAndroidClassType.at_cmd,
    serial_number="c44b420",
    server_dir="C:/pyro_server",
    python_path="C:/Python36/python.exe",
    iperf_details=_askey_iperf,
    serial_com=7,  # serial port of modem device
    diag_com=8,  # port of Ports(COM&LPT) Qualcomm HS-USB Diagnostics 901F
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.84.12",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4=None, v6="2a00:8a00:6000:600c::1d07", vlan_id=519),
    x2u=NetworkAddress(v4=None, v6="2a00:8a00:6000:600c::1d07", vlan_id=519),
    s1u=NetworkAddress(v4=None, v6="2a00:8a00:6000:600c::1d07", vlan_id=519),
)

_pdu_gnb = Gude(addr="10.44.177.218", port_numbers=[3], model="EPC", version="8221-1")

_pdu_enb = Gude(addr="10.44.177.218", port_numbers=[4], model="EPC", version="8221-1")

_pdu_enb_ru = Gude(
    addr="10.44.200.120", port_numbers=[3], model="EPC", version="8221-1"
)

_pdu_gnb_ru = Gude(addr="10.44.200.120", port_numbers=[4], model="EPC", version="8221-1")


_ru_1 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AZQS",
    serial_number="1M212807189",
    product_code="475664A.101",
    lmp_connection=SshServiceDetails(
        addr="10.42.142.37",
        port=2003,
        username=""
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2",
        username={
            "SBTS22R4": "rfsw",
        },
        password={
            "SBTS22R4": "5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
        },
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
)

_abil1 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1222301863",
    rus=[_ru_1],
)


_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1],
    pdu_port=_pdu_gnb.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A104",
    serial_number="DH203265307",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.57", username="ute", password="ute"
    ),
    connections=[_asib_gnb_1],
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50589, instance_id=50589
)

_core = RealCore5G()

_enb_ru_1 = RU(
    ru_hw_group="oZPS0POrRieRtu",
    radio_type="AHEB",
    serial_number="L1182205469",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.129",
        username={
            "SBTS22R4": "rfsw",
        },
        password={
            "SBTS22R4": "dV0s7Yk/kE100lIN53JdoX/bjZ+J3kXU4g4HMXda+ew=",
        },
    ),
    pdu_port=_pdu_enb_ru.pdu_ports[3],
)

_abia_enb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="A107",
    serial_number="DH212899381",
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[4],
    serial_number="L1215007261",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:600c::1d07", vlan_id=519),
    global_bts_id=40588,
    instance_id=40588,
    oam_ip=NetworkAddress(v4="10.42.86.140"),
    rms=[_enb_ru_1],
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.61", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASKEY_ASIBR_ABIOR_AZQS_ENB",
    core=_core,
    ues=[_askey],
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb, _pdu_enb_ru],
    appservers=[_appserver_siso],
)

__maintainer__ = "Filip Poprawa"
__email__ = "filip.poprawa@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import Android, PluginAndroidClassType


__all__ = ["tl"]

_appserver_ssh = SshServiceDetails(
    addr="10.42.61.65", username="5g", password="2019H@slo", port=5019
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.42.197.170",
    iperf_path="",
)

_askey_ue = Android(
    class_name=PluginAndroidClassType.at_cmd,
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.195", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="a28417d8",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    clear_logs=True,
    clear_server_files=True,
    network_mode_switch_method="adb",
    interface_name="Cellular 2",
    reset_interface=False,
    enable_disable_cfun=True,
    processes_to_kill=[
        "notepad++",
        "putty",
        "QXDM",
        "adb",
        "iperf",
        "QPSTConfig",
        "QMITestPro",
    ],
    iperf_details=_iperf,
    serial_com=8,
    diag_com=7,
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2b2", vlan_id=370),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2b2", vlan_id=370),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2b2", vlan_id=370),
)


_pdu_gnb = Gude(addr="10.44.206.217", port_numbers=[12], model="EPC", version="8221-1")

_pdu_gnb_ru = Gude(
    addr="10.44.206.217", port_numbers=[5], model="EPC", version="8221-1"
)

_pdu_enb = Gude(
    addr="10.44.206.217", port_numbers=[12], model="EPC", version="8221-1"
)  # backplane powered

_gnb_ru = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AZQO",
    serial_number="YK201100163",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.161", username="ute", password="ute"
    ),
    connections=[_asik_gnb_1],
)

_airscale_gnb_1 = Airscale([_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru])

_abia_enb_1 = CapacityUnit(addr="192.168.253.36")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[12],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    global_bts_id=40503,
    instance_id=1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2b2", vlan_id=370),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.162", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50503, instance_id=1
)

_core = RealCore5G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASKEY_ASIKL_ABILB1_AZQO_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb],
)

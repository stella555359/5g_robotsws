__team__ = "MN 5G&SC 5G Pz 1 WRO 9 SG"
__owner__ = "Rafal Sytyk"
__maintainer__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__email__ = "I_EXT_5G_SISO_CRT@internal.nsn.com"
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import Android

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::601d", vlan_id=465),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::601d", vlan_id=466),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::601d", vlan_id=467),
)

_pdu_gnb = Gude(addr="10.44.206.162", port_numbers=[2], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.206.218", port_numbers=[9, 10], model="EPC", version="8220-1"
)

_ru_1 = RU(
    ru_hw_group="AZHL",
    radio_type="AZHL",
    serial_number="AH211400637",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.49",
        username="rfsw",
        password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)
_ru_2 = RU(
    ru_hw_group="AZHL",
    radio_type="AZHL",
    serial_number="AH211600324",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.49",
        username="rfsw",
        password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[10],
)

_bbmod_1_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22", hardware_type="ABINL", serial_number="L1221200790"
)
_bbmod_1_gnb_2_loner = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIOL",
    serial_number="L1221200746",
    rus=[_ru_1, _ru_2],
)
_asill_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1_gnb_1_loner, _bbmod_1_gnb_2_loner],
    pdu_port=_pdu_gnb.pdu_ports[2],
    hardware_type="ASIL",
    serial_number="L1221104530",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.34", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[_asill_gnb_1],
)

_airscale_gnb_1 = Airscale(common_units=[_asill_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2])


_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50575, instance_id=50575
)

_core = RealCore()

_appserver_ssh = SshServiceDetails(
    addr="10.45.168.53", username="5g", password="2019H@slo"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.42.197.170",
    iperf_path="/data/data/com.nokia.android.application",
)

# NOKIA
_nokia = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.13", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="HZQN1876BAKC2300364",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python36/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    network_mode_switch_method="adb",
    clear_server_files=True,
    clear_logs=True,
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ABINL_ABIOL_2xAZHL",
    core=_core,
    ues=[_nokia],
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)

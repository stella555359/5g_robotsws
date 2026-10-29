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
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.ue import Android

__all__ = ["tl"]
# _attenuator = TopYoung(
#     ip_addr="10.42.54.205", port=3001, attenuation_port_numbers=range(1, 32)
# )
_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::601d", vlan_id=465),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::601d", vlan_id=466),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::601d", vlan_id=467),
)
_pdu_gnb = Gude(addr="10.44.206.162", port_numbers=[2], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.206.218", port_numbers=[9, 10], model="EPC", version="8220-1"
)
_pdu_enb = Gude(addr="0.0.0.0", port_numbers=[0], model="EPC", version="8221-1")
_pdu_enb_ru = Gude(addr="10.44.206.162", port_numbers=[4], model="EPC", version="8221-1")
_ru_1 = RU(
    ru_hw_group="AZHL",
    radio_type="AZHL",
    serial_number="AH211400637",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.49",
        username="rfsw",
        password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)
# _ru_2 = RU(
#     ru_hw_group="AZHL",
#     radio_type="AZHL",
#     serial_number="AH211600324",
#     default_ssh_connection_details=SshServiceDetails(
#         addr="192.168.254.49",
#         username="rfsw",
#         password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=",
#     ),
#     pdu_port=_pdu_gnb_ru.pdu_ports[10],
# )

_bbmod_1_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22", hardware_type="ABINL", serial_number="L1220202310"
)
_bbmod_1_gnb_2_loner = CapacityUnit(
    addr="192.168.253.26", hardware_type="ABIOL", serial_number="L1220104196"
)
_asill_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1_gnb_1_loner, _bbmod_1_gnb_2_loner],
    pdu_port=_pdu_gnb.pdu_ports[2],
    hardware_type="ASILL",
    serial_number="L1215103924",
)
_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.180.50", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[_asill_gnb_1],
)
_airscale_gnb_1 = Airscale(common_units=[_asill_gnb_1])
_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1])
# _du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2])
_abial_enb_1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIAL")
_asial_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abial_enb_1],
    pdu_port=_pdu_enb.pdu_ports[0],
    hardware_type="ASIAL",
    serial_number="L1211406935",
)
_airscale_enb_1 = Airscale(common_units=[_asial_enb_1])
_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50575
)
_core = RealCore5G()
_enb_rmod_1 = RU(
    ru_hw_group="FRGT",
    radio_type="FRGT",
    serial_number="F7142523677",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="root",
        password="",
    ),
    pdu_port=_pdu_enb_ru.pdu_ports[4],
)
_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::601c", vlan_id=465),
    global_bts_id=40575,
    instance_id=40575,
    oam_ip=NetworkAddress(v4="10.44.66.141"),
    rms=[_enb_rmod_1],
)
_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.231", username="ute", password="ute"
    ),
    connections=[_enb_1],
)
_appserver_ssh = SshServiceDetails(
    addr="10.42.61.65", username="5g", password="2019H@slo"
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
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
    clear_server_files=True,
    clear_logs=True,
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ABINL_ABIOL_2xAZHL",
    core=_core,
    ues=[_nokia],
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb, _pdu_enb_ru],
    # attenuators=[_attenuator],
)

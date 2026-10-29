__maintainer__ = "Krystian Wojakiewicz"
__team__ = "PZ_2_WRO_6"
__email__ = "krystian.wojakiewicz@nokia.com"
__owner_email__ = "krystian.wojakiewicz@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, NetworkAddress, RealEnb, RoutingInformation
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.attenuator import JFW

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.207", username="ute", password="ute"
    )
)

_RUE_attenuator = JFW(
    ip_addr="10.42.54.173",
    port=3001,
    attenuation_port_numbers=[3, 4, 11, 12, 17, 18],
)

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

# _abil_master = CapacityUnit(addr="192.168.253.20")
# _abil_slave = CapacityUnit(addr="192.168.253.21")
# _abil_loner = CapacityUnit(addr="192.168.253.22")

_abio_master = CapacityUnit(addr="fsp-5a")
_abio_slave = CapacityUnit(addr="fsp-5b")
_abio_loner = CapacityUnit(addr="fsp-5c")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_master, _abio_slave, _abio_loner],
    pdu_port=None,
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_cu.m = NetworkAddress(
    v4="10.44.224.30",
    vlan_id=915,
    routing=RoutingInformation(gateway="10.44.88.129", ip_prefix_length=26),
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    radio_type="AEQA",
)

_du = DU(_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51994, instance_id=51994)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=555, mnc=10)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abio_loner], pdu_port=None
)

_nuc_ue_pc_ssh = SshServiceDetails("10.44.72.81", "wro5grrm", password="5gpass!1")

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="2a00:8a00:6000:607c:ffff:ffff:ffff:effb",
    iperf_path="/usr/bin/iperf",
)

_android_ue_1 = Android(
    ssh_connection_details=_nuc_ue_pc_ssh,
    capabilities=["REAL_UE_SA", "REAL_UE_SA_PING", "REAL_UE_SA_HO"],
    serial_number="7ed81c7f",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg.txt",
    imsi="N/A",
    diag_com="N/A",
    dmc_path="c:/Users/wro5grrm/auto/qxdm_filter.dmc",
    iperf_details=_iperf_ue,
    licensekeeper="/cygdrive/c/Users/wro5grrm/Desktop/QPM_LK1.5.1",
    iperf_directory="/data/data/com.nokia.android.application/",
    phone_number="+35848560002716",
)

_android_ue_2 = Android(
    ssh_connection_details=_nuc_ue_pc_ssh,
    capabilities=["REAL_UE_SA"],
    serial_number="ea8e1199",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg.txt",
    imsi="N/A",
    diag_com="N/A",
    dmc_path="c:/Users/wro5grrm/auto/qxdm_filter.dmc",
    iperf_details=_iperf_ue,
    licensekeeper="/cygdrive/c/Users/wro5grrm/Desktop/QPM_LK1.5.1",
    iperf_directory="/data/data/com.nokia.android.application/",
    phone_number="+35848560002717",
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lte = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.90.68",
        vlan_id=487,
        routing=RoutingInformation(gateway="10.44.90.65", ip_prefix_length=26),
    ),
    global_bts_id=40087,
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="",
    attenuator=_RUE_attenuator,
    core=_real_core,
    ues=[_android_ue_1, _android_ue_2],
    enbs=[_lte],
)

tl.max_atten_value = 62
tl.tl_type = "sa"
tl.qxdm_username = "krystian.wojakiewicz@nokia.com"
tl.qxdm_password = "Password2"
tl.smod_slave = False

tl.ho_source_ports = [3, 4]
tl.ho_target_ports = [11, 12]

__all__ = ["tl"]

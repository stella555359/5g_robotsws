__maintainer__ = "Krystian Wojakiewicz"
__team__ = "PZ_2_WRO_6"
__email__ = "krystian.wojakiewicz@nokia.com"
__owner_email__ = "krystian.wojakiewicz@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.pdn import PDNAndroidDetails
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
        addr="10.44.178.27", username="ute", password="uteUTE!"
    )
)

_RUE_attenuator = JFW(
    ip_addr="10.42.221.87",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14],
)

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(v4="to_be_updated", v6="to_be_updated", vlan_id=None)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

_abil_master = CapacityUnit(addr="fsp-1-1a")
_abil_slave = CapacityUnit(addr="fsp-1-1b")
_abil_loner = CapacityUnit(addr="fsp-1-1c")

# _abio_master = CapacityUnit(addr="fsp-1a")
# _abio_slave = CapacityUnit(addr="fsp-1b")
# _abio_loner = CapacityUnit(addr="fsp-1c")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
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
    v4="10.44.88.143",
    vlan_id=480,
    routing=RoutingInformation(gateway="to_be_updated", ip_prefix_length=26),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50035, instance_id=50035)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=555, mnc=10)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abil_loner], pdu_port=None
)

_nuc_ue_pc_ssh = SshServiceDetails("10.44.72.20", "wro5grrm", password="5gpass!1")

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="/usr/bin/iperf",
)

_android_ue = Android(
    ssh_connection_details=_nuc_ue_pc_ssh,
    serial_number="8d330c20",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg.txt",
    imsi="555106000021036",
    diag_com="COM9",
    dmc_path="c:/Users/wro5grrm/auto/qxdm_filter.dmc",
    iperf_details=_iperf_ue,
    licensekeeper="/cygdrive/c/Users/wro5grrm/Desktop/QPM_LK1.5",
    iperf_directory="/data/data/com.nokia.android.application/",
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
        v4="10.44.88.207",
        vlan_id=481,
        routing=RoutingInformation(gateway="to_be_updated", ip_prefix_length=26),
    ),
    global_bts_id=40087,
    oam_ip=NetworkAddress(v4="10.44.90.60"),
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="to_be_updated",
    attenuator=_RUE_attenuator,
    core=_real_core,
    ues=[_android_ue],
    enbs=[_lte],
)

tl.max_atten_value = 62
tl.tl_type = "sa"
tl.qxdm_username = "krystian.wojakiewicz@nokia.com"
tl.qxdm_password = "Password1"

__all__ = ["tl"]

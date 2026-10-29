__maintainer__ = "Bartlomiej Swoboda"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "bartlomiej.swoboda@nokia.com"
__owner_email__ = "bartlomiej.swoboda@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import (
    NetworkAddress,
    RoutingInformation,
    RealEnb,
    Android,
    JFW,
)
from taf.config.testline.core import RealCore5G
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit


_RUE_attenuator = JFW(ip_addr="UNKNOWN", port=3001, attenuation_port_numbers=[])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.21", username="ute", password="ute"
    )
)

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.10", username="ute", password="Ut3pa5s#1be1"
    )
)

_realcore_appsrv = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.197.170", username="5g", password="2019H@slo"
    )
)

_abil_loner = CapacityUnit(addr="fsp-1c")
_abil_slave = CapacityUnit(addr="fsp-1b")
_abil_master = CapacityUnit(addr="fsp-1a")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=None,
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129", vlan_id=834),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.85.138",
        v6="2a00:8a00:6000:607c::1:616e",
        vlan_id=821,
        routing_v4=RoutingInformation(gateway="10.44.85.129", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.76.160",
        v6="2a00:8a00:6000:607c::1:623f",
        vlan_id=822,
        routing_v4=RoutingInformation(gateway="10.44.76.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.76.228",
        v6="2a00:8a00:6000:607c::1:6342",
        vlan_id=823,
        routing_v4=RoutingInformation(gateway="10.44.76.193", ip_prefix_length=26),
    ),
)
_cu.m = NetworkAddress(
    v4="10.44.85.75",
    vlan_id=820,
    routing=RoutingInformation(gateway="10.44.85.65", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.44.77.32",
    vlan_id=824,
    routing=RoutingInformation(gateway="10.44.77.1", ip_prefix_length=26),
)

_du = DU(airscale=_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50029, instance_id=50029)

_real_core = RealCore5G(mcc=555, mnc=10)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    lmp_connection=_common_unit_lte_ssh, capacity_units=[_abil_loner]
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
        v4="10.44.85.139",
        v6="2a00:8a00:6000:607c::1:616f",
        vlan_id=821,
        routing_v4=RoutingInformation(gateway="10.44.85.129", ip_prefix_length=26),
    ),
    global_bts_id=40029,
)

_lte.m = NetworkAddress(
    v4="10.44.85.75",
    v6="2a00:8a00:6000:607c::1:606f",
    vlan_id=820,
    routing_v4=RoutingInformation(gateway="10.44.85.65", ip_prefix_length=26),
)

_nuc_ue_pc_ssh = SshServiceDetails("10.42.22.233", "wro5grrm", password="5gpass!1")

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="/usr/bin/iperf",
)

_android_ue = Android(
    ssh_connection_details=_nuc_ue_pc_ssh,
    serial_number="HZQN1876AAK60100468",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg.txt",
    imsi="",
    diag_com="",
    dmc_path="c:/Users/wro5grrm/auto/qxdm_filter.dmc",
    iperf_details=_iperf_ue,
    licensekeeper="/cygdrive/c/Users/wro5grrm/Desktop/QPM_LK1.5",
    iperf_directory="/data/data/com.nokia.android.application/",
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIK_ABIL_3xAHLOA_ENB",
    attenuator=_RUE_attenuator,
    core=_real_core,
    ues=[_android_ue],
    enbs=[_lte],
)

__all__ = ["tl"]

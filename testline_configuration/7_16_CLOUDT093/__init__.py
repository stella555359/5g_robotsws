__maintainer__ = "Sebastian Mikos"
__team__ = "5G Wro RRM5 IODT"
__email__ = "sebastian.mikos@nokia.com"
__owner_email__ = "sebastian.mikos@nokia.com"

import os
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
from taf.config.testline import DU, RU
from taf.config.testline.pdu import ATEN
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.71", username="ute", password="ute"
    )
)

_pdu_gnb = ATEN(addr="10.42.61.141", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu_gnb.pdu_ports[3],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.76.4",
        vlan_id=820,
        routing=RoutingInformation(gateway="10.44.76.1", ip_prefix_length=26),
    ),
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
        v4="10.44.76.68",
        vlan_id=821,
        routing=RoutingInformation(
            gateway="10.44.76.65",
            ip_prefix_length=26,
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.76.162",
        vlan_id=822,
        routing=RoutingInformation(gateway="10.44.76.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.76.227",
        vlan_id=823,
        routing=RoutingInformation(gateway="10.44.76.193", ip_prefix_length=26),
    ),
)


_ru_default_ssh = SshServiceDetails(
    addr="192.168.254.34", username="root", password="umniedziala"
)

_ru_lmp_ssh = SshServiceDetails(addr="", username="")

_ru = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=None,
    ru_hw_group="",
    radio_type="AZQH",
)

_du = DU(_airscale, rus=[_ru])

_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50011)

_core = RealCore5G(mcc=555, mnc=10)

_core_ssh = SshServiceDetails(addr="10.42.53.71", username="ute", password="ute")

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_capacity_unit], pdu_port=None
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lteenb = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.76.69",
        vlan_id=821,
        routing=RoutingInformation(gateway="10.44.76.65", ip_prefix_length=26),
    ),
    global_bts_id=40020,
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.72", username="ute", password="ute"
    ),
    connections=[_lteenb],
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="/opt/iperf/",
)

_ue_pc_ssh = SshServiceDetails("10.42.158.237", "wro5grrm", password="5gpass!1")

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="72437e82",
    server_dir="/cygdrive/c/pyro_server/ta_ue_plugin_android/ue",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    imsi="555106900020004",
    iperf_details=_iperf_ue,
    iperf_directory="/data/",
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _test_pc_enb],
    gnbs=[_classical_bts],
    enbs=[_lteenb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB1_AZQH_ENB",
    core=_core,
    ues=[_android_ue],
)

__all__ = ["tl"]

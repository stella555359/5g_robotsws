__maintainer__ = "Tomasz Sobania"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "tomasz.sobania@nokia.com"
__owner_email__ = "artur.maka@nokia.com"

import os
from taf.config.testline import DU, RU, NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import TM500
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, EPC


def get_dir_path():
    cfg_dir = os.path.dirname(os.path.abspath(__file__))
    return cfg_dir


_pdu1 = ATEN(addr="10.42.61.127", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdus = [_pdu1]

test_line_config_dir = get_dir_path()

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.123 ", username="ute", password="ute"
    )
)

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu1.pdu_ports[8],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.65.172", v6="2a00:8a00:6000:607c::5b64", vlan_id=460),
    x2u=NetworkAddress(v4="10.44.65.236", v6="2a00:8a00:6000:607c::5c44", vlan_id=461),
    s1u=NetworkAddress(v4="10.44.66.44", v6="2a00:8a00:6000:607c::5d44", vlan_id=462),
)

_cu.m = NetworkAddress(
    v4="10.44.76.40",
    vlan_id=820,
    routing=RoutingInformation(gateway="10.44.76.1", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.44.77.26",
    vlan_id=458,
    routing=RoutingInformation(gateway="10.44.77.1", ip_prefix_length=26),
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    radio_type="AHCA",
)

_du = DU(airscale=_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51993)

_epc_core = EPCSim(
    mme_ip="10.1.1.101",
    tac=7151,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.68.129", username="ute", password="ute"
    ),
    mcc="540",
    mnc="01",
    dir_path="/home/ute/epcsim_fdd/esimmode_WTS_1879136.4_4.0.11814",
    cfg_filename="simple.cfg",
    edaemon_port=10111,
    egate_port=20111,
)

_real_core = RealCore5G(mcc=555, mnc=10)

_viavi_ssh = SshServiceDetails(
    addr="10.42.158.199", username="NOKLAB\wro5grrm", password="5gpass!1"
)

_tm500 = TM500(
    tma_host=_viavi_ssh,
    tma_command_port=5003,
    iperf_details=IperfDataTransferDetails(
        iperf_path="C:/iperf-2.0.9-win32/iperf-2.0.9-win32/",
        ssh_connection_details=_viavi_ssh,
        network_interface_address="10.1.2.1",
        port=5410,
    ),
)

tl = TestLine(
    test_pc=_test_pc,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_VIAVI_ASIKL_ABILB1_AHCA",
    gnbs=[_cbts],
    core=_epc_core,
    ues=[_tm500],
)

__all__ = ["tl"]

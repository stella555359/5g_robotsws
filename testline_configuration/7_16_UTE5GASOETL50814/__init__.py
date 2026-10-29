__maintainer__ = "Patryk Mielcarek"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "patryk.mielcarek@nokia.com"
__owner_email__ = "patryk.mielcarek@nokia.com"

import os
from taf.config.testline import DU, RU, NetworkAddress, RoutingInformation, RealEnb
from taf.config.testline.ue import Android
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import EPCSim, RealCore5G
from taf.config.testline.ue import TM500
from taf.config.testline.appserver import AppServer
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.attenuator import JFW
from taf.config.testline.nms import Netact, NOM


def get_dir_path():
    cfg_dir = os.path.dirname(os.path.abspath(__file__))
    return cfg_dir


_attenuator = JFW(
    ip_addr="10.42.54.225",
    port=3001,
    attenuation_port_numbers=[3, 4, 11, 12],
)

test_line_config_dir = get_dir_path()

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.214", username="ute", password="ute"
    )
)

# _pdu1 = ATEN(
#     addr="10.42.208.151", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8]
# )  # PDU Asik  ##port 3
#

_pdu_su = Gude(
    addr="10.44.177.83",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru_1 = Gude(
    addr="10.44.177.37",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru_2 = Gude(
    addr="10.44.177.36",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_su, _pdu_ru_1, _pdu_ru_2]


_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

# _abil_master = CapacityUnit(addr="fsp-1a")
# _abil_slave = CapacityUnit(addr="fsp-1b")
# _abil_loner = CapacityUnit(addr="fsp-1c")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_su.pdu_ports[7],
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
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
    x2c=NetworkAddress(v4="10.44.224.99", v6="2a00:8a00:6000:607c::2b23", vlan_id=821),
    x2u=NetworkAddress(v4="10.44.224.163", v6="2a00:8a00:6000:607c::2c23", vlan_id=822),
    s1u=NetworkAddress(v4="10.44.224.227", v6="2a00:8a00:6000:607c::2d23", vlan_id=823),
)

_cu.m = NetworkAddress(
    v4="10.44.224.35",
    vlan_id=820,
    routing=RoutingInformation(gateway="10.44.224.1", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.44.225.35",
    vlan_id=824,
    routing=RoutingInformation(gateway="10.44.255.1", ip_prefix_length=26),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru_1.pdu_ports[12],
    ru_hw_group="",
    radio_type="AHEH",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[2:4],
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru_2.pdu_ports[6],
    ru_hw_group="",
    radio_type="AHEH",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[0:2],
)


_du = DU(airscale=_airscale, rus=[_ru_1, _ru_2])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=50815, global_bts_id=50815)


_core = RealCore5G(mcc=540, mnc=1)

_nuc_ue_pc_ssh = SshServiceDetails("10.44.72.17", "wro5grrm", password="5gpass!1")

###
# The correct realcore configuration
_realcore_appsrv = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    )
)
###


_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="/data/data/com.nokia.android.application/",
)

_android_ue_1 = Android(
    ssh_connection_details=_nuc_ue_pc_ssh,
    serial_number="HZQN1876FAL33100109",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    imsi="540017000000068",
    iperf_details=_iperf_ue,
    iperf_directory="/data/data/com.nokia.android.application/",
    clear_logs=True,
    clear_server_files=True,
)


tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _realcore_appsrv],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIK_ABIL_3xAHLOA_ENB",
    gnbs=[_cbts],
    pdus=_pdus,
    ues=[_android_ue_1],
    attenuator=_attenuator,
)


__all__ = ["tl"]

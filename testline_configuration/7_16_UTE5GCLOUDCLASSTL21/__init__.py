__maintainer__ = "Anna Nykiel"
__team__ = "MN 5G RAN I&V Cloud"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "anna.nykiel@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU
from taf.config.testline.radio import RU
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore4G
from taf.config.testline.pdu import ATEN
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import Android
from taf.config.testline.attenuator import JFW

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# 5G VM
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.74", username="ute", password="ute"
    )
)
_attenuator = JFW(
    ip_addr="10.42.221.94", port=3001, attenuation_port_numbers=range(9, 12)
)
_pdu = ATEN(addr="10.44.206.38", port_numbers=[4, 5], model="ATEN", version="")

# 5G radio units
_gnb_ru = RU(
    ru_hw_group="Below6GHz",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
)

# 4G radio units
_enb_rus = [RU(ru_hw_group="LTE_RADIO", radio_type="FXFB")]

_capacity_unit = CapacityUnit(addr="192.168.253.21")

_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
# BTS 5G
_asik = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_pdu.pdu_ports[5]
)
# BTS 4G
_asia = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_pdu.pdu_ports[4]
)
# BTS 5G
_airscale = Airscale(common_units=[_asik])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    f1m=NetworkAddress(v4="10.44.90.165"),
    x2c=NetworkAddress(v4="10.44.90.211"),
    x2u=NetworkAddress(v4="10.44.91.21"),
    s1u=NetworkAddress(v4="10.44.91.104"),
    tracing=NetworkAddress(v4="10.44.91.208"),
)
_du = DU(airscale=_airscale, rus=[_gnb_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=50439, global_bts_id=50439)

# BTS 4G

_core = RealCore4G()

_enb = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    rms=_enb_rus,
    instance_id=40439,
    global_bts_id=40439,
    oam_ip=NetworkAddress(v4="10.44.92.38"),
    x2_link_addr=NetworkAddress(v4="10.44.92.101"),
)
# 4G VM
_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.75", username="ute", password="ute"
    ),
    connections=[_enb],
)
# NUC
_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.132", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = SshServiceDetails(
    addr="10.42.61.65", username="5g", password="2019H@slo"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.42.61.65",
    iperf_path="/usr/bin/iperf",
)

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="",
    server_dir="/cygdrive/c/pyro_server/ta_ue_plugin_android/ue",
    python_path="C:/Python27/python.exe",
)

_askey_at_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "askey_at_ue.yaml"
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _test_pc_enb],
    gnbs=[_cbts],
    enbs=[_enb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AHLOA_ENB",
    core=_core,
    pdus=[_pdu],
)

__all__ = ["tl"]

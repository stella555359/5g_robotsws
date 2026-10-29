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
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU
from taf.config.testline.radio import RU
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore4G
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import Android


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.227", username="ute", password="ute"
    )
)

_pdu = Gude(addr="10.44.206.178", port_numbers=[4], model="EPC", version="8220-1")

# 5G radio units

_gnb_ru = RU(
    ru_hw_group="Below6GHz",
    radio_type="AHDB",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
)

_gnb_ru = RU(
    ru_hw_group="Below6GHz",
    radio_type="AHDB",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
)
# 4G radio units
_enb_rus = [RU(ru_hw_group="LTE_RADIO", radio_type="AHCA")]

_capacity_unit = CapacityUnit(addr="192.168.253.21")

_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_asik = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_pdu.pdu_ports[4]
)

_asia = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_pdu.pdu_ports[4]
)

_airscale = Airscale(common_units=[_asik])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    f1m=NetworkAddress(v4="10.44.66.156"),
    x2c=NetworkAddress(v4="10.44.66.220"),
    x2u=NetworkAddress(v4="10.44.67.17"),
    s1u=NetworkAddress(v4="10.44.67.81"),
    tracing=NetworkAddress(v4="10.44.67.145"),
)

_du = DU(airscale=_airscale, rus=[_gnb_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=50422, global_bts_id=50422)

_core = RealCore4G()

_enb = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    rms=_enb_rus,
    instance_id=40422,
    global_bts_id=40422,
    oam_ip=NetworkAddress(v4="10.44.66.157"),
    x2_link_addr=NetworkAddress(v4="10.44.66.221"),
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.228", username="ute", password="ute"
    ),
    connections=[_enb],
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.42.22.124", username="wro5gcloud", password="Secret2.022!"
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _test_pc_enb],
    gnbs=[_cbts],
    enbs=[_enb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_2xAHDB_ENB",
    core=_core,
    pdus=[_pdu],
)

__all__ = ["tl"]

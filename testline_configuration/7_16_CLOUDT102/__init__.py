__maintainer__ = "Piotr Golabek"
__team__ = "RRM team"
__email__ = "piotr.golabek@nokia.com"
__owner_email__ = "piotr.golabek@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import EPCSim
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, EPC
from taf.config.testline.ue import Android
from taf.compatibility.configuration import TestlineWrapper

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.88", username="ute", password="ute"
    )
)

_pdu1 = ATEN(addr="10.44.61.221", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdus = [_pdu1]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu1.pdu_ports[4],
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
    f1m=None,
    f1c=None,
    f1u=None,
    x2c="10.1.1.1",
    x2u="10.1.1.2",
    s1c="10.1.1.1",
    s1u="10.1.1.2",
    tracing=None,
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[5],
    ru_hw_group="",
    radio_type="AEUA",
)

_du = DU(_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_core = EPCSim(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.88", username="ute", password="ute"
    ),
    dir_path="/opt/core",
    cfg_filename="epcsim.cfg",
    mme_ip="10.1.1.100",
    mcc=311,
    mnc=489,
    tac=788,
    edaemon_port=10000,
    egate_port=20000,
)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abil_loner], pdu_port=_pdu1.pdu_ports[2]
)

_lteenb = RealEnb(airscale=_airscale, x2_link_addr="10.1.1.110")

_ue_pc_ssh = SshServiceDetails(
    addr="10.42.158.1", username="wro5grrm", password="5gpass!1"
)

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="15b67d59",
    server_dir="/cygdrive/c/pyro_server/ta_ue_plugin_android/ue",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIKA101_ABILA101_AEUA_ENB",
    core=_core,
    pdus=_pdus,
    enbs=[_lteenb],
    ues=[_android_ue],
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]

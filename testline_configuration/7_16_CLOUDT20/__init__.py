__maintainer__ = "Wojciech Hyski"
__team__ = "I_MN_5GSC_PZ_5G_IV7_WRO_5"
__email__ = "I_MN_5GSC_PZ_5G_IV7_WRO_5@internal.nsn.com"
__owner_email__ = "wojciech.hyski@nokia.com"
import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU, NetworkAddress
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.pdu import ATEN, PduPort
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.42", username="ute", password="ute"
    )
)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.1.1.1", vlan_id="1904"),
)

_pdu_asik = ATEN(addr="10.44.206.102", port_numbers=[2])
_pdu_rmod1 = ATEN(addr="0.0.0.0", port_numbers=[0])
_pdu_rmod2 = ATEN(addr="0.0.0.0", port_numbers=[0])
_pdu_fanbreaker = ATEN(addr="0.0.0.0", port_numbers=[0])
_pdu_gpsbreaker = ATEN(addr="0.0.0.0", port_numbers=[0])

_abil1_du1 = CapacityUnit(addr="192.168.253.20")
_asik_du1 = CommonUnit(
    pdu_port=_pdu_asik.pdu_ports[2],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
)
_rmod1_du1 = RU(
    ru_hw_group="Unknown",
    radio_type="Unknown",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[0],
)

_du1 = DU(Airscale(common_units=[_asik_du1, _rmod1_du1]))

_cbts = ClassicalBts(cu=_cu, dus=[_du1])

_lteemu = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.61", username="ute", password="uteadmin"
    ),
    dir_path="/opt/core",
    cfg_filename="basic_cfg_LteEmu.cfg",
    mme_ip="10.1.1.100",
    mcc=555,
    mnc=10,
    tac=7150,
    edaemon_port=22222,
    egate_port=10000,
)

_pdus = [_pdu_asik, _pdu_rmod1, _pdu_rmod2, _pdu_fanbreaker, _pdu_gpsbreaker]

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLASSICAL_5G_",
    core=_lteemu,
    pdus=_pdus,
)

__all__ = ["tl"]

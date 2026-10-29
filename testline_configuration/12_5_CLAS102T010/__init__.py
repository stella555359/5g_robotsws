import os
from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.core import EPCSim, LTEEmuCore, PrismaCore
from taf.config.testline import RU, DU
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import AirphoneCloud, Airphone, Prisma, TM500
from taf.config.testline import Enb, SimEnb, RealEnb, LTEEmuEnb, PrismaEnb, DocomoEnb
from taf.config.testline.switch import DellS4048ONSwitch, DellS4048TONSwitch
from taf.compatibility.configuration import TestlineWrapper

__maintainer__ = "Liu Yijun"  # TL owner name
__team__ = "I_NSB_MN_BOAM_RD_OM_FRSMZ_EITPIT_GMS_GMS <I_NSB_MN_BOAM_RD_OM_FRSMZ_EITPIT_GMS@internal.nsn.com>"
__email__ = "Jenny.j.liu@nokia-sbell.com"  # TL owner's email

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# host
_NCIR_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.163.88", username="ute", password="Hangzhoueit123!"
    )
)

# epc_sim
# _epcsim = EPCSim(mme_ip='10.57.157.137', mcc=311, mnc=489, tac=788,
#          default_ssh_connection_details=SshServiceDetails(
#          addr='10.57.157.137', username='nokia', password='nokia123'),
#          dir_path='/home/nokia/Jenny/Binary64bits_RrcWithNrRrc', cfg_filename='basic_wts_step1_175.cfg',
#          edaemon_port='22222', egate_port='20000')

# Cobham

# 5GRU for classicalBTS
_ru_pdu = FACOM(addr="10.57.246.243", port_numbers=[1])

_ru = RU(
    ru_hw_group="AEUA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_ru_pdu.pdu_ports[1],
)

# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="10.108.245.46", username="toor4nsn", password="oZPS0POrRieRtu", port="443"
)
_capacity_unit = CapacityUnit(addr="192.168.253.20")
_gnb_pdu = FACOM(addr="10.57.241.145", port_numbers=[4])
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[4],
)
_airscale = Airscale(common_units=[_common_unit_0])
_du = DU(airscale=_airscale, rus=[_ru])

# CU
_cu = CU(
    backhaul_site_oam_ip="",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.108.245.46", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.108.245.46", username="Nemuadmin", password="nemuuser", port="443"
    ),
)

# RealEnb
_lmp_connection_enb = SshServiceDetails(
    addr="10.57.235.176", username="toor4nsn", password="oZPS0POrRieRtu"
)
_common_unit_1 = CommonUnit(
    lmp_connection=_lmp_connection_enb,
    capacity_units=[],
    pdu_port=_gnb_pdu.pdu_ports[4],
)
_real_enb = Airscale(common_units=[_common_unit_1])
_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# cloud_topology
_tl_cloud_topology = "CLOUD_5G_BB3"

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu)

tl = TestLine(
    test_pc=_NCIR_host,
    gnbs=[_classical_bts],
    enbs=[_lte_real_enb],
    tl_cloud_topology=_tl_cloud_topology,
)

tl = TestlineWrapper(tl)

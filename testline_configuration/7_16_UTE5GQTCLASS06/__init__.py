__maintainer__ = "QT WRO"
__team__ = "MN 5G RAN Pz WRO CI"
__email__ = "I_5GQT_WRO@internal.nsn.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.cloud_hosting import (
    NCIR,
    ControlNode,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.enb import RealEnb  # currently unknown
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import Airphone
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, ATEN
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.gnb.networkaddress import NetworkAddress  # add in taf.meta 5.4


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.29", username="ute", password="ute"
    )
)
_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.51", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.51", username="admin", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_17A")

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="192.168.4.111", vlan_id=459),
    x2u=NetworkAddress(v4="192.168.4.111", vlan_id=459),
    s1u=NetworkAddress(v4="192.168.4.111", vlan_id=459),
)

_du_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_capacity_unit = CapacityUnit(addr="192.168.253.22")


_du_pdu = ATEN(addr="10.42.61.174", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9])

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=1)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[_du_capacity_unit],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru_pdu = ATEN(addr="10.42.61.177", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9])

_ru_pdu_port = PduPort(pdu=_ru_pdu, port_no=9)

_ru = RU(
    ru_hw_group="AEUA X22",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="user5", password="password5"
    ),
    pdu_port=_ru_pdu_port,
)

_du = DU(airscale=_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_epcsim = EPCSim(
    mme_ip="192.168.4.120",
    mcc=311,
    mnc=489,
    tac=333,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.68.197", username="ute", password="ute"
    ),
    dir_path="/home/ute/Robot_LteEmu",
    cfg_filename="Robot_LteEmu_Config",
)

_lteenb = RealEnb(airscale=_airscale, x2_link_addr=NetworkAddress(v4="10.83.182.123"))

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_lteenb],
    cloud_hostings=[_ncir],
    core=_epcsim,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKA101L_ABILA102_AHCA",
)
tl = TestlineWrapper(tl)


__all__ = ["tl"]

__maintainer__ = "TP MB"
__team__ = "Trials and Pilots Wroclaw"
__email__ = "mateusz.buszczak@nokia.com"


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
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import Airphone
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, ATEN
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline import RU

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.54.213", username="ute", password="uteadmin"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.20.30.40", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.20.30.40", username="admin", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_17A")

_cu = CU(
    backhaul_site_oam_ip="10.1.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.1.1.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.1.1.2", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.1.1.2", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_capacity_unit = CapacityUnit(addr="6.6.6.6")


_du_pdu = ATEN(addr="1.2.3.4", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9])

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=1)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[_du_capacity_unit],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru_pdu = ATEN(addr="4.3.2.1", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9])

_ru_pdu_port = PduPort(pdu=_ru_pdu, port_no=9)

_ru = RU(
    ru_hw_group="AEQD",
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
    mme_ip="10.1.1.100",
    mcc=244,
    mnc=8,
    tac=123,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.54.213", username="ute", password="ute"
    ),
    dir_path="/home/ute/epcsim",
    cfg_filename="kk.cfg",
)

_egate = SshServiceDetails(addr="0.0.0.0", username="user2", password="password2")
_l3 = SshServiceDetails(addr="3.3.3.3", username="user3", password="password3")

_l2 = SshServiceDetails(addr="4.4.4.4", username="user4", password="password4")

_lmp_connection = SshServiceDetails(
    addr="5.5.5.5", username="user5", password="password5"
)

_capacity_unit = CapacityUnit(addr="6.6.6.6")

_common_unit = CommonUnit(
    lmp_connection=_lmp_connection, capacity_units=[_capacity_unit]
)

_l1 = Airscale(common_units=[_common_unit])

_airphone = Airphone(
    egate=_egate, l3_ssh_connection_details=_l3, l2_ssh_connection_details=_l2, l1=_l1
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    core=_epcsim,
    ues=[],
    tl_cloud_topology="class01",
)
tl = TestlineWrapper(tl)

__all__ = ["tl"]

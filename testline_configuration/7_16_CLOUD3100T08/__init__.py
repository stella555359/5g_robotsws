__maintainer__ = "Jakub Migdalek"
__team__ = "RRM team"
__email__ = "jakub.migdalek@nokia.com"
__owner_email__ = "jakub.migdalek@nokia.com"

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
)
from taf.config.testline.gnb import CloudBts, CU, DU
from taf.config.testline.core import EPCSim
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.pdu import PduPort, ATEN
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline import RealEnb

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.92", username="ute", password="uteUTE!"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.110", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.110", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_19")


_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_16_CLOUD3100T08_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="c3100t08",
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_16_CLOUD3100T08_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_16_CLOUD3100T08_BTS",
    env_files=[os.path.join(_CFG_DIR, "config_bts.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_bts.yaml"),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu = CU(
    backhaul_site_oam_ip="10.44.200.96",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.200.96", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.200.96", username="Nemuadmin", password="nemuuser"
    ),
)

_common_unit_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_pdu1 = ATEN(addr="10.44.206.26", port_numbers=list(range(1, 9)))

_pdu2 = ATEN(addr="10.44.206.24", port_numbers=list(range(1, 9)))

_common_unit_pdu_port1 = PduPort(pdu=_pdu1, port_no=5)

_common_unit_pdu_port2 = PduPort(pdu=_pdu2, port_no=5)

_capacity_unit1 = CapacityUnit(addr="192.168.253.20")

_capacity_unit2 = CapacityUnit(addr="192.168.253.20")

_common_unit1 = CommonUnit(
    lmp_connection=_common_unit_lmp_connection,
    capacity_units=[_capacity_unit1],
    pdu_port=_common_unit_pdu_port1,
)

_common_unit2 = CommonUnit(
    lmp_connection=_common_unit_lmp_connection,
    capacity_units=[_capacity_unit2],
    pdu_port=_common_unit_pdu_port2,
)

_airscale1 = Airscale([_common_unit1])
_airscale2 = Airscale([_common_unit2])

_du1 = DU(airscale=_airscale1)
_du2 = DU(airscale=_airscale2)

_cbts = CloudBts(
    cu=_cu, cloud_deployment=_cloud_deployment, dus=[_du1], vnf_name="c3100t08"
)

_epcsim = EPCSim(
    mme_ip="10.1.1.66",
    mcc="311",
    mnc="489",
    tac=333,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.68.191", username="ute", password="ute"
    ),
    dir_path="/home/ute/Desktop/epcsim/",
    cfg_filename="EPCoulu.cfg",
)

_lteenb = RealEnb(airscale=_du2, x2_link_addr="10.1.1.4")

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_lteenb],
    tl_cloud_topology="CLOUD_5G_ASIK101L_ABIL102B1_AEUA",
    cloud_hostings=[_ncir],
    pdus=[_pdu1, _pdu2],
)
tl = TestlineWrapper(tl)

__all__ = ["tl"]

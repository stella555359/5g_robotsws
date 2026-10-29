__maintainer__ = "Bartlomiej Lebda"
__team__ = "I_5GSC_5G_PZ1_WRO_6"
__email__ = "I_5GSC_5G_PZ1_WRO_6@internal.nsn.com"
__owner_email__ = "bartlomiej.lebda@nokia.com"

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
from taf.config.testline.gnb import CloudBts, CU
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.hardware_controller import (
    GPSPowerHardwareController,
    AmiaFanHardwareController,
)
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline import DU, RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.60", username="ute", password="ute"
    )
)

_compute = ComputeNode(
    bmc_connection_details=BmcConnectionDetails(
        addr="10.42.208.212", username="admin", password="admin"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.2", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.2", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.42.208.3", username="admin", password="admin"
    ),
)

_control_1 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.3", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.3", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.42.208.224", username="admin", password="admin"
    ),
)

_ncir = NCIR(
    compute_nodes=[_compute], control_nodes=[_control_0, _control_1], version="ncir_17a"
)

_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_16_CLOUD1200T02_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
    default_vnf_prefix="C1200T02",
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_16_CLOUD1200T02_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_16_CLOUD1200T02_BTS",
    env_files=[os.path.join(_CFG_DIR, "config_bts.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu = CU(
    backhaul_site_oam_ip="10.44.181.4",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.181.4", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.181.4", username="Nemuadmin", password="nemuuser"
    ),
)

_pdu1 = ATEN(addr="10.0.0.0", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdu2 = Gude(
    addr="10.44.206.151",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="EPC",
    version="8221-1",
)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_abil2_du1 = CapacityUnit(addr="192.168.253.24")

_asik_du1 = CommonUnit(
    pdu_port=_pdu1.pdu_ports[1],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1, _abil2_du1],
)

_ru = RU(
    pdu_port=_pdu2.pdu_ports[1],
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(addr="", username=""),
    lmp_connection=SshServiceDetails(addr="", username=""),
)

_du1 = DU(Airscale(common_units=[_asik_du1]), rus=[_ru], f1_m_ip_addr="192.168.2.60")

_cbts = CloudBts(
    cu=_cu,
    cloud_deployment=_cloud_deployment,
    vnf_name="C1200T02",
    dus=[_du1],
    instance_id=1900,
    global_bts_id=1900,
)

_rpi = AmiaFanHardwareController(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.54.127", username="pi", password="raspberry"
    )
)

_pdus = [_pdu1, _pdu2]

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    tl_cloud_topology="CLOUD_5G_RPI_ASIKA101L_ABILA101B1_AEUA",
    core=None,
    hardware_controllers=[_rpi],
    pdus=_pdus,
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]

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
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline import DU, RU
from taf.config.testline.ue import TM500
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.hardware_controller import (
    GPSPowerHardwareController,
    AmiaFanHardwareController,
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.35", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.186", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.186", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.0.0.0", username="admin", password="admin"
    ),
)

_compute = ComputeNode(
    bmc_connection_details=BmcConnectionDetails(
        addr="10.0.0.0", username="admin", password="admin"
    )
)

_ncir = NCIR(compute_nodes=[_compute], control_nodes=[_control_0], version="ncir_19")

_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_16_CLOUD2800T02_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
    default_vnf_prefix="c2800_T02",
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_16_CLOUD2800T02_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_16_CLOUD2800T02_BTS",
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
    backhaul_site_oam_ip="2A00:8A00:6000:607c::1:3F04",
    oam_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::1:3F04", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="2A00:8A00:6000:607c::1:3F04", username="Nemuadmin", password="nemuuser"
    ),
)

_pdu_asik = ATEN(addr="10.0.0.0", port_numbers=[1, 2])

_pdu_ru = Gude(
    addr="10.44.206.151", port_numbers=[11, 12], model="EPC", version="8221-1"
)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_abil2_du1 = CapacityUnit(addr="192.168.253.24")

_asik_du1 = CommonUnit(
    pdu_port=_pdu_asik.pdu_ports[1],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1, _abil2_du1],
)

_asik_du2 = CommonUnit(
    pdu_port=_pdu_asik.pdu_ports[1],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1, _abil2_du1],
)

_ru_du1 = RU(
    pdu_port=_pdu_ru.pdu_ports[11],
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(addr="", username=""),
    lmp_connection=SshServiceDetails(addr="", username=""),
)

_ru_du2 = RU(
    pdu_port=_pdu_ru.pdu_ports[12],
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(addr="", username=""),
    lmp_connection=SshServiceDetails(addr="", username=""),
)

_du1 = DU(
    Airscale(common_units=[_asik_du1]),
    rus=[_ru_du1],
    f1_c_ip_addr="2A00:8A00:6000:607c::1:4010",
    f1_u_ip_addr="2A00:8A00:6000:607c::1:4011",
    f1_m_ip_addr="2A00:8A00:6000:607c::1:4012",
)


_du2 = DU(
    Airscale(common_units=[_asik_du2]),
    rus=[_ru_du2],
    f1_c_ip_addr="2A00:8A00:6000:607c::1:4013",
    f1_u_ip_addr="2A00:8A00:6000:607c::1:4014",
    f1_m_ip_addr="2A00:8A00:6000:607c::1:4015",
)

_cbts = CloudBts(
    cu=_cu,
    cloud_deployment=_cloud_deployment,
    vnf_name="2800t02",
    dus=[_du1, _du2],
    instance_id=50314,
    global_bts_id=50314,
)

_pdus = [_pdu_ru]

_rpi = AmiaFanHardwareController(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.53", username="pi", password="raspberry"
    )
)

_tm500 = TM500(
    tma_host=SshServiceDetails(
        addr="10.42.158.35", username="wro5goam", password="Uteadmin1@"
    ),
    tma_command_port=5005,
    pdu_port=None,
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    tl_cloud_topology="CLOUD_5G_VIAVI_RPI_SB_ASIKA101L_ABILA101B1_AEUA",
    ues=[_tm500],
    hardware_controllers=[_rpi],
    pdus=_pdus,
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]

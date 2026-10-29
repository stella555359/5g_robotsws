import os
from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
    OSP,
)
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.core import EPCSim, LTEEmuCore, PrismaCore
from taf.config.testline.gnb.du import DU
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, ATEN, RRB, APC, Gude
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.gnb import CloudBts, CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import (
    AirphoneCloud,
    Airphone,
    Prisma,
    TM500,
    Qualcomm,
    QualcommUeType,
    Android,
)  # added in taf.meta.5.4
from taf.config.testline.enb import (
    Enb,
    SimEnb,
    RealEnb,
    LTEEmuEnb,
    PrismaEnb,
    DocomoEnb,
)
from taf.config.testline.switch import DellS4048ONSwitch, DellS4048TONSwitch
from taf.config.testline.attenuator import (
    AttenuationPort,
    TopYoung,
)  # added in taf.meta 5.4
from taf.config.testline.gnb.networkaddress import NetworkAddress  # add in taf.meta 5.4
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)
from taf.config.testline.hardware_controller import (
    AmiaFanHardwareController,
    GPSPowerHardwareController,
)
from taf.config.testline.signal_analyzer import KeysightN9935A
from taf.config.testline.nms import Netact
from taf.compatibility.configuration import TestlineWrapper

__maintainer__ = "Rita Feng"
__team__ = "I_NSB_MN_CRAN_PZ_CBTS_SOL6_VRF_GMS <I_NSB_MN_CRAN_PZ_CBTS_SOL6_VRF@internal.nsn.com>"
__email__ = "rita.feng@nokia-sbell.com"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# #host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.57.167.68", username="ute", password="ute"
    )
)

# #epcsim
_epc_sim = EPCSim(
    mme_ip="10.70.38.224",
    mcc=262,
    mnc=3,
    tac=61,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.70.38.224", username="ute", password="ute"
    ),
    edaemon_port=10000,
    egate_port=20000,
    dir_path="/home/ute/Public/",
    cfg_filename="epc_standalone.lua",
)

# #RealEnb
_real_enb_pdu = FACOM(addr="10.57.241.200", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.57.237.130", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[1],
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# #5GRU_0 for cloudBTS
_ru_0_pdu = FACOM(addr="", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_ru_0 = RU(
    ru_hw_group="above6GHz",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_ru_0_pdu.pdu_ports[1],
    radio_type=RadioTypes.AEUB,
)

# #5GRU_1 for cloudBTS
_ru_1_pdu = FACOM(addr="", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_ru_1 = RU(
    ru_hw_group="above6GHz",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_ru_1_pdu.pdu_ports[1],
    radio_type=RadioTypes.AEUB,
)

# #DU_0 for cloudlBTS
_lmp_connection_9 = SshServiceDetails(
    addr=" 10.57.229.135", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_9 = CapacityUnit(addr="192.168.253.20")

_du_0_pdu = FACOM(addr="10.57.241.200", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_common_unit_9 = CommonUnit(
    lmp_connection=_lmp_connection_9,
    capacity_units=[_capacity_unit_9],
    pdu_port=_du_0_pdu.pdu_ports[1],
)

_airscale_0 = Airscale(common_units=[_common_unit_9])

_du_0 = DU(
    airscale=_airscale_0,
    rus=[_ru_0],
    f1_m_ip_addr=NetworkAddress(v4="10.57.229.135", vlan_id=1805),
    f1_c_ip_addr=NetworkAddress(v4="192.168.2.201", vlan_id=1805),
    f1_u_ip_addr=NetworkAddress(v4="192.168.2.202", vlan_id=1805),
)

# #DU_1 for cloudlBTS
_lmp_connection_8 = SshServiceDetails(
    addr="5.5.5.5", username="user5", password="password5"
)

_capacity_unit_8 = CapacityUnit(addr="6.6.6.6")

_du_1_pdu = FACOM(addr="5.5.5.5", port_numbers=[3])

_common_unit_8 = CommonUnit(
    lmp_connection=_lmp_connection_8,
    capacity_units=[_capacity_unit_8],
    pdu_port=_du_1_pdu.pdu_ports[3],
)

_airscale_1 = Airscale(common_units=[_common_unit_8])

_du_1 = DU(airscale=_airscale_1, rus=[_ru_1])

# #CU

_f1m = NetworkAddress(v4="10.57.229.135", vlan_id=1805)
_f1c = NetworkAddress(v4="192.168.2.107", vlan_id=1805)
_f1u = NetworkAddress(v4="192.168.2.110", vlan_id=1805)
_x2c = NetworkAddress(v4="10.57.159.182", vlan_id=1)
_x2u = NetworkAddress(v4="10.57.159.183", vlan_id=1)
_s1c = NetworkAddress(v4="10.57.159.182", vlan_id=1)
_s1u = NetworkAddress(v4="10.57.159.183", vlan_id=1)
_tracing = NetworkAddress(v4="192.168.3.104", vlan_id=1214)

_cu = CU(
    backhaul_site_oam_ip="10.107.168.145",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.107.168.145", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.107.168.145", username="Nemuadmin", password="nemuuser"
    ),
    f1m=_f1m,
    f1c=_f1c,
    f1u=_f1u,
    x2c=_x2c,
    x2u=_x2u,
    s1c=_s1c,
    s1u=_s1u,
    tracing=_tracing,
)

# cloud
_control = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.107.168.74",
        username="CBTS4user",
        tenant="CBTS4",
        password="system123",
        port=5000,
        protocol="http",
        version="v3",
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.107.8.112", username="stack", password="system123"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)


_osp = OSP(
    control_nodes=[_control], compute_nodes=[], version="19A", cloud_deployments=None
)


# #cloudbts
flavor_env_files = [os.path.join(_cfg_dir, "5gbts_flavor.env")]

net_env_files = [
    os.path.join(_cfg_dir, "5gbts_int_net.env"),
    os.path.join(_cfg_dir, "5gbts_int_net_ci.env"),
]

vnf_env_files = [
    os.path.join(_cfg_dir, "5gbts_heat.env"),
    os.path.join(_cfg_dir, "5gbts_heat_ci.env"),
]

_cbts_flavor = DeploymentFlavorStack(
    name="cransg06-tl4-flavor",
    env_files=flavor_env_files,
    yaml_file=os.path.join(_cfg_dir, "5gbts_flavor.yaml"),
    default_vnf_prefix="cransg06-tl4",
)

_cbts_net = DeploymentNetworkStack(
    name="cransg06-tl4-int",
    env_files=net_env_files,
    yaml_file=os.path.join(_cfg_dir, "5gbts_int_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="cransg06-tl4-cu",
    env_files=vnf_env_files,
    yaml_file=os.path.join(_cfg_dir, "5gbts_heat.yaml"),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_osp,
)

_cbts = CloudBts(
    dus=[_du_0], cu=_cu, cloud_deployment=_cloud_deployment, vnf_name="CBTS4_gNB_CU_3"
)

# #cloud_topology
_tl_cloud_topology = "CLOUD_5G_RPI_SB_ASIKA101L_ABILA101B1_AEUB_19A"

# switch Dtor
_dell_s4048on_ssh = SshServiceDetails(
    addr="1.0.0.1", port="1/10", username="user", password="pass"
)  # EIF1 port
_dell_s4048on_switch = DellS4048ONSwitch(_dell_s4048on_ssh)

# switch Mtor
_dell_s4048ton_ssh = SshServiceDetails(
    addr="1.0.0.1", port="1/5", username="5gran", password="nokia123"
)  # LMP Port
_dell_s4048ton_switch = DellS4048TONSwitch(_dell_s4048ton_ssh)

# netact
_netact = Netact("5.5.5.5")

# #Prisma
_airmosaic_ssh = SshServiceDetails(addr="10.10.10.10", username="user", password="pass")

_airmosaic_harness = HttpConnectionDetails(addr="10.10.10.10", port=8090)

_lsu_uu_ssh = SshServiceDetails(addr="9.9.9.9", username="user", password="pass")

_tstm_uu_ssh = SshServiceDetails(addr="9.9.9.9", username="user", password="pass")

_prisma_ue = Prisma(
    airmosaic_ssh_connection_details=_airmosaic_ssh,
    airmosaic_harness_connection_details=_airmosaic_harness,
    lsu_uu_ssh_connection_details=_lsu_uu_ssh,
    tstm_uu_ssh_connection_details=_tstm_uu_ssh,
)

_tstm_x2_ssh = SshServiceDetails(addr="9.9.9.9", username="user", password="pass")

_prisma_enb = PrismaEnb(tstm_x2_ssh_connection_details=_tstm_x2_ssh)

_lsu_s1_ssh = SshServiceDetails(addr="8.8.8.8", username="user", password="pass")

_tstm_s1_ssh = SshServiceDetails(addr="8.8.8.8", username="user", password="pass")

_prisma_core = PrismaCore(
    lsu_s1_ssh_connection_details=_lsu_s1_ssh,
    tstm_s1_ssh_connection_details=_tstm_s1_ssh,
)

tl = TestLine(
    test_pc=_host,
    gnbs=[_cbts],
    cloud_hostings=[_osp],
    core=_epc_sim,
    nms=_netact,
    enbs=[_lte_real_enb],
    ues=[_prisma_ue],
    tl_cloud_topology=_tl_cloud_topology,
    switches=[_dell_s4048on_switch, _dell_s4048ton_switch],
)


# old version keyword under robotws5g/resource compatibility workaround
tl = TestlineWrapper(tl)

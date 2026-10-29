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
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.core import RealCore
from taf.config.testline.core import EPCSim, LTEEmuCore, PrismaCore
from taf.config.testline import RU, DU

# from taf.config.testline.pdu import HBTE
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU, ClassicalBts
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import Qualcomm, QualcommUeType, Android
from taf.config.testline import Enb, SimEnb, RealEnb, LTEEmuEnb, PrismaEnb, DocomoEnb
from taf.config.testline.switch import DellS4048ONSwitch, DellS4048TONSwitch
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.nms import Netact
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.appserver import AppServer
from taf.config.testline import NetworkAddress, RoutingInformation

__maintainer__ = "Qian,Jianwu"
__team__ = (
    "I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS <I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03@internal.nsn.com>"
)
__email__ = "jianwu.qian@nokia-sbell.com"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# test pc
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.52.200.154", username="ute", password="ute"
    )
)

# 5GRU for classicalBTS
# _ru_pdu = HBTE(addr="10.52.200.129", port_numbers=[4])

_ru = RU(
    ru_hw_group="hw_group",  # Above6GHZ or Below6GHZ
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.49", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.49", username="root", password="umniedziala"
    ),
    # pdu_port=_ru_pdu.pdu_ports[4],
)

##DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_capacity_unit = CapacityUnit(addr="192.168.253.20")
# _gnb_pdu = HBTE(addr="10.52.202.210", port_numbers=[6])
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    # pdu_port=_gnb_pdu.pdu_ports[6],
)
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="SFP", port_id=1),
        target=Endpoint(unit=_ru, label="SFP", port_id=1),
    ),
]
_airscale = Airscale(common_units=[_common_unit_0])
_du = DU(
    airscale=_airscale, rus=[_ru], f1_m_ip_addr="192.168.255.129", cablinks=_ru_cablinks
)

# RealEnb
# _real_enb_pdu = HBTE(addr="xxxx", port_numbers=[1])
_lmp_connection_enb = SshServiceDetails(
    addr="xxx.xxx.xxx.xxx", username="toor4nsn", password="oZPS0POrRieRtu"
)
_common_unit_1 = CommonUnit(
    lmp_connection=_lmp_connection_enb,
    capacity_units=[],
    # pdu_port=_real_enb_pdu.pdu_ports[1],
)
_real_enb = Airscale(common_units=[_common_unit_1])
_lte_real_enb = RealEnb(airscale=_real_enb)

## switch Dtor
_dell_s4048on_ssh = SshServiceDetails(
    addr="10.0.0.0", port="1/6", username="xx", password="nokia123"
)
_dell_s4048on_switch = DellS4048ONSwitch(_dell_s4048on_ssh)

## switch Mtor
_dell_s4048ton_ssh = SshServiceDetails(
    addr="10.0.0.0", port="1/9", username="xx", password="nokia123"
)
_dell_s4048ton_switch = DellS4048TONSwitch(_dell_s4048ton_ssh)

##CU
_cu_oam_ip = NetworkAddress("2a00:8a00:2000:4901::1c4", vlan_id=None)
_x2c = NetworkAddress(
    v6="2a00:8a00:2000:4901:0000:0000:0000:1f9",
    vlan_id=None,
    routing=RoutingInformation(
        gateway="2a00:8a00:2000:4901:0000:0000:0000:1ff", ip_prefix_length=124
    ),
)
_tracing = NetworkAddress(v4="xxxx", v6="xxxx", vlan_id="xxxx")

_cu = CU(
    backhaul_site_oam_ip=_cu_oam_ip,
    oam_ssh_connection_details=SshServiceDetails(
        addr="2a00:8a00:2000:4901::1c4", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="[2a00:8a00:2000:4901::1c4]", username="Nemuadmin", password="nemuuser"
    ),
    x2c=_x2c,
    x2u=_x2c,
    s1u=_x2c,
    tracing=_tracing,
)

# cloud
_control = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.52.201.223",
        username="swenguser1",
        tenant="5gtenant1",
        password="Scp@dm1!",
        port=5000,
        protocol="https",
        version="v3",
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.52.201.223", username="swenguser1", password="Scp@dm1!"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="5.5.5.5", username="admin", password="admin"
    ),
)

_ncir = NCIR(
    compute_nodes=[],
    control_nodes=[_control],
    version="ncir_19",
    cloud_deployments=None,
)

# #cloudbts
_cbts_flavor = DeploymentFlavorStack(
    name="mmw-npv-tl107-flavor",
    env_files=[
        os.path.join(_cfg_dir, "5gbts_flavor.env"),
    ],
    yaml_file=os.path.join(_cfg_dir, "5gbts_flavor.yaml"),
    default_vnf_prefix="cbts_prefix",
)

_cbts_net = DeploymentNetworkStack(
    name="mmw-npv-tl107_ext_net",
    env_files=[
        os.path.join(_cfg_dir, "5gbts_ext_net.env"),
    ],
    yaml_file=os.path.join(_cfg_dir, "5gbts_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="mmw-npv-tl107-deploy",
    env_files=[
        os.path.join(_cfg_dir, "5gbts_heat.env"),
    ],
    yaml_file=os.path.join(_cfg_dir, "5gbts_heat.yaml"),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cbts = CloudBts(
    dus=[_du],
    cu=_cu,
    vnf_name=_cbts_vnf.name,
    instance_id=107,
    global_bts_id=107,
    cloud_deployment=_cloud_deployment,
)

##cloud_topology
_tl_cloud_topology = "CLOUD_5G_QC_ASIKL_ABILB1_AEWD_IPv6"

# iperf server
_appserver_ssh = SshServiceDetails(
    addr="10.4.130.77", username="scpadm", password="scpadm", port="43032"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.4.130.77",
    iperf_path="/usr/bin/iperf",
    port="43032",
)

_iperf_details_on_appserver2 = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.4.130.77",
    iperf_path="iperf",
    port="43046",
)
_appserver = AppServer(_iperf_details_on_appserver2)
# Qualcomm UE as Android
_android = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.52.200.138", username="usnap-scpadm", password="Scp@dm1!"
    ),
    serial_number="R3CN30ZFJ2B",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["REAL_ANDROID_UE", "samsung"],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    enbs=[_lte_real_enb],
    switches=[_dell_s4048on_switch, _dell_s4048ton_switch],
    tl_cloud_topology=_tl_cloud_topology,
    ues=[_android],
    appserver=_appserver,
    core=RealCore(mcc=1, mnc=1),
)

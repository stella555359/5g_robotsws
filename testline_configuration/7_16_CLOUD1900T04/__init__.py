__maintainer__ = "Artur Tabaka"
__team__ = "MN 5G RAN I&V 3 Pz Autom 1 SG"
__email__ = "I_CV_WRO_AUTOTEAM@internal.nsn.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import NetworkAddress
from taf.config.testline.cloud_hosting import (
    NCIR,
    ControlNode,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
)
from taf.config.testline.gnb import CloudBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.pdu import ATEN, EPC
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.compatibility.configuration import TestlineWrapper

import os

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.24", username="ute", password="ute"
    )
)

_compute = ComputeNode(
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.230", username="admin", password="admin"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.44.149.37", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.37", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.233", username="admin", password="admin"
    ),
)

_control_1 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.44.149.37", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.37", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.232", username="admin", password="admin"
    ),
)

_ncir = NCIR(
    compute_nodes=[_compute], control_nodes=[_control_0, _control_1], version="ncir_18"
)

_cbts_flavor = DeploymentFlavorStack(
    name="c02604_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="C026T04",
)

_cbts_net = DeploymentNetworkStack(
    name="c02604_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="c02604_BTS",
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
    backhaul_site_oam_ip="2A00:8A00:6000:607c::9A94",
    oam_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::9A94", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="2A00:8A00:6000:607c::9A94", username="Nemuadmin", password="nemuuser"
    ),
    f1m="2A00:8A00:6000:607c::9B94",
    f1c="2A00:8A00:6000:607c::9C94",
    f1u="2A00:8A00:6000:607c::9E94",
    x2c=NetworkAddress(v6="2A00:8A00:6000:607c::9D94", vlan_id=526),
    x2u=NetworkAddress(v6="2A00:8A00:6000:607c::9F94", vlan_id=528),
    s1c=NetworkAddress(v6="2A00:8A00:6000:607c::9D94", vlan_id=526),
    s1u=NetworkAddress(v6="2A00:8A00:6000:607c::A094", vlan_id=529),
    tracing=None,
)

_pdu1 = ATEN(addr="1.1.1.1", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdu2 = EPC(addr="10.44.206.150", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])

_pdus = [_pdu1, _pdu2]

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    pdu_port=_pdu1.pdu_ports[3],
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.102.2", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[12],
    ru_hw_group="",
    radio_type="AEUA",
)

_du1 = DU(Airscale(common_units=[_asik_du1]), rus=[_ru])

_cbts = CloudBts(
    cu=_cu, cloud_deployment=_cloud_deployment, vnf_name="C026T04", dus=[_du1]
)

_core = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.24", username="ute", password="ute"
    ),
    dir_path="/opt/core",
    cfg_filename="basic_cfg_LteEmu.cfg",
    mme_ip="10.1.1.100",
    mcc=311,
    mnc=489,
    tac=788,
    edaemon_port=22222,
    egate_port=10000,
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    tl_cloud_topology="CLOUD_5G_ASIKA101L_ABILA102B1_AEUA",
    core=_core,
    pdus=_pdus,
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]

__maintainer__ = "Jacek Juszczyszyn"
__team__ = "RRM team"
__email__ = "jacek.juszczyszyn@nokia.com"
__owner_email__ = "jacek.juszczyszyn@nokia.com"

import os
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
from taf.config.testline.core import EPCSim
from taf.config.testline import IperfDataTransferDetails
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer


__all__ = ["tl"]

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_testpc_ssh = SshServiceDetails(addr="10.42.209.39", username="ute", password="ute")
_test_pc = TestPc(default_ssh_connection_details=_testpc_ssh)
_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.158.11", username="ute", password="ute"
    )
)

_appserver = AppServer(
    IperfDataTransferDetails(
        ssh_connection_details=SshServiceDetails(
            addr="10.42.197.170", username="ute", password="ute"
        ),
        network_interface_address="",
        iperf_path="iperf",
    )
)


_compute = ComputeNode(
    bmc_connection_details=BmcConnectionDetails(
        addr="10.42.208.85", username="admin", password="admin"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.29", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.29", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.42.208.5", username="admin", password="admin"
    ),
)

_control_1 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.29", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.29", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.42.208.6", username="admin", password="admin"
    ),
)

_ncir = NCIR(
    compute_nodes=[_compute], control_nodes=[_control_0, _control_1], version="ncir_17A"
)

_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_16_CLOUD2600T04_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="C2600T04",
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_16_CLOUD2600T04_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_16_CLOUD2600T04_BTS",
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
    backhaul_site_oam_ip="10.44.200.6",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.200.6", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.200.6", username="Nemuadmin", password="nemuuser"
    ),
    f1m="192.168.2.111",
    f1c="192.168.2.112",
    f1u="192.168.2.113",
    x2c=NetworkAddress(v4="10.1.1.1", v6=None, vlan_id=3232),
    x2u=NetworkAddress(v4="10.1.1.2", v6=None, vlan_id=None),
    s1c=NetworkAddress(v4="10.1.1.1", v6=None, vlan_id=3232),
    s1u=NetworkAddress(v4="10.1.1.2", v6=None, vlan_id=None),
    tracing=None,
)

_capacity_unit = CapacityUnit(addr="192.168.253.22")

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")


_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=None,
)

_du = DU(airscale=Airscale(common_units=[_common_unit]))

_cbts = CloudBts(
    cu=_cu,
    dus=[_du],
    cloud_deployment=_cloud_deployment,
    vnf_name="c2600t03",
    global_bts_id=1900,
)

_epcsim_pc_ssh = SshServiceDetails(addr="10.42.68.6", username="ute", password="ute")
_core = EPCSim(
    mme_ip="10.1.1.100",
    mcc=311,
    mnc=489,
    tac=124,
    default_ssh_connection_details=_epcsim_pc_ssh,
    dir_path="/home/ute",
    cfg_filename="EPCoulu.cfg",
)


def _adapt_path_from_yml(_ue):
    for k, v in _ue["UE_POOLS"]["ViaviUePool"].items():
        value = v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["radio_card_config"]
        v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["radio_card_config"] = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), value
        )
        v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["attach"] = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["attach"],
        )
        v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["detach"] = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["detach"],
        )
    return _ue


with open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "viavi_config.yml")
) as ue_config:
    import yaml

    _ue = _adapt_path_from_yml(yaml.load(ue_config, yaml.SafeLoader))


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    tl_cloud_topology="CLOUD_5G_ASIKA101L_ABILA101B1_ABILA101B1_AEUA",
    core=_core,
    ues=[_ue],
    appserver=_appserver,
    test_pcs=[_lte_test_pc],
)

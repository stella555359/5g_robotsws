######################################
#  TestLine 26 Ulm                   #
######################################
__maintainer__ = "MN 5G&SC SW Eng ULM L3NRT 07 SG SQD61"
__team__ = "MN 5G&SC SW Eng ULM L3NRT 07 SG SQD61"
__email__ = "I_ECE_RD_ULM_SQD_61@internal.nsn.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline import NetworkAddress, RoutingInformation, Airphone
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
from taf.config.testline.pdu import APC
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# PDU  port5= gNB  port6= Airphone
_pdu = APC(addr="10.46.139.52", port_numbers=[5, 6])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.20.206", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.47.18.120",
        username="admin",
        tenant="admin",
        password="system123",
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.18.120", username="cloudadmin", password="system123"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="1.1.1.1", username="unknown", password="unknown"
    ),
)

_ncir = NCIR(control_nodes=[_control_0], version="NCIR19", compute_nodes=[])

# GNB

_cbts_flavor = DeploymentFlavorStack(
    name="TL26_5gbts_flavors",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "5gbts_flavor.yaml"),
    default_vnf_prefix="tl26-5gbts",
)

_cbts_net = DeploymentNetworkStack(
    name="TL26_5gbts_ext",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "5gbts_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL26_5gbts_rac",
    env_files=[os.path.join(_CFG_DIR, "config_bts.env")],
    yaml_file=os.path.join(_CFG_DIR, "5gbts_heat.yaml"),
)


_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.125.10", vlan_id=2526),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.125.10", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.125.10", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=2226),
    x2u=NetworkAddress(v4="10.0.1.3", vlan_id=2226),
    s1u=NetworkAddress(v4="10.0.1.3", vlan_id=2226),
    f1u=NetworkAddress(v4="10.0.3.3", vlan_id=2226),
)

# ABIL
_capacity_unit_1 = CapacityUnit(addr="192.168.253.20")

# ASIK
_common_unit_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit_1],
    pdu_port=_pdu.pdu_ports[5],
)

_airscale_1 = Airscale(common_units=[_common_unit_1])

_du_1 = DU(airscale=_airscale_1)

_cbts = CloudBts(
    cu=_cu, dus=[_du_1], cloud_deployment=_cloud_deployment, vnf_name="tl26-5gbts", instance_id=715000261
)


# TODO convert to new TL config
Baseband = "ABIL"
airscaleNodeID = ["0x10", "0x12"]


# AirPhone


_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                [CapacityUnit(addr="192.168.253.84")],
                pdu_port=_pdu.pdu_ports[6],
            )
        ]
    ),
)


# Testline
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    tl_cloud_topology="CLOUD_5G_ASIK_AP",
    pdus=[_pdu],
    ues=[_ue],
)

__all__ = ["tl"]

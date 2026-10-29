__maintainer__ = "xxxx"
__team__ = "MN_RAN_Pz_3_WRO_02&04"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"

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
)

from taf.config.testline.testpc import TestPc
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.core import RealCore
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import VDU, FHGW
from taf.config.testline.cloud_hosting import MasterNode, K8S, HelmChart
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU
from taf.config.testline.pdu import Gude
# from taf.config.testline.nms import NMS
# from taf.config.testline.nom import NOM

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu = Gude(
    addr="10.44.167.200",
    port_numbers=[5],
    model="EPC",
    version="8439-1",
)

_pdus = [_pdu]

_control = ControlNode(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.186.40", username="core", password="system123"
    ),
    open_stack_connection_details=OpenStackConnectionDetails(
        username="core",
        password="system123",
        ip_addr="10.42.142.198",
        tenant="cran8521",
    ),
    # Configuration for BMC access if you need use it in test case, plase config it
    # currently, it's not used in agent
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control], version="ncir_17")

_vcu_intnet_1 = DeploymentNetworkStack(
    name="aic-vcu-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vcu_vnf_1 = DeploymentVnfStack(
    name="aic-vcu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/aic_vdu_values_override_0.yaml"
    ),
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.249.40",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.45.186.40", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.249.40", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="192.168.6.48",
        vlan_id=3898,
        routing_v4=RoutingInformation(gateway="192.168.6.1", ip_prefix_length=24),
    ),
    xnc=NetworkAddress(
        v4="192.168.5.48",
        vlan_id=3897,
        routing_v4=RoutingInformation(gateway="192.168.5.1", ip_prefix_length=24),
    ),
    f1c=NetworkAddress(
        v4="10.42.39.101",
        vlan_id=763,
        routing=RoutingInformation(gateway="10.44.130.129", ip_prefix_length=26),
    ),
    f1u=NetworkAddress(
        v4="10.42.39.37",
        vlan_id=762,
        routing=RoutingInformation(gateway="10.44.130.65", ip_prefix_length=26),
    ),
    ngc=NetworkAddress(
        v4="10.42.39.229",
        vlan_id=767,
        routing=RoutingInformation(gateway="10.42.25.1", ip_prefix_length=24),
    ),
    ngu=NetworkAddress(
        v4="10.42.39.165",
        vlan_id=776,
        routing=RoutingInformation(gateway="10.42.24.1", ip_prefix_length=24),
    ),
    tracing=None,
    global_bts_id=84391,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.45.186.40", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.45.186.40", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8439", master_node=_vcu_master_node)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
)

_ru_1 = RU(
    ru_hw_group="cMAA_Gen4.0_8T8R_eCPRI",
    pdu_port=_pdu.pdu_ports[5],
    serial_number="EA200255434",
)

_fhgw_0 = FHGW(
    user_config_path=os.path.join(
       _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1],
    # pxe_server=_pxe_server,
    fhgw_id=8439,
)

_fhgw_0.ssh_username = "toor4nsn"
_fhgw_0.ssh_password = "Fhgw@nokia1243"

_vdu_vnf_0 = DeploymentVnfStack(
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

_vdu_intnet_0 = DeploymentNetworkStack(
    name="aic-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.45.186.40", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.45.186.40", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    networks=[_vdu_intnet_0],
    vnfs=[_vdu_vnf_0],
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.45.186.171", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    f1_c_ip_addr=NetworkAddress(
        v4="10.44.168.184",
        vlan_id=341,
        routing=RoutingInformation(gateway="10.44.168.1", ip_prefix_length=24),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.42.67.184",
        vlan_id=340,
        routing=RoutingInformation(gateway="10.42.67.1", ip_prefix_length=24),
    ),
    instance_id=1,
)

_ru_1 = RU(
    ru_hw_group="cMAA_Gen4.0_8T8R_eCPRI",
    #pdu_port=_pdu1.pdu_ports[9],
    serial_number="EA200255434",
)


_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vdu8439",
    instance_id="8439",
)

# _pxe_server_ssh_info = SshServiceDetails(
#     addr="", username="", password=""
# )
# _pxe_server = PxeServer(
#     nfs_ip="", ssh_connection_details=_pxe_server_ssh_info
# )

# _realcore = RealCore(five_g=None, mcc="", mnc="", pdns=None)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.62",
        username="ute",
        password="ute",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_ncir],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_FHGW_1vDU_AZQS",
#    core=_realcore,
    pdus=_pdus,
)

__all__ = ["tl"]

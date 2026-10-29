__maintainer__ = "jakub.ozierski@nokia.com"
__email__ = "jakub.ozierski@nokia.com"

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
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import VDU, FHGW, RANNIC
from taf.config.testline.cloud_hosting import MasterNode, K8S, HelmChart
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU
from taf.config.testline.pdu import Gude

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.206.70",
    port_numbers=[10],
    model="EPC",
    version="8220-1",
)

_pdu2 = Gude(
    addr="10.44.206.89",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.140.10",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.69.155", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.140.10", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.255.29.138",
        vlan_id=549,
        routing_v4=RoutingInformation(gateway="10.255.29.129/25"),
    ),
    xnc=NetworkAddress(
        v4="10.255.29.10",
        vlan_id=548,
        routing_v4=RoutingInformation(gateway="10.255.29.1/25"),
    ),
    f1c=NetworkAddress(
        v4="10.255.25.10",
        vlan_id=568,
        routing_v4=RoutingInformation(gateway="10.255.25.1/25"),
    ),
    f1u=NetworkAddress(
        v4="10.255.24.138",
        vlan_id=567,
        routing_v4=RoutingInformation(gateway="10.255.24.129/25"),
    ),
    ngc=NetworkAddress(
        v4="10.44.81.10",
        vlan_id=561,
        routing_v4=RoutingInformation(gateway="10.44.81.1/25"),
    ),
    ngu=NetworkAddress(
        v4="10.42.220.10",
        vlan_id=560,
        routing_v4=RoutingInformation(gateway="10.42.220.1/25"),
    ),
    tracing=None,
    global_bts_id=869301,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.69.155", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.69.155", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran869301", master_node=_vcu_master_node)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
)

_ru_1 = RU(
    radio_type = "ARGA",
    ru_hw_group="FRMr5.1_1_6T6R",
    pdu_port=_pdu1.pdu_ports[10],
    serial_number="F7204205582",
    )

_ru_2 = RU(
    radio_type = "AEQE",
    ru_hw_group="cMAAr6.1_64T64R",
    pdu_port=_pdu2.pdu_ports[10],
    serial_number="1M222002684",
    )

_fhgw_0 = FHGW(
    user_config_path=os.path.join(
       _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1],
    fhgw_id=8697,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.103.172", port=22, username="toor4nsn", password="Fhgw@nokia12435"
    ),
)

_rannic_0 = RANNIC(
    serial_number = "L1242202595",
    product_code = "AF1791.102",
    rus = [_ru_2],
)

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
    addr="10.42.139.7", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.139.7", username="core", password="system123", port=22
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
    addr="10.42.139.134", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    rannics=[_rannic_0],
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    f1_c_ip_addr=NetworkAddress(
        v4="10.255.24.6",
        vlan_id=566,
        routing_v4=RoutingInformation(gateway="10.255.24.1/25"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.255.23.134",
        vlan_id=565,
        routing_v4=RoutingInformation(gateway="10.255.23.129/25"),
    ),
    instance_id=1,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vdu8697",
    instance_id=8697, # parameter to do depricated!
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.16",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

# vCU is on cluster - below are details of all 3 master nodes
# DELL.vcu.5
vcu_server_mgmt_0 = SshServiceDetails(
        addr="10.42.138.27",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

# DELL.vcu.4
vcu_server_mgmt_1 = SshServiceDetails(
        addr="10.42.138.26",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

# DELL.vcu.1
vcu_server_mgmt_2 = SshServiceDetails(
        addr="10.42.138.23",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

vdu_server_mgmt = SshServiceDetails(
        addr="10.42.138.32",
        username="admin",
        password="ItDs@3dE0j16DHMf",
    )

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    # tl_cloud_topology="CLOUD_5G_FHGW_1vDU_AZQS",
    pdus=_pdus,
)

__all__ = ["tl"]

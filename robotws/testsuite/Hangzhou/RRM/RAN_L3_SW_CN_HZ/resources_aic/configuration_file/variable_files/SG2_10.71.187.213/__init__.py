__maintainer__ = "Xiang Kang"
__owner_email__ = "kang.xiang@nokia-sbell.com"

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
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId
from taf.config.testline import Airphone
from taf.config.testline.ue import PreferredVlan
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.core import RealCore
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.gnb.du import VDU
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU
from taf.config.testline.nms import NMS
from taf.config.testline.nms import NOM

# Following mandatory files and parameters should be configured
# Please don't ignore any parameters, you can add, but don't ingore
# Any problem, please check with CI team

# ####  FOLLOWING ARE CHECKLIST OF TESTLINE CONFIGURATION #######

#  1. 5gbts_ext_net.env have been configured as following
#  2. 5gbts_flavor.env have been configured as following
#  3. 5gbts_heat.env have been configured as following
#  4. aic-intnet-values-override_${vdu_index}.yaml (vdu_index should start from 0) have been configured as following
#  5. aic-vdu-values-override_${vdu_index}.yaml (vdu_index should start from 0) have been configured as following
#  6. user_config_${fhgw_index}.yaml (fhgw_index should start from 0) have been configured as following
#  (currently, it's not used)
#  7. "vnf_prefix" in 5gbts_flavor.env should be re-configued, don't use common flavor name
#  8. vnf_prefix naming rule should be flavor-<testline name>, e.g: flavor-7_5_UTE5GAIC001T037
#  9. "flavors" in 5gbts_heat.env should be configured and prefix should equal to vnf_prefix value configured on
#  5gbts_flavor.env
#  10. please make sure 5gbts_ext_net.env, 5gbts_flavor.env, 5gbts_heat.env are new enough for next build
#  11. please make sure aic-intnet-values-override_x.yaml and aic-vdu-values-override_x.yaml are new enough for
#  next build
#  12. please make sure files in step 1,2,3,4,5 have valid configuration
#  13. please make sure ip address of NCIR and test pc can be accessible by network
#  14. please make sure VDU on OE have been cleared or VDU helm release name is equal to name of DeploymentVnfStack
#  before start agent_5g_aic
#  15. please make sure VCU on NCIR have been cleared or VCU stack name is TL_<testline name>_BTS before start
#  agent_5g_aic
#  16. please check nom mo configured
#################################################################


_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# UTE IP address and User Name, Password,
# this is test PC for AIC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.71.187.213", username="ute", password="ute"
    )
)

# VCU related NCIR controlNode
_control = ControlNode(
    # Configuration for SSH access
    default_ssh_connection_details=SshServiceDetails(
        addr="10.57.222.6", username="core", password="system123"
    ),
    # Configuration for openstack connection
    open_stack_connection_details=OpenStackConnectionDetails(
        username="core",
        password="system123",
        ip_addr="10.57.222.6",
        tenant="tl726-new",
    ),
    # Configuration of BMC connection, if you need use it in test case, plase config it
    # currently, it's not used in agent
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

# configuration of VCU related NCIR/OSP
_ncir = NCIR(compute_nodes=[], control_nodes=[_control], version="ncir_19")

# CU configuration
_cu = CU(
    # CU web UI ip address, oam interface ip of oam vm
    backhaul_site_oam_ip=NetworkAddress(
        v4="192.168.100.129"
        # v6='2a00:8a00:8000:136:10:57:159:1111'
    ),
    # VCU OAM ssh connection, oam interface ip of oam vm
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.57.222.6", username="core", password="system123"
    ),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.100.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    # route configuration for x2 link to ENB, v4 is network address of ENB x2 link
    x2c=NetworkAddress(
        v4="10.0.1.111",
        vlan_id=3473,
        routing_v4=RoutingInformation(gateway="10.0.1.1/24"),
    ),
    # route configuration for xn link to GNB,v4 is network address of GNB xnc link
    xnc=NetworkAddress(
        v4="10.0.12.111",
        vlan_id=3474,
        routing_v4=RoutingInformation(gateway="10.0.12.1/24"),
    ),
    # route configuration for f1c link to VDU on VCU,v4 is network address of VDU f1c link
    f1c=NetworkAddress(
        v4="172.16.1.101",
        vlan_id=3498,
        routing_v4=RoutingInformation(gateway="172.16.1.1/24"),
    ),
    # route configuration for f1u link to VDU on VCU, v4 is network address of VDU f1u link
    f1u=NetworkAddress(
        v4="172.16.1.201",
        vlan_id=3498,
        routing_v4=RoutingInformation(gateway="172.16.1.1/24"),
    ),
    s1u=NetworkAddress(
        v4="10.0.1.113",
        vlan_id=3473,
        routing_v4=RoutingInformation(gateway="10.0.1.1/24"),
    ),
    x2u=NetworkAddress(
        v4="10.0.1.112",
        vlan_id=3473,
        routing_v4=RoutingInformation(gateway="10.0.1.1/24"),
    ),
    xnu=NetworkAddress(
        v4="10.0.12.112",
        vlan_id=3474,
        routing_v4=RoutingInformation(gateway="10.0.12.1/24"),
    ),
    ngc=NetworkAddress(
        v4="10.0.11.111",
        vlan_id=3471,
        routing_v4=RoutingInformation(gateway="10.0.11.1/24"),
    ),
    ngu=NetworkAddress(
        v4="10.0.11.112",
        vlan_id=3471,
        routing_v4=RoutingInformation(gateway="10.0.11.1/24"),
    ),
    tracing=None,
)

# enb for NSA
_real_enb = RealEnb(oam_ip="10.97.122.232", instance_id="")

# test pc information of enb
# you can configure it as AIC UTE environment
_enb_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.71.187.213", username="ute", password="ute"
    ),
    connections=[_real_enb],
)

# flavor of VCU
flavor_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_flavor.env")]

# ext_net of VCU
net_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_ext_net.env")]

# heat parameters
vnf_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_heat.env")]

_cbts_flavor = DeploymentFlavorStack(
    name="name is not used",  # this name is not used, you need NOT configure it, let it be
    env_files=flavor_env_files,
    default_vnf_prefix="hgz-tl1234",
)

_cbts_net = DeploymentNetworkStack(
    name="name is not used",  # this name is not used, you need NOT configure it, let it be
    env_files=net_env_files,
    yaml_file=os.path.join(_cfg_dir, "5gbts_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="name is not used",  # this name is not used, you need NOT configure it, let it be
    env_files=vnf_env_files,
    yaml_file=os.path.join(_cfg_dir, "5gbts_heat.yaml"),
)

# cloud deployment configuration fo VCU
_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

# VDU configuration for deployment
_vdu_vnf_0 = DeploymentVnfStack(
    name="aic-vdu-mvp",  # vdu release name, name should only be lower case and only can include alphabet, number, _
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

# VDU internal network configuration for deployment
_vdu_intnet_0 = DeploymentNetworkStack(
    name="aic-intnet-mvp",  # intnet release name,name should only be lower case and only can include alphabet,number,_
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

# ssh connection information of OE, for tenant user
_ssh_connection_details = SshServiceDetails(
    addr="192.168.2.2", username="core", password="system123"
)

_ssh_connection_details_du2 = SshServiceDetails(
    addr="192.168.2.3", username="core", password="system123"
)

# ssh connection information of OE, for cloudadmin user
_k8s_connection_details = K8SConnectionDetails(
    ip_addr="192.168.2.2", username="core", password="system123", port="22"
)

_k8s_connection_details_du2 = K8SConnectionDetails(
    ip_addr="192.168.2.3", username="core", password="system123", port="22"
)

# master node information of OE
_master_node = MasterNode(
    k8s_connection_details=_k8s_connection_details,
    ssh_connection_details=_ssh_connection_details,
)

_master_node_du2 = MasterNode(
    k8s_connection_details=_k8s_connection_details_du2,
    ssh_connection_details=_ssh_connection_details_du2,
)

_k8s = K8S(namespace="tl726-new", master_node=_master_node)

_k8s_du2 = K8S(namespace="tl726-new", master_node=_master_node_du2)

# VDU deployment configuration
_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_0],
    vnfs=[_vdu_vnf_0],
    cloud_hosting=_k8s,
)

_k8s_cloud_deployment_du2 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_0],
    vnfs=[_vdu_vnf_0],
    cloud_hosting=_k8s_du2,
)

# VDU oam http connection
_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="192.168.255.129", port="443", username="Nemuadmin", password="nemuuser"
)

_vdu_oam_http_connection_details_du2 = HttpConnectionDetails(
    addr="192.168.255.130", port="443", username="Nemuadmin", password="nemuuser"
)

# RU configuration
_ru_1 = RU(ru_hw_group="RU_INT_ECPRI", serial_number="1M213624067")
_ru_2 = RU(ru_hw_group="RU_INT_ECPRI", serial_number="DU213624067")

# PXE server info for FHGW deployment
_pxe_server_ssh_info = SshServiceDetails(
    addr="", username="root", password="centos"
)
_pxe_server = PxeServer(
    nfs_ip="", ssh_connection_details=_pxe_server_ssh_info
)

# FHGW information
_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1, _ru_2],
    pxe_server=_pxe_server,
)

# fhgw extra parameter configuration
_fhgw_0.ssh_username = "root"
_fhgw_0.ssh_password = "root"

# VDU global configuration
_vdu_0 = VDU(
    cloud_deployment=_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    # route configuration of f1m link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_m_ip_addr=NetworkAddress(
        v4="192.168.255.129",
        vlan_id=3470,
        routing_v4=RoutingInformation(gateway=""),
    ),
    # route configuration of f1c link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_c_ip_addr=NetworkAddress(
        v4="172.16.1.6",
        vlan_id=3498,
        routing_v4=RoutingInformation(gateway="172.16.1.1/24"),
    ),
    # route configuration of f1u link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_u_ip_addr=NetworkAddress(
        v4="172.16.1.7",
        vlan_id=3498,
        routing_v4=RoutingInformation(gateway="172.16.1.1/24"),
    ),
)

# route configuration of fhm link to airphone on VDU, no need ip, just fetch vlanid for iphy.xml configuration
_vdu_0.fhm_vlan_id = 2330

_vdu_1 = VDU(
    cloud_deployment=_k8s_cloud_deployment_du2,
    oam_http_connection_details=_vdu_oam_http_connection_details_du2,
    fhgws=[_fhgw_0],
    # route configuration of f1m link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_m_ip_addr=NetworkAddress(
        v4="192.168.255.130",
        vlan_id=3470,
        routing_v4=RoutingInformation(gateway="192.168.255.1/24"),
    ),
    # route configuration of f1c link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_c_ip_addr=NetworkAddress(
        v4="172.16.1.8",
        vlan_id=3498,
        routing_v4=RoutingInformation(gateway="192.168.101.1/24"),
    ),
    # route configuration of f1u link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_u_ip_addr=NetworkAddress(
        v4="172.16.1.9",
        vlan_id=3498,
        routing_v4=RoutingInformation(gateway="172.16.1.1/24"),
    ),
)

# route configuration of fhm link to airphone on VDU, no need ip, just fetch vlanid for iphy.xml configuration
_vdu_1.fhm_vlan_id = 2324

# mcc, mnc configuration
_realcore = RealCore(five_g=None, mcc="311", mnc="489", pdns=None)

# ######## start of NOM ######################################################
_nom_ssh_connection_edge0 = SshServiceDetails(
    addr="10.39.156.122", username="cloud-user"
)

_nom1 = NOM(
    ssh_connections_info=[_nom_ssh_connection_edge0],
    https_main_info=HttpConnectionDetails(
        addr="https://neo-hosting-page.srncnms04.srnblr.nsn-rdnet.net/",
        username="cnms04",
        password="Qwer_1234",
    ),
    https_user_mgmt_info=HttpConnectionDetails(
        addr="https://user-mgmt.srncnms04.srnblr.nsn-rdnet.net",
    ),
    https_rest_info=HttpConnectionDetails(
        addr="https://apigw.srncnms04.srnblr.nsn-rdnet.net",
    ),
)

_cnms = NMS(nom=_nom1)

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

# ssh connection information of OE, for tenant user
_vcu_ssh_connection_details = SshServiceDetails(
    addr="10.57.222.6", username="core", password="system123"
)
# ssh connection information of OE, for root user
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.57.222.6", username="core", password="system123", port="22"
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="tl726-new", master_node=_vcu_master_node)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vcu_intnet_1],
    vnfs=[_vcu_vnf_1],
    cloud_hosting=_vcu_k8s,
)

# VCU global configuration
_cbts_0 = CloudBts(
    dus=[_vdu_0, _vdu_1],  # vdu related parameter
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    # instance_id="",
    # global_bts_id="1",
)


_vlan1 = PreferredVlan(slot_id=SlotId.B1, port_id=1, preferred_vlan_id=2330)

_vlan2 = PreferredVlan(slot_id=SlotId.B2, port_id=1, preferred_vlan_id=2324)

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
                [
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                ],
                hardware_type="ASIL",
                # pdu_port=_pdus[0].pdu_ports[7],
            )
        ]
    ),
    preferred_vlans=[_vlan1, _vlan2],
)


# Testline configuration, tl is only variable which can be accessed by agent and test case
# you can access all parameters configured upper by tl parameter
tl = TestLine(
    test_pc=_test_pc,
    nms=_cnms,
    gnbs=[_cbts_0],
    enbs=[_real_enb],
    tl_cloud_topology="CLOUD_5GC_dR2.0_2vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD",
    ues=[_ue],
    cloud_hostings=[_ncir],
    test_pcs=[_enb_test_pc],
    core=_realcore,
)

# only tl variable can be accessed by user
__all__ = ["tl"]

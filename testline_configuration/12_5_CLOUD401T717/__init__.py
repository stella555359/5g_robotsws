__maintainer__ = "Zhang Qixuan"
__team__ = "I_NSB_MN_RAN_BOAM_RD_OM_OMUI_EIT <I_NSB_MN_RAN_BOAM_RD_OM_OMUI_EIT@internal.nsn.com>"
__email__ = "I_NSB_MN_RAN_BOAM_RD_OM_OMUI_EIT@internal.nsn.com"
__owner_email__ = "qixuan.zhang@nokia-sbell.com"

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
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline import DU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.attenuator import HBTE
from taf.config.testline.core import RealCore
from taf.config.testline.ue import Android, Qualcomm

######################VDU###########################
## following are VDU related class which defined
## in taf.config.testline
## you can uncomment them when new version of
## taf.config.testline merged
#######################VDU##########################
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.gnb.du import VDU
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.gnb.networkaddress import RoutingInformation
from taf.config.testline.radio import RU
from taf.config.testline.nms import NMS
from taf.config.testline.nom import NOM

# Following all parameters should be configured for one testline
# please don't ignore any parameters, you can add, but don't ingore
# any problem, please check with CI team

#####  FOLLOWING ARE CHECKLIST OF TESTLINE CONFIGURATION #######

#  1. 5gbts_ext_net.env have been configured as following
#  2. 5gbts_flavor.env have been configured as following
#  3. 5gbts_heat.env have been configured as following
#  4. aic-intnet-values-override_x.yaml have been configured as following
#  5. aic-vdu-values-override_x.yaml have been configured as following
#  6. user_config_x.yaml have been configured as following (currently, it's not used)
#  7. "vnf_prefix" in 5gbts_flavor.env should be re-configued, don't use common flavor name
#  8. vnf_prefix naming rule should be flavor-<testline name>, e.g: flavor-7_5_UTE5GAIC001T001
#  9. "flavors" in 5gbts_heat.env should be configured and prefix should equal to vnf_prefix value configured on 5gbts_flavor.env
#  10. please make sure 5gbts_ext_net.env, 5gbts_flavor.env, 5gbts_heat.env are new enough for next build
#  11. please make sure aic-intnet-values-override_x.yaml and aic-vdu-values-override_x.yaml are new enough for next build
#  12. please make sure files in step 1,2,3,4,5 have valid configuration
#  13. please make sure ip address of NCIR and test pc can be accessible by network
#  14. please make sure VDU on OE have been cleared or VDU helm release name is equal to name of DeploymentVnfStack before start agent_5g_aic
#  15. please make sure VCU on NCIR have been cleared or VCU stack name is TL_<testline name>_BTS before start agent_5g_aic
#################################################################


_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# this is test PC for AIC, including UTE IP address, User Name and Password.
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.209.172", username="ute", password="ute"
    )
)

# ######## start of vCU ##########################################################
# NCIR
_control = ControlNode(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.110.157.17", username="robot", password="rastre1"
    ),
    open_stack_connection_details=OpenStackConnectionDetails(
        username="robot",
        password="rastre1",
        ip_addr="10.110.157.17",
        tenant="robot",
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control], version="ncir_19")

# enb

# CloudBts deployment
flavor_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_flavor.env")]
net_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_ext_net.env")]
vnf_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_heat.env")]

_cbts_flavor = DeploymentFlavorStack(
    name="name is not used", env_files=flavor_env_files, default_vnf_prefix="hgz-tl5555"
)

_cbts_net = DeploymentNetworkStack(
    name="name is not used",
    env_files=net_env_files,
    yaml_file=os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="name is not used",
    env_files=vnf_env_files,
    yaml_file=os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_heat.yaml"),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)


_cu = CU(
    # CU web UI ip address, oam interface ip of oam vm
    # backhaul_site_oam_ip=NetworkAddress(v4="10.107.138.103"),
    backhaul_site_oam_ip=NetworkAddress(v4="10.107.138.103"),
    # VCU OAM ssh connection, oam interface ip of oam vm
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.110.157.17", username="robot", password="rastre1"
    ),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        #     addr="10.107.138.103", username="Nemuadmin", password="nemuuser", port="443"
        addr="10.110.157.17",
        username="Nemuadmin",
        password="nemuuser",
        port="443",
    ),
    # route configuration for x2 link to ENB, v4 is network address of ENB x2 link
    # x2c=NetworkAddress(
    #    v4="10.97.122.0",
    #    routing=RoutingInformation(gateway="10.110.101.1", ip_prefix_length=24),
    # ),
    # route configuration for f1c link to VDU on VCU, v4 is network address of VDU f1c link
    f1c=NetworkAddress(
        v4="10.106.231.152",
        routing=RoutingInformation(gateway="10.110.158.1", ip_prefix_length=29),
    ),
    # route configuration for f1u link to VDU on VCU, v4 is network address of VDU f1u link
    f1u=NetworkAddress(
        v4="10.106.231.152",
        routing=RoutingInformation(gateway="10.110.158.1", ip_prefix_length=29),
    ),
    s1u=NetworkAddress(
        v4="10.0.0.0",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.110.158.1", ip_prefix_length=28),
    ),
    tracing=None,
    global_bts_id=17,
)

# mcc, mnc configuration
_realcore = RealCore(five_g=None, mcc="262", mnc="03", pdns=None)


# ######## start of ENB #############################
_capacity_unit = CapacityUnit(addr="6.6.6.6")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
)

_airscale = Airscale(common_units=[_common_unit])

_real_enb = RealEnb(airscale=_airscale, oam_ip="2.2.2.2", global_bts_id="5254")

# you can configure it as AIC UTE environment
_enb_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="3.3.3.3", username="ute", password="ute"
    ),
    connections=[_real_enb],
)


# ######## start of vDU ######################################################
# VDU deployment

_vdu_vnf_1 = DeploymentVnfStack(
    name="vdu1",
    yaml_file=os.path.join(
        _cfg_dir,
        "DEP_SCF_FILES/CU_0/vDU_0/one_click_ne_deploy.yaml",
    ),
)

_vdu_intnet_0 = DeploymentNetworkStack(
    # this is intnet release name, the name should only be lower case and only can include alphabet, number,
    name="aic-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

_ssh_connection_details_0 = SshServiceDetails(
    addr="10.106.231.132", username="core", password="system123"
)
_k8s_connection_details_0 = K8SConnectionDetails(
    ip_addr="10.106.231.132", username="core", password="system123", port="22"
)

_master_node_0 = MasterNode(
    k8s_connection_details=_k8s_connection_details_0,
    ssh_connection_details=_ssh_connection_details_0,
)
_k8s_0 = K8S(namespace="cran1", master_node=_master_node_0)
_k8s_cloud_deployment_0 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_0],
    vnfs=[_vdu_vnf_1],
    cloud_hosting=_k8s_0,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.106.231.162", port="443", username="Nemuadmin", password="Nokia@123"
)
# RU configuration
# for cell 1,2 (PC 10.97.126.219)
_hbte_params_235 = {
    "ip_addr": "10.97.126.235",
    "port": 5000,
    "attenuation_port_numbers": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    "model": "PA-16-8-4-127-0.5-B-S",
    "version": None,
}
_attenuator_5G_235 = HBTE(**_hbte_params_235)

# RU configuration
_ru_1 = RU(
    ru_hw_group="RU_INT_CPRI",
    serial_number="1M212810183 ",
    attenuation_ports=[
        _attenuator_5G_235.attenuator_ports[7],
        _attenuator_5G_235.attenuator_ports[15],
    ],
)
_ru_2 = RU(
    ru_hw_group="RU_INT_CPRI",
    serial_number="1M212901952",
    attenuation_ports=[
        _attenuator_5G_235.attenuator_ports[8],
        _attenuator_5G_235.attenuator_ports[16],
    ],
)
_ru_3 = RU(
    ru_hw_group="RU_INT_CPRI",
    serial_number="1M211225071",
    attenuation_ports=[
        _attenuator_5G_235.attenuator_ports[8],
        _attenuator_5G_235.attenuator_ports[16],
    ],
)
# PXE server info for FHGW deployment
_pxe_server_ssh_info = SshServiceDetails(
    addr="10.71.160.156", username="root", password="centos"
)
_pxe_server = PxeServer(
    nfs_ip="10.71.160.156", ssh_connection_details=_pxe_server_ssh_info
)

# FHGW information
_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_3.yaml"
    ),
    rus=[_ru_1],
    pxe_server=_pxe_server,
)
_vdu_0 = VDU(
    cloud_deployment=_k8s_cloud_deployment_0,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    # route configuration of f1m link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_m_ip_addr=NetworkAddress(
        v4="10.110.158.0",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.231.161", ip_prefix_length=28),
    ),
    # route configuration of f1c link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_c_ip_addr=NetworkAddress(
        v4="10.110.158.0",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.231.153", ip_prefix_length=24),
    ),
    # route configuration of f1u link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_u_ip_addr=NetworkAddress(
        v4="10.110.158.0",  # v4="10.110.138.128",#
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.231.153", ip_prefix_length=24),
    ),
    instance_id=17,
)

_appserver_ssh = SshServiceDetails(
    addr="1.1.1.1", username="ute", password="QAZqaz123!@#"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="1.1.1.1",
    iperf_path="/usr/bin/iperf",
)
_android = Android(
    ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="aic", password="Nokia123!"
    ),
    serial_number="R5CR414H3QN",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "samsung"],
)


# ######## start of NOM ######################################################
_nom_ssh_connection_edge0 = SshServiceDetails(addr="2.2.2.2", username="cloud-user")

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
    neo_endpoints_ip="2.2.2.2",
)

_cnms = NMS(addr="2.2.2.2", nom=_nom1)

_vcu_intnet_1 = DeploymentNetworkStack(
    name="aic-vcu-pre",
    yaml_file=os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/values-override-pre.yaml"),
)

_vcu_vnf_1 = DeploymentVnfStack(
    name="aic-vcu-cnf",
    yaml_file=os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/values-override-vcu.yaml"),
)


# ssh connection information of OE, for tenant user
_vcu_ssh_connection_details = SshServiceDetails(
    addr="10.68.93.76", username="core", password="ute/systeM!23456"
)
# ssh connection information of OE, for root user
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.68.93.76", username="core", password="ute/systeM!23456", port="22"
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran2", master_node=_vcu_master_node)
_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vcu_intnet_1],
    vnfs=[_vcu_vnf_1],
    cloud_hosting=_vcu_k8s,
)


# VCU global configuration
_cbts = CloudBts(
    dus=[_vdu_0],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    instance_id="17",
    global_bts_id="17",
)


_tools_repository = {
    "ip": "1.1.1.1",
    "username": "ute",
    "password": "ute",
    "repo_tool_folder": "/opt/tools/trans_test/",
    "repo_data_folder": "/opt/tools/trans_data/",
    "repo_simu4trs_folder": "/opt/tools/trans_simu4trs/",
}

# Testline configuration, tl is only variable which can be accessed by agent and test case
# you can access all parameters configured upper by tl parameter
tl = TestLine(
    test_pc=_test_pc,
    nms=_cnms,
    attenuators=[_attenuator_5G_235],
    gnbs=[_cbts],
    enbs=[_real_enb],
    tl_cloud_topology="CLOUD_5G_AIC_OCP_OCP_FHGW_AEQP",
    cloud_hostings=[_ncir],
    test_pcs=[_enb_test_pc],
    ues=[_android],
    core=_realcore,
)

# it's a WA, please see https://jira3.int.net.nokia.com/browse/TALIB-846,
# this jira has blocked a few transport TA cases design and debug
# one of other WA is declare a global python variable, 'TRANS_PARA = _trans_para'
# i don't know which WA is better, please give me suggestion if you like to change WA.


__all__ = ["tl"]

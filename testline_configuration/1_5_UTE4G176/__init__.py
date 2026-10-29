__maintainer__ = "Di, Zheng"
__email__ = "zheng.di@nokia-sbell.com"

import os
import yaml

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
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, FPFH
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import HBTE
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.pdu import TopYoung as TP
from taf.config.testline.core import RealCore
from taf.config.testline.ue import Android, Qualcomm
from taf.config.testline.nms import NMS
from taf.config.testline.nom import NOM
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.gnb.du import VDU
from taf.config.testline.cloud_hosting import MasterNode, K8S, HelmChart
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNTafUeAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import TafUeAndroid

# Following mandatory files and parameters should be configured
# Please don't ignore any parameters, you can add, but don't ingore
# Any problem, please check with CI team

#####  FOLLOWING ARE CHECKLIST OF TESTLINE CONFIGURATION #######

#  1. 5gbts_ext_net.env have been configured as following
#  2. 5gbts_flavor.env have been configured as following
#  3. 5gbts_heat.env have been configured as following
#  4. aic-intnet-values-override_${vdu_index}.yaml (vdu_index should start from 0) have been configured as following
#  5. aic-vdu-values-override_${vdu_index}.yaml (vdu_index should start from 0) have been configured as following
#  6. user_config_${fhgw_index}.yaml (fhgw_index should start from 0) have been configured as following (currently, it's not used)
#  7. "vnf_prefix" in 5gbts_flavor.env should be re-configued, don't use common flavor name
#  8. vnf_prefix naming rule should be flavor-<testline name>, e.g: flavor-7_5_UTE5GAIC001T037
#  9. "flavors" in 5gbts_heat.env should be configured and prefix should equal to vnf_prefix value configured on 5gbts_flavor.env
#  10. please make sure 5gbts_ext_net.env, 5gbts_flavor.env, 5gbts_heat.env are new enough for next build
#  11. please make sure aic-intnet-values-override_x.yaml and aic-vdu-values-override_x.yaml are new enough for next build
#  12. please make sure files in step 1,2,3,4,5 have valid configuration
#  13. please make sure ip address of NCIR and test pc can be accessible by network
#  14. please make sure VDU on OE have been cleared or VDU helm release name is equal to name of DeploymentVnfStack before start agent_5g_aic
#  15. please make sure VCU on NCIR have been cleared or VCU stack name is TL_<testline name>_BTS before start agent_5g_aic
#  16. please check nom mo configured
#################################################################


_cfg_dir = os.path.dirname(os.path.abspath(__file__))


_pdu_1 = FPFH(addr="10.108.161.12", port_numbers=[1, 6])

########### Part 3: gnbs ##################################
# VDU related NCIR controlNode
_control1 = ControlNode(
    # Configuration for SSH access
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.213.50", username="cranuser1", password="systeM!23"
    ),
    # Configuration for openstack connection
    open_stack_connection_details=OpenStackConnectionDetails(
        username="cranuser1",
        password="systeM!23",
        ip_addr="10.56.213.50",
        tenant="cran1",
    ),
    # Configuration of BMC connection, if you need use it in test case, plase config it
    # currently, it's not used in agent
    bmc_connection_details=BmcConnectionDetails(
        addr="10.56.213.18", username="admin", password="NokiaOE22-VDUvdu"
    ),
)

# configuration of VCU related NCIR/OSP
_ncir = NCIR(compute_nodes=[], control_nodes=[_control1], version="OE22")

# CloudBts deployment
# flavor of VCU
flavor_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_flavor.env")]

# ext_net of VCU
net_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_ext_net.env")]

# heat parameters
vnf_env_files = [os.path.join(_cfg_dir, "DEP_SCF_FILES/CU_0/5gbts_heat.env")]

_cbts_flavor = DeploymentFlavorStack(
    name="name is not used",  # this name is not used, you need NOT configure it, let it be
    env_files=flavor_env_files,
    default_vnf_prefix="hgz-tl4444",
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


# #################### START of VCU CNF platform ##########################
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
    addr="10.107.99.210", username="cranuser9", password="systeM!23"
)
# VCU_1 ssh connection information of OE, for root user
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.107.99.210",
    username="core",
    #    password="VCU@nokia123",
    password="system123",
    port="22",
    #    ip_addr="10.107.14.66",
    #    username="cranuser9",
    #    password="systeM!23",
    #    port="22",
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran9", master_node=_vcu_master_node)

_cluster_preparation_cu_1 = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, "vcu-cluster-preparation.yaml"),
)

_prerequisite_cu_1 = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vcu-prerequisite.yaml"),
)

_cnf_cu_1 = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, "vcu-cnf.yaml"),
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vcu_intnet_1],
    cluster_preparation=_cluster_preparation_cu_1,
    prerequisite=_prerequisite_cu_1,
    cnf=_cnf_cu_1,
    vnfs=[_vcu_vnf_1],
    cloud_hosting=_vcu_k8s,
)

# #################### End of VCU CNF platform ##########################
# CU configuration
_cu = CU(
    # CU web UI ip address, oam interface ip of oam vm
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.107.205.76"
        # v6='2a00:8a00:8000:136:10:57:159:1111'
    ),
    # VCU OAM ssh connection, oam interface ip of oam vm
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.107.205.76", username="Nemuadmin", password="nemuuser"
    ),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.107.205.76", username="Nemuadmin", password="nemuuser", port="443"
    ),
    # route configuration for x2 link to ENB, v4 is network address of ENB x2 link
    x2c=NetworkAddress(
        v4="10.107.205.204",
        vlan_id=109,
        routing=RoutingInformation(gateway="10.107.205.193", ip_prefix_length=27),
    ),
    # route configuration for f1c link to VDU on VCU, v4 is network address of VDU f1c link
    f1c=NetworkAddress(
        v4="10.107.204.12",
        vlan_id=100,
        routing=RoutingInformation(gateway="10.107.204.1", ip_prefix_length=26),
    ),
    # route configuration for f1u link to VDU on VCU, v4 is network address of VDU f1u link
    f1u=NetworkAddress(
        v4="10.107.204.74",
        vlan_id=101,
        routing=RoutingInformation(gateway="10.107.204.65", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.107.206.12",
        vlan_id=111,
        routing=RoutingInformation(gateway="10.107.206.1", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.107.205.236",
        vlan_id=110,
        routing=RoutingInformation(gateway="10.107.205.225", ip_prefix_length=27),
    ),
    tracing=None,
    global_bts_id="37025",
)

# mcc, mnc configuration
_realcore = RealCore(five_g=None, mcc="262", mnc="03", pdns=None)

# VDU configuration for deployment
_vdu_vnf_0 = DeploymentVnfStack(
    #    name="vdutest",  # this is vdu release name, the name should only be lower case and only can include alphabet, number, _
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)
# _vdu_vnf_1 = DeploymentVnfStack(
#    name="aic-vdu-1",  # this is vdu release name, the name should only be lower case and only can include alphabet, number, _
#    yaml_file=os.path.join(
#        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_1/aic_vdu_values_override_0.yaml"
#    ),
# )
# VDU internal network configuration for deployment
_vdu_intnet_0 = DeploymentNetworkStack(
    name="aic-intnet",  # this is intnet release name, the name should only be lower case and only can include alphabet, number, _
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)
# _vdu_intnet_1 = DeploymentNetworkStack(
#    name="aic-intnet",  # this is intnet release name, the name should only be lower case and only can include alphabet, number, _
#    yaml_file=os.path.join(
#        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_1/aic_intnet_values_override_0.yaml"
#    ),
# )

# ssh connection information of OE, for tenant user
_ssh_connection_details_0 = SshServiceDetails(
    addr="10.56.213.50", username="cranuser1", password="systeM!23"
)

# ssh connection information of OE, for cloudadmin user
_k8s_connection_details_0 = K8SConnectionDetails(
    ip_addr="10.56.213.50",
    username="core",
    password="system123",
    port="22",
    #    ip_addr="10.56.213.50",
    #    username="cranuser1",
    #    password="systeM!23",
    #    port="22",
)

# master node information of OE
_master_node_0 = MasterNode(
    k8s_connection_details=_k8s_connection_details_0,
    ssh_connection_details=_ssh_connection_details_0,
)

_k8s_0 = K8S(namespace="cran1", master_node=_master_node_0)

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, "vdu-cluster-preparation.yaml"),
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vdu-prerequisite.yaml"),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, "vdu-cnf.yaml"),
)

# VDU deployment configuration
_k8s_cloud_deployment_0 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_0],
    vnfs=[_vdu_vnf_0],
    cloud_hosting=_k8s_0,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

# VDU oam http connection
_vdu_oam_http_connection_details_0 = HttpConnectionDetails(
    addr="10.56.213.82", port="443", username="Nemuadmin", password="nemuuser"
)

# RU configuration
_ru_1 = RU(
    ru_hw_group="RU_INT_ECPRI",
    radio_type="AZQG",
    serial_number="EA193671559",
    pdu_port=_pdu_1.pdu_ports[1],
)
_ru_2 = RU(
    ru_hw_group="RU_INT_ECPRI",
    radio_type="AEQE",
    serial_number="1M204603364",
    pdu_port=_pdu_1.pdu_ports[6],
)


# PXE server info for FHGW deployment
# _pxe_server_ssh_info = SshServiceDetails(
#    addr="10.56.210.30", username="ute", password="Ut3pa5s#ff97"
# )
# _pxe_server = PxeServer(
#    nfs_ip="10.56.210.30", ssh_connection_details=_pxe_server_ssh_info
# )

# FHGW information
# _fhgw_0 = FHGW(
#    user_config_path=os.path.join(
#        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
#    ),
#    rus=[_ru_1, _ru_2],
#    pxe_server=_pxe_server,
# )


# fhgw extra parameter configuration
# _fhgw_0.ssh_username = "toor4nsn"
# _fhgw_0.ssh_password = "Fhgw@nokia123"


# VDU global configuration
_vdu_0 = VDU(
    cloud_deployment=_k8s_cloud_deployment_0,
    oam_http_connection_details=_vdu_oam_http_connection_details_0,
    rus=[_ru_1, _ru_2],
    #    fhgws=[_fhgw_0],
    # route configuration of f1m link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_m_ip_addr=NetworkAddress(
        v4="10.56.213.82",
        vlan_id=616,
        routing=RoutingInformation(gateway="10.56.213.81", ip_prefix_length=29),
    ),
    # route configuration of f1c link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_c_ip_addr=NetworkAddress(
        v4="10.56.213.74",
        vlan_id=615,
        routing=RoutingInformation(gateway="10.56.213.73", ip_prefix_length=26),
    ),
    # route configuration of f1u link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_u_ip_addr=NetworkAddress(
        v4="10.56.213.75",
        vlan_id=615,
        routing=RoutingInformation(gateway="10.56.213.73", ip_prefix_length=25),
    ),
    instance_id=37025,
    global_bts_id=37025,
)


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
    neo_endpoints_ip="10.39.156.88",
)

_cnms = NMS(addr="10.39.156.122", nom=_nom1)


# VCU global configuration
_cbts_0 = CloudBts(
    dus=[_vdu_0],  # vdu related parameter
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    instance_id="37025",
    global_bts_id="37025",
)

########### Part 4: UE ####################################
#  iperf server info
_appserver_ssh = SshServiceDetails(
    addr="10.108.229.121", username="ute", password="ute"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.106.243.149",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="54015",
)

Qualcomm8250 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.83.10", username="csv1-tester", password="Nokia123!"
    ),
    serial_number="7TD5T21427006286",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python36/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei1"],
)
########### Part 9: Appserver #############################
_appserver = AppServer(_iperf)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.69.64.197",
    user="tdlte-tester",
    password="btstest",
    bind_interface_ip="10.69.64.196",
    expected_prompt="~]$",
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
)  # OPTIONAL

_data_transfer_ping = TafUeDataTransferProtocol(
    protocol_name="ping", app_server=_app_server_1, interval=1
)

_data_transfer_ftp = TafUeDataTransferProtocol(
    protocol_name="ftp", app_server=_app_server_1, interval=1
)

_pdn1 = PDNTafUeAndroidDetails(
    entryName="stdata1", apnName="stdata1", apnType=["DEFAULT"]
)


_android1 = TafUeAndroid(
    serial_number="UQG5T20730008589",
    capabilities=["REAL_UE"],
    ue_pc_address="10.106.230.9",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.106.230.9", username="siso2-tester", password="Nokia123!"
    ),
    phone_number="+358480500013",
    ue_pc_port="8080",
    imei="12345678912345",
    imsi="260123456789",
    pdns=[_pdn1],
    # qualcomm_prototype=True,
    # service_call_attach='16',
    # service_call_detach='16',
    # network_mode_switch_method='ADB',
    # airplane_mode_switcher_text='Airplane',
    # airplane_mode_confirm_button_text='OK',
    # path_to_network_mode_type='Mobile networks/Preferred network type',
    # secret_code='*#*#4636#*#*',
    # is_rooted='no',
    # voice_call_technology='2G',
    # voice_call_technology_timeout=60.0,
    # voice_call_dialing_timeout=-1.0
)
########### Main: Testline configuration ##################

# UTE IP address and User Name, Password,
# this is test PC for AIC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.252.120", username="ute", password="ute"
    ),
    connections=[_cbts_0],
)

# Testline configuration, tl is only variable which can be accessed by agent and test case
# you can access all parameters configured upper by tl parameter
tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_ncir],
    gnbs=[_cbts_0],
    #    ues=[Qualcomm8250],
    ues=[_android1],
    tl_cloud_topology="CLOUD_5G_AIC_SA_1XvDU_OE22_AEQE_AZQG",
    core=_realcore,
    nms=_cnms,
    appserver=_appserver,
)

# only tl variable can be accessed by user
__all__ = ["tl"]

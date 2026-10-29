__maintainer__ = "Zhan yangjun"
__team__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_4_GMS "
__email__ = "i_nsb_mn_ran_rd_vrf_haz1_4@internal.nsn.com"
__owner_email__ = "yangjun.zhan@nokia-sbell.com"

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
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import HBTE
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.pdu import TopYoung as TP
from taf.config.testline.core import RealCore
from taf.config.testline.ue import Android, Qualcomm
from taf.config.testline.nms import NMS
from taf.config.testline.nom import NOM

######################VDU###########################
## following are VDU related class which defined
## in taf.config.testline
## you can uncomment them when new version of
## taf.config.testline merged
#######################VDU##########################
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.gnb.du import VDU
from taf.config.testline.cloud_hosting import MasterNode, K8S, HelmChart
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU


_cfg_dir = os.path.dirname(os.path.abspath(__file__))


########### Part 2: cloud_hostings ########################
# VDU related NCIR controlNode
_control = ControlNode(
    # configuration for ssh connecting to OE
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.163.34", username="core", password="system123"
    ),
    # configuration for connection of open stack UI, default port is 5000
    open_stack_connection_details=OpenStackConnectionDetails(
        username="core",
        password="system123",
        ip_addr="10.68.163.34",
        tenant="cran1",
    ),
    # BMC configuration of OE
    bmc_connection_details=BmcConnectionDetails(
        addr="10.68.163.2", username="admin", password="CNnokia123_nokia"    ## former info:'cmb9.admin'--xk
    ),
)

# configuration of VCU related NCIR/OSP
_ncir = NCIR(compute_nodes=[], control_nodes=[_control], version="HPE")

########### Part 6: attenuator ############################
_hbte_params = {
    "ip_addr": "10.56.107.207",
    "port": 5000,
    "attenuation_port_numbers": [1, 2, 3, 4, 5, 6, 7, 8],
    "model": "TAS16T16-0.2G6-120-0.5S -DES",    ##model?--xk
    "version": None,
}
_attenuator_5G = HBTE(**_hbte_params)

########### Part 3: gnbs ##################################
# RU configuration
_ru_pdu = TP(addr="10.56.107.208", port_numbers=[1, 2, 3, 4, 5, 6])

_ru_1 = RU(
    ru_hw_group="RU_INT_ECPRI",
    radio_type="AZQJ",
    serial_number="1M203905777",
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[1],
        _attenuator_5G.attenuator_ports[2],
        _attenuator_5G.attenuator_ports[3],
        _attenuator_5G.attenuator_ports[4],
        _attenuator_5G.attenuator_ports[5],
        _attenuator_5G.attenuator_ports[6],
        _attenuator_5G.attenuator_ports[7],
        _attenuator_5G.attenuator_ports[8],
    ],
    pdu_port=_ru_pdu.pdu_ports[1]
)
_ru_2 = RU(
    ru_hw_group="RU_INT_ECPRI",
    radio_type="AZQJ",
    serial_number="1M234905260",
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[1],
        _attenuator_5G.attenuator_ports[2],
        _attenuator_5G.attenuator_ports[3],
        _attenuator_5G.attenuator_ports[4],
        _attenuator_5G.attenuator_ports[5],
        _attenuator_5G.attenuator_ports[6],
        _attenuator_5G.attenuator_ports[7],
        _attenuator_5G.attenuator_ports[8],
    ],
    pdu_port=_ru_pdu.pdu_ports[2]
)

# PXE server info for FHGW deployment
_pxe_server_ssh_info = SshServiceDetails(
    addr="10.56.107.206", username="ute", password="qazQAZ123!@#"
)
_pxe_server = PxeServer(
    nfs_ip="10.56.107.206", ssh_connection_details=_pxe_server_ssh_info
)

# VDU configuration for deployment
_vdu_vnf_0 = DeploymentVnfStack(
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

# VDU internal network configuration for deployment
_vdu_intnet_0 = DeploymentNetworkStack(
    name="aic-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

# ssh connection information of OE, for tenant user
_ssh_connection_details = SshServiceDetails(
    addr="10.68.163.34", username="core", password="system123"
)
# ssh connection information of OE, for cloudadmin user
_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.68.163.34", username="core", password="system123", port="22"
)
# master node information of OE
_master_node = MasterNode(
    k8s_connection_details=_k8s_connection_details,
    ssh_connection_details=_ssh_connection_details,
)

_k8s = K8S(namespace="cran1", master_node=_master_node)

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cluster-preparation.yaml'),
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vdu-prerequisite.yaml'),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cnf.yaml'),
)

# VDU deployment configuration
_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_0],
    vnfs=[_vdu_vnf_0],
    cloud_hosting=_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

# VDU oam http connection
_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.68.163.66", port="443", username="Nemuadmin", password="nemuuser"
)


# FHGW information
_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1],
    pxe_server=_pxe_server,
)

# fhgw extra parameter configuration
_fhgw_0.ssh_username = "toor4nsn"
_fhgw_0.ssh_password = "Fhgw@nokia123!"

# VDU global configuration
_vdu_0 = VDU(
    cloud_deployment=_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    # route configuration of f1m link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_m_ip_addr=NetworkAddress(
        v4="192.168.254.33",
        vlan_id=295,
        routing=RoutingInformation(gateway="192.168.254.34", ip_prefix_length=26),
    ),
    # route configuration of f1c link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_c_ip_addr=NetworkAddress(
        v4="10.68.163.58",
        vlan_id=115,
        routing=RoutingInformation(gateway="10.68.163.57", ip_prefix_length=29),
    ),
    # route configuration of f1u link to VCU on VDU, v4 is VCU fronthaul port network address
    f1_u_ip_addr=NetworkAddress(
        v4="10.68.163.59",
        vlan_id=115,
        routing=RoutingInformation(gateway="10.68.163.57", ip_prefix_length=29),
    ),
    instance_id=5467,
)

# VCU configuration ************************TBD Lance
_cu = CU(
    # CU web UI ip address, oam interface ip of oam vm
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.107.104.166"
        # v6='2a00:8a00:8000:136:10:57:159:1111'
    ),
    # VCU OAM ssh connection, oam interface ip of oam vm
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.107.104.166", username="Nemuadmin", password="Nokia@123"
    ),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.107.104.166", username="Nemuadmin", password="Nokia@123", port="443"
    ),
    # route configuration for x2 link to ENB on VCU, v4 is network address of ENB x2 link
    x2c=NetworkAddress(
        v4="10.107.104.230",
        vlan_id=2002,
        routing=RoutingInformation(gateway="10.107.104.225", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.107.106.142",
        vlan_id=2003,
        routing=RoutingInformation(gateway="10.107.106.129", ip_prefix_length=27),
    ),
    # route configuration for f1c link to VDU on VCU, v4 is network address of VDU f1c link
    f1c=NetworkAddress(
        v4="10.107.104.38",
        vlan_id=2000,
        routing=RoutingInformation(gateway="10.107.104.33", ip_prefix_length=27),
    ),
    # route configuration for f1u link to VDU on VCU, v4 is network address of VDU f1u link
    f1u=NetworkAddress(
        v4="10.107.104.78",
        vlan_id=2001,
        routing=RoutingInformation(gateway="10.107.104.65", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.107.106.206",
        vlan_id=2006,
        routing=RoutingInformation(gateway="10.107.106.193", ip_prefix_length=27),
    ),
    tracing=None,
)

# k8s information
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
    addr="10.107.123.2", username="cranuser5", password="systeM!23"
)
# ssh connection information of OE, for root user
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.107.123.2", username="core", password="system123", port="22"
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)
_vcu_k8s = K8S(namespace="cran5", master_node=_vcu_master_node)

_cluster_preparation_cu_1 = HelmChart(
  name = "aic-vcu-cluster-preparation",
  yaml_file = os.path.join(_cfg_dir, 'vcu-cluster-preparation.yaml'),
)

_prerequisite_cu_1 = HelmChart(
  name = "aic-vcu-prerequisite",
  yaml_file = os.path.join(_cfg_dir, 'vcu-prerequisite.yaml'),
)

_cnf_cu_1 = HelmChart(
  name = "aic-vcu",
  yaml_file = os.path.join(_cfg_dir, 'vcu-cnf.yaml'),
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

_cbts = CloudBts(
    dus=[_vdu_0],  # vdu related parameter
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="hgz-37355",
    instance_id="37355",
    global_bts_id="37355",
)


########### Part 1: Testpc ################################
# UTE IP address and User Name, Password
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.97.65.249", username="ute", password="ute"
    ),
    connections=[_cbts]
)



########### Part 4: UE ####################################
#  iperf server info
_appserver_ssh = SshServiceDetails(
    addr="10.108.230.92", username="ute", password="uteUTE!"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.106.243.149",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="54015",
)

huawei1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.66.143", username="noklab\csv5-tester", password="Nokia123!"
    ),
    serial_number="3777b956",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "xiaomi"],
)

########### Part 7: CoreNetwork TBD Lance #################
# mcc, mnc configuration
_realcore = RealCore(five_g=None, mcc="262", mnc="03", pdns=None)

########### Part 8: NMS TBD Lance #########################
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

########### Part 9: Appserver #############################
_appserver = AppServer(_iperf)

########### Main: Testline configuration ##################
tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_ncir],
    gnbs=[_cbts],
    ues=[huawei1],
    tl_cloud_topology="CLOUD_5G_AIC_SA_1xAndroid_1xvDU_OE22_1xFHGW_2xAZQJ",
    attenuator=_attenuator_5G,
    core=_realcore,
    nms=_cnms,
    appserver=_appserver,
)

# only tl variable can be accessed by user

__all__ = ["tl"]

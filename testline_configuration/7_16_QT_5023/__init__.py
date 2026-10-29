__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"
__owner_email__ = "I_5GQT_WRO@internal.nsn.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.core import EPCSim
from taf.config.testline.cloud_hosting import (
    ControlNode,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    CloudDeployment,
)
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.core import RealCore
from taf.config.testline.gnb.du import VDU
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.gnb.du import RANNIC
from taf.config.testline.pdu import HBTE, PduPort, ATEN, Gude
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.cloud_hosting import MasterNode, K8S, ComputeNode
from taf.config.testline.testline import TestLine
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb.gnb import CloudBts, CU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import Android
from taf.config.testline.enb import (
    Enb,
    RealEnb,
)
from taf.config.testline.radio import RU
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import TopYoung
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAt

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.76", username="ute", password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.42.194.76", username="ute", password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.45.168.53",
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue = TafUeAppServer(
    app_server_name="APP_TAF_UE",
    address="10.45.168.53",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.45.168.53",
    expected_prompt="qt5g@wl-srn-server-1-idf34",
)

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue,
                                                 interval=1,
                                                 binary_path="/cygdrive/c/iperf/",
                                                 version=2,
                                                 interface_name='ASKEY_5023',
                                                 dt_from_uepc=True)


# ####################### start of vCU ##################################
# cloud_deployment for vCU
_vcu_cnf_1 = DeploymentVnfStack(
# this is vcu release name, the name should only be lower case and only can include alphabet number,
    name="vcutest",
)
_vcu_intnet_1 = DeploymentNetworkStack(
# this is vcu pvc release name, the name should only be lower case and only can include alphabet number,
    name="pvc-vcutest",
)

# ssh connection information of OE, for tenant user
_vcu_ssh_connection_details = SshServiceDetails(
    addr="10.44.68.90", username="core", password="system123", port=22
)

# ssh connection information of OE
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.68.90", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)
_vcu_k8s = K8S(namespace="cu5023", master_node=_vcu_master_node)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vcu_intnet_1],
    vnfs=[_vcu_cnf_1],
    cloud_hosting=_vcu_k8s,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.68.79"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.68.90", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.68.79", port=443
    ),
)
# ####################### end of vCU ##################################

#  ####################### start of vDU ###############################
# VDU deployment
_ssh_connection_details_0 = SshServiceDetails(
    addr="10.44.79.244", username="core", password="system123"
)

_k8s_connection_details_0 = K8SConnectionDetails(
    ip_addr="10.44.79.244", username="core", password="system123", port="22"
)

_master_node_0 = MasterNode(
    k8s_connection_details=_k8s_connection_details_0,
    ssh_connection_details=_ssh_connection_details_0,
)

_k8s_0 = K8S(namespace="cran1", master_node=_master_node_0)
_vdu_vnf_0 = DeploymentVnfStack(
    # this is vdu release name, the name should only be lower case and only can include alphabet number,
    name="aic-vdu"
)

_vdu_intnet_0 = DeploymentNetworkStack(
    # this is pvc release name, the name should only be lower case and only can include alphabet number,
    name="aic-vdu-prerequisite"
)

_k8s_cloud_deployment_0 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_0],
    vnfs=[_vdu_vnf_0],
    cloud_hosting=_k8s_0,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.44.79.200", port="443"
)

_ru_1 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="serviceuser", password="bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4="
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.34", username="serviceuser", password="bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4="
    ),
)
_ru_1.length = "1"

# rannic information
_rannic_0 = RANNIC(rus=[_ru_1])

_vdu_0 = VDU(
    cloud_deployment=_k8s_cloud_deployment_0,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    rannics=[_rannic_0],
)
_vdu_0.du_pods = {'oamcm': 'oamcm', 'oamconfig': 'oamconfig'}
# ####################### end of vDU ###############################

# ####################### override yaml definition ###############################
_vdu_0.du_cnf_yaml = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/DU_cnf_values-override.yaml"
)

_vdu_0.du_pvc_yaml = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/DU_pvc_values-override.yaml"
)

_cu.cu_cnf_yaml = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/CU_cnf_values-override.yaml"
)
_cu.cu_pvc_yaml = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/CU_pvc_values-override.yaml"
)

_vcu_k8s_cloud_deployment.cnf_override_dir = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/cnf_values-override.yaml"
)

_vcu_k8s_cloud_deployment.pvc_override_dir = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/pvc_values-override.yaml"
)

_vcu_k8s_cloud_deployment.cnf_conversion_dir = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/cnf_values-override_converted.yaml"
)

_vcu_k8s_cloud_deployment.pvc_conversion_dir = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/pvc_values-override_converted.yaml"
)
# ####################### end of override yaml definition ###############################

_cbts = CloudBts(
    dus=[_vdu_0],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="5023",
)

_epcsim = EPCSim(
    mme_ip="10.45.168.53",
    mcc=540,
    mnc=1,
    tac=7151,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.168.53", username="qt5g", password="5Gqtmoth!"
    ),
    dir_path="/home/ute/Robot_LteEmu",
    cfg_filename="Robot_LteEmu_Config",
)

_askey = TafUeAt(com_port='3', #Visible in ue_proxy when checking for available devices
                 serial_number="c40d6151", #visible in ADB
                 capabilities=['_5G'], #capabilities that are testd on the specific TL
                 ue_pc_address='10.42.224.157', #UEPC Addr
                 ue_pc_login='wro5gqt', #UEPC login
                 ue_pc_password='5Gqtmoth', #UEPC password
                 proxy_mngr_port='80', #proxy mngr port, defined in the preparing uepc with proxy mngr section
                 ueproxy_force_release=False, #Keep this FALSE so that it does not collide with healthchecker
                 ue_pc_expected_prompt='wro5gqt@PLWR5G5320', #ssh to the UEPC after installing cygwin
                 data_transfer=[_data_transfer_iperf], #This is the same for all QT Tls
                 )
_askey.ue_type = "askey"

_attenuator = TopYoung(
    ip_addr="10.42.61.181",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_04G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_test_pc,
    ues=[_askey],
    gnbs=[_cbts],
    core=_epcsim,
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="5023",
)

tl.target_traffic_5G = {
    "MIN_DL": "240", #Mbits/sec
    "MIN_UL": "24", #Mbits/sec
    "MAX_DL": "300", #Mbits/sec
    "MAX_UL": "30", #Mbits/sec
    "IPERF_DURATION": "180", #seconds
    "cell_id_rf1": "870367233"
}

tl.custom = {
    "real_enb": "False",  # True if TL connected to LTE eNB
    "standalone": "True",  # True if SA, False for NSA
    "has_real_core": "True",  # True if TL not using EPCSim
    "askey_pdu_ip": "10.44.177.234",
    "askey_pdu_port": "6",
}

tl.attenuation = {
    "attenuation_5G": {19: 10, 20: 10},
    "attenuation_index": {"att":0},
    "pdu_model": "gude",
    "pdu_attenuator_version": "8221-1",
    "pdu_attenuator_ip": "10.44.177.234",
    "pdu_attenuator_port": "1",
}

tl.custom_vDU = {
    "du_scf": "SCF_TDD_eCPRI_vDU_AEQP_5023.xml",
    "du_webui_ip": "10.44.79.200",
    "du_k8s_addr": "10.44.79.244",
    "du_k8s_user": "core",
    "du_k8s_pwd": "system123",
    "du_k8s_port": "22",
    "du_tenant": "cran1",
    "du_cnfname": "aic-vdu",
    "du_pvcname": "aic-vdu-prerequisite",
    "du_netname": "tn-intnet-int",
    "du_aic_net_dir": "ocp-intnet",
    "du_aic_pvc_dir": "ocp-pvc",
    "fhgw_ip": "10.42.75.162",
    "fhgw_username": "toor4nsn",
    "fhgw_password": "Fhgw@nokia123$",
    "vdu_index": "0",
    "cu_aic_net_dir": "aic-intent",
    "l2rt_app": "l2rt",
    "pwr1_command": "/usr/bin/dapd -pwr 0",
    "pwr2_command": "/usr/bin/dapd -pwr 1",
    "is_tdd_tl": "True",
    "fhgw_version": "24R1",
    "oe_version_check": "OE20",
}

tl.custom_vCU = {
    "cu_scf": "SCF_TDD_eCPRI_CU_5023.xml",
    "cu_pvcname": "vcutest",
    "cu_webui_ip": "10.44.68.79",
    "cu_k8s_addr": "10.44.69.137",
    "cu_k8s_port": "22",
    "cu_k8s_user": "core",
    "cu_k8s_pwd": "system123",
    "cu_tenant": "cu5023",
    "cu_pvcname": "pvc-vcutest",
    "cu_cnfname": "vcutest",
    "cu_netname": "net-vcutest",
    "cu_rbacname": "rbac-vcutest",
    "rus_length": "1",
    "install_flag": "True",
    "certificate_flag": "False",
    "cloudknife_flag": "False",
    "cu_aic_net_dir": "aic-vcu-network",
    "cu_aic_pvc_dir": "aic-vcu-pvc",
    "cu_aic_cnf_dir": "aic-vcu-cnf",
    "cu_aic_rbac_dir": "aic-vcu-rbac",
    "cu_net_device": "ens12f1"
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

tl.du_scf_variables = {
    "mrbts": 53123,
    "nrbts": 53123,
    "btsName": "vDU23_5023",
    
    "rnic_productCode": "AF1791.M01",
    "rnic_serialNumber": "L1233907170",
    "rmod_productCode": "475238A.102",
    "rmod_serialNumber": "1M213805696",
    "pmax": "260",

    "mcc": "540",
    "mnc": "1",
    "mncLength": "2",
    "physCellId": "323",
    "fivegstac": "7151",

    "oam_certman_server_tracecontroller": "172.16.4.2",
    "oam_destIpAddr_1": "10.44.79.192",
    "oam_destIpAddr_2": "172.16.4.0",
    "destinationipprefixlength_oam": "28",

    "f1c_vdu_IpAddrAllocated": "10.44.147.57",
    "f1u_vdu_IpAddrAllocated": "10.44.147.58",
    "f1c_vcu_IpAddrAllocated": "10.44.69.79",
    "f1_vdu_destIpAddr": "10.44.147.32",
    "f1_vdu_gateway": "10.44.147.33",
    "f1u_vcu_destIpAddr": "10.44.69.160",
    "f1c_vcu_destIpAddr": "10.44.69.64",
    "destinationipprefixlength_f1": "27",
    "destinationipprefixlength": "27",
}

tl.cu_scf_variables = {
    "mrbts": 53123,
    "nrbts": 53123,
    "btsName": "CU_5023",
    "f1c_vdu_destIpAddr": "10.44.147.32",
    "f1u_vdu_destIpAddr": "10.44.147.32",
    "f1c_vcu_gateway": "10.44.69.65",
    "f1u_vcu_gateway": "10.44.69.161",
    "ngc_vcu_gateway": "10.44.69.97",
    "ngu_vcu_gateway": "10.44.71.225",
    "ngu_destIpAddr": "10.42.249.128",
    "mcc": "540",
    "mnc": "1",
    "mncLength": "2",
    "destinationipprefixlength_ngu_1": "28",
    "destinationipprefixlength_ngu_2": "27",
    "destinationipprefixlength_f1": "27",
    "amfIPAddress": "10.94.232.6",
    "physCellId": "323",
    "fivegstac": "7151"
}

__all__ = ["tl"]

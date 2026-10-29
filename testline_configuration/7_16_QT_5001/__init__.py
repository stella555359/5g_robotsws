__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"
__owner_email__ = "I_5GQT_WRO@internal.nsn.com"

import os
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
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
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.enb import (
    Enb,
    RealEnb,
)
from taf.config.testline.radio import RU
from taf.config.testline.appserver import AppServer, TafUeAppServer
from taf.config.testline.attenuator import TopYoung

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.195.70", username="ute", password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.42.195.70", username="ute", password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.45.168.53",
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue = TafUeAppServer(app_server_name="APP_TAF_UE",
    address="10.45.168.53",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.45.168.53",
    expected_prompt="qt5g@wl-srn-server-1-idf34")

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue,
                                                 interval=1)

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
    addr="10.42.143.69", username="core", password="system123", port=22
)

# ssh connection information of OE
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.143.69", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)
_vcu_k8s = K8S(namespace="cu5001", master_node=_vcu_master_node)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vcu_intnet_1],
    vnfs=[_vcu_cnf_1],
    cloud_hosting=_vcu_k8s,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.143.131"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.143.69", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.143.131", port=443
    ),
)
# ####################### end of vCU ##################################

#  ####################### start of vDU ###############################
# VDU deployment
_ssh_connection_details_0 = SshServiceDetails(
    addr="10.44.79.248", username="core", password="system123"
)

_k8s_connection_details_0 = K8SConnectionDetails(
    ip_addr="10.44.79.248", username="core", password="system123", port="22"
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
    addr="10.42.143.143", port="443"
)

_ru_1 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="serviceuser", password="bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4="
    ),
    lmp_connection=SshServiceDetails(
        addr="0.0.0.0", username="serviceuser", password="bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4="
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
    vnf_name="5001",
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

_android = TafUeAndroid(
    serial_number="HZQN1876AAKA2800240",
    capabilities=['_5G'],
    ue_pc_address="10.42.224.251",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.251", username="wro5gqt", password="5Gqtmoth"
    ),
    proxy_mngr_port=80,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    ueproxy_force_release=False,
    ue_pc_port="5000",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Aeroplane mode",
)

_android.ue_type = "android"

_attenuator = TopYoung(
    ip_addr="10.42.61.181",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_04G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_test_pc,
    ues=[_android],
    gnbs=[_cbts],
    core=_epcsim,
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="5001",
)

tl.target_traffic_5G = {
    "MIN_DL": "240", #Mbits/sec
    "MIN_UL": "24", #Mbits/sec
    "MAX_DL": "300", #Mbits/sec
    "MAX_UL": "30", #Mbits/sec
    "IPERF_DURATION": "70", #seconds
    "cell_id_rf1": "869220353"
}

tl.custom = {
    "real_enb": "False",        # True if TL connected to LTE eNB
    "standalone": "True",       # True if SA, False for NSA
    "has_real_core": "True",    # True if TL not using EPCSim
}

tl.attenuation = {
    "attenuation_5G": {15:0, 16:0},
    "attenuation_index": {"att":0},
    "pdu_model": "GUDE",
    "pdu_attenuator_version": "8221-1",
    "pdu_attenuator_ip": "10.44.177.234",
    "pdu_attenuator_port": "1",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

tl.du_scf_variables = {
    "mrbts": 53053,
    "nrbts": 53053,
    "btsName": "vDU01_5001",

    "rnic_productCode": "AF1791.101",
    "rnic_serialNumber": "L1242200368",
    "rmod_productCode": "475238A.102",
    "rmod_serialNumber": "1M222806722",
    "pmax": "260",

    "mcc": "540",
    "mnc": "1",
    "mncLength": "2",
    "physCellId": "51",
    "fivegstac": "7151",

    "oam_certman_server_tracecontroller": "172.16.4.2",
    "oam_destIpAddr_1": "10.42.143.128",
    "oam_destIpAddr_2": "172.16.4.0",
    "destinationipprefixlength_oam": "27",

    "f1c_vdu_IpAddrAllocated": "10.255.35.227",
    "f1u_vdu_IpAddrAllocated": "10.255.35.228",
    "f1c_vcu_IpAddrAllocated": "10.255.36.3",
    "f1_vdu_destIpAddr": "10.255.35.224",
    "f1_vdu_gateway": "10.255.35.225",
    "f1u_vcu_destIpAddr": "10.255.36.0",
    "f1c_vcu_destIpAddr": "10.255.36.0",
    "destinationipprefixlength_f1": "27",
    "destinationipprefixlength": "27",
}

tl.cu_scf_variables = {
    "mrbts": 53053,
    "nrbts": 53053,
    "btsName": "CU_5001",

    "mcc": "540",
    "mnc": "1",
    "mncLength": "2",
    "amfIPAddress": "10.94.232.6",
    "physCellId": "51",
    "fivegstac": "7151",

    "f1c_vdu_destIpAddr": "10.255.35.224",
    "f1u_vdu_destIpAddr": "10.255.35.224",
    "f1c_vcu_gateway": "10.255.36.1",
    "f1u_vcu_gateway": "10.255.36.1",
    "destinationipprefixlength_f1": "27",

    "ngc_vcu_gateway": "10.42.107.209",
    "ngu_vcu_gateway": "10.42.185.225",
    "ngu_destIpAddr" : "10.42.249.128",
    "destinationipprefixlength_ngu_1": "28",
    "destinationipprefixlength_ngu_2": "27",
}

__all__ = ["tl"]

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
        addr="10.42.194.84", username="ute", password="UTE.debian12"
    )
)

_test_pc_lte_nsa = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.93", username="ute", password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.42.194.84", username="ute", password="UTE.debian12"
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
                                                 interface_name='ASKEY_7500',
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
    addr="10.35.221.196", username="core", password="system123", port=22
)

# ssh connection information of OE
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.35.221.196", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)
_vcu_k8s = K8S(namespace="cu7500", master_node=_vcu_master_node)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vcu_intnet_1],
    vnfs=[_vcu_cnf_1],
    cloud_hosting=_vcu_k8s,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.35.221.226"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.35.221.196", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.35.221.226", port=443
    ),
)
# ####################### end of vCU ##################################

#  ####################### start of vDU ###############################
# VDU deployment
_ssh_connection_details_0 = SshServiceDetails(
    addr="10.35.221.201", username="core", password="system123"
)

_k8s_connection_details_0 = K8SConnectionDetails(
    ip_addr="10.35.221.201", username="core", password="system123", port="22"
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
    addr="10.35.221.226", port="443"
)

_ru_1 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
)
_ru_1.length = "1"

# FHGW information
_fhgw_0 = FHGW(user_config_path=_cfg_dir, rus=[_ru_1])
_fhgw_0.ip = "10.35.221.205"
_fhgw_0.username = "toor4nsn"
_fhgw_0.password = "Fhgw@nokia123!"
_fhgw_0.Ethernet_Ports = '2,27'

_vdu_0 = VDU(
    cloud_deployment=_k8s_cloud_deployment_0,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
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
    vnf_name="7500",
)

_epcsim = EPCSim(
    mme_ip="10.45.168.53",
    mcc=555,
    mnc=10,
    tac=7150,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.168.53", username="qt5g", password="5Gqtmoth!"
    ),
    dir_path="/home/ute/Robot_LteEmu",
    cfg_filename="Robot_LteEmu_Config",
)

_common_unit_enb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.44.231.13", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    hardware_type="ASIA",
    hardware_version="A.101",
)

_common_unit_enb.tl_enb = "eNB_25"

_real_enb = Airscale(common_units=[_common_unit_enb])

_lte_real_enb = RealEnb(system_module=_real_enb)

_askey = TafUeAt(com_port='6', #Visible in ue_proxy when checking for available devices
                 serial_number="1f796490", #visible in ADB
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
    ip_addr="10.42.221.54",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_04G6_90_1S_EJS",
)

_attenuator_eNB = TopYoung(
    ip_addr="10.42.61.181",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_04G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc_lte_nsa, _test_pc],
    ues=[_askey],
    enbs=[_lte_real_enb],
    gnbs=[_cbts],
    core=_epcsim,
    appserver=_appserver,
    attenuators=[_attenuator, _attenuator_eNB],
    tl_cloud_topology="7500",
)

tl.target_traffic_5G = {
    "MIN_DL": "64", #Mbits/sec
    "MIN_UL": "16", #Mbits/sec
    "MAX_DL": "80", #Mbits/sec
    "MAX_UL": "20", #Mbits/sec
    "IPERF_DURATION": "70", #seconds
    "cell_id_rf1": "13598466"
}

tl.custom = {
    "real_enb": "True",  # True if TL connected to LTE eNB
    "standalone": "False",  # True if SA, False for NSA
    "has_real_core": "True",  # True if TL not using EPCSim
    "askey_pdu_ip": "10.44.177.234",
    "askey_pdu_port": "6",
    #"scf_suffix": "SYNC",
    "gnss_sync_in_rinline2": "True"
}

tl.attenuation = {
    "attenuation_5G": {3:0, 4:0},
    "eNB_attenuation": {6:0},
    "attenuation_index": {"att":0,"eNB":1},
    "pdu_model": "gude",
    "pdu_attenuator_version": "8221-1",
    "pdu_attenuator_ip": "10.44.177.234",
    "pdu_attenuator_port": "12",
}

tl.cu_scf_variables = {
    "mrbts": 66293,
    "btsName": "CU_7500",
    "nrbts": 66293,
    "mcc": "555",
    "mnc": "10",
    "mncLength": "2",
    "physCellId": "52",
    "fiveGsTac": "6666",
    "x2_destinationIpPrefixLength": "26",
    "x2_destIpAddr": "10.44.231.64",
    "x2c_vcu_gateway": "10.44.69.97",
    "f1_destinationIpPrefixLength": "27",
    "f1c_vdu_destIpAddr": "10.44.147.32",
    "f1c_vcu_gateway": "10.44.69.65",
    "x2u_vcu_gateway": "10.45.175.129",
    "f1u_vdu_destIpAddr": "10.44.147.32",
    "f1u_vcu_gateway": "10.44.69.161",
    "s1u_destinationIpPrefixLength": "32",
    "s1u_destIpAddr": "10.42.249.83",
    "s1u_vcu_gateway": "10.44.71.225",
}

tl.du_scf_variables = {
    "mrbts": 66293,
    "nrbts": 66293,
    "btsName": "vDU24_7500",
    "rmod_prodCode": "473966A.101",
    "rmod_serialNumber": "AS195012644",
    "rnicmod_prodCode": "AF1791.M01",
    "rnicmod_serialNumber": "L1234505964",
    "mcc": "555",
    "mnc": "10",
    "mncLength": "2",
    "physCellId": "52",
    "pmax": "430",
    "f1c_vcu_IpAddrAllocated": "10.35.222.10",
    "f1c_vcu_destIpAddr": "10.44.69.64",
    "f1_vdu_gateway": "10.35.222.1",
    "destinationipprefixlength": "26",
    "f1u_vcu_destIpAddr": "10.44.69.160",
    "fiveGsTac": "0",
}

tl.fhgw_scf_variables = {
    "vlan_port27": "250-250,295-295",
    "firstEndpointPortId": "2",
    "eth1": "0",
    "eth2": "1",
}


__all__ = ["tl"]

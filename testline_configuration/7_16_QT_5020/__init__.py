__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"
__owner_email__ = "I_5GQT_WRO@internal.nsn.com"

import os
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.core import EPCSim
from taf.config.testline.cloud_hosting import (
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
from taf.config.testline.gnb.du import VDU
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.testline import TestLine
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb.gnb import CloudBts, CU
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.enb import (
    RealEnb,
)
from taf.config.testline.radio import RU
from taf.config.testline.appserver import AppServer, TafUeAppServer
from taf.config.testline.attenuator import TopYoung

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.180.165", username="ute", password="UTE.debian12"
    )
)

_test_pc_lte_nsa = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.93", username="ute", password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.44.180.165", username="ute", password="UTE.debian12"
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
                                                 interval=1)                                 #OPTIONAL

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
    addr="10.44.68.83", username="core", password="system123", port=22
)

# ssh connection information of OE
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.68.83", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)
_vcu_k8s = K8S(namespace="cu5020", master_node=_vcu_master_node)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vcu_intnet_1],
    vnfs=[_vcu_cnf_1],
    cloud_hosting=_vcu_k8s,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.68.76"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.68.83", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.68.76", port=443
    ),
)
# ####################### end of vCU ##################################

#  ####################### start of vDU ###############################
# VDU deployment
_ssh_connection_details_0 = SshServiceDetails(
    addr="10.44.79.241", username="core", password="system123"
)

_k8s_connection_details_0 = K8SConnectionDetails(
    ip_addr="10.44.79.241", username="core", password="system123", port="22"
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
    addr="10.44.79.197", port="443"
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
_fhgw_0.ip = "10.42.75.159"
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
    vnf_name="5020",
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
    hardware_version="A.203",
)

_common_unit_enb.tl_enb = "eNB_25"

_real_enb = Airscale(common_units=[_common_unit_enb])

_lte_real_enb = RealEnb(system_module=_real_enb)

_android = TafUeAndroid(
    serial_number="HZQN1876FAL33100109",
    capabilities=['_5G'],
    ue_pc_address="10.42.224.111",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.111", username="wro5gqt", password="5Gqtmoth"
    ),
    proxy_mngr_port=80,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    ueproxy_force_release=False,
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
    test_pcs=[_test_pc_lte_nsa, _test_pc],
    ues=[_android],
    enbs=[_lte_real_enb],
    gnbs=[_cbts],
    core=_epcsim,
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="5020",
)

tl.target_traffic_5G = {
    "MIN_DL": "64",  # Mbits/sec
    "MIN_UL": "16",  # Mbits/sec
    "MAX_DL": "80",  # Mbits/sec
    "MAX_UL": "20",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "13598465",
}

tl.custom = {
    "real_enb": "True",  # True if TL connected to LTE eNB
    "standalone": "False",
    "has_real_core": "True",  # True if TL not using EPCSim
    #"scf_suffix": "SYNC",
    "gnss_sync_in_rinline2": "True",
}

tl.attenuation = {
    "attenuation_5G": {13: 0, 14: 0},
    "eNB_attenuation": {5: 15},
    "attenuation_index": {"att":0,"eNB":0},
    "pdu_model": "gude",
    "pdu_attenuator_ip": "10.44.177.234",
    "pdu_attenuator_port": "1",
    "pdu_attenuator_version": "8221-1",
}

tl.cu_scf_variables = {
    "mrbts": 5020,
    "btsName": "CU_5020",
    "nrbts": 5020,
    "mcc": "555",
    "mnc": "10",
    "mncLength": "2",
    "physCellId": "52",    
    "fiveGsTac": "7150",
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
    "mrbts": 5020,
    "nrbts": 5020,
    "btsName": "vD20_5020",
    "rmod_prodCode": "473966A.101",
    "rmod_serialNumber": "AS220720644",
    "rnicmod_prodCode": "AF1791.101",
    "rnicmod_serialNumber": "L1240606043",
    "mcc": "555",
    "mnc": "10",
    "mncLength": "2",
    "physCellId": "52",
    "pmax": "430",
    "f1c_vcu_IpAddrAllocated": "10.44.69.76",
    "f1c_vcu_destIpAddr": "10.44.69.64",
    "f1_vdu_gateway": "10.44.147.33",
    "destinationipprefixlength": "27",
    "f1u_vcu_destIpAddr": "10.44.69.160",
    "fiveGsTac": "6666",
}

tl.fhgw_scf_variables = {
    "vlan_port27": "220-220,295-295",
    "firstEndpointPortId": "2",
    "eth1": "0",
    "eth2": "1",
}


tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]

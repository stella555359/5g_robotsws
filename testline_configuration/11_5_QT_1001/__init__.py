__maintainer__ = "Gu Haijian"
__team__ = "I_MN_HZQT_TEAM_GMS_GMS <I_MN_HZQT_TEAM_GMS@internal.nsn.com>"
__email__ = "I_MN_HZQT_TEAM_GMS@internal.nsn.com"
__owner_email__ = "haijian.gu@nokia-sbell.com"

import os
from taf.config.testline import  TafUeDataTransferProtocol
from taf.config.testline.cloud_hosting import (
    ControlNode,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    CloudDeployment,
)

from taf.config.testline.connection_details import (
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.core import RealCore
from taf.config.testline.gnb.du import VDU
from taf.config.testline.gnb.du import RANNIC
from taf.config.testline.pdu import TopYoung, HBTE, FPFH
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.cloud_hosting import MasterNode, K8S, ComputeNode
from taf.config.testline.testline import TestLine
from taf.config.testline import NetworkAddress
from taf.config.testline.enb import Cloud4gBts
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import Android, TafUeAndroid
from taf.config.testline.radio import RU
from taf.config.testline.appserver import AppServer, TafUeAppServer

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# Testpc
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.108.56", username="ute", password="UTE.debian12"
    )
)

#  ####################### start of vDU ###############################
# VDU deployment
_ssh_connection_details_0 = SshServiceDetails(
    addr="10.68.130.18", username="core", password="system123"
)

_k8s_connection_details_0 = K8SConnectionDetails(
    ip_addr="10.68.130.18", username="core", password="system123", port="22"
)

_master_node_0 = MasterNode(
    k8s_connection_details=_k8s_connection_details_0,
    ssh_connection_details=_ssh_connection_details_0,
)

_k8s_0 = K8S(namespace="cran1", master_node=_master_node_0)
_vdu_vnf_0 = DeploymentVnfStack(
    # this is vdu release name, the name should only be lower case and only can include alphabet number,
    name="4gvdu"
)

_vdu_intnet_0 = DeploymentNetworkStack(
    # this is pvc release name, the name should only be lower case and only can include alphabet number,
    name="4gvdu-prerequisite"
)

_k8s_cloud_deployment_0 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_0],
    vnfs=[_vdu_vnf_0],
    cloud_hosting=_k8s_0,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.68.131.18", port="443"
)

_4g_ru_pdu = FPFH(addr="10.108.191.66", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.41", username="root", password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM="
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.10.41", username="root", password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM="
    ),
    pdu_port=_4g_ru_pdu.pdu_ports[1],
)
_ru.length = "1"

_rannic_0 = RANNIC(rus=[_ru])

_vdu_0 = VDU(
    cloud_deployment=_k8s_cloud_deployment_0,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    rannics=[_rannic_0],
)


# ####################### override yaml definition ###############################
_vdu_0.du_cnf_yaml = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/DU_cnf_values-override.yaml"
)

_vdu_0.du_pvc_yaml = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/DU_pvc_values-override.yaml"
)
_k8s_cloud_deployment_0.cnf_override_dir = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/cnf_values-override.yaml"
)

_k8s_cloud_deployment_0.pvc_override_dir = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/pvc_values-override.yaml"
)

_k8s_cloud_deployment_0.cnf_conversion_dir = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/cnf_values-override_converted.yaml"
)

_k8s_cloud_deployment_0.pvc_conversion_dir = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "Override_yaml/pvc_values-override_converted.yaml"
)
# ####################### end of override yaml definition ###############################

_cbts = Cloud4gBts(
    du=_vdu_0,
    cloud_deployment=_k8s_cloud_deployment_0,
    vnf_name="hgz-1001",
)
#########UE##########
# _appserver = AppServer(_iperf_details_on_appserver)
_appserver_taf_ue = TafUeAppServer(app_server_name="APP_TAF_UE",
    address="10.56.108.56",
    user="ute",
    password="UTE.debian12",
    )

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue,
                                                 interval=1)

_android = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.195.22", username="ute", password="UTE.debian12"
    ),
    ue_pc_address="10.69.195.22",
    serial_number="R3CR10LKJKB",
    ueproxy_force_release=False,
    proxy_mngr_port=5000,
    imsi="android",
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    data_transfer=[_data_transfer_iperf],
    qualcomm_prototype=False,
    airplane_mode_switcher_text="Off|On",
    capabilities=["_4G"],
)

_android.ue_type = "android"
_android.ui_version = "S20UI2.5"
# TestLine
tl = TestLine(
    test_pc=_test_pc,
    enbs=[_cbts],
    ues=[_android],
    tl_cloud_topology="hgz-1001",
)

tl.target_traffic_4G = {
    "MIN_DL": "48", #Mbits/sec
    "MIN_UL": "32", #Mbits/sec
    "MAX_DL": "60", #Mbits/sec
    "MAX_UL": "40", #Mbits/sec
    "IPERF_DURATION": "70", #seconds
    "cell_id_rf1": "2895617"
}

tl.custom = {
    "has_real_core": "True",
    "pdu_model": "None",
    #"scf_suffix": "SYNC",
    #"gnss_sync_in_rinline2": "True"
}

tl.du_scf_variables = {
    "mrbts": 11311,
    "lnbts": 11311,
    "lncel": 1001,
    "btsName": "QT-LTE_CPRI_FDD_Thor-HGZ-1001",
    "rmod_prodCode": "474331A.101",
    "rmod_serialNumber": "BL2027G1AVJ",
    "rnicmod_prodCode": "AF1791.101",
    "rnicmod_serialNumber": "L1240701697",
    "moduleLocation": "HangZhou",
    "mme_ipAddrPrim": "10.110.194.171",
    "earfcnDL": "68716",
    "earfcnUL": "133252",
    "tac": "6666",
    "mcc": "262",
    "mnc": "3",
    "mncLength": "2",
    "pmax": "390",
    "mme_IpAddrAllocated": "10.110.0.0",
    "mme_destinationipprefixlength": "16",
    "lteCore_IpAddrAllocated": "10.107.0.0",
    "lteCore_destinationipprefixlength": "16",
    "s1_gateway": "10.68.131.9",
}

__all__ = ["tl"]

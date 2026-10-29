__maintainer__ = "Krystian Wachowski"
__team__ = "MN RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"
__owner_email__ = "krystian.wachowski@nokia.com"

import os
from taf.config.testline import TafUeDataTransferProtocol, NetworkAddress
from taf.config.testline.cloud_hosting import (
    DeploymentNetworkStack,
    DeploymentVnfStack,
    CloudDeployment,
    MasterNode,
    K8S,
)
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    K8SConnectionDetails,
)
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.du import RANNIC, VDU
from taf.config.testline.enb import Cloud4gBts
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.radio import RU
from taf.config.testline.appserver import AppServer, TafUeAppServer

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.172", username="ute", password="UTE.debian12"
    )
)

#  ####################### start of vDU ###############################
# VDU deployment
_ssh_connection_details_0 = SshServiceDetails(
    addr="10.33.183.150", username="core", password="system123"
)

_k8s_connection_details_0 = K8SConnectionDetails(
    ip_addr="10.33.183.150", username="core", password="system123", port="22"
)

_master_node_0 = MasterNode(
    k8s_connection_details=_k8s_connection_details_0,
    ssh_connection_details=_ssh_connection_details_0,
)

_k8s_0 = K8S(namespace="cran1", master_node=_master_node_0)
_vdu_vnf_0 = DeploymentVnfStack(
    # this is vdu release name, the name should only be lower case and only can include alphabet number,
    name="cloudran-4gvdu"
)

_vdu_intnet_0 = DeploymentNetworkStack(
    # this is pvc release name, the name should only be lower case and only can include alphabet number,
    name="cloudran-4gvdu-prerequisite"
)

_k8s_cloud_deployment_0 = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    networks=[_vdu_intnet_0],
    vnfs=[_vdu_vnf_0],
    cloud_hosting=_k8s_0,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.33.183.182", port="443"
)

_ru_1 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.170.0.2",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.170.0.2",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
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
# ####################### end of vDU ###############################

# ####################### override yaml definition ###############################
_vdu_0.du_cnf_yaml = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "Override_yaml/DU_cnf_values-override.yaml",
)

_vdu_0.du_pvc_yaml = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "Override_yaml/DU_pvc_values-override.yaml",
)

_k8s_cloud_deployment_0.cnf_override_dir = os.environ["ABSTRACT_LIB_CONFIG"] = (
    os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        "Override_yaml/cnf_values-override.yaml",
    )
)

_k8s_cloud_deployment_0.pvc_override_dir = os.environ["ABSTRACT_LIB_CONFIG"] = (
    os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        "Override_yaml/pvc_values-override.yaml",
    )
)

_k8s_cloud_deployment_0.cnf_conversion_dir = os.environ["ABSTRACT_LIB_CONFIG"] = (
    os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        "Override_yaml/cnf_values-override_converted.yaml",
    )
)

_k8s_cloud_deployment_0.pvc_conversion_dir = os.environ["ABSTRACT_LIB_CONFIG"] = (
    os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        "Override_yaml/pvc_values-override_converted.yaml",
    )
)
# ####################### end of override yaml definition ###############################

_cbts = Cloud4gBts(
    du=_vdu_0,
    cloud_deployment=_k8s_cloud_deployment_0,
    vnf_name="5101",
)

#########UE##########
_appserver_taf_ue = TafUeAppServer(
    app_server_name="APP_TAF_UE",
    address="10.35.102.96",
    user="srn",
    password="!!IperfUser@25",
    bind_interface_ip="10.35.102.96",
    expected_prompt="srn@iperfU39",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_appserver_taf_ue, interval=1
)  # OPTIONAL

_android = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ssh_connection_details=SshServiceDetails(
        addr="10.33.9.11", username="FIOUSRUSR", password="!SRkuivasranta2"
    ),
    capabilities=["_4G"],
    ue_pc_address="10.33.9.11",
    data_transfer=[_data_transfer_iperf],
    proxy_mngr_port=80,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    ueproxy_force_release=False,
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Airplane mode",
)

_android.ue_type = "android"

# TestLine
tl = TestLine(
    test_pc=_test_pc,
    ues=[_android],
    enbs=[_cbts],
    tl_cloud_topology="5101",
)

tl.target_traffic_4G = {
    "IPERF_DURATION": "180",  # seconds
    "MIN_DL": "120",  # Mbits/sec
    "MAX_DL": "160",  # Mbits/sec
    "MIN_UL": "20",  # Mbits/sec
    "MAX_UL": "40",  # Mbits/sec
    "cell_id_rf1": "15158273",
}

tl.custom = {
    "has_real_core": "True",  # True if TL not using EPCSim
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

tl.du_scf_variables = {
    "mrbts": 59212,
    "lnbts": 59212,
    "lncel": 55681,
    "btsName": "QT-LTE_CPRI_FDD_Thor-OULU-5101",
    "moduleLocation": "Oulu",
    "rmod_prodCode": "475767A",
    "rmod_serialNumber": "YK223600015",
    "rnicmod_prodCode": "AF1791.101",
    "rnicmod_serialNumber": "L1240401491",
    "tac": "9000",
    "mcc": "244",
    "mnc": "9",
    "mncLength": "2",
    "pmax": "390",
    "earfcnDL": "1450",
    "earfcnUL": "19450",
    "mme_ipAddrPrim": "10.33.58.200",
    "mme_IpAddrAllocated": "10.33.58.200",
    "mme_destinationipprefixlength": "32",
    "lteCore_IpAddrAllocated": "10.33.59.0",
    "lteCore_destinationipprefixlength": "24",
    "s1_gateway": "10.33.183.161",
}

__all__ = ["tl"]

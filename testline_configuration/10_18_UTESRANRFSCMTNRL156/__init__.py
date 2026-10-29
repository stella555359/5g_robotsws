__maintainer__ = "marius.roman@nokia.com"
__email__ = "marius.roman@nokia.com"
__owner_email__ = "marius.roman@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote                                                      
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import Gude
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails 
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.gnb.cu import CU
from taf.config.testline.gnb.du import VDU, RANNIC
from taf.config.testline.gnb.gnb import CloudBts
from taf.config.testline.optical_switch import Calient
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ran import RNC
                                               
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    CloudDeployment,
    HelmChart,
)
 
_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.52",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[],
)


_pdu_1 = Gude(
    "10.255.2.32",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
                                                 
                                                  
                                               
_ru_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH214201661",  
    pdu_port=_pdu_1.pdu_ports[4],
#        lmi=SerialOverHost(
#        host=TestPc(
#            default_ssh_connection_details=SshServiceDetails(
#                addr="10.5.53.128",
#                username="rfsharing",
#                password="Nokia2022!@1"
#            )
#        ),
#        uart_mapping=[  # windows
#            Local(
#                port="COM3"
#            )
#        ]
#    )
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1232711665",  
    pdu_port=_pdu_1.pdu_ports[6],
)

_ru_3 = RU(
    ru_hw_group="",            
    radio_type=RadioTypes.AQQL.value,
    serial_number="DH234520593", 
    pdu_port=_pdu_1.pdu_ports[11],
)

_ru_4 = RU(
    ru_hw_group="",            
    radio_type=RadioTypes.AHLOB.value,
    serial_number="BL2240D50LU", 
    pdu_port=_pdu_1.pdu_ports[12],
)                                          
 
_vdu1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.59.142",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.5.59.142", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.59.142", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cranuser1", master_node=_vdu_master_node)

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

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

# RANNIC class for RANNIC defining (only for CBTS if direct connection between RMs and VDUs is requested).
_rannic_n = RANNIC(
    serial_number="L1241604183",
    product_code="AF1791.101",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4],
)

_vdu_1 = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu1_oam_http_connection_details,
    rannics=[_rannic_n],               
    instance_id=624156,
    fhuc_vlans=[301],
)

_vcu_oam_ssh_connection_details = SshServiceDetails(
    addr="10.5.59.143", username="core", password="system123"
)                                                                                                           

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.59.143", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_oam_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran2", master_node=_vcu_master_node)

_cluster_preparation_cu = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, "vcu-cluster-preparation.yaml"),
)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vcu-prerequisite.yaml"),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, "vcu-cnf.yaml"),
)

_vcu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.59.143",
    username="Nemuadmin",
    port=443,
    password="Nokia@123",
)

_cu = CU(
    backhaul_site_oam_ip="None",
    oam_ssh_connection_details=_vcu_oam_ssh_connection_details,
    oam_http_connection_details=_vcu_oam_http_connection_details,
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    cluster_preparation=_cluster_preparation_cu,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
)              

_cbts = CloudBts(
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    dus=[_vdu_1],
)

_test_pc_1.connections.append(_cbts)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.28",
    user="ftp_5g",
    password="Aikon_123456",
    bind_interface_ip="10.5.61.131",
)
#_app_server_2 = TafUeAppServer(
#    app_server_name="APP_2",
#    address="10.9.146.30",
#    user="iperf_user",
#    password="Treperf",
#    bind_interface_ip="10.9.146.30",
#)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

#_data_transfer_iperf_2 = TafUeDataTransferProtocol(
#    protocol_name="iperf", app_server=_app_server_2, interval=1, server_close_delay=50
#)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_cbts],

)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "USER_STOP_AND_FIX": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
    "USER_RSI_INFO_COLLECT": True,
    "USER_SCF_VALIDATION_CHECK": False,
    "POWER_ON_FLAG": True,
    "USER_STOP_AND_FIX_BLOCK_TEST": False,
}

__all__ = ["tl"]

__maintainer__ = "Michal Tryba"
__email__ = "michal.tryba@nokia.com"

import os
from taf.config.testline import (
    MasterNode,
    K8S,
    ComputeNode,
    CloudDeployment,
    HelmChart,
    TestLine,
    RU,
    FHGW,
    CloudBts,
    CU,
    VDU,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)

from taf.config.testline.testpc import TestPc
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.167.204", port_numbers=[1, 2, 4, 11, 12], model="EPC", version="8220-1"
)
_pdu2 = Gude(
    addr="10.44.167.205", port_numbers=[3, 4, 12], model="EPC", version="8220-1"
)

_pdus = [_pdu1, _pdu2]

# VDU

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.44.169.25", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.169.25", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
)

# RU configuration
_ru_1 = RU(
    pdu_port=_pdu2.pdu_ports[3],
    ru_hw_group="cMAA_Gen4.0_8T8R",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        port=22,
        username="rfsw",
        password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=",
    ),
    radio_type="AZQL",
    serial_number="EA201551642",
    product_code="475130A.101",
)

_ru_2 = RU(
    pdu_port=_pdu1.pdu_ports[11],
    ru_hw_group="cMAAr6.1_8T8R",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        port=22,
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    radio_type="AZQU",
    serial_number="4H210730003",
    product_code="475665A.101",
)

_ru_3 = RU(
    pdu_port=_pdu2.pdu_ports[4],
    ru_hw_group="cMAAr6.1_8T8R",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        port=22,
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    radio_type="AZQO",
    serial_number="1M203310018",
    product_code="475288A.102",
)

_ru_4 = RU(
    pdu_port=_pdu1.pdu_ports[4],
    ru_hw_group="cMAAr6.1_8T8R",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        port=22,
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    radio_type="AZQU",
    serial_number="1M212422836",
    product_code="475665A.101",
)

_ru_5 = RU(
    pdu_port=_pdu2.pdu_ports[12],
    ru_hw_group="cMAArChile_64T64R",
    default_ssh_connection_details=SshServiceDetails(
        addr="", port=22, username="rfsw", password="bdS%ztWG3v7%SjreCVA79wTPb"
    ),
    radio_type="AEHC",
    serial_number="K9222600539",
    product_code="475124B.101",
)

_ru_6 = RU(
    pdu_port=_pdu1.pdu_ports[12],
    ru_hw_group="cMAAr6.2_64T64R",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        port=22,
        username="rfsw",
        password="gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=",
    ),
    radio_type="AQQL",
    serial_number="DH234520600",
    product_code="476136A.101",
)

_ru_7 = RU(
    pdu_port=_pdu1.pdu_ports[2],
    ru_hw_group="cMAAr6.2_64T64R",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        port=22,
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    radio_type="AQQE",
    serial_number="L1215205795",
    product_code="475544A.101",
)

_ru_8 = RU(
    pdu_port=_pdu1.pdu_ports[1],
    ru_hw_group="5Ggen4_LowF_2T2R",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        port=22,
        username="rfsw",
        password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    ),
    radio_type="AVQL",
    serial_number="L1232907072",
    product_code="476203A.101",
)

# FHGW information
_fhgw = FHGW(
    user_config_path="",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7, _ru_8],
)

_vdu = VDU(
    instance_id=8718,
    cloud_deployment=vdu_k8s_cloud_deployment,
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.192.219", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    fhgws=[_fhgw],
)

#VCU
_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.183.207", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.183.207", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.44.169.25", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.169.25", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8718", master_node=_vcu_master_node)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
)

_test_pc_vm = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.40",
        username="ute",
        password="uteUTE!",
    ),
    connections=[_cbts],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_Server_WG",
    address="10.44.184.246",
    user="ranpz",
    password="Pass4Testers!",
    bind_interface_ip="10.44.184.246",
)

_asus_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_ue = TafUeAndroid(
    serial_number="MAAIKN00P787JXZ",
    ue_pc_address="10.45.165.167",
    ssh_connection_details=SshServiceDetails(
        addr="10.45.165.167", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    data_transfer=[_asus_iperf],
    is_rooted="yes",
    airplane_mode_switcher_text="Airplane mode",
)

tl = TestLine(
    test_pc=_test_pc_vm,
    gnbs=[_cbts],
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    tl_cloud_topology="CLOUD_5G_CLOUD_7_16_UTE5GSISOAUTOCL8718",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]

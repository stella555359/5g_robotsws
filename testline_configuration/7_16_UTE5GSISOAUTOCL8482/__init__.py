__maintainer__ = "Pawel Woloszyn"
__email__ = "pawel.woloszyn@nokia.com"

import os
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    ComputeNode,
    CloudDeployment,
    HelmChart,
    #    TestLine,
    #    CloudBts,
    #    CU,
    #    VDU,
    #    FHGW,
    #    RU,
)

from taf.config.testline.connection_details import (
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.gnb.du import VDU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.ue import PreferredVlan
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId
from taf.config.testline.optical_switch import Leoni
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import FHGW
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

# _los = Leoni(addr="10.42.201.38", model="mol 6x(2x6)")

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.44.169.21", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.169.21", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

#######vdu deployment########
_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vdu-prerequisite.yaml"),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, "vdu-cnf.yaml"),
)

_values_override_aic_vdu_prerequisite = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "values-override_aic-vdu-prerequisite.yaml"),
)

_values_override_aic_vdu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, "values-override_aic-vdu.yaml"),
)

vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    prerequisite=_values_override_aic_vdu_prerequisite,
    cnf=_values_override_aic_vdu,
    #    prerequisite=_prerequisite_du,
    #    cnf=_cnf_du,
)
###################

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
# _fhgw_0 = FHGW(
#    user_config_path=os.path.join(
#        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
#    ),
#    fhgw_id=8482,
# )

_vdu = VDU(
    instance_id=8482,
    cloud_deployment=vdu_k8s_cloud_deployment,
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.126.120", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    fhgws=[_fhgw],
    #    fhuc_vlans=[301],
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.183.184", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.183.184", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.44.169.21", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.169.21", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8482", master_node=_vcu_master_node)

#######vcu deployment########
_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "vcu-prerequisite.yaml"),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, "vcu-cnf.yaml"),
)

_values_override_aic_vcu_prerequisite = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, "values-override_aic-vcu-prerequisite.yaml"),
)

_values_override_aic_vcu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, "values-override_aic-vcu.yaml"),
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    prerequisite=_values_override_aic_vcu_prerequisite,
    cnf=_values_override_aic_vcu,
    #    prerequisite=_prerequisite_cu,
    #    cnf=_cnf_cu,
)
###################

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
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170",
)

_asus_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
    version=3,
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
    tl_cloud_topology="CLOUD_5G_CLOUD_7_16_UTE5GSISOAUTOCL8482",
    ues=[_ue],
    pdus=_pdus,
    #    optical_switches=[_los],
)

__all__ = ["tl"]

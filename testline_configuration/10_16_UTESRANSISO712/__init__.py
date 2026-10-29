__maintainer__ = "Wojciech Bodzek"
__email__ = "wojciech.bodzek@nokia.com"

import os
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    ComputeNode,
    CloudDeployment,
    HelmChart,
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
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.167.211", port_numbers=[1,3,5], model="EPC", version="8220-1"
)

_pdu2 = Gude(
    addr="10.44.167.191", port_numbers=[1,2,3,4,5,9], model="EPC", version="8220-1"
)

_pdus = [_pdu1,_pdu2]


_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.44.169.28", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.169.28", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vdu-prerequisite.yaml'),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cnf.yaml'),
)

vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.44.192.222", port=443, username="Nemuadmin", password="nemuuser"
)

# RU configuration
_ru_1 = RU(ru_hw_group="cMAAr7.1_64T64R", pdu_port=_pdu1.pdu_ports[1], radio_type="AVQL", serial_number="L1242806541")
_ru_2 = RU(ru_hw_group="cMAAr7.1_64T64R", pdu_port=_pdu1.pdu_ports[3], radio_type="AVQL", serial_number="L1242806546")
_ru_3 = RU(ru_hw_group="cMAAr7.1_64T64R", pdu_port=_pdu1.pdu_ports[5], radio_type="AVQL", serial_number="L1242806544")
_ru_4 = RU(ru_hw_group="FRMr6.2_4T4R", pdu_port=_pdu2.pdu_ports[1], radio_type="AHFII", serial_number="K9241302847")
_ru_5 = RU(ru_hw_group="FRMr6.2_4T4R", pdu_port=_pdu2.pdu_ports[2], radio_type="AHFII", serial_number="BL2242N432I")
_ru_6 = RU(ru_hw_group="FRMr6.2_4T4R", pdu_port=_pdu2.pdu_ports[3], radio_type="AHFII", serial_number="BL2235N41PG")
_ru_7 = RU(ru_hw_group="FRMr5.1a_4T4R", pdu_port=_pdu2.pdu_ports[4], radio_type="AHFIB", serial_number="K9182242683")
_ru_8 = RU(ru_hw_group="FRMr6.2a_4T4R", pdu_port=_pdu2.pdu_ports[5], radio_type="AHEGHA", serial_number="BL2311H601W")
_ru_9 = RU(ru_hw_group="FRMr6.2a_4T4R", pdu_port=_pdu2.pdu_ports[9], radio_type="AHEGHA", serial_number="BL2351H69VC")

# FHGW information
_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7, _ru_8, _ru_9],

)

_vdu = VDU(
    cloud_deployment=vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    instance_id=8721,
    fhuc_vlans=[301],
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.183.210", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.183.210", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.183.210/25"
    ),
    global_bts_id=8721,
)



_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.44.169.166", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.169.166", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8721", master_node=_vcu_master_node)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vcu-prerequisite.yaml'),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, 'vcu-cnf.yaml'),
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.121.91",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    tl_cloud_topology="CLOUD_AIC_10_16_UTESRANSISO712",
#    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]

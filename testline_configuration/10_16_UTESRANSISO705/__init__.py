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
from taf.config.testline.gnb.du import RANNIC

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.167.191", port_numbers=[6,7,8], model="EPC", version="8220-1"
)

_pdus = [_pdu1]


_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.126.53", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.126.53", username="core", password="system123", port=22
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
    addr="10.42.126.117", port=443, username="Nemuadmin", password="nemuuser"
)

# RU configuration
_ru_1 = RU(ru_hw_group="FRMr5.1a_4T4R", pdu_port=_pdu1.pdu_ports[7], radio_type="AHFIB", serial_number="K9181046216")
_ru_2 = RU(ru_hw_group="FRMr5.1a_4T4R", pdu_port=_pdu1.pdu_ports[6], radio_type="AHFIB", serial_number="K9175116255")
_ru_3 = RU(ru_hw_group="FRMr5.1a_4T4R", pdu_port=_pdu1.pdu_ports[8], radio_type="AHBCC", serial_number="K9190632468")

# FHGW information
_fhgw_0_ssh_connection_details = SshServiceDetails(
    addr="10.42.201.113", username="toor4nsn", port=22, password="Fhgw@nokia1254"
)

_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1, _ru_2, _ru_3],
    fhgw_id=8474,
    default_ssh_connection_details=_fhgw_0_ssh_connection_details,
)

_rannic_0 = RANNIC(
    serial_number="L1232810438",
    rus=[],
)

_vdu = VDU(
    cloud_deployment=vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    instance_id=8474,
    fhuc_vlans=[301],
    rannics=[_rannic_0],
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.183.181", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.183.181", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
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

_vcu_k8s = K8S(namespace="cran8474", master_node=_vcu_master_node)

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
        addr="10.42.121.12",
        username="ute",
        password="ute",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    tl_cloud_topology="CLOUD_AIC_10_16_UTESRANSISO705",
#    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]

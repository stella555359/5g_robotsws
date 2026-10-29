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
from taf.config.testline.cloud_hosting import MasterNode, K8S, ContainerRegistry

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

vcu_container_registry = ContainerRegistry(url="ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net:443/vcu", username ="robot$vrf", password="biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR")
vdu_container_registry = ContainerRegistry(url="ccr-wg-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu", username ="robot$vrf", password="zS8IxZm4R6H8Heu2NWFmd8wQMCRDv3b9")


_pdu1 = Gude(
    addr="10.44.167.212", port_numbers=[4], model="EPC", version="8220-1"
)
_pdu2 = Gude(
    addr="10.44.167.253", port_numbers=[10,11], model="EPC", version="8220-1"
)
_pdu3 = Gude(
    addr="10.44.167.109", port_numbers=[9,10,11], model="EPC", version="8221-1"
)
_pdu4 = Gude(
    addr="10.44.167.213", port_numbers=[11], model="EPC", version="8221-1"
)
_pdu5 = Gude(
    addr="10.44.167.117", port_numbers=[1,2,8,9,11], model="EPC", version="8220-1"
)


_pdus = [_pdu1,_pdu2, _pdu3, _pdu4, _pdu5]

_rannic_0 = RANNIC(
    serial_number="L1243107661"
)

_rannic_1 = RANNIC(
    serial_number="L1243107665"
)

_rannic_2 = RANNIC(
    serial_number="L1243107718"
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.126.54", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.126.54", username="core", password="system123", port=22
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
    container_registry=vdu_container_registry
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.126.118", port=443, username="Nemuadmin", password="nemuuser"
)

# RU configuration
_ru_1 = RU(ru_hw_group="FRMr6.2_4T4R", pdu_port=_pdu1.pdu_ports[4], radio_type="AHEGSA", serial_number="1M251406752")
_ru_2 = RU(ru_hw_group="FRMr5.1_1_6T6R", pdu_port=_pdu2.pdu_ports[10], radio_type="ARDB", serial_number="LR250502176")
_ru_3 = RU(ru_hw_group="FRMr5.1_1_6T6R", pdu_port=_pdu2.pdu_ports[11], radio_type="AREA", serial_number="EA191771360")
_ru_4 = RU(ru_hw_group="FRMr6.2_4T4R", pdu_port=_pdu4.pdu_ports[11], radio_type="AHPMDG", serial_number="BL2331C62X6")
_ru_5 = RU(ru_hw_group="FRMr5.1_1_4T4R_LP", pdu_port=_pdu5.pdu_ports[8], radio_type="AHHA", serial_number="EA182510837")
_ru_6 = RU(ru_hw_group="FRMr5.1_1_4T4R_LP", pdu_port=_pdu5.pdu_ports[2], radio_type="AHEJ", serial_number="DH251003010")
_ru_7 = RU(ru_hw_group="FRMr6.2_4T4R", pdu_port=_pdu5.pdu_ports[11], radio_type="AHFII", serial_number="BL2212N400A")
_ru_8 = RU(ru_hw_group="cMAAr6.2_64T64R", pdu_port=_pdu3.pdu_ports[9], radio_type="AQQL", serial_number="DH243126346")
_ru_9 = RU(ru_hw_group="cMAAr6.2_64T64R", pdu_port=_pdu3.pdu_ports[10], radio_type="AQQL", serial_number="DH243126347")
_ru_10 = RU(ru_hw_group="cMAAr6.2_64T64R", pdu_port=_pdu3.pdu_ports[11], radio_type="AQQL", serial_number="DH243126348")
_ru_11 = RU(ru_hw_group="FRMr5.1_4T4R", pdu_port=_pdu5.pdu_ports[9], radio_type="AHPMDB", serial_number="AS210713338")
_ru_12 = RU(ru_hw_group="FRMr6.2a_4T4R", pdu_port=_pdu5.pdu_ports[1], radio_type="AHPDC", serial_number="RW233001152")

# FHGW information
_fhgw_0_ssh_connection_details = SshServiceDetails(
    addr="10.42.185.164", username="toor4nsn", port=22, password="Fhgw@nokia1243"
)

_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7, _ru_8, _ru_9, _ru_10, _ru_11, _ru_12],
    fhgw_id=8480,
    default_ssh_connection_details=_fhgw_0_ssh_connection_details,

)

_vdu = VDU(
    cloud_deployment=vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    instance_id=1,
    fhuc_vlans=[301],
    rannics=[_rannic_0, _rannic_1, _rannic_2],
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.183.182", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.183.182", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.126.198", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.126.198", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8480", master_node=_vcu_master_node)

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
    container_registry=vcu_container_registry
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.121.131",
        username="ute",
        password="ute",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    tl_cloud_topology="CLOUD_AIC_10_16_UTESRANSISO703",
#    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]

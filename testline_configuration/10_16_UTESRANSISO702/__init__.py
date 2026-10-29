__maintainer__ = "Marek Oleksiewicz"
__email__ = "marek.oleksiewicz@nokia.com"

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

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.167.213", port_numbers=[2,4,7,8,10], model="EPC", version="8221-1"
)

_pdu2 = Gude(
    addr="10.44.167.201", port_numbers=[10], model="EPC", version="8221-1"
)

_pdu3 = Gude(
    addr="10.44.167.212", port_numbers=[9], model="EPC", version="8220-1"
)

_pdu4 = Gude(
    addr="10.44.167.198", port_numbers=[11], model="EPC", version="8220-1"
)

_pdu5 = Gude(
    addr="10.44.167.211", port_numbers=[12], model="EPC", version="8220-1"
)

_pdus = [_pdu1,_pdu2,_pdu3,_pdu4,_pdu5]

_los = Leoni(addr="10.42.201.36", model="mol 6x(2x6)")

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.44.192.71", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.192.71", username="core", password="system123", port=22
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
    addr="10.44.192.147", port=443, username="Nemuadmin", password="nemuuser"
)

# RU configuration
_ru_1 = RU(ru_hw_group="FRMr5.1_1_2T4R", pdu_port=_pdu1.pdu_ports[10], radio_type="AHPE", serial_number="1M202303622")
_ru_2 = RU(ru_hw_group="FRMr5.1_1_6T6R", pdu_port=_pdu2.pdu_ports[10], radio_type="ARPA", serial_number="LR241802190")
_ru_3 = RU(ru_hw_group="FRMr5.1_4T4R", pdu_port=_pdu1.pdu_ports[4], radio_type="AHFIC", serial_number="DC1946001U2")
_ru_4 = RU(ru_hw_group="FRMr5.1_1_4T4R", pdu_port=_pdu1.pdu_ports[2], radio_type="AHCA", serial_number="L1181111027")
_ru_5 = RU(ru_hw_group="FRMr5.1_4T4R", pdu_port=_pdu1.pdu_ports[8], radio_type="AHBCC", serial_number="K9190632475")
_ru_6 = RU(ru_hw_group="FRMr5.1_1_4T4R", pdu_port=_pdu3.pdu_ports[9], radio_type="AHHB", serial_number="EA202151829")
_ru_7 = RU(ru_hw_group="FRMr5.1_1_4T4R", pdu_port=_pdu1.pdu_ports[7], radio_type="AHFIG", serial_number="K9200215156")
_ru_8 = RU(ru_hw_group="FRMr6.2a_4T4R", pdu_port=_pdu4.pdu_ports[11], radio_type="AHEGSA", serial_number="1M251406775")
_ru_9 = RU(ru_hw_group="FRMr5.1_1_4T4R", pdu_port=_pdu5.pdu_ports[12], radio_type="AHLOA", serial_number="BL2106G109T")

# FHGW information
_fhgw_0_ssh_connection_details = SshServiceDetails(
    addr="10.42.185.86", username="toor4nsn", port=22, password="Fhgw@nokia1243"
)

_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6,  _ru_7,  _ru_8,  _ru_9],
    fhgw_id=8747,
    default_ssh_connection_details=_fhgw_0_ssh_connection_details,
)

_vdu = VDU(
    cloud_deployment=vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    instance_id=1,
    fhuc_vlans=[301],
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.183.243", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.183.243", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.126.215", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.126.215", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8435", master_node=_vcu_master_node)

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
        addr="10.42.121.46",
        username="ute",
        password="ute",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    tl_cloud_topology="CLOUD_AIC_10_16_UTESRANSISO702",
#    ues=[_ue],
    pdus=_pdus,
    optical_switches=[_los],
)

__all__ = ["tl"]

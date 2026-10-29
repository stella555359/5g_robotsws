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
from taf.config.testline.enb import RealEnb
from taf.config.testline.testpc import TestPc, Connection
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
    addr="10.44.167.210", port_numbers=[5,6,7,8], model="EPC", version="8221-1"
)

_pdu2 = Gude(
    addr="10.44.167.214", port_numbers=[6,7,8], model="EPC", version="8221-1"
)

_pdu3 = Gude(
    addr="10.44.167.212", port_numbers=[2,10], model="EPC", version="8220-1"
)

_pdu4 = Gude(
    addr="10.44.167.198", port_numbers=[7,8,9,10,12], model="EPC", version="8220-1"
)

_pdus = [_pdu1,_pdu2,_pdu3,_pdu4]


_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.44.192.28", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.192.28", username="core", password="system123", port=22
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
    addr="10.44.192.241", port=443, username="Nemuadmin", password="nemuuser"
)

# RU configuration
_ru_1 = RU(ru_hw_group="cMAAr6.2_64T64R", pdu_port=_pdu1.pdu_ports[5], radio_type="AQQL", serial_number="DH243126323")
_ru_2 = RU(ru_hw_group="cMAAr6.2_64T64R", pdu_port=_pdu1.pdu_ports[6], radio_type="AQQL", serial_number="DH243126322")
_ru_3 = RU(ru_hw_group="cMAAr6.2_64T64R", pdu_port=_pdu1.pdu_ports[7], radio_type="AQQL", serial_number="DH243126335")
_ru_4 = RU(ru_hw_group="cMAAr6.1_32T32R", pdu_port=_pdu1.pdu_ports[8], radio_type="AEQY", serial_number="1M201202406")
_ru_5 = RU(ru_hw_group="cMAAr6.2_64T64R", pdu_port=_pdu2.pdu_ports[6], radio_type="AQQS", serial_number="L1223508298")
_ru_6 = RU(ru_hw_group="cMAAr6.2_64T64R", pdu_port=_pdu2.pdu_ports[7], radio_type="AQQS", serial_number="L1223508299")
_ru_7 = RU(ru_hw_group="cMAAr7.1_64T64R", pdu_port=_pdu3.pdu_ports[2], radio_type="AVQL", serial_number="L1242806533")
_ru_8 = RU(ru_hw_group="cMAAr7.1_64T64R", pdu_port=_pdu3.pdu_ports[10], radio_type="AVQL", serial_number="L1242806531")
_ru_9 = RU(ru_hw_group="cMAAr7.1_64T64R", pdu_port=_pdu2.pdu_ports[8], radio_type="AVQL", serial_number="L1242806539")
_ru_10 = RU(ru_hw_group="FRMr5.1_2T4R", pdu_port=_pdu4.pdu_ports[7], radio_type="AHFII", serial_number="K9245120901")
_ru_11 = RU(ru_hw_group="FRMr5.1_2T4R", pdu_port=_pdu4.pdu_ports[8], radio_type="AHPB", serial_number="DH244316335")
_ru_12 = RU(ru_hw_group="FRMr6.2a_4T4R", pdu_port=_pdu4.pdu_ports[9], radio_type="AHEGHA", serial_number="K9242639679")
_ru_13 = RU(ru_hw_group="FRMr6.2a_4T4R", pdu_port=_pdu4.pdu_ports[10], radio_type="AHEGHA", serial_number="K9242639680")

# FHGW information
#_fhgw_0 = FHGW(
#    user_config_path=os.path.join(
#        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
#    ),
#    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7, _ru_8, _ru_9, _ru_10, _ru_11, _ru_12, _ru_13],
#    fhgw_id=1,
#)

_rannic_0 = RANNIC(
    serial_number="L1243107694",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_10, _ru_11, _ru_12, _ru_13],
)

_rannic_1 = RANNIC(
    serial_number="L1242702879",
    rus=[_ru_7, _ru_8, _ru_9],
)

_vdu = VDU(
    cloud_deployment=vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
 #   fhgws=[_fhgw_0],
    instance_id=1,
    fhuc_vlans=[301],
    rannics=[_rannic_0,_rannic_1],
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.183.236", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.183.236", port=443, username="Nemuadmin", password="nemuuser"
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

_vcu_k8s = K8S(namespace="cran8714", master_node=_vcu_master_node)

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

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1215008474",
    rus=[_ru_12, _ru_13],
)  # 4G

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu4.pdu_ports[12],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234400873",
)  # 4G

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_ru_12,_ru_13],
    oam_ip=NetworkAddress("10.44.46.158"),
    instance_id=1307,
)  # 4G

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.121.224",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.121.25",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)  # 4G

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    enbs=[_enb_sbts_1],
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    tl_cloud_topology="CLOUD_AIC_10_16_UTESRANSISO711",
#    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]

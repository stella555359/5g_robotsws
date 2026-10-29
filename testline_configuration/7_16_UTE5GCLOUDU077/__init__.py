__maintainer__ = "Monika Ceglarek"
__team__ = "I_MN_RAN_PZ2_WRO_2_SG_GMS"
__email__ = "I_MN_RAN_PZ2_WRO_2_SG@internal.nsn.com"
__owner_email__ = "monika.ceglarek@nokia.com"

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
from taf.config.testline.gnb.du import VDU, RANNIC
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.ue import PreferredVlan
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.pdu import FPFH
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import ATEN
from taf.config.testline.gnb.du import FHGW

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.206.35",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="ATEN",
)

_pdu2 = Gude(
    addr="10.44.177.176",
    port_numbers=[1, 3, 4, 8, 9],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2]

_rmod_1 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQL",
    serial_number="L1240202698",
    pdu_port=_pdu2.pdu_ports[9],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQE",
    serial_number="L1243110362",
    pdu_port=_pdu2.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQQ",
    serial_number="DH242024104",
    pdu_port=_pdu2.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHEGG",
    serial_number="K9242618296",
    pdu_port=_pdu2.pdu_ports[3],
)
_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="K9242817622",
    pdu_port=_pdu2.pdu_ports[8],
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.38.55", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.38.55", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

# _prerequisite_du = HelmChart(
#    name="aic-vdu-prerequisite",
#    yaml_file=os.path.join(_cfg_dir, 'vdu-prerequisite.yaml'),
# )

# _cnf_du = HelmChart(
#     name="aic-vdu",
#     yaml_file=os.path.join(_cfg_dir, 'vdu-cnf.yaml'),
# )

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    #  prerequisite=_prerequisite_du,
    #  cnf=_cnf_du,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.42.38.247", port=443, username="Nemuadmin", password="Nokia@123"
)

# FHGW information
_fhgw_0_ssh_connection_details = SshServiceDetails(
    addr="10.42.142.37", username="toor4nsn", port=22, password="Fhgw@nokia1243"
)

_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "/home/ute/topology-configs/CLOUD_5GC_dRNIC_1vDU_P_AP_LO_RRH_SWFH/vDUCNF00/PRIVATE_SANSA_FS_ECPRI_CMWV_TDD_AHEGG_AHPMDG_AQQQ_AVQE_AVQL/FHGW/fhgw-user-config_4.yaml"
    ),
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    fhgw_id=8680,
    default_ssh_connection_details=_fhgw_0_ssh_connection_details,
)

_vdu_0_rannic1 = RANNIC(serial_number="L1240401478", product_code="1791B.101")

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    instance_id=1,
    fhuc_vlans=[301, 301],
    # fhuc_vlans=[3523, 3523]
    rannics=[_vdu_0_rannic1],
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.93.155", username="Nemuadmin", password="Nokia@123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.93.155", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.44.249.132",
    username="core",
    password="system123",
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.249.132",
    username="core",
    password="system123",
    port=22,
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8680", master_node=_vcu_master_node)

# _prerequisite_cu = HelmChart(
#    name="aic-vcu-prerequisite",
#    yaml_file=os.path.join(_cfg_dir, "vcu-prerequisite.yaml"),
# )

# _cnf_cu = HelmChart(
#    name="aic-vcu",
#    yaml_file=os.path.join(_cfg_dir, "vcu-cnf.yaml"),
# )

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    # prerequisite=_prerequisite_cu,
    # cnf=_cnf_cu,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
)

_preferred_vlan = PreferredVlan(slot_id=SlotId.B1, port_id=1, preferred_vlan_id=295)

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                [CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")],
                hardware_type="ASIL",
                pdu_port=_pdu1.pdu_ports[5],
            )
        ]
    ),
    preferred_vlans=[_preferred_vlan],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.180",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts, _ue],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]

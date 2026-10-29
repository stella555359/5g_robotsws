__maintainer__ = "Piotr Bebel, Krzysztof Wojnar"
__team__ = "MN RAN RD VRF WRO2 10"
__email__ = "MN RAN RD VRF WRO2 10@internal.nsn.com"
__owner_email__ = "piotr.bebel@nokia.com, krzysztof.wojnar@nokia.com"

import os
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    CloudDeployment,
    HelmChart,
)

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.gnb.du import VDU, RANNIC
from taf.config.testline import Airphone
from taf.config.testline.ue import PreferredVlan
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId
from taf.config.testline.cloud_hosting import MasterNode, K8S
from taf.config.testline.pdu import ATEN

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu = ATEN(addr='10.44.206.35', port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdus = [_pdu]


_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.38.57", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.38.57", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details
)

_vdu_k8s = K8S(namespace="1-16-ute5gcloudtl8519", master_node=_vdu_master_node)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'vdu-prerequisite.yaml'),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'vdu-cnf.yaml'),
)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.45.186.131", port=443, username="Nemuadmin", password="nemuuser"
)

_vdu_rannic1 = RANNIC(serial_number="L1240400785", product_code="1791.101")

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=1,
    fhuc_vlans=[3813,3813],
    rannics=[_vdu_rannic1]
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.249.3", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.249.3", port=443, username="Nemuadmin", password="nemuuser"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.42.91.178", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.42.91.178", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="1-16-ute5gcloudtl8519", master_node=_vcu_master_node)

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
                pdu_port=_pdu.pdu_ports[4],
            )
        ]
    ),
    preferred_vlans=[_preferred_vlan],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.214",
        username="ute",
        password="ut3adminTC##!",
    ),
    connections=[_cbts, _ue],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC",
    ues=[_ue],
    pdus=_pdu,
)

__all__ = ["tl"]

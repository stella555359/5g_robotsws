__maintainer__ = "oana.vacarescu@nokia.com"
__email__ = "oana.vacaresc@nokia.com"
__owner_email__ = "oana.vacarescu@nokia.com"

import os
from taf.config.testline.lmi import SerialOverHost, SerialOverTcp, Local, Remote                                                                        
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.cu import CU
from taf.config.testline.gnb.gnb import CloudBts
from taf.config.testline import NetAct
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
    BmcConnectionDetails,
    OpenStackConnectionDetails     
)
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import VDU, FHGW, RANNIC
from taf.config.testline.cloud_hosting import MasterNode, K8S, HelmChart
from taf.config.testline.gnb.networkaddress import NetworkAddress
_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.49",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.49",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    "10.255.2.25",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude(
    "10.255.2.23",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"

vcu_server_mgmt = SshServiceDetails(
        addr="10.5.46.82",
        username="user_bmc",
        password="Aikon_1234",
    )

vdu_server_mgmt = SshServiceDetails(
        addr="10.5.46.83",
        username="user_bmc",
        password="Aikon_1234",
    )
    

_ru_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2227N40ND",
    pdu_port=_pdu_3.pdu_ports[3],
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIHA.value,
    serial_number="RW233403223",
    pdu_port=_pdu_3.pdu_ports[4],
)

_ru_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="BL2329H6094",
    pdu_port=_pdu_3.pdu_ports[10],
)

_rannic_0 = RANNIC(
    serial_number = "L1250200922",
    product_code = "AF1791.102",
    rus = [_ru_1, _ru_2, _ru_3],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="",
    rus=[_ru_1, _ru_2, _ru_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIM",
    hardware_version="473764A.102",
    serial_number="L1230610661",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])

_netact_ssh_2002 = SshServiceDetails(
    addr="10.82.47.15", username="omc", password='Medsql!_1893'
)

_netact_http_2002 = HttpConnectionDetails(
    addr="srnclab2002lbwas.srnblr.nsn-rdnet.net", username="omc", password="Medsql!_1893"

)
_netact_2002 = NetAct(_netact_ssh_2002, _netact_http_2002)

_netact_ssh_5012 = SshServiceDetails(
    addr="10.8.103.177", username="omc", password='Medsql!_1893'
)

_netact_http_5012 = HttpConnectionDetails(
    addr="srnclab5012lbwas.srnblr.nsn-rdnet.net", username="omc", password="Medsql!_1893"

)
_netact_5012 = NetAct(_netact_ssh_5012, _netact_http_5012)

_enb_lte = RealEnb(
    system_module=_smod_1,
    rms=[_ru_1, _ru_2, _ru_3],
    instance_id=621157,
    oam_ip=NetworkAddress("10.0.70.247"),
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

#_vdu1_oam_http_connection_details = HttpConnectionDetails(
#    addr="10.5.59.144",
#    username="Nemuadmin",
#    port=443,
#    password="Nokia@123",
#)

#_vdu_1 = VDU(
#    cloud_deployment="None",
#    oam_http_connection_details=_vdu1_oam_http_connection_details,
#    instance_id=623157,
#    fhuc_vlans=[301],
#)


_vdu_vnf_0 = DeploymentVnfStack(
    name="aic-vdu",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_vdu_values_override_0.yaml"
    ),
)

_vdu_intnet_0 = DeploymentNetworkStack(
    name="aic-intnet",
    yaml_file=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/aic_intnet_values_override_0.yaml"
    ),
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.5.59.11", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.59.11", username="core", password="system123", port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace="cran1", master_node=_vdu_master_node)

_cluster_preparation_du = HelmChart(
    name="aic-vdu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vdu-cluster-preparation.yaml'),
)

_prerequisite_du = HelmChart(
    name="aic-vdu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vdu-prerequisite.yaml'),
)

_cnf_du = HelmChart(
    name="aic-vdu",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vdu.yaml'),
)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    cluster_preparation=_cluster_preparation_du,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.5.59.144", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu = VDU(
    rannics=[_rannic_0],
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
#    fhgws=[],
    f1_c_ip_addr=NetworkAddress(
        v4="10.5.59.94",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.64/26"),
    ),
    f1_u_ip_addr=NetworkAddress(
        v4="10.5.59.95",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.64/26"),
    ),
    instance_id=1,
)





#_cu_oam_ssh_connection_details = SshServiceDetails(
#    addr="10.5.59.11", username="core", password="system123"
#)

#_cu_oam_http_connection_details = HttpConnectionDetails(
#    addr="10.5.59.145",
#    username="Nemuadmin",
#    port=443,
#    password="Nokia@123",
#)

#_cu = CU(
#    backhaul_site_oam_ip="None",
#    oam_ssh_connection_details=_cu_oam_ssh_connection_details,
#    oam_http_connection_details=_cu_oam_http_connection_details,
#)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.5.59.145",
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.5.59.11", username="core", password="system123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.5.59.145", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    xnu=NetworkAddress(
        v4="10.5.59.94",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    xnc=NetworkAddress(
        v4="10.5.59.95",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    f1c=NetworkAddress(
        v4="10.5.59.94",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    f1u=NetworkAddress(
        v4="10.5.59.95",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    ngc=NetworkAddress(
        v4="10.5.59.94",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    ngu=NetworkAddress(
        v4="10.5.59.95",
        vlan_id=201,
        routing_v4=RoutingInformation(gateway="10.5.12.65/24"),
    ),
    tracing=None,
    global_bts_id=62315701,
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.5.59.11", username="core", password="system123"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.5.59.11", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran2", master_node=_vcu_master_node)

_cluster_preparation_cu = HelmChart(
    name="aic-vcu-cluster-preparation",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-cluster-preparation.yaml'),
)

_prerequisite_cu = HelmChart(
    name="aic-vcu-prerequisite",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu-prerequisite.yaml'),
)

_cnf_cu = HelmChart(
    name="aic-vcu",
    yaml_file=os.path.join(_cfg_dir, 'common_helm_values/values-override.aic-vcu.yaml'),
)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    cluster_preparation=_cluster_preparation_cu,
    prerequisite=_prerequisite_cu,
    cnf=_cnf_cu,
)
#_cbts = CloudBts(
#    cu=_cu,
#    cloud_deployment=None,
#    dus=[_vdu_1],
#)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    vnf_name="vDU-623157",
    instance_id=623157, # parameter to do depricated!
)


_test_pc_1.connections.append(_cbts)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    enbs=[_enb_lte],
    nms=_netact_5012,
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
}

__all__ = ["tl"]


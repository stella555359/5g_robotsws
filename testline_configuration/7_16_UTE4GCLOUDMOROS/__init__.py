__maintainer__ = "Jaroslaw Wojczyszyn"
__email__ = "jaroslaw.wojczyszyn@nokia.com"

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
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.gnb.du import VDU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import (
    NetworkAddress,
    RoutingInformation,
    TafUeDataTransferProtocol,
)
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
vdu_container_registry = ContainerRegistry(url="ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net:443/vdu", username ="robot$vrf", password="ObCV0W80KGzzazO1aCRKDU25DozYU338")

_pdu1 = Gude(
    addr="10.44.200.207", port_numbers=[2,3], model="EPC", version="8041-1"
)  # --> 2-RMOD:AHLOA, 3-SMOD:ASIB P,

_pdus = [_pdu1]

_rannic1 = RANNIC(
    serial_number="L1242403214"
)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.45.186.26", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.45.186.26", username="core", password="system123", port=22
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

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
    prerequisite=_prerequisite_du,
    cnf=_cnf_du,
    container_registry=vdu_container_registry
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.45.186.154", port=443, username="Nemuadmin", password="Nokia@123"
)

_ru_1 = RU(ru_hw_group="", pdu_port=_pdu1.pdu_ports[2], radio_type="AHLOA", serial_number="BL2106G10HY")

_fhgw_0_ssh_connection_details = SshServiceDetails(
    addr="10.42.142.222", username="toor4nsn", port=22, password="Fhgw@nokia1243"
)

_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_5.yaml"
    ),
    rus=[_ru_1],
    fhgw_id=8683,
    default_ssh_connection_details=_fhgw_0_ssh_connection_details,

)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    fhgws=[_fhgw_0],
    instance_id=8683,
    global_bts_id=8683,
    fhuc_vlans=[301],
    rannics=[_rannic1],
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.249.26", username="Nemuadmin", password="Nokia@123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.249.26", username="Nemuadmin", password="Nokia@123", port=443
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.44.249.159", username="core", password="system123"
)
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.44.249.159", username="core", password="system123", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran8853", master_node=_vcu_master_node)

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

_ue_pc_ssh = SshServiceDetails("10.42.215.84", "wro5grrm", password="5gpass!1")

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
    expected_prompt="dummy_prompt",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_app_server_1,
    interval=1,
    version=2,
    interface_name="internet"
)

_pdn1 = PDNTafUeAndroidDetails(
    entryName="APN", apnName="internet", apnType=["DEFAULT"], protocol="IPV4"
)

_ue1 = TafUeAndroid(
    serial_number="RFCWC0BXAVP",
    ue_pc_address="10.42.215.84",
    data_transfer=[_data_transfer_iperf_1],
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "RFCWC0BXAVP",
        "S24",
    ],
    ssh_connection_details=_ue_pc_ssh,
    service_call_attach="16",
    service_call_detach="16",
    pdns=[_pdn1],
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.81",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vdu_k8s, _vcu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_AIC_7_16_UTE4GCLOUDMOROS",
    ues=[_ue1],
    pdus=_pdus,
)

__all__ = ["tl"]


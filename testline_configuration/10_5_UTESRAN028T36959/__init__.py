__maintainer__ = "shujin"
__team__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_2_GMS"
__email__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_2_GMS@internal.nsn.com"
__owner_email__ = "shunxin.jin@nokia-sbell.com"

import os

from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.lab_infrastructure import PxeServer
from taf.config.testline.core import RealCore
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.gnb.du import FHGW
from taf.config.testline.gnb.du import VDU
from taf.config.testline.cloud_hosting import MasterNode, K8S, HelmChart
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU
from taf.config.testline.appserver import AppServer
from taf.config.testline.ue import Android
from taf.config.testline.pdu import HBTE as PBHBTE
from taf.config.testline.attenuator import HBTE
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.nms import NMS
from taf.config.testline.nom import NOM

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# vCU
_cu = CU(
    # CU web UI ip address, oam interface ip of oam vm
    backhaul_site_oam_ip=NetworkAddress(v4="10.110.29.138"),
    # VCU OAM ssh connection, oam interface ip of oam vm
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.110.29.138", username="serviceuser", password="Pl(FzaYj5~c5;q"
    ),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.110.29.138", username="Nemuadmin", password="Nokia@123", port="443"
    ),
    tracing=None,
)

# ssh connection information of OE, for tenant user
_vcu_ssh_connection_details = SshServiceDetails(
    addr="10.110.10.70", username="cranuser10", password="systeM!23"
)
# ssh connection information of OE, for root user
_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.110.10.70", username="core", password="system123", port="22"
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran10", master_node=_vcu_master_node)

# _cluster_preparation_cu_0 = HelmChart(
#     name="aic-vcu-cluster-preparation",
#     yaml_file=os.path.join(_cfg_dir, 'vcu-cluster-preparation.yaml'),
# )
#
# _prerequisite_cu_0 = HelmChart(
#     name="aic-vcu-prerequisite",
#     yaml_file=os.path.join(_cfg_dir, 'vcu-prerequisite.yaml'),
# )
#
# _cnf_cu_0 = HelmChart(
#     name="aic-vcu",
#     yaml_file=os.path.join(_cfg_dir, 'vcu-cnf.yaml'),
# )

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
    # cluster_preparation=_cluster_preparation_cu_0,
    # prerequisite=_prerequisite_cu_0,
    # cnf=_cnf_cu_0,
)

# vDU_0
# ssh connection information of OE, for tenant user
_vdu_0_ssh_connection_details = SshServiceDetails(
    addr="10.56.9.178", username="core", password="system123"
)

# ssh connection information of OE, for cloudadmin user
_vdu_0_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.56.9.178", username="core", password="system123", port="22"
)

# master node information of OE
_vdu_0_master_node = MasterNode(
    k8s_connection_details=_vdu_0_k8s_connection_details,
    ssh_connection_details=_vdu_0_ssh_connection_details,
)

_vdu_0_k8s = K8S(namespace="cran1", master_node=_vdu_0_master_node)

# _cluster_preparation_du_0 = HelmChart(
#     name="aic-vdu-cluster-preparation",
#     yaml_file=os.path.join(_cfg_dir, 'vdu-cluster-preparation.yaml'),
# )
#
# _prerequisite_du_0 = HelmChart(
#     name="aic-vdu-prerequisite",
#     yaml_file=os.path.join(_cfg_dir, 'vdu-prerequisite.yaml'),
# )
#
# _cnf_du_0 = HelmChart(
#     name="aic-vdu",
#     yaml_file=os.path.join(_cfg_dir, 'vdu-cnf.yaml'),
# )

# VDU deployment configuration
_vdu_0_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_0_k8s,
    # cluster_preparation=_cluster_preparation_du_0,
    # prerequisite=_prerequisite_du_0,
    # cnf=_cnf_du_0,
)

# VDU oam http connection
_vdu_0_oam_http_connection_details = HttpConnectionDetails(
    addr="10.56.9.162", port="443", username="Nemuadmin", password="Nokia@123"
)

# vDU_1
_vdu_1_ssh_connection_details = SshServiceDetails(
    addr="10.56.9.130", username="core", password="systeM!23"
)

_vdu_1_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.56.9.130", username="core", password="system123", port="22"
)

_vdu_1_master_node = MasterNode(
    k8s_connection_details=_vdu_1_k8s_connection_details,
    ssh_connection_details=_vdu_1_ssh_connection_details,
)

_vdu_1_k8s = K8S(namespace="cran1", master_node=_vdu_1_master_node)

# VDU deployment configuration
_vdu_1_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_1_k8s,
)

_vdu_1_oam_http_connection_details = HttpConnectionDetails(
    addr="10.56.9.162", port="443", username="Nemuadmin", password="Nokia@123"
)

# RU PDU
_ru_pdu = PBHBTE(addr="10.97.65.6", port_numbers=[1, 2, 3, 4, 5, 6])

# PA configuration
_attenuator_5G = TopYoung(
    ip_addr="10.97.65.12",
    port=3000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="TAS16T16-51-120-1S-DES",
)

_ru_0 = RU(
    ru_hw_group="RU_INT_CPRI",
    radio_type="AEQE",
    serial_number="1M220112679",
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[1],
        _attenuator_5G.attenuator_ports[2],
        _attenuator_5G.attenuator_ports[3],
        _attenuator_5G.attenuator_ports[4],
        _attenuator_5G.attenuator_ports[5],
        _attenuator_5G.attenuator_ports[6],
        _attenuator_5G.attenuator_ports[7],
        _attenuator_5G.attenuator_ports[8],
        _attenuator_5G.attenuator_ports[9],
        _attenuator_5G.attenuator_ports[10],
        _attenuator_5G.attenuator_ports[11],
        _attenuator_5G.attenuator_ports[12],
        _attenuator_5G.attenuator_ports[13],
        _attenuator_5G.attenuator_ports[14],
        _attenuator_5G.attenuator_ports[15],
        _attenuator_5G.attenuator_ports[16],
    ],
    pdu_port=_ru_pdu.pdu_ports[4],
)

_ru_1 = RU(
    ru_hw_group="RU_INT_CPRI",
    radio_type="AEQE",
    serial_number="1M220112678",
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[1],
        _attenuator_5G.attenuator_ports[3],
        _attenuator_5G.attenuator_ports[5],
        _attenuator_5G.attenuator_ports[7],
    ],
    pdu_port=_ru_pdu.pdu_ports[5],
)

_ru_2 = RU(
    ru_hw_group="RU_INT_CPRI",
    radio_type="AEQE",
    serial_number="1M213504200",
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[2],
        _attenuator_5G.attenuator_ports[4],
        _attenuator_5G.attenuator_ports[6],
        _attenuator_5G.attenuator_ports[8],
    ],
    pdu_port=_ru_pdu.pdu_ports[6],
)

_ru_3 = RU(
    ru_hw_group="RU_INT_CPRI",
    radio_type="AZQI",
    serial_number="1M212323240",
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[9],
        _attenuator_5G.attenuator_ports[11],
    ],
    pdu_port=_ru_pdu.pdu_ports[1],
)

_ru_4 = RU(
    ru_hw_group="RU_INT_CPRI",
    radio_type="AZQI",
    serial_number="1M223349072",
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[10],
        _attenuator_5G.attenuator_ports[12],
    ],
    pdu_port=_ru_pdu.pdu_ports[2],
)

_ru_5 = RU(
    ru_hw_group="RU_INT_CPRI",
    radio_type="AZQJ",
    serial_number="1M224359338",
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[13],
        _attenuator_5G.attenuator_ports[15],
    ],
    pdu_port=_ru_pdu.pdu_ports[3],
)

# PXE server info for FHGW deployment
_pxe_server_ssh_info = SshServiceDetails(
    addr="10.56.9.30", username="ute", password="Cdslabadmin@"
)
_pxe_server = PxeServer(
    nfs_ip="10.56.9.30", ssh_connection_details=_pxe_server_ssh_info
)
# FHGW information
_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_0, _ru_1, _ru_2],
    pxe_server=_pxe_server,
)

_fhgw_1 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_1/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_3, _ru_4, _ru_5],
    pxe_server=_pxe_server,
)

# VDU global configuration
_vdu_0 = VDU(
    cloud_deployment=_vdu_0_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_0_oam_http_connection_details,
    fhgws=[_fhgw_0],
)

_vdu_1 = VDU(
    cloud_deployment=_vdu_1_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_1_oam_http_connection_details,
    fhgws=[_fhgw_1],
)

# mcc, mnc configuration
_realcore = RealCore(five_g=None, mcc="262", mnc="03", pdns=None)

#  iperf server info
_appserver_ssh = SshServiceDetails(
#   addr="10.106.243.149", username="ute", password="Nokia123!123"
     addr="10.56.201.182", username="ute", password="uteUTE!"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.56.201.182",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="54015",
)

_appserver = AppServer(_iperf)

# UE configuration
huawei_m40 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.65.13", username="Pz1", password="Nokia@2w3e4r5t6y7u"
    ),
    serial_number="7TD5T21520000428",
    server_dir="/cygdrive/c/pyro_server",
    # python_path="C:/Python27/python.exe",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei_m40"],
)

Samsung_vonr = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.65.13", username="Pz1", password="Nokia@2w3e4r5t6y7u"
    ),
    serial_number="RFCW41T79AZ",
    server_dir="/cygdrive/c/pyro_server",
    # python_path="C:/Python27/python.exe",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "samsung"],
)

_M80 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.65.13", username="Pz1", password="Nokia@2w3e4r5t6y7u"
    ),
    serial_number="0123456789ABCDEF",
    server_dir="/cygdrive/c/pyro_server",
    # python_path="C:/Python27/python.exe",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Qualcomm", "REAL_ANDROID_UE"],
)

_cbts = CloudBts(
    dus=[_vdu_0, _vdu_1],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
    instance_id="11071",
    global_bts_id="11071",
)


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.201.182", username="ute", password="uteUTE!"
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_AIC_SA_NSA_2XAndroid_1XvCU_2XvDU_OE20_2XFHGW_2XAEQE_1XAEQY_1XAZQI1",
    ues=[Samsung_vonr, huawei_m40, _M80],
    attenuator=_attenuator_5G,
    appserver=_appserver,
    core=_realcore,
)


__all__ = ["tl"]

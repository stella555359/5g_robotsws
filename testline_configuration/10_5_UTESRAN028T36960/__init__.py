__maintainer__ = "Yang Mengli"
__team__ = "I_NSB_MN_RAN_PZ_1_HAZ_3_GMS "
__email__ = "I_NSB_MN_RAN_PZ_1_HAZ_3@internal.nsn.com"
__owner_email__ = "mengli.yang@nokia-sbell.com"

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

# vCU_0
_cu_0 = CU(
    # CU web UI ip address, oam interface ip of oam vm
    backhaul_site_oam_ip=NetworkAddress(v4="10.110.29.143"),
    # VCU OAM ssh connection, oam interface ip of oam vm
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.110.29.143", username="serviceuser", password="Pl(FzaYj5~c5;q"
    ),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.110.29.143", username="Nemuadmin", password="nemuuser", port="443"
    ),
    tracing=None,
)

# ssh connection information of OE, for tenant user
_vcu_0_ssh_connection_details = SshServiceDetails(
    addr="10.110.10.70", username="cranuser15", password="systeM!23"
)
# ssh connection information of OE, for root user
_vcu_0_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.110.10.70", username="core", password="HZnokia321!", port="22"
)

_vcu_0_master_node = MasterNode(
    k8s_connection_details=_vcu_0_k8s_connection_details,
    ssh_connection_details=_vcu_0_ssh_connection_details,
)

_vcu_0_k8s = K8S(namespace="cran15", master_node=_vcu_0_master_node)

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

_vcu_0_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_0_k8s,
    # cluster_preparation=_cluster_preparation_cu_0,
    # prerequisite=_prerequisite_cu_0,
    # cnf=_cnf_cu_0,
)

# vCU_1
_cu_1 = CU(
    # VCU OAM ssh connection, oam interface ip of oam vm
    backhaul_site_oam_ip=NetworkAddress(v4="10.107.92.18"),
    # CU web UI ip address, oam interface ip of oam vm
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.107.92.18", username="serviceuser", password="Pl(FzaYj5~c5;q"
    ),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.107.92.18", username="Nemuadmin", password="nemuuser", port="443"
    ),
    tracing=None,
)

# VCU ssh connection information of OE, for tenant user
_vcu_1_ssh_connection_details = SshServiceDetails(
    addr="10.107.14.68", username="cranuser14", password="systeM!23"
)
# VCU ssh connection information of OE, for root user
_vcu_1_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.107.14.68", username="core", password="system123", port="22"
)

_vcu_1_master_node = MasterNode(
    k8s_connection_details=_vcu_1_k8s_connection_details,
    ssh_connection_details=_vcu_1_ssh_connection_details,
)

_vcu_1_k8s = K8S(namespace="cran14", master_node=_vcu_1_master_node)

_vcu_1_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_1_k8s,
)

# vDU_0
# ssh connection information of OE, for tenant user
_vdu_0_ssh_connection_details = SshServiceDetails(
    addr="10.70.85.130", username="cranuser1", password="systeM!23"
)

# ssh connection information of OE, for cloudadmin user
_vdu_0_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.70.85.130", username="core", password="system123", port="22"
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
    addr="10.70.85.162", port="443", username="Nemuadmin", password="nemuuser"
)

# vDU_1
_vdu_1_ssh_connection_details = SshServiceDetails(
    addr="10.69.104.226", username="cranuser1", password="systeM!23"
)

_vdu_1_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.69.104.226", username="core", password="system123", port="22"
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
    addr="10.69.108.2", port="443", username="Nemuadmin", password="nemuuser"
)

# RU PDU
_ru_pdu = PBHBTE(addr="10.97.122.137", port_numbers=[7, 8, 4, 6])

# PA configuration
_attenuator_5G = HBTE(
    ip_addr="10.97.65.68",
    port=5000,
    attenuation_port_numbers=[1, 18, 37, 54, 73, 90, 13, 29, 45],
    model="PA-16-16-6-127-0.5-B-S",
    version=None,
)

# RU configuration
_ru_1 = RU(
    ru_hw_group="RU_INT_ECPRI",
    radio_type="AEQY",
    serial_number="K9190632476",
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[1],
        _attenuator_5G.attenuator_ports[18],
        _attenuator_5G.attenuator_ports[37],
        _attenuator_5G.attenuator_ports[54],
        _attenuator_5G.attenuator_ports[73],
        _attenuator_5G.attenuator_ports[90],
        _attenuator_5G.attenuator_ports[13],
        _attenuator_5G.attenuator_ports[29],
        _attenuator_5G.attenuator_ports[45],
    ],
    pdu_port=_ru_pdu.pdu_ports[4],
)

# PXE server info for FHGW deployment
_pxe_server_ssh_info = SshServiceDetails(
    addr="10.97.120.170", username="root", password="pxe@systeM!23"
)
_pxe_server = PxeServer(
    nfs_ip="10.97.120.170", ssh_connection_details=_pxe_server_ssh_info
)
# FHGW information
_fhgw_0 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_0/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1],
    pxe_server=_pxe_server,
)

_fhgw_1 = FHGW(
    user_config_path=os.path.join(
        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_1/FHGW_0/fhgw_user_config_0.yaml"
    ),
    rus=[_ru_1],
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
    addr="10.106.243.149", username="ute", password="PZ1RRM3!5t6y7u"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.106.243.149",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="54015",
)

_appserver = AppServer(_iperf)

# UE configuration
_huawei1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.65.67", username="guoqianqian", password="Nokia@123"
    ),
    serial_number="H4K5T20A30008277",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei1"],
)

_android1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.65.67", username="guoqianqian", password="Nokia@123"
    ),
    serial_number="R5CR20G4AVK",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "samsung"],
)

_android2 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.65.67", username="guoqianqian", password="Nokia@123"
    ),
    serial_number="RFCW41M2F2T",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "samsung23"],
)

_Qualcomm1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.65.67", username="guoqianqian", password="Nokia@123"
    ),
    serial_number="A1KUS87",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Qualcomm", "REAL_ANDROID_UE"],
)

_Qualcomm2 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.65.67", username="guoqianqian", password="Nokia@123"
    ),
    serial_number="b5e2b67c",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Qualcomm", "REAL_ANDROID_UE2"],
)

_cbts_0 = CloudBts(
    dus=[_vdu_0],
    cu=_cu_0,
    cloud_deployment=_vcu_0_k8s_cloud_deployment,
    instance_id="10848",
    global_bts_id="10848",
)

_cbts_1 = CloudBts(
    dus=[_vdu_1],
    cu=_cu_1,
    cloud_deployment=_vcu_1_k8s_cloud_deployment,
    instance_id="10875",
    global_bts_id="10875",
)


# Testpc
# UTE IP address and User Name, Password
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.201.183", username="ute", password="uteUTE!"
    ),
    connections=[_cbts_0, _cbts_1],
)

# Testline configuration
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts_0, _cbts_1],
    tl_cloud_topology="CLOUD_5G_AIC_SA_2XAndroid_1XvCU_1XvDU_OE20_1XFHGW_3XAEQY_Common",
    ues=[_android1, _huawei1, _android2],
    attenuator=_attenuator_5G,
    appserver=_appserver,
    core=_realcore,
)

# only tl variable can be accessed by user

__all__ = ["tl"]

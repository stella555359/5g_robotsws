__maintainer__ = "Guo, Qianqian"
__team__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_2_GMS"
__email__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_2@internal.nsn.com"
__owner_email__ = "qianqian.guo@nokia-sbell.com"

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
    backhaul_site_oam_ip=NetworkAddress(v4="10.107.104.171"),
    # VCU OAM ssh connection, oam interface ip of oam vm
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.107.104.171", username="serviceuser", password="Pl(FzaYj5~c5;q"
    ),
    # VCU OAM http connection, oam interface ip of oam vm
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.107.104.171", username="Nemuadmin", password="Nokia@123", port="443"
    ),
    tracing=None,
)

# ssh connection information of OE, for tenant user
_vcu_0_ssh_connection_details = SshServiceDetails(
    addr="10.107.123.2", username="cranuser10", password="systeM!23"
)
# ssh connection information of OE, for root user
_vcu_0_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.107.123.2", username="core", password="system123", port="22"
)

_vcu_0_master_node = MasterNode(
    k8s_connection_details=_vcu_0_k8s_connection_details,
    ssh_connection_details=_vcu_0_ssh_connection_details,
)

_vcu_0_k8s = K8S(namespace="cran10", master_node=_vcu_0_master_node)

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

# vDU_0
# ssh connection information of OE, for tenant user
_vdu_0_ssh_connection_details = SshServiceDetails(
    addr="10.56.105.210", username="core", password="system123"
)

# ssh connection information of OE, for cloudadmin user
_vdu_0_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.56.105.210", username="core", password="system123", port="22"
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
    addr="10.56.105.242", port="443", username="Nemuadmin", password="nemuuser"
)


# RU PDU
_ru_pdu = PBHBTE(addr="10.97.122.137", port_numbers=[7, 8, 4, 6])

# PA configuration
_attenuator_5G = HBTE(
    ip_addr="10.97.83.32",
    port=5000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="PA-16-16-6-127-0.5-B-S",
    version=None,
)

_ru_1 = RU(
    ru_hw_group="RU_INT_CPRI",
    radio_type="AEQP",
    serial_number="1M212810184",
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
    pdu_port=_ru_pdu.pdu_ports[7],
)

_ru_2 = RU(
    ru_hw_group="RU_INT_CPRI",
    radio_type="AEQP",
    serial_number="1M214905137",
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[11],
        _attenuator_5G.attenuator_ports[12],
    ],
    pdu_port=_ru_pdu.pdu_ports[8],
)

_ru_3 = RU(
    ru_hw_group="RU_INT_CPRI",
    radio_type="AEQP",
    serial_number="1M212810182",
    attenuation_ports=[
        _attenuator_5G.attenuator_ports[15],
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
    rus=[_ru_1, _ru_2, _ru_3],
    pxe_server=_pxe_server,
)

#_fhgw_1 = FHGW(
#    user_config_path=os.path.join(
#        _cfg_dir, "DEP_SCF_FILES/CU_0/vDU_1/FHGW_0/fhgw_user_config_0.yaml"
#    ),
#    rus=[_ru_4],
#    pxe_server=_pxe_server,
#)

# VDU global configuration
_vdu_0 = VDU(
    cloud_deployment=_vdu_0_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_0_oam_http_connection_details,
    fhgws=[_fhgw_0],
)

#_vdu_1 = VDU(
#    cloud_deployment=_vdu_1_k8s_cloud_deployment,
#    oam_http_connection_details=_vdu_1_oam_http_connection_details,
#    fhgws=[_fhgw_1],
#)

# mcc, mnc configuration
_realcore = RealCore(five_g=None, mcc="262", mnc="03", pdns=None)

#  iperf server info
_appserver_ssh = SshServiceDetails(
    addr="10.56.201.181", username="ute", password="ute"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.56.201.181",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="54015",
)

_appserver = AppServer(_iperf)

# UE configuration
# Qualcomm8350
Qualcomm8350 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.83.6", username="csv1-tester", password="Nokia123!"
    ),
    serial_number="4035e192",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Qualcomm", "REAL_ANDROID_UE"],
)

samsung21 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.83.6", username="csv1-tester", password="Nokia123!"
    ),
    serial_number="R5CR92XZS7W",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "samsung21"],
)

redmi12 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.83.6", username="csv1-tester", password="Nokia123!"
    ),
    serial_number="7LAY7HXWHQ4P5XFE",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "xiaomi"],
)


huawei1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.83.6", username="csv1-tester", password="Nokia123!"
    ),
    serial_number="7TD0221327005743",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei_mate40"],
)

huawei2 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.83.6", username="csv1-tester", password="Nokia123!"
    ),
    serial_number="7TD0221529001408",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei_mate40"],
)

huawei3 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.83.6", username="csv1-tester", password="Nokia123!"
    ),
    serial_number="7TD5T21520000428",
    # 460
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei_mate40"],
)

_M80 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.83.6", username="csv1-tester", password="Nokia123!"
    ),
    serial_number="0123456789ABCDEF",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "MTP845"],
)


_cbts_0 = CloudBts(
    dus=[_vdu_0],
    cu=_cu_0,
    cloud_deployment=_vcu_0_k8s_cloud_deployment,
    instance_id="10870",
    global_bts_id="10870",
)


# UTE IP address and User Name, Password,
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.201.181", username="ute", password="uteUTE!"
    ),
    connections=[_cbts_0],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts_0],
    tl_cloud_topology="CLOUD_5G_AIC_SA_1xAndroid_1xvDU_OE19_1xFHGW_1xAEQP",
    ues=[huawei1,huawei2,huawei3,samsung21,_M80,redmi12,Qualcomm8350],
    attenuator=_attenuator_5G,
    appserver=_appserver,
    core=_realcore,
)

# only tl variable can be accessed by user
__all__ = ["tl"]

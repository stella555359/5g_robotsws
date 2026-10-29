__maintainer__ = "Liu AnAn"
__team__ = "NSB_MN_RAN_RD_VRF_HAZ1_2"
__email__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_2@internal.nsn.com"
__owner_email__ = "anan.liu@nokia-sbell.com"

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
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC
from taf.config.testline.ue import Android
from taf.config.testline.radio import RU


_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu = FACOM(
    addr="HBTE 10.108.190.163",
    port_numbers=[1],


)

_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.68.164.130", username="core", password="system123"
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.68.164.130", username="core", password="system123", port=22
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
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr="10.68.164.162", port=443, username="Nemuadmin", password="Nokia@123"
)

_vdu_0_rannic1 = RANNIC(serial_number="L1240804834", product_code="AF1791.101")

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
    instance_id=1,
    fhuc_vlans=[817],
    rannics=[_vdu_0_rannic1]
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.107.104.167", username="Nemuadmin", password="Nokia@123"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.107.104.167", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr="10.107.123.2", username="cranuser6", password="systeM!23"
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr="10.107.123.2", username="cranuser6", password="systeM!23", port=22
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace="cran6", master_node=_vcu_master_node)

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
    vnf_name="5gvDU-37357_TDD_DC",
    instance_id="37357",
    global_bts_id="37357",
)

########### Part 4: UE ####################################


_xiaomi12 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.108.190.164", username="noklab\csv5-tester", password="Nokia123!"
    ),
    serial_number="8885dec7",
    # 262 03
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    capabilities=["Commercial", "xiaomi12"],
)


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.111.93",
        username="ute",
        password="Ut3pa5s#ff97",
    ),
    connections=[_cbts, _xiaomi12],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_AIC_SA_1XRedmiK50Pro_1XvCU_1XvDU_HPE_1XAVQE",
    ues=[_xiaomi12],
    pdus=_pdu,
)

__all__ = ["tl"]


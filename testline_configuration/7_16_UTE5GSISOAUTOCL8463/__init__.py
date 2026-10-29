__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__owner__ = "Michal Tryba"
__maintainer__ = "Michal Tryba"
__email__ = "michal.tryba@nokia.com"

import os
from taf.config.testline import (
    TestLine,
    CloudBts,
    CU,
    VDU,
    FHGW,
    RU,
    CloudDeployment,
    MasterNode,
    K8S,
    K8SConnectionDetails,
    SshServiceDetails,
    HttpConnectionDetails,
)


_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_du_master_node = MasterNode(
    k8s_connection_details=K8SConnectionDetails(
        ip_addr="", port=None, username="", password=""
    ),
    ssh_connection_details=SshServiceDetails(
        addr="10.42.126.42", port=22, username="core", password="system123"
    ),
)

_du_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=K8S(namespace="cran1", master_node=_du_master_node),
)

_ru_1 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        port=22,
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    radio_type="AKQJ",
    serial_number="1M220224015",
    product_code="475824A.101",
)

_fhgw = FHGW(
    user_config_path="",
    rus=[_ru_1],
)

_du = VDU(
    instance_id=8463,
    cloud_deployment=_du_k8s_cloud_deployment,
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.126.106", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    fhgws=[_fhgw],
)

_cu_master_node = MasterNode(
    k8s_connection_details=K8SConnectionDetails(
        ip_addr="", port=None, username="", password=""
    ),
    ssh_connection_details=SshServiceDetails(
        addr="10.42.126.216", port=22, username="core", password="system123"
    ),
)

_cu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=K8S(namespace="cran8463", master_node=_cu_master_node),
)

_cu = CU(
    instance_id=8463,
    oam_ssh_connection_details=SshServiceDetails(addr="", username="", password=""),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.183.170", port=443, username="Nemuadmin", password="Nokia@123"
    ),
    backhaul_site_oam_ip="",
)

_bts = CloudBts(
    dus=[_du],
    cu=_cu,
    cloud_deployment=_cu_k8s_cloud_deployment,
)

tl = TestLine(
    test_pc=None,
    ues=[],
    gnbs=[_bts],
)

__all__ = ["tl"]

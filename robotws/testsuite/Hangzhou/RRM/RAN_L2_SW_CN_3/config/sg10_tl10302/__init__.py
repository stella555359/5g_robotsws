import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb.gnb import CloudBts, CU
from taf.config.testline.cloud_hosting import (
    CloudDeployment,
    OSP,
)


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


# Testpc
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.183.63", username="ute", password="ute"
    )
)


# cloud
_osp = OSP(
    control_nodes=[], compute_nodes=[], version="22R1", cloud_deployments=None
)


# CU
_cu = CU(
    backhaul_site_oam_ip="1.1.1.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="ute", password="ute"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="1.1.1.1", username="Nemuadmin", password="nemuuser"
    ),
)


# CLOUDBTS
_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    cloud_hosting=_osp,
)

_cbts = CloudBts(
    cu=_cu, cloud_deployment=_cloud_deployment
)

# UE
cpe = {
        'addr': "10.68.152.11",
        'username': "spark",
        'password': "spark",
        'cpe_type': 'SPARK_CPE',
        'spark_path': 'C:\\Program Files (x86)\\Spark1.1.2001.107\\Bin\\Spark.exe',
        'mcs_pc_ip': '10.108.183.125',
        'mcs_username': 'SG11-tester',
        'mcs_pwd': 'Nokia123!'
}

# Testline
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="",
    ues=[cpe],
)


__all__ = ["tl"]

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.ue import Android
from taf.config.testline.gnb.gnb import CloudBts, CU
from taf.config.testline.cloud_hosting import (
    CloudDeployment,
    OSP,
)


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


# Testpc
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.184.213", username="ute", password="ute"
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
_qualcomm = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.108.163.157", username="SG-tester", password="Nokia123!"
    ),
    serial_number=None,
    server_dir="C:/pyro_server",
    python_path="C:/Python38/python.exe",
)


# Testline
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="",
    ues=[_qualcomm],
)


__all__ = ["tl"]

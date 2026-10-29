import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline import RealEnb, Airscale, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.ue import Android
from taf.config.testline.gnb.gnb import CloudBts, CU
from taf.config.testline import VDU, FHGW
from taf.config.testline.cloud_hosting import (
    CloudDeployment,
    OSP,
)


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


# Testpc
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.164.11", username="ute", password="%EjvHVvvkQD6"
    )
)


# cloud
_osp = OSP(
    control_nodes=[], compute_nodes=[], version="22R1", cloud_deployments=None
)


# CU
_cu = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)


# CLOUDBTS
_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    cloud_hosting=_osp,
)


_common_unit_9 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
)


_airscale_0 = Airscale(common_units=[_common_unit_9])

_du_0 = RealEnb(
    airscale=_airscale_0
)


# BTS
_cbts = CloudBts(
        dus=[_du_0],
        cu=_cu,
        cloud_deployment=_cloud_deployment
        )

# UE
_qualcomm = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.108.134.26", username="SG-tester", password="Nokia123!"
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

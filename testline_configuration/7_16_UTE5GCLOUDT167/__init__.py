__maintainer__ = "Patryk Seman"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "patryk.seman@nokia.com"
__owner_email__ = "patryk.seman@nokia.com"

import os
from taf.config.testline.ue import MediaTek
from taf.config.testline.connection_details import (
    SshServiceDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.appserver import AppServer
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.core import RealCore

## common
__all__ = ["tl"]

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


# Test PC
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.142", username="ute", password="ute"
    )
)

# for MTK UE
_mtk_appserver_ssh = SshServiceDetails(
    addr="10.42.63.197", username="cmw_sg4", password="Zvm086!"
)
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_mtk_appserver_ssh,
    network_interface_address="10.57.163.xx",
    iperf_path="/usr/bin/iperf",
    ports=[54000, 61615, 61616, 61617, 61618],
)

_appserver = AppServer(_iperf_details_on_appserver)
_mtk_host_ssh = SshServiceDetails(
    addr="10.42.63.197", username="nokia5G", password="noki@123"
)
_iperf_details_on_mtk = IperfDataTransferDetails(
    ssh_connection_details=_mtk_host_ssh,
    network_interface_address="",
    iperf_path="/usr/bin/iperf",
    ports=[54000, 61615, 61616, 61617, 61618],
)

_mtk = MediaTek(
    ssh_connection_details=_mtk_host_ssh,
    server_dir="c:/pyro_server",
    server_port=8080,
    # if use petrus mtk, the edb_file_path should be set "auto"
    edb_file_path="C:/VMOLY.W19.43.p3/bach-mp-dnr-m70-of.w19.41.p9_v1_3GPP_15.6_June(VMOLY.W19.43.p3_IODTCBr.20191022.Build20191031.1200)/MDDB_MT6297_S00_VMOLY_W19_43_P3.EDB",
    imei="1234512345123478",
    apn_url="wap1.nokia.com",
    iperf_details=_iperf_details_on_mtk,
    capabilities=["REAL_MEDIATEK_UE"],
)

_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="wap3.nokia.com"),
    PDN(pdp_type=PDPTypes.IP.value, apn="wap2.nokia.com"),
]
_core = RealCore(pdns=_pdns)

tl = TestLine(
    test_pc=_host,
    ues=[_mtk],
    core=_core,
    # tl_cloud_topology='just for test',
    appserver=_appserver,
)

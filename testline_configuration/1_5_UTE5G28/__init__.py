__maintainer__ = "Huang Dan"
__team__ = "siso"
__email__ = "dan.huang@nokia-sbell.com"

import os
import yaml
import re
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale
from taf.config.testline import DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import FACOM
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import CU, ClassicalBts

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.106.213.103", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
# _test_pc_2 = TestPc(SshServiceDetails(addr='10.42.166.67', username='ute'),
#                    connections=[NetworkAddress(v4='192.168.255.126')])

_pdu_1 = FACOM(addr="10.106.208.165", port_numbers=[6], model="facom")
_pdu_2 = FACOM(addr="10.106.208.179", port_numbers=[5, 6], model="hbte")
_pdu_3 = FACOM(addr="10.106.208.161", port_numbers=[1], model="hbte")

_fsp_1 = CapacityUnit(
    addr="192.168.253.190",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101555",
    pdu_port=_pdu_1.pdu_ports[6],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212562555",
)
# _fct_2 = CommonUnit(SshServiceDetails(addr='192.168.255.1', username='toor4nsn', password='oZPS0POrRieRtu'),
#                     capacity_units=[_fsp_4, _fsp_5],
#                     pdu_port=_pdu_2.pdu_ports[2],
#                     hardware_type='ASIA',
#                     hardware_version='A.203',
#                     serial_number='L1173212320')
_smod_1 = Airscale([_fct_1])
# _smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="Panasonic(AHEGB)",
    serial_number="K9182210665",
    pdu_port=_pdu_2.pdu_ports[5],
    product_code="474090A.101",
)

_rmod_2 = RU(
    ru_hw_group="Panasonic(AHEGB)",
    serial_number="K9184605656",
    pdu_port=_pdu_2.pdu_ports[6],
    product_code="474090A.101",
)

_rmod_3 = RU(
    ru_hw_group="Panasonic(AHEGB)",
    serial_number="EA204150818",
    pdu_port=_pdu_3.pdu_ports[1],
    product_code="474090A.101",
)

# _enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
_du_1 = DU(
    airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3], f1_m_ip_addr="192.168.255.1"
)  # 5G S1 IP

# CU
_cu = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=10911, global_bts_id=10911
)


_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_ue_pc_ssh = SshServiceDetails(
    addr="10.68.160.34", username="siso2-tester", password="Nokia123!"
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.197",
    username="tdlte-tester",
    password="btstest",
)
_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.196",
    iperf_path="iperf",
)
_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="UQG5T20B19007308",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM31",
    iperf_details=_android_iperf,
    capabilities=["REAL_ANDROID_UE", "REAL_UE"],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_android_ue],
    appserver=_appserver,
    #    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_3xAHEGC",
)


__all__ = ["tl"]


# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1], enbs=[_enb_sbts_1])

# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Jia Han"
__email__ = "jia.han@nokia-sbell.com"

# import sys
# sys.path.append('/opt/ute/remoteswinglibrary/remoteswinglibrary-2.2.3.jar')
import subprocess, os
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.testpc import TestPc,Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
)

vm_password='UTE.debian12'

if os.path.exists('/etc/ute/vncpasswd'):
    vm_password=subprocess.check_output("sudo cat /etc/ute/vncpasswd", shell=True).decode('utf-8')

_ue_pc_ssh = SshServiceDetails('10.97.92.202', 'professor', password='Nokia@123')
_ue_pc_ssh_2 = SshServiceDetails('10.97.92.203', 'professor', password='Nokia@123')
_iperf_pc_ssh = SshServiceDetails('10.106.245.181', 'ute', password=vm_password)
_android_iperf = IperfDataTransferDetails(_iperf_pc_ssh, '40.1.1.254', None)
_android_ue1 = Android(ssh_connection_details=_ue_pc_ssh,
                       serial_number='SJE0217B04000334',  # Huawei P10
                       server_dir='/cygdrive/c/pyro_server/',
                       python_path='C:/Python27/python.exe',
                       qcat_path='C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe',
                       diag_cfg_path='C:/pyro_server/DIAG.cfg',
                       iperf_details=_android_iperf,
                       capabilities=['Nokia_8'],
                       )

_android_ue2 = Android(ssh_connection_details=_ue_pc_ssh_2,
                       serial_number='SJE0217B04000334',  # Huawei P10
                       server_dir='/cygdrive/c/pyro_server/',
                       python_path='C:/Python27/python.exe',
                       qcat_path='C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe',
                       diag_cfg_path='C:/pyro_server/DIAG.cfg',
                       iperf_details=_android_iperf,
                       capabilities=['SONY_XZ2'],
                       )

_android_ue3 = Android(ssh_connection_details=_ue_pc_ssh_2,
                       serial_number='9YS0219C17019509',  # Nokia 8.3 5G
                       server_dir='/cygdrive/c/pyro_server/',
                       python_path='C:/Python27/python.exe',
                       qcat_path='C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe',
                       diag_cfg_path='C:/pyro_server/DIAG.cfg',
                       iperf_details=_android_iperf,
                       capabilities=['Nokia_8.3_5G'],
                       )

_android_ue4 = Android(ssh_connection_details=_ue_pc_ssh_2,
                       serial_number='9YS0219C17019509',  # Mate30Pro5G
                       server_dir='/cygdrive/c/pyro_server/',
                       python_path='C:/Python27/python.exe',
                       qcat_path='C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe',
                       diag_cfg_path='C:/pyro_server/DIAG.cfg',
                       iperf_details=_android_iperf,
                       capabilities=['Mate30Pro5G'],
                       )

_android_ue5 = Android(ssh_connection_details=_ue_pc_ssh_2,
                       serial_number='9YS0219C17019509',  # Mate 30 Pro 5G
                       server_dir='/cygdrive/c/pyro_server/',
                       python_path='C:/Python27/python.exe',
                       qcat_path='C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe',
                       diag_cfg_path='C:/pyro_server/DIAG.cfg',
                       iperf_details=_android_iperf,
                       capabilities=['Mate_30_Pro_5G'],
                       )

# _pdu_1 = Gude("10.97.97.146", [1, 2, 3, 4, 5, 6, 7, 8], "TOPYOUNG", "")
_pdu_1 = Gude("10.56.206.182", [1, 2, 3, 4, 5, 6, 7, 8], "TOPYOUNG", "")
_pdu_2 = Gude("10.56.206.180", [1, 2, 3, 4, 5, 6, 7, 8], "HBTE", "")

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOH",
    hardware_version="476255A.102",
    serial_number="L1243307825",
)
_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type=RadioTypes.AVQC,
    serial_number="1M242008667",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.161", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.106.170.66"),
    instance_id=10620,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.229.38", username="ute", password='UTE.debian12'),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_rnc = RNC(
    rnc_id=301,
    oms_ip=NetworkAddress("10.27.127.36"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.94.92.155", username="Nemuadmin", password="Nemuadmin@123"
    ),
)

_bsc = BSC(
    name="BSC-1",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.70.120.39", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    ues=[ _android_ue1, _android_ue2, _android_ue3, _android_ue4, _android_ue5 ],
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_ASOG_1AEHC_1AZQP",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]


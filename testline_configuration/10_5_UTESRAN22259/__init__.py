# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Larry Ling"
__email__ = "larry.ling@nokia-sbell.com"

import os, subprocess
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
    HttpConnectionDetails,
)
from taf.config.testline import NetAct

vm_password='uteUTE!'
if os.path.exists('/etc/ute/vncpasswd'):
    vm_password=subprocess.check_output("sudo cat /etc/ute/vncpasswd", shell=True).decode('utf-8')


### BLR Labs ### start ###
_netact_ssh_1045 = SshServiceDetails('10.43.48.123', 'omc', password='Medsql!_1893')
_netact_http_1045 = HttpConnectionDetails('srnclab1045lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1045 = NetAct(_netact_ssh_1045, _netact_http_1045)

_netact_ssh_1046 = SshServiceDetails('10.43.48.159', 'omc', password='Medsql!_1893')
_netact_http_1046 = HttpConnectionDetails('srnclab1046lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1046 = NetAct(_netact_ssh_1046, _netact_http_1046)

_netact_ssh_1047 = SshServiceDetails('10.43.48.192', 'omc', password='Medsql!_1893')
_netact_http_1047 = HttpConnectionDetails('srnclab1047lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1047 = NetAct(_netact_ssh_1047, _netact_http_1047)

_netact_ssh_2003 = SshServiceDetails('10.82.47.46', 'omc', password='Medsql!_1893')
_netact_http_2003 = HttpConnectionDetails('srnclab2003lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_2003 = NetAct(_netact_ssh_2003, _netact_http_2003)

_netact_ssh_2014 = SshServiceDetails('10.82.47.190', 'omc', password='Medsql!_1893')
_netact_http_2014 = HttpConnectionDetails('srnclab2014lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_2014 = NetAct(_netact_ssh_2014, _netact_http_2014)
### BLR Labs ### start ###

### Hangzhou Labs ### start ###
_netact_ssh_chen4 = SshServiceDetails('10.108.248.82', 'omc', password='Nokia123!')
_netact_http_chen4 = HttpConnectionDetails('chen4lbwas.chen4.srnhz.nsn-rdnet.net', 'omc', password='Nokia123!')
_netact_chen4 = NetAct(_netact_ssh_chen4, _netact_http_chen4)
### Hangzhou Labs ### end ###

_ue_pc_ssh_1 = SshServiceDetails('10.97.92.202', 't05-tester', password='Nokia123!')
_ue_pc_ssh_2 = SshServiceDetails('10.97.92.203', 't05-tester', password='Nokia123!')

_iperf_pc_ssh = SshServiceDetails('10.106.245.178', 'ute', password=vm_password)
_android_iperf = IperfDataTransferDetails(_iperf_pc_ssh, '40.1.1.254', None)

_android_ue_1 = Android(ssh_connection_details=_ue_pc_ssh_1,
                       serial_number='9YS0220710005892',  # Mate 30 Pro 5G
                       server_dir='/cygdrive/c/pyro_server/',
                       python_path='C:/Python313/python.exe',
                       qcat_path='C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe',
                       diag_cfg_path='C:/pyro_server/DIAG.cfg',
                       iperf_details=_android_iperf,
                       capabilities=['Mate_30_Pro_5G'],
                       )

_android_ue_2 = Android(ssh_connection_details=_ue_pc_ssh_2,
                       serial_number='NB1GAD2791104124',  # Nokia
                       server_dir='/cygdrive/c/pyro_server/',
                       python_path='C:/Python313/python.exe',
                       qcat_path='C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe',
                       diag_cfg_path='C:/pyro_server/DIAG.cfg',
                       iperf_details=_android_iperf,
                       capabilities=['LTE'],
                       )

_pdu_1 = FACOM(
    addr="10.97.92.21",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_pdu_2 = FPFH(
    addr="10.97.92.231",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_pdu_3 = TopYoung(
    addr="10.97.97.148",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA190572959",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA190573031",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204008463",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1204307664",
)
_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB,
    serial_number="EA203761589",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.161", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type=RadioTypes.FXDB,
    serial_number="1M170932989",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.33", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.97.92.201"),
    instance_id=5050,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.106.245.178", username="ute", password='uteUTE!'),
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
    ues=[ _android_ue_1, _android_ue_2 ],
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIL_2ABIA_1ABIO_1FXDB_1AHEGB",
    bscs=[_bsc],
    rncs=[_rnc],
    nms=_netact_1046,
)

__all__ = ["tl"]

dhcp_server = {
	"ip": "10.97.92.238",
	"user": "ute",
	"password": "UTE.debian12",
}

fault_4297={'faultId': 4297, 'faultName': 'NTP Server 2a00:8a00:8000:101::5 unavailable'}
fault_4654={'faultId': 4654, 'faultName': 'Ethernet port security is disabled'}
fault_61642={'faultId': 61642, 'faultName': 'SSH enabled'}
fault_61652={'faultId': 61652, 'faultName': 'R&D Service Port enabled'}
fault_61649={'faultId': 61649, 'faultName': 'LMP access via port'}
fault_4655={'faultId': 4655, 'faultName': 'Automatic BTS Operator Certificate retrieval unsuccessful'}
fault_4293={'faultId': 4293, 'faultName': 'IP Traffic Capacity Limit'}
fault_61074={'faultId': 61074, 'faultName': 'CRL Update Failure'}
fault_7509={'faultId': 7509, 'faultName': 'EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM'}
ADDITIONAL_IGNORED_ALARMS=[fault_4297, fault_4654, fault_61642, fault_61652, fault_4655, fault_4293, fault_61074, fault_7509]

# dhcp_server = {
# 	"ip": "10.97.92.243",
# 	"user": "ute",
# 	"password": "UTE.debian12",
#   "note": "Backup DHCP server",
# }

__all__ = ["tl", "dhcp_server", "ADDITIONAL_IGNORED_ALARMS"]

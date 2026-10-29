# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Larry Ling"
__email__ = "larry.ling@nokia-sbell.com"

import sys
sys.path.append('/opt/ute/remoteswinglibrary/remoteswinglibrary-2.2.3.jar')
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
    HttpConnectionDetails,
)
from taf.config.testline import NetAct

vm_password='uteUTE!'

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


_pdu_1 = TopYoung(
    addr="10.97.97.146",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    # model="TopYoung",
)
_pdu_2 = TopYoung(
    addr="10.97.97.150",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    # model="TopYoung",
)
_pdu_3 = FPFH(
    addr="10.97.92.210",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    model="FPFH",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA222154540",
)
_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type=RadioTypes.AQQJ,
    serial_number="1M223936412",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.161", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHPB,
    serial_number="EA204457588",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.33", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.97.97.135"),
    instance_id=10673,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.106.245.181", username="ute", password='ute'),
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

### BLR Labs ### start ###
_netact_ssh_1013 = SshServiceDetails('10.41.146.72', 'omc', password='Medsql!_1893')
_netact_http_1013 = HttpConnectionDetails('srnclab1013lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1013 = NetAct(_netact_ssh_1013, _netact_http_1013)

_netact_ssh_1014 = SshServiceDetails('10.41.146.105', 'omc', password='Medsql!_1893')
_netact_http_1014 = HttpConnectionDetails('srnclab1014lbwas.srnblr.nsn-rdnet.net', 'omc', password='Medsql!_1893')
_netact_1014 = NetAct(_netact_ssh_1014, _netact_http_1014)

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


tl = TestLine(
    ues=[ _android_ue1, _android_ue2, _android_ue3, _android_ue4, _android_ue5 ],
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_ASOE_1AHGB_1AHPDA",
    bscs=[_bsc],
    rncs=[_rnc],
    nms=_netact_1047,
)

__all__ = ["tl"]

TraceConfiguration={
    "TraceReference": -1,
    "TraceTarget": "MRBTS-10673/LNBTS-10673/LNCEL-0",
    "CellTrace": {
      "CellTraceBasic": {
        "Job_type": "Trace only",
        "Trace_type": "Cell Trace",
        "Activation_profile": "System profile",
        "Description": "systemTest: Cell Trace",
        "START_DATE": "2000-12-12",
        "START_TIME": "23:59",
        "STOP_DATE": "2025-12-12",
        "STOP_TIME": "23:59"
      },
      "CellTraceAdvanced": {
        "TA": False,
        "UE_Throughput": False,
        "PCMD": False,
        "IP_of_TCE": "",
        "Port_of_TCE": "",
        "Limit_of_active_UEs": "100",
        "Maximum_buffering_time": "250",
        "Force_UE_IDs_repetition": "No",
        "Interface_selection": "NSNTI"
      },
      "CellTraceMDT": {
        "Report_interval": "5120 ms",
        "Report_amount": "4",
        "Data_anoymization": "No identity",
        "GNSS_positioning": False,
        "Obtain_location": False,
        "Fore_UE_consent": False,
        "Select_only_GNSS_UEs": False,
        "TA_synch": False,
        "PHR": False,
        "UE_RANK": False,
        "UL_SINR": False,
        "RIP": False,
        "PDSCH_PRB": False,
        "UE_BSR": False,
        "AoA": False,
        "PUSCH_PRB": False,
        "Limit_of_active_MDT_UEs": "100",
        "RIP_type": "Subframe and slot",
        "RIP_report_interval": "5 sec"
      }
    },
    "LoggedMDT": {
      "CELL_WORKING_MODE": "Configure and retrieve",
      "ANONYMIZATION_MDT_DATA": "IMEI-TAC",
      "TCE_ID": "0",
      "SELECT_ONLY_STANDALONE_GNSS_UES": False,
      "FORCE_UE_CONSTENT": True,
      "ENABLE_LOGGED_MDT_TRS_START": False,
      "LOGGING_DURATION": "10 min",
      "LOGGING_INTERVAL": "1280 ms",
      "COLLECTION_AREA": "PLMN ID",
      "Description": "systemTest: Logged MDT",
      "STOP_DATE": "2025-12-12",
      "STOP_TIME": "23:59"
    },
    "SubscriberTrace": {
      "Target": "IMSI",
      "NE": "FLEXINS-1 MME",
      "Traced number": "262033031521111",
      "Trace_type": "Subscriber",
      "Trace_level": "Maximum",
      "IP_of_TCE": "10.97.92.236",
      "MCC": "262",
      "MNC": "03",
      "Trigger event": {
        "Attach_TAU_Detach": True,
        "Handover": True,
        "Service_Request": True,
        "Bear_Act_Mod_Deat": True
      },
      "Interface": {
        "S1_MME": True,
        "X2": True,
        "Uu": True
      },
      "Description": "systemTest: Subscriber Trace",
      "START_DATE": "2000-12-12",
      "START_TIME": "23:59",
      "STOP_DATE": "2025-12-12",
      "STOP_TIME": "23:59"
    },
    "LTE_Activation_Profile": [
      "RRCEarlyDataRequest",
      "RRCConnectionReject"
    ]
}

# << Start of srnclab1045
# netact={
#     "SDV_ROOT_USER": "root",
#     "SDV_ROOT_PASSWORD": "arthur",
#     "SDV_DESKTOP_ADMIN_PASSWORD": "Medsql!_1893",
#     "SDV_DESKTOP_ADMIN_USER": "omc",
#     "SDV_DB_OMC_USER": "omc",
#     "SDV_DB_OMC_PASSWORD": "omc",
#     "SDV_DB_HOSTNAME_IP": "10.43.48.98",
#     "SDV_HOSTNAME_DSS1_IP": "10.43.48.98",
#     "SDV_HOSTNAME_DSS2_IP": "10.43.48.98",
#     "SDV_HOSTNAME_Q3_IP": "10.43.48.104",
#     "SDV_WEBSPHERE_APPSERVER_PRIMARY_IP": "10.43.48.123",
#     "SDV_WEBSPHERE_APPSERVER_SECONDARY_IP": "10.43.48.123",
#     "SDV_WEBSPHERE_CLUSTER_IP": "10.43.48.126",
#     "SDV_WEBSPHERE_APPSERVER_PRIMARY_FQDN": "srnclab1045node14srnblr.nsn-rdnet.net",
#     "SDV_WEBSPHERE_CLUSTER_FQDN": "srnclab1045lbwas.srnblr.nsn-rdnet.net"
# }
# End of srnclab1045 >> 

# << Start of srnclab1052
# netact = {
#     "SDV_ROOT_USER": "root",
#     "SDV_ROOT_PASSWORD": "arthur",
#     "SDV_DESKTOP_ADMIN_PASSWORD": "Medsql!_1893",
#     "SDV_DESKTOP_ADMIN_USER": "omc",
#     "SDV_DB_OMC_USER": "omc",
#     "SDV_DB_OMC_PASSWORD": "omc",
#     "SDV_DB_HOSTNAME_IP": "10.63.2.143",
#     "SDV_HOSTNAME_DSS1_IP": "10.63.2.143",
#     "SDV_HOSTNAME_DSS2_IP": "10.63.2.143",
#     "SDV_HOSTNAME_Q3_IP": "10.63.2.149",
#     "SDV_WEBSPHERE_APPSERVER_PRIMARY_IP": "10.63.2.159",
#     "SDV_WEBSPHERE_APPSERVER_SECONDARY_IP": "10.63.2.159",
#     "SDV_WEBSPHERE_CLUSTER_IP": "10.63.2.168",
#     "SDV_WEBSPHERE_APPSERVER_PRIMARY_FQDN": "srnclab1052node18srnblr.nsn-rdnet.net",
#     "SDV_WEBSPHERE_CLUSTER_FQDN": "srnclab1052lbwas.srnblr.nsn-rdnet.net"
# }
# End of srnclab1052 >>

# << Start of srnclab33
# netact={
# 	"SDV_ROOT_USER": "root",
# 	"SDV_ROOT_PASSWORD": "arthur",
# 	"SDV_DESKTOP_ADMIN_PASSWORD": "Medsql!_1893",
# 	"SDV_DESKTOP_ADMIN_USER": "omc",
# 	"SDV_DB_OMC_USER": "omc",
# 	"SDV_DB_OMC_PASSWORD": "omc",
# 	"SDV_DB_HOSTNAME_IP": "10.53.80.122",
# 	"SDV_HOSTNAME_DSS1_IP": "10.53.80.122",
# 	"SDV_HOSTNAME_DSS2_IP": "10.53.80.122",
# 	"SDV_HOSTNAME_Q3_IP": "10.53.80.128",
# 	"SDV_WEBSPHERE_APPSERVER_PRIMARY_IP": "10.53.80.134",
# 	"SDV_WEBSPHERE_APPSERVER_SECONDARY_IP": "10.53.80.134",
# 	"SDV_WEBSPHERE_CLUSTER_IP": "10.53.80.146",
# 	"SDV_WEBSPHERE_APPSERVER_PRIMARY_FQDN": "srnclab33node14srnblr.nsn-rdnet.net",
# 	"SDV_WEBSPHERE_CLUSTER_FQDN": "srnclab33lbwas.srnblr.nsn-rdnet.net",
# }
# End of srnclab33 >> 

# << Start of srnclab1014
# netact = {
#     "SDV_ROOT_USER": "root",
#     "SDV_ROOT_PASSWORD": "arthur",
#     "SDV_DESKTOP_ADMIN_PASSWORD": "Medsql!_1893",
#     "SDV_DESKTOP_ADMIN_USER": "omc",
#     "SDV_DB_OMC_USER": "omc",
#     "SDV_DB_OMC_PASSWORD": "omc",
#     "SDV_DB_HOSTNAME_IP": "10.41.146.89",
#     "SDV_HOSTNAME_DSS1_IP": "10.41.146.89",
#     "SDV_HOSTNAME_DSS2_IP": "10.41.146.89",
#     "SDV_HOSTNAME_Q3_IP": "10.41.146.95",
#     "SDV_WEBSPHERE_APPSERVER_PRIMARY_IP": "10.41.146.105",
#     "SDV_WEBSPHERE_APPSERVER_SECONDARY_IP": "10.41.146.105",
#     "SDV_WEBSPHERE_CLUSTER_IP": "10.41.146.114",
#     "SDV_WEBSPHERE_APPSERVER_PRIMARY_FQDN": "srnclab1014node18srnblr.nsn-rdnet.net",
#     "SDV_WEBSPHERE_CLUSTER_FQDN": "srnclab1014lbwas.srnblr.nsn-rdnet.net"
# }
# End of srnclab1014 >> 

# # << Start of srnclab1015
#netact = {
#	"SDV_ROOT_USER": "root",
#	"SDV_ROOT_PASSWORD": "arthur",
#	"SDV_DESKTOP_ADMIN_PASSWORD": "Medsql!_1893",
#	"SDV_DESKTOP_ADMIN_USER": "omc",
#	"SDV_DB_OMC_USER": "omc",
#	"SDV_DB_OMC_PASSWORD": "omc",
#	"SDV_DB_HOSTNAME_IP": "10.41.146.122",
#	"SDV_HOSTNAME_DSS1_IP": "10.41.146.122",
#	"SDV_HOSTNAME_DSS2_IP": "10.41.146.122",
#	"SDV_HOSTNAME_Q3_IP": "10.41.146.128",
#	"SDV_WEBSPHERE_APPSERVER_PRIMARY_IP": "10.41.146.134",
#	"SDV_WEBSPHERE_APPSERVER_SECONDARY_IP": "10.41.146.134",
#	"SDV_WEBSPHERE_CLUSTER_IP": "10.41.146.147",
#	"SDV_WEBSPHERE_APPSERVER_PRIMARY_FQDN": "srnclab1015node14srnblr.nsn-rdnet.net",
#	"SDV_WEBSPHERE_CLUSTER_FQDN": "srnclab1015lbwas.srnblr.nsn-rdnet.net",
#}
# # End of srnclab1015 >> 
# # << Start of srnclab1025
netact = {
	"SDV_ROOT_USER": "root",
	"SDV_ROOT_PASSWORD": "arthur",
	"SDV_DESKTOP_ADMIN_PASSWORD": "Medsql!_1893",
	"SDV_DESKTOP_ADMIN_USER": "omc",
	"SDV_DB_OMC_USER": "omc",
	"SDV_DB_OMC_PASSWORD": "omc",
	"SDV_DB_HOSTNAME_IP": "10.41.148.3",
	"SDV_HOSTNAME_DSS1_IP": "10.41.148.3",
	"SDV_HOSTNAME_DSS2_IP": "10.41.148.3",
	"SDV_HOSTNAME_Q3_IP": "10.41.148.9",
	"SDV_WEBSPHERE_APPSERVER_PRIMARY_IP": "10.41.148.15",
	"SDV_WEBSPHERE_APPSERVER_SECONDARY_IP": "10.41.148.15",
	"SDV_WEBSPHERE_CLUSTER_IP": "10.41.148.28",
	"SDV_WEBSPHERE_APPSERVER_PRIMARY_FQDN": "srnclab1025node14srnblr.nsn-rdnet.net",
	"SDV_WEBSPHERE_CLUSTER_FQDN": "srnclab1025lbwas.srnblr.nsn-rdnet.net",
}
# # End of srnclab1025 >> 

# # << Start of srnclab1027
# netact = {
# 	"SDV_DB_OMC_USER": "omc",
# 	"SDV_ROOT_USER": "root",
# 	"SDV_WEBSPHERE_APPSERVER_SECONDARY_IP": "10.41.148.99",
# 	"SDV_HOSTNAME_Q3_IP": "10.41.148.89",
# 	"SDV_WEBSPHERE_CLUSTER_FQDN": "srnclab1027lbwas.srnblr.nsn-rdnet.net",
# 	"SDV_WEBSPHERE_APPSERVER_PRIMARY_FQDN": "srnclab1027node18srnblr.nsn-rdnet.net",
# 	"SDV_DB_HOSTNAME_IP": "10.41.148.83",
# 	"SDV_ROOT_PASSWORD": "arthur",
# 	"SDV_HOSTNAME_DSS1_IP": "10.41.148.83",
# 	"SDV_DESKTOP_ADMIN_PASSWORD": "Medsql!_1893",
# 	"SDV_WEBSPHERE_APPSERVER_PRIMARY_IP": "10.41.148.99",
# 	"SDV_WEBSPHERE_CLUSTER_IP": "10.41.148.108",
# 	"SDV_DB_OMC_PASSWORD": "omc",
# 	"SDV_HOSTNAME_DSS2_IP": "10.41.148.83",
# 	"SDV_DESKTOP_ADMIN_USER": "omc",
# }
# # End of srnclab1027 >> 

# # << Start of srnclab1028
# netact= {
#     "SDV_ROOT_USER": "root",
#     "SDV_ROOT_PASSWORD": "arthur",
#     "SDV_DESKTOP_ADMIN_PASSWORD": "Medsql!_1893",
#     "SDV_DESKTOP_ADMIN_USER": "omc",
#     "SDV_DB_OMC_USER": "omc",
#     "SDV_DB_OMC_PASSWORD": "omc",
#     "SDV_DB_HOSTNAME_IP": "10.41.148.123",
#     "SDV_HOSTNAME_DSS1_IP": "10.41.148.123",
#     "SDV_HOSTNAME_DSS2_IP": "10.41.148.123",
#     "SDV_HOSTNAME_Q3_IP": "10.41.148.129",
#     "SDV_WEBSPHERE_APPSERVER_PRIMARY_IP": "10.41.148.139",
#     "SDV_WEBSPHERE_APPSERVER_SECONDARY_IP": "10.41.148.139",
#     "SDV_WEBSPHERE_CLUSTER_IP": "10.41.148.148",
#     "SDV_WEBSPHERE_APPSERVER_PRIMARY_FQDN": "srnclab1028node18srnblr.nsn-rdnet.net",
#     "SDV_WEBSPHERE_CLUSTER_FQDN": "srnclab1028lbwas.srnblr.nsn-rdnet.net"
# }
# # End of srnclab1028 >>

# # << Start of srnclab1013
# netact = {
# 	"SDV_ROOT_USER": "root",
# 	"SDV_ROOT_PASSWORD": "arthur",
# 	"SDV_DESKTOP_ADMIN_PASSWORD": "Medsql!_1893",
# 	"SDV_DESKTOP_ADMIN_USER": "omc",
# 	"SDV_DB_OMC_USER": "omc",
# 	"SDV_DB_OMC_PASSWORD": "omc",
# 	"SDV_DB_HOSTNAME_IP": "10.41.146.56",
# 	"SDV_HOSTNAME_DSS1_IP": "10.41.146.56",
# 	"SDV_HOSTNAME_DSS2_IP": "10.41.146.56",
# 	"SDV_HOSTNAME_Q3_IP": "10.41.146.62",
# 	"SDV_WEBSPHERE_APPSERVER_PRIMARY_IP": "10.41.146.72",
# 	"SDV_WEBSPHERE_APPSERVER_SECONDARY_IP": "10.41.146.72",
# 	"SDV_WEBSPHERE_CLUSTER_IP": "10.41.146.81",
# 	"SDV_WEBSPHERE_APPSERVER_PRIMARY_FQDN": "srnclab1013node18srnblr.nsn-rdnet.net",
# 	"SDV_WEBSPHERE_CLUSTER_FQDN": "srnclab1013lbwas.srnblr.nsn-rdnet.net",
# }
# # End of srnclab1013 >>

# # << Start of srnclab1016
# netact = {
# 	"SDV_ROOT_USER": "root",
# 	"SDV_ROOT_PASSWORD": "arthur",
# 	"SDV_DESKTOP_ADMIN_PASSWORD": "Medsql!_1893",
# 	"SDV_DESKTOP_ADMIN_USER": "omc",
# 	"SDV_DB_OMC_USER": "omc",
# 	"SDV_DB_OMC_PASSWORD": "omc",
# 	"SDV_DB_HOSTNAME_IP": "10.41.146.155",
# 	"SDV_HOSTNAME_DSS1_IP": "10.41.146.155",
# 	"SDV_HOSTNAME_DSS2_IP": "10.41.146.155",
# 	"SDV_HOSTNAME_Q3_IP": "10.41.146.161",
# 	"SDV_WEBSPHERE_APPSERVER_PRIMARY_IP": "10.41.146.167",
# 	"SDV_WEBSPHERE_APPSERVER_SECONDARY_IP": "10.41.146.167",
# 	"SDV_WEBSPHERE_CLUSTER_IP": "10.41.146.180",
# 	"SDV_WEBSPHERE_APPSERVER_PRIMARY_FQDN": "srnclab1016node14srnblr.nsn-rdnet.net",
# 	"SDV_WEBSPHERE_CLUSTER_FQDN": "srnclab1016lbwas.srnblr.nsn-rdnet.net",
# }
# # End of srnclab1016 >>

# << Start of srnclabxxxx

# End of srnclabxxxx >>


ctrlts=[
    {
        "parameterName": "certTypeForTlsAuth", "operation": "update", "value": "RSA",
     },
    {
        "parameterName": "ctrlTsId", "operation": "update", "value": 1,
    },
    {
        "parameterName": "extTraceReporting", "operation": "update", "value":
        [
            {
                "extCellTraceRep": True,
                "extUeTraceRep": True,
            }
        ],
    },
    {
        "parameterName": "maxUeTraceSessions", "operation": "update", "value": "60",
    },
    {
        "parameterName": "netActIpAddr", "operation": "update", "value": "127.0.0.1",
    },
    {
        "parameterName": "omsTracePortNum", "operation": "update", "value": 49392,
    },
    {
        "parameterName": "subscriberMDTObtainLocation", "operation": "update", "value": False,
    },
    {
        "parameterName": "tceIdLogMdtIpMap", "operation": "update", "value":
        [
            {
                "loggedPortNum": 49392,
                "loggedTCEId": 0,
                "loggedTCEIP": "127.0.0.1",
                # "loggedTCEIP": "192.168.0.1",
                "loggedTCEmcc": 262,
                "loggedTCEmnc": 3,
                "loggedTCEmncLen": 2,
            },
        ]
    },
    {
        "parameterName": "tceTlsEnabled", "operation": "update", "value": False,
     },
    {
        "parameterName": "tceTracePortNum", "operation": "update", "value": 49151,
     },
    {
        "parameterName": "traceRepMode", "operation": "update", "value":
        [
            {
                "cellTraceRepMode": "Offline",
                "ueTraceRepMode": "Offline"
            },
        ],
    },
    {
        # ueTraceInterfaceSelection was introduced in CB006542 in 23R3
        "parameterName": "ueTraceInterfaceSelection", "operation": "update", "value": "NSNTI",
    },
    {
        "parameterName": "vendorSpecTracing", "operation": "update", "value":
        [
            {
                "taTracing": False,
            }
        ],
    },
]

__all__ = ["tl", "TraceConfiguration", "netact", "ctrlts"]

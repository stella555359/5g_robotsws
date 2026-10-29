__maintainer__ = "radu.hirsovescu@nokia.com"
__email__ = "radu.hirsovescu@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.ran import BSC

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.48.3", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.48.137", username="rfs_rrm", password="Nokia2022!@1"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_bsc = BSC(
    name="BSC_TIMISOARA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.236", username="SYSTEM", password="SYSTEM"
    ),
)

_pdu_1 = Gude(
    addr="10.255.2.16",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.2.15",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_3 = Gude(
    addr="10.255.2.16",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[7].contactor = "NORMALLY_OPEN"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_OPEN"

_pdu_2.pdu_ports[12].contactor = "NORMALLY_OPEN"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_OPEN"

_pdu_3.pdu_ports[10].contactor = "NORMALLY_OPEN"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_OPEN"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_OPEN"

_fsp = CapacityUnit(
    addr="", hardware_type="FBBC", hardware_version="A.101", serial_number="L1142811238"
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="FSMF",
    hardware_version="A.101",
    serial_number="L6130616474",
    test_pc=_test_pc_master,
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_2.pdu_ports[12],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="TY145022670",
    test_pc=_test_pc_slave,
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.FXFC,
    serial_number="F7144704836",
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FXFC,
    serial_number="F7144701325",
    pdu_port=_pdu_1.pdu_ports[8],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.FRLB,
    serial_number="EA171162220",
    pdu_port=_pdu_3.pdu_ports[9],
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FRLB,
    serial_number="EA143061462",
    pdu_port=_pdu_3.pdu_ports[10],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FRLB,
    serial_number="EA143061270",
    pdu_port=_pdu_3.pdu_ports[12],
)
_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=10231,
)
_bts2g_gsm = Bts2G(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    bcf_id="1231",
    master=_enb_sbts,
)

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    bts2g_objects=[_bts2g_gsm],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_HRAN_RFS_FC_LG23_2xFXFC_3xFRLB",
    bscs=[_bsc],
)

UTE_UE_CONFIG = "/home/ute/10_18_UTESRANLG23/10_18_UTESRANLG23_Samsung.yaml"
UEM_CONFIG_PATH = "/home/ute/10_18_UTESRANLG23/ues2.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": False,
    "fail_if_wrn_threshold": True,
}

__all__ = ["tl"]

TL1 = {
    "HOST_IP": "10.5.48.3",
    "FR": {
        "F7144704836": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 7}},
        "F7144701325": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 8}},
        "EA171162220": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 9}},
        "EA143061462": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 10}},
        "EA143061270": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 12}},
    },
    "FSM": {
        "L6130616474": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 11}}
    },
    "BBMOD": {
        "L1142811238": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 11}}
    },
}
TL2 = {
    "FSM": {
        "TY145022670": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 12}}
    }
}

NODES = {
    "TEAM": "RFS_RRM",
    "TL1": {
        "HOST_IP": "10.5.48.3",
        "FR": {
            "F7144704836": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 7}
            },
            "F7144701325": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 8}
            },
            "EA171162220": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 9}
            },
            "EA143061462": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 10}
            },
            "EA143061270": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 12}
            },
        },
        "FSM": {
            "L6130616474": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 11}
            }
        },
        "EC": {
            "L1142811238": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 11}
            }
        },
    },
    "TL2": {
        "HOST_IP": "10.5.48.3",
        "FSM": {
            "TY145022670": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 12}
            }
        },
    },
}

SW_BUILDS_DIR_PATH = "/mnt/burak2/SW/eNB/FL17_SP/Branch/"
SCFC_1ST_RAT_REFERENCE_FILE_PATH = "/home/ute/robotlte/config/Timisoara/10_18_UTESRANLG23/node1/BTS_CLOUD_RFS_FC_LG00193E_2xFXFC_3xFRLB_FL17SP.xml"
SCFC_2ND_RAT_REFERENCE_FILE_PATH = ""

NETACT = {
    "pc_ip_addr": "10.92.135.24",
    "pc_ssh_user": "omc22",
    "pc_ssh_pass": "022--User",
    "sw_builds_dir_path": "/var/opt/nokia/oss/global/swm/swm_arch/",
    "start_page_url": "https://clab2086lbwas.netact.nsn-rdnet.net",
    "user": "omc22",
    "pass": "022--User",
    "mo_type": "MRBTS",
}

RAT_1ST = {
    "mplane_ip_addr": "10.5.40.231",
    "cplane_ip_addr": "10.5.39.231",
    "lmp_ip_addr": "192.168.255.129",
    "enb_id": "10231",
    "enb_user": "toor4nsn",
    "enb_pass": "oZPS0POrRieRtus",
    "startup_time": 400,
}

RAT_2ND = {
    "mplane_ip_addr": "10.5.32.1",
    "pc_ip_addr": "10.5.48.137",
    "lmp_ip_addr": "192.168.255.131",
    "bcf_or_wbts_id": "1231",
    "bsc_or_rnc_ip_addr": "10.5.42.236",
    "bsc_or_rnc_user": "SYSTEM",
    "bsc_or_rnc_pass": "SYSTEM",
    "bsc_or_rnc_port": "23",
    "startup_time": 720,
}

CP_PARAMS = {
    "sem_cli_path": r"/opt/btssm_cli_tools/",
    "ue_pc_files_path": r"C:\\PythonLibs",
    "cells_count": "6",
    "att_loops": "1",
    "rdrt_loops": "1",
    "csfb_loops": "1",
    "ho_loops": "3",
    "ft_loops": "6",
    "autoresponder": "00104",
    "data_transfer_protocol": "udp",
    "intra_ho_a3_tc_name": "[1][WRO.CP.TA.004] Intra eNB, inter-frequency A3 HO",
}

ATTENUATOR = {
    "ip_addr": "10.5.44.138",
    "port": "3001",
    "cells_to_ports_mapping": [[1, 2], [3, 4], [5, 6], [7, 8]],
    "scenario_attach": r"config/Timisoara/10_18_UTESRANLG23/attenuator_scenario_file_att.txt",
    "scenario_csfb": r"config/Timisoara/10_18_UTESRANLG23/attenuator_scenario_file_csfb.txt",
    "scenario_ho": r"config/Timisoara/10_18_UTESRANLG23/attenuator_scenario_file_handover.txt",
    "scenario_rdrt": r"config/Timisoara/10_18_UTESRANLG23/attenuator_scenario_file_rdrt.txt",
    "scenario_inter_freq_ho": r"config/Timisoara/10_18_UTESRANLG23/attenuator_scenario_file_inter_freq_handover.txt",
    "scenario_enacc": r"config/Timisoara/10_18_UTESRANLG23/attenuator_scenario_file_enacc.txt",
}
IPERF = {
    "pc_ip_addr": "10.5.26.67",
    "pc_ssh_user": "root",
    "pc_ssh_pass": "alcatel",
    "call_duration": "30",
}
UES_CONTROL_PC = {
    "ip_addr": "10.5.48.137",
    "ssh_user": "rfsharing",
    "ssh_pass": "Nokia2016!",
    "pyro_port": "9090",
    "ue_serial_number": "994f35ec",
    "ue_pc_files_path": r"C:\\PythonLibs",
    "drive_for_logs": [
        r"/mnt/burak2/",
        "Y:",
        r"\\10.154.10.14\GloVer",
        r"labnet\feve",
        "fevepass",
    ],
}

TA_UE_CONFIG = (
    "/home/ute/robotlte/config/Timisoara/10_18_UTESRANLG23/10_18_UTESRANLG23.yml"
)

TSHARK_S1_INTERFACE = {
    "is_used": "no",
    "logs_dir_path": "/tmp/" + RAT_1ST["mplane_ip_addr"],
    "pc_ip_addr": "10.5.48.251",
    "port": "2002",
    "pc_ssh_user": "ute",
    "pc_ssh_pass": "uteadmin",
    "app_dir_path": "/usr/local/bin",
    "interface": "ens4",
    "capture_filter": "host " + RAT_1ST["mplane_ip_addr"],
}

RAT_1ST_ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "BTS booted at .*? due to trs .*? reset",
    "ToP master service 10.5.16.101 unusable",
    "BTS time not corrected",
    "Temp Fault1",
    "LMP access via port .*?",
    ".*? Service Port enabled",
    "SSH enabled",
    "BTS internal SW management problem",
    "Unsigned software release has been successfully downloaded",
    "BTS Reset Cause",
    "Service account root access is enabled",
    "Ethernet port security is disabled",
    "Sanity Check Error",
]

RAT_2ND_ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "CRL update failure",
    "MMI CONNECTED TO BASE STATION",
    "WORKING SDCCH CHANNEL RATIO BELOW THRESHOLD",
    "BTS WITH NO TRANSACTIONS",
    "CONTINUOUS RESTARTS OF BCF/TRX",
    "BCF SW PACKAGE MAY BE DIFFERENT AS DEFINED AS A DEFAULT IN",
    "Service account root access is enabled",
    "Sanity Check Error",
]


def get_variables():
    variables = {
        "TL1": TL1,
        "TL2": TL2,
        "NODES": NODES,
        "SW_BUILDS_DIR_PATH": SW_BUILDS_DIR_PATH,
        "SCFC_1ST_RAT_REFERENCE_FILE_PATH": SCFC_1ST_RAT_REFERENCE_FILE_PATH,
        "SCFC_2ND_RAT_REFERENCE_FILE_PATH": SCFC_2ND_RAT_REFERENCE_FILE_PATH,
        "NETACT": NETACT,
        "RAT_1ST": RAT_1ST,
        "RAT_2ND": RAT_2ND,
        "CP_PARAMS": CP_PARAMS,
        "RAT_1ST_ALLOWED_ALARMS": RAT_1ST_ALLOWED_ALARMS,
        "RAT_2ND_ALLOWED_ALARMS": RAT_2ND_ALLOWED_ALARMS,
        "ATTENUATOR": ATTENUATOR,
        "IPERF": IPERF,
        "UES_CONTROL_PC": UES_CONTROL_PC,
        "TA_UE_CONFIG": TA_UE_CONFIG,
        "TSHARK_S1_INTERFACE": TSHARK_S1_INTERFACE,
    }
    return variables

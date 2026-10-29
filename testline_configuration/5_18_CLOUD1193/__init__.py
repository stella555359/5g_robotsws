__maintainer__ = "benjamin.rozsa@nokia.com"
__email__ = "benjamin.rozsa@nokia.com"

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
        addr="10.5.48.34", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.48.141", username="rfs_rrm", password="Nokia2022!@1"
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
    addr="10.255.2.14",
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

_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPEN"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPEN"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPEN"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPEN"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPEN"

_fsp = CapacityUnit(
    addr="", hardware_type="FBBC", hardware_version="A.101", serial_number="L1142712533"
)
_fsp = CapacityUnit(
    addr="", hardware_type="FBBC", hardware_version="A.101", serial_number="L1143725498"
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A.101",
    serial_number="NK153960095",
    test_pc=_test_pc_master,
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="L1141827232",
    test_pc=_test_pc_slave,
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_4T4R",
    radio_type=RadioTypes.FXED,
    serial_number="L1152300134",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_4T4R",  # ???
    radio_type=RadioTypes.FXED,
    serial_number="L1152303344",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_4T4R",
    radio_type=RadioTypes.FXED,
    serial_number="L1152206017",
    pdu_port=_pdu_1.pdu_ports[6],
)

_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.5.40.231"),
    instance_id=10193,
)
_bts2g_gsm = Bts2G(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    bcf_id="1193",
    master=_enb_sbts,
)

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    bts2g_objects=[_bts2g_gsm],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_HRAN_RFS_FCC_LG18_3xFXED",
    bscs=[_bsc],
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/5_18_CLOUD1193/5_18_CLOUD1193.yml"

__all__ = ["tl"]

TL1 = {
    "HOST_IP": "10.5.48.34",
    "FR": {
        "L1152300134": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.14", "port": 2}},
        "L1152303344": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.14", "port": 4}},
        "L1152206017": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.14", "port": 6}},
    },
    "FSM": {
        "NK153960095": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 1}},
        "BBMOD": {
            "L1142712533": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 1}
            },
            "L1143725498": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 2}
            },
        },
    },
}

TL2 = {
    "FSM": {
        "L1141827232": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 2}}
    }
}


NODES = {
    "TEAM": "RFS_RRM",
    "TL1": {
        "HOST_IP": "10.5.48.34",
        "FR": {
            "L1152300134": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.14", "port": 2}
            },
            "L1152303344": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.14", "port": 4}
            },
            "L1152206017": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.14", "port": 6}
            },
        },
        "FSM": {
            "NK153960095": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 1}}
        },
        "EC": {
            "L1142712533": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 1}
            },
            "L1143725498": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 1}
            },
        },
    },
    "TL2": {
        "HOST_IP": "10.5.48.34",
        "FSM": {
            "L1141827232": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 2}}
        },
    },
}

SW_BUILDS_DIR_PATH = "/mnt/burak2/SW/eNB/FL17_SP/Branch/"
SCFC_1ST_RAT_REFERENCE_FILE_PATH = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD1193/node1/BTS_CLOUD_RFS_FCC_LG00627_3xFXED_SBTS00.xml"
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
    "mplane_ip_addr": "10.5.40.193",
    "cplane_ip_addr": "10.5.39.193",
    "lmp_ip_addr": "192.168.255.129",
    "enb_id": "10193",
    "enb_user": "toor4nsn",
    "enb_pass": "oZPS0POrRieRtu",
    "startup_time": 400,
}

RAT_2ND = {
    "mplane_ip_addr": "10.5.32.1",
    "pc_ip_addr": "10.5.48.141",
    "lmp_ip_addr": "192.168.255.131",
    "bcf_or_wbts_id": "1193",
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
    "data_transfer_protocol": "tcp",
    "intra_ho_a3_tc_name": "[1][WRO.CP.TA.004] Intra eNB, inter-frequency A3 HO",
}

ATTENUATOR = {
    "ip_addr": "10.5.44.0",
    "port": "3001",
    "cells_to_ports_mapping": [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10], [11, 12]],
    "scenario_attach": r"config/Timisoara/5_18_CLOUD1193/attenuator_scenario_file_att.txt",
    "scenario_csfb": r"config/Timisoara/5_18_CLOUD1193/attenuator_scenario_file_csfb.txt",
    "scenario_ho": r"config/Timisoara/5_18_CLOUD1193/attenuator_scenario_file_handover.txt",
    "scenario_rdrt": r"config/Timisoara/5_18_CLOUD1193/attenuator_scenario_file_rdrt.txt",
    "scenario_inter_freq_ho": r"config/Timisoara/5_18_CLOUD1193/attenuator_scenario_file_inter_freq_handover.txt",
    "scenario_enacc": r"config/Timisoara/5_18_CLOUD1193/attenuator_scenario_file_enacc.txt",
}
IPERF = {
    "pc_ip_addr": "10.5.26.69",
    "pc_ssh_user": "root",
    "pc_ssh_pass": "alcatel",
    "call_duration": "30",
}
UES_CONTROL_PC = {
    "ip_addr": "10.5.48.141",
    "ssh_user": "rfsharing",
    "ssh_pass": "Nokia2016!",
    "pyro_port": "9090",
    "ue_serial_number": "xxxxxx",
    "ue_pc_files_path": r"C:\\PythonLibs",
    "drive_for_logs": [
        r"/mnt/burak2/",
        "Y:",
        r"\\10.154.10.14\GloVer",
        r"labnet\feve",
        "fevepass",
    ],
}

TA_UE_CONFIG = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD1193/5_18_CLOUD1193.yml"

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
    "Service account root access is enabled",
    "Ethernet port security is disabled",
    "BTS Reset Cause",
]

RAT_2ND_ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "CRL update failure",
    "MMI CONNECTED TO BASE STATION",
    "WORKING SDCCH CHANNEL RATIO BELOW THRESHOLD",
    "BTS WITH NO TRANSACTIONS",
    "CONTINUOUS RESTARTS OF BCF/TRX",
    "BCF SW PACKAGE MAY BE DIFFERENT AS DEFINED AS A DEFAULT IN",
]


TruTable = {
    "10 MHz": [33.416, 69.82, 68.534, 20.45],
    "15 MHz": [52.487, 104.974, 103.180, 32.7],
    "20 MHz": [71.993, 143.986, 141.567, 49.185],
    "5 MHz": [16.296, 32.591, 29.826, 8.88],
    "3 MHz": [8.800, 17.599, 0, 5.8901],
}


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

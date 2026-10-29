__maintainer__ = "oana.bonchis@nokia.com"
__email__ = "oana.bonchis@nokia.com"

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
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.48.11", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.48.12", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_pdu_1 = Gude(
    addr="10.255.2.114",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.2.115",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[7].contactor = "NORMALLY_OPEN"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_OPEN"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPEN"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPEN"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPEN"


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="FSMF",
    hardware_version="A.101",
    serial_number="KQ170730020",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.5", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="F7170802447",
    test_pc=_test_pc_2,
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.FRGY,
    serial_number="EA170731370",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FRGY,
    serial_number="EA170731363",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.FRGY,
    serial_number="EA170731366",
    pdu_port=_pdu_2.pdu_ports[3],
)

_enb_lte_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=10396,
)
_nb_wcdma_1 = NB(
    system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3], slave=_enb_lte_1
)

_rnc = RNC(
    rnc_id="10396",
    oms_ip="10.27.31.235",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.56", username="_nokadmin", password="_P@ssword123"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_lte_1],
    nb_objects=[_nb_wcdma_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_F_WL35_3xFRGY",
    rncs=[_rnc],
)

# UTE_UE_CONFIG = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2396/5_18_CLOUD2396.yaml"

__all__ = ["tl"]

######################### UCA-653 - new version of init #######################################
TL1 = {
    "HOST_IP": "10.5.48.12",
    "FR": {
        "EA170731370": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.115", "port": 1}},
        "EA170731363": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.115", "port": 2}},
        "EA170731366": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.115", "port": 3}},
    },
    "FSM": {
        "F7170802447": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.114", "port": 8}}
    },
}

TL2 = {
    "HOST_IP": "10.5.48.11",
    "FSM": {
        "KQ170730020": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.114", "port": 7}}
    },
    "BBMOD": {
        "L1132014911": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.114", "port": 7}}
    },
}


NODES = {
    "TEAM": "RFS_RRM",
    "TL1": {
        "HOST_IP": "10.5.48.12",
        "FR": {
            "EA170731370": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.115", "port": 1}
            },
            "EA170731363": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.115", "port": 2}
            },
            "EA170731366": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.115", "port": 3}
            },
        },
        "FSM": {
            "F7170802447": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.114", "port": 8}
            }
        },
    },
    "TL2": {
        "HOST_IP": "10.5.48.11",
        "FSM": {
            "KQ170730020": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.114", "port": 7}
            }
        },
        "EC": {
            "L1132014911": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.114", "port": 7}
            }
        },
    },
}

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"
SCFC_1ST_RAT_REFERENCE_FILE_PATH = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2396/node1/BTS_CLOUD_RFS_F_WL00610_3xFRGY_FL17A.xml"
SCFC_2ND_RAT_REFERENCE_FILE_PATH = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2396/node1/BTS_CLOUD_RFS_F_WL00610_3xFRGY_WBTS.xml"

NETACT = {
    "pc_ip_addr": "10.91.149.56",
    "pc_ssh_user": "omc22",
    "pc_ssh_pass": "022--User",
    "sw_builds_dir_path": "/var/opt/nokia/oss/global/swm/swm_arch/",
    "start_page_url": "https://clab771lbwas.netact.nsn-rdnet.net",
    "user": "omc22",
    "pass": "022--User",
    "mo_type": "MRBTS",
}

RAT_1ST = {
    "mplane_ip_addr": "10.15.249.96",
    "cplane_ip_addr": "10.15.248.96",
    "lmp_ip_addr": "192.168.255.127",
    "enb_id": "10396",
    "enb_user": "toor4nsn",
    "enb_pass": "oZPS0POrRieRtu",
    "startup_time": 620,
}

RAT_2ND = {
    "mplane_ip_addr": "10.15.245.96",
    "pc_ip_addr": "10.5.48.11",
    "lmp_ip_addr": "192.168.255.129",
    "bcf_or_wbts_id": "10396",
    "bsc_or_rnc_ip_addr": "10.55.0.56",
    "bsc_or_rnc_user": "_nokadmin",
    "bsc_or_rnc_pass": "_P@ssword123",
    "bsc_or_rnc_port": "22",
    "startup_time": 720,
}

CP_PARAMS = {
    "sem_cli_path": r"/opt/btssm_cli_tools/",
    "ue_pc_files_path": r"C:\\PythonLibs",
    "cells_count": "3",
    "att_loops": "1",
    "rdrt_loops": "1",
    "csfb_loops": "1",
    "ho_loops": "3",
    "ft_loops": "3",
    "autoresponder": "00104",
    "data_transfer_protocol": "udp",
    "intra_ho_a3_tc_name": "[1][WRO.CP.TA.004] Intra eNB, inter-frequency A3 HO",
}
CP_HO_A5_INTRA_ENB_INTRA_FREQ = {
    "LNCEL:threshold3": "58",
    "LNCEL:threshold3a": "59",
    "LNCEL:a3Offset": "30",
    "LNCEL:threshold1": "90",
    "LNCEL:threshold2a": "85",
}

CP_HO_A5_INTRA_ENB_INTER_FREQ = {
    "LNHOIF:a3OffsetRsrpInterFreq": "30",
    "LNCEL:threshold2InterFreq": "75",
    "LNCEL:threshold2a": "85",
    "LNHOIF:measQuantInterFreq": "rsrp",
    "LNHOIF:threshold3InterFreq": "60",
    "LNHOIF:threshold3aInterFreq": "59",
    "LNCEL:threshold1": "90",
}

CP_HO_IRAT = {
    "LNCEL:threshold1": "90",
    "LNCEL:threshold2a": "85",
    "LNCEL:threshold2Wcdma": "75",
    "LNHOW:b2Threshold1Utra": "59",
    "LNHOW:b2Threshold2UtraRscp": "35",
}

CP_HO_A3_INTRA_ENB_INTRA_FREQ = {
    "LNCEL:a3Offset": "3",
    "LNCEL:threshold3": "58",
    "LNCEL:threshold3a": "59",
    "LNCEL:threshold1": "90",
    "LNCEL:threshold2a": "85",
}

CP_HO_A3_INTRA_ENB_INTER_FREQ = {
    "LNHOIF:a3OffsetRsrpInterFreq": "6",
    "LNCEL:threshold2InterFreq": "75",
    "LNCEL:threshold2a": "85",
    "LNHOIF:measQuantInterFreq": "rsrp",
    "LNHOIF:threshold3InterFreq": "60",
    "LNHOIF:threshold3aInterFreq": "59",
    "LNCEL:threshold1": "90",
}
ATTENUATOR = {
    "ip_addr": "10.5.59.3",
    "port": "3001",
    "cells_to_ports_mapping": [[1, 2], [3, 4], [5, 6]],
    "scenario_attach": r"config/Timisoara/5_18_CLOUD2396/attenuator_scenario_file_att.txt",
    "scenario_csfb": r"config/Timisoara/5_18_CLOUD2396/attenuator_scenario_file_csfb.txt",
    "scenario_ho": r"config/Timisoara/5_18_CLOUD2396/attenuator_scenario_file_handover.txt",
    "scenario_rdrt": r"config/Timisoara/5_18_CLOUD2396/attenuator_scenario_file_rdrt.txt",
    "scenario_inter_freq_ho": r"config/Timisoara/5_18_CLOUD2396/attenuator_scenario_file_inter_freq_handover.txt",
    "scenario_enacc": r"config/Timisoara/5_18_CLOUD2396/attenuator_scenario_file_enacc.txt",
}
IPERF = {
    "pc_ip_addr": "10.5.26.68",
    "pc_ssh_user": "root",
    "pc_ssh_pass": "alcatel",
    "call_duration": "30",
}
UES_CONTROL_PC = {
    "ip_addr": "10.5.48.144",
    "ssh_user": "rfs_rrm",
    "ssh_pass": "Nokia02!",
    "pyro_port": "9090",
    "ue_serial_number": "a1c823e3",
    "ue_pc_files_path": r"C:\\PythonLibs",
    "drive_for_logs": [
        r"/mnt/burak2/",
        "Y:",
        r"\\10.154.10.14\GloVer",
        r"labnet\feve",
        "fevepass",
    ],
}

TA_UE_CONFIG = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2396/5_18_CLOUD2396.yml"

TSHARK_S1_INTERFACE = {
    "is_used": "yes",
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
    "Synchronization lost",
    "BTS booted at .*? due to trs .*? reset",
    "LMP access via port .*?",
    ".*? Service Port enabled",
    "SSH enabled",
    "Transport layer connection failure in X2 interface",
    "Service account root access is enabled",
    "Ethernet port security is disabled",
    "Failure in internal BTS connection or connection to 3rd party tool",
    "Failure in connection between BTS and BTSMED or 3rd party tool",
    "Temp Fault1",
]

RAT_2ND_ALLOWED_ALARMS = ["BTS booted at .*? due to trs management reset"]


TruTable = {
    "10 MHz": [33.416, 69.82, 68.534, 20.45],
    "15 MHz": [52.487, 104.974, 103.180, 32.7],
    "20 MHz": [71.993, 142, 141.567, 43],
    "5 MHz": [14.5, 29, 29.826, 5.03],
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

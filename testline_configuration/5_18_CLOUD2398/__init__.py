__maintainer__ = "oana.vacarescu@nokia.com"
__email__ = "oana.vacarescu@nokia.com"

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
        addr="10.5.48.39", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.48.38", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_pdu_1 = Gude(
    addr="10.255.2.117",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.2.116",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPEN"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPEN"

_pdu_2.pdu_ports[8].contactor = "NORMALLY_OPEN"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_OPEN"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_OPEN"


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="FSMF",
    hardware_version="A.101",
    serial_number="F7173800031",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.127", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="AS173711844",
    test_pc=_test_pc_2,
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.FHDB,
    serial_number="1M171423366",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FHDB,
    serial_number="1M171423621",
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.FHDB,
    serial_number="1M164752384",
    pdu_port=_pdu_2.pdu_ports[12],
)

_enb_lte_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.15.249.60"),
    instance_id=10398,
)
_nb_wcdma_1 = NB(
    system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3], slave=_enb_lte_1
)

_rnc = RNC(
    rnc_id="10398",
    oms_ip="10.27.31.235",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.56", username="_nokadmin", password="_P@ssword123"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_lte_1],
    nb_objects=[_nb_wcdma_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_F_WL37_3xFHDB",
    rncs=[_rnc],
)

# UTE_UE_CONFIG = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2398/5_18_CLOUD2398.yml"
# UEM_CONFIG_PATH = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2398/ues2.yaml"

__all__ = ["tl"]

TL1 = {
    "HOST_IP": "10.5.48.39",
    "FR": {
        "1M171423366": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.116", "port": 8}},
        "1M171423621": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.116", "port": 10}},
        "1M164752384": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.116", "port": 12}},
    },
    "FSM": {
        "F7173800031": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.117", "port": 6}}
    },
}

TL2 = {
    "HOST_IP": "10.5.48.38",
    "FSM": {
        "AS173711844": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.117", "port": 5}}
    },
}

NODES = {
    "TEAM": "RFS_RRM",
    "TL1": {
        "HOST_IP": "10.5.48.39",
        "FR": {
            "1M171423366": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.116", "port": 8}
            },
            "1M171423621": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.116", "port": 10}
            },
            "1M164752384": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.116", "port": 12}
            },
        },
        "FSM": {
            "F7173800031": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.117", "port": 6}
            }
        },
    },
    "TL2": {
        "HOST_IP": "10.5.48.38",
        "FSM": {
            "AS173711844": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.117", "port": 5}
            }
        },
    },
}


SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"
SCFC_1ST_RAT_REFERENCE_FILE_PATH = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2398/node1/BTS_CLOUD_RFS_F_WL00439_3xFHDB_FL18A.xml"
SCFC_2ND_RAT_REFERENCE_FILE_PATH = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2398/node1/BTS_CLOUD_RFS_F_WL00439_3xFHDB_WBTS.xml"

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
    "mplane_ip_addr": "10.15.249.98",
    "cplane_ip_addr": "10.15.248.98",
    "lmp_ip_addr": "192.168.255.127",
    "enb_id": "10398",
    "enb_user": "toor4nsn",
    "enb_pass": "oZPS0POrRieRtu",
    "startup_time": 400,
}

RAT_2ND = {
    "mplane_ip_addr": "10.15.245.98",
    "pc_ip_addr": "10.5.48.38",
    "lmp_ip_addr": "192.168.255.129",
    "bcf_or_wbts_id": "10398",
    "bsc_or_rnc_ip_addr": "10.91.190.126",
    "bsc_or_rnc_user": "_nokadmin",
    "bsc_or_rnc_pass": "_P@ssword123",
    "bsc_or_rnc_port": "23",
    "startup_time": 720,
}

CP_PARAMS = {
    "sem_cli_path": r"/opt/btssm_cli_tools/",
    "ue_pc_files_path": r"C:\\PythonLibs",
    "cells_count": "3",
    "att_loops": "3",
    "rdrt_loops": "3",
    "csfb_loops": "3",
    "ho_loops": "3",
    "ft_loops": "3",
    "autoresponder": "00104",
    "data_transfer_protocol": "udp",
    "intra_ho_a3_tc_name": "[1][WRO.CP.TA.004] Intra eNB, inter-frequency A3 HO",
    "scf_hoA5": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2398/CP/BTS_CLOUD_RFS_F_WL00439_3xFHDB_hoA5_FL00.xml",
    "scf_maxTput-hoA3": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2398/CP/BTS_CLOUD_RFS_F_WL00439_3xFHDB_maxTput-hoA3_FL00.xml",
    "scf_IRAT": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2398/CP/BTS_CLOUD_RFS_F_WL00439_3xFHDB_IRAT_FL00.xml",
}
CP_HO_A5_INTRA_ENB_INTRA_FREQ = {
    "LNCEL:threshold3": "45",
    "LNCEL:threshold3a": "50",
    "LNCEL:a3Offset": "30",
    "LNCEL:threshold1": "41",
    "LNCEL:threshold2a": "40",
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
    "LNCEL:threshold2Wcdma": "60",
    "LNHOW:b2Threshold1Utra": "50",
    "LNHOW:b2Threshold2UtraRscp": "47",
}

CP_HO_A3_INTRA_ENB_INTRA_FREQ = {
    "LNCEL:a3Offset": "3",
    "LNCEL:threshold3": "58",
    "LNCEL:threshold3a": "59",
    "LNCEL:threshold1": "90",
    "LNCEL:threshold2a": "41",
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
    "ip_addr": "10.5.59.5",
    "port": "3001",
    "cells_to_ports_mapping": [[1, 2], [3, 4], [5, 6]],
    "scenario_attach": r"config/Timisoara/5_18_CLOUD2398/attenuator_scenario_file_att.txt",
    "scenario_csfb": r"config/Timisoara/5_18_CLOUD2398/attenuator_scenario_file_csfb.txt",
    "scenario_ho": r"config/Timisoara/5_18_CLOUD2398/attenuator_scenario_file_handover.txt",
    "scenario_rdrt": r"config/Timisoara/5_18_CLOUD2398/attenuator_scenario_file_rdrt.txt",
    "scenario_irat": r"config/Timisoara/5_18_CLOUD2398/attenuator_scenario_file_irat.txt",
    "scenario_inter_freq_ho": r"config/Timisoara/5_18_CLOUD2398/attenuator_scenario_file_inter_freq_handover.txt",
    "scenario_enacc": r"config/Timisoara/5_18_CLOUD2398/attenuator_scenario_file_enacc.txt",
}
IPERF = {
    "pc_ip_addr": "10.5.26.68",
    "pc_ssh_user": "root",
    "pc_ssh_pass": "alcatel",
    "call_duration": "30",
}
UES_CONTROL_PC = {
    "ip_addr": "10.5.48.146",
    "ssh_user": "rfs_rrm",
    "ssh_pass": "Nokia02!",
    "pyro_port": "9090",
    "ue_serial_number": "2a6bc738",
    "ue_pc_files_path": r"C:\\PythonLibs",
    "drive_for_logs": [
        r"/mnt/burak2/",
        "Y:",
        r"\\10.154.10.14\GloVer",
        r"labnet\feve",
        "fevepass",
    ],
}

TA_UE_CONFIG = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2398/5_18_CLOUD2398.yml"

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
    "Failure in internal BTS connection or connection to 3rd party tool",
    "Failure in connection between BTS and BTSMED or 3rd party tool",
    "Temp Fault1",
    "Validation of signed file failed",
]  # only for trunk

RAT_2ND_ALLOWED_ALARMS = ["BTS booted at .*? due to trs management reset"]

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

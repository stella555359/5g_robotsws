__maintainer__ = "nadina.petrescu@nokia.com"
__email__ = "nadina.petrescu@nokia.com"

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
        addr="10.5.21.16", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.60.85", username="rfs_rrm", password="Nokia2022!@1"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_bsc = BSC(
    name="BSC_BUICK",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.5.8.132", username="SYSTEM", password="SYSTEM"
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
    addr="10.255.2.14",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[11].contactor = "NORMALLY_OPEN"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPEN"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPEN"

_pdu_2.pdu_ports[9].contactor = "NORMALLY_OPEN"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_OPEN"

_pdu_3.pdu_ports[5].contactor = "NORMALLY_OPEN"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_OPEN"


_fsp = CapacityUnit(
    addr="", hardware_type="FBBC", hardware_version="A.101", serial_number="NK154530191"
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp],
    pdu_port=_pdu_2.pdu_ports[9],
    hardware_type="FSMF",
    hardware_version="A.101",
    serial_number="F7134230066",
    test_pc=_test_pc_master,
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_2.pdu_ports[10],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="L1142428520",
    test_pc=_test_pc_slave,
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.FRHD,
    serial_number="RY151210460",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FRHD,
    serial_number="RY151214190",
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.FXEF,
    serial_number="EA164111162",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FRHD,
    serial_number="RY151214187",
    pdu_port=_pdu_1.pdu_ports[11],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T3R",  # ???
    radio_type=RadioTypes.FXEF,
    serial_number="EA164111185",
    pdu_port=_pdu_1.pdu_ports[6],
)
_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=10230,
)
_bts2g_gsm = Bts2G(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    bcf_id="1230",
    master=_enb_sbts,
)

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    bts2g_objects=[_bts2g_gsm],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_HRAN_RFS_FC_LG22_2xFXEF_3xFRHD",
    bscs=[_bsc],
)

UTE_UE_CONFIG = (
    "/home/ute/robotlte/config/Timisoara/10_18_UTESRANRFSLG22/10_18_UTESRANRFSLG22.yaml"
)

__all__ = ["tl"]

TL1 = {
    "HOST_IP": "10.5.48.2",
    "FR": {
        "RY151210460": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.14", "port": 5}},
        "RY151214190": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.14", "port": 3}},
        "RY151214187": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 11}},
        "EA164111162": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 5}},
        "EA164111185": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 6}},
    },
    "FSM": {
        "F7134230066": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 9}}
    },
    "BBMOD": {
        "NK154530191": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 9}}
    },
}

TL2 = {
    "FSM": {
        "L1142428520": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 10}}
    }
}

NODES = {
    "TEAM": "RFS_RRM",
    "TL1": {
        "HOST_IP": "10.5.48.2",
        "FR": {
            "RY151210460": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.14", "port": 5}
            },
            "RY151214190": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.14", "port": 3}
            },
            "RY151214187": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 11}
            },
            "EA164111162": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 5}
            },
            "EA164111185": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.16", "port": 6}
            },
        },
        "FSM": {
            "F7134230066": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 9}}
        },
        "EC": {
            "NK154530191": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 9}}
        },
    },
    "TL2": {
        "HOST_IP": "10.5.48.2",
        "FSM": {
            "L1142428520": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.15", "port": 10}
            }
        },
    },
}

# SW_BUILDS_DIR_PATH = "/mnt/burak2/SW/eNB/FL17_SP/Branch/"
SCFC_1ST_RAT_REFERENCE_FILE_PATH = "/home/ute/robotlte/config/Timisoara/10_18_UTESRANRFSLG22/node1/BTS_CLOUD_RFS_FC_LG00670E_2xFXEF_3xFRHD_FL17A.xml"
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
    "mplane_ip_addr": "10.5.40.230",
    "cplane_ip_addr": "10.5.39.230",
    "lmp_ip_addr": "192.168.255.129",
    "enb_id": "10230",
    "enb_user": "toor4nsn",
    "enb_pass": "oZPS0POrRieRtu",
    "startup_time": 400,
}

RAT_2ND = {
    "mplane_ip_addr": "10.5.32.1",
    "pc_ip_addr": "10.5.60.85",
    "lmp_ip_addr": "192.268.255.131",
    "bcf_or_wbts_id": "1230",
    "bsc_or_rnc_ip_addr": "10.5.42.236",
    "bsc_or_rnc_user": "SYSTEM",
    "bsc_or_rnc_pass": "SYSTEM",
    "bsc_or_rnc_port": "23",
    "startup_time": 720,
}

CP_PARAMS = {
    "sem_cli_path": r"/opt/btssm_cli_tools/",
    "ue_pc_files_path": r"C:\\PythonLibs",
    "cells_count": "4",
    "att_loops": "1",
    "rdrt_loops": "1",
    "csfb_loops": "1",
    "ho_loops": "3",
    "ft_loops": "4",
    "enacc_loops": "1",
    "autoresponder": "00104",
    "data_transfer_protocol": "tcp",
    "intra_ho_a3_tc_name": "[1][WRO.CP.TA.004] Intra eNB, inter-frequency A3 HO",
    "enacc_cells_to_block": ["42301", "42302", "42300"],
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
    "ip_addr": "10.5.44.139",
    "port": "3001",
    "cells_to_ports_mapping": [[1, 2], [3, 4], [5, 6], [7, 8]],
    "scenario_attach": r"config/Timisoara/10_18_UTESRANRFSLG22/attenuator_scenario_file_att.txt",
    "scenario_csfb": r"config/Timisoara/10_18_UTESRANRFSLG22/attenuator_scenario_file_csfb.txt",
    "scenario_ho": r"config/Timisoara/10_18_UTESRANRFSLG22/attenuator_scenario_file_handover.txt",
    "scenario_rdrt": r"config/Timisoara/10_18_UTESRANRFSLG22/attenuator_scenario_file_rdrt.txt",
    "scenario_inter_freq_ho": r"config/Timisoara/10_18_UTESRANRFSLG22/attenuator_scenario_file_inter_freq_handover.txt",
    "scenario_enacc": r"config/Timisoara/10_18_UTESRANRFSLG22/attenuator_scenario_file_enacc.txt",
}
IPERF = {
    "pc_ip_addr": "10.5.26.69",
    "pc_ssh_user": "root",
    "pc_ssh_pass": "alcatel",
    "call_duration": "30",
}
UES_CONTROL_PC = {
    "ip_addr": "10.5.60.85",
    "ssh_user": "rfs_rrm",
    "ssh_pass": "Nokia02!",
    "pyro_port": "9090",
    #    'ue_serial_number': '5203f51afa65841d',
    "ue_serial_number": "98f0ce9d",
    "ue_pc_files_path": r"C:\\PythonLibs",
    "drive_for_logs": [
        r"/mnt/burak2/",
        "Y:",
        r"\\10.154.10.14\GloVer",
        r"labnet\feve",
        "fevepass",
    ],
}


TruTable = {
    "10 MHz": [33.416, 69.82, 68.534, 20.45],
    "15 MHz": [52.487, 104.974, 103.180, 32.7],
    "20 MHz": [71.993, 143.986, 141.567, 49.185],
    "5 MHz": [16.296, 32.591, 29.826, 8.88],
    "3 MHz": [8.800, 17.599, 0, 5.8901],
}

TA_UE_CONFIG = (
    "/home/ute/robotlte/config/Timisoara/10_18_UTESRANRFSLG22/10_18_UTESRANRFSLG22.yaml"
)

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
    "Vendor BTS certificate",
    "Synchronization lost",
    "ToP master service *",
    "BTS Reset Cause",
    "SSH enabled",
    "Temp Fault1",
    "BTS internal SW management problem",
    "LMP access via port .*?",
    ".*? Service Port enabled",
    "BTS booted at .*? due to trs .*? reset",
    "Service account root access is enabled",
    ".*? ToP master service .*? unusable",
    "Ethernet port security is disabled",
    "Sanity Check Error",
]

RAT_2ND_ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "Diagnostic Files collected",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "CRL update failure",
    "MMI CONNECTED TO BASE STATION",
    "WORKING SDCCH CHANNEL RATIO BELOW THRESHOLD",
    "BTS WITH NO TRANSACTIONS",
    "CONTINUOUS RESTARTS OF BCF/TRX",
    "Service account root access is enabled",
    "BCF SW PACKAGE MAY BE DIFFERENT AS DEFINED AS A DEFAULT IN",
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
        "CP_HO_A5_INTRA_ENB_INTRA_FREQ": CP_HO_A5_INTRA_ENB_INTRA_FREQ,
        "CP_HO_A5_INTRA_ENB_INTER_FREQ": CP_HO_A5_INTRA_ENB_INTER_FREQ,
        "CP_HO_IRAT": CP_HO_IRAT,
        "CP_HO_A3_INTRA_ENB_INTRA_FREQ": CP_HO_A3_INTRA_ENB_INTRA_FREQ,
        "CP_HO_A3_INTRA_ENB_INTER_FREQ": CP_HO_A3_INTRA_ENB_INTER_FREQ,
        "ATTENUATOR": ATTENUATOR,
        "IPERF": IPERF,
        "UES_CONTROL_PC": UES_CONTROL_PC,
        "TruTable": TruTable,
        "TA_UE_CONFIG": TA_UE_CONFIG,
        "TSHARK_S1_INTERFACE": TSHARK_S1_INTERFACE,
    }
    return variables

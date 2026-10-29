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
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.48.9", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.48.8", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)
_pdu_1 = Gude(
    addr="10.255.2.120",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.2.119",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPEN"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPEN"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPEN"

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="FSMF",
    hardware_version="A.101",
    serial_number="KQ170730019",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.5", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="D6111873225",
    test_pc=_test_pc_2,
)
_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])
_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.FXDA,
    serial_number="L6123504085",
    pdu_port=_pdu_2.pdu_ports[5],
)

_enb_lte_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.15.249.82"),
    instance_id=10382,
)
_nb_wcdma_1 = NB(system_module=_smod_1, rms=[_rmod_1], slave=_enb_lte_1)
_rnc = RNC(
    rnc_id="10382",
    oms_ip="10.27.31.235",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.121", username="_nokadmin", password="_P@ssword123"
    ),
)
tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_lte_1],
    nb_objects=[_nb_wcdma_1],
    tl_cloud_topology="CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP",
    rncs=[_rnc],
)

# UTE_UE_CONFIG = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2396/5_18_CLOUD2396.yaml"
__all__ = ["tl"]
######################### UCA-653 - new version of init #######################################

TL1 = {
    "HOST_IP": "10.5.48.9",
    "FR": {
        "L1110303146": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.120", "port": 3}},
        "K9130522539": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.120", "port": 4}},
        "L6123504085": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.119", "port": 5}},
        "L6123930361": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.119", "port": 6}},
    },
    "FSM": {
        "KQ170730019": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.119", "port": 4}}
    },
    "BBMOD": {
        "EA185224421": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.119", "port": 4}}
    },
}

TL2 = {
    "HOST_IP": "10.5.48.8",
    "FSM": {
        "D6111873225": {"pdu": {"type": "EPC", "ip_addr": "10.255.2.120", "port": 3}}
    },
}


# tl = ta_gve_conf(TL1)

NODES = {
    "TEAM": "RFS_RRM",
    "TL1": {
        "HOST_IP": "10.5.48.9",
        "FR": {
            "L1110303146": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.120", "port": 3}
            },
            "K9130522539": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.120", "port": 4}
            },
            "L6123504085": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.119", "port": 5}
            },
            "L6123930361": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.119", "port": 6}
            },
        },
        "FSM": {
            "KQ170730019": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.119", "port": 4}
            }
        },
        "EC": {
            "EA185224421": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.119", "port": 4}
            }
        },
    },
    "TL2": {
        "HOST_IP": "10.5.48.8",
        "FSM": {
            "D6111873225": {
                "pdu": {"type": "EPC", "ip_addr": "10.255.2.119", "port": 3}
            }
        },
    },
}

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"
SCFC_1ST_RAT_REFERENCE_FILE_PATH = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/node1/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_FL17SP.xml"
SCFC_2ND_RAT_REFERENCE_FILE_PATH = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/node1/SCFC_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP.xml"

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
    "mplane_ip_addr": "10.15.249.82",
    "cplane_ip_addr": "10.15.248.82",
    "lmp_ip_addr": "192.168.255.127",
    "enb_id": "10382",
    "enb_user": "toor4nsn",
    "enb_pass": "oZPS0POrRieRtu",
    "startup_time": 500,
}

RAT_2ND = {
    "mplane_ip_addr": "10.15.245.82",
    "pc_ip_addr": "10.5.48.8",
    "lmp_ip_addr": "192.168.255.129",
    "bcf_or_wbts_id": "10382",
    "bsc_or_rnc_ip_addr": "10.91.190.126",
    "bsc_or_rnc_user": "_P@ssword123",
    "bsc_or_rnc_pass": "system",
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
    "ho_loops": "4",
    "ft_loops": "4",
    "autoresponder": "00104",
    "data_transfer_protocol": "tcp",
    "dt_deviation": "20",
    "intra_ho_a3_tc_name": "[1][WRO.CP.TA.004] Intra eNB, inter-frequency A3 HO",
    "scf_maxTput_FL00": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_FL00/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_maxTput_FL00_FL19.xml",
    "scf_hoA3_FL00": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_FL00/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA3_FL00_FL19.xml",
    "scf_hoA5_FL00": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_FL00/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA5_FL00_FL19.xml",
    "scf_maxTput_FL19": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_FL19/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_maxTput_FL19.xml",
    "scf_hoA3_FL19": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_FL19/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA3_FL19.xml",
    "scf_hoA5_FL19": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_FL19/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA5_FL19.xml",
    "scf_maxTput_SBTS19A": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS19A/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_maxTput_SBTS19A.xml",
    "scf_hoA3_SBTS19A": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS19A/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA3_SBTS19A.xml",
    "scf_hoA5_SBTS19A": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS19A/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA5_SBTS19A.xml",
    "scf_maxTput_SBTS19B": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS19B/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_maxTput_SBTS19B.xml",
    "scf_hoA3_SBTS19B": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS19B/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA3_SBTS19B.xml",
    "scf_hoA5_SBTS19B": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS19B/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA5_SBTS19B.xml",
    "scf_maxTput_SBTS00": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS00/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_maxTput_SBTS00.xml",
    "scf_hoA3_SBTS00": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS00/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA3_SBTS00.xml",
    "scf_hoA5_SBTS00": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS00/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA5_SBTS00.xml",
    "scf_maxTput_SBTS20A": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS20A/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_maxTput_SBTS20A.xml",
    "scf_hoA3_SBTS20A": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS20A/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA3_SBTS20A.xml",
    "scf_hoA5_SBTS20A": "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/CP_SBTS20A/BTS_CLOUD_RFS_FC_WL20006_2xFXDA_2xFRGP_scf_hoA5_SBTS20A.xml",
}

CP_HO_A5_INTRA_ENB_INTRA_FREQ = {
    "LNCEL:threshold3": "47",
    "LNCEL:threshold3a": "48",
    "LNCEL:a3Offset": "30",
    "LNCEL:threshold1": "40",
    "LNCEL:threshold2a": "34",
}

CP_HO_A5_INTRA_ENB_INTER_FREQ = {
    "LNHOIF:a3OffsetRsrpInterFreq": "30",
    "LNCEL:threshold2InterFreq": "50",
    "LNCEL:threshold2a": "55",
    "LNHOIF:measQuantInterFreq": "rsrp",
    "LNHOIF:threshold3InterFreq": "45",
    "LNHOIF:threshold3aInterFreq": "47",
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
    "LNCEL:threshold2a": "34",
}

CP_HO_A3_INTRA_ENB_INTER_FREQ = {
    "LNHOIF:a3OffsetRsrpInterFreq": "6",
    "LNCEL:threshold2InterFreq": "50",
    "LNCEL:threshold2a": "55",
    "LNHOIF:measQuantInterFreq": "rsrp",
    "LNHOIF:threshold3InterFreq": "59",
    "LNHOIF:threshold3aInterFreq": "60",
    "LNCEL:threshold1": "90",
}

ATTENUATOR = {
    "ip_addr": "10.5.44.252",
    "port": "3001",
    "cells_to_ports_mapping": [[1, 2], [3, 4], [5, 6], [7, 8]],
    "scenario_attach": r"config/Timisoara/5_18_CLOUD2382/attenuator_scenario_file_att.txt",
    "scenario_csfb": r"config/Timisoara/5_18_CLOUD2382/attenuator_scenario_file_csfb.txt",
    "scenario_ho": r"config/Timisoara/5_18_CLOUD2382/attenuator_scenario_file_handover.txt",
    "scenario_irat": r"config/Timisoara/5_18_CLOUD2382/attenuator_scenario_file_irat.txt",
    "scenario_rdrt": r"config/Timisoara/5_18_CLOUD2382/attenuator_scenario_file_rdrt.txt",
    "scenario_inter_freq_ho": r"config/Timisoara/5_18_CLOUD2382/attenuator_scenario_file_inter_freq_handover.txt",
    "scenario_enacc": r"config/Timisoara/5_18_CLOUD2382/attenuator_scenario_file_enacc.txt",
}
IPERF = {
    "pc_ip_addr": "10.5.26.67",
    "pc_ssh_user": "root",
    "pc_ssh_pass": "alcatel",
    "call_duration": "30",
}
UES_CONTROL_PC = {
    "ip_addr": "10.5.48.140",
    "ssh_user": "rfs_rrm",
    "ssh_pass": "Nokia02!",
    "pyro_port": "9090",
    "ue_serial_number": "4a62b2d2",
    "ue_pc_files_path": r"C:\\PythonLibs",
    "drive_for_logs": [
        r"/mnt/burak2/",
        "Y:",
        r"\\10.154.10.14\GloVer",
        r"labnet\feve",
        "fevepass",
    ],
}

TA_UE_CONFIG = "/home/ute/robotlte/config/Timisoara/5_18_CLOUD2382/5_18_CLOUD2382.yml"

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
    "Diagnostic Files collected",
    "BTS booted at .*? due to trs .*? reset",
    "ToP master service 10.5.16.101 unusable",
    "LMP access via port .*?",
    ".*? Service Port enabled",
    "Service account root access is enabled",
    "Ethernet port security is disabled",
    "SSH enabled",
    "Transport layer connection failure in X2 interface",
    "BTS site autonomous reset as recovery action",
    "Failure in internal BTS connection or connection to 3rd party tool",
]

RAT_2ND_ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Diagnostic Files collected",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "CRL update failure",
    "MMI CONNECTED TO BASE STATION",
    "WORKING SDCCH CHANNEL RATIO BELOW THRESHOLD",
    "BTS WITH NO TRANSACTIONS",
    "CONTINUOUS RESTARTS OF BCF/TRX",
    "BCF SW PACKAGE MAY BE DIFFERENT AS DEFINED AS A DEFAULT IN",
    "Synchronization lost",
]
TruTable = {
    "10 MHz": [33.416, 69.82, 68.534, 20.45],
    "15 MHz": [52.487, 104.974, 103.180, 32.7],
    "20 MHz": [71.993, 143.986, 141.567, 49.185],
    "5 MHz": [16.296, 32.591, 29.826, 8.88],
    "3 MHz": [8.800, 17.599, 0, 5.8901],
}

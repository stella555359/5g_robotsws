"""
TL929 Configuration for CB014095 Inter-gNB Test Cases
Author: Hongye.fu
Contact: Hongye.fu@nokia-sbell.com
Squad group: NSB MN RAN RD VRF HAZ 4
"""

# Note: Do NOT import 'tl' in this Python variable file.
# Robot Framework loads __init__.py (with tl) automatically at runtime.
# Any tl-dependent variables (like iperf_port) should be defined in robot files
# using ${tl.xxx} syntax, same as T845 does.

# UE Configuration for Inter-gNB scenarios
UE_CONFIG = {
    'ue_type': 'huawei_sigspark',
    'ue_index': 1,
    'ue_mode': 'SA',
    'attach_mode': '5G_SA',
    'apn': 'dxdata3',
    'pci': 576,  # PCell PCI for gNB0 (anchor gNB)
    'throughput': '1900Mbits/sec',
    'call_duration': 3600,
    'get_spark_license': True,
    'power_reset': True,
    '4G_check': False
}

# gNB Configuration for Inter-gNB scenarios
GNB_CONFIG = {
    'gnb0': {
        'role': 'anchor',  # PCell gNB
        'instance_id_key': 'gnb0_instance_id',
        'connection': 'COAM',
        'description': 'Anchor gNB (PCell)'
    },
    'gnb1': {
        'role': 'secondary',  # SCell gNB
        'instance_id_key': 'gnb1_instance_id',
        'connection': 'COAM1',
        'description': 'Secondary gNB (SCell)'
    }
}

# Parameter Configuration for Inter-gNB SCell parameter removal test
SCELL_PARAMS_TO_REMOVE = [
    'sCellAdditionMethod',
    'sCellOperationalMode'
]

# NRCELL/NRREL paths for gNB1 (secondary gNB)
NRREL_PATHS = [
    'NRCELL-3/NRREL-1',
    'NRCELL-3/NRREL-2'
]

# Test timing configuration
TIMING_CONFIG = {
    'commission_wait': 10,  # Wait time after commissioning (seconds)
    'attach_wait': 5,       # Wait time after UE attach (seconds)
    'traffic_start_wait': 10,  # Wait time after starting traffic (seconds)
    'before_param_removal': 30,  # Wait time before parameter removal (seconds)
    'log_start_wait': 2,    # Wait time after starting log (seconds)
    'scell_release_wait': 60,  # Wait time for SCell release (seconds)
    'after_param_removal': 30,  # Wait time after parameter removal (seconds)
    'cell_check_timer': '2min'  # Timer for cell status check
}

# Allowed alarms for the test (inherited from CB014095_Common_Keywords)
ALLOWED_ALARMS = [
    '61524', '61652', '4654', '4655', '49', '50', '4592', '4614',
    '61649', '7319', '7300', '6327', '61510', '23', '7107', '16',
    '4420', '62003', '7311', '7331'
]

# Log file configuration
LOG_CONFIG = {
    'log_directory': '/home/ute/Case_Logs',
    'pcap_directory': '/tmp',
    'delta_file_path': '/tmp/delta_remove_scell_params_inter_gnb.json'
}

# Traffic configuration (for legacy/other test cases if needed)
TRAFFIC_CONFIG = {
    'ul_traffic_list': [79, 66, 20, 20],  # 20Mbps
    'port_list': [43567, 43577, 43587, 43597],
    'traffic_duration': 600,
    'ul_power_port_list': [43567, 43577, 43587, 43597],
    'dl_power_port_list': [57845, 43617, 43627, 43637]
}

# Spark MultiUE configuration (for T929 inter-gNB test using sparkMultiUE_yiyuan)
SPARK_CONFIG = {
    'ue_alias': 'spark_UE',
    'spark_ue_index': 1,  # Use tl.ues[1] which is _sigspark2
    'spark_ue_num': 2,    # Use UE2 (second UE in 2UE module, ue_num_input for sigspark_mmw3)
    'target_cell_id': 68719475329,
    'ul_throughput': '70MKbits/sec'
}

# Export Spark variables for Robot Framework
ue_alias = SPARK_CONFIG['ue_alias']
spark_ue_index = SPARK_CONFIG['spark_ue_index']
spark_ue_num = SPARK_CONFIG['spark_ue_num']
# Note: iperf_port is set in the robot file using ${tl.ues[1].iperf_details.port}

# Spark MultiUE configuration dictionaries (for sparkMultiUE_yiyuan library)
# These will be converted to Robot Framework dictionary variables
DL_CONFIG = {
    'target_throughput': UE_CONFIG['throughput'],
    'duration': UE_CONFIG['call_duration']
}

UL_CONFIG = {
    'target_throughput': SPARK_CONFIG['ul_throughput'],
    'duration': UE_CONFIG['call_duration']
}

UE1_CONFIG = {
    'detach_request': False,
    'power_reset': True,
    'get_spark_license': True,
    'ue_num_input': 2,
    'ue_mode': UE_CONFIG['ue_mode'],
    'apn': UE_CONFIG['apn'],
    'iperf_port': None,  # Will be overridden in robot file with ${tl.ues[1].iperf_details.port}
    'dl': DL_CONFIG,
    'ul': UL_CONFIG,
    'target_percent': 0.9,
    'reset_sol': 'none',
    'attach_mode': UE_CONFIG['attach_mode'],
    'dt_name': 'DT_8',
    'protocol': 'udp',
    'connection_type': 'app',
    'apn_address': UE_CONFIG['apn']
}

# Note: UE_INDEX_LIST and MultiUECFG_SA need to be defined in robot file
# because they reference robot list variables

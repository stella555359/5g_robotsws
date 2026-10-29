from ta_gve_conf.interface import ta_gve_conf

# TL1 = {
#       'HOST_IP': '10.43.54.204',
#       'FR': 	{'K9134011937': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.168', 'port': 5}},
#                  'K9134011956': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.168', 'port': 7}},
#                  'L6131214940': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.168', 'port': 8}}},
#       'FSM': 	{'EA181061998': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.169', 'port': 8}}},
#       'BBMOD':  {'AS180445762': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.169', 'port': 8}},
#                  'AS175023665': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.169', 'port': 8}}},
# }
TL1 = {
       'HOST_IP': '10.43.54.201',
       'FR':    {'F7180220127': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.143', 'port': 7}}},
       'FSM':   {'K9171153216': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.142', 'port': 8}}}
      }

TL2 = {
      'HOST_IP': '10.43.54.205',
      'FSM':   {'AS180300281': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.169', 'port': 7}}}

}
# NODES = {
#     'TEAM': 'LTE_ST',
#     'TL1': {
#         'HOST_IP': '10.43.54.204',
#         'FR': {'K9134011937': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.168', 'port': 5}},
#                'K9134011956': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.168', 'port': 7}},
#                'L6131214940': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.168', 'port': 8}}},
#         'EC': {'AS180445762': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.169', 'port': 8}},
#                'AS175023665': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.169', 'port': 8}}},
#         'FSM': {'EA181061998': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.169', 'port': 8}}}
#     },
#
#     'TL2': {
#         'HOST_IP': '10.43.54.205',
#         'FSM':   {'AS180300281': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.169', 'port': 7}}}
#     },
# }

NODES = {
    'TEAM': 'LTE_ST',
    'TL1': {
        'HOST_IP': '10.43.54.201',
        'FR': {'F7180220127': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.143', 'port': 7}}},
        'EC': {'L1170201974': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.142', 'port': 8}}},
        'FSM': {'K9171153216': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.142', 'port': 8}}}
    },

    'TL2': {
        'HOST_IP': '10.43.54.205',
        'FSM':   {'AS180300281': {'pdu': {'type': 'MYCOMP', 'ip_addr': '10.41.155.169', 'port': 7}}}
    },
}

# tl = ta_gve_conf(TL1)
tl = ta_gve_conf(TL1, hw_type="fsmr4")

# RFS additional parameters
SCFC_1ST_RAT_REFERENCE_FILE_PATH = '/home/ute/robotlte/config/Bangalore/1_2_CLOUD437/node1/BTS_CLOUD_RFS_FC_WL00341E_3xFRGP_BLR_SBTS00.xml'
SCFC_2ND_RAT_REFERENCE_FILE_PATH = '/home/ute/robotlte/config/Bangalore/1_2_CLOUD434/node1/SCFC_CLOUD_RFS_FC_WL00341E_3xFRGP_WBTS.xml'
SW_BUILDS_DIR_PATH = '/home/ute/Downloads/'



RAT_1ST = {'mplane_ip_addr': '10.43.197.145',
           'cplane_ip_addr': '10.43.197.145',
           'lmp_ip_addr': '192.168.255.129',
           'enb_id': '435',
           'enb_user': 'toor4nsn',
           'enb_pass': 'oZPS0POrRieRtu',
           'startup_time': 800}

RAT_2ND = {'mplane_ip_addr': '10.255.196.98',
           'pc_ip_addr': '10.43.54.205',
		   'lmp_ip_addr': '192.168.255.129',
           'bcf_or_wbts_id': '174',
           'bsc_or_rnc_ip_addr': '10.43.124.237',
           'bsc_or_rnc_user': '_nokadmin',
           'bsc_or_rnc_pass': 'system',
           'bsc_or_rnc_port': '23',
           'startup_time': 800}

CP_PARAMS = {
    'sem_cli_path': r"/opt/btssm_cli_tools/",
    'ue_pc_files_path': r"C:\\PythonLibs",
    'cells_count': '6',
    'att_loops': '1',
    'rdrt_loops': '1',
    'csfb_loops': '1',
    'ho_loops': '1',
    'ft_loops': '6',
	'autoresponder': '+123456',
	'data_transfer_protocol': 'tcp',
	'data_transfer_duration': '20'
}

ATTENUATOR_CELLS_LIST = ['ENB_1_CELL_1', 'ENB_1_CELL_2', 'ENB_1_CELL_3', 'ENB_2_CELL_1', 'ENB_2_CELL_2']

ATTENUATOR = {
    'ip_addr': '10.53.203.66',
    'port': '3001',
    'cells_to_ports_mapping': [[1,2],[3,4],[9,10],[13],[16]],
    'attach_to_cell': r"config/Wroclaw/1_16_CLOUD3664/attenuator_scenario_file_att.txt",
    'attenuation_cell_to_zero': r"config/Wroclaw/1_16_CLOUD3664/attenuation_cell_to_zero.txt"
}

TA_UE_CONFIG = '/home/ute/robotlte/config/Bangalore/1_2_CLOUD437/GVE_WRO_CLOUD3664.yml'
UTE_UE_CONFIG = '/home/ute/robotlte/config/Bangalore/1_2_CLOUD437/GVE_WRO_CLOUD3664.yml'

TSHARK = {
    'user': 'inbabtslabuser',
    'password': 'BT5l@bus3rl0g1n',
    'tshark_logs_dir': '/tmp/' + RAT_1ST['mplane_ip_addr'],
    'tshark_dir': r'/usr/bin',
    'interface': 'ens8',
    'tshark_ip': '10.53.164.126'
}

RAT_1ST_ALLOWED_ALARMS = ['Vendor BTS certificate',
                          'Synchronization lost',
                          'BTS booted at .*? due to trs management reset',
                          'BTS booted at .*? due to trs power-on reset',
                          '.*? ToP master service .*? unusable',
                          'R&D Service Port enabled',
						  'IP Traffic Capturing ongoing SMOD-1, LMP, 52:54:00:26:51:26',
                          'SSH enabled',
                          'Service account root access is enabled',
                          'Ethernet port security is disabled',
                          'LMP access via port .*?']

RAT_2ND_ALLOWED_ALARMS = ['Vendor BTS certificate',
                          'Synchronization lost',
                          'BTS booted at .*? due to trs management reset',
                          'BTS booted at .*? due to trs power-on reset',
                          '.*? ToP master service .*? unusable',
                          'R&D Service Port enabled',
                          'SSH enabled',
                          'Cell blocked',
                          'LMP access via port .*?']

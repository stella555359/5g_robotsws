from robot.libraries.BuiltIn import BuiltIn

ATTENUATOR_IP = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')

ATTENUATOR_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')

VENDOR = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 10,
    },
    'TOPYOUNG': {
        'max': 90,
        'avg': 10,
    },
}

TPUT_MATRIX1 = {
    'atten_default_values': ATTENUATOR_VALUES,
    'linux_congestion': None,
    'parallel_streams': '1',
    'buffer_client': None,
    'buffer_server': None,
    'size_packet': '1320B',
    'interval': '1',
    'NRCELL-11': {
        'DL': {
            'tput': '200 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 11,
        'real_cell_id': 1264402443,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP,
                'att_port': ATTENUATOR_PORT,
                'vendor': VENDOR,
                'ports': [5, 6, 7, 8],
                'atten_ul': {
                    0: [5, 6, 7, 8],
                },
                'atten_dl': {
                    0: [5, 6, 7, 8],
                }
            }
        ]
    },
    'NRCELL-12': {
        'DL': {
            'tput': '200 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 12,
        'real_cell_id': 1264402444,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP,
                'att_port': ATTENUATOR_PORT,
                'vendor': VENDOR,
                'ports': [5, 6, 7, 8],
                'atten_ul': {
                    0: [5, 6, 7, 8],
                },
                'atten_dl': {
                    0: [5, 6, 7, 8],
                }
            }
        ]
    },
    'NRCELL-31': {
        'DL': {
            'tput': '200 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 31,
        'real_cell_id': 1264402463,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP,
                'att_port': ATTENUATOR_PORT,
                'vendor': VENDOR,
                'ports': [1, 2, 3, 4],
                'atten_ul': {
                    0: [1, 2, 3, 4],
                },
                'atten_dl': {
                    0: [1, 2, 3, 4],
                }
            }
        ]
    },
    'NRCELL-32': {
        'DL': {
            'tput': '200 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 32,
        'real_cell_id': 1264402464,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP,
                'att_port': ATTENUATOR_PORT,
                'vendor': VENDOR,
                'ports': [1, 2, 3, 4],
                'atten_ul': {
                    0: [1, 2, 3, 4],
                },
                'atten_dl': {
                    0: [1, 2, 3, 4],
                }
            }
        ]
    }
}

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Upgrade': ['SAS Registration Failure', 'Incompatible SW version detected', 'Incompatible Sw detected',
                'GTP-U Path Failure', 'WiFi Configuration Issue'],
    'Snapshot': ['BTS Reset Cause', 'SAS Registration Failure', 'Incompatible SW version detected',
                 'Incompatible Sw detected', 'GTP-U Path Failure', 'WiFi Configuration Issue'],
}

FILE_LIST = ['frozenFrameDirtyRf.log', 'nahka_dump_safe.log', 'messages.zip', 'frozenFrameDracoCarrierConfig.log',
             'frozenFramePowerManagement.log', 'jesd_ul_log_file.log.xz', 'frozenFrameDracoRT.log',
             'jesd_dl_log_file.log.xz', 'MemoryConsumption_LastDay.csv', 'fault_history_log.txt',
             'hlapi_transactions.log', 'frozenFrame_Coco_l3as1.log', 'RP1OM.xml', 'frozenFrame_Coco_port1.log',
             'frozenFrame_Coco_l3as0.log', 'frozenFrame_Coco_eth1.log', 'frozenFrame_Coco_port0.log',
             'frozenFrame_Coco_cocowizardinstance1.log', 'frozenFrame_Coco_l3ar0.log', 'frozenFrame_Coco_l3ar1.log',
             'MemoryConsumption_LastMonth.csv', 'hlapi_state.log', 'frozenFrame_ruoam_cpri.log',
             'frozenFrame_Coco_clkm.log', 'MemoryConsumption_LastFourHours.csv', 'dmesg.zip',
             'frozenFramePowerManagement.log.xz', 'eth-interfaces-check.log.tar.gz', 'frozenFrameDracoRT.log.xz',
             'frozenFrameDracoCarrierConfig.log.xz', 'startup.zip', 'ps.zip', 'nahka_dump_safe.log.xz', 'lsmod.zip',
             'runtime.zip', 'swman_history.zip.gz', 'frozenFrameDirtyRf.log.xz', 'frozenFrame_Coco_clkm.log.xz',
             'frozenFrame_Coco_port1.log.xz', 'UnitOAM_SOAP_Log.zip', 'BBOX5_all.zip', 'frozenFrame_ruoam_cpri.log.xz',
             'frozenFrame_Coco_eth1.log.xz', 'frozenFrame_Coco_l3as1.log.xz', 'MemoryConsumption_LastFourHours.csv.gz',
             'MemoryConsumption_LastDay.csv.gz', 'MemoryConsumption_LastMonth.csv.gz', 'hlapi_transactions.log.gz',
             'frozenFrame_Coco_port0.log.xz', 'RP1OM.xml.gz', 'fault_history_log.txt.gz', 'hlapi_state.log.gz',
             'frozenFrame_Coco_cocowizardinstance1.log.xz', 'frozenFrame_Coco_l3ar0.log.xz',
             'frozenFrame_Coco_l3as0.log.xz', 'frozenFrame_Coco_l3ar1.log.xz',
             'UnitOAM_SOAP_.*_Log(\\\\d{1,2})?\\\\.xml']


ACCEPTED_MISSING_FILES = {
    "AH193502362": FILE_LIST,
    "AH193502378": FILE_LIST
}

DELTAS = {
    'desiredPmax': 'desiredPmax.json',
    'maxGrantPwrRed': 'maxGrantPwrRed.json',
    'channelspacing': 'channelspacing.json',
}

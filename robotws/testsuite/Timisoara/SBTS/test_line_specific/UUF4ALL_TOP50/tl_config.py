# Allowed Fault's Definition
#  '61649' - LMP access via port xx
#  '61652' - R&D Service Port enabled
#  '61524' - SSH enabled
#  '61510' - Automatic BTS Operator Certificate retrieval unsuccessful  /ipsec
#  '4459' - User Account has Default Password
#  '6455' - Service account root access is enabled
#  '4657'  - unsupported SFP
#  '4655' - Service account root access is enabled (from 21B)
#  '4654' - Ethernet port security is disabled (from 21B)
#  '4389' -  OTDOA PRS transmission disabled
#  '61648' - LMP connectivity detected
#  '4293' - IP Traffic Capacity Limit


# Client List
# ['AIS Thailand', 'AT&T', 'BT UK', 'CBN', 'CMCC', 'CTC', 'CUC', 'DTAG', 'Elisa', 'Free France', 'Generic',
# 'Globe', 'H3G', 'KDDI Japan', 'Korean Telecom', 'LGU+', 'Optus', 'Orange France', 'SBM', 'SFR', 'SKT', 'Softbank',
# 'Sprint', 'STC Saudi, 'TEF Spain', 'TMO Poland', 'TMO US', 'VDF', 'VIL', 'Verizon', 'Vodacom']

# FULL COSTOMER LIST
# https://app.powerbi.com/groups/me/apps/
# a0c70a39-1cd2-44d9-9b57-86bd66d0cb05/reports/
# c77ee2cc-fd9a-4296-9440-f0050c83a05d/ReportSection8bff1e06268841e10f6e?ctid=5d471751-9675-428d-917b-70f44f9630b0
#
config = {



    '10_18_UTESRANCLOUD1470': {  # 4G
        'NUMBER_OF_RESET_LOOPS': 10,
        'NUMBER_OF_UPGRADE_LOOPS': 3,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [],  # done
        'UBOOT_DOWNGRADE': [],  # :ToDo
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1],  # done
        'COLLECT_SNAPSHOT': [1],  # done
        'ADD_SWCONFIG_FLAGS': [],  # done
        'SAVE_LOGS_AFTER_TEST_PASS': False,
        'SAVE_LOGS_AFTER_TEST_FAIL': True,
        'CHECK_CELL_COUNT': 35,
        'CHECK_FAULT_COUNT': 25,
        'RECOVER_TESTLINE': True,
        'RECOVERY_RESET_COUNT': 1,
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '3FRGU+1FRMF+2FXDB+2FXED',
            'SMOD': 'ASIA',
            'CA': 'RAN_PZ_TSR',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': '',  # for 5G
            'TDD_FDD': 'FDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Mobily'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.5.20.116',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIA'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 8,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1471': {  # 5G
        'NUMBER_OF_RESET_LOOPS': 10,
        'NUMBER_OF_UPGRADE_LOOPS': 3,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [],  # done
        'UBOOT_DOWNGRADE': [],  # :ToDo
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1],  # done
        'COLLECT_SNAPSHOT': [1],  # done
        'ADD_SWCONFIG_FLAGS': [],  # done
        'SAVE_LOGS_AFTER_TEST_PASS': False,
        'SAVE_LOGS_AFTER_TEST_FAIL': True,
        'CHECK_CELL_COUNT': 35,
        'CHECK_FAULT_COUNT': 25,
        'RECOVER_TESTLINE': True,
        'RECOVERY_RESET_COUNT': 1,
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '3AEHC',
            'SMOD': 'ASIB',
            'CA': 'RAN_PZ_TSR',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': 'SA',  # for 5G
            'TDD_FDD': 'TDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Mobily'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.5.20.117',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIB'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '5G',
                'RMOD_COUNT': 3,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1472': {  # 4G
        'NUMBER_OF_RESET_LOOPS': 10,
        'NUMBER_OF_UPGRADE_LOOPS': 3,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [],  # done
        'UBOOT_DOWNGRADE': [],  # :ToDo
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1],  # done
        'COLLECT_SNAPSHOT': [1],  # done
        'ADD_SWCONFIG_FLAGS': [],  # done
        'SAVE_LOGS_AFTER_TEST_PASS': False,
        'SAVE_LOGS_AFTER_TEST_FAIL': True,
        'CHECK_CELL_COUNT': 35,
        'CHECK_FAULT_COUNT': 25,
        'RECOVER_TESTLINE': True,
        'RECOVERY_RESET_COUNT': 1,
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '3AEHC',
            'SMOD': 'ASIB',
            'CA': 'RAN_PZ_TSR',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': '',  # for 5G
            'TDD_FDD': 'FDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Mobily'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.5.20.118',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIB'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 3,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1755': {  # 2G-4G
        'NUMBER_OF_RESET_LOOPS': 10,
        'NUMBER_OF_UPGRADE_LOOPS': 3,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [],  # done
        'UBOOT_DOWNGRADE': [],  # :ToDo
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1],  # done
        'COLLECT_SNAPSHOT': [1],  # done
        'ADD_SWCONFIG_FLAGS': [],  # done
        'SAVE_LOGS_AFTER_TEST_PASS': False,
        'SAVE_LOGS_AFTER_TEST_FAIL': True,
        'CHECK_CELL_COUNT': 35,
        'CHECK_FAULT_COUNT': 25,
        'RECOVER_TESTLINE': True,
        'RECOVERY_RESET_COUNT': 1,
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '1ARDA+3AHEGC+1ARMA',
            'SMOD': 'ASIB',
            'CA': 'RAN_PZ_TSR',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': '',  # for 5G
            'TDD_FDD': 'FDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Mobily'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.5.20.104',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIB'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 5,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1756': {  # 5G
        'NUMBER_OF_RESET_LOOPS': 10,
        'NUMBER_OF_UPGRADE_LOOPS': 3,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [],  # done
        'UBOOT_DOWNGRADE': [],  # :ToDo
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1],  # done
        'COLLECT_SNAPSHOT': [1],  # done
        'ADD_SWCONFIG_FLAGS': [],  # done
        'SAVE_LOGS_AFTER_TEST_PASS': False,
        'SAVE_LOGS_AFTER_TEST_FAIL': True,
        'CHECK_CELL_COUNT': 35,
        'CHECK_FAULT_COUNT': 25,
        'RECOVER_TESTLINE': True,
        'RECOVERY_RESET_COUNT': 1,
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '3AEHC',
            'SMOD': 'ASIB',
            'CA': 'RAN_PZ_TSR',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': 'SA',  # for 5G
            'TDD_FDD': 'TDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Mobily'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.5.20.105',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIB'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '5G',
                'RMOD_COUNT': 3,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1757': {  # 4G
        'NUMBER_OF_RESET_LOOPS': 10,
        'NUMBER_OF_UPGRADE_LOOPS': 3,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [],  # done
        'UBOOT_DOWNGRADE': [],  # :ToDo
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1],  # done
        'COLLECT_SNAPSHOT': [1],  # done
        'ADD_SWCONFIG_FLAGS': [],  # done
        'SAVE_LOGS_AFTER_TEST_PASS': False,
        'SAVE_LOGS_AFTER_TEST_FAIL': True,
        'CHECK_CELL_COUNT': 35,
        'CHECK_FAULT_COUNT': 25,
        'RECOVER_TESTLINE': True,
        'RECOVERY_RESET_COUNT': 1,
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '3AEHC',
            'SMOD': 'ASIB',
            'CA': 'RAN_PZ_TSR',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': '',  # for 5G
            'TDD_FDD': 'FDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Mobily'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.5.20.106',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIB'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 3,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1761': {  # 2G-3G-4G-5G  ????? OBSAI-MDEA-CPRI ?
        'NUMBER_OF_RESET_LOOPS': 10,
        'NUMBER_OF_UPGRADE_LOOPS': 3,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [],  # done
        'UBOOT_DOWNGRADE': [],  # :ToDo
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1],  # done
        'COLLECT_SNAPSHOT': [1],  # done
        'ADD_SWCONFIG_FLAGS': [],  # done
        'SAVE_LOGS_AFTER_TEST_PASS': False,
        'SAVE_LOGS_AFTER_TEST_FAIL': True,
        'CHECK_CELL_COUNT': 35,
        'CHECK_FAULT_COUNT': 25,
        'RECOVER_TESTLINE': True,
        'RECOVERY_RESET_COUNT': 1,
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '3FRGU+2FXDB+2FXED+1FRMF',
            'SMOD': 'ASIA',
            'CA': 'RAN_PZ_TSR',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': '',  # for 5G
            'TDD_FDD': 'FDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Mobily'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.5.20.112',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIA'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',  # ?????????????????
                'RMOD_COUNT': 8,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1762': {  # 4G
        'NUMBER_OF_RESET_LOOPS': 10,
        'NUMBER_OF_UPGRADE_LOOPS': 3,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [],  # done
        'UBOOT_DOWNGRADE': [],  # :ToDo
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1],  # done
        'COLLECT_SNAPSHOT': [1],  # done
        'ADD_SWCONFIG_FLAGS': [],  # done
        'SAVE_LOGS_AFTER_TEST_PASS': False,
        'SAVE_LOGS_AFTER_TEST_FAIL': True,
        'CHECK_CELL_COUNT': 35,
        'CHECK_FAULT_COUNT': 25,
        'RECOVER_TESTLINE': True,
        'RECOVERY_RESET_COUNT': 1,
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '3AZHA',
            'SMOD': 'ASIA',
            'CA': 'RAN_PZ_TSR',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': '',  # for 5G
            'TDD_FDD': 'FDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Mobily'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.5.20.113',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIA'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 3,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1763': {  # 5G
        'NUMBER_OF_RESET_LOOPS': 10,
        'NUMBER_OF_UPGRADE_LOOPS': 3,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [],  # done
        'UBOOT_DOWNGRADE': [],  # :ToDo
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1],  # done
        'COLLECT_SNAPSHOT': [1],  # done
        'ADD_SWCONFIG_FLAGS': [],  # done
        'SAVE_LOGS_AFTER_TEST_PASS': False,
        'SAVE_LOGS_AFTER_TEST_FAIL': True,
        'CHECK_CELL_COUNT': 35,
        'CHECK_FAULT_COUNT': 25,
        'RECOVER_TESTLINE': True,
        'RECOVERY_RESET_COUNT': 1,
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '3AEQE+2FXED+1FRMF',
            'SMOD': 'ASIB',
            'CA': 'RAN_PZ_TSR',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': 'SA',  # for 5G
            'TDD_FDD': 'TDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Mobily'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.5.20.114',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIB'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '5G',
                'RMOD_COUNT': 3,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1318': {  # 4G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '1FRMF+1FXED+1ARGA',
                'SMOD': 'ASIB',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': '',  # for 5G
                'TDD_FDD': 'FDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['Elisa'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.79',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '4G',
                    'RMOD_COUNT': 3,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1319': {  # 5G
        'NUMBER_OF_RESET_LOOPS': 10,
        'NUMBER_OF_UPGRADE_LOOPS': 3,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [],  # done
        'UBOOT_DOWNGRADE': [],  # :ToDo
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1],  # done
        'COLLECT_SNAPSHOT': [1],  # done
        'ADD_SWCONFIG_FLAGS': [],  # done
        'SAVE_LOGS_AFTER_TEST_PASS': False,
        'SAVE_LOGS_AFTER_TEST_FAIL': True,
        'CHECK_CELL_COUNT': 35,
        'CHECK_FAULT_COUNT': 25,
        'RECOVER_TESTLINE': True,
        'RECOVERY_RESET_COUNT': 1,
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '3AZQL+1ARPA',
            'SMOD': 'ASIK',
            'CA': 'RAN_PZ_TSR',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': 'SA',  # for 5G
            'TDD_FDD': 'TDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Elisa'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.5.20.80',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIK'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '5G',
                'RMOD_COUNT': 4,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1320': {  # 2G-3G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  #
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '1FXDB',
                'SMOD': 'FSMF',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': '',  # for 5G
                'TDD_FDD': 'FDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['Elisa'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.81',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['FSMF'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '4G',  # ??????????  2G-3G ?
                    'RMOD_COUNT': 1,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1751': {  # 5G
        'NUMBER_OF_RESET_LOOPS': 10,
        'NUMBER_OF_UPGRADE_LOOPS': 3,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [],  # done
        'UBOOT_DOWNGRADE': [],  # :ToDo
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1],  # done
        'COLLECT_SNAPSHOT': [1],  # done
        'ADD_SWCONFIG_FLAGS': [],  # done
        'SAVE_LOGS_AFTER_TEST_PASS': False,
        'SAVE_LOGS_AFTER_TEST_FAIL': True,
        'CHECK_CELL_COUNT': 35,
        'CHECK_FAULT_COUNT': 25,
        'RECOVER_TESTLINE': True,
        'RECOVERY_RESET_COUNT': 1,
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '3AEQQ+1ARPA',
            'SMOD': 'ASIB',
            'CA': 'RAN_PZ_TSR',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': 'SA',  # for 5G
            'TDD_FDD': 'TDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Elisa'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.5.20.100',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIB'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '5G',
                'RMOD_COUNT': 4,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1752': {  # 4G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  #
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '1FXED+1FRMC+1FRGU',
                'SMOD': 'FSMF',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': '',  # for 5G
                'TDD_FDD': 'FDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['Elisa'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.101',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['FSMF'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '4G',
                    'RMOD_COUNT': 3,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1750': {  # 4G-5G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '3AZQJ+1ARGA+1ARPA+1FRMF+1AREA',
                'SMOD': 'ASIB',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': 'SA',  # for 5G
                'TDD_FDD': 'TDD+FDD',  # ???????????
                'TOOL': 'WebEM',
                'CUSTOMERS': ['Elisa'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.99',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '5G',  # ??????????????
                    'RMOD_COUNT': 7,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1322': {  # 4G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '1FRMF+1AREA+1ARGA',
                'SMOD': 'ASIB',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': '',  # for 5G
                'TDD_FDD': 'FDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['Elisa'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.82',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '4G',
                    'RMOD_COUNT': 3,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1329': {  # 5G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '3AQQC+1ARGA+1ARPA',
                'SMOD': 'ASIB+2ABIO',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': 'SA',  # for 5G
                'TDD_FDD': 'TDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['Elisa'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.83',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '5G',
                    'RMOD_COUNT': 5,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1341': {  # 2G-3G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  #
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '1FXDB',
                'SMOD': 'FSMF',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': '',  # for 5G
                'TDD_FDD': 'FDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['Elisa'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.84',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['FSMF'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '4G',  # 2G-3G ?
                    'RMOD_COUNT': 1,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1305': {  # 4G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '2AREA+2ARGA+3AHPMDA',
                'SMOD': 'ASIB',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': '',  # for 5G
                'TDD_FDD': 'FDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['STC Saudi'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.85',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '4G',
                    'RMOD_COUNT': 7,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1346': {  # 5G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '3AEQE',
                'SMOD': 'ASIB',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': '',  # for 5G
                'TDD_FDD': 'FDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['STC Saudi'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.86',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '5G',
                    'RMOD_COUNT': 3,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1482': {  # 5G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '3AENB',
                'SMOD': 'ASIB',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': '',  # for 5G
                'TDD_FDD': 'FDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['STC Saudi'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.87',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '5G',
                    'RMOD_COUNT': 3,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1758': {  # 4G   ??? STC10   2 Cores?
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '3AHPMDA+2ARGA+2AREA+6AZNA',  # ???????
                'SMOD': 'ASIB',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': '',  # for 5G
                'TDD_FDD': 'FDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['STC Saudi'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.107',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '4G',
                    'RMOD_COUNT': 13,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
                '2': {
                    'VM_IP': '10.5.20.108',
                    'LMP_IP': '192.168.255.119',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '4G',
                    'RMOD_COUNT': 13,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                 },
            },
        },
    '10_18_UTESRANCLOUD1759': {  # 5G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '3AQQL',
                'SMOD': 'ASIB',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': 'SA',  # for 5G
                'TDD_FDD': 'TDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['STC Saudi'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.109',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '5G',
                    'RMOD_COUNT': 3,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1760': {  # 4G-5G  ???? STC#12 2 cores ?
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '3AREA+3ARGA+3AHPMDA+3AEQE+3AZNA',  # ????
                'SMOD': 'ASIB',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': 'SA',  # for 5G
                'TDD_FDD': 'TDD+FDD',  # ???
                'TOOL': 'WebEM',
                'CUSTOMERS': ['STC Saudi'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.111',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '5G',  # 4G+5G ?
                    'RMOD_COUNT': 15,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1753': {  # 2G-4G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '3AHEGC+3AHPMDB',
                'SMOD': 'ASIA',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': '',  # for 5G
                'TDD_FDD': 'FDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['ZAIN'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.102',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '4G',  # +2G ?
                    'RMOD_COUNT': 6,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1754': {  # 5G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '3AQQL',
                'SMOD': 'ASIB',   # ??? ASIB/L ?
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': 'SA',  # for 5G
                'TDD_FDD': 'TDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['ZAIN'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.103',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '5G',
                    'RMOD_COUNT': 3,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1344': {  # 2G-4G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '3AHEGC+2FXDB+1ARMA',
                'SMOD': 'ASIA',
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': '',  # for 5G
                'TDD_FDD': 'FDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['ZAIN'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.88',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIA'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '4G',  # ??? +2G ?
                    'RMOD_COUNT': 6,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
    '10_18_UTESRANCLOUD1481': {  # 5G
            'NUMBER_OF_RESET_LOOPS': 10,
            'NUMBER_OF_UPGRADE_LOOPS': 3,
            'STOP_TEST_AFTER_FAIL': False,
            'PERFORM_UPGRADE': [1],  # done
            'PERFORM_ROLLBACK': [1],  # done
            'PERFORM_RESET': [1],  # done
            'CHECK_CELLS': [1],  # done
            'CHECK_FAULTS': [1],  # done
            'CHECK_VALIDATION': [1],  # done
            'CHECK_BLACKBOX': [1],  # done
            'CHECK_SYSLOG': [1],  # done
            'CHECK_ALD': [],  # done
            'UBOOT_DOWNGRADE': [],  # :ToDo
            'SERIAL_CONSOLE_ON': [],  # done
            'COLLECT_SYSLOG': [1],  # done
            'COLLECT_SNAPSHOT': [1],  # done
            'ADD_SWCONFIG_FLAGS': [],  # done
            'SAVE_LOGS_AFTER_TEST_PASS': False,
            'SAVE_LOGS_AFTER_TEST_FAIL': True,
            'CHECK_CELL_COUNT': 35,
            'CHECK_FAULT_COUNT': 25,
            'RECOVER_TESTLINE': True,
            'RECOVERY_RESET_COUNT': 1,
            'REPORT': {
                'RP_REPORT': True,
                'REPORT_NAME': '',
                'RUS_IDINAHUI': '3AQQL+3AEHC',
                'SMOD': 'ASIB',   # ??? ASIB/L ?
                'CA': 'RAN_PZ_TSR',
                'QC_DOMAIN': '',
                'QC_PROJECT': '',
                'QC_ID': '',
                'SA_NSA': 'SA',  # for 5G
                'TDD_FDD': 'TDD',
                'TOOL': 'WebEM',
                'CUSTOMERS': ['ZAIN'],
            },
            'TL_CONFIG': {
                '1': {
                    'VM_IP': '10.5.20.89',
                    'LMP_IP': '192.168.255.1',
                    'SM_TYPES': ['ASIB'],
                    'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                    'TECHNOLOGY': '5G',
                    'RMOD_COUNT': 6,
                    'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                    'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                    'SWCONFIG_FLAGS': [
                        '0x3F001E=1',
                    ],
                },
            },
        },
}

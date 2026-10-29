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
# 'Sprint', 'TEF Spain', 'TMO Poland', 'TMO US', 'VDF', 'VIL', 'Verizon', 'Vodacom']

# FULL COSTOMER LIST
# https://app.powerbi.com/groups/me/apps/
# a0c70a39-1cd2-44d9-9b57-86bd66d0cb05/reports/
# c77ee2cc-fd9a-4296-9440-f0050c83a05d/ReportSection8bff1e06268841e10f6e?ctid=5d471751-9675-428d-917b-70f44f9630b0
#
config = {
    '1_16_CLOUDGTA3810': {  # 4G-5G
        'NUMBER_OF_LOOPS': 1,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [1],  # done
        'UBOOT_DOWNGRADE': [],  # done
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
            'RUS_IDINAHUI': '3UHLC+3UHLB+3UHNA',
            'SMOD': '1ASIA+1ABIA',
            'CA': 'RAN_PZ_WRO_3',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': '',  # for 5G
            'TDD_FDD': 'FDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['AT&T'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.42.82.231',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIA'],
                'BB_NODES': ['192.168.253.36',
                             '192.168.253.40',
                             '192.168.253.44'],
                'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 9,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '1_16_UTESRAN2096': {  # 4G-5G
        'NUMBER_OF_LOOPS': 1,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1, 2],  # done
        'PERFORM_ROLLBACK': [2, 1],  # done
        'PERFORM_RESET': [1, 2],  # done
        'CHECK_CELLS': [1, 2],  # done
        'CHECK_FAULTS': [1, 2],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1, 2],  # done
        'CHECK_SYSLOG': [1, 2],  # done
        'CHECK_ALD': [1],  # done
        'UBOOT_DOWNGRADE': [],  # done
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1, 2],  # done
        'COLLECT_SNAPSHOT': [1, 2],  # done
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
            'RUS_IDINAHUI': '3UHIE',
            'SMOD': '1ASIA+1ABIA',
            'CA': 'RAN_PZ_WRO_3',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': '',  # for 5G
            'TDD_FDD': 'FDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['Verizon', 'TMO US'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.42.250.184',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIA'],
                'BB_NODES': ['192.168.253.36'],
                'TYPE': '4G-5G',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 3,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
            '2': {
                'VM_IP': '10.42.250.174',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIK'],
                'BB_NODES': ['192.168.253.20'],
                'TYPE': '4G-5G',
                'TECHNOLOGY': '5G',
                'RMOD_COUNT': 3,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61524', '61652', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61524', '61652', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '1_16_CLOUD3773': {  # FULLRACK
        'NUMBER_OF_LOOPS': 1,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [1],  # done
        'PERFORM_ROLLBACK': [1],  # done
        'PERFORM_RESET': [1],  # done
        'CHECK_CELLS': [1],  # done
        'CHECK_FAULTS': [1],  # done
        'CHECK_VALIDATION': [1],  # done
        'CHECK_BLACKBOX': [1],  # done
        'CHECK_SYSLOG': [1],  # done
        'CHECK_ALD': [1],  # done
        'UBOOT_DOWNGRADE': [],  # done
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
            'RUS_IDINAHUI': '2AHFIC+2AHFIA+4AZRB',
            'SMOD': '1ASIA+2ABIA+1ASIA+2ABIA',
            'BB_NODES': [],
            'CA': 'RAN_PZ_WRO_3',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': '',  # for 5G
            'TDD_FDD': 'FDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['TMO US'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.42.83.159',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIA'],
                'BB_NODES': ['192.168.253.20', '192.168.253.28'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 8,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
            '2': {
                'VM_IP': '10.42.83.160',
                'LMP_IP': '192.168.255.7',
                'SM_TYPES': ['ASIA'],
                'BB_NODES': ['192.168.253.36', '192.168.253.40'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 8,  # fullrack should sum up rmods for both nodes
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '1_16_UTESRAN3801': {
        'NUMBER_OF_LOOPS': 1,
        'STOP_TEST_AFTER_FAIL': False,
        'PERFORM_UPGRADE': [4],  # done
        'PERFORM_ROLLBACK': [4],  # done
        'PERFORM_RESET': [],  # done
        'CHECK_CELLS': [1, 2, 4],  # done
        'CHECK_FAULTS': [1, 2, 4],  # done
        'CHECK_VALIDATION': [4],  # done
        'CHECK_BLACKBOX': [1, 2, 4],  # done
        'CHECK_SYSLOG': [1, 2, 4],  # done
        'CHECK_ALD': [1, 2, 4],  # done
        'UBOOT_DOWNGRADE': [],  # done
        'SERIAL_CONSOLE_ON': [],  # done
        'COLLECT_SYSLOG': [1, 2, 4],  # done
        'COLLECT_SNAPSHOT': [1, 2, 4],  # done
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
            'RUS_IDINAHUI': '3AEHC+3AHLOA+3AHFIB',
            'SMOD': '1ASIA+3ABIA+1ASIB+3ABIC+1ASIK+3ABIL+1ASIK+3ABIL',
            'CA': 'RAN_PZ_WRO_3',
            'QC_DOMAIN': '',
            'QC_PROJECT': '',
            'QC_ID': '',
            'SA_NSA': '',  # for 5G
            'TDD_FDD': 'FDD',
            'TOOL': 'WebEM',
            'CUSTOMERS': ['TMO US'],
        },
        'TL_CONFIG': {
            '1': {
                'VM_IP': '10.42.82.120',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIB'],
                'BB_NODES': [''],
                'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 3,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
            '2': {
                'VM_IP': '10.42.82.121',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIA'],
                'BB_NODES': [''],
                'TYPE': 'standalone',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 6,  # fullrack should sum up rmods for both nodes
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
            #            '3': {
            #                'VM_IP': '10.42.82.122',
            #                'LMP_IP': '192.168.255.7',
            #                'SM_TYPES': ['ASIA'],
            #                'TYPE': 'fullrack',
            #                'TECHNOLOGY': '5G',
            #                'RMOD_COUNT': 6,  # fullrack should sum up rmods for both nodes
            #                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654',
            #                                           '4681'],
            #                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
            #                'SWCONFIG_FLAGS': [
            #                    '0x3F001E=1',
            #                ],
            #            },
            '4': {
                'VM_IP': '10.42.82.123',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIK'],
                'BB_NODES': [''],
                'TYPE': 'fullrack',
                'TECHNOLOGY': '5G',
                'RMOD_COUNT': 6,  # fullrack should sum up rmods for both nodes
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
            '5': {
                'VM_IP': '10.42.82.124',
                'LMP_IP': '192.168.255.7',
                'SM_TYPES': ['ASIK'],
                'BB_NODES': [''],
                'TYPE': 'fullrack',
                'TECHNOLOGY': '5G',
                'RMOD_COUNT': 6,  # fullrack should sum up rmods for both nodes
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
        },
    },
    '10_18_UTESRANCLOUD1718': {  # 4G-5G
        'NUMBER_OF_LOOPS': 2,
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
        'UBOOT_DOWNGRADE': [1],  # :ToDo
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
        'RP_REPORT': True,  # done
        'REPORT': {
            'RP_REPORT': True,
            'REPORT_NAME': '',
            'RUS_IDINAHUI': '2FRGY+2FXDB+1AHEB',
            'SMOD': 'ASIA+ABIA',
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
                'VM_IP': '10.5.20.97',
                'LMP_IP': '192.168.255.1',
                'SM_TYPES': ['ASIA'],
                'TYPE': 'fullrack',  # standalone, fullrack, multirat, 4G+5G
                'TECHNOLOGY': '4G',
                'RMOD_COUNT': 5,
                'ALLOWED_FAULTS_INITIAL': ['61649', '61652', '61524', '61510', '4459', '4655', '4654', '4681'],
                'ALLOWED_FAULTS': ['61649', '61652', '61524', '61510', '4459', '4655', '4654'],
                'SWCONFIG_FLAGS': [
                    '0x3F001E=1',
                ],
            },
            '2': {
                'VM_IP': '10.5.20.98',
                'LMP_IP': '192.168.255.119',
                'SM_TYPES': ['ASIA'],
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

}

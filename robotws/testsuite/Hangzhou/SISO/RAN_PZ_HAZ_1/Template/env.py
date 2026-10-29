import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "41",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
    },
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "5",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
    },
]

FW_INFO = {
    'TYPE': 'GG',
    'IP': '10.56.7.147',
    'USERNAME': 'BTS2251',
    'PASSWORD': 'SISO1_test',
    'BBU_PORT': "110;123"
}

# This dict is used for case "SWDL For Incompatible Load SW RRU", Other cases don't need this dict.
RF_INCOMPATIBLE_SW_STORAGE = {
    '6Q181710303': {
        'LOGIN': 'siso',
        'PASSWORD': 'siso',
        'HOST_IP': '10.106.211.194',
        'SW_PATH': '/home/siso/LTE/Factory_SW/',
        'RRUuser': 'root',
        'RRUpassword': '',
        'IMAGE_FILE_23R2': 'FRM-rfsw-image-install_20230316151252-multi.tar',
        'IMAGE_FILE_23R1': 'FRM-rfsw-image-install_20230104150549-multi.tar',
        'IMAGE_FILE_22R4': 'FRM-rfsw-image-install_20230125164106-multi.tar',
        'checksum_23R2': '0xdaecbc67',
        'checksum_23R1': '0x50e9fc2b',
        'checksum_22R4': '0x219219b1',
        'fileVersion_23R2': 'install_20230316151252-multi',
        'fileVersion_23R1': 'install_20230104150549-multi',
        'fileVersion_22R4': 'install_20230125164106-multi',
        'BuildName_23R2': 'RF.FRM5.23R2.20230316.005',
        'BuildVersion_23R2': 'RF.FRM5.23R2.20230316.005',
        'BuildName_23R1': 'RF.FRM5.23R1.20230104.001',
        'BuildVersion_23R1': 'RF.FRM5.23R1.20230104.001',
        'BuildName_22R4': 'RF.FRM5.22R4.20230125.002',
        'BuildVersion_22R4': 'RF.FRM5.22R4.20230125.002',
    },
}

RF_FAULT_INFO = {
    'password': 'KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=',
    '1907': {
        'trigger': {
            'ssh': {
                'before': ['/ action create ConfigAccess /ca /module\r\n',
                           '/ca action fetch DECODED "gc.bin" "/ram/gc.json"\r\n'],
                'parameter': [{'name': 'startup.fbMaxThreshold', 'value': '-50'},
                              {'name': 'runtime.fbMaxThreshold', 'value': '-50'}],
                'after': ['/ca action store DECODED "gc.bin" "/ram/gc.json"\r\n',
                          '/ca action update\r\n']
            },
        },
    },
    '1933': {
        'trigger': {
            'ssh': {
                'before': ['/ action create ConfigAccess /ca /module\r\n',
                           '/ca action fetch DECODED "tcs.bin" "/ram/tcs.json"\r\n'],
                'parameter': [{'name': 'tcs.Nrpm_fail', 'value': '1'},
                              {'name': 'tcs.deltaTmulti', 'value': '120'},
                              {'name': 'tcs.deltaTctl', 'value': '120'}],
                'after': ['/ca action store PERMANENT DECODED "tcs.bin" "/ram/tcs.json"\r\n'
                          ],
                'set_alarm': ['/ action create FanDevice /CI/fan /fan/1\r\n',
                              '/CI/fan set control_state TESTABILITY_SW\r\n',
                              '/CI/fan action set_setpoint 0\r\n',
                              '/ action create ThermometerDevice /CI/ThermoModule /temp/pa/drv1_2\r\n',
                              '/CI/ThermoModule action override TEMPERATURE 120\r\n']
            },
        },
        'cancel': ['/CI/fan action set_setpoint 1\r\n',
                   '/ action create ConfigAccess /ca /module\r\n',
                   '/ca action delete "tcs.bin"\r\n',
                   '/CI/ThermoModule action override TEMPERATURE 50\r\n']
    }
}

SAS_SIM = True

PACKAGE_TYPE = "CMCC"

tl_config = sys.modules[__name__]

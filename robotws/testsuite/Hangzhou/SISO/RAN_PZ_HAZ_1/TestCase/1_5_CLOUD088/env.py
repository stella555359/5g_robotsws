import sys

UE_TYPE = "CPE"

UE_INFO = [
    {
            "TYPE": "CPE",
            "MODEL": "Gemtek",
            "IP": "192.168.1.6",
            "LAN_IP": "192.168.1.2",
            "BAND": "3,40,41",
            "DMZ": "no",
            "STATUS": "Enabled",
            "NETWORK_TYPE": "4G"
    }
]

FW_INFO = {
    'TYPE': 'GG',
    'IP': '10.108.151.146',
    'USERNAME': 'BTS6458',
    'PASSWORD': 'lcl198287_',
    'BBU_PORT': "63;64;65;66;67;68"
}

RF_FAULT_INFO = {
    '1937': {
        'trigger': {
            'telnet': {
                'before': ['/ action create ConfigAccess /CI/ConfigAccess_Module /module',
                           '/CI/ConfigAccess_Module action fetch DECODED "tempest_inst1.bin" "/ram/tempest_inst1.json"'
                           ],
                'after': [
                    '/CI/ConfigAccess_Module action store TEMPORARY DECODED "tempest_inst1.bin" '
                    '"/ram/tempest_inst1.json"',
                    '/CI/ConfigAccess_Module action update',
                    '/ action create ThermometerDevice /trx1 /rf/trx1',
                    '/trx1 action override TEMPERATURE 70']
            },
            'ssh': ['sed -i \'s/"tempOffset": 0,/"tempOffset": 50,/g\' /ram/tempest_inst1.json'],
        },
        'cancel': {
            'telnet': {
                'before': ['/ action create ConfigAccess /CI/ConfigAccess_Module /module',
                           '/CI/ConfigAccess_Module action fetch DECODED "tempest_inst1.bin" "/ram/tempest_inst1.json"'
                           ],
                'after': ['/CI/ConfigAccess_Module action store TEMPORARY DECODED "tempest_inst1.bin" '
                          '"/ram/tempest_inst1.json"',
                          '/CI/ConfigAccess_Module action update',
                          '/ action create ThermometerDevice /trx1 /rf/trx1',
                          '/trx1 action override TEMPERATURE 20']
            },
            'ssh': ['sed -i \'s/"tempOffset": 50.0,/"tempOffset": 0,/g\' /ram/tempest_inst1.json'],
        },
        'port': 2000
    }
}

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

TESTLINE_TYPE = "Flexible"

ADDITIONAL_ADMIN_ALLOWED_ALARMS = [
                  'Vendor BTS certificate',
                  'Synchronization lost',
                  'Diagnostic Files collected',
                  'BTS booted at .*? due to trs management reset',
                  '.*? ToP master service .*? unusable',
                  'NTP Server .*? unavailable',
                  'SSH enabled',
                  'R&D Service Port enabled',
                  'LMP access via port.*',
                  'BTS internal SW management problem',
                  'Failure in optical interface',
                  'Receiving failure in Optical Interface',
                  'Unsigned software release has been successfully downloaded',
                  'Cell disabled due to unknown problem; logs collected',
                  'Unsigned software release has been successfully downloaded',
                  'Service account root access is enabled',
                  'Ethernet port security is disabled',
                  'Sanity Check Error'
                  ]

REQUIRE_PACKAGES = "Active"

tl_config = sys.modules[__name__]

import sys

UE_TYPE = "CPE"

UE_INFO = [
    {
            "TYPE": "CPE",
            "MODEL": "Gemtek",
            "IP": "192.168.1.6",
            "LAN_IP": "192.168.1.3",
            "BAND": "3,40,41",
            "DMZ": "no",
            "STATUS": "Enabled",
            "NETWORK_TYPE": "4G"
    }
]

FW_INFO = {
    'TYPE': 'GG',
    'IP': '10.69.64.240',
    'USERNAME': 'admin',
    'PASSWORD': 'password',
    'BBU_PORT': "62:45;64:47;66:37;91:41;42:43;92:17;18:19;20:21;22:23;93:25;26:27"
}

SUPPORTED_CALL = False

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
                    '/trx1 action override TEMPERATURE 70'
                ]
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
                          '/trx1 action override TEMPERATURE 20'
                          ]
            },
            'ssh': ['sed -i \'s/"tempOffset": 50.0,/"tempOffset": 0,/g\' /ram/tempest_inst1.json'],
        },
        'port': 2000
    }
}

SHARE_RRU_INFO = {
     "BBU": {
         "OPTICAL_SWITCH_PORTS": "62:64:66:91:92:93"
     },
     "10.69.64.240_FZNN": {
         "OPTICAL_SWITCH_PORTS": "17-31:35:37-45:47:55:56:61:65:88-90"
     }
 }

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"


TESTLINE_TYPE = "FlexibleShare"
REQUIRE_PACKAGES = "Active"

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
                  'Service account root access is enabled',
                  'Receiving failure in Optical Interface',
                  'Unsigned software release has been successfully downloaded',
                  'Cell disabled due to unknown problem; logs collected',
                  'Unsigned software release has been successfully downloaded',
                  'RX out of order',
                  'RF Module failure',
                  'Increased BER detected on the optical connector',
                  'VSWR major alarm',
                  'BTS Reset Cause',
                  'Ethernet port security is disabled',
                  'Sanity Check Error'
                  ]

tl_config = sys.modules[__name__]

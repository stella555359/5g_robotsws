import os
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.dist_name_patterns import EnbDistNamePatterns


ant_statuses_blocked = {
                        'operationalState': 'disabled',
                        'commissioned': 'Yes',
                        'localState': 'blocked',
                        'hardwareState': 'working',
                        'softwareState': 'detected'
                        }
ant_statuses_unblocked = {
                        'operationalState': 'enabled',
                        'commissioned': 'Yes',
                        'localState': 'unblocked',
                        'hardwareState': 'working',
                        'softwareState': 'detected'
                        }

statuses_after_reset_hub = {
                            'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'unblocked',
                            'hardwareState': 'working', 'softwareState': 'configured', 'activeStatusLEDColor': 'Green',
                            'faultStatusLEDColor': 'Off', 'powerStatusLEDColor': 'Green'
                            }

earfcn_to_change = [
        {
            "distName": 'MRBTS-76007/LNBTS-76007/LNCEL-1/LNCEL_FDD-0',
            "operation": "update",
            "parameters": [
                {
                    "parameterName": 'earfcnDL',
                    "value": '',
                    "operation": "update"
                },
                {
                    "parameterName": 'earfcnUL',
                    "value": '',
                    "operation": "update"
                }
            ]
        }
    ]


ASIR_ALARMS = {
    'Default_list_of_alarms': [],
    'Config_Reset': [3060],
    'Block_ants': [4348],
    'Delata_commisioning': [61648, 1907],
    'PoePower': [4480],
    'Block_RF_Mod': [1931],
    'Earfcn_change': [4484],
    }

commands = {
    'Hub': {
        "power_consumptions": "cat /sys/bus/i2c/devices/1-0022/port_info | awk '{print $4}' |tail -4; "
                              "cat /sys/bus/i2c/devices/1-0024/port_info | awk '{print $4}' |tail -4; "
                              "cat /sys/bus/i2c/devices/1-0026/port_info | awk '{print $4}' |tail -4;",
    },
}

DEFAULT_ALARMS = ['SSH enabled', 'R&D Service Port enabled', 'LMP access via port 443', 'LMP access via port 3600',
                  'Service account root access is enabled', 'Ethernet port security is disabled',
                  'LMP connectivity detected'
                  ]

allowed_alarms = ['SSH enabled', 'R&D Service Port enabled', 'LMP access via port 443', 'LMP access via port 3600',
                  'Service account root access is enabled', 'Ethernet port security is disabled',
                  'LMP connectivity detected',
                  ]

allowed_alarms_for_cpri_verification = ['SSH enabled', 'LMP access via port 443', 'Ethernet port security is disabled',
                                        'Service account root access is enabled', 'Diagnostic Check Error']

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Block_AsirAnts': ['Setup of X2 connectivity to gNB failed', 'Service account root access is enabled',
                       'SSH enabled', 'Ethernet port security is disabled',
                       'R&D Service Port enabled', 'LMP access via port 443', 'Failure detected on assigned antennas',
                       'Diagnostic Files collected', 'CRL Update Failure'],
    'Cell_block_unblock': ['Setup of X2 connectivity to gNB failed', 'Cell blocked', 'Diagnostic Files collected',
                           'Service account root access is enabled', 'SSH enabled',
                           'Ethernet port security is disabled', 'R&D Service Port enabled', 'LMP access via port 443',
                           'CRL Update Failure'],
    'Hub_reset': ['Setup of X2 connectivity to gNB failed', 'Service account root access is enabled', 'SSH enabled',
                  'Ethernet port security is disabled', 'Diagnostic Files collected',
                  'R&D Service Port enabled', 'LMP access via port 443', 'Failure detected on assigned antennas',
                  'CRL Update Failure'],
    'L3_call': ['Setup of X2 connectivity to gNB failed', 'Service account root access is enabled', 'SSH enabled',
                'Ethernet port security is disabled', 'R&D Service Port enabled', 'LMP access via port 443',
                'Diagnostic Files collected', 'CRL Update Failure'],
    'Comm_and_Recomm': ['Setup of X2 connectivity to gNB failed', 'BTS Reset Cause',
                        'Service account root access is enabled', 'SSH enabled',
                        'Ethernet port security is disabled', 'R&D Service Port enabled', 'LMP access via port 443',
                        'Failure detected on assigned antennas', 'Antennas assignment not available',
                        'Diagnostic Files collected', 'CRL Update Failure'],
    'Hub_block': ['Setup of X2 connectivity to gNB failed', 'Service account root access is enabled', 'SSH enabled',
                  'Ethernet port security is disabled', 'Diagnostic Files collected',
                  'R&D Service Port enabled', 'LMP access via port 443', 'Failure detected on assigned antennas',
                  'CRL Update Failure'],
}

from robot.libraries.BuiltIn import BuiltIn


expected_items_sfp = [
    "vendor", "waveLength", "transmissionRate", "txPowerHighAlarmThreshold", "txPowerLowAlarmThreshold",
    "txPowerLowWarnThreshold", "txPowerHighWarnThreshold", "rxPowerHighAlarmThreshold", "rxPowerHighWarnThreshold",
    "rxPowerLowAlarmThreshold", "rxPowerLowWarnThreshold", "temperatureHighAlarmThreshold",
    "temperatureLowAlarmThreshold", "TXSupplyVoltage", "TXOpticalPower", "RXOpticalPower", "connectorType"
]

AEQE_credentials = {
    "username": "serviceuser",
    "password": "bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4="
}

gNB_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')

alarm_monitoring_params = [{
    'distName': "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1".format(gNB_id),
    'operation': 'update',
    'parameters': [{
        'operation': 'update',
        'value': '{}',
        'parameterName': 'actTransceiverAlarmMonitoring'
    }]
}]

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Clock_Link_and_QSFP': ['Unit synchronization failed', 'No connection to unit', 'ToP reference missing',
                            'ToP master service RU eCPRI port #2 unusable', 'Not able to synchronize baseband bus',
                            'Unstable eCPRI Link Detected'],
    'FID_4698_to_4701': ['SFP Transceiver temperature too high', 'TX Bias Current too low', 'TX Power too low',
                         'RX Power too low', 'Toggling: SFP Transceiver temperature too high (4698)'],
}

syslog_alarms = {
    "Step2": ["2928", "2930"],
    "Step3": ["2928", "2930"],  # not visible
    "Step4": ["2929", "2930"],
    "Step5": ["2929", "2930"],
    "Step4a": ["2929"],
    "Step5a": ["2929"],
    "Step6": ["2928"],  # not visible
    "Step8": ["2929"],  # not visible
}

alarms_on_ru = {
    "Step2": [
        {
            "alarm_id": "1405",
            "alarm_name": "EFaultId_EthLinkLoss",
            "alarm_state": "active",
        },
        {
            "alarm_id": "1404",
            "alarm_name": "EFaultId_SfpTxFaultEcpri",
            "alarm_state": "active",
        },
        {
            "alarm_id": "10001",
            "alarm_name": "EEventId_SyncLost",
            "alarm_state": "active",
        }
    ],
    "Step3": [
        {
            "alarm_id": "1405",
            "alarm_name": "EFaultId_EthLinkLoss",
            "alarm_state": "cleared",
        },
        {
            "alarm_id": "1404",
            "alarm_name": "EFaultId_SfpTxFaultEcpri",
            "alarm_state": "cleared",
        },
        {
            "alarm_id": "10001",
            "alarm_name": "EEventId_SyncLost",
            "alarm_state": "cleared",
        }
    ],
    "Step4": [
        {
            "alarm_id": "1385",
            "alarm_name": "EFaultId_LossOfSignalCapacityWarning",
            "alarm_state": "active",
        },
        {
            "alarm_id": "1405",
            "alarm_name": "EFaultId_EthLinkLoss",
            "alarm_state": "active",
        },
        {
            "alarm_id": "10001",
            "alarm_name": "EEventId_SyncLost",
            "alarm_state": "active",
        }
    ],
    "Step5": [
        {
            "alarm_id": "1385",
            "alarm_name": "EFaultId_LossOfSignalCapacityWarning",
            "alarm_state": "cleared",
        },
        {
            "alarm_id": "1405",
            "alarm_name": "EFaultId_EthLinkLoss",
            "alarm_state": "cleared",
        },
        {
            "alarm_id": "10001",
            "alarm_name": "EEventId_SyncLost",
            "alarm_state": "cleared",
        }
    ],
    "Step6": [
        {
            "alarm_id": "1405",
            "alarm_name": "EFaultId_EthLinkLoss",
            "alarm_state": "active",
        },
        {
            "alarm_id": "1404",
            "alarm_name": "EFaultId_SfpTxFaultEcpri",
            "alarm_state": "active",
        }
    ],
    "Step8": [
        {
            "alarm_id": "1405",
            "alarm_name": "EFaultId_EthLinkLoss",
            "alarm_state": "active",
        },
        {
            "alarm_id": "1385",
            "alarm_name": "EFaultId_LossOfSignalCapacityWarning",
            "alarm_state": "active",
        }
    ],
    "Step4a": [
        {
            "alarm_id": "1385",
            "alarm_name": "EFaultId_LossOfSignalCapacityWarning",
            "alarm_state": "active",
        },
        {
            "alarm_id": "1405",
            "alarm_name": "EFaultId_EthLinkLoss",
            "alarm_state": "active",
        }
    ],
    "Step5a": [
        {
            "alarm_id": "1385",
            "alarm_name": "EFaultId_LossOfSignalCapacityWarning",
            "alarm_state": "cleared",
        },
        {
            "alarm_id": "1405",
            "alarm_name": "EFaultId_EthLinkLoss",
            "alarm_state": "cleared",
        }
    ]
}

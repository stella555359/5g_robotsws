fid_1932 = {
    'webem':
    {
        'query': "alarmingObjectIds contains (runtime eq '{runtime_object}') and faultId eq 1932",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['serialNo'],
            'value': '{serialNo}'
            },
        ],
        'internal_queries': [
            "alarmAttribute contains ((attributeName eq 'serial_no') and (attributeValue eq '{serialNo}'))",
            "alarmAttribute contains ((attributeName eq 'affected_cells') and (attributeValue eq {affected_cells}))",
            ]
    },
    'netact_live': {
        'query': "dn eq '{dn}' and additionalText1 eq '{faultName}'",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['additionalText3'],
            'value': '1932 serial_no={serialNo} additionalFaultID=1932'
            },
        ],
    },
    'netact_snap': {
        'query': "dn eq '{dn}' and additionalText1 eq '{faultName}'",
        'path_to_alarms': ['data', 0, 'alarmInfo'],
        'expected': [{
            'path_to_key': ['additionalText3'],
            'value': '1932 serial_no={serialNo} additionalFaultID=1932'
            },
        ],
    },
    'netact_compare': {}
}
fid_1933 = {
    'webem':
    {
        'query': "alarmingObjectIds contains (runtime eq '{runtime_object}') and faultId eq 1933",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['serialNo'],
            'value': '{serialNo}'
            },
        ],
        'internal_queries': [
            "alarmAttribute contains ((attributeName eq 'serial_no') and (attributeValue eq '{serialNo}'))",
            "alarmAttribute contains ((attributeName eq 'affected_cells') and (attributeValue eq {affected_cells}))",
            ]
    },
    'netact_live': {
        'query': "dn eq '{dn}' and additionalText1 eq '{faultName}'",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['additionalText3'],
            'value': '1933 serial_no={serialNo} additionalFaultID=1933'
            },
        ],
    },
    'netact_snap': {
        'query': "dn eq '{dn}' and additionalText1 eq '{faultName}'",
        'path_to_alarms': ['data', 0, 'alarmInfo'],
        'expected': [{
            'path_to_key': ['additionalText3'],
            'value': '1933 serial_no={serialNo} additionalFaultID=1933'
        },
        ],
    },
    'netact_compare': {}
}
fid_4479_common = {
    'netact_query': "dn eq '{dn}' and additionalText1 eq 'Failure detected on assigned antennas'",
    'netact_expected': [{
        'path_to_key': ['additionalText3'],
        'value': '4479 unitName={unitName} path={path} serial_no={serialNo} '
        'supplAlarmInfo={supplAlarmInfo} additionalFaultID=4479 conf_path={conf_path}'
    },
    ],
}
fid_4479 = {
    'webem':
    {
        'query': "alarmingObjectIds contains (runtime eq '{runtime_object}') and faultId eq 4479",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['serialNo'],
            'value': '{serialNo}'
        }, {
            'path_to_key': ['faultName'],
            'value': 'Failure detected on assigned antennas'
        },
        ],
        'internal_queries': [
            "alarmAttribute contains ((attributeName eq 'serial_no') and (attributeValue eq '{serialNo}'))",
            # "alarmAttribute contains ((attributeName eq 'faulty_cells') and (attributeValue eq '{faulty_cells}'))",
            "alarmAttribute contains ((attributeName eq 'conf_path') and (attributeValue eq '{conf_path}'))",
        ]
    },
    'netact_live': {
        'query': fid_4479_common['netact_query'],
        'path_to_alarms': [],
        'expected': fid_4479_common['netact_expected']
    },
    'netact_snap': {
        'query': fid_4479_common['netact_query'],
        'path_to_alarms': ['data', 0, 'alarmInfo'],
        'expected': fid_4479_common['netact_expected']
    },
    'netact_compare_remaining': {
        'query': fid_4479_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'remainingAlarms'],
        'expected': fid_4479_common['netact_expected']
    },
    'netact_compare_new': {
        'query': fid_4479_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'newAlarms'],
        'expected': fid_4479_common['netact_expected']
    },
}

fid_61648_common = {
    'netact_query': "dn eq '{dn}' and additionalText1 eq 'LMP connectivity detected'",
    'netact_expected': [{
            'path_to_key': ['additionalText3'],
            'value': '61648 unitName={unitName} path={path} serial_no={serialNo} '
                     'additionalFaultID=61648 conf_path={conf_path}'
        },
        ],
}
fid_61648 = {
    'webem':
    {
        'query': "alarmingObjectIds contains (runtime eq '{runtime_object}') and faultId eq 61648",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['serialNo'],
            'value': '{serialNo}'
        }, {
            'path_to_key': ['faultName'],
            'value': 'LMP connectivity detected'
        },
        ],
        'internal_queries': [
            "alarmAttribute contains ((attributeName eq 'serial_no') and (attributeValue eq '{serialNo}'))",
            "alarmAttribute contains ((attributeName eq 'conf_path') and (attributeValue eq '{conf_path}'))",
        ]
    },
    'netact_live': {
        'query': fid_61648_common['netact_query'],
        'path_to_alarms': [],
        'expected': fid_61648_common['netact_expected']
    },
    'netact_snap': {
        'query': fid_61648_common['netact_query'],
        'path_to_alarms': ['data', 0, 'alarmInfo'],
        'expected': fid_61648_common['netact_expected']
    },
    'netact_compare_remaining': {
        'query': fid_61648_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'remainingAlarms'],
        'expected': fid_61648_common['netact_expected']
    },
    'netact_compare_new': {
        'query': fid_61648_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'newAlarms'],
        'expected': fid_61648_common['netact_expected']
    },
}

fid_10_common = {
    'netact_query': "dn eq '{dn}' and additionalText1 eq 'No connection to unit'",
    'netact_expected': [{
        'path_to_key': ['additionalText3'],
        'value': '10 unitName={unitName} path={path} serial_no={serialNo} '
        'supplAlarmInfo={supplAlarmInfo} '
        'additionalFaultID=10 conf_path={conf_path}'
    }],
}
fid_10 = {
    'webem':
    {
        'query': "alarmingObjectIds contains (runtime eq '{runtime_object}') and faultId eq 10",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['serialNo'],
            'value': '{serialNo}'
        }, {
            'path_to_key': ['faultName'],
            'value': 'No connection to unit'
        },
        ],
        'internal_queries': [
            "alarmAttribute contains ((attributeName eq 'serial_no') and (attributeValue eq '{serialNo}'))",
            "alarmAttribute contains ((attributeName eq 'conf_path') and (attributeValue eq '{conf_path}'))",
        ]
    },
    'netact_live': {
        'query': fid_10_common['netact_query'],
        'path_to_alarms': [],
        'expected': fid_10_common['netact_expected']
    },
    'netact_snap': {
        'query': fid_10_common['netact_query'],
        'path_to_alarms': ['data', 0, 'alarmInfo'],
        'expected': fid_10_common['netact_expected']
    },
    'netact_compare_remaining': {
        'query': fid_10_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'remainingAlarms'],
        'expected': fid_10_common['netact_expected']
    },
    'netact_compare_new': {
        'query': fid_10_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'newAlarms'],
        'expected': fid_10_common['netact_expected']
    },
}

fid_4570_name = 'The following KPI formula SBTS_SFPSM_TEMPERATURE_SUM > 0 has ' \
                'been evaluated to true: CNI130136_KPI_FAULT0'
fid_4570_common = {
    'netact_query': "dn eq '{dn}' and additionalText1 eq '" + fid_4570_name + "'",
    'netact_expected': [{
        'path_to_key': ['additionalText3'],
        'value': '4570 unitName={unitName} path={path} serial_no={serialNo} '
        'additionalFaultID=4570 conf_path={conf_path}'
    }],
}
fid_4570 = {
    'webem':
    {
        'query': "alarmingObjectIds contains (runtime eq '{runtime_object}') and faultId eq 4570",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['serialNo'],
            'value': '{serialNo}'
        }, {
            'path_to_key': ['faultName'],
            'value': fid_4570_name
        },
        ],
        'internal_queries': [
            "alarmAttribute contains ((attributeName eq 'serial_no') and (attributeValue eq '{serialNo}'))",
            "alarmAttribute contains ((attributeName eq 'conf_path') and (attributeValue eq '{conf_path}'))",
        ]
    },
    'netact_live': {
        'query': fid_4570_common['netact_query'],
        'path_to_alarms': [],
        'expected': fid_4570_common['netact_expected']
    },
    'netact_snap': {
        'query': fid_4570_common['netact_query'],
        'path_to_alarms': ['data', 0, 'alarmInfo'],
        'expected': fid_4570_common['netact_expected']
    },
    'netact_compare_remaining': {
        'query': fid_4570_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'remainingAlarms'],
        'expected': fid_4570_common['netact_expected']
    },
    'netact_compare_new': {
        'query': fid_4570_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'newAlarms'],
        'expected': fid_4570_common['netact_expected']
    },
}

fid_4571_name = 'The following KPI formula SBTS_SFPSM_RX_POWER_LANE_SUM < 0 has ' \
                'been evaluated to true: CNI130136_KPI_FAULT1'
fid_4571_common = {
    'netact_query': "dn eq '{dn}' and additionalText1 eq '" + fid_4571_name + "'",
    'netact_expected': [{
        'path_to_key': ['additionalText3'],
        'value': '4571 unitName={unitName} path={path} serial_no={serialNo} '
        'additionalFaultID=4571 conf_path={conf_path}'
    }],
}
fid_4571 = {
    'webem':
    {
        'query': "alarmingObjectIds contains (runtime eq '{runtime_object}') and faultId eq 4571",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['serialNo'],
            'value': '{serialNo}'
        }, {
            'path_to_key': ['faultName'],
            'value': fid_4571_name
        },
        ],
        'internal_queries': [
            "alarmAttribute contains ((attributeName eq 'serial_no') and (attributeValue eq '{serialNo}'))",
            "alarmAttribute contains ((attributeName eq 'conf_path') and (attributeValue eq '{conf_path}'))",
        ]
    },
    'netact_live': {
        'query': fid_4571_common['netact_query'],
        'path_to_alarms': [],
        'expected': fid_4571_common['netact_expected']
    },
    'netact_snap': {
        'query': fid_4571_common['netact_query'],
        'path_to_alarms': ['data', 0, 'alarmInfo'],
        'expected': fid_4571_common['netact_expected']
    },
    'netact_compare_remaining': {
        'query': fid_4571_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'remainingAlarms'],
        'expected': fid_4571_common['netact_expected']
    },
    'netact_compare_new': {
        'query': fid_4571_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'newAlarms'],
        'expected': fid_4571_common['netact_expected']
    },
}

fid_4569_name = 'The following KPI formula SBTS_ASIR_MAX_FANSPEED > -1 has ' \
                'been evaluated to true: CNI130136_KPI_FAN_FAULT'
fid_4569_common = {
    'netact_query': "dn eq '{dn}' and additionalText1 eq '" + fid_4569_name + "'",
    'netact_expected': [{
        'path_to_key': ['additionalText3'],
        'value': '4569 unitName={unitName} path={path} serial_no={serialNo} '
        'additionalFaultID=4569'  # FAN_R-{fan_id}'
    }],
}
fid_4569 = {
    'webem':
    {
        'query': "alarmingObjectIds contains (runtime eq '{runtime_object}') and faultId eq 4569",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['serialNo'],
            'value': '{serialNo}'
        }, {
            'path_to_key': ['faultName'],
            'value': fid_4569_name
        },
        ],
        'internal_queries': [
            "alarmAttribute contains ((attributeName eq 'serial_no') and (attributeValue eq '{serialNo}'))",
            "alarmAttribute contains ((attributeName eq 'unitName') and (attributeValue eq '{unitName}'))",
        ]
    },
    'netact_live': {
        'query': fid_4569_common['netact_query'],
        'path_to_alarms': [],
        'expected': fid_4569_common['netact_expected']
    },
    'netact_snap': {
        'query': fid_4569_common['netact_query'],
        'path_to_alarms': ['data', 0, 'alarmInfo'],
        'expected': fid_4569_common['netact_expected']
    },
    'netact_compare_remaining': {
        'query': fid_4569_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'remainingAlarms'],
        'expected': fid_4569_common['netact_expected']
    },
    'netact_compare_new': {
        'query': fid_4569_common['netact_query'],
        'path_to_alarms': ['data', 'compareResultData', 0, 'alarmListsCompareResult', 'newAlarms'],
        'expected': fid_4569_common['netact_expected']
    },
}

fid_4348_asir = {
    'webem':
    {
        'query': {
            'source_object': '{so}',
            'fault_id': 4348
        },
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['fault_name'],
            'value': 'Ant Blocked'
        },
        ],
    },
    'netact_live': {
        'query': "dn eq '{dn}' and additionalText1 eq 'Ant Blocked'",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['additionalText3'],
            'value': '4348;path={path};serial_no.={serialNo};;caPartnerId=;antPortRDN={antPortRDN};'
                     'chainPosition={chainPosition};additionalFaultId=4348;conf_path={conf_path}'
        },
        ],
    },
}

fid_1911_asir = {
    'webem':
    {
        'query': {
            'source_object': '{so}',
            'fault_id': 1911
        },
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['fault_name'],
            'value': 'RX out of order'
        },
        ],
    },
    'netact_live': {
        'query': "dn eq '{dn}' and additionalText1 eq 'RX out of order'",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['additionalText3'],
            'value': '1911;path={path};serial_no.={serialNo};;caPartnerId=;antPortRDN={antPortRDN};'
                     'chainPosition={chainPosition};additionalFaultId=1911;conf_path={conf_path}'
        },
        ],
    },
}

fid_10_asir = {
    'webem':
    {
        'query': {
            'source_object': '{so}',
            'fault_id': 10
        },
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['fault_name'],
            'value': 'No connection to unit'
        },
        ],
    },
    'netact_live': {
        'query': "dn eq '{dn}' and additionalText1 eq 'No connection to unit'",
        'path_to_alarms': [],
        'expected': [{
            'path_to_key': ['additionalText3'],
            'value': '10;path={path};serial_no.={serialNo};;caPartnerId=;'
                     'additionalFaultId=10;conf_path={conf_path}'
        },
        ],
    },
}

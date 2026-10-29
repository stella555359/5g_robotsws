GNB_RESET_ALLOWED_ALARMS = [
    {'alarm_id': 7107, 'fault_id': 7300, 'fault_name': 'No X2 link available', 'severity': 'Major'},
    {'alarm_id': 7107, 'fault_id': 7319, 'fault_name': 'No X2 link available for a specific LTEENB',
     'severity': 'Major'},
    {'alarm_id': 7220, 'fault_id': 61524, 'fault_name': 'BTS Local OAM user account root has been locked',
     'severity': 'Minor'},
]
additional_allowed_alarms = [
    {'alarm_id': 7220, 'fault_id': 61510, 'fault_name': 'Automatic BTS Operator Certificate retrieval unsuccessful',
     'severity': 'Major'},
    {'alarm_id': 7115, 'fault_id': 4592, 'fault_name': 'BTS Reset Cause',
     'severity': 'Warning'},
    {'alarm_id': 7114, 'fault_id': 4479, 'fault_name': 'Failure detected on assigned antennas',
     'severity': 'Critical'},
    {'alarm_id': 7107, 'fault_id': 7316, 'fault_name': 'NgSetupFailure',
     'severity': 'Critical'},
]

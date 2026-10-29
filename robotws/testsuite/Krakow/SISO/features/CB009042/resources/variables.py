allowed_alarms_during_ru_reset = [
    {
        'fault_id': 7319,
        'fault_name': 'No X2 link available for a specific LTEENB'
    },
    {
        'fault_id': 7300,
        'fault_name': 'No X2 link available'
    },
    {
        'fault_id': 4590,
        'fault_name': 'Fault signature for crash or failure'
    },
    {
        'fault_id': 4655,
        'fault_name': 'Service account root access is enabled'
    }
]

allowed_alarms_during_bts_power_reset = [
    {
        'fault_id': 7319,
        'fault_name': 'No X2 link available for a specific LTEENB'
    },
    {
        'fault_id': 7300,
        'fault_name': 'No X2 link available'
    },
    {
        'fault_id': 4592,
        'fault_name': 'BTS Reset Cause'
    }
]

allowed_alarms_during_bts_blocked = [
    {
        'fault_id': 50,
        'fault_name': 'BTS blocked'
    },
    {
        'fault_id': 7319,
        'fault_name': 'No X2 link available for a specific LTEENB'
    },
    {
        'fault_id': 7300,
        'fault_name': 'No X2 link available'
    },
]

allowed_alarms_during_ru_power_reset = [
    {
        'fault_id': 7319,
        'fault_name': 'No X2 link available for a specific LTEENB'
    },
    {
        'fault_id': 7300,
        'fault_name': 'No X2 link available'
    },
    {
        'fault_id': 4589,
        'fault_name': 'Unit power reset'
    },
    {
        'fault_id': 10,
        'fault_name': 'No connection to unit'
    },
    {
        'fault_id': 4655,
        'fault_name': 'Service account root access is enabled'
    }
]

allowed_alarms_during_bbu_reset = [
    {
        'fault_id': 7319,
        'fault_name': 'No X2 link available for a specific LTEENB'
    },
    {
        'fault_id': 7300,
        'fault_name': 'No X2 link available'
    }
]

cells_to_delete_mapping = [
    {
        'cell_id_to_delete': '12',
        'cell_id_to_copy_from': '11',
        'cell_group_id_to_delete': '1'
    },
    {
        'cell_id_to_delete': '13',
        'cell_id_to_copy_from': '11',
        'cell_group_id_to_delete': '1'
    },
    {
        'cell_id_to_delete': '14',
        'cell_id_to_copy_from': '11',
        'cell_group_id_to_delete': '1'
    },
    {
        'cell_id_to_delete': '15',
        'cell_id_to_copy_from': '16',
        'cell_group_id_to_delete': '1'
    },
    {
        'cell_id_to_delete': '16',
        'cell_id_to_copy_from': '15',
        'cell_group_id_to_delete': '1'
    },
    {
        'cell_id_to_delete': '17',
        'cell_id_to_copy_from': '15',
        'cell_group_id_to_delete': '1'
    },

    {
        'cell_id_to_delete': '18',
        'cell_id_to_copy_from': '15',
        'cell_group_id_to_delete': '1'
    },
]

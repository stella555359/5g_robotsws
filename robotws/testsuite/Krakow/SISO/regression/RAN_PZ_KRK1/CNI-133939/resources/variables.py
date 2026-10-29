parameters_to_change = [
    [
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}',
            'parameter': 'Activate Paging',
            'value': 'true',
            'verification_value': 'true',
            'online': True
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRPMRNL-1',
            'parameter': 'NR Paging',
            'value': '5min',
            'verification_value': '5min',
            'online': True
        },
    ],
    [
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-0',
            'parameter': 'PRACH configuration index',
            'value': '14',
            'verification_value': '14',
            'online': True
        },
    ],
    [
        {
            'dist_name': 'MRBTS-{}/MNL-1/MNLENT-1/SYNC-1',
            'parameter': 'Manual frame timing adjustment',
            'value': '1',
            'verification_value': '1 µs',
            'online': False
        },
    ],
    [
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-0',
            'parameter': 'Maximum output power',
            'value': '30',
            'verification_value': '30 dBm',
            'online': True
        },
    ],
]

incorrect_parameters = [
    {
        'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-1',
        'parameter': 'Maximum output power',
        'value': '100',
        'verification_value': '27 dBm'
    },
]

delta_deactivate_rat_reset_enh = [{
    'distName': 'MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'actRatResetEnhancement',
            'value': 'false'},
        {
            'operation': 'update',
            'parameterName': 'actL1ReconfigImprovement',
            'value': 'false'},
        {
            'operation': 'update',
            'parameterName': 'actBbReconfigImprovement',
            'value': 'false'},
    ]
}]

delta_activate_rat_reset_enh = [{
    'distName': 'MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'actRatResetEnhancement',
            'value': 'true'},
        {
            'operation': 'update',
            'parameterName': 'actL1ReconfigImprovement',
            'value': 'true'},
        {
            'operation': 'update',
            'parameterName': 'actBbReconfigImprovement',
            'value': 'true'},
    ]
}]

allowed_alarms_during_cell_block = ['Cell blocked']

nrcellids_to_reconfiguring_dlmimomode = ['0', '1', '2']

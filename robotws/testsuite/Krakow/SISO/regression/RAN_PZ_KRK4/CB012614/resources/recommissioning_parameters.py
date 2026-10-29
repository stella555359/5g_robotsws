from robot.libraries.BuiltIn import BuiltIn

# pmax_verification_value = '17' if 'SBTS25R3' in str(BuiltIn().get_variable_value('${ENB_BRANCH}')) else '17 dBm'

parameters_to_change = [
    [
        {
            'dist_name': 'MRBTS-{}/MNL-1',
            'parameter': 'Time zone',
            'value': '(GMT+0) UTC',
            'verification_value': '(GMT+0) UTC'
        },
    ],
    [
        {
            'dist_name': 'MRBTS-{}/MNL-1/AMGR-1/LUAC-1',
            'parameter': 'BTS maximum failed login attempts',
            'value': '10',
            'verification_value': '10'
        },
    ],
]

incorrect_parameters = [
    {
        'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-1',
        'parameter': 'Maximum output power',
        'value': '100',
        'verification_value': '17 dBm'
    },
]

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

nrcellids_to_reconfiguring_dlmimomode_A = ['0', '1', '2', '3', '4', '5']

nrcellids_to_reconfiguring_dlmimomode_B = ['0', '1', '2']

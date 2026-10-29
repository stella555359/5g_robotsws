automated_activation_on = [
    {
        'distName': 'MRBTS-{}/MNL-1',
        'operation': 'update',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'autoInstallOfPredefinedRu',
            'value': 'true'}]
    }
]

automated_activation_off = [
    {
        'distName': 'MRBTS-{}/MNL-1',
        'operation': 'update',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'autoInstallOfPredefinedRu',
            'value': 'false'}]
    }
]

predefined_delta = [
    {
        'distName': 'MRBTS-{}/EQM-1/APEQM-1/RMOD-3',
        'operation': 'update',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'predefined',
            'value': 'true'}]
    }
]

not_predefined_delta = [
    {
        'distName': 'MRBTS-{}/EQM-1/APEQM-1/RMOD-3',
        'operation': 'update',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'predefined',
            'value': 'false'}]
    }
]

predefined_cells = [31, 32, 33, 34]

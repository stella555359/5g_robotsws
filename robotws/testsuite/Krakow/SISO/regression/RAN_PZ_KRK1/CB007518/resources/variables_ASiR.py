predefined_delta = [
    {
        'distName': 'MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-3',
        'operation': 'update',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'predefined',
            'value': 'true'}]
    }
]

not_predefined_delta = [
    {
        'distName': 'MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-3',
        'operation': 'update',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'predefined',
            'value': 'false'}]
    }
]

asir_delta = [
    {
        'distName': 'ASI-1/HUBMOD-1',
        'parameters': [{
            'operation': 'create',
            'parameterName': 'predefined',
            'value': 'true'}]
    }
]

not_predefined_asir_delta = [
    {
        'distName': 'ASI-1/HUBMOD-1',
        'parameters': [{
            'operation': 'delete',
            'parameterName': 'predefined'}]
    }
]

prodCodePlanned_delta = {
    "correct": [{
        'distName': 'MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-3',
        'operation': 'update',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'prodCodePlanned',
            'value': '475295A'}]
    }],
    "incorrect": [{
        'distName': 'MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-3',
        'operation': 'update',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'prodCodePlanned',
            'value': '476239A'}]
    }]
}

predefined_cells = [2103, 3503, 3603, 3]

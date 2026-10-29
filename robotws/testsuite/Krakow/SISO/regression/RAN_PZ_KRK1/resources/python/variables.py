delta_dlmimomode_template = {
    'delta_deactivate_dl_mimo_8x4': {
        'distName': 'MRBTS-{}/NRBTS-{}/',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'dlMimoMode',
                'value': '4x4 or 4x2 Closed Loop Spatial Multiplexing'},
            {
                'operation': 'update',
                'parameterName': 'periodicCsiAcquisition',
                'value': [
                    {
                        'csiReportPeriodicity': 'slots320',
                        'scramblingIdStep': '3',
                    }
                ]
            },
        ]
    },
    'delta_activate_dl_mimo_8x4':  {
        'distName': 'MRBTS-{}/NRBTS-{}/',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'dlMimoMode',
                'value': '8x4 Closed Loop Spatial Multiplexing'},
            {
                'operation': 'update',
                'parameterName': 'periodicCsiAcquisition',
                'value': [
                    {
                        'csiReportPeriodicity': 'slots320',
                        'csirsNumberWithinReportPeriod_Set1': '1',
                        'csirsPower': '18',
                        'maxCsirsNumber': '4',
                        'scramblingIdStep': '3',
                        },
                ]
            },
        ]
    },
}

delta_20_2 = [{
    'distName': 'MRBTS-78155/EQM-1/APEQM-1/ASIRMOD-20',
    'operation': 'update',
    'parameters': [{
        'operation': 'update',
        'parameterName': 'asiRModId',
        'value': '2'
    }]
}]

delta_kpi_configure = [
    {
        'distName': 'MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'mtSBTSSfpSMOD',
                'value': '5min'
            },
            {
                'operation': 'update',
                'parameterName': 'mtSbtsSfpSmodLane',
                'value': '5min'
            },
            {
                'operation': 'update',
                'parameterName': 'mtSBTSASIRMODFan',
                'value': '5min'
            },
        ]
    },
    {
        'distName': 'MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'kpiAlarmTriggers',
                'value': [
                    {
                        'faultID': '4570',
                        'formulaDescription': 'CNI130136_KPI_FAULT0',
                        'timeToTrigger': 0,
                        'triggeringFormula': 'SBTS_SFPSM_TEMPERATURE_SUM > 0'
                    },
                    {
                        'faultID': '4571',
                        'formulaDescription': 'CNI130136_KPI_FAULT1',
                        'timeToTrigger': 0,
                        'triggeringFormula': 'SBTS_SFPSM_RX_POWER_LANE_SUM < 0'
                    },
                    {
                        'faultID': '4569',
                        'formulaDescription': 'CNI130136_KPI_FAN_FAULT',
                        'timeToTrigger': 0,
                        'triggeringFormula': 'SBTS_ASIR_MAX_FANSPEED > -1'
                    },
                ]
            },
        ]
    },
]

delta_kpi_deconfigure = [
    {
        'distName': 'MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'mtSBTSSfpSMOD',
                'value': 'disabled'
            },
            {
                'operation': 'update',
                'parameterName': 'mtSbtsSfpSmodLane',
                'value': 'disabled'
            },
            {
                'operation': 'update',
                'parameterName': 'mtSBTSASIRMODFan',
                'value': 'disabled'
            },
        ]
    },
    {
        'distName': 'MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'delete',
                'parameterName': 'kpiAlarmTriggers',
            },
        ]
    },
]

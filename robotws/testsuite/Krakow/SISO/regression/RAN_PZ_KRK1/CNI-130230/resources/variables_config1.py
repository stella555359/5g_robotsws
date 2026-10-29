lanes = {
    "0":
        {
            'dist_name': 'MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1',
            'parameter': 'Administrative state',
            'value': 'Locked',
            'verification_value': 'Locked',
            'return_value': 'Unlocked',
            'return_verification_value': 'Unlocked',
            'alarm': "10",
            'affected_cells': ['all']
        }
}

linkspeed_parameters = {
            'dist_name': 'MRBTS-{}/EQM-1/HWTOP-1/CABLINK-6',
            'parameter': 'Link speed',
            'value': 'eCpri10',
            'verification_value': 'eCpri10',
            'return_value': 'eCpri25',
            'return_verification_value': 'eCpri25',
            'alarm': '1868',
            'affected_cells': ['all']
        }

max_linkspeed = {
            'dist_name': 'MRBTS-{}/EQM_R-4/HWTOP_R-1/CABLINK_R-1001',
            'parameter': 'Link maximum physical capacity',
            'value': '10312 (Mb/s)',
            'return_value': '25781 (Mb/s)'
        }

cablink_parameters = {
    "6":
        {
            'ethIfId': '1',
            'linkSelectorDN': 'MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-1',
            'parameters': {
                            'First endpoint distinguished name': 'MRBTS-75114/EQM-1/APEQM-1/CABINET-1/BBMOD-1',
                            'First endpoint port label': 'OPT',
                            'First endpoint port identifier': '1',
                            'IQ compression': 'eCPRI IQ9_E7',
                            'Link speed': 'eCpri25',
                            'Radio protocol type': 'eCPRI',
                            'Second endpoint distinguished name': 'MRBTS-75114/EQM-1/APEQM-1/RMOD-3',
                            'Second endpoint label': 'OPT',
                            'Second endpoint port identifier': '1'
            }
        },
    "7":
        {
            'ethIfId': '2',
            'linkSelectorDN': 'MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2',
            'parameters': {
                            'First endpoint distinguished name': 'MRBTS-75114/EQM-1/APEQM-1/CABINET-1/BBMOD-1',
                            'First endpoint port label': 'OPT',
                            'First endpoint port identifier': '2',
                            'IQ compression': 'eCPRI IQ9_E7',
                            'Link speed': 'eCpri25',
                            'Radio protocol type': 'eCPRI',
                            'Second endpoint distinguished name': 'MRBTS-75114/EQM-1/APEQM-1/RMOD-3',
                            'Second endpoint label': 'OPT',
                            'Second endpoint port identifier': '2'
            }
        }
}

allowed_alarms_during_lane_block = ['No connection to unit']

BTS_DIST = 'MRBTS-11156/NRBTS-11156'


ulConfiguredGrantType2_75 = [{
            'maxGBRAndCgType2TrafficLimit': '75',
            'ulCgMaxNumPrbs': '52',
            'ulCgMaxNumUeUl': '2',
            'ulCgPrbStartOffset': '0'
         }
    ]

ulConfiguredGrantType2_75_false = [{
            'ulCgMaxNumPrbs': '4',
            'ulCgMaxNumUeUl': '1',
            'ulCgPrbStartOffset': '0'
         }
    ]

ulConfiguredGrantType2_55 = [{
            'maxGBRAndCgType2TrafficLimit': '55',
            'ulCgMaxNumPrbs': '68',
            'ulCgMaxNumUeUl': '10',
            'ulCgPrbStartOffset': '0'
         }
    ]

actUlCgType2_true = [
    dict(dist_name=BTS_DIST+'/NRCELL-1', parameter='actUlCgType2', value='true', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-2', parameter='actUlCgType2', value='true', operation='update'),
    dict(dist_name=BTS_DIST+'/NRULCG_PROFILE-1', parameter='', value='', operation='create_object'),
    dict(dist_name=BTS_DIST+'/NRULCG_PROFILE-1', parameter='grantedPacketSize', value='1200', operation='update'),
    dict(dist_name=BTS_DIST+'/NRULCG_PROFILE-1', parameter='maxNumPrbs', value='12', operation='update'),
    dict(dist_name=BTS_DIST+'/NRULCG_PROFILE-1', parameter='periodicity', value='ms80', operation='update'),
    dict(dist_name=BTS_DIST+'/NRDRB-11', parameter='nrDrbUlCgDN',
         value='MRBTS-11156/NRBTS-11156/NRULCG_PROFILE-1', operation='update'),
    dict(dist_name=BTS_DIST+'/NRDRB-12', parameter='nrDrbUlCgDN',
         value='MRBTS-11156/NRBTS-11156/NRULCG_PROFILE-1', operation='update'),
    dict(dist_name=BTS_DIST+'/NRDRB-13', parameter='nrDrbUlCgDN',
         value='MRBTS-11156/NRBTS-11156/NRULCG_PROFILE-1', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-1', parameter='ulConfiguredGrantType2',
         value=ulConfiguredGrantType2_75, operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-2', parameter='ulConfiguredGrantType2',
         value=ulConfiguredGrantType2_75, operation='update')
]

actUlCgType2_false = [
    dict(dist_name=BTS_DIST+'/NRCELL-1', parameter='actUlCgType2', value='false', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-2', parameter='actUlCgType2', value='false', operation='update'),
    dict(dist_name=BTS_DIST+'/NRULCG_PROFILE-1', parameter='', value='', operation='delete_object'),
    dict(dist_name=BTS_DIST+'/NRDRB-11', parameter='nrDrbUlCgDN', value='', operation='delete'),
    dict(dist_name=BTS_DIST+'/NRDRB-12', parameter='nrDrbUlCgDN', value='', operation='delete'),
    dict(dist_name=BTS_DIST+'/NRDRB-13', parameter='nrDrbUlCgDN', value='', operation='delete'),
    dict(dist_name=BTS_DIST+'/NRCELL-1', parameter='ulConfiguredGrantType2',
         value=ulConfiguredGrantType2_75_false, operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-2', parameter='ulConfiguredGrantType2',
         value=ulConfiguredGrantType2_75_false, operation='update')
]

ulConfigured_55 = [
    dict(dist_name=BTS_DIST+'/NRCELL-1', parameter='ulConfiguredGrantType2',
         value=ulConfiguredGrantType2_55, operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-2', parameter='ulConfiguredGrantType2',
         value=ulConfiguredGrantType2_55, operation='update')
]

NRULCG_PROFILE = [
    dict(dist_name=BTS_DIST+'/NRULCG_PROFILE-1', parameter='grantedPacketSize', value='1000', operation='update'),
    dict(dist_name=BTS_DIST+'/NRULCG_PROFILE-1', parameter='maxNumPrbs', value='24', operation='update'),
    dict(dist_name=BTS_DIST+'/NRULCG_PROFILE-1', parameter='periodicity', value='ms40', operation='update')
]

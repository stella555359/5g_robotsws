RMOD_ECPRI_fid16_exceptions = ['AEHC', 'AZHL', 'AENB', 'AZQS', 'AZQU']
RMOD_CNI_103974_exceptions = ['AWHHD', 'AWHHH']
RMOD_CB010846_exceptions = ['MRM6', '5MF5', 'FRC3', 'TDL3', '5GH4', '5LL3', '5GL3']
RMOD_CB012446_exceptions = ['MRM6', '5MF5', 'FRC3', 'TDL3', '5GH4', '5LL3', '5GL3']

RMOD_snapshot_rules = {
    'default': ['BTS[0-9A-Z]*_${RMOD_sn}_RMOD_L_[0-9]{1,}_(ram_){0,1}runtime.zip',
                'BTS[0-9A-Z]*_${RMOD_sn}_RMOD_L_[0-9]{1,}_(ram_){0,1}startup.zip'],
    'default_optional': ['BTS[0-9A-Z]*_${RMOD_sn}_RMOD_L_[0-9]{1}_pm_1_syslog.zip',
                         'BTS[0-9A-Z]*_${RMOD_sn}_RMOD_L_[0-9]{1}_pm_2_syslog.zip'],
    'srm7': ['BTS[0-9A-Z]*_${RMOD_sn}_RMOD_L_[0-9]{1}_ccsrt-runtime.tar.gz',
             'BTS[0-9A-Z]*_${RMOD_sn}_RMOD_L_[0-9]{1}_ccsrt-startup.tar.gz'],
    'srm7_optional': [],
    'fru6': ['BTS[0-9A-Z]*_${RMOD_sn}_RMOD_L_[0-9]{1}_ccsrt-runtime.tar.gz',
             'BTS[0-9A-Z]*_${RMOD_sn}_RMOD_L_[0-9]{1}_ccsrt-startup.tar.gz'],
    'fru6_optional': [],
    'frm6': ['BTS[0-9A-Z]*_${RMOD_sn}_RMOD_L_[0-9]{1,}_runtime.zip',
             'BTS[0-9A-Z]*_${RMOD_sn}_RMOD_L_[0-9]{1,}_startup.zip'],
    'frm6_optional': []
}

# ABIA_AirScale_Capacity = {'POWERGROUP-1': [1, 2, 3, 4, 5, 6],
#                          'POWERGROUP-2': [1, 2, 3, 4, 5, 6],
#                          'hwVariant': 'Kepler2'}

# ABIC_AirScale_Capacity = {'POWERGROUP-1': [1, 2, 3, 4, 5, 6, 7, 8, 9],
#                          'POWERGROUP-2': [1, 2, 3, 4, 5, 6, 7, 8, 9],
#                          'hwVariant': 'Lionfish'}

ABIL_AirScale_Capacity = {'POWERGROUP-1': [1, 2, 3, 4],
                          'hwVariant': 'XeonD'}

ABIN_AirScale_Capacity = {'POWERGROUP-1': [1, 2, 3, 4, 5, 6, 7, 8, 9],
                          'hwVariant': 'Loki'}

ABIO_AirScale_Capacity = {'POWERGROUP-1': [1, 2, 3, 4, 5, 6],
                          'POWERGROUP-2': [7, 8, 9],
                          'hwVariant': 'Loki'}

ABIP_AirScale_Capacity = {'POWERGROUP-1': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                          'hwVariant': 'Thor'}

ABIQ_AirScale_Capacity = {'POWERGROUP-1': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                          'hwVariant': 'Thor'}

ASOE_AirScale_Core = {'POWERGROUP-1': [1, 2, 3, 4, 5, 6],
                      'POWERGROUP-2': [7, 8, 9, 10, 11, 12],
                      'hwVariant': 'Loki'}

ASOH_AirScale_Core = {'POWERGROUP-1': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                      'hwVariant': 'Thor'}

Reset_dependency_rules = {
    'SHARED_RMOD': {('CPRI',): {'disabled':
                                {'linkModeConfiguration': 'True',
                                 'relation': 'and',
                                 'linkModeSynchronization': 'False'},
                                'reset':
                                {'linkModeSynchronization': 'True'},
                                'enabled':
                                {'linkModeSynchronization': 'False',
                                 'relation': 'and',
                                 'linkModeConfiguration': 'False'}},
                    ('CPRI_IN_FHS',): {'disabled':
                                       {'linkModeConfiguration': 'True',
                                        'relation': 'and',
                                        'linkModeSynchronization': 'False'},
                                       'reset':
                                       {'linkModeSynchronization': 'True'},
                                       'enabled':
                                       {'linkModeSynchronization': 'False',
                                        'relation': 'and',
                                        'linkModeConfiguration': 'False'}},
                    ('ECPRI',): {'disabled':
                                 {'linkModeConfiguration': 'True',
                                  'relation': 'and',
                                  'linkModeSynchronization': 'False'},
                                 'reset':
                                 {'linkModeSynchronization': 'True'},
                                 'enabled':
                                 {'linkModeSynchronization': 'False',
                                  'relation': 'and',
                                  'linkModeConfiguration': 'False'}},
                    ('ECPRI_NETCONF',): {'disabled':
                                         {'linkModeConfiguration': 'True',
                                          'relation': 'and',
                                          'linkModeSynchronization': 'False'},
                                         'reset':
                                         {'linkModeSynchronization': 'True'},
                                         'enabled':
                                         {'linkModeSynchronization': 'False',
                                          'relation': 'and',
                                          'linkModeConfiguration': 'False'}},
                    ('OBSAI',): {'disabled':
                                 {'linkModeConfiguration': 'True',
                                  'relation': 'and',
                                  'linkModeSynchronization': 'False'},
                                 'reset':
                                 {'linkModeSynchronization': 'True'},
                                 'enabled':
                                 {'linkModeSynchronization': 'False',
                                  'relation': 'and',
                                  'linkModeConfiguration': 'False'}}},
    'SHARED_FHS': {('CPRI',): {'disabled':
                               {'linkModeConfiguration': 'True',
                                'relation': 'and',
                                'linkModeSynchronization': 'False'},
                               'reset':
                               {'linkModeSynchronization': 'True'},
                               'enabled':
                               {'linkModeSynchronization': 'False',
                                'relation': 'and',
                                'linkModeConfiguration': 'False'}}},
    'DEDICATED_RMOD': {('CPRI',): {'disabled':
                                   {},
                                   'reset':
                                   {'linkModeConfiguration': 'True',
                                    'relation': 'or',
                                    'linkModeSynchronization': 'True'},
                                   'enabled':
                                   {'linkModeSynchronization': 'False',
                                    'relation': 'and',
                                    'linkModeConfiguration': 'False'}},
                       ('CPRI_IN_FHS',): {'disabled':
                                          {},
                                          'reset':
                                          {'linkModeConfiguration': 'True',
                                           'relation': 'or',
                                           'linkModeSynchronization': 'True'},
                                          'enabled':
                                          {'linkModeSynchronization': 'False',
                                           'relation': 'and',
                                           'linkModeConfiguration': 'False'}},
                       ('ECPRI',): {'disabled':
                                    {'linkModeSynchronization': 'True',
                                     'relation': 'and',
                                     'linkModeConfiguration': 'False'},
                                    'reset':
                                    {'linkModeConfiguration': 'True'},
                                    'enabled':
                                    {'linkModeSynchronization': 'False',
                                     'relation': 'and',
                                     'linkModeConfiguration': 'False'}},
                       ('ECPRI_NETCONF',): {'disabled':
                                            {'linkModeConfiguration': 'True',
                                             'relation': 'and',
                                             'linkModeSynchronization': 'False'},
                                            'reset':
                                            {'linkModeSynchronization': 'True'},
                                            'enabled':
                                            {'linkModeSynchronization': 'False',
                                             'relation': 'and',
                                             'linkModeConfiguration': 'False'}},
                       ('OBSAI',): {'disabled':
                                    {},
                                    'reset':
                                    {'linkModeSynchronization': 'True',
                                     'relation': 'or',
                                     'linkModeConfiguration': 'True'},
                                    'enabled':
                                    {'linkModeSynchronization': 'False',
                                     'relation': 'and',
                                     'linkModeConfiguration': 'False'}}},
    'DEDICATED_FHS': {('CPRI',): {'disabled':
                                  {},
                                  'reset':
                                  {'linkModeConfiguration': 'True',
                                   'relation': 'or',
                                   'linkModeSynchronization': 'True'},
                                  'enabled':
                                  {'linkModeSynchronization': 'False',
                                   'relation': 'and',
                                   'linkModeConfiguration': 'False'}}}}

Reset_dependency_rules_CB007447 = {
    'SHARED_RMOD': {('CPRI',): {'disabled':
                                {'linkModeConfiguration': 'True'},
                                'reset':
                                {},
                                'enabled':
                                {'linkModeConfiguration': 'False'}},
                    ('CPRI_IN_FHS',): {'disabled':
                                       {'linkModeConfiguration': 'True',
                                        'relation': 'and',
                                        'linkModeSynchronization': 'False'},
                                       'reset':
                                       {'linkModeSynchronization': 'True'},
                                       'enabled':
                                       {'linkModeSynchronization': 'False',
                                        'relation': 'and',
                                        'linkModeConfiguration': 'False'}},
                    ('CPRI_no_CB007447',): {'disabled':
                                            {'linkModeConfiguration': 'True',
                                             'relation': 'and',
                                             'linkModeSynchronization': 'False'},
                                            'reset':
                                            {'linkModeSynchronization': 'True'},
                                            'enabled':
                                            {'linkModeSynchronization': 'False',
                                             'relation': 'and',
                                             'linkModeConfiguration': 'False'}},
                    ('ECPRI',): {'disabled':
                                 {'linkModeConfiguration': 'True',
                                  'relation': 'and',
                                  'linkModeSynchronization': 'False'},
                                 'reset':
                                 {'linkModeSynchronization': 'True'},
                                 'enabled':
                                 {'linkModeSynchronization': 'False',
                                  'relation': 'and',
                                  'linkModeConfiguration': 'False'}},
                    ('ECPRI_NETCONF',): {'disabled':
                                         {'linkModeConfiguration': 'True',
                                          'relation': 'and',
                                          'linkModeSynchronization': 'False'},
                                         'reset':
                                         {'linkModeSynchronization': 'True'},
                                         'enabled':
                                         {'linkModeSynchronization': 'False',
                                          'relation': 'and',
                                          'linkModeConfiguration': 'False'}},
                    ('OBSAI',): {'disabled':
                                 {'linkModeConfiguration': 'True',
                                  'relation': 'and',
                                  'linkModeSynchronization': 'False'},
                                 'reset':
                                 {'linkModeSynchronization': 'True'},
                                 'enabled':
                                 {'linkModeSynchronization': 'False',
                                  'relation': 'and',
                                  'linkModeConfiguration': 'False'}},
                    },
    'SHARED_FHS': {('CPRI',): {'disabled':
                               {'linkModeConfiguration': 'True',
                                'relation': 'and',
                                'linkModeSynchronization': 'False'},
                               'reset':
                               {'linkModeSynchronization': 'True'},
                               'enabled':
                               {'linkModeSynchronization': 'False',
                                'relation': 'and',
                                'linkModeConfiguration': 'False'}}},
    'DEDICATED_RMOD': {('CPRI',): {'disabled':
                                   {'linkModeConfiguration': 'True'},
                                   'reset':
                                   {},
                                   'enabled':
                                   {'linkModeConfiguration': 'False'}},
                       ('CPRI_IN_FHS',): {'disabled':
                                          {},
                                          'reset':
                                          {'linkModeConfiguration': 'True',
                                           'relation': 'or',
                                           'linkModeSynchronization': 'True'},
                                          'enabled':
                                          {'linkModeSynchronization': 'False',
                                           'relation': 'and',
                                           'linkModeConfiguration': 'False'}},
                       ('CPRI_no_CB007447',): {'disabled':
                                               {},
                                               'reset':
                                               {'linkModeConfiguration': 'True',
                                                'relation': 'or',
                                                'linkModeSynchronization': 'True'},
                                               'enabled':
                                               {'linkModeSynchronization': 'False',
                                                'relation': 'and',
                                                'linkModeConfiguration': 'False'}},
                       ('ECPRI',): {'disabled':
                                    {'linkModeSynchronization': 'True',
                                     'relation': 'and',
                                     'linkModeConfiguration': 'False'},
                                    'reset':
                                    {'linkModeConfiguration': 'True'},
                                    'enabled':
                                    {'linkModeSynchronization': 'False',
                                     'relation': 'and',
                                     'linkModeConfiguration': 'False'}},
                       ('ECPRI_NETCONF',): {'disabled':
                                            {'linkModeConfiguration': 'True',
                                             'relation': 'and',
                                             'linkModeSynchronization': 'False'},
                                            'reset': {'linkModeSynchronization': 'True'},
                                            'enabled':
                                            {'linkModeSynchronization': 'False',
                                             'relation': 'and',
                                             'linkModeConfiguration': 'False'}},
                       ('OBSAI',): {'disabled':
                                    {},
                                    'reset':
                                    {'linkModeSynchronization': 'True',
                                     'relation': 'or',
                                     'linkModeConfiguration': 'True'},
                                    'enabled':
                                    {'linkModeSynchronization': 'False',
                                     'relation': 'and',
                                     'linkModeConfiguration': 'False'}}},
    'DEDICATED_FHS': {('CPRI',): {'disabled':
                                  {},
                                  'reset':
                                  {'linkModeConfiguration': 'True',
                                   'relation': 'or',
                                   'linkModeSynchronization': 'True'},
                                  'enabled':
                                  {'linkModeSynchronization': 'False',
                                   'relation': 'and',
                                   'linkModeConfiguration': 'False'}}}}

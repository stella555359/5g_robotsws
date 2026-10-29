DURATION_STANDARD = {
    'parameters_description':
    {
        'format':
        {
            'OPER_TYPE':
            {
                'ACTION_TYPE':
                {
                    'MO_TYPE': 1
                }
            }
        },
        'enum':
            {
            'OPER_TYPE': ['VALIDATE', 'PREACTIVATE', 'ACTIVATE', 'PROVISION'],
            'MO_TYPE': ['2G-CELL', '3G-CELL', '4G-CELL', '5G-CELL', 'ALL-CELL',
                        'ADD-DEL-CELL', '2G-RAT', '3G-RAT', '4G-RAT', '5G-RAT', 'SITE',
                        'CREAT-PCMD-TRACE', 'CREAT-CELL-TRACE', 'UC', 'ADD-DEL-NEIG-NE',
                        'ADD-DEL-NEIG-CELL', 'GENERAL'],
            'ACTION_TYPE': ['ONLINE', 'OUTAGE', 'ERROR', 'GENERAL']
            }
    },
    'PROVISION':
    {
        'ONLINE':
        {
            'GENERAL':
            {
                'duration_standard': 115,
                'params':
                {
                    'class': 'com.nokia.srbts:MRBTS',
                    'operation': 'update',
                    'parameters':
                    {
                        'btsName': ['CB008457_TA_name_1', 'CB008457_TA_name_2']
                    },
                    'expect_status': ''
                }
            }
        }
    },
    'VALIDATE':
    {
        'ONLINE':
        {
            '2G-CELL':
            {
                'duration_standard': 35,
                'params':
                {}
            },
            '3G-CELL':
            {
                'duration_standard': 35,
                'params':
                {}
            },
            '4G-CELL':
            {
                'duration_standard': 35,
                'params':
                {}
            },
            '5G-CELL':
            {
                'duration_standard': 35,
                'params':
                {}
            },
            'ALL-CELL':
            {
                'duration_standard': 40,
                'params':
                {}
            },
            'ADD-DEL-CELL':
            {
                'duration_standard': 40,
                'params':
                {}
            },
            'CREAT-PCMD-TRACE':
            {
                'duration_standard': 35,
                'params':
                {}
            },
            'CREAT-CELL-TRACE':
            {
                'duration_standard': 35,
                'params':
                {}
            },
            'ADD-DEL-NEIG-NE':
            {
                'duration_standard': 35,
                'params':
                {}
            },
            'ADD-DEL-NEIG-CELL':
            {
                'duration_standard': 35,
                'params':
                {}
            },
            'GENERAL':
            {
                'duration_standard': 45,
                'params':
                {
                    'class': 'com.nokia.srbts.mnl:FEATCADM',
                    'operation': 'update',
                    'parameters':
                    {
                        'actDtPim': ['0', '1']
                    },
                    'expect_status': ''
                }
            }
        }
    },
    'PREACTIVATE':
    {
        'ERROR':
        {
            'GENERAL':
            {
                'duration_standard': 60,
                'params':
                {
                    'class': 'NOKLTE:LNCEL',
                    'operation': 'delete',
                    'parameters':
                    {
                    },
                    'expect_status': ''
                }
            }
        },
        'GENERAL':
        {
            'GENERAL':
            {
                'duration_standard': 60,
                'params':
                {}
            }
        }
    },
    'ACTIVATE':
    {
        'ONLINE':
        {
            '2G-CELL':
            {
                'duration_standard': 50,
                'params':
                {}
            },
            '3G-CELL':
            {
                'duration_standard': 50,
                'params':
                {}
            },
            '4G-CELL':
            {
                'duration_standard': 50,
                'params':
                {}
            },
            '5G-CELL':
            {
                'duration_standard': 50,
                'params':
                {}
            },
            'ALL-CELL':
            {
                'duration_standard': 55,
                'params':
                {}
            },
            'ADD-DEL-CELL':
            {
                'duration_standard': 55,
                'params':
                {}
            },
            'CREAT-PCMD-TRACE':
            {
                'duration_standard': 50,
                'params':
                {}
            },
            'CREAT-CELL-TRACE':
            {
                'duration_standard': 50,
                'params':
                {}
            },
            'ADD-DEL-NEIG-NE':
            {
                'duration_standard': 50,
                'params':
                {}
            },
            'ADD-DEL-NEIG-CELL':
            {
                'duration_standard': 50,
                'params':
                {}
            },
            'GENERAL':
            {
                'duration_standard': 60,
                'params':
                {
                    'class': 'com.nokia.srbts:MRBTS',
                    'operation': 'update',
                    'parameters':
                    {
                        'btsName': ['CB008457_TA_name_1', 'CB008457_TA_name_2']
                    },
                    'expect_status': ''
                }
            }
        },
        'OUTAGE':
        {
            '2G-RAT':
            {
                'duration_standard': 100,
                'params':
                {}
            },
            '3G-RAT':
            {
                'duration_standard': 80,
                'params':
                {}
            },
            '4G-RAT':
            {
                'duration_standard': 80,
                'params':
                {}
            },
            '5G-RAT':
            {
                'duration_standard': 80,
                'params':
                {
                    'class': 'com.nokia.srbts.mnl:FEATCADM',
                    'operation': 'update',
                    'parameters':
                    {
                        'actDtPim': ['0', '1']
                    },
                    'expect_status': 'RAT:nr:ALL_DISABLED'
                }
            },
            'SITE':
            {
                'duration_standard': 575,
                'params':
                {}
            }
        }
    }
}

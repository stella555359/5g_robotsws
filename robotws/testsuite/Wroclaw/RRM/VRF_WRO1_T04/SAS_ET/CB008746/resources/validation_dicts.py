DELTA_DYN_KEYS_A_B601_OAM_VALIDATION = {
    'bip_quotas': {
        1: {
            'min': '10',
            'max': '50'
        },
    },
    'spid_slicing_activated': True,
    'default_resource_group_ids': [1],
    'resource_group_ids': [1],
    'plmns': {1: {
        'mcc': '311',
        'mnc': '489',
        'mnc_length': '3'
    }},
    'cell_params': {
        '$nrCellId': {
            'FDD': '3',
            'TDD': '1'
        },
        '$cellDepType': 'SA+NSA'
    }
}

DELTA_DYN_KEYS_A_B601_NO_SPID_VALIDATION = {
    'bip_quotas': {
        1: {
            'min': '10',
            'max': '50'
        },
        2: {
            'min': '20',
            'max': '75'
        },
        3: {
            'min': '15',
            'max': '90'
        },
        4: {
            'min': '25',
            'max': '100'
        },
        5: {
            'min': '25',
            'max': '70'
        },
    },
    'quotas': {
        '$minQuotaGrp1': '10',
        '$maxQuotaGrp1': '50',
        '$minQuotaGrp2': '20',
        '$maxQuotaGrp2': '75',
        '$minQuotaGrp3': '15',
        '$maxQuotaGrp3': '90',
        '$minQuotaGrp4': '25',
        '$maxQuotaGrp4': '100',
        '$minQuotaGrp5': '25',
        '$maxQuotaGrp5': '100',
    },
    'dn_list': {
        '$resourceGroup1_dn': 'NRSPID-1',
        '$resourceGroup2_dn': 'NRSPID-2',
        '$resourceGroup3_dn': 'NRSPID-3',
        '$resourceGroup4_dn': 'NRSPID-4',
        '$resourceGroup5_dn': 'NRSPID-5',
    },
    'spid_slicing_activated': True,
    'default_resource_group_ids': [2, 3, 4],
    'resource_group_ids': [1, 2, 3, 4, 5],
    'plmns':
        {
            1: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            2: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },

            3: {
                'mcc': '312',
                'mnc': '490',
                'mnc_length': '3'
            },
            4: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
            5: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
        },
    'cell_params': {
        '$nrCellId': {
            'FDD': '3',
            'TDD': '1'
        },
        '$cellDepType': 'SA+NSA'
    }
}

DELTA_DYN_KEYS_A_B105_003_VALIDATION = {
    'bip_quotas': {
        1: {
            'min': '10',
            'max': '80'
        },
        2: {
            'min': '20',
            'max': '60'
        },
        3: {
            'min': '15',
            'max': '30'
        }
    },
    'quotas': {
        '$minQuotaGrp1': '10',
        '$maxQuotaGrp1': '80',
        '$minQuotaGrp2': '20',
        '$maxQuotaGrp2': '60',
        '$minQuotaGrp3': '15',
        '$maxQuotaGrp3': '30'
    },
    'dn_list': {
        '$resourceGroup1_dn': 'NRSPID-1',
        '$resourceGroup2_dn': 'NRSPID-2',
        '$resourceGroup3_dn': 'NRSPID-3',
    },
    'spid': {
        '$spidGrp1': '256',
        '$spidGrp2': '54',
        '$spidLastGrp2': '59',
        '$spidGrp3': '103',
        '$spidLastGrp3': '107'
    },
    'spid_slicing_activated': True,
    'default_resource_group_ids': [2, 8, 14, 23, 26, 31],
    'resource_group_ids': [i for i in range(1, 33)],
    'plmns':
        {
            1: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            2: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            3: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            4: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            5: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            6: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            }
        },
    'cell_params': {
        '$nrCellId': {
            'FDD': '3',
            'TDD': '1'
        },
        '$cellDepType': 'SA+NSA'
    }
}

DELTA_DYN_KEYS_A_B301_001_VALIDATION = {
    'bip_quotas': {
        1: {
            'min': '10',
            'max': '80'
        },
        2: {
            'min': '5',
            'max': '70'
        },
        3: {
            'min': '20',
            'max': '100'
        },
        4: {
            'min': '5',
            'max': '70'
        },
        5: {
            'min': '20',
            'max': '100'
        },
        6: {
            'min': '15',
            'max': '75'
        },
        7: {
            'min': '10',
            'max': '80'
        },
    },

    'quotas': {
        '$minQuotaGrp1': '10',
        '$maxQuotaGrp1': '80',
        '$minQuotaGrp2': '5',
        '$maxQuotaGrp2': '70',
        '$minQuotaGrp3': '20',
        '$maxQuotaGrp3': '100',
        '$minQuotaGrp4': '5',
        '$maxQuotaGrp4': '70',
        '$minQuotaGrp5': '20',
        '$maxQuotaGrp5': '100',
        '$minQuotaGrp6': '15',
        '$maxQuotaGrp6': '75',
        '$minQuotaGrp7': '10',
        '$maxQuotaGrp7': '80',
    },
    'dn_list': {
        '$resourceGroup1_dn': 'SNSSAI-1',
        '$resourceGroup2_dn': 'SNSSAI-2',
        '$resourceGroup3_dn': 'SNSSAI-3',
        '$resourceGroup4_dn': 'NRSPID-1',
        '$resourceGroup5_dn': 'NRSPID-2',
        '$resourceGroup6_dn': 'NRSPID-3',
        '$resourceGroup7_dn': 'NRSPID-4',
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3'
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1'
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '490',
        '$mncValue3': '491',
    },
    'mcc': {
        '$mncValue1': '311',
        '$mncValue2': '312',
        '$mncValue3': '313',
    },
    'spid': {
        '$spidGrp1': '5',
        '$spidLastGrp1': '10',
        '$spidGrp2': '100',
        '$spidLastGrp2': '150',
        '$spidGrp3': '1',
        '$spidLastGrp3': '90',
        '$spidGrp4': '60',
        '$spidLastGrp4': '90'
    },
    'spid_slicing_activated': True,
    'default_resource_group_ids': [1, 2, 4],
    'resource_group_ids': [i for i in range(1, 8)],
    'plmns':
        {
            1: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            2: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            3: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            4: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            5: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            6: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            }
        },
    'cell_params': {
        '$nrCellId': {
            'FDD': '3',
            'TDD': '1'
        },
        '$cellDepType': 'SA+NSA'
    }
}

DELTA_DYN_KEYS_A_B301_003_1_VALIDATION = {
    'bip_quotas': {
        1: {
            'min': '5',
            'max': '70'
        },
        2: {
            'min': '5',
            'max': '100'
        },
        3: {
            'min': '15',
            'max': '65'
        },
        4: {
            'min': '10',
            'max': '50'
        },
        5: {
            'min': '1',
            'max': '100'
        },
        6: {
            'min': '25',
            'max': '100'
        },
        7: {
            'min': '10',
            'max': '60'
        },
    },

    'quotas': {
        '$minQuotaGrp1': '5',
        '$maxQuotaGrp1': '70',
        '$minQuotaGrp2': '5',
        '$maxQuotaGrp2': '100',
        '$minQuotaGrp3': '15',
        '$maxQuotaGrp3': '65',
        '$minQuotaGrp4': '10',
        '$maxQuotaGrp4': '50',
        '$minQuotaGrp5': '1',
        '$maxQuotaGrp5': '100',
        '$minQuotaGrp6': '25',
        '$maxQuotaGrp6': '100',
        '$minQuotaGrp7': '10',
        '$maxQuotaGrp7': '60',
    },
    'dn_list': {
        '$resourceGroup1_dn': 'SNSSAI-1',
        '$resourceGroup2_dn': 'SNSSAI-2',
        '$resourceGroup3_dn': 'SNSSAI-3',
        '$resourceGroup4_dn': 'SNSSAI-4',
        '$resourceGroup5_dn': 'NRSPID-1',
        '$resourceGroup6_dn': 'NRSPID-2',
        '$resourceGroup7_dn': 'NRSPID-3',
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3',
        '$sdValue4': '4'
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1',
        '$sstValue4': '1',
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '490',
        '$mncValue3': '491',
        '$mncValue4': '491',
    },
    'mcc': {
        '$mncValue1': '311',
        '$mncValue2': '312',
        '$mncValue3': '313',
        '$mncValue4': '313',
    },
    'spid': {
        '$spidGrp1': '1',
        '$spidLastGrp1': '103',
        '$spidGrp2': '63',
        '$spidGrp3': '12',
        '$spidLastGrp3': '68',
        '$spidGrp4': '60',
        '$spidLastGrp4': '90'
    },
    'spid_slicing_activated': True,
    'default_resource_group_ids': [1, 2, 3],
    'resource_group_ids': [i for i in range(1, 4)],
    'plmns':
        {
            1: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            2: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            3: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            4: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            5: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            6: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            }
        },
    'cell_params': {
        '$nrCellId': {
            'FDD': '3',
            'TDD': '1'
        },
        '$cellDepType': 'SA+NSA'
    }
}

DELTA_DYN_KEYS_A_B301_003_2_VALIDATION = {
    'bip_quotas': {
        1: {
            'min': '20',
            'max': '95'
        },
        2: {
            'min': '1',
            'max': '50'
        },
        3: {
            'min': '1',
            'max': '65'
        },
        4: {
            'min': '10',
            'max': '85'
        },
        5: {
            'min': '20',
            'max': '50'
        },
        6: {
            'min': '15',
            'max': '80'
        },
        7: {
            'min': '10',
            'max': '100'
        },
    },

    'quotas': {
        '$minQuotaGrp1': '20',
        '$maxQuotaGrp1': '95',
        '$minQuotaGrp2': '1',
        '$maxQuotaGrp2': '50',
        '$minQuotaGrp3': '1',
        '$maxQuotaGrp3': '65',
        '$minQuotaGrp4': '10',
        '$maxQuotaGrp4': '85',
        '$minQuotaGrp5': '20',
        '$maxQuotaGrp5': '50',
        '$minQuotaGrp6': '15',
        '$maxQuotaGrp6': '80',
        '$minQuotaGrp7': '10',
        '$maxQuotaGrp7': '100'
    },
    'dn_list': {
        '$resourceGroup1_dn': 'SNSSAI-1',
        '$resourceGroup2_dn': 'SNSSAI-2',
        '$resourceGroup3_dn': 'SNSSAI-3',
        '$resourceGroup4_dn': 'SNSSAI-4',
        '$resourceGroup5_dn': 'NRSPID-1',
        '$resourceGroup6_dn': 'NRSPID-2',
        '$resourceGroup7_dn': 'NRSPID-3',
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3',
        '$sdValue4': '4'
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1',
        '$sstValue4': '1',
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '490',
        '$mncValue3': '491',
        '$mncValue4': '491',
    },
    'mcc': {
        '$mncValue1': '311',
        '$mncValue2': '312',
        '$mncValue3': '313',
        '$mncValue4': '313',
    },
    'spid': {
        '$spidGrp1': '1',
        '$spidLastGrp1': '103',
        '$spidGrp2': '63',
        '$spidGrp3': '12',
        '$spidLastGrp3': '68',
        '$spidGrp4': '60',
        '$spidLastGrp4': '90'
    },
    'spid_slicing_activated': True,
    'default_resource_group_ids': [1, 2, 3],
    'resource_group_ids': [i for i in range(1, 4)],
    'plmns':
        {
            1: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            2: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            3: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            4: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            5: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            6: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            }
        },
    'cell_params': {
        '$nrCellId': {
            'FDD': '3',
            'TDD': '1'
        },
        '$cellDepType': 'SA+NSA'
    }
}

DELTA_DYN_KEYS_A_B401_001_VALIDATION = {
    'bip_quotas': {
        1: {
            'min': '10',
            'max': '50'
        },
        2: {
            'min': '20',
            'max': '75'
        },
        3: {
            'min': '15',
            'max': '90'
        },
        4: {
            'min': '25',
            'max': '100'
        },
        5: {
            'min': '25',
            'max': '70'
        },
    },

    'quotas': {
        '$minQuotaGrp1': '10',
        '$maxQuotaGrp1': '50',
        '$minQuotaGrp2': '20',
        '$maxQuotaGrp2': '75',
        '$minQuotaGrp3': '15',
        '$maxQuotaGrp3': '90',
        '$minQuotaGrp4': '25',
        '$maxQuotaGrp4': '100',
        '$minQuotaGrp5': '25',
        '$maxQuotaGrp5': '70',
    },
    'dn_list': {
        '$resourceGroup1_dn': 'NRSPID-1',
        '$resourceGroup2_dn': 'NRSPID-2',
        '$resourceGroup3_dn': 'NRSPID-3',
        '$resourceGroup4_dn': 'NRSPID-4',
        '$resourceGroup5_dn': 'NRSPID-5',
    },
    'spid': {
        '$spidGrp1': '1',
        '$spidGrp2': '3',
        '$spidLastGrp2': '10',
        '$spidGrp3': '3',
        '$spidLastGrp3': '10',
        '$spidGrp4': '8',
        '$spidGrp5': '56',
        '$spidLastGrp5': '127'
    },
    'spid_slicing_activated': True,
    'default_resource_group_ids': [2, 3, 4],
    'resource_group_ids': [i for i in range(1, 6)],
    'plmns':
        {
            1: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            2: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            3: {
                'mcc': '312',
                'mnc': '490',
                'mnc_length': '3'
            },
            4: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
            5: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
        },
    'cell_params': {
        '$nrCellId': {
            'FDD': '3',
            'TDD': '1'
        },
        '$cellDepType': 'SA+NSA'
    }
}

DELTA_DYN_KEYS_A_B107_001_VALIDATION = {
    'bip_quotas': {
        1: {
            'min': '40',
            'max': '90'
        },
        2: {
            'min': '1',
            'max': '100'
        },
        3: {
            'min': '30',
            'max': '70'
        },
        4: {
            'min': '10',
            'max': '50'
        }
    },
    'quotas': {
        '$minQuotaGrp1': '40',
        '$maxQuotaGrp1': '90',
        '$minQuotaGrp2': '1',
        '$maxQuotaGrp2': '100',
        '$minQuotaGrp3': '30',
        '$maxQuotaGrp3': '70',
        '$minQuotaGrp4': '10',
        '$maxQuotaGrp4': '50',
    },
    'dn_list': {
        '$resourceGroup1_dn': 'NRSPID-1',
        '$resourceGroup2_dn': 'NRSPID-2',
        '$resourceGroup3_dn': 'NRSPID-3',
        '$resourceGroup4_dn': 'NRSPID-4',
    },
    'spid': {
        '$spidGrp1': '1',
        '$spidLastGrp1': '50',
        '$spidGrp2': '51',
        '$spidLastGrp2': '100',
        '$spidGrp3': '1',
        '$spidGrp4': '5',
        '$spidLastGrp3': '256'
    },
    'spid_slicing_activated': True,
    'default_resource_group_ids': [1, 3, 4],
    'resource_group_ids': [i for i in range(1, 5)],
    'plmns':
        {
            1: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            2: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            3: {
                'mcc': '312',
                'mnc': '490',
                'mnc_length': '3'
            },
            4: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
            5: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
        },
    'cell_params': {
        '$nrCellId': {
            'FDD': '3',
            'TDD': '1'
        },
        '$cellDepType': 'SA+NSA'
    }
}

DELTA_DYN_KEYS_A_B105_32_SPIDGRP_8_PMQAP_VALIDATION = {
    'bip_quotas': {
        1: {
            'max': '50',
            'min': '1'
        },
        2: {
            'max': '20',
            'min': '2'
        },
        3: {
            'max': '100',
            'min': '2'
        },
        4: {
            'max': '100',
            'min': '3'
        },
        5: {
            'max': '70',
            'min': '4'
        },
        6: {
            'max': '70',
            'min': '1'
        },
        7: {
            'max': '100',
            'min': '1'
        },
        8: {
            'max': '50',
            'min': '5'
        },
        9: {
            'max': '35',
            'min': '3'
        },
        10: {
            'max': '85',
            'min': '7'
        },
        11: {
            'max': '55',
            'min': '1'
        },
        12: {
            'max': '95',
            'min': '2'
        },
        13: {
            'max': '70',
            'min': '1'
        },
        14: {
            'max': '10',
            'min': '5'
        },
        15: {
            'max': '55',
            'min': '3'
        },
        16: {
            'max': '25',
            'min': '3'
        },
        17: {
            'max': '70',
            'min': '2'
        },
        18: {
            'max': '40',
            'min': '2'
        },
        19: {
            'max': '30',
            'min': '5'
        },
        20: {
            'max': '65',
            'min': '2'
        },
        21: {
            'max': '55',
            'min': '5'
        },
        22: {
            'max': '60',
            'min': '5'
        },
        23: {
            'max': '60',
            'min': '1'
        },
        24: {
            'max': '45',
            'min': '1'
        },
        25: {
            'max': '40',
            'min': '1'
        },
        26: {
            'max': '45',
            'min': '5'
        },
        27: {
            'max': '55',
            'min': '2'
        },
        28: {
            'max': '50',
            'min': '6'
        },
        29: {
            'max': '50',
            'min': '1'
        },
        30: {
            'max': '45',
            'min': '4'
        },
        31: {
            'max': '50',
            'min': '2'
        },
        32: {
            'max': '70',
            'min': '1'
        }
    },
    'quotas': {
        '$maxQuotaGrp1': '50',
        '$minQuotaGrp1': '1',

        '$maxQuotaGrp2': '20',
        '$minQuotaGrp2': '2',

        '$maxQuotaGrp3': '100',
        '$minQuotaGrp3': '2',

        '$maxQuotaGrp4': '100',
        '$minQuotaGrp4': '3',

        '$maxQuotaGrp5': '70',
        '$minQuotaGrp5': '4',

        '$maxQuotaGrp6': '70',
        '$minQuotaGrp6': '1',

        '$maxQuotaGrp7': '100',
        '$minQuotaGrp7': '1',

        '$maxQuotaGrp8': '50',
        '$minQuotaGrp8': '5',

        '$maxQuotaGrp9': '35',
        '$minQuotaGrp9': '3',

        '$maxQuotaGrp10': '85',
        '$minQuotaGrp10': '7',

        '$maxQuotaGrp11': '55',
        '$minQuotaGrp11': '1',

        '$maxQuotaGrp12': '95',
        '$minQuotaGrp12': '2',

        '$maxQuotaGrp13': '70',
        '$minQuotaGrp13': '1',

        '$maxQuotaGrp14': '10',
        '$minQuotaGrp14': '5',

        '$maxQuotaGrp15': '55',
        '$minQuotaGrp15': '3',

        '$maxQuotaGrp16': '25',
        '$minQuotaGrp16': '3',

        '$maxQuotaGrp17': '70',
        '$minQuotaGrp17': '2',

        '$maxQuotaGrp18': '40',
        '$minQuotaGrp18': '2',

        '$maxQuotaGrp19': '30',
        '$minQuotaGrp19': '5',

        '$maxQuotaGrp20': '65',
        '$minQuotaGrp20': '2',

        '$maxQuotaGrp21': '55',
        '$minQuotaGrp21': '5',

        '$maxQuotaGrp22': '60',
        '$minQuotaGrp22': '5',

        '$maxQuotaGrp23': '60',
        '$minQuotaGrp23': '1',

        '$maxQuotaGrp24': '45',
        '$minQuotaGrp24': '1',

        '$maxQuotaGrp25': '40',
        '$minQuotaGrp25': '1',

        '$maxQuotaGrp26': '45',
        '$minQuotaGrp26': '5',

        '$maxQuotaGrp27': '55',
        '$minQuotaGrp27': '2',

        '$maxQuotaGrp28': '50',
        '$minQuotaGrp28': '6',

        '$maxQuotaGrp29': '50',
        '$minQuotaGrp29': '1',

        '$maxQuotaGrp30': '45',
        '$minQuotaGrp30': '4',

        '$maxQuotaGrp31': '50',
        '$minQuotaGrp31': '2',
        '$maxQuotaGrp32': '70',
        '$minQuotaGrp32': '1',
    },
    'dn_list': {
        '$resourceGroup1_dn': 'NRSPID-1',
        '$resourceGroup2_dn': 'NRSPID-2',
        '$resourceGroup3_dn': 'NRSPID-3',
        '$resourceGroup4_dn': 'NRSPID-4',
        '$resourceGroup5_dn': 'NRSPID-5',
        '$resourceGroup6_dn': 'NRSPID-6',
        '$resourceGroup7_dn': 'NRSPID-7',
        '$resourceGroup8_dn': 'NRSPID-8',
        '$resourceGroup9_dn': 'NRSPID-9',
        '$resourceGroup10_dn': 'NRSPID-10',
        '$resourceGroup11_dn': 'NRSPID-11',
        '$resourceGroup12_dn': 'NRSPID-12',
        '$resourceGroup13_dn': 'NRSPID-13',
        '$resourceGroup14_dn': 'NRSPID-14',
        '$resourceGroup15_dn': 'NRSPID-15',
        '$resourceGroup16_dn': 'NRSPID-16',
        '$resourceGroup17_dn': 'NRSPID-17',
        '$resourceGroup18_dn': 'NRSPID-18',
        '$resourceGroup19_dn': 'NRSPID-19',
        '$resourceGroup20_dn': 'NRSPID-20',
        '$resourceGroup21_dn': 'NRSPID-21',
        '$resourceGroup22_dn': 'NRSPID-22',
        '$resourceGroup23_dn': 'NRSPID-23',
        '$resourceGroup24_dn': 'NRSPID-24',
        '$resourceGroup25_dn': 'NRSPID-25',
        '$resourceGroup26_dn': 'NRSPID-26',
        '$resourceGroup27_dn': 'NRSPID-27',
        '$resourceGroup28_dn': 'NRSPID-28',
        '$resourceGroup29_dn': 'NRSPID-29',
        '$resourceGroup30_dn': 'NRSPID-30',
        '$resourceGroup31_dn': 'NRSPID-31',
        '$resourceGroup32_dn': 'NRSPID-32',
    },
    'spid_slicing_activated': True,
    'default_resource_group_ids': [2, 8, 14, 23, 26, 31],
    'resource_group_ids': [i for i in range(1, 33)],
    'plmns':
        {
            1: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            2: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            3: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            4: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            5: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            6: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            7: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            8: {
                'mcc': '312',
                'mnc': '490',
                'mnc_length': '3'
            },
            9: {
                'mcc': '312',
                'mnc': '490',
                'mnc_length': '3'
            },
            10: {
                'mcc': '312',
                'mnc': '490',
                'mnc_length': '3'
            },
            11: {
                'mcc': '312',
                'mnc': '490',
                'mnc_length': '3'
            },
            12: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
            13: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
            14: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
            15: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
            16: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
            17: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
            18: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
            19: {
                'mcc': '313',
                'mnc': '491',
                'mnc_length': '3'
            },
            20: {
                'mcc': '314',
                'mnc': '492',
                'mnc_length': '3'
            },
            21: {
                'mcc': '314',
                'mnc': '492',
                'mnc_length': '3'
            },
            22: {
                'mcc': '314',
                'mnc': '492',
                'mnc_length': '3'
            },
            23: {
                'mcc': '314',
                'mnc': '492',
                'mnc_length': '3'
            },
            24: {
                'mcc': '315',
                'mnc': '493',
                'mnc_length': '3'
            },
            25: {
                'mcc': '315',
                'mnc': '493',
                'mnc_length': '3'
            },
            26: {
                'mcc': '315',
                'mnc': '493',
                'mnc_length': '3'
            },
            27: {
                'mcc': '315',
                'mnc': '493',
                'mnc_length': '3'
            },
            28: {
                'mcc': '316',
                'mnc': '494',
                'mnc_length': '3'
            },
            29: {
                'mcc': '316',
                'mnc': '494',
                'mnc_length': '3'
            },
            30: {
                'mcc': '316',
                'mnc': '494',
                'mnc_length': '3'
            },
            31: {
                'mcc': '316',
                'mnc': '494',
                'mnc_length': '3'
            },
            32: {
                'mcc': '316',
                'mnc': '494',
                'mnc_length': '3'
            }
        },
    'cell_params': {
        '$nrCellId': {
            'FDD': '3',
            'TDD': '1'
        },
        '$cellDepType': 'SA+NSA'
    }
}

PRB_DSS_VALIDATION = {
    'bip_quotas': {
        1: {
            'min': '30',
            'max': '80'
        },
    },
    'quotas': {
        '$minQuotaGrp1': '30',
        '$maxQuotaGrp1': '80',
    },
    'dn_list': {
        '$resourceGroup1_dn': 'NRSPID-1',
    },
    'spid': {
        '$spidGrp1': '7',
        '$spidGrp2': '10',
        '$spidGrp3': '11',
    },
    'spid_slicing_activated': True,
    'default_resource_group_ids': [1],
    'resource_group_ids': [i for i in range(1, 4)],
    'plmns':
        {
            1: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            2: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
            3: {
                'mcc': '311',
                'mnc': '489',
                'mnc_length': '3'
            },
        },
    'cell_params': {
        '$nrCellId': {
            'FDD': '3',
            'TDD': '1'
        },
        '$cellDepType': 'SA+NSA'
    }
}

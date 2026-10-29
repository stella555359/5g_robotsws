configurations = {
    'AHLOA': {
        '5': {
              'chBwDl': '5MHz',
              'chBwUl': '5MHz',
              'actPdschAtSsbSlots': False,
              'actPdschRmCsirsForTracking': False,
              'type0CoresetConfigurationIndex': 2,
              'type0SearchSpaceConfigurationIndex': 4,
              'reqMinNumPuschPrb': 15,
              'bwpDN': (9, 30),
              'gscnOrSsPbchArfcn': 1587,
        },
        '10': {
            'chBwDl': '10MHz',
            'chBwUl': '10MHz',
            'actPdschAtSsbSlots': True,
            'actPdschRmCsirsForTracking': True,
            'type0CoresetConfigurationIndex': 7,
            'type0SearchSpaceConfigurationIndex': 4,
            'reqMinNumPuschPrb': 19,
            'bwpDN': (4, 31),
            'gscnOrSsPbchArfcn': 1587,
        },
        '15': {
            'chBwDl': '15MHz',
            'chBwUl': '15MHz',
            'actPdschAtSsbSlots': True,
            'actPdschRmCsirsForTracking': True,
            'type0CoresetConfigurationIndex': 7,
            'type0SearchSpaceConfigurationIndex': 4,
            'reqMinNumPuschPrb': 19,
            'bwpDN': (4, 32),
            'gscnOrSsPbchArfcn': 1587,

        },
        '20': {
            'chBwDl': '20MHz',
            'chBwUl': '20MHz',
            'actPdschAtSsbSlots': True,
            'actPdschRmCsirsForTracking': True,
            'type0CoresetConfigurationIndex': 6,
            'type0SearchSpaceConfigurationIndex': 15,
            'reqMinNumPuschPrb': 19,
            'bwpDN': (4, 33),
            'gscnOrSsPbchArfcn': 1587
        }
    },
    'AHFIB': {
        '5': {
              'chBwDl': '5MHz',
              'chBwUl': '5MHz',
              'actPdschAtSsbSlots': False,
              'actPdschRmCsirsForTracking': False,
              'type0CoresetConfigurationIndex': 0,
              'type0SearchSpaceConfigurationIndex': 4,
              'reqMinNumPuschPrb': 15,
              'bwpDN': (9, 30),
              'gscnOrSsPbchArfcn': 5361
        },
        '10': {
              'chBwDl': '10MHz',
              'chBwUl': '10MHz',
              'actPdschAtSsbSlots': True,
              'actPdschRmCsirsForTracking': True,
              'type0CoresetConfigurationIndex': 0,
              'type0SearchSpaceConfigurationIndex': 4,
              'reqMinNumPuschPrb': 19,
              'bwpDN': (4, 31),
              'gscnOrSsPbchArfcn': 5361
        },
        '15': {
            'chBwDl': '15MHz',
            'chBwUl': '15MHz',
            'actPdschAtSsbSlots': True,
            'actPdschRmCsirsForTracking': True,
            'type0CoresetConfigurationIndex': 6,
            'type0SearchSpaceConfigurationIndex': 4,
            'reqMinNumPuschPrb': 19,
            'bwpDN': (4, 32),
            'gscnOrSsPbchArfcn': 5361
        },
        '20': {
            'chBwDl': '20MHz',
            'chBwUl': '20MHz',
            'actPdschAtSsbSlots': True,
            'actPdschRmCsirsForTracking': True,
            'type0CoresetConfigurationIndex': 6,
            'type0SearchSpaceConfigurationIndex': 15,
            'reqMinNumPuschPrb': 19,
            'bwpDN': (4, 33),
            'gscnOrSsPbchArfcn': 5361
        },

    },
    'AEHC': {
        '40': {
            'chBw': '40MHz',
            'bwpDN': (7, 71),
            'gscnOrSsPbchArfcn': 6354
        },
        '50': {
            'chBw': '50MHz',
            'bwpDN': (7, 72),
            'gscnOrSsPbchArfcn': 6354
        },
        '60': {
            'chBw': '60MHz',
            'bwpDN': (7, 73),
            'gscnOrSsPbchArfcn': 6354
        },
        '80': {
            'chBw': '80MHz',
            'bwpDN': (7, 75),
            'gscnOrSsPbchArfcn': 6354
        },
        '100': {
            'chBw': '100MHz',
            'bwpDN': (7, 77),
            'gscnOrSsPbchArfcn': 6354
        }


    }
}

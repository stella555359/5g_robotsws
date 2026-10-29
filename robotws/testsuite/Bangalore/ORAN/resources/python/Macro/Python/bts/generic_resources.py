class GenericResources(object):
    pass


class EnbResources(GenericResources):
    pass


class GnbResources(GenericResources):
    nr_frequency_bands = {
        "257": {"nrarfcn": {
                            "60 KHz": [2055222, 2078772, 2102915],
                            "120 KHz": [2055047, 2078773, 2102899]
                            },
                "gscn": [22390, 22472, 22556]
                },
        "258": {"nrarfcn": {
                            "60 KHz": [2018127, 2043794, 2068908],
                            "120 KHz": [2018219, 2043793, 2068999]
                            },
                "gscn": [22262, 22350, 22438]
                },
        "260": {"nrarfcn": {
                            "60 KHz": [2230259, 2253782, 2278068],
                            "120 KHz": [2230091, 2253783, 2278237]
                            },
                "gscn": [22998, 23080, 23164]
                },
        "261": {"nrarfcn": {
                            "60 KHz": [2071720, 2077158, 2278068],
                            "120 KHz": [2071745, 2076965, 2084159]
                            },
                "gscn": [22448, 22466, 22490]
                }
    }

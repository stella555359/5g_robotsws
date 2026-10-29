"""
:copyright: Nokia Networks
:author: Bartlomiej Bienko, Wioleta Swies
:contact: bartlomiej.bienko@nokia.com, wioleta.swies@nokia.com
:maintainer: Bartlomiej Bienko, Wioleta Swies
:contact: bartlomiej.bienko@nokia.com, wioleta.swies@nokia.com

Moudle provides site specyfic variables; intentionally used for TLs:
    - 7-7-UTE5GCLOUDT4SK033.p04.ska-lab.nsn-rdnet.net (eNB)
    - 7-7-UTE5GCLOUDT4SK038.p04.ska-lab.nsn-rdnet.net (main gNB)
    - 7-7-UTE5GCLOUDT4SK048.p04.ska-lab.nsn-rdnet.net (secondary gNB)

Every value should has short description of purpose.
"""


attenuator_gNB_port_no = 2
attenuator_eNB_port_no = 1
attenuator_tl_ports = [attenuator_gNB_port_no, attenuator_eNB_port_no]

# used for adjust frequencies of 4SK038/NRHOIFs to make UE be able to handover to nrcells of 4SK048
proper_frequencies = [
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-1",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "2071387", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-2",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "2073115", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-3",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "2074843", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-4",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "126850", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-5",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "126010", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-6",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "126950", "operation": "update"}
        ],
    },
]

# used for adjust frequencies of 4SK038/NRHOIFs to make UE be unable to handover to nrcells of 4SK048
improper_frequencies = [
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-1",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "2071418", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-2",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "2073146", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-3",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "2074874", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-4",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "126881", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-5",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "126041", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-6",
        "operation": "update",
        "parameters": [
            {"parameterName": "ssbFrequency", "value": "126981", "operation": "update"}
        ],
    },
]

# event A4 enabled on FR2 NRHOIFs, events A3 and A5 are disabled
default_nrhoif_event_configuration = [
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-1",
        "operation": "update",
        "parameters": [
            {"parameterName": "a3MeasEnabled", "value": "none", "operation": "update"},
            {"parameterName": "a4MeasHigherPrioFreqEnabled", "value": "rsrp", "operation": "update"},
            {"parameterName": "a5MeasEnabled", "value": "none", "operation": "update"},
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-2",
        "operation": "update",
        "parameters": [
            {"parameterName": "a3MeasEnabled", "value": "none", "operation": "update"},
            {"parameterName": "a4MeasHigherPrioFreqEnabled", "value": "rsrp", "operation": "update"},
            {"parameterName": "a5MeasEnabled", "value": "none", "operation": "update"},
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-3",
        "operation": "update",
        "parameters": [
            {"parameterName": "a3MeasEnabled", "value": "none", "operation": "update"},
            {"parameterName": "a4MeasHigherPrioFreqEnabled", "value": "rsrp", "operation": "update"},
            {"parameterName": "a5MeasEnabled", "value": "none", "operation": "update"},
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-4",
        "operation": "update",
        "parameters": [
            {"parameterName": "a3MeasEnabled", "value": "none", "operation": "update"},
            {"parameterName": "a4MeasHigherPrioFreqEnabled", "value": "none", "operation": "update"},
            {"parameterName": "a5MeasEnabled", "value": "none", "operation": "update"},
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-5",
        "operation": "update",
        "parameters": [
            {"parameterName": "a3MeasEnabled", "value": "none", "operation": "update"},
            {"parameterName": "a4MeasHigherPrioFreqEnabled", "value": "none", "operation": "update"},
            {"parameterName": "a5MeasEnabled", "value": "none", "operation": "update"},
        ],
    },
    {
        "distName": "MRBTS-77038/NRBTS-77038/NRCELL-1/NRHOIF-6",
        "operation": "update",
        "parameters": [
            {"parameterName": "a3MeasEnabled", "value": "none", "operation": "update"},
            {"parameterName": "a4MeasHigherPrioFreqEnabled", "value": "none", "operation": "update"},
            {"parameterName": "a5MeasEnabled", "value": "none", "operation": "update"},
        ],
    },
]

nrhoif_event_configuration_B7 = {
    'FR1': [],
    'FR2': ['A3', 'A4', 'A5']
}

nrhoif_event_configuration_B11 = {
    'FR1': ['A4'],
    'FR2': ['A3', 'A5']
}

nrhoif_event_configuration_B12 = {
    'FR1': ['A3', 'A5'],
    'FR2': ['A4']
}

nrhoif_event_configuration_B13 = {
    'FR1': [],
    'FR2': ['A3', 'A4', 'A5']
}

nrhoif_event_configuration_default = {
    'FR1': [],
    'FR2': ['A4']
}

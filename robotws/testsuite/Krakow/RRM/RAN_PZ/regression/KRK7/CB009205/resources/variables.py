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

main_gnb_instance_index = 0
main_gnb_instance_index_for_B03_Intra_test = 1

main_nrbts_id = "77038"
main_nrbts_id_for_B03_Intra_test = "77048"

main_nrcell_id = "1"
main_nrcell_id_for_B03_Intra_test = "422"

attenuator_gNB_port_no = 2
attenuator_eNB_port_no = 1
attenuator_tl_ports = [attenuator_gNB_port_no, attenuator_eNB_port_no]

DEFAULT_ADDITION_GNB_INSTANCE_INIT_INDEX = 0  # refers to main gNB 4SK038
DEFAULT_ADDITION_NRCELL_ID = "1"  # refers to NRCELL-1 on main gNB 4SK038
B03_INTRA_DEFAULT_ADDITION_NRCELL_ID = "422"  # refers to NRCELL-422 on gNB 4SK048

nrhoif_default_event_configuration = {
    'FR1': [],
    'FR2': ['A4']
}

nrhoif_all_events_all_nrhoifs_mapping = {
    'FR1': ['A3', 'A4', 'A5'],
    'FR2': ['A3', 'A4', 'A5']
}

nrhoif_event_configuration_B03_Inter = {
    'FR1': ['A3', 'A4', 'A5'],
    'FR2': ['A3', 'A4', 'A5']
}

nrhoif_event_configuration_EC01 = {
    'FR1': ['A3', 'A5'],
    'FR2': ['A3', 'A4', 'A5']
}

max_react_default_value = 2

actA1HoPrefNrLayer_default_enabled_parameter_configuration = [
    {
        "parameterName": "a1MeashoPrefNRLayerSsbRsrp",
        "operation": "update",
        "value": [
            {
                "a1HysteresisSsbRsrp": 0,
                "a1ThresholdhoSsbRsrp": 71,
                "a1TimeToTriggerhoSsbRsrp": "ms64"
            },
        ]
    },
    {
        "parameterName": "a1MeashoSsbRsrp",
        "operation": "update",
        "value": [
            {
                "a1HysteresishoSsbRsrp": 0,
                "a1ThresholdhoSsbRsrp": 71,
                "a1TimeToTriggerhoSsbRsrp": "ms480"
            },
        ]
    },
    {
        "parameterName": "a2MeashoSsbRsrp",
        "operation": "update",
        "value": [
            {
                "a2HysteresishoSsbRsrp": 0,
                "a2ThresholdhoSsbRsrp": 34,
                "a2TimeToTriggerhoSsbRsrp": "ms480"
            },
        ]
    },
]

actA1HoPrefNrLayer_default_disabled_parameter_configuration = [
    {
        "parameterName": "a1MeashoPrefNRLayerSsbRsrp",
        "operation": "delete",
        "value": []
    },
    {
        "parameterName": "a2MeashoSsbRsrp",
        "operation": "update",
        "value": [
            {
                "a2HysteresishoSsbRsrp": 0,
                "a2ThresholdhoSsbRsrp": 70,
                "a2TimeToTriggerhoSsbRsrp": "ms480"
            },
        ]
    },
]

actA1HoPrefNrLayer_configuration_enabled = {
    True: actA1HoPrefNrLayer_default_enabled_parameter_configuration,
    False: actA1HoPrefNrLayer_default_disabled_parameter_configuration,
}

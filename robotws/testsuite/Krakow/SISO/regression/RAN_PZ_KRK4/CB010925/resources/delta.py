from robot.libraries.BuiltIn import BuiltIn

bts0_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')
bts1_id = BuiltIn().get_variable_value('${tl.gnbs[1].dus[0].global_bts_id}')
bts2_id = BuiltIn().get_variable_value('${tl.gnbs[2].dus[0].global_bts_id}')

site_reset_delta_bts0 = [
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-11".format(bts0_id), "operation": "update",
     "parameters": [
         {"parameterName": "qRxLevMin", "value": "-22", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-12".format(bts0_id), "operation": "update",
     "parameters": [
         {"parameterName": "qRxLevMin", "value": "-44", "operation": "update"},
     ]},
]

radio_module_power_reset_delta_bts0 = [
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-11".format(bts0_id), "operation": "update",
     "parameters": [
         {"parameterName": "qRxLevMin", "value": "-44", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-12".format(bts0_id), "operation": "update",
     "parameters": [
         {"parameterName": "qRxLevMin", "value": "-22", "operation": "update"},
     ]},
]

site_reset_delta_bts1 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-11/SIB-0".format(bts1_id), "operation": "update",
     "parameters": [
         {"parameterName": "qrxlevmin", "value": "-44", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-22/SIB-0".format(bts1_id), "operation": "update",
     "parameters": [
         {"parameterName": "qrxlevmin", "value": "-90", "operation": "update"},
     ]},
]

radio_module_power_reset_delta_bts1 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-11/SIB-0".format(bts1_id), "operation": "update",
     "parameters": [
         {"parameterName": "qrxlevmin", "value": "-90", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-22/SIB-0".format(bts1_id), "operation": "update",
     "parameters": [
         {"parameterName": "qrxlevmin", "value": "-44", "operation": "update"},
     ]},
]

site_reset_delta_bts2 = [
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-17".format(bts2_id), "operation": "update",
     "parameters": [
         {"parameterName": "qRxLevMin", "value": "-44", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-18".format(bts2_id), "operation": "update",
     "parameters": [
         {"parameterName": "qRxLevMin", "value": "-22", "operation": "update"},
     ]},
]

radio_module_power_reset_delta_bts2 = [
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-17".format(bts2_id), "operation": "update",
     "parameters": [
         {"parameterName": "qRxLevMin", "value": "-44", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-18".format(bts2_id), "operation": "update",
     "parameters": [
         {"parameterName": "qRxLevMin", "value": "-22", "operation": "update"},
     ]},
]

radio_module_power_reset_delta = [
    radio_module_power_reset_delta_bts0,
    radio_module_power_reset_delta_bts1,
    radio_module_power_reset_delta_bts2,
]

site_reset_delta = [
    site_reset_delta_bts0,
    site_reset_delta_bts1,
    site_reset_delta_bts2,
]

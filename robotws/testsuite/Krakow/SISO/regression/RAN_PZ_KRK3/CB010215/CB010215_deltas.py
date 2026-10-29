from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')

activate_uDTX_with_TC_delta_Rel4 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-0".format(bts_id, bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actMicroDtx", "value": "true", "operation": "update"},
         {"parameterName": "allowTrafficConcentration", "value": "true", "operation": "update"},
     ]}
]

activate_uDTX_with_TC_delta_Rel5 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-1".format(bts_id, bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actMicroDtx", "value": "true", "operation": "update"},
         {"parameterName": "allowTrafficConcentration", "value": "true", "operation": "update"},
     ]}
]
activate_uDTX_without_TC_delta_Rel5 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-1".format(bts_id, bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actMicroDtx", "value": "true", "operation": "update"},
         {"parameterName": "allowTrafficConcentration", "value": "false", "operation": "update"},
     ]}
]

activate_uDTX_with_TC_delta_Rel6 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-2".format(bts_id, bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actMicroDtx", "value": "true", "operation": "update"},
         {"parameterName": "allowTrafficConcentration", "value": "true", "operation": "update"},
     ]}
]

deactivate_uDTX_Rel4 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-0".format(bts_id, bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actMicroDtx", "value": "false", "operation": "update"},
     ]}
]
deactivate_uDTX_Rel5 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-1".format(bts_id, bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actMicroDtx", "value": "false", "operation": "update"},
     ]}
]
deactivate_uDTX_Rel6 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-2".format(bts_id, bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actMicroDtx", "value": "false", "operation": "update"},
     ]}
]

activate_TC_Rel5 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-1".format(bts_id, bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "allowTrafficConcentration", "value": "true", "operation": "update"},
     ]}
]

enable_CRG_Rel5 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-1".format(bts_id, bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "cellResourceSharingMode", "value": "selectiveTtiDonate", "operation": "update"},
     ]}
]

disable_CRG_Rel5 = [
    {"distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-1".format(bts_id, bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "cellResourceSharingMode", "value": "none", "operation": "update"},
     ]}
]

actMicroDtx_false_Rel4 = {'PLMN-PLMN/MRBTS-{}/LNBTS-{}/LNCEL-0'.format(bts_id, bts_id): {'actMicroDtx': 'false'}}

actMicroDtx_false_Rel5 = {'PLMN-PLMN/MRBTS-{}/LNBTS-{}/LNCEL-1'.format(bts_id, bts_id): {'actMicroDtx': 'false'}}

actMicroDtx_false_Rel6 = {'PLMN-PLMN/MRBTS-{}/LNBTS-{}/LNCEL-2'.format(bts_id, bts_id): {'actMicroDtx': 'false'}}

allowTrafficConcentration_false_Rel4 = {
    'PLMN-PLMN/MRBTS-{}/LNBTS-{}/LNCEL-0'.format(bts_id, bts_id): {'allowTrafficConcentration': 'false'}}

allowTrafficConcentration_false_Rel5 = {
    'PLMN-PLMN/MRBTS-{}/LNBTS-{}/LNCEL-1'.format(bts_id, bts_id): {'allowTrafficConcentration': 'false'}}

allowTrafficConcentration_false_Rel6 = {
    'PLMN-PLMN/MRBTS-{}/LNBTS-{}/LNCEL-2'.format(bts_id, bts_id): {'allowTrafficConcentration': 'false'}}

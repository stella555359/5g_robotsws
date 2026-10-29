from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')


def prepare_actIndSw_delta(value, bts_id=0):
    global_bts_id = tl.gnbs[bts_id].dus[0].global_bts_id
    return [
        {
            "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-1".format(global_bts_id),
            "operation": "update",
            "parameters": [
                {
                    "value": value,
                    "operation": "update",
                    "parameterName": "actIndSwUpgradeForSharedASIR"

                }
            ]
        },
        {
            "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-2".format(global_bts_id),
            "operation": "update",
            "parameters": [
                {
                    "value": value,
                    "operation": "update",
                    "parameterName": "actIndSwUpgradeForSharedASIR"

                }
            ]
        },
        {
            "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-3".format(global_bts_id),
            "operation": "update",
            "parameters": [
                {
                    "value": value,
                    "operation": "update",
                    "parameterName": "actIndSwUpgradeForSharedASIR"

                }
            ]
        },
    ]

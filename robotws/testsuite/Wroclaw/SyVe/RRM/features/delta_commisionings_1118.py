_sa_to_nsa_parameters = '''"parameters": [
            {"parameterName": "cellDepType",
             "value": "NSA",
             "operation": "update"},
            {"parameterName": "configuredEpsTac",
             "value": "7151",
             "operation": "update"
             },
             {
                "parameterName":"actDynUlDataSplitMode",
                "value":"true",
                "operation":"update"
            },
            {"parameterName": "trackingAreaDN",
             "value": "",
             "operation": "delete"
             }
            ] '''

_nsa_to_sa_parameters = '''"parameters": [
            {"parameterName": "cellDepType",
             "value": "SA",
             "operation": "update"},
            {"parameterName": "configuredEpsTac",
             "value": "",
             "operation": "delete"
             },
             {
                "parameterName":"actDynUlDataSplitMode",
                "value":"false",
                "operation":"update"
            },
            {"parameterName": "trackingAreaDN",
             "value": "MRBTS-50435/NRBTS-50435/TRACKINGAREA-7151",
             "operation": "update"
             }
            ] '''

_cell_dep_type_change = """
[
        {{"distName": "MRBTS-50435/NRBTS-50435/NRCELL-1",
         "operation": "update",
         {params_to_be_changed} }},
        {{"distName": "MRBTS-50435/NRBTS-50435/NRCELL-2",
         "operation": "update",
         {params_to_be_changed} }},
        {{"distName": "MRBTS-50435/NRBTS-50435/NRCELL-3",
         "operation": "update",
         {params_to_be_changed} }}
]
"""

nsa_to_sa = _cell_dep_type_change.format(params_to_be_changed=_nsa_to_sa_parameters)
sa_to_nsa = _cell_dep_type_change.format(params_to_be_changed=_sa_to_nsa_parameters)

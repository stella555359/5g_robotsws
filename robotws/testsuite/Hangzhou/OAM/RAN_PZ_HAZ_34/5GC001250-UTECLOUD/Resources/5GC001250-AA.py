"""
:copyright: Nokia Networks
:author: Lixia Tang
:contact: lixia.tang@nokia-sbell.com
"""

import os
"""
usage

admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/EQM-1/HWTOP-1/CABLINK-3
...                                         parameter=params_to_create_bbmod_obj

"""


def params_to_create_new_cablink_obj(mrbtsId, rmodid):
    return prepare_params_to_create_object(cablinkN(mrbtsId, rmodid))


def prepare_params_to_create_object(object_params):
    """
    :param object_params: list of dicts like [{param: value}, {param: value} ...]
    :return:
    """
    param_dicts = []
    for param, value in object_params.items():
        param_dicts.append(
            {"parameterName": param, "operation": "update", "value": value}
        )
    return param_dicts


def cablinkN(mrbtsId, rmodid):
    return {
        "firstEndpointDN": "MRBTS-{}/EQM-1/APEQM-1/CABINET-1/SMOD-1".format(mrbtsId),
        "firstEndpointLabel": "SFP",
        "firstEndpointPortId": 2,
        "linkModeConfiguration": "false",
        "linkModeDC": "false",
        "linkModeData": "false",
        "linkModeSynchronization": "false",
        "linkSpeed": "eCpri25",
        "radioProtocolType": "25eCPRI",
        "secondEndpointDN": "MRBTS-{}/EQM-1/APEQM-1/RMOD-{}".format(mrbtsId, rmodid),
        "secondEndpointLabel": "SFP",
        "secondEndpointPortId": 2
    }

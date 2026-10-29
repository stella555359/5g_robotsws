"""
usage

admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/EQM-1/HWTOP-1/CABLINK-3
...                                         parameter=params_to_create_bbmod_obj

"""


def params_to_create_cablink_obj(mrbtsId):
    return prepare_params_to_create_object(cablink(mrbtsId))


def params_to_create_cablink_ASOD_obj(mrbtsId):
    return prepare_params_to_create_object(cablink_ASOD(mrbtsId))


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


def cablink(mrbtsId):
    return {
        "firstEndpointLabel": "QSFP",
        "firstEndpointPortId": 2,
        "linkSpeed": "Cpri6",
        "firstEndpointDN": "{}/EQM-1/APEQM-1/CABINET-1/BBMOD-1".format(mrbtsId),
        "secondEndpointDN": "{}/EQM-1/APEQM-1/RMOD-1".format(mrbtsId)
    }


def cablink_ASOD(mrbtsId):
    return {
        "firstEndpointLabel": "SFP",
        "firstEndpointPortId": 1,
        "linkSpeed": "eCpri25",
        "firstEndpointDN": "{}/EQM-1/APEQM-1/CABINET-1/SMOD-1".format(mrbtsId),
        "secondEndpointDN": "{}/EQM-1/APEQM-1/RMOD-1".format(mrbtsId)
    }


def cablink1(mrbtsId, rmodid):
    return {
        "firstEndpointLabel": "QSFP",
        "firstEndpointPortId": 1,
        "linkSpeed": "Cpri7",
        "radioProtocolType": "TDDCPRI",
        "firstEndpointDN": "{}/EQM-1/APEQM-1/CABINET-1/BBMOD-1".format(mrbtsId),
        "secondEndpointDN": "{}/EQM-1/APEQM-1/RMOD-{}".format(mrbtsId, rmodid),
        "secondEndpointLabel": "QSFP",
        "secondEndpointPortId": 1
    }


def cablink1_ASOD(mrbtsId, rmodid):
    return {
        "firstEndpointLabel": "SFP",
        "firstEndpointPortId": 2,
        "linkSpeed": "eCpri25",
        "radioProtocolType": "25eCPRI",
        "firstEndpointDN": "{}/EQM-1/APEQM-1/CABINET-1/SMOD-1".format(mrbtsId),
        "secondEndpointDN": "{}/EQM-1/APEQM-1/RMOD-{}".format(mrbtsId, rmodid),
        "secondEndpointLabel": "SFP",
        "secondEndpointPortId": 1
    }


def params_to_create_cablink1_obj(mrbtsId, rmodid):
    return prepare_params_to_create_object(cablink1(mrbtsId, rmodid))


def params_to_create_cablink1_ASOD_obj(mrbtsId, rmodid):
    return prepare_params_to_create_object(cablink1_ASOD(mrbtsId, rmodid))


def params_to_create_rmod_obj():
    return prepare_params_to_create_object(rmod())


def rmod():
    return {
        "actPimCancellation": False,
        "actSnapshotCollection": False,
        "administrativeState": "Locked",
        "pimCancellingEnabled": False,
        "prodCodePlanned": "089530A",
        "linkSpeed": "Cpri7"
    }


def params_to_create_rmod_ASOD_obj():
    return prepare_params_to_create_object(rmod_ASOD())


def rmod_ASOD():
    return {
        "actPimCancellation": False,
        "actSnapshotCollection": False,
        "administrativeState": "Locked",
        "pimCancellingEnabled": False,
        "prodCodePlanned": "089530A",
        "linkSpeed": "Cpri7"
    }


def get_info_on_specific_ru(all_components_info, component_id):
    return _RuRetriever().get_info_on_specific_component(
        all_components_info, component_id)

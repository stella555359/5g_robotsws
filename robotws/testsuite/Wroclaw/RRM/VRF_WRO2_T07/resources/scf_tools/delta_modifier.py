import json
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog


def edit_delta_object(distName, **kwargs):
    try:
        _edit_delta_object(distName=distName, operation='update', **kwargs)
    except Exception:
        blog("No object to update, need to create")
        _edit_delta_object(distName=distName, operation='create', **kwargs)


def _edit_delta_object(distName, operation, **kwargs):
    parameter_list = []
    for parameter, value in kwargs.items():
        parameter_list.append({'parameterName': parameter,
                               'value': value,
                               'operation': 'update'})
    delta_object = [
        {
            'distName': distName,
            'operation': operation,
            'parameters': parameter_list
        }
    ]
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta_object))

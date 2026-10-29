from contextlib import contextmanager
from pprint import pformat

from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import vdu

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration

_cu = cu()
_vdu = vdu()


@contextmanager
def vcu_context():
    try:
        details = TestlineConfiguration().get_gnb_oam_connection_details()
        yield _cu.connect_to(host=details['hostname'], port='443', username=details['username'],
                             password=details['password'], secure=True)
    finally:
        _cu.disconnect()


@contextmanager
def vdu_context(du_id):
    try:
        details = TestlineConfiguration().get_du_oam_connection_details(du_id=du_id)
        yield _cu.connect_to(host=details['hostname'], port='443', username=details['username'],
                             password=details['password'], secure=True)
    finally:
        _cu.disconnect()


def check_commissioned_parameters(params_dict, admin):
    params_read = {}
    for distname, params in params_dict.items():
        for name, value in params.items():
            found_param = admin.search_parameters_of_current_plan(name).to_dict()
            params_read = _merge_dicts(params_read, _parse_search_response(found_param))
    assert _is_dict_subset(params_read, params_dict), \
        f"Parameters read form node: {pformat(params_read)}\n\n Expected: {pformat(params_dict)}"


def _parse_search_response(response):
    params = {}
    for item in response['items']:
        params[item['distname']] = _parse_parameter(item['parameter'])
    return params


def _parse_parameter(param):
    if not isinstance(param, dict) and hasattr(param, 'to_dict'):
        param = param.to_dict()
    if param['parameter_type'] == 'complex':
        return _parse_complex_parameter(param)
    elif param['parameter_type'] == 'simple':
        return _parse_simple_parameter(param)
    else:
        raise ValueError(f"Unknown parameter type {param['parameter_type']}")


def _parse_complex_parameter(param):
    name = param['complex_parameter']['name']
    data = {name: {}}
    for nested_param in param['complex_parameter']['value'][0].structure_parameters:
        data[name].update(_parse_parameter(nested_param))
    return data


def _parse_simple_parameter(param):
    return {param['simple_parameter']['name']: param['simple_parameter']['value']}


def _merge_dicts(d1, d2):
    for k, v in d1.items():
        if k in d2:
            if isinstance(v, dict) and isinstance(d2[k], dict):
                d2[k] = _merge_dicts(v, d2[k])
    d3 = d1.copy()
    d3.update(d2)
    return d3


def _is_dict_subset(superset, subset):
    for k, v in subset.items():
        if k not in superset:
            return False
        if isinstance(v, dict):
            if not isinstance(superset[k], dict) or not _is_dict_subset(superset[k], v):
                return False
        else:
            if superset[k] != v:
                return False
    return True

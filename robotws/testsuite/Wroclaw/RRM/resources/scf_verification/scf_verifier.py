import testsuite.Wroclaw.RRM.resources.scf_verification.dynamic_pdcch_setup as dyn_pdcch
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.resources.log.log import blog
from taf.config.scf import scf

msg = 'Parameter: {param} | Current: {current_value} | Expected: {expected_value}'
_scf = scf()


def setup_and_check_preconditions_in_scf(params_to_check=None,
                                         scf_file=None,
                                         skip_parameter_relation_errors=False,
                                         bandwidth=None, bts_host=None):
    """
    Check whether the SCF parameters specified in params_to_check are set up as expected
    and correct them if they're not.
    :param params_to_check: A dict of relevant parameters, given as { 'p_name': 'wanted value' } pairs.
           if you want the parameter to be checked and changed only in the specific object you should input the full
           distname path before the parameter name (e.g. 'MRBTS-1900/NRBTS-1900/NRCELL-1/chBw'). You can omit the
           MRBTS part only ('NRBTS-1900/NRCELL-1/chBw' will work too).
    :param scf_file: The scf file you want to handle. Will download current scf if not specified.
    :param skip_parameter_relation_errors: Boolean which decides about scf commissioning in case of relation errors
    :param bandwidth: The bandwidth used for dynamic PDCCH configuration.
    :param bts_host: IP address of WebEM. Usually the m-plane address.
    :returns Assertion error if parameters could not be set up properly.
    """
    bts_host = bts_host if bts_host else '192.168.255.129'
    admin_utils = AdminUtils(bts_host=bts_host)

    current_scf_file = admin_utils.download_current_scf(file_name='backup_scf.xml')
    if not scf_file:
        scf_file = admin_utils.download_current_scf(file_name='new_scf.xml')
    _scf.load_scf(scf_file)
    try:
        if bandwidth:
            dyn_pdcch.check_expected_pdcch_parameters(_scf, bandwidth)
        if params_to_check:
            check_expected_parameters(params_to_check, _scf)
    except AssertionError:
        if bandwidth:
            dyn_pdcch.setup_expected_pdcch_parameters(_scf, bandwidth)
            dyn_pdcch.check_expected_pdcch_parameters(_scf, bandwidth)

        if params_to_check:
            setup_expected_parameters(params_to_check, _scf)
            check_expected_parameters(params_to_check, _scf)
        _scf.save_scf(scf_file)

        admin_utils.perform_commissioning(scf_file=scf_file,
                                          skip_parameter_relation_errors=skip_parameter_relation_errors)
        admin_utils.wait_for_all_cells_on_air_state()
    return current_scf_file


def check_expected_parameters(params_to_check, _scf):
    for param, expected_value in params_to_check.items():
        if '/' in param:
            dist_name, param = param.rsplit('/', 1)
            if isinstance(expected_value, list):
                fetched_values = _scf.get_all_values_from_scf(dist_name=dist_name, list_name=param)
            else:
                fetched_values = _scf.get_all_values_from_scf(dist_name=dist_name, p_name=param)
        else:
            if isinstance(expected_value, list):
                fetched_values = _scf.get_all_values_from_scf(list_name=param)
            else:
                fetched_values = _scf.get_all_values_from_scf(p_name=param)
        for value in fetched_values:
            if isinstance(expected_value, list):
                blog(msg.format(param=param, current_value=fetched_values, expected_value=expected_value))
                assert list(map(str.lower, fetched_values)) == list(map(str.lower, expected_value)), \
                    '{param} is not set properly.'.format(param=param)
            else:
                blog(msg.format(param=param, current_value=value, expected_value=expected_value))
                assert value.lower() == expected_value.lower(), '{param} is not set properly.'.format(param=param)


def setup_expected_parameters(params_to_modify, _scf):
    blog("=== Setting parameters ===")
    for param, value_to_set in params_to_modify.items():
        if '/' in param:
            dist, param = param.rsplit('/', 1)
            if isinstance(value_to_set, list):
                _scf.remove_list_from_scf(list_name=param, dist_name=dist)
                _scf.add_list_to_scf(list_name=param, dist_name=dist)
                _scf.add_elements_to_list(list_name=param, dist_name=dist, elements=value_to_set)
            else:
                _scf.modify_scf_element(value=value_to_set, p_name=param, dist_name=dist)
        else:
            if isinstance(value_to_set, list):
                raise Exception("Modifying list elements via scf_verifier is not supported without dist name")
            else:
                number_of_duplicate_elements = len(_scf.get_all_values_from_scf(p_name=param))
                for idx in range(number_of_duplicate_elements):
                    _scf.modify_scf_element(value=value_to_set, p_name=param, index=idx)
    blog("=== Parameters set ===")


def get_parameters_value_from_scf(params_to_get, scf_file=None, bts_host=None):
    bts_host = bts_host if bts_host else '192.168.255.129'
    admin_utils = AdminUtils(bts_host=bts_host)

    if not scf_file:
        scf_file = admin_utils.download_current_scf()
    _scf.load_scf(scf_file)

    values = [get_single_parameter_values_from_scf_object(distname_or_param, _scf)
              for distname_or_param
              in params_to_get]
    return values


def get_single_parameter_values_from_scf_object(distname_or_param, _scf):
    if '/' in distname_or_param:
        dist_name, param = distname_or_param.rsplit('/', 1)
        return _scf.get_all_values_from_scf(dist_name=dist_name, p_name=param)
    else:
        param = distname_or_param
        return _scf.get_all_values_from_scf(p_name=param)


def get_single_parameter_value_from_scf_file(distname_or_param, scf_file):
    _scf.load_scf(scf_file)
    return get_single_parameter_values_from_scf_object(distname_or_param, _scf)

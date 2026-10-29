import re
from taf.rfrl.bts.devices.asir.asir_operations import AsirHubOperations


def compare_delta_parameters_with_asir_scf(delta, scf_file_path, should_be_equal=True):
    """
    Compare delta parameters with asir scf
    :param      delta: list of dicts with parameters changes
    :param      scf_file_path: path to asir scf file
    :param      should_be_equal: optional, specifies whether the values should be the same
    :raises:    ValueError if parameters are incompatible
    """
    asir = AsirHubOperations()
    for delta_params_dict in delta:
        if 'parameters' in delta_params_dict:
            moc = re.findall(r'[^/-]+(?=-\d+$)', delta_params_dict['distName'])[0]
            class_name = f'com.nokia.asi:{moc}'
            scf_params = asir.get_all_params_under_class_name(scf_file_path, class_name)[0]['params']
            for delta_parameter in delta_params_dict['parameters']:
                if should_be_equal and delta_parameter['value'] != \
                        scf_params[delta_parameter['parameterName']]:
                    raise ValueError("Parameter '{0}' has a different value '{1}, {2}' in delta and scf, "
                                     "but should have the same".format(delta_parameter['parameterName'],
                                                                       delta_parameter['value'],
                                                                       scf_params[delta_parameter['parameterName']]))
                elif not should_be_equal and delta_parameter['value'] == \
                        scf_params[delta_parameter['parameterName']]:
                    raise ValueError("Parameter '{0}' has the same value '{1}' in delta and scf, "
                                     "but should have different".format(delta_parameter['parameterName'],
                                                                        delta_parameter['value']))

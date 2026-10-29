from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn
import yaml


def get_yaml_parameter_uepc(ue_name, parameter):
    """
    Gets parameter from YAML file
    :param ue_name: UE name
    :type ue_name: string
    :param parameter: parameter from configuration file (ue_pc_ip, password)
    :type parameter: string
    :return: Return parameter value
    :rtype: string
    :raise Configuration file reading error or bad UE name
    """
    with open(BuiltIn().get_variable_value("${tl.ues[0]}"), 'r') as stream:
        try:
            ue_settings = yaml.safe_load(stream)
            configuration = (ue_settings['UE_POOLS']['AndroidUePool']['inline_config']
                                        [ue_name]['CONSTRUCTOR_PARAMETERS']['configuration'])
            return configuration[parameter]
        except yaml.YAMLError as exc:
            BuiltIn().log_to_console(exc)


def get_yaml_ue_name():
    """
    Gets UE name from YAML file
    :return: ue name
    :rtype: string
    :raise Configuration file reading error (IOError: [Errno 2] No such file or directory)
           or bad configuration in __init__123.py file
    """
    with open(BuiltIn().get_variable_value("${tl.ues[0]}"), 'r') as stream:
        try:
            ue_settings = yaml.safe_load(stream)
            return ue_settings['UE_POOLS']['AndroidUePool']['inline_config'].keys()[0]
        except yaml.YAMLError as exc:
            BuiltIn().log_to_console(exc)


def get_type_ue():
    """
    Get ue type from __init__ file
    :return: UE type
    :rtype: string
    :raise Exception no supporting eu found.
    """
    tl_type = BuiltIn().get_variable_value("${tl.tl_cloud_topology}")
    if tl_type:
        if 'WNC' in tl_type:
            return 'WNC'
        elif 'ASKEY' in tl_type:
            return 'ASKEY'
        elif 'QC' in tl_type:
            return 'QUALCOMM'
        elif 'VIAVI' in tl_type:
            return 'VIAVI'
        else:
            raise Exception('[ERROR] No ue information in tl_cloud_topology')
    else:
        raise Exception('[ERROR] No "tl_cloud_topology" information in __init__123.py')

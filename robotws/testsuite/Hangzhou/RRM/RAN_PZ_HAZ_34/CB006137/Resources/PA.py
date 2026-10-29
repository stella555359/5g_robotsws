"""
Author: Ding Binmei
Description: Methods related with PA.
"""
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

__init__ = [
    "get_pa_ports_based_on_ru_index",
    "generate_pa_ports_and_values_for_update"
]


def get_pa_ports_based_on_ru_index(ru_index, gnb_index=0, du_index=0):
    """
    Get PA ports defined in init file based on RU index.
    Return a list of PA ports.

    """
    pa_ports_obj = tl.gnbs[gnb_index].dus[du_index].rus[ru_index].attenuation_ports
    pa_ports = [pa_port_obj.port_no for pa_port_obj in pa_ports_obj]
    return pa_ports


def generate_pa_ports_and_values_for_update(dict_pa_for_ru):
    """
    Generate ports and values for updating PA.
    Will find PA ports based on RU index which is defined in testline config file. And also generate pa value list
    based on port number and provided value.
    :param dict_pa_for_ru: should be in dict format with bellow format:
    {
        ru_index1: pa_value1,
        ru_index2: pa_value2
    }
    return: with a dict in bellow formats:
    {
        "pa_ports": [pa_port1, pa_port2, ...],
        "pa_values": [pa_value1, pa_value1, ...]
    }

    """
    list_ru_index = dict_pa_for_ru.keys()
    dict_pa_ports_values = {"pa_ports": [], "pa_values": []}
    for ru_index in list_ru_index:
        ru_index = int(ru_index)
        pa_ports = get_pa_ports_based_on_ru_index(ru_index)
        pa_ports_num = len(pa_ports)
        pa_values = [int(dict_pa_for_ru[ru_index]) for _ in range(pa_ports_num)]
        dict_pa_ports_values["pa_ports"].extend(pa_ports)
        dict_pa_ports_values["pa_values"].extend(pa_values)
    return dict_pa_ports_values

# -*- coding: utf-8 -*

"""
Author:         Liu Zheng
Contact Mail:   zheng.4.liu@nokia-sbell.com
Description:    verify the values in list are different

"""
from robot.api import logger


def verify_values_in_list_are_different(input_list):
    input_list_len = len(input_list)

    input_list_set_len = len(set(input_list))

    if input_list_len != input_list_set_len:
        print('there are same values in this list: ', input_list)
        raise Exception('there are same values in list, please check the list!')


def get_ciphering_value_of_current_plan(para_dict):
    '''
    :param :
    {b'items': [{b'distname': b'MRBTS-247/NRBTS-1',
                 b'mo_uuid': b'fecb5dc8-e539-4645-84b0-3f51f3f35cd1',
                 b'nidd_id': b'199432',
                 b'parameter': {b'complex_parameter': {b'name': b'cipherPrefL',
                                                       b'state': 'unchanged',
                                                       b'value': [{'structure_parameters': [{'complex_parameter': None,
                                                                                'parameter_type': u'simple',
                                                                                'simple_list_parameter': None,
                                                                        'simple_parameter': {'name': 'nea0',
                                                                                            'state': u'unchanged',
                                                                                            'value': '0'}},
                                                                        {'complex_parameter': None,
                                                                         ...
                                                                        'simple_parameter': {'name': 'nea1_128',
                                                                                'state': u'unchanged',
                                                                                'value': '2'}},
                                                                        {'complex_parameter': None,
                                                                         ...
                                                                        'simple_parameter': {'name': 'nea2_128',
                                                                                            'state': u'unchanged',
                                                                                            'value': '4'}},
                                                                        {'complex_parameter': None,
                                                                         ...
                                                                        'simple_parameter': {'name': 'nea3_128',
                                                                                            'state': u'unchanged',
                                                                                            'value': '5'}}]}]},
                               b'parameter_type': 'complex',
                               b'simple_list_parameter': None,
                               b'simple_parameter': None},
                 b'parameter_name': b'cipherPrefL',
                 b'state': 'unchanged'}], b'total': 1}

    :return: ciphering dict
    note: structure_parameters type is
    <class 'taf.internal.gnb.oam.coam.cu.client.asm.v1.models.complex_param_children_structure.
    ComplexParamChildrenStructure'>
    '''
    ciphering_dict = {}
    structure_parameters = para_dict['items'][0]['parameter']['complex_parameter']['value'][0]
    logger.info("structure_parameters type is {}".format(type(structure_parameters)))
    for structure_para_value in structure_parameters.structure_parameters:
        ciphering_dict[structure_para_value.simple_parameter.name] = structure_para_value.simple_parameter.value
    return ciphering_dict

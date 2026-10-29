"""
:copyright: Nokia Networks
:author: Dawid Krawczuk <dawid.krawczuk@nokia.com>
:maintainer: Dawid Krawczuk <dawid.krawczuk@nokia.com>
"""
import logging


def get_field_from_structure(field_getter_params, many=False):
    if len(field_getter_params) == 2:
        structure_name_to_find_field = field_getter_params[0]
        field_name = field_getter_params[1]

        def _return_field(msg):
            r_logger = logging.getLogger('message_verifier_for_pcmd')
            try:
                structure = msg.get_value_by_unique_key(
                    structure_name_to_find_field)
            except Exception as e:
                r_logger.warn('Could not get structure: {} due to: {}'.format(
                    structure_name_to_find_field, e))
                raise e
            if many is False:
                fun = structure.get_value_by_unique_key
            else:
                fun = structure.get_all_values_by_key
            try:
                field_value = fun(field_name)
            except Exception as e2:
                r_logger.warn('Could not get field: {} from struct: {} due to: {}'.format(field_name,
                                                                                          structure_name_to_find_field,
                                                                                          e2))
                raise e2
            return field_value
    elif len(field_getter_params) == 3:
        structure_name_to_find_field = field_getter_params[0]
        non_unique_substructure_name_to_find_field = field_getter_params[1]
        field_name = field_getter_params[2]
        field_values = []

        def _return_field(msg):
            r_logger = logging.getLogger('message_verifier_for_pcmd')
            try:
                structure = msg.get_value_by_unique_key(
                    structure_name_to_find_field)
            except Exception as e:
                r_logger.warn('Could not get structure: {} due to: {}'.format(
                    structure_name_to_find_field, e))
                raise e
            substructures = structure.get_all_values_by_key(
                non_unique_substructure_name_to_find_field)
            for substructure in substructures:
                fun = substructure.get_value_by_unique_key
                try:
                    field_value = fun(field_name)
                    field_values.append(field_value)
                except Exception as e2:
                    r_logger.warn('Could not get field: {} from struct: {} due to: {}'.
                                  format(field_name, structure_name_to_find_field, e2))
                    raise e2
            return field_values

    return _return_field


def default_unique_field_getter(field_name, many=False):
    def _return_field(msg):
        if many is False:
            fun = msg.get_value_by_unique_key
        else:
            fun = msg.get_all_values_by_key
        return fun(field_name)
    return _return_field

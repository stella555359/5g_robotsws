import json
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from testsuite.Wroclaw.OAM.VRF_WRO3_T04.common_resources.admin.decorators import inject_admin_connection


class ParametersCommissioningManager:

    @inject_admin_connection
    def recommission_object(self, dist_name, operation, skip_parameter_relation_errors,
                            should_activate, timeout, retry, connection, **kwargs):
        parameter_list = self._create_multiple_parameters_recommission_list(kwargs)

        response = BuiltIn().wait_until_keyword_succeeds('{}x'.format(retry),
                                                         '{}s'.format(30),
                                                         'coam_admin.perform_object_recommissioning',
                                                         dist_name,
                                                         parameter_list,
                                                         operation,
                                                         skip_parameter_relation_errors,
                                                         should_activate,
                                                         timeout,
                                                         connection)

        summary = self._format_multiple_parameters_summary(kwargs)
        logger.info('Performed parameters {operation} on BTS ({param_summary})'
                    .format(operation=operation, param_summary=summary),
                    also_console=True)

        return response

    @inject_admin_connection
    def recommission_parameter(self, dist_name, param_name, operation, param_value,
                               skip_parameter_relation_errors, should_activate,
                               timeout, retry, connection):
        response = BuiltIn().wait_until_keyword_succeeds('{}x'.format(retry),
                                                         '{}s'.format(30),
                                                         'coam_admin.perform_parameter_recommissioning',
                                                         dist_name,
                                                         param_name,
                                                         operation,
                                                         param_value,
                                                         skip_parameter_relation_errors,
                                                         should_activate,
                                                         timeout,
                                                         connection)

        logger.info('Performed parameter {operation} on BTS ({dist_name}/{param_name}), {param_value}'
                    .format(operation=operation, dist_name=dist_name,
                            param_name=param_name, param_value=param_value),
                    also_console=True)
        return response

    @inject_admin_connection
    def recommission_with_delta(self, delta, skip_parameter_relation_errors, should_activate,
                                timeout, retry, connection):
        json_delta = json.dumps(delta)
        response = BuiltIn().wait_until_keyword_succeeds('{}x'.format(retry),
                                                         '{}s'.format(30),
                                                         'coam_admin.perform_delta_recommissioning',
                                                         json_delta,
                                                         skip_parameter_relation_errors,
                                                         should_activate,
                                                         timeout,
                                                         connection)

        summary = self._format_delta_parameters_summary(delta)
        logger.info('Performed delta parameters recommissioning on BTS:\n{}'
                    .format(summary), also_console=True)

        return response

    @staticmethod
    def _create_multiple_parameters_recommission_list(params_dict):
        return [{
            'parameterName': param_name,
            'operation': 'update',
            'value': param_value
        } for param_name, param_value in params_dict.items()]

    @staticmethod
    def _format_delta_parameters_summary(params_list):
        delta_summary = list()

        for param_object in params_list:
            for param in param_object['parameters']:
                value = ': ' + param['value'] if param['value'] else ''
                delta_summary.append('{operation} {param_name}{param_value}'.format(
                    operation=param['operation'].upper(),
                    param_name=param['parameterName'],
                    param_value=value)
                )

            return '\n'.join(delta_summary)

    @staticmethod
    def _format_multiple_parameters_summary(params_dict):
        str_dict = ['{}: {}'.format(key, value) for key, value in params_dict.items()]
        return ', '.join(str_dict)

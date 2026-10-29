import yaml


class ParameterParser():
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.parameter = None

    def load_parameter_file(self, param_file):
        stream = open(param_file, 'r')
        self.parameter = yaml.load(stream, Loader=yaml.FullLoader)
        return

    def is_testcase_parameter_present(self, test_name):
        return test_name in self.parameter

    def get_feature_paramters_dict(self, test_name, param_section):
        self.test_case_should_be_present(test_name)
        return self.parameter[test_name][param_section]

    def test_case_should_be_present(self, test_name):
        if not self.is_testcase_parameter_present(test_name):
            raise AssertionError('Test Name:{} not configured in parameter file'.format(test_name))
        return

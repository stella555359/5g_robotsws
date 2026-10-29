import yaml


class ParameterParser():
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.parameter = None

    def load_parameter_file(self, param_file):
        with open(param_file, 'r') as stream:
            self.parameter = yaml.load(stream, Loader=yaml.FullLoader)
        return

    def is_sce_parameter_present(self, sce_name):
        return sce_name in self.parameter

    def get_feature_parameters_dict(self, sce_name, param_section):
        self.sce_should_be_present(sce_name)
        return self.parameter[sce_name][param_section]

    def sce_should_be_present(self, sce_name):
        if not self.is_sce_parameter_present(sce_name):
            raise AssertionError('Sce Name:{} not configured in parameter file'.format(sce_name))
        return

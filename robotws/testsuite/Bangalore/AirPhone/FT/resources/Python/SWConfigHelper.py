class SWConfigHelper(object):
    ROBOT_LIBRARY_SCOPE = 'TEST CASE'

    def __init__(self):
        self.sw_config_fields = {}

    def _uncommented_non_empty(self, swconfig_file):
        with open(self.sw_config_file, 'r') as file_handler:
            for line in file_handler:
                if line != "\n" and not (line.startswith('#')):
                    yield line

    def load_sw_config_file(self, sw_config_file):
        self.sw_config_file = sw_config_file
        for line in self._uncommented_non_empty(self.sw_config_file):
            field_name, field_value = line.strip().split('=', 1)
            self.sw_config_fields[field_name.strip()] = field_value.strip().split(" ")[0]
        return

    def is_field_present(self, field):
        return field in self.sw_config_fields

    def update_field(self, **kwargs):
        self.sw_config_fields.update(**kwargs)
        return

    def delete_field(self, **kwargs):
        for key, value in kwargs.items():
            if self.is_field_present(key):
                del self.sw_config_fields[key]
        return

    def generate_swconfig_file(self, filepath):
        with open(filepath, "w") as file_handler:
            for key, value in self.sw_config_fields.items():
                file_handler.writelines('{0}={1}\n'.format(key, value))
        return filepath

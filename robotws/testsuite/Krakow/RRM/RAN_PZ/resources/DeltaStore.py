from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


class DeltaStore():
    ROBOT_LIBRARY_SCOPE = 'TEST CASE'

    def __init__(self):
        self.delta_store_name = None
        self.admin_cli = BuiltIn().get_library_instance('coam')

    def initialise_delta_store(self, name):
        self.delta_store_name = name
        self.delete_delta_if_alread_present(self.delta_store_name)
        self.delta_store = self.admin_cli.create_delta(delta_id=self.delta_store_name)

    def add_param_to_delta(self, dist_name, param_name, value):
        self.admin_cli.append_parameter_update_to_delta(delta_id=self.delta_store_name,
                                                        dist_name=dist_name,
                                                        parameter=param_name,
                                                        value=value)

    def collect_delta_store(self):
        return self.admin_cli.get_delta(delta_id=self.delta_store_name)

    def delete_delta_if_alread_present(self, name):
        try:
            self.admin_cli.remove_all_delta_id()
        except Exception as e:
            pass

    def recommission_with_delta(self, should_activate=True):
        delta_json = self.collect_delta_store()
        if delta_json == '[]':
            logger.info('No new parameter added to perform delta commisioning')
            return
        logger.debug('Performing delta commisioning with delta json %s' % (delta_json,))
        self.admin_cli.perform_delta_recommissioning(delta_file=delta_json,
                                                     skip_parameter_relation_errors=True,
                                                     should_activate=should_activate)

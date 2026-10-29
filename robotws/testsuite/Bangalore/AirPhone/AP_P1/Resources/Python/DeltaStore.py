from taf.sbts.oam.coam.admin import admin


class DeltaStore():
    ROBOT_LIBRARY_SCOPE = 'TEST CASE'

    def __init__(self):
        self.delta_store_name = None
        self.admin = admin()

    def initialise_delta_store(self, name='default'):
        self.delta_store_name = name
        self.delete_delta_if_alread_present(self.delta_store_name)
        self.delta_store = self.admin.create_delta(delta_id=self.delta_store_name)

    def add_param_to_delta(self, dist_name, param_name, value):
        self.admin.append_parameter_update_to_delta(delta_id=self.delta_store_name,
                                                    dist_name=dist_name,
                                                    parameter=param_name,
                                                    value=value)

    def add_managed_object_and_parameter_to_delta(self, dist_name, **parameters):
        self.admin.append_managed_object_to_delta(dist_name, operation='create',
                                                  delta_id=self.delta_store_name)
        self.add_parameters_to_delta(dist_name, **parameters)
        return

    def delete_managed_object_from_delta(self, dist_name):
        self.admin.append_managed_object_to_delta(dist_name, operation='delete',
                                                  delta_id=self.delta_store_name)
        return

    def update_managed_object_and_parameter_to_delta(self, dist_name, **parameters):
        self.admin.append_managed_object_to_delta(dist_name, operation='update',
                                                  delta_id=self.delta_store_name)
        self.add_parameters_to_delta(dist_name, **parameters)
        return

    def add_parameters_to_delta(self, dist_name, **parameters):
        for name, value in parameters.items():
            self.admin.append_parameter_update_to_delta(dist_name, name, value,
                                                        self.delta_store_name)
        return

    def add_list_parameters_to_delta(self, dist_name, list_name, **parameters):
        self.admin.append_parameter_update_to_delta(dist_name, parameter=list_name,
                                                    value=[parameters],
                                                    delta_id=self.delta_store_name)
        return

    def add_list_parameters_without_name_to_delta(self, dist_name, list_name, *parameters):
        self.admin.append_parameter_update_to_delta(dist_name, parameter=list_name,
                                                    value=[parameters],
                                                    delta_id=self.delta_store_name)
        return

    def collect_delta_store(self):
        return self.admin.get_delta(delta_id=self.delta_store_name)

    def delete_delta_if_alread_present(self, name):
        try:
            self.admin.remove_all_delta_id()
        except Exception as e:
            pass

    def add_legacy_list_parameters_to_delta(self, dist_name, list_name, *parameters):
        values = list(parameters)
        self.admin.append_parameter_update_to_delta(dist_name, list_name, values, self.delta_store_name)
        return

    def delete_param_from_delta(self, dist_name, param_name):
        self.admin.append_parameter_delete_to_delta(dist_name=dist_name,
                                                    parameter=param_name,
                                                    delta_id=self.delta_store_name)

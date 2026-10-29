from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from taf.sbts.oam.coam.admin.utils.delta import DeltaInterface


class DeltaStore:
    def __init__(self, bts_host='192.168.255.129'):
        self.delta_store_name, self.delta_store = None, None
        self.bts_host = bts_host

    def initialise_delta_store(self, bts_host='192.168.255.129', name='default'):
        self.bts_host = bts_host
        self.delta_store_name = name
        self.delete_delta_if_already_present(name)
        self.delta_store = DeltaInterface.create_delta(delta_id=self.delta_store_name)

    @logged_keyword
    def add_param_to_delta(self, dist_name, param_name, value):
        DeltaInterface.append_parameter_update_to_delta(delta_id=self.delta_store_name,
                                                        dist_name=dist_name,
                                                        parameter=param_name,
                                                        value=value)

    @logged_keyword
    def add_param_to_delta_to_delete_it(self, dist_name, param_name):
        DeltaInterface.append_parameter_delete_to_delta(delta_id=self.delta_store_name,
                                                        dist_name=dist_name,
                                                        parameter=param_name)

    def add_managed_object_and_parameter_to_delta(self, dist_name, **parameters):
        DeltaInterface.append_managed_object_to_delta(dist_name, operation='create', delta_id=self.delta_store_name)
        self.add_parameters_to_delta(dist_name, **parameters)

    def add_complex_item_to_delta(self, dist_name, list_name, **parameters):
        DeltaInterface.append_complex_item_to_delta(
            dist_name, list_name=list_name, delta_id=self.delta_store_name, **parameters)

    def delete_managed_object_from_delta(self, dist_name):
        DeltaInterface.append_managed_object_to_delta(dist_name, operation='delete', delta_id=self.delta_store_name)

    def update_managed_object_and_parameter_to_delta(self, dist_name, **parameters):
        DeltaInterface.append_managed_object_to_delta(dist_name, operation='update', delta_id=self.delta_store_name)
        self.add_parameters_to_delta(dist_name, **parameters)

    def add_parameters_to_delta(self, dist_name, **parameters):
        for name, value in parameters.items():
            DeltaInterface.append_parameter_update_to_delta(dist_name, name, value, self.delta_store_name)

    def add_list_parameters_to_delta(self, dist_name, list_name, **parameters):
        DeltaInterface.append_parameter_update_to_delta(dist_name, parameter=list_name, value=[parameters],
                                                        delta_id=self.delta_store_name)

    def add_list_parameters_without_name_to_delta(self, dist_name, list_name, *parameters):
        DeltaInterface.append_parameter_update_to_delta(dist_name, parameter=list_name, value=[parameters],
                                                        delta_id=self.delta_store_name)

    def collect_delta_store(self):
        return DeltaInterface.get_delta(delta_id=self.delta_store_name)

    @staticmethod
    def delete_delta_if_already_present(name):
        try:
            DeltaInterface.remove_all_delta_id()
        except Exception as e:
            pass

    def perform_delta_recommissioning(self, delta_file, bts_host=None, skip_parameter_relation_errors=False,
                                      should_activate=True):
        bts_host = self.bts_host if bts_host is None else bts_host
        with AdminApi(bts_host=bts_host) as web_api:
            web_api.perform_delta_recommissioning(delta_file=delta_file,
                                                  skip_parameter_relation_errors=skip_parameter_relation_errors,
                                                  should_activate=should_activate)

    def validate_scf(self, scf_file=None, skip_parameter_relation_errors=False, timeout=60):
        with AdminApi(bts_host=self.bts_host) as web_api:
            if not scf_file:
                scf_file = web_api.get_current_scf_file(local_dir_path=robot_globals.outputdir(),
                                                        file_name='current_scf.xml')

            return web_api.validate_scf(scf_file,
                                        skip_parameter_relation_errors=skip_parameter_relation_errors,
                                        timeout=timeout)

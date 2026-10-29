import taf.config.testline
from requests.exceptions import HTTPError, ConnectionError
from robot.libraries.BuiltIn import BuiltIn
from taf.gnb.oam.megazone_client import megazone_client
from taf.sbts.oam.coam.admin import admin
from ute_common_admin.exception import AdminApiConnectionClosedException
from testsuite.Wroclaw.RRM.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.webui.webui_executors import MegazoneExecutor, COAMExecutor
from testsuite.Wroclaw.RRM.resources.webui.exceptions import UnrecognisedOAMTypeException


class WebuiInterface(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    oam_type = "unknown"

    def __init__(self):
        self.__executor = None
        self.oam_type = "unknown"
        self.is_classical_testline = isinstance(BuiltIn().get_variable_value('${tl.gnbs[0]}'),
                                                taf.config.testline.gnb.gnb.ClassicalBts)
        self.oam_address = BuiltIn().get_variable_value("${tl.gnbs[0].cu.oam_http_connection_details.addr}")
        self.setup()

    @logged_keyword
    def setup(self):
        self.oam_type = 'cOAM'  # self.__get_executor_type()
        WebuiInterface.oam_type = self.oam_type
        if self.oam_type == 'megazone_client':
            self.__executor = MegazoneExecutor()
        elif self.oam_type == 'cOAM':
            self.__executor = COAMExecutor()
        else:
            self.__executor = UnrecognisedExecutor()

    def create_session(self):
        self.__executor.create_session()

    def teardown_session(self):
        self.__executor.teardown_session()

    def reset_and_wait_for_site(self):
        self.__executor.reset_and_wait_for_site()

    def get_frm(self, attribute=None):
        return self.__executor.get_frm(attribute)

    def get_bts_info(self, attribute=None):
        return self.__executor.get_bts_info(attribute)

    def get_all_vms_types(self):
        return self.__executor.get_all_vms_types()

    def get_vm_availability_status(self, **kwargs):
        return self.__executor.get_vm_availability_status(**kwargs)

    def get_vms_availability_statuses(self):
        return self.__executor.get_vms_availability_statuses()

    def is_cell_in_state(self, **kwargs):
        return self.__executor.is_cell_in_state(**kwargs)

    def cell_lock(self, **kwargs):
        return self.__executor.cell_lock(**kwargs)

    def cell_unlock(self, **kwargs):
        return self.__executor.cell_unlock(**kwargs)

    def get_cell_specific_info(self, **kwargs):
        return self.__executor.get_cell_specific_info(**kwargs)

    def get_current_scf_content(self):
        return self.__executor.get_current_scf_content()

    def get_sw_version(self):
        return self.__executor.get_sw_version()

    def get_sw_release_name(self):
        return self.__executor.get_sw_release_name()

    def wait_for_rap_availability(self):
        return self.__executor.wait_for_rap_availability()

    def get_current_scf_file(self, local_dir_path, file_name):
        return self.__executor.get_current_scf_file(local_dir_path, file_name)

    def rap_reset(self, **kwargs):
        return self.__executor.rap_reset(**kwargs)

    def wait_for_site_availability(self, url, timeout, interval=1.0):
        return self.__executor.wait_for_site_availability(url, timeout, interval)

    def wait_for_site_unavailability(self, url, timeout, interval=1.0):
        return self.__executor.wait_for_site_unavailability(url, timeout, interval)

    def get_startup_phase(self):
        return self.__executor.get_startup_phase()

    def get_pm_files_list(self):
        return self.__executor.get_pm_files_list()

    def get_pm_file_content(self, pm_filename):
        return self.__executor.get_pm_file_content(pm_filename)

    def perform_parameter_recommissioning(self, **kwargs):
        return self.__executor.perform_parameter_recommissioning(**kwargs)

    def perform_object_recommissioning(self, **kwargs):
        return self.__executor.perform_object_recommissioning(**kwargs)

    def perform_delta_recommissioning(self, **kwargs):
        return self.__executor.perform_delta_recommissioning(**kwargs)

    def create_delta(self, **kwargs):
        return self.__executor.create_delta(**kwargs)

    def append_managed_object_to_delta(self, **kwargs):
        return self.__executor.append_managed_object_to_delta(**kwargs)

    def append_list_items_to_delta(self, **kwargs):
        return self.__executor.append_list_items_to_delta(**kwargs)

    def get_managed_objects(self, **kwargs):
        return self.__executor.get_managed_objects(**kwargs)

    def make_snapshot(self, log_path, timeout):
        return self.__executor.make_snapshot(log_path=log_path, timeout=timeout)

    def perform_commissioning(self, scf_path, timeout=600):
        return self.__executor.perform_commissioning(scf_path, timeout=timeout)

    def get_counters_info(self, dist_name):
        return self.__executor.get_counters_info(dist_name=dist_name)

    def get_local_cells(self):
        return self.__executor.get_local_cells()

    def get_subcells_info(self):
        return self.__executor.get_subcells_info()

    def validate_scf(self, scf_file):
        return self.__executor.validate_scf(scf_file)

    def get_active_alarms(self):
        return self.__executor.get_active_alarms()

    @logged_keyword
    def __get_executor_type(self):
        if WebuiInterface.oam_type != "unknown":
            return WebuiInterface.oam_type

        api = admin()
        try:
            api.connect_to()
            api.teardown()
            return 'cOAM'
        except (AdminApiException, AttributeError, OSError):
            pass

        api = megazone_client()
        try:
            api.create_session('https://{}/'.format(self.oam_address))
            api.teardown_session()
            return 'megazone_client'
        except (HTTPError, ConnectionError):
            pass

        return 'Unrecognised OAM type'


class UnrecognisedExecutor(object):
    def __getattr__(self, item):
        raise UnrecognisedOAMTypeException

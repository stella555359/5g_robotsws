"""
Module contains end to end operations related to WebUI
"""

import time
from robot.libraries.BuiltIn import BuiltIn
from taf.ul.oam.selenium_megazone import selenium_megazone
from taf.config.scf import scf
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.webui import WebuiInterface
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.decorators import \
    wait_until_function_succeeds
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.decorators import logged_keyword

scf = scf()
timeout_for_selenium = 30
oam_address = BuiltIn().get_variable_value("${tl.gnbs[0].cu.oam_http_connection_details.addr}")


class WebUIOperations(WebuiInterface):

    def __init__(self, oam_ip=oam_address):
        super(WebUIOperations, self).__init__()
        self.oam_ip = oam_ip
        self.create_session()

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.teardown_session()

    def wait_for_cell_availability(self, timeout=1500.0, interval=5.0, cell_number=1):
        end = time.time() + timeout
        is_cell_online = self.is_cell_in_state(state="online", number=cell_number) or \
            self.is_cell_in_state(state="degraded", number=cell_number)
        while not is_cell_online and not (end < time.time()):
            time.sleep(interval)
            is_cell_online = self.is_cell_in_state(state="online", number=cell_number) or \
                self.is_cell_in_state(state="degraded", number=cell_number)
        assert is_cell_online, 'Timeout expired while waiting for cell availability'
        return is_cell_online


class WebUISeleniumOperations(selenium_megazone):

    def __init__(self, oam_ip=oam_address):
        super(WebUISeleniumOperations, self).__init__()
        self.oam_ip = oam_ip
        self.enable_virtual_display()
        self.login("https://{}/".format(self.oam_ip), 'Nemuadmin', 'nemuuser')

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.logout()
        self.disable_virtual_display()

    def wait_for_cell_is_green(self, timeout=1200.0, interval=5.0):
        end = time.time() + timeout
        is_cell_green = self.is_cell_green()
        while not is_cell_green and not (end < time.time()):
            time.sleep(interval)
            is_cell_green = self.is_cell_green()
        assert is_cell_green, 'Timeout expired while waiting for green cell'
        return is_cell_green

    def is_cell_green(self):
        return self.get_cell_status_from_site_management_page(cell_status_name='operational_state') == 'enabled'


def change_parameter_value_using_scf(parameter_abbreviation, value):
    """
    Downloads current scf file, changes parameter to given value, performs commissioning and waits till restart finish.
    """
    scf_file = download_current_scf()
    scf.load_scf(scf_file)
    scf.modify_scf_element(value=value,
                           p_name=parameter_abbreviation, index=0)
    scf.save_scf(scf_file)
    perform_commissioning_and_wait_till_oam_ready(scf_file)


def change_parameters_values_using_scf(parameters_list):
    """
    Downloads current scf file, changes parameter to given values, performs commissioning
    and waits till restart finish.
    :param parameters_list: list with elements of dictionary with keys:
        p_name:     parameter_abbreviation
        value:      new value
        dist_name:  optional parameter, in <managedObject> as 'distName', SBTS prefix can be
                    ommited e.g.: both 'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent.
                    None is default value.
        index:      optional parameter, int or str: , should be castable to int.\
                    Should be used if more than one match expected. Indexing starts from 0.
                    0 is default value.
    """
    scf_file = download_current_scf()
    scf.load_scf(scf_file)
    any_param_changed = False
    for parameter in parameters_list:
        p_name = parameter.get("p_name", False)
        value = parameter.get("value", False)
        dist_name = parameter.get("dist_name", None)
        index = parameter.get("index", 0)
        BuiltIn().log(message="Parameter dict: {}".format(parameter))
        if not (p_name or value):
            BuiltIn().log(level='WARN', message="Parameters p_name or value were not given in dict.")
            continue
        old_value = scf.get_value_from_scf(p_name=p_name, dist_name=dist_name, index=index)
        scf.modify_scf_element(value=value, p_name=p_name, dist_name=dist_name, index=0)
        BuiltIn().log(message="Parameter {name} was changed from {old} to {new}.".format(name=p_name,
                                                                                         old=old_value,
                                                                                         new=value))
        if old_value.lower() == value.lower():
            BuiltIn().log(level='WARN',
                          message="Value of parameter {name} is same like you want to change. Value: {val}.".
                          format(name=p_name,
                                 val=old_value))
        else:
            any_param_changed = True
    scf.save_scf(scf_file)
    if any_param_changed:
        perform_commissioning_and_wait_till_oam_ready(scf_file)
    else:
        BuiltIn().log(level='WARN', message="Nothing to change, all params are already set up.")


def perform_commissioning_and_wait_till_oam_ready(scf_path):
    """
    Uploads given scf, makes commissioning and waits till restart finish.
    """
    with WebUIOperations() as webui:
        webui.perform_commissioning(scf_path)
    wait_for_availability_after_restart()


def get_pm_counters(dist_name):
    with WebUIOperations() as webui:
        pmcounters_dict = webui.get_counters_info(dist_name=dist_name)
    return pmcounters_dict


def all_vms_should_be_online():
    """
    Checks if all vms are up.
    """
    with WebUIOperations() as webui:
        vm_statuses = webui.get_vms_availability_statuses()
        for vm, status in vm_statuses.items():
            assert status == "online", "{} vm is not online:\nExpected: online\nBut was: {}".format(vm, status)


def perform_site_reset_and_wait_for_availability_after_restart():
    with WebUIOperations() as webui:
        webui.reset_and_wait_for_site()
    __wait_for_rap()


def wait_for_availability_after_restart():
    """
    Waits for till site is available after restart and rap is up
    """
    from taf.gnb.oam.megazone_client import megazone_client
    web_address = "https://{}/".format(oam_address)
    mz = megazone_client()
    # mz.wait_for_site_unavailability(url=web_address, timeout=120, interval=10)
    mz.wait_for_site_availability(url=web_address, timeout=120, interval=10)
    __wait_for_rap()


@wait_until_function_succeeds(retry_time_in_seconds=600, retry_interval_in_seconds=10)
def __wait_for_rap():
    from taf.gnb.oam.megazone_client import megazone_client
    web_address = "https://{}/".format(oam_address)
    mz = megazone_client()
    mz.wait_for_site_availability(url=web_address, timeout=1200, interval=30)
    with WebUIOperations() as webui:
        webui.wait_for_rap_availability()


def download_current_scf(file_name="scf.xml"):
    """
    Downloads scf from WebUI and returns path to it
    """
    local_dir_path = BuiltIn().get_variable_value("${LOG_PATH}") + '/'
    with WebUIOperations() as webui:
        current_scf = webui.get_current_scf_file(local_dir_path=local_dir_path, file_name=file_name)
    return current_scf


def add_parameter_in_webui_and_activate_it(parameter_dist_name, parameter_name, value):
    param_dictionary = {parameter_name: value}
    with WebUISeleniumOperations() as selenium:
        selenium.add_parameter(parameter_dist_name, parameter_name, param_dictionary, timeout=timeout_for_selenium)
        selenium.validate_changes(timeout=timeout_for_selenium)
        validation_errors = selenium.get_validation_error(timeout=timeout_for_selenium)
        assert not validation_errors, "Following validation errors appears: {}".format(validation_errors)
        selenium.activate_changes(timeout=timeout_for_selenium)
    wait_for_availability_after_restart()


def change_parameter_in_webui_and_activate_it(parameter_dist_name, parameter_abbreviation, value):
    with WebUISeleniumOperations() as selenium:
        selenium.change_text_value(parameter_dist_name, parameter_abbreviation, value, timeout=timeout_for_selenium)
        selenium.validate_changes(timeout=timeout_for_selenium)
        validation_errors = selenium.get_validation_error(timeout=timeout_for_selenium)
        assert not validation_errors, "Following validation errors appears: {}".format(validation_errors)
        selenium.activate_changes()
    wait_for_availability_after_restart()


def change_list_parameter_in_webui_and_activate_it(parameter_dist_name, parameter_abbreviation, value):
    with WebUISeleniumOperations() as selenium:
        selenium.change_list_value(parameter_dist_name, parameter_abbreviation, value, timeout=timeout_for_selenium)
        selenium.validate_changes(timeout=timeout_for_selenium)
        validation_errors = selenium.get_validation_error(timeout=timeout_for_selenium)
        assert not validation_errors, "Following validation errors appears: {}".format(validation_errors)
        selenium.activate_changes()


def modify_online_list_parameters_on_megazone(*args):
    """
    Keyword for changing online list parameters on megazone_clinet. It could be passed with giving
    three strings: dist_name, parameter_abbreviation, value in case of one parameter, or
    list of list of three strings in case of more than one parameters at once.
    :param args: str, str, str or [[str, str, str], [str, str, str], ...]
    """
    is_only_one_parameter = type(args[0]) == str and len(args) == 3
    with WebUISeleniumOperations() as selenium:
        if is_only_one_parameter:
            selenium.change_list_value(args[0], args[1], args[2])
        else:
            for params in args:
                selenium.change_list_value(params[0], params[1], params[2])
        if selenium.get_status_btn_validate():
            selenium.validate_changes()
            validation_errors = selenium.get_validation_error()
            assert not validation_errors, "Following validation errors appears: {}".format(validation_errors)
            selenium.activate_changes()
        else:
            BuiltIn().log(message="Parameters: {} were not activated, maybe they are set.".format(args))


def get_parameter_value_from_webui(parameter_dist_name, parameter_abbreviation, parameter_name):
    with WebUISeleniumOperations() as selenium:
        value = selenium.get_text_parameter_value(
            parameter_dist_name,
            parameter_abbreviation,
            filter_param=parameter_name,
            timeout=timeout_for_selenium)
    return value


def get_parameter_value_from_scf(parameter_abbreviation=None, path=None, parameter_dist_name=None, l_name=None):
    if not path:
        path = download_current_scf()
    scf.load_scf(path)
    if parameter_dist_name is not None:
        return scf.get_value_from_scf(dist_name=parameter_dist_name, list_name=l_name, p_name=parameter_abbreviation)
    return scf.get_value_from_scf(p_name=parameter_abbreviation, list_name=l_name, index=0)


def get_parameters_value_from_scf(parameter_abbreviation=None, path=None, parameter_dist_name=None, l_name=None):
    if not path:
        path = download_current_scf()
    scf.load_scf(path)
    if parameter_dist_name is not None:
        return scf.get_all_values_from_scf(dist_name=parameter_dist_name, list_name=l_name,
                                           p_name=parameter_abbreviation)
    return scf.get_all_values_from_scf(p_name=parameter_abbreviation, list_name=l_name, index=0)


def restart_cell_and_rap_wait_till_cell_is_green():
    with WebUISeleniumOperations() as selenium:
        selenium.lock_cells("Lock")
        selenium.unlock_cells("Unlock")

    with WebUIOperations() as webui:
        webui.rap_reset()
        webui.wait_for_cell_availability()

    with WebUISeleniumOperations() as selenium:
        selenium.wait_for_cell_is_green()


def wait_for_startup_phase(expected_phase=2, interval=5, timeout=1000):
    """
    :param expected_phase: phase which should be reached.
    Currently there are following phases:
        * 1 - Startup ongoing, enabling virtual machines...
        * 2 - Startup ongoing, enabling RAP...
        * 3 - Startup ongoing, enabling radio...
        * 4 - Radio enabled
        * 5 - Name unknown due to lack of documentation regarding OAM REST API
    :param interval:
    :param timeout:
    """
    web_client = WebuiInterface()
    end = time.time() + timeout
    ok = False
    current_phase = None

    while not ok and time.time() < end:
        try:
            web_client.create_session()
            startup_phase = web_client.get_startup_phase()
        except Exception as e:
            print(e)
            time.sleep(interval)
        else:
            current_phase = int(startup_phase['currentPhase'])
            max_phases = int(startup_phase['maxPhases'])
            if max_phases < expected_phase:
                assert 'Expected_phase {} has higher value than max_phases {}'.format(expected_phase, max_phases)
            ok = current_phase >= expected_phase
        finally:
            web_client.teardown_session()
    else:
        assert ok, 'Startup timed out. Expected phase {}, reached phase {}'.format(expected_phase, current_phase)


def x2_link_is_available():
    with WebUIOperations() as webui:
        webui.wait_for_cell_availability()


def make_webui_snapshot(timeout=600):
    log_path = "{path}/{filename}_snapshot.zip".format(path=BuiltIn().get_variable_value("${LOG_PATH}"),
                                                       filename=BuiltIn().get_variable_value("${test_name}"))
    with WebUIOperations() as webui:
        webui.make_snapshot(log_path=log_path, timeout=timeout)


@logged_keyword
def get_cells_number():
    with WebUIOperations() as webui:
        cells = webui.get_local_cells()
        cells = [cell for cell in cells if ('rxAxcResRef' in cell and '#CG#' not in cell['rxAxcResRef']) or
                 ('rxAxcResRef' not in cell)]
        return len(cells)


def lock_and_unlock_all_cells():
    number_of_cells = get_cells_number()
    with WebUIOperations() as webui:
        for cell_nr in range(1, number_of_cells + 1):
            webui.cell_lock(cell_id=cell_nr)

        BuiltIn().sleep('20s', reason='Wait between lock/unlock cells')

        for cell_nr in range(1, number_of_cells + 1):
            webui.cell_unlock(cell_id=cell_nr)


def wait_for_all_cells_on_air_state(timeout=1500.0):
    number_of_cells = get_cells_number()
    with WebUIOperations() as webui:
        for i in range(number_of_cells):
            webui.wait_for_cell_availability(timeout=timeout, cell_number=i+1)


def scf_validation(scf_file='/home/ute/testline_init_results/config_files/SCFC.xml'):
    with WebUIOperations() as webui:
        validation_result = webui.validate_scf(scf_file)
        hw_err = validation_result['pdlValidationResult']['logs']['hardwareErrors']
        rel_err = validation_result['pdlValidationResult']['logs']['relationErrors']
        BuiltIn().log_to_console('\n Hardware Errors: {} \n Relation Errors: {}'.format(len(hw_err), len(rel_err)))


def is_bbmod_ready():
    with WebUIOperations() as webui:
        return webui.get_bts_info()["basebandModules"][0]["status"]["operationalState"]

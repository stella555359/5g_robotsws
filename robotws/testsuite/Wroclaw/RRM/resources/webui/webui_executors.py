import abc
import time
import re
from robot.libraries.BuiltIn import BuiltIn
from taf.gnb.oam.megazone_client import megazone_client
from taf.sbts.oam.coam.admin import admin


class BasicExecutor(object):
    """
    Common interface for cOAM and megazone operations
    """
    __metaclass__ = abc.ABCMeta

    @abc.abstractmethod
    def __init__(self):
        self._api = None

    @abc.abstractmethod
    def create_session(self):
        pass

    @abc.abstractmethod
    def teardown_session(self):
        pass

    @abc.abstractmethod
    def reset_and_wait_for_site(self):
        pass

    @abc.abstractmethod
    def get_frm(self, attribute):
        pass

    @abc.abstractmethod
    def get_bts_info(self, attribute):
        pass

    @abc.abstractmethod
    def get_all_vms_types(self):
        pass

    @abc.abstractmethod
    def get_vm_availability_status(self, **kwargs):
        pass

    @abc.abstractmethod
    def get_vms_availability_statuses(self):
        pass

    @abc.abstractmethod
    def is_cell_in_state(self, **kwargs):
        pass

    @abc.abstractmethod
    def cell_lock(self):
        pass

    @abc.abstractmethod
    def cell_unlock(self):
        pass

    @abc.abstractmethod
    def get_cell_specific_info(self, **kwargs):
        pass

    @abc.abstractmethod
    def get_current_scf_content(self):
        pass

    @abc.abstractmethod
    def get_sw_version(self):
        pass

    @abc.abstractmethod
    def get_sw_release_name(self):
        pass

    @abc.abstractmethod
    def wait_for_rap_availability(self):
        pass

    @abc.abstractmethod
    def get_current_scf_file(self, local_dir_path, file_name):
        pass

    @abc.abstractmethod
    def rap_reset(self):
        pass

    @abc.abstractmethod
    def wait_for_site_availability(self, url, timeout, interval):
        pass

    @abc.abstractmethod
    def wait_for_site_unavailability(self, url, timeout, interval):
        pass

    @abc.abstractmethod
    def get_startup_phase(self):
        pass

    @abc.abstractmethod
    def get_pm_files_list(self):
        pass

    @abc.abstractmethod
    def get_pm_file_content(self, pm_filename):
        pass

    @abc.abstractmethod
    def perform_parameter_recommissioning(self, **kwargs):
        pass

    @abc.abstractmethod
    def perform_object_recommissioning(self, **kwargs):
        pass

    @abc.abstractmethod
    def perform_delta_recommissioning(self, **kwargs):
        pass

    @abc.abstractmethod
    def create_delta(self, **kwargs):
        pass

    @abc.abstractmethod
    def append_managed_object_to_delta(self, **kwargs):
        pass

    @abc.abstractmethod
    def append_list_items_to_delta(self, **kwargs):
        pass

    @abc.abstractmethod
    def get_managed_objects(self, **kwargs):
        pass

    @abc.abstractmethod
    def make_snapshot(self, log_path, timeout):
        pass

    @abc.abstractmethod
    def perform_commissioning(self, scf_path, timeout):
        pass

    @abc.abstractmethod
    def get_counters_info(self, dist_name):
        pass

    @abc.abstractmethod
    def get_local_cells(self):
        pass

    @abc.abstractmethod
    def get_subcells_info(self):
        pass

    @abc.abstractmethod
    def validate_scf(self, scf_file):
        pass

    @abc.abstractmethod
    def get_active_alarms(self):
        pass


class MegazoneExecutor(BasicExecutor):

    def __init__(self):
        super(MegazoneExecutor, self).__init__()
        self._api = megazone_client()
        self.oam_address = BuiltIn().get_variable_value("${tl.gnbs[0].cu.oam_ssh_connection_details.addr}")

    def create_session(self):
        is_IPv6 = re.search('^([0-9a-fA-F]{0,4}:+[0-9a-fA-F]{0,4}){1,9}', self.oam_address)
        if is_IPv6:
            self._api.create_session("https://[{}]/".format(self.oam_address))
        else:
            self._api.create_session("https://{}/".format(self.oam_address))

    def teardown_session(self):
        self._api.teardown_session()

    def reset_and_wait_for_site(self):
        self._api.reset_and_wait_for_site()

    def get_frm(self, attribute):
        return self._api.get_frm(attribute=attribute)

    def get_bts_info(self, attribute):
        return self._api.get_bts_info(attribute=attribute)

    def get_all_vms_types(self):
        return self._api.get_all_vms_types()

    def get_vm_availability_status(self, **kwargs):
        return self._api.get_vm_availability_status(**kwargs)

    def get_vms_availability_statuses(self):
        return self._api.get_vms_availability_statuses()

    def is_cell_in_state(self, **kwargs):
        return self._api.is_cell_in_state(**kwargs)

    def cell_lock(self, **kwargs):
        return self._api.cell_lock(**kwargs)

    def cell_unlock(self, **kwargs):
        return self._api.cell_unlock(**kwargs)

    def get_cell_specific_info(self, **kwargs):
        return self._api.get_cell_specific_info(**kwargs)

    def get_current_scf_content(self):
        return self._api.get_current_scf_content()

    def get_sw_version(self):
        return self._api.get_sw_version()

    def get_sw_release_name(self):
        return self._api.get_cbts_sw_release_name()

    def wait_for_rap_availability(self):
        return self._api.wait_for_rap_availability()

    def get_current_scf_file(self, local_dir_path, file_name):
        return self._api.get_current_scf_file(local_dir_path=local_dir_path, file_name=file_name)

    def rap_reset(self, **kwargs):
        return self._api.rap_reset(**kwargs)

    def wait_for_site_availability(self, url, timeout, interval):
        return self._api.wait_for_site_availability(url, timeout, interval)

    def wait_for_site_unavailability(self, url, timeout, interval):
        return self._api.wait_for_site_unavailability(url, timeout, interval)

    def get_startup_phase(self):
        return self._api.get_startup_phase()

    def get_pm_files_list(self):
        return self._api.get_pm_files_list()

    def get_pm_file_content(self, pm_filename):
        return self._api.get_pm_file_content(pm_filename=pm_filename)

    def perform_parameter_recommissioning(self, **kwargs):
        return NotImplementedError

    def perform_object_recommissioning(self, **kwargs):
        return NotImplementedError

    def perform_delta_recommissioning(self, **kwargs):
        return NotImplementedError

    def create_delta(self, **kwargs):
        return NotImplementedError

    def append_managed_object_to_delta(self, **kwargs):
        return NotImplementedError

    def get_managed_objects(self, **kwargs):
        return NotImplementedError

    def append_list_items_to_delta(self, **kwargs):
        return NotImplementedError

    def make_snapshot(self, log_path, timeout):
        self._api.make_snapshot(snapshot_path=log_path, timeout=timeout)

    def perform_commissioning(self, scf_path, timeout=600):
        return self._api.perform_commissioning(scf_path, timeout=timeout)

    def get_counters_info(self, dist_name):
        raise NotImplementedError

    def get_local_cells(self):
        return self._api.get_local_cells()

    def get_subcells_info(self):
        return self._api.get_subcells()

    def validate_scf(self, scf_file):
        raise NotImplementedError

    def get_active_alarms(self):
        raise NotImplementedError


class COAMExecutor(BasicExecutor):

    def __init__(self):
        super(COAMExecutor, self).__init__()
        self._api = admin()
        self.__connection = None

    def create_session(self, **kwargs):
        self.__connection = self._api.connect_to()

    def teardown_session(self):
        self._api.teardown()

    def reset_and_wait_for_site(self):
        self._api.reset_site(timeout=600)

    def get_frm(self, attribute):
        try:
            frm = self._api.get_frm()[0]
        except IndexError:
            raise Exception("No radio unit detected by webUI.")
        if attribute in ['availabilityStatus', 'operationalState']:
            return frm['status'][attribute].lower()
        if attribute:
            return list(find(attribute, frm))
        return frm

    def get_bts_info(self, attribute=None):
        megazone_to_coam_attributes = {'id': 'mrbtsID'}
        bts_info = self._api.get_bts_info()
        if attribute and attribute in megazone_to_coam_attributes:
            return bts_info[megazone_to_coam_attributes[attribute]]
        return bts_info

    def get_all_vms_types(self):
        raise NotImplementedError

    def get_vm_availability_status(self, **kwargs):
        return 'online'.encode("utf-8")

    def get_vms_availability_statuses(self):
        raise NotImplementedError

    def is_cell_in_state(self, state, number=1):
        if state:
            return state.lower() == self.get_cell_specific_info(attribute='availabilityStatus', cell_number=number)
        else:
            return state == self.get_cell_specific_info(attribute='availabilityStatus', cell_number=number)

    def cell_lock(self, cell_id=1, **kwargs):
        dist_name = 'MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(BuiltIn().get_variable_value('${tl.gnbs[0].instance_id}'),
                                                         BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}'),
                                                         cell_id)
        self.perform_parameter_recommissioning(dist_name=dist_name,
                                               parameter='administrativeState',
                                               operation='update',
                                               value='Locked')

    def cell_unlock(self, cell_id=1, **kwargs):
        dist_name = 'MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(BuiltIn().get_variable_value('${tl.gnbs[0].instance_id}'),
                                                         BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}'),
                                                         cell_id)
        self.perform_parameter_recommissioning(dist_name=dist_name,
                                               parameter='administrativeState',
                                               operation='update',
                                               value='Unlocked')

    def get_cell_specific_info(self, attribute, cell_number=1):
        cell_specific_info = self._api.get_cells_info()[int(cell_number) - 1]['status'].get(attribute)
        if cell_specific_info:
            return cell_specific_info.lower()
        else:
            return cell_specific_info

    def get_current_scf_content(self):
        return self._api.get_current_scf_content()

    def get_sw_version(self):
        return self._api.get_sw_version()

    def get_sw_release_name(self):
        return self._api.get_sw_release_name()

    def wait_for_rap_availability(self, timeout=600.0, interval=2.0):
        end = time.time() + float(timeout)
        is_online = self._api.get_bts_info(timeout=30)[
                        "radioModules"]["rmod"][0]["status"].get("availabilityStatus") in ['Online', None]
        while not is_online:
            BuiltIn().sleep(interval, 'Waiting for rap availability')
            is_online = self._api.get_bts_info(timeout=30)[
                            "radioModules"]["rmod"][0]["status"].get("availabilityStatus") in ['Online', None]
            if end < time.time():
                raise Exception("Timeout exceeded")
        return is_online

    def get_current_scf_file(self, local_dir_path, file_name):
        return self._api.get_current_scf_file(local_dir_path=local_dir_path, file_name=file_name, timeout=30)

    def rap_reset(self, **kwargs):
        raise NotImplementedError

    def wait_for_site_availability(self, url, timeout, interval):
        mz_api = megazone_client()
        return mz_api.wait_for_site_availability(url, timeout, interval)

    def wait_for_site_unavailability(self, url, timeout, interval):
        mz_api = megazone_client()
        return mz_api.wait_for_site_unavailability(url, timeout, interval)

    def get_startup_phase(self):
        raise NotImplementedError

    def get_pm_files_list(self):
        raise NotImplementedError

    def get_pm_file_content(self, pm_filename):
        raise NotImplementedError

    def perform_parameter_recommissioning(self, **kwargs):
        return self._api.perform_parameter_recommissioning(**kwargs)

    def perform_object_recommissioning(self, **kwargs):
        return self._api.perform_object_recommissioning(**kwargs)

    def perform_delta_recommissioning(self, **kwargs):
        return self._api.perform_delta_recommissioning(**kwargs)

    def create_delta(self, **kwargs):
        return self._api.create_delta(**kwargs)

    def append_managed_object_to_delta(self, **kwargs):
        return self._api.append_managed_object_to_delta(**kwargs)

    def append_list_items_to_delta(self, **kwargs):
        return self._api.append_list_items_to_delta(**kwargs)

    def get_managed_objects(self, **kwargs):
        return self._api.get_managed_objects(**kwargs)

    def make_snapshot(self, log_path, timeout):
        self._api.get_snapshot(target_file_name=log_path, timeout=timeout)

    def perform_commissioning(self, scf_path, oam_ip=None, timeout=600):
        return self._api.perform_commissioning(scf_path, skip_parameter_relation_errors=True, timeout=timeout)

    def get_counters_info(self, dist_name):
        return self._api.get_counters_info(dist_name=dist_name, timeout=300)

    def get_local_cells(self):
        return self._api.get_cells_info()

    def get_subcells_info(self):
        return self._api.get_subcells_info()

    def validate_scf(self, scf_file):
        return self._api.validate_scf(scf_file)

    def get_active_alarms(self):
        return self._api.get_active_alarms()


def find(key, dictionary):
    for k, v in dictionary.iteritems():
        if k == key:
            yield v
        elif isinstance(v, dict):
            for result in find(key, v):
                yield result
        elif isinstance(v, list):
            for d in v:
                for result in find(key, d):
                    yield result

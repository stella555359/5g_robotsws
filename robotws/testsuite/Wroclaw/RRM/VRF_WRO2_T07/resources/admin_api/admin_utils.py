from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword, wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
import os
import random

retry_timeout_seconds = 1800
assert_msg = '\n'.join(['{message}', 'Expected: {expected}', 'But was: {current}'])


class AdminUtils(object):
    def __init__(self, bts_host='192.168.255.129'):
        self.bts_host = bts_host

    @logged_keyword
    @wait_until_function_succeeds(retry_time_in_seconds=retry_timeout_seconds, retry_interval_in_seconds=10)
    def wait_for_all_cells_on_air_state(self, cell_type='nr'):
        with AdminApi(bts_host=self.bts_host) as web_api:
            cells = web_api.get_cells_info(cell_type=cell_type)
            assert len(cells), 'Cells not detected'
            for cell in cells:
                assert cell['status'].get('availabilityStatus') in \
                    ['Online', None, 'Degraded', 'degraded'], assert_msg.format(
                    message='Not all cells are online.',
                    expected='availabilityStatus: Online (or None),',
                    current=cell['status'].get('availabilityStatus')).replace('\n', '  ')

    @logged_keyword
    @wait_until_function_succeeds(retry_time_in_seconds=retry_timeout_seconds, retry_interval_in_seconds=10)
    def wait_for_cell_availability(self, cell_number):
        with AdminApi(bts_host=self.bts_host) as web_api:
            cells = web_api.get_cells_info()
            assert len(cells), 'Cells not detected'
            relevant_cell = cells[cell_number]
            assert relevant_cell['status'].get('availabilityStatus') in \
                   ['Online', None, 'Degraded', 'degraded'], assert_msg.format(
                message='The cell is not available.',
                expected='availabilityStatus: Online (or None),',
                current=relevant_cell['status'].get('availabilityStatus')).replace('\n', '  ')

    @logged_keyword
    def download_current_scf(self, local_dir_path=None, file_name='scf.xml'):
        with AdminApi(bts_host=self.bts_host) as web_api:
            local_dir_path = local_dir_path if local_dir_path else robot_globals.outputdir()
            current_scf = web_api.get_current_scf_file(local_dir_path=local_dir_path, file_name=file_name, timeout=60)
            return current_scf

    @logged_keyword
    def perform_commissioning(self, bts_id=None, scf_file=None, skip_parameter_relation_errors=False):
        bts_id = self.get_bts_ids()[0] if not bts_id else bts_id
        with AdminApi(bts_host=self.bts_host) as web_api:
            web_api.perform_commissioning(bts_id=bts_id, scf_file=scf_file,
                                          skip_parameter_relation_errors=skip_parameter_relation_errors, timeout=600)

    @logged_keyword
    @wait_until_function_succeeds(retry_time_in_seconds=retry_timeout_seconds, retry_interval_in_seconds=10)
    def trigger_site_reset_and_wait_for_onair(self):
        self.trigger_site_reset()
        self.wait_for_all_cells_on_air_state()

    @logged_keyword
    def trigger_site_reset(self):
        with AdminApi(bts_host=self.bts_host) as web_api:
            web_api.reset_site()

    @logged_keyword
    def collect_snapshot(self, filename=None, timeout=360):
        blog('Start snapshot collection...')
        filename = os.path.join(robot_globals.outputdir(), 'snapshot.tar.gz') if filename is None else filename
        with AdminApi(bts_host=self.bts_host) as web_api:
            web_api.collect_snapshot(filename, force=True, timeout=timeout)
        blog('Snapshot collection finished successfully!')

    @logged_keyword
    def lock_cells(self, cell_list=[], timeout=120, cells_type='NRCEL', dist_name_list=None):
        if dist_name_list:
            cell_list = dist_name_list
            blog('AdminUtils: dist_name_list argument is deprecated. Use cell_list instead.')

        cell_list = [self.cell_id_to_dist_name(value, cells_type) if value.isdigit() else value for value in cell_list]
        id_list = [self.dist_name_to_cell_id(value) for value in cell_list]

        with AdminApi(bts_host=self.bts_host) as web_api:
            blog(f'Locking {cells_type}s: {id_list}')
            response = web_api.lock(dist_name=cell_list, timeout=timeout)
            assert 'completed' in response, 'Error: Unable to lock some of the cells.'

    @logged_keyword
    def unlock_cells(self, cell_list=[], timeout=120, cells_type='NRCEL', dist_name_list=None):
        if dist_name_list:
            cell_list = dist_name_list
            blog('AdminUtils: dist_name_list argument is deprecated. Use cell_list instead.')

        cell_list = [self.cell_id_to_dist_name(value, cells_type) if value.isdigit() else value for value in cell_list]
        id_list = [self.dist_name_to_cell_id(value) for value in cell_list]

        with AdminApi(bts_host=self.bts_host) as web_api:
            response = web_api.unlock(dist_name=cell_list, timeout=timeout)
            blog(f'Unlocking {cells_type}s: {id_list}')
            assert 'completed' in response, 'Error: Unable to unlock some of the cells.'

    def lock_cell_by_id(self, cell_id, cells_type='NRCEL'):
        blog(f'AdminUtils: lock_cell_by_id() is deprecated. Use lock_cells() instead.')
        self.lock_cells([cell_id], cells_type=cells_type)

    @logged_keyword
    def unlock_all_cells(self, cells_type='NRCEL', timeout=120):
        dist_name_list = self.get_cells_dist_names(cells_type=cells_type)
        self.unlock_cells(dist_name_list, timeout)

    @logged_keyword
    def lock_all_cells(self, cells_type='NRCEL', timeout=120):
        dist_name_list = self.get_cells_dist_names(cells_type=cells_type)
        self.lock_cells(dist_name_list, timeout)

    @logged_keyword
    def lock_all_cells_except_random_one(self, cells_type='NRCEL'):
        dist_name_list = self.get_cells_dist_names(cells_type=cells_type)
        random_cell_dist_name = random.choice(dist_name_list)
        dist_name_list.remove(random_cell_dist_name)
        self.lock_cells(cell_list=dist_name_list)
        blog(level='WARN', message=f'WARNING: All cells except for: {random_cell_dist_name} will be LOCKED!')
        return random_cell_dist_name

    @logged_keyword
    def lock_all_cells_except_chosen_one(self, chosen_cell_id, cells_type='NRCEL'):
        cell_dist_names = self.get_cells_dist_names(cells_type=cells_type)
        cell_to_remove = None

        for cell in cell_dist_names:
            if cell.split('-')[-1] == str(chosen_cell_id):
                cell_to_remove = cell

        if not cell_to_remove:
            raise Exception('Invalid cell id entered or it doesn\'t exist.')

        cell_dist_names.remove(cell_to_remove)
        self.lock_cells(cell_list=cell_dist_names)
        blog(level='WARN', message=f'WARNING: All cells except for: {cell_to_remove} will be LOCKED!')

    @logged_keyword
    def lock_all_cells_except_chosen_x(self, cell_list=[], cells_type='NRCEL'):
        cell_dist_names = self.get_cells_dist_names(cells_type=cells_type)
        cells_to_remove = [cell for cell in cell_dist_names if cell.split('-')[-1] in map(str, cell_list)]

        if not cells_to_remove:
            raise Exception('Invalid cell ids entered or they don\'t exist.')

        for cell in cells_to_remove:
            cell_dist_names.remove(cell)

        self.lock_cells(cell_list=cell_dist_names)
        blog(level='WARN', message=f'WARNING: All cells except for: {cells_to_remove} will be LOCKED!')

    @logged_keyword
    def get_cells_dist_names(self, cells_type='NRCEL'):
        with AdminApi(bts_host=self.bts_host) as web_api:
            return web_api.get_ids_for_all(class_name=cells_type)

    def get_cell_dist_name_by_nr_cell_id_param(self, cell_id=None):
        blog("AdminUtils: get_cell_dist_name_by_nr_cell_id_param() is deprecated. Use cell_id_to_dist_name() instead.")
        return self.cell_id_to_dist_name(cell_id)

    @logged_keyword
    def cell_id_to_dist_name(self, cell_id=None, cells_type='NRCEL'):
        cell_dist_names = self.get_cells_dist_names(cells_type=cells_type)
        try:
            return [cell for cell in cell_dist_names if cell.split('-')[-1] == cell_id][0]
        except Exception as e:
            e.args = ('Invalid cell id entered or it doesn\'t exist.',)
            raise e

    @logged_keyword
    def dist_name_to_cell_id(self, dist_name=None):
        return dist_name.split('-')[-1]

    @logged_keyword
    def get_rmod_id_by_nr_cell_dist_name(self, cell_dist_name):
        with AdminApi(bts_host=self.bts_host) as web_api:
            rmod_id = web_api.get_cell_specific_info(cell_dist_name)[
                 'carrierList'][0]['antennaLineId']['configuration'].split('/')[-2][-1]
            return rmod_id

    @logged_keyword
    def get_antl_distnames_by_nr_cell_dist_name(self, cell_dist_name):
        with AdminApi(bts_host=self.bts_host) as web_api:
            antls = []
            for channel in web_api.get_cell_specific_info(cell_dist_name)['carrierList']:
                antls.append(channel['antennaLineId']['internal'])
                antls = list(set(antls))
            return antls

    @logged_keyword
    def get_rmod_ip_by_rmod_id(self, rmod_id):
        with AdminApi(bts_host=self.bts_host) as web_api:
            rmods_list = web_api.get_all_items_by_class_name('RMOD')
            try:
                rmod_id = 'RMOD_R-' + rmod_id
                return [rmod['ipAddress'] for rmod in rmods_list if rmod['name'] == rmod_id][0]
            except Exception as e:
                e.args = ('Invalid rmod id entered or it doesn\'t exist.',)
                raise e

    @logged_keyword
    def get_rmod_models_mapping_by_rmod_id(self):
        with AdminApi(bts_host=self.bts_host) as web_api:
            bts_info = web_api.get_bts_info()
            try:
                rmod_ids = [rmod_info['id']['configuration'][-1] for rmod_info in bts_info['radioModules']['rmod']]
                rmod_models = [rmod_info['productName'] for rmod_info in bts_info['radioModules']['rmod']]
                rmod_mapping = dict(zip(rmod_ids, rmod_models))
                return rmod_mapping
            except Exception as e:
                e.args = ('RMODs models mapping failed.',)
                raise e

    @logged_keyword
    def get_all_cell_ids(self, cell_type='nr'):
        with AdminApi(bts_host=self.bts_host) as web_api:
            results = web_api.get_cells_info(cell_type=cell_type)
            return [cell['globalCellId'] for cell in results]

    @logged_keyword
    def get_subcells_info(self):
        with AdminApi(bts_host=self.bts_host) as web_api:
            cells_info = web_api.get_subcells_info()
        return cells_info

    @logged_keyword
    def get_active_alarms(self, severity=None, timeout=10):
        with AdminApi(bts_host=self.bts_host) as web_api:
            alarms = web_api.get_active_alarms(severity=severity, timeout=timeout)
            blog(f'Detected active alarms: {alarms}')
            return alarms

    @wait_until_function_succeeds(retry_time_in_seconds=retry_timeout_seconds, retry_interval_in_seconds=1)
    @logged_keyword
    def wait_for_all_bbmods_online_state(self):
        assert self.check_if_all_bbmods_are_ready(), 'Not all BBMODs are operational'

    @logged_keyword
    def check_if_all_bbmods_are_ready(self):
        with AdminApi(bts_host=self.bts_host) as web_api:
            bbmod_infos = web_api.get_detected_hw_info()['basebandModules']
            return all(self.is_bbmod_ready(bbmod) for bbmod in bbmod_infos)

    @logged_keyword
    def is_bbmod_ready(self, bbmod):
        return bbmod['status'].get('availabilityStatus') in ['Online', None]

    @logged_keyword
    def get_active_sw(self):
        with AdminApi(bts_host=self.bts_host) as web_api:
            active_sw_version = web_api.get_sw_version()
        if active_sw_version.split("_", 3)[2] == "9999" or active_sw_version.split("_", 3)[2] == "9990":
            active_sw_version = "_".join(["SBTS00", active_sw_version.split("_", 1)[1]])
        if "5G" in active_sw_version.split("_", 1)[0]:
            release = active_sw_version.split("_", 1)[0]
            build_number = ".".join([_.lstrip("0") for _ in active_sw_version.split("_")[2::]])
            active_sw_version = "_".join([release, build_number])
        return active_sw_version

    @logged_keyword
    def get_bts_ids(self):
        mrbts_id = tl.gnbs[0].global_bts_id
        nrbts_id = tl.gnbs[0].instance_id
        if nrbts_id is None:
            with AdminApi(bts_host=self.bts_host) as web_api:
                nrbts = web_api.get_id_for_current('NRBTS').split('/')
                nrbts_id = nrbts[-1].split('-')[-1]
        return mrbts_id, nrbts_id

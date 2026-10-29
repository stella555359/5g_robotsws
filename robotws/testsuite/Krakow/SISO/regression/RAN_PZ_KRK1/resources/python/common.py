import re
import os
import logging
import copy
from pathlib import Path
from datetime import datetime, timedelta
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns
from taf.rfrl.bts.devices.generic_bts import login_logout_GUI, login_logout
from taf.rfrl.procedures.resources.python.wft.remote_api import BuildEndpoint
from taf.rfrl.procedures.resources.python.sw_update.SW_update import SW_update
from taf.rfrl.utilities.transfer_files import download_files
from taf.rfrl.utilities.tl_config import get_testline_name
from taf.rfrl.utilities.test_config import get_log_path, DefaultFileLocation
from exceptions import RUValidationError, SWDowloadError, RuResetNotExecuted, AlarmNotTriggered, WrongCellTriggered


def prepare_cells_setup_for_tput(ru_map):
    """
    Prepare list of cells containing tput/cell, ID of RU and ports to set on matrix.
    Author/Contact: agnieszka.bylica@nokia.com
    :param ru_map: dictionary with RU/cells and tputs value
    :return: list of items in format:
        {
        'ru_id': None,
        'active_cell': {'id': None,
                        'ports': None,
                        'exp_dl_tput': None,
                        'exp_ul_tput': None},
        'cells_to_block': []
    }
    """
    from copy import deepcopy
    cells_setup_list = []
    common_dict_item = {
        'ru_id': None,
        'active_cell': {'id': None,
                        'ports': None,
                        'exp_dl_tput': None,
                        'exp_ul_tput': None},
        'cells_to_block': []
    }

    for ru in ru_map:
        cells_setup_list_for_ru = []
        ru_cells_ids = [cell['cell_id'] for cell in ru['cells']]
        for cell in ru['cells']:
            cell_info = deepcopy(common_dict_item)
            cell_info['ru_id'] = ru['ru_id']
            cell_info['active_cell']['id'] = cell['cell_id']
            cell_info['active_cell']['exp_dl_tput'] = cell['exp_dl_tput']
            cell_info['active_cell']['exp_ul_tput'] = cell['exp_ul_tput']
            ports = cell['ant_ids'] if ru['ant_ids'] is None else ru['ant_ids']
            cell_info['active_cell']['ports'] = ':'.join(str(port) for port in ports)
            cells_to_block = deepcopy(ru_cells_ids)
            cells_to_block.remove(cell['cell_id'])
            cell_info['cells_to_block'] = cells_to_block
            cells_setup_list_for_ru.append(cell_info)
        cells_setup_list.extend(cells_setup_list_for_ru)
    return cells_setup_list


def prepare_distname_for_qRxLevMin(bts_id=0):
    return GnbRuOperations().adjust_dist_name(dist_name='{}/NRCELL-'.format(GnbDistNamePatterns().bts_dist_name),
                                              bts_id=bts_id)


def check_number_of_rus(cells_setup_list):
    ru = GnbRuOperations()
    rus_info = ru.get_all_radio_unit_info(skip_ru_if_not_configured=True)
    ru_number_from_bts = len(rus_info)
    rus_ids = set([cell_setup['ru_id'] for cell_setup in cells_setup_list])
    ru_no_from_csl = len(rus_ids)
    if ru_no_from_csl != ru_number_from_bts:
        raise RUValidationError(
            'Number of RU from BTS and from ru_matrix is not equal'
        )
    return [str(id) for id in rus_ids]


def get_previous_regression_released_soft(curr_sw):
    """
    Function to get proper previous regression release software.

    :param curr_sw: Name of current software,
    Return: Previous released software name.
    """
    curr_branch = re.split('_', str(curr_sw))[0]
    wft_query = f'&view[columns[][id]]=deliverer.project.full_path' \
                f'&view[columns[][id]]=deliverer.title' \
                f'&view[columns[][id]]=version' \
                f'&view[columns[][id]]=branch.title' \
                f'&view[columns[][id]]=promotion_status'
    wft_answer = BuildEndpoint(project='SBTS', component='CI_ENB', version='').get_specific_query(wft_query)
    return [d['version'] for d in wft_answer if d['branch.title'] == curr_branch and d['promotion_status']][0]


def download_sw_package(sw_to_download, builds_dir=None):
    """
    Function is download proper software to specific directory,

    :param sw_to_download: Name of software to download,
    :param builds_dir: Name of software to download,
    :return: path to downloaded software.
    """
    def _get_sw_path_if_already_downloaded(download_dir, sw_name):
        sw_regex = re.compile(r'{}_release_BTSSM_downloadable.*\.zip'.format(sw_name))
        for root, dirs, files in os.walk(download_dir):
            for file_name in files:
                if file_name and sw_regex.match(file_name):
                    return os.path.join(root, file_name)
        return False

    target_dir = '/home/ute/.ute-ca/cache/bts' if not builds_dir else builds_dir
    sw_package_path = os.path.join(target_dir, sw_to_download)

    downloaded_sw_path = _get_sw_path_if_already_downloaded(download_dir=target_dir, sw_name=sw_to_download)
    if downloaded_sw_path:
        logging.info(f'SW already in directory {downloaded_sw_path}')
        return downloaded_sw_path
    else:
        sw = SW_update()
        logging.info(f'Downloading SW {sw_to_download}')
        try:
            if not os.path.exists(sw_package_path):
                Path(sw_package_path).mkdir(parents=True)
            already_downloaded_sw_path = sw.download_software(sw_package_path, sw_to_download)
        except Exception as err:
            logging.info('SW download failed')
            raise SWDowloadError(err)

        return already_downloaded_sw_path


def verify_all_cells_statuses_from_given_locked_ru(ru_id, bts_id=0, du_id=0):
    def convert_cell_ids_from_distname(cell_distname_list):
        cell_ids = []
        for cell_distname in cell_distname_list:
            match = re.search(r"NRCELL-(\d+)", cell_distname)
            cell_ids.append(int(match.group(1)))
        return cell_ids

    cell = GnbCellOperations()
    shared_cells = cell.get_cells_shared_on_more_than_one_ru(bts_id=bts_id, du_id=du_id)
    shared_cells_id = convert_cell_ids_from_distname(shared_cells)
    ru_cell_ids = cell.get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, radio_id=ru_id)
    for cell_id in ru_cell_ids:
        logging.debug(cell_id)
        if cell_id in shared_cells_id:
            cell.verify_cell_statuses(cell_id=cell_id, bts_id=bts_id, du_id=du_id,
                                      availability_status="degraded",
                                      operational_state="enabled",
                                      administrative_state="Unlocked")
        else:
            cell.verify_cell_statuses(cell_id=cell_id, bts_id=bts_id, du_id=du_id,
                                      availability_status="dependency",
                                      operational_state="disabled",
                                      administrative_state="Unlocked")


def verify_cell_mapping(bts_id=0, du_id=0):
    """
    Verify if all configured cells are present in the /ram/NrCellMappingInfo.txt
    """
    cell = GnbCellOperations()
    configured_cells_ids = cell.get_all_global_cell_ids()

    logs_path = get_log_path()
    logging.debug(f'Logs path: {logs_path}')
    download_files(local_dir=logs_path,
                   remote_file='NrCellMappingInfo.txt',
                   device_name=cell.ssh_alias.format(bts_id, du_id),
                   remote_dir='/ram/')
    mapping_file_path = Path(logs_path, 'NrCellMappingInfo.txt')
    logging.debug(f'Mapping file path: {mapping_file_path}')
    cells_from_mapping = _get_cells_ids_from_mapping_file(mapping_file_path)
    cells_not_in_mapping = [cell_id for cell_id in configured_cells_ids if cell_id not in cells_from_mapping]
    if cells_not_in_mapping:
        raise ValueError(f"Some cells' ids haven't been found in the NrCellMappingInfo.txt: {cells_not_in_mapping}")
    logging.info(f'All configured cells are in the mapping file: {cells_from_mapping}')


def _get_cells_ids_from_mapping_file(file_path):
    table_found = False
    cells_ids = list()
    with open(file_path, 'r') as mapping_file:
        for line in mapping_file:
            if re.match(r'NRCELL\s+', line):
                table_found = True
            if table_found:
                matched = re.match(r'(?P<CELL_ID>\d+)\s+\d+', line)
                if matched:
                    logging.debug(f'matched line: {line}')
                    cells_ids.append(int(matched.group('CELL_ID')))
    logging.debug(f'Cells IDs from matched lines: {cells_ids}')
    return cells_ids


def verify_param_can_be_set_but_not_activated(dist_name, parameter, value, bts_id=0, du_id=0):
    gnb = GnbDuOperations()
    gnb_scf = GnbCommissioning()
    gui_alias = gnb.gui_alias.format(bts_id, du_id)

    def _get_parameter_value(self, bts_id=0, du_id=0):
        param_value = self.gui_coam.get_parameter_value(
            dist_name=self.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id),
            filter_param=parameter, sbts=gui_alias)
        logging.info(f'Currently {parameter}={param_value}')
        return param_value

    parameter_value = login_logout_GUI(_get_parameter_value)(gnb, bts_id=bts_id, du_id=du_id)

    gnb_scf.verify_if_parameter_changed_to_incorrect_value_via_gui(
        dist_name=gnb.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id),
        parameter=parameter,
        value=value)
    logging.info(f'Changing {parameter} to incorrect value: {value} finished. Refreshing page...')
    gnb.gui_coam.refresh_page(sbts=gui_alias)
    gnb_scf.verify_parameter_after_change(dist_name=dist_name, parameter=parameter, value=parameter_value)
    logging.info(f'Currently {parameter}={parameter_value}')


def save_current_time():
    current_time = datetime.now()
    logging.info(f'Current time: {current_time}')
    logging.info(f'Current time type: {type(current_time)}')
    return current_time


def verify_ru_uptime(ru_id, start_time, bts_id=0, du_id=0):
    ru = GnbRuOperations()
    ru_info = ru._get_ru_info_via_gui(ru_id=ru_id)
    logging.debug(f'RU-{ru_id} info: {ru_info}')
    current_time = datetime.now()
    time_delta = current_time - start_time
    logging.info(f'Time delta between stop ({current_time}) and start ({start_time}): {time_delta}')
    match_obj = re.search(r'(?P<DAY>\d+)d\s+(?P<HOUR>\d+)h\s+(?P<MIN>\d+)m\s+(?P<SEC>\d+)s', ru_info['Uptime'])
    uptime_values = match_obj.groupdict()
    uptime = timedelta(days=int(uptime_values['DAY']), hours=int(uptime_values['HOUR']),
                       minutes=int(uptime_values['MIN']), seconds=int(uptime_values['SEC']))
    if uptime > time_delta:
        raise RuResetNotExecuted(f'Uptime {uptime} of the RU-{ru_id} is greater than the time delta {time_delta}')
    logging.info(f'Uptime {uptime} of the RU-{ru_id} is smaller than the time delta {time_delta}.'
                 f'Reboot successfully performed.')


def check_alarms_and_affected_cells(fid=None, affected_cells=['all'], bts_id=0, du_id=0):
    """
    Check if alarm is present at BTS and verify it affects correct cells
    :param fid:             FID of alarm
    :param affected_cells:  list of cells that should be affected by alarm
    :param bts_id:          BTS id
    :param du_id:           DU id
    """
    gnb = GnbDuOperations()

    def _get_alarms(self, bts_id=0, du_id=0):
        alias = gnb.rest_alias.format(bts_id, du_id)
        active_alarms = self.admin.get_active_alarms(connection=alias)
        logging.debug(f'Currently active alarms={active_alarms}')
        return active_alarms

    alarms = login_logout(_get_alarms)(gnb, bts_id=bts_id, du_id=du_id)

    if fid:
        for alarm in alarms:
            if alarm['faultId'] == int(fid):
                logging.debug(f'FID:{fid} has been found')
                alarm_cells = _get_affected_cells(alarm)
                logging.debug(f'Affected cells ({fid}): {alarm_cells}')
                _check_cells(alarm_cells, affected_cells)
                return alarm_cells
        raise AlarmNotTriggered(f'FID:{fid} not present')


def _get_affected_cells(full_alarm_message):
    for x in full_alarm_message['alarmAttribute']:
        if x['attributeName'] == 'faulty_cells':
            logging.info(x)
            alarm_cells = x['attributeValue'].split(':')[1]
            alarm_cells = alarm_cells.split(',')
            return alarm_cells


def _check_cells(cells, desired_cells):
    for cell in cells:
        if int(cell) not in desired_cells:
            raise WrongCellTriggered(f'Cell {cell} wrongly triggered')


def load_variables_for_configuration(prefix_tag):
    """
        Load variables from a Python file located in configuration directory
            robotws/testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/resources/variables/<TL_NAME>/<BRANCH>(Optional)
        Author/Contact: agnieszka.bylica@nokia.com
        :param prefix_tag: name of the file without the extension
        """
    def check_if_variable_file_exists(directory, base_name):
        """
        Check if the variable file exists in the expected directories.
        :param directory: Directory to check for the variable file. pathlib.Path object.
        :param prefix_tag: Prefix tag to match the variable file.
        """
        variable_file_name = f'{base_name}.py'
        logging.debug(f"Checking if variable file {variable_file_name} exists in the {directory} directory:")

        if directory.exists():
            for file_path in directory.iterdir():
                if file_path.match(variable_file_name):
                    return file_path
        logging.debug(f"Variable file {variable_file_name} not found in the {directory} directory.")

    cur_dir = Path(__file__).parent.resolve()
    base_variable_dir = cur_dir.joinpath('../variables').resolve()
    branch = DefaultFileLocation().get_commissioning_branch()
    branch = 'SBTS00' if branch == 'TRUNK' else branch
    testline_name = get_testline_name()

    testline_dir = base_variable_dir.joinpath(testline_name)
    branch_dir = testline_dir.joinpath(branch)

    variable_file = check_if_variable_file_exists(branch_dir, prefix_tag)
    if not variable_file:
        variable_file = check_if_variable_file_exists(testline_dir, prefix_tag)

    if not variable_file:
        raise ValueError(f'No variable file for prefix_tag={prefix_tag} found in {branch_dir} or {testline_dir}')

    logging.info(f'Importing variables from: {variable_file}')
    BuiltIn().import_variables(variable_file)


def prepare_delta_reconfiguring_dl_mimo_mode(operation, delta_dlmimomode_template,
                                             nrcellids_to_reconfiguring_dlmimomode):
    """
    Prepares a delta configuration for enabling or disabling 8x4 Downlink MIMO mode on specified cells.
    Author/Contact: radoslaw.serafin@nokia.com
    :param operation: Either 'enable' or 'disable', specifying the desired operation.
    :param delta_dlmimomode_template: A dictionary containing templates for enabling and disabling 8x4 DL MIMO.
        Expected keys are 'delta_activate_dl_mimo_8x4' and 'delta_deactivate_dl_mimo_8x4'
    :param nrcellids_to_reconfiguring_dlmimomode: A list of strings representing the IDs of the cells
        to be reconfigured, ex: ['0', '1']
    """
    delta = []
    delta_cell_template = delta_dlmimomode_template['delta_activate_dl_mimo_8x4'] if operation == 'enable' \
        else delta_dlmimomode_template['delta_deactivate_dl_mimo_8x4']
    for nrcellid in nrcellids_to_reconfiguring_dlmimomode:
        delta_cell = copy.deepcopy(delta_cell_template)
        delta_cell['distName'] = delta_cell['distName'] + f'NRCELL-{nrcellid}'
        delta.append(delta_cell)
    return delta

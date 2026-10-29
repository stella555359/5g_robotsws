from taf.sbts.oam.coam.admin import admin
from robot.api import logger
from functools import wraps
import re


class AdminHelper(admin):
    def __init__(self, admin_ip='192.168.255.129'):
        super(AdminHelper, self).__init__()
        self.set_admin_ip(admin_ip)
        assert self.admin_ip, 'Admin IP should be passed either as argument or from TL'

    def set_admin_ip(self, admin_ip):
        self.admin_ip = admin_ip if admin_ip else get_admin_ip_from_tl()
        return

    def login_logout(admin_func):
        @wraps(admin_func)
        def wrapper(self, *args, **kwargs):
            try:
                self.create_admin_session()
                result = admin_func(self, *args, **kwargs)
                return result
            finally:
                self.disconnect()

        return wrapper

    def create_admin_session(self):
        self.connect_to(bts_host=self.admin_ip)
        release = self.get_sw_release_name()
        self.teardown()
        self.connect_to(bts_host=self.admin_ip, release=release)
        return

    def disconnect(self):
        self.teardown()

    @login_logout
    def get_bts_status_from_admin(self):
        bts_info = self.get_bts_statuses(timeout=30)
        return bts_info

    @login_logout
    def get_nr_cells_info(self):
        cells_info = self.get_cells_info(cell_type='nr', timeout=30)
        return cells_info

    @login_logout
    def recommission_with_delta_from_admin(self, delta_json, should_activate=True, connection=None):
        if delta_json == '[]':
            logger.info('No new parameter added to perform delta commissioning')
            return
        logger.debug('Performing delta commissioning with delta json %s' % (delta_json,))
        self.perform_delta_recommissioning(delta_file=delta_json,
                                           skip_parameter_relation_errors=False,
                                           should_activate=should_activate,
                                           connection=connection)

    @login_logout
    def get_cells_distname_list(self):
        cell_dists = []
        cells_info = self.get_managed_objects(class_name='NRCELL_A')
        for cell_info in cells_info:
            cell_dists.append(cell_info['distName'].split('/')[-1].replace("_A", ""))
        if cell_dists:
            return sorted(cell_dists)
        raise Exception("Cannot get cell distname")

    @login_logout
    def get_nrcell_r_distname_list(self):
        cell_dists = []
        cells_info = self.get_managed_objects(class_name='NRCELL_R')
        for cell_info in cells_info:
            cell_dists.append(cell_info['distName'])
        if cell_dists:
            return sorted(cell_dists)
        raise Exception("Cannot get cell distname")

    def verify_all_cells_are_onair_with_admin(self):
        expected_cell_state = {'operationalState': 'Enabled', 'proceduralStatus': 'configured',
                               'blockingState': 'Unblocked', 'availabilityStatus': 'Online',
                               'administrativeState': 'Unlocked', 'usageState': 'Active',
                               'barringStatus': 'unbarred'}
        cells_info = self.get_nr_cells_info()
        for cell in cells_info:
            for key, val in cell['status'].items():
                exp_val = expected_cell_state[key]
                if not re.search(exp_val, val, flags=re.I):
                    raise Exception("The cell status is not as expected. Current cell status: {} "
                                    "and Expected Cell Status: {}".format(cell['status'], expected_cell_state))
        self.bts_state_online()

    def bts_state_online(self):
        expected_bts_status = {'operationalState': r'enabled', 'proceduralState': r'on\s?air',
                               'blockingState': r'unblocked'}
        bts_status = self.get_bts_status_from_admin()
        for exp_key, exp_val in expected_bts_status.items():
            act_val = bts_status[exp_key]
            if not re.search(exp_val, act_val, flags=re.I):
                raise Exception("The BTS status is not as expected. Current BTS status: {} and Expected BTS status: {}"
                                .format(bts_status, expected_bts_status))

    @login_logout
    def get_rmod_serial_number(self, rmod_id):
        rmods_info = self.get_detected_hw_info(timeout=30)
        for rmod in rmods_info['radioModules']['rmod']:
            if 'RMOD-' + str(rmod_id) in rmod['id']['configuration']:
                return rmod['serialNumber']

    def get_number_of_cells(self):
        cells_info = self.get_nr_cells_info()
        return len(cells_info)

    @login_logout
    def get_mrbts_id(self):
        return "".join(["MRBTS", "-", str(self.get_bts_info()['mrbtsID'])])

    @login_logout
    def get_nrbts_id(self):
        nrbts = self.get_managed_objects('NRBTS_A')
        return nrbts[0]['distName'].split('/')[-1].replace("_A", "")

    # @login_logout
    # def get_mrbts_id_from_admin(self):
    #     return "".join(["MRBTS", "-", str(self.get_bts_info()['mrbtsID'])])
    #
    # @login_logout
    # def get_nrbts_id_from_admin(self):
    #     nrbts = self.get_managed_objects('NRBTS_A')
    #     return nrbts[0]['distName'].split('/')[-1].replace("_A", "")
    #
    # @login_logout
    # def is_cell_parameter_value_equal_to_from_admin(self, physcellid, name, value):
    #     """
    #     Check if the value of the parameter has the given value.
    #     :param physcellid: str: Physical Cell Id
    #     :param name: str: Abbreviation of parameter
    #     :param value: str: Expected value of the parameter
    #     :return: bool: True or False
    #     """
    #     cells_info = self.get_managed_objects(class_name='NRCELL_A')
    #     for cell_info in cells_info:
    #         if str(cell_info["parameters"]['physCellId']) == str(physcellid):
    #             return str(cell_info["parameters"][name]).lower() == str(value).lower()
    #     raise BaseException("There is no cell with given physical cell id")
    #
    # @login_logout
    # def get_nrcell_id_for_physical_id(self, physical_cell_id):
    #     cells_info = self.get_managed_objects(class_name='NRCELL_A')
    #     for cell_index, cell_info in enumerate(cells_info, 1):
    #         if str(cell_info["parameters"]['physCellId']) == str(physical_cell_id):
    #             return cell_info['distName'].split('/')[-1].replace("_A", "")
    #
    #     raise AssertionError("No Cell Found for given physical cell id: %s" % (physical_cell_id, ))
    #
    # @login_logout
    # def get_distname_for_nrcell_from_admin(self, physical_cell_id):
    #     nr_cell_id = self.get_nrcell_id_for_physical_id(physical_cell_id)
    #     return "/".join([self.get_distname_for_nrbts(), nr_cell_id])
    #
    # @login_logout
    # def get_distname_for_nrcell_using_logical_id(self, logical_cell_id):
    #     return "/".join([self.get_distname_for_nrbts(), "NRCELL" + "-" + str(logical_cell_id)])
    #
    # @login_logout
    # def download_current_scf_file(self, local_dir_path='/tmp', file_name='SCF.xml'):
    #     scf_dir_path = self.get_current_scf_file(local_dir_path, file_name)
    #     return scf_dir_path
    #
    # @login_logout
    # def get_distname_for_nrbts(self):
    #     return "/".join([self.get_mrbts_id_from_admin(), self.get_nrbts_id_from_admin()])
    #
    # def bts_status_should_match_from_admin(self, state_type, expected_status):
    #     bts_status = self.get_bts_status_from_admin()
    #     bts_status_type = bts_status[state_type]
    #     if bts_status_type != expected_status:
    #         raise AssertionError('BTS Status expected is {} but it is {}'.format(expected_status,
    #                                                                              bts_status))
    #     return


def get_admin_ip_from_tl():
    from robot.libraries.BuiltIn import BuiltIn
    return BuiltIn().get_variable_value(r'${tl.gnbs[0].cu.oam_http_connection_details.addr}')

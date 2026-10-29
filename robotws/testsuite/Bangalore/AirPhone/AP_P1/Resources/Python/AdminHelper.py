from taf.sbts.oam.coam.admin import admin
from robot.api import logger
from functools import wraps
import os
try:
    import loguru
except ImportError:
    os.system('pip install loguru')
    import loguru


class AdminHelper(admin):
    def __init__(self, admin_ip=None):
        super(AdminHelper, self).__init__()
        self.set_admin_ip(admin_ip)
        assert self.admin_ip, 'Admin Ip should be passed either as argument or from TL'

    def set_admin_ip(self, admin_ip):
        self.admin_ip = admin_ip if admin_ip else get_admin_ip_from_tl()
        return

    def login_logout(admin_func):
        @wraps(admin_func)
        def wrapper(self, *args, **kwargs):
            self.create_admin_session()
            try:
                result = admin_func(self, *args, **kwargs)
                return result
            finally:
                self.disconnect()
        return wrapper

    def create_admin_session(self):
        self.connect_to(self.admin_ip)
        return

    def disconnect(self):
        self.teardown()

    @login_logout
    def get_bts_id(self):
        return self.get_bts_info()['mrbtsID']

    @login_logout
    def get_mrbts_id_from_admin(self):
        return "".join(["MRBTS", "-", str(self.get_bts_info()['mrbtsID'])])

    @login_logout
    def get_nrbts_id_from_admin(self):
        nrbts = self.get_managed_objects('NRBTS_A')
        return nrbts[0]['distName'].split('/')[-1].replace("_A", "")

    @login_logout
    def get_nr_cells_info(self):
        cells_info = self.get_cells_info(cell_type='nr', timeout=30)
        return cells_info

    @login_logout
    def get_bts_status_from_admin(self):
        bts_info = self.get_bts_statuses(timeout=30)
        return bts_info

    @login_logout
    def get_gnb_build(self):
        gnb_sw_version = self.get_sw_version().split('_')
        load = list(gnb_sw_version[2])[-1]
        branch = gnb_sw_version[3].lstrip('0')
        version = gnb_sw_version[4].lstrip('0')
        return '.'.join([load, branch, version])

    @login_logout
    def is_cell_parameter_value_equal_to_from_admin(self, physcellid, name, value):
        """
        Check if the value of the parameter has the given value.
        :param physcellid: str: Physical Cell Id
        :param name: str: Abbreviation of parameter
        :param value: str: Expected value of the parameter
        :return: bool: True or False
        """
        cells_info = self.get_managed_objects(class_name='NRCELL_A')
        for cell_info in cells_info:
            if str(cell_info["parameters"]['physCellId']) == str(physcellid):
                return str(cell_info["parameters"][name]).lower() == str(value).lower()
        raise BaseException("There is no cell with given physical cell id")

    @login_logout
    def recommission_with_delta_from_admin(self, delta_json, should_activate=True):
        if delta_json == '[]':
            logger.info('No new parameter added to perform delta commisioning')
            return
        logger.debug('Performing delta commisioning with delta json %s' % (delta_json,))
        self.perform_delta_recommissioning(delta_file=delta_json,
                                           skip_parameter_relation_errors=True,
                                           should_activate=should_activate)

    @login_logout
    def get_nrcell_id_for_physical_id(self, physical_cell_id):
        cells_info = self.get_managed_objects(class_name='NRCELL_A')
        for cell_index, cell_info in enumerate(cells_info, 1):
            if str(cell_info["parameters"]['physCellId']) == str(physical_cell_id):
                return cell_info['distName'].split('/')[-1].replace("_A", "")

        raise AssertionError("No Cell Found for given physical cell id: %s" % (physical_cell_id,))

    def get_distname_for_nrcell_from_admin(self, physical_cell_id):
        nr_cell_id = self.get_nrcell_id_for_physical_id(physical_cell_id)
        return "/".join([self.get_distname_for_nrbts(), nr_cell_id])

    def get_distname_for_nrcell_using_logical_id(self, logical_cell_id):
        return "/".join([self.get_distname_for_nrbts(), "NRCELL" + "-" + str(logical_cell_id)])

    @login_logout
    def download_current_scf_file(self, local_dir_path='/tmp', file_name='SCF.xml', timeout=60):
        scf_dir_path = self.get_current_scf_file(local_dir_path, file_name, timeout=timeout)
        return scf_dir_path

    def get_distname_for_nrbts(self):
        return "/".join([self.get_mrbts_id_from_admin(), self.get_nrbts_id_from_admin()])

    @login_logout
    def get_managed_object_and_parameters_coresetDedicated(self, class_name):
        managed_object = self.get_managed_objects(class_name=class_name)
        coresetdedicated_params = self.get_parameters(managed_object)
        return (managed_object, coresetdedicated_params['coresetDedicated'])

    def bts_status_should_match_from_admin(self, state_type, expected_status):
        bts_status = self.get_bts_status_from_admin()
        bts_status_type = bts_status[state_type]
        if bts_status_type != expected_status:
            raise AssertionError('BTS Status expected is {} but it is {}'.format(expected_status,
                                                                                 bts_status))
        return

    def verify_all_cells_are_onair_with_admin(self):
        expected_cell_state = {'operationalState': 'Enabled', 'proceduralStatus': 'configured',
                               'blockingState': 'Unblocked', 'administrativeState': 'Unlocked',
                               'usageState': 'Active'}
        expected_bts_status = {'operationalState': 'Enabled', 'proceduralState': 'OnAir',
                               'blockingState': 'Unblocked'}
        cells_info = self.get_nr_cells_info()
        for cell in cells_info:
            if cell['status'] != expected_cell_state:
                raise Exception("The cell status is not as expected. Current cell status : {} "
                                "and Expected Cell Status : {}".format(cell['status'], expected_cell_state))
        bts_status = self.get_bts_status_from_admin()
        if bts_status != expected_bts_status:
            raise Exception("The BTS status is not as expected. Current BTS status : {} and Expected BTS status : {}"
                            .format(bts_status, expected_bts_status))
        return

    def get_handover_parameters_for_cells(self):
        mutliple_cell_info = {}
        cells_info = self.get_nr_cells_info()
        for cell in cells_info:
            mutliple_cell_info[cell['id']['configuration']] = {'physCellId': str(cell['physicalCellId']),
                                                               'nrarfcn': str(cell['nrarfcn'])}
        return mutliple_cell_info

    def get_intra_nrcell_distnames(self):
        nrcell_distnames = []
        cells_info = self.get_nr_cells_info()
        for cell in cells_info:
            nrcell_distnames.append(cell['id']['configuration'])
        return sorted(nrcell_distnames)

    @login_logout
    def configure_default_netconf_account(self):
        try:
            accounts = [
                {
                    "id": "1",
                    "defaultNetconfAccount": {
                        "defaultNetconfAccountName": "xranuser",
                        "defaultNetconfAccountPwd": "xran-password",
                    },
                    "authentifierSshServer": {
                        "publicKeySshServerFormat": "",
                        "publicKeySshServerValue": "",
                    },
                }
            ]
            self.configure_netconf_accounts(
                unsecure_ciphering=False,
                authentication_method="NoAuthentication",
                accounts=accounts,
            )
            return 0, None
        except Exception as e:
            loguru.logger.error(f"Failed to configure default netconf account: {str(e)}")
            return (1, f"Failed to configure default netconf account: {str(e)}")

    @login_logout
    def update_rfm_plugin(self, filename):
        self.update_software(filename)
        return


def get_admin_ip_from_tl():
    from robot.libraries.BuiltIn import BuiltIn
    return BuiltIn().get_variable_value(r'${tl.gnbs[0].cu.oam_http_connection_details.addr}')

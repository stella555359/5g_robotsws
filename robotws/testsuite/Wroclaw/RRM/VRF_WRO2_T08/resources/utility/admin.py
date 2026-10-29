"""
Context Manager for taf.sbts.oam.coam.admin api. Automatically acquires connection details from testline init

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

from taf.sbts.oam.coam.admin import admin

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.decorators import wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration


class AdminContext(admin):
    def __init__(self, alias='default'):
        super(AdminContext, self).__init__()
        self._bts_addr, self._bts_username, self._bts_password = (None, None, None)
        self._remote_host, self._remote_username, self._remote_password = (None, None, None)
        self.alias = alias
        self.connection = None

    def __enter__(self):
        return self.connect()

    def __exit__(self, *args):
        self.teardown_admin(connection=self.alias)

    def connect(self, alias=None):
        if alias is None:
            alias = self.alias
        self.connection = self.setup_admin(bts_host=self._bts_addr, username=self._bts_username,
                                           password=self._bts_password, name=alias, remote_host=self._remote_host,
                                           remote_host_username=self._remote_username,
                                           remote_host_password=self._remote_password)
        return self.connection

    def set_connection_details(self, hostname, username, password):
        self._bts_addr = hostname
        self._bts_username = username
        self._bts_password = password

    def set_remote_details(self, hostname, username, password):
        self._remote_host = hostname
        self._remote_username = username
        self._remote_password = password


class Admin5G(AdminContext):
    def __init__(self, gnb_id=0, alias='admin_5g'):
        super(Admin5G, self).__init__(alias=alias)
        oam_connection_details = TestlineConfiguration().get_gnb_oam_connection_details(gnb_id=gnb_id)
        self.set_connection_details(**oam_connection_details)


class AdminLTE(AdminContext):
    def __init__(self, enb_id=0, alias='admin_lte'):
        super(AdminLTE, self).__init__(alias=alias)
        oam_connection_details = TestlineConfiguration().get_gnb_oam_connection_details(gnb_id=enb_id)
        lte_pc_connection_details = TestlineConfiguration().get_lte_test_pc_connection_details()
        self.set_connection_details(**oam_connection_details)
        self.set_remote_details(**lte_pc_connection_details)


def get_active_software(tech='5g'):
    api = Admin5G() if tech.lower() == '5g' else AdminLTE()
    with api:
        active_sw_version = api.get_sw_version(connection=api.alias)
    if active_sw_version.split("_")[2] in ["9999", "9990"]:
        active_sw_version = "_".join(["SBTS00", active_sw_version.split("_", 1)[1]])
    return active_sw_version


def perform_5g_scf_commissioning(scf_file_path, timeout=300):
    _perform_scf_commissioning(scf_file_path=scf_file_path, admin_api=Admin5G, timeout=timeout)


def perform_lte_scf_commissioning(scf_file_path, timeout=300):
    _perform_scf_commissioning(scf_file_path=scf_file_path, admin_api=AdminLTE, timeout=timeout)


def _perform_scf_commissioning(scf_file_path, admin_api, timeout):
    with admin_api() as admin_connection:
        admin_connection.perform_commissioning(scf_file=scf_file_path, timeout=timeout)


def commission_bts(scf_5g=None, scf_lte=None):
    if scf_5g is not None:
        perform_5g_scf_commissioning(scf_5g)
    if scf_lte is not None:
        perform_lte_scf_commissioning(scf_lte)


def save_5g_scf_file(local_dir, file_name):
    _save_scf_file(local_dir=local_dir, file_name=file_name, admin_api=Admin5G)


def save_lte_scf_file(local_dir, file_name):
    _save_scf_file(local_dir=local_dir, file_name=file_name, admin_api=AdminLTE)


def _save_scf_file(local_dir, file_name, admin_api):
    with admin_api() as admin_connection:
        admin_connection.get_current_scf_file(local_dir_path=local_dir, file_name=file_name)


def backup_scf_files(mode='SA', local_dir="/tmp"):
    save_5g_scf_file(local_dir=local_dir, file_name="backup_5g_scf.xml")
    if mode == 'NSA':
        save_lte_scf_file(local_dir=local_dir, file_name="backup_lte_scf.xml")


def wait_for_all_5g_cells_on_air_state(timeout=420, interval=10):
    wait_until_function_succeeds(timeout=timeout, interval=interval,
                                 console=False)(_assert_all_cells_on_air_state)(Admin5G, 'nr')


def wait_for_all_lte_cells_on_air_state(timeout=420, interval=10):
    wait_until_function_succeeds(timeout=timeout, interval=interval,
                                 console=False)(_assert_all_cells_on_air_state)(AdminLTE, 'lte')


def _assert_all_cells_on_air_state(admin_api, cell_type, console=False):
    with admin_api() as admin_connection:
        cells = admin_connection.get_cells_info(cell_type=cell_type)
        assert len(cells), 'Cells not detected'
        for cell in cells:
            cell = cell['status']
            if cell.get('administrativeState') == 'Unlocked' and cell.get('blockingState') == 'Unblocked' \
                    and cell.get('operationalState') == 'enabled':
                assert cell.get('availabilityStatus') in ['Online', None, 'Degraded', 'degraded'], \
                    f'Not all cells are online\n{cell}'


def wait_for_testline_cells_on_air(mode='SA', timeout=420, interval=10):
    wait_for_all_5g_cells_on_air_state(timeout=timeout, interval=interval)
    if mode == 'NSA':
        wait_for_all_lte_cells_on_air_state(timeout=timeout, interval=interval)

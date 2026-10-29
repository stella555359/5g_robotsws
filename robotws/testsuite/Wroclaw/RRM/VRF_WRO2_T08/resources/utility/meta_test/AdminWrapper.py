from contextlib import contextmanager

from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin import admin, AdminConnection

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.decorators import wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger
from .robot_library import RobotLibrary
from .teardown import Teardown

_teardown = Teardown()


class AdminWrapper(admin, RobotLibrary):
    verbose = False

    def __init__(self, verbose=False):
        if self._library_initiation_guard():
            return
        super().__init__()
        self._nr = None
        self._nr_kwargs = None
        self._lte = None
        self._lte_kwargs = None
        self.verbose = verbose

    def setup_admin(self,
                    bts_host="192.168.255.1",
                    bts_port=443,
                    username="Nemuadmin",
                    password="nemuuser",
                    use_ssl=True,
                    update_interval=5000,
                    admin_api_log_dir="",
                    bundle_path=None,
                    remote_host=None,
                    remote_host_username="ute",
                    remote_host_password="ute",
                    timeout=30,
                    name="default",
                    release=None,
                    **kwargs):
        connection = super().setup_admin(bts_host, bts_port, username, password, use_ssl, update_interval,
                                         admin_api_log_dir, bundle_path, remote_host, remote_host_username,
                                         remote_host_password, timeout, name, release, **kwargs)
        _teardown.schedule_suite_teardown_function(f'Teardown admin ({id(connection)})', super().teardown_admin,
                                                   [connection])
        return connection

    @property
    def nr_connection(self):
        if self._nr is None:
            admin_nr = self._get_admin_nr_by_default_alias()
            if admin_nr is None:
                admin_nr = self._get_default_admin_nr_from_config()
            self._nr = admin_nr
        return self._nr

    @nr_connection.setter
    def nr_connection(self, value):
        if value is None:
            self._nr = None
        else:
            self._nr = self._resolve_connection(value)

    @contextmanager
    def nr_context(self):
        yield self.nr_connection
        self.teardown_admin(connection=self.nr_connection)
        self._nr = None

    def setup_nr_connection(self,
                            bts_host="192.168.255.1",
                            bts_port=443,
                            username="Nemuadmin",
                            password="nemuuser",
                            use_ssl=True,
                            update_interval=5000,
                            admin_api_log_dir="",
                            bundle_path=None,
                            remote_host=None,
                            remote_host_username="ute",
                            remote_host_password="ute",
                            timeout=30,
                            release=None,
                            **kwargs):
        self._nr = self.setup_admin(bts_host, bts_port, username, password, use_ssl, update_interval,
                                    admin_api_log_dir, bundle_path, remote_host, remote_host_username,
                                    remote_host_password, timeout, 'admin_nr', release, **kwargs)

    def _get_admin_nr_by_default_alias(self):
        return self._get_admin_by_alias_or_none('admin_nr')

    def _get_admin_by_alias_or_none(self, alias):
        try:
            return self.store.get(alias)
        except AliasLookupError:
            return None

    def _get_default_admin_nr_from_config(self):
        default_kwargs = dict(zip(('bts_host', 'username', 'password'),
                                  TestlineConfiguration().get_gnb_oam_connection_details(gnb_id=0).values()))
        default_kwargs['name'] = 'admin_nr'
        logger.info(f"Setting up default admin nr from testline configuration. kwargs: {default_kwargs}",
                    also_to_console=self.verbose)
        return self.setup_admin(**default_kwargs)

    @property
    def lte_connection(self):
        if self._lte is None:
            admin_lte = self._get_admin_lte_by_default_alias()
            if admin_lte is None:
                admin_lte = self._get_default_admin_lte_from_config()
            self._lte = admin_lte
        return self._lte

    @lte_connection.setter
    def lte_connection(self, value):
        if value is None:
            self._lte = None
        else:
            self._lte = self._resolve_connection(value)

    @contextmanager
    def lte_context(self):
        yield self.lte_connection
        self.teardown_admin(connection=self.lte_connection)
        self._lte = None

    def setup_lte_connection(self,
                             bts_host="192.168.255.1",
                             bts_port=443,
                             username="Nemuadmin",
                             password="nemuuser",
                             use_ssl=True,
                             update_interval=5000,
                             admin_api_log_dir="",
                             bundle_path=None,
                             remote_host=None,
                             remote_host_username="ute",
                             remote_host_password="ute",
                             timeout=30,
                             release=None,
                             **kwargs):
        self._lte = self.setup_admin(bts_host, bts_port, username, password, use_ssl, update_interval,
                                     admin_api_log_dir, bundle_path, remote_host, remote_host_username,
                                     remote_host_password, timeout, 'admin_lte', release, **kwargs)

    def get_lte_connection(self):
        return self.lte_connection

    def _get_admin_lte_by_default_alias(self):
        return self._get_admin_by_alias_or_none('admin_lte')

    def _get_default_admin_lte_from_config(self):
        default_kwargs = dict(zip(('bts_host', 'username', 'password'),
                                  TestlineConfiguration().get_gnb_oam_connection_details(gnb_id=0).values()))
        default_kwargs.update(dict(zip(('remote_host', 'remote_host_username', 'remote_host_password'),
                                       TestlineConfiguration().get_lte_test_pc_connection_details().values())))
        default_kwargs['name'] = 'admin_lte'
        logger.info(f"Setting up default admin LTE from testline configuration. kwargs: {default_kwargs}",
                    also_to_console=self.verbose)
        return self.setup_admin(**default_kwargs)

    def _resolve_connection(self, connection):
        if isinstance(connection, AdminConnection):
            return connection
        elif isinstance(connection, str):
            return self.store.get(connection)
        elif isinstance(connection, dict):
            return self.setup_admin(**connection)
        raise TypeError(f"Could not resolve connection. Type of connection passed: {type(connection)}")

    def teardown_admin(self, connection='admin_nr', **kwargs):
        connection = self._resolve_connection(connection)
        super().teardown_admin(connection=connection, **kwargs)
        _teardown.recall_suite_teardown_function(f'Teardown admin ({id(connection)})')

    def get_active_software(self, connection='admin_nr'):
        admin_context = self._resolve_connection(connection)
        active_sw_version = admin_context.get_sw_version()
        if active_sw_version.split("_")[2] in ["9999", "9990"]:
            active_sw_version = "_".join(["SBTS00", active_sw_version.split("_", 1)[1]])
        return active_sw_version

    def wait_until_all_cells_on_air(self, connection='admin_nr', cell_type='nr', timeout=420, interval=10):
        @wait_until_function_succeeds(timeout=timeout, interval=interval, exceptions=AssertionError)
        def _assert_all_cells_on_air_state(admin_context):
            cells = admin_context.get_cells_info(cell_type=cell_type)
            assert len(cells), 'Cells not detected'
            for cell in cells:
                cell = cell['status']
                if cell.get('administrativeState') == 'Unlocked' and cell.get('blockingState') == 'Unblocked' \
                        and cell.get('operationalState') == 'enabled':
                    assert cell.get('availabilityStatus') in ['Online', None, 'Degraded', 'degraded'], \
                        f'Not all cells are online: {cell}'

        context = self._resolve_connection(connection=connection)
        _assert_all_cells_on_air_state(admin_context=context)

    def save_5g_scf_file(self, local_dir, file_name="backup_5g_scf.xml", timeout=10):
        logger.info(f"Making 5G scf backup in {local_dir}/{file_name}", also_to_console=self.verbose)
        self.get_current_scf_file(local_dir_path=local_dir, file_name=file_name, timeout=timeout,
                                  connection=self.nr_connection)

    def save_lte_scf_file(self, local_dir, file_name="backup_lte_scf.xml", timeout=10):
        logger.info(f"Making LTE scf backup in {local_dir}/{file_name}", also_to_console=self.verbose)
        self.get_current_scf_file(local_dir_path=local_dir, file_name=file_name, timeout=timeout,
                                  connection=self.lte_connection)

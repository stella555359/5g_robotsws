import os
from contextlib import contextmanager
from queue import Queue
from time import sleep, time

from ta_attenuator import ta_attenuator
from ta_ue_plugin_android.uepc.ue_manager_exceptions import UeManagerException
from taf.sbts.oam.coam.admin import (AdminConnection, admin,
                                     admin_interface_context)

import testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.cleaners as clean
import testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.decorators as deco
import testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.sanity_checks as sanity
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.facade import \
    LogCollectorFacade
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.reporting_portal import \
    report_to_reporting_portal
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import (
    RobotNotRunningError, get_robot_library, get_robot_variable)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import \
    TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import \
    logger

from .log_threads import AnalysisThread, GatheringThread
from .meta_test_parser import MetaConfigParser


class SingletonInterface:
    _singleton = None

    def __new__(cls, *args, **kwargs):
        if cls._singleton is None:
            cls._singleton = super().__new__(cls, *args, **kwargs)
        return cls._singleton

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def _is_instance_locked(self):
        try:
            assert self._instance_locked
            return True
        except (AttributeError, AssertionError):
            self._instance_locked = True
            return False


class TeardownInterface(SingletonInterface):
    teardown_wrapper = deco.continue_on_failure

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._suite_teardown_callbacks = {}
        self._test_teardown_callbacks = {}

    def _teardown(self, teardown_kind):
        callbacks = self._test_teardown_callbacks if teardown_kind == "test" else self._suite_teardown_callbacks
        failed = []
        for name, (callback, args) in reversed(list(callbacks.items())):
            _, result = callback(*args)
            if result is False:
                failed.append(name)
        assert not failed, (
            f"{teardown_kind.capitalize()} teardown encountered error in following functions:"
            f" {failed}. Inspect log for details"
        )

    def schedule_suite_teardown_function(self, name, callback, args):
        self._suite_teardown_callbacks[name] = (callback, args)

    def schedule_test_teardown_function(self, name, callback, args):
        self._test_teardown_callbacks[name] = (callback, args)

    def recall_test_teardown_function(self, name):
        if name in self._test_teardown_callbacks:
            del self._test_teardown_callbacks[name]

    def recall_suite_teardown_function(self, name):
        if name in self._suite_teardown_callbacks:
            del self._suite_teardown_callbacks[name]


class MetaTestInterface(TeardownInterface):
    def __init__(self, config_parser=MetaConfigParser, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.suite_dir = "/tmp"
        self.test_dir = None
        self.suite_time = None
        self.test_time = None
        self.testname = "default_test"
        self._iterations = (0,)
        self.cfg_parser = config_parser()
        self.cfg = None
        self.common_cfg = None
        self.report_name = "MetaTest"
        self.report_status = "failed"

    def suite_setup(self, config=None):
        self.suite_time = time()
        self.load_config(config)
        self.load_robot_outputdir()
        MetaTestInterface.sanity_check_uepc()
        self.sanity_check_vm()

    def load_config(self, config=None):
        if config is None:
            config = TestlineConfiguration().yaml
        self.cfg_parser.parse(config)
        self.common_cfg = self.cfg_parser.common_config

    def load_robot_outputdir(self):
        try:
            suite_dir = get_robot_variable("OUTPUT_DIR", self.suite_dir)
            self.suite_dir = suite_dir
        except RobotNotRunningError:
            self.suite_dir = os.getcwd()

    @staticmethod
    def load_robot_testname():
        try:
            return get_robot_variable("TESTNAME")
        except RobotNotRunningError:
            return "default_test"

    @staticmethod
    def sanity_check_uepc():
        sanity.kill_uepc_python_processes()

    def sanity_check_vm(self):
        sanity.check_vm_disk_space()
        clean.clear_tmp_if_needed()
        clean.clear_admin_api_logs(self.suite_dir)

    def test_setup(self, testname=None):
        self.test_time = time()
        if testname is None:
            testname = MetaTestInterface.load_robot_testname()
        self.testname = testname
        self.cfg = self.cfg_parser.tests.get(f"tc_{testname}", self.cfg_parser.default)
        self.test_dir = MetaTestInterface._create_subdirectory(testname, self.suite_dir)

    def run(self):
        self._execute_log_threads()

    def _execute_log_threads(self):
        queue = Queue(maxsize=20)
        gather_thread = GatheringThread(self.gather_logs, self._iterations, queue)
        analyze_thread = AnalysisThread(self.analyze_logs, queue)
        gather_thread.start()
        analyze_thread.start()
        try:
            analyze_thread.join()
        finally:
            gather_thread.stop()
            gather_thread.join()
        return analyze_thread.outcome

    def gather_logs(self, iteration):
        raise NotImplementedError

    def analyze_logs(self, logs):
        raise NotImplementedError

    @staticmethod
    def _create_subdirectory(name, root_dir):
        output_subdir = os.path.join(root_dir, name)
        if not os.path.exists(output_subdir):
            os.mkdir(output_subdir)
        return output_subdir

    def print_test_execution_time(self):
        logger.info(f"Test execution took {round((time() - self.test_time) / 60, 2)} min.", also_to_console=True)

    def print_suite_execution_time(self):
        logger.info(f"Suite execution took {round((time() - self.suite_time) / 3600, 2)} h.", also_to_console=True)

    def test_teardown(self):
        try:
            self._teardown("test")
        finally:
            self._test_teardown_callbacks = {}
            logger.log_background_messages()
            self.print_test_execution_time()

    def suite_teardown(self):
        try:
            self._teardown("suite")
        finally:
            self._suite_teardown_callbacks = {}
            if self.common_cfg.make_report:
                report_to_reporting_portal(
                    self.report_name, self.report_status, self.common_cfg.hostname, self.common_cfg.tl_type
                )
            self.print_suite_execution_time()


class CollectorsInterface(TeardownInterface):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._verification_logs = LogCollectorFacade()
        self._test_logs = LogCollectorFacade()

    def add_verification_collector(self, collector):
        self._verification_logs.add_collector(collector)

    def add_test_collector(self, collector):
        self._test_logs.add_collector(collector)

    def setup_all_collectors(self):
        self.setup_test_collectors()
        self.setup_verification_collectors()

    def setup_verification_collectors(self):
        self._verification_logs.setup_log_collectors()
        callback = self.teardown_wrapper()(self._verification_logs.shutdown_log_collectors)
        self.schedule_test_teardown_function(
            "Teardown verification collectors", callback, []
        )

    def setup_test_collectors(self):
        self._test_logs.setup_log_collectors()
        callback = self.teardown_wrapper()(self._test_logs.shutdown_log_collectors)
        self.schedule_test_teardown_function("Teardown test collectors", callback, [])

    def start_verification_collectors(self):
        self._verification_logs.start_log_collecting()
        callback = self.teardown_wrapper()(self._verification_logs.stop_log_collecting)
        self.schedule_test_teardown_function(
            "Stop verification collectors", callback, []
        )

    def start_test_collectors(self):
        self._test_logs.start_log_collecting()
        callback = self.teardown_wrapper()(self._test_logs.stop_log_collecting)
        self.schedule_test_teardown_function("Stop test collectors", callback, [])

    def stop_verification_collectors(self):
        self._verification_logs.stop_log_collecting()
        self.recall_test_teardown_function("Stop verification collectors")

    def stop_test_collectors(self):
        self._test_logs.stop_log_collecting()
        self.recall_test_teardown_function("Stop test collectors")

    def download_verification_logs(self, log_prefix):
        return self._verification_logs.download_logs(log_prefix=log_prefix)

    def download_test_logs(self, log_prefix):
        return self._test_logs.download_logs(log_prefix=log_prefix)

    def teardown_all_collectors(self):
        self.teardown_verification_collectors()
        self.teardown_test_collectors()

    def teardown_verification_collectors(self):
        self._verification_logs.shutdown_log_collectors()
        self.recall_test_teardown_function("Teardown verification collectors")

    def teardown_test_collectors(self):
        self._test_logs.shutdown_log_collectors()
        self.recall_test_teardown_function("Teardown test collectors")


class AttenuatorInterface(TeardownInterface):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.attenuator = ta_attenuator()

    def setup_attenuator(self, yaml_path=None):
        self.attenuator.load_attenuation_config(TestlineConfiguration(yaml_conf=yaml_path).yaml_path)
        self.attenuator.require_attenuator_setup_of(self.attenuator.cells_pool.registered_names)
        self.attenuator.set_maximum_attenuation_for_all_cells_of_testline()
        self.schedule_suite_teardown_function("Teardown attenuator", self.teardown_attenuator, tuple())

    @TeardownInterface.teardown_wrapper()
    def teardown_attenuator(self):
        self.attenuator.release_attenuator_cell(self.attenuator.cells_pool.registered_names)


class TafUeInterface(TeardownInterface):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._taf_ue = None
        self._attach_wait = 3
        self._ue_alias = "UE_1"

    def load_robot_taf_ue(self):
        self._taf_ue = get_robot_library("taf.ue")

    def attach_ue(self, ue_alias, capabilities="REAL_UE"):
        if f"Detach {ue_alias}" not in self._test_teardown_callbacks:
            self._taf_ue.require_ue(ue_alias=ue_alias, capabilities=capabilities)
        self.detach_ue(ue_alias=ue_alias)
        self._taf_ue.attach_ue(ue_alias=ue_alias)
        self.schedule_test_teardown_function(f"Detach {ue_alias}", self.detach_ue, (ue_alias,))
        sleep(self._attach_wait)

    def start_tput_on_ue(
        self,
        ue_alias,
        direction="ULDL",
        duration=36000,
        protocol="tcp",
        packet_size="1400",
        max_segment_size="1200",
        buffer="7M",
        throughput="max",
    ):
        kwargs = TafUeInterface._get_protocol_and_tput_specific_taf_data_transfer_kwargs(
            throughput, protocol, max_segment_size
        )
        packet_size = str(packet_size)
        if "UL" in direction:
            self._taf_ue.start_data_transfer(
                dt_name=f"{ue_alias}_DT_UL",
                ue_alias=ue_alias,
                direction="UL",
                duration=f"{duration}s",
                protocol=protocol,
                packet_size=packet_size,
                buffer=buffer,
                **kwargs,
            )
        if "DL" in direction:
            self._taf_ue.start_data_transfer(
                dt_name=f"{ue_alias}_DT_DL",
                ue_alias=ue_alias,
                direction="DL",
                duration=f"{duration}s",
                protocol=protocol,
                packet_size=packet_size,
                buffer=buffer,
                **kwargs,
            )
        self.schedule_test_teardown_function(f"Stop tput on {ue_alias}", self.stop_tput_on_ue, (ue_alias, direction))
        sleep(30)

    @staticmethod
    def _get_protocol_and_tput_specific_taf_data_transfer_kwargs(throughput, protocol, max_segment_size):
        kwargs = (
            {"max_segment_size": str(max_segment_size)} if protocol.lower() == "tcp" else {"throughput": "2 Gbits/sec"}
        )
        if throughput != "max":
            param, value = (
                ("bandwidth", throughput) if protocol.lower() == "tcp" else ("throughput", f"{throughput}bits/sec")
            )
            kwargs[param] = value
        return kwargs

    @TeardownInterface.teardown_wrapper()
    def stop_tput_on_ue(self, ue_alias, direction):
        direction = direction.upper()
        if "UL" in direction:
            self._taf_ue.stop_data_transfer(dt_name=f"{ue_alias}_DT_UL")
        if "DL" in direction:
            self._taf_ue.stop_data_transfer(dt_name=f"{ue_alias}_DT_DL")

    @TeardownInterface.teardown_wrapper()
    def detach_ue(self, ue_alias):
        try:
            self._taf_ue.detach_ue(ue_alias=ue_alias)
        except UeManagerException:
            pass

    def get_average_tput(self, ue_alias, direction, omit=3):
        return self._taf_ue.get_average_throughput(f"{ue_alias}_DT_{direction}", omit=omit)


class AdminInterface(TeardownInterface):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.admin_api = admin()
        self.admin_nr = None
        self.admin_nr_kwargs = None
        self.admin_lte = None
        self.admin_lte_kwargs = None

    def setup_admin_nr(self):
        if isinstance(self.admin_nr, AdminConnection):
            self.teardown_admin_nr()
        self.admin_nr = self.admin_api.setup_admin(**self._get_default_admin_nr_kwargs())
        self.schedule_suite_teardown_function("Teardown admin NR", self.teardown_admin_nr, tuple())

    def setup_admin_lte(self):
        if isinstance(self.admin_lte, AdminConnection):
            self.teardown_admin_lte()
        self.admin_lte = self.admin_api.setup_admin(**self._get_default_admin_lte_kwargs())
        self.schedule_suite_teardown_function("Teardown admin LTE", self.teardown_admin_lte, tuple())

    def setup_admins(self, mode="SA", multirat=False):
        self.setup_admin_nr()
        if mode.upper() == "NSA" and multirat is False:
            self.setup_admin_lte()

    @TeardownInterface.teardown_wrapper()
    def teardown_admin_nr(self):
        self.admin_api.teardown_admin(self.admin_nr)
        self.admin_nr = None

    @TeardownInterface.teardown_wrapper()
    def teardown_admin_lte(self):
        self.admin_api.teardown_admin(self.admin_lte)
        self.admin_lte = None

    def admin_nr_context(self):
        if isinstance(self.admin_nr, AdminConnection):
            return self._admin_nr_context_mock()
        return admin_interface_context(**self._get_default_admin_nr_kwargs())

    @contextmanager
    def _admin_nr_context_mock(self):
        yield self.admin_nr

    def admin_lte_context(self):
        if isinstance(self.admin_lte, AdminConnection):
            return self._admin_lte_context_mock()
        return admin_interface_context(**self._get_default_admin_lte_kwargs())

    @contextmanager
    def _admin_lte_context_mock(self):
        yield self.admin_lte

    def _get_default_admin_nr_kwargs(self):
        if self.admin_nr_kwargs is not None:
            return self.admin_nr_kwargs
        hostname, username, password = TestlineConfiguration().get_gnb_oam_connection_details(gnb_id=0).values()
        self.admin_nr_kwargs = {"bts_host": hostname, "username": username, "password": password, "name": "admin5g"}
        return self.admin_nr_kwargs

    def _get_default_admin_lte_kwargs(self):
        if self.admin_lte_kwargs is not None:
            return self.admin_lte_kwargs
        hostname, username, password = TestlineConfiguration().get_gnb_oam_connection_details(gnb_id=0).values()
        remote_host, remote_username, remote_password = (
            TestlineConfiguration().get_lte_test_pc_connection_details().values()
        )
        self.admin_lte_kwargs = {
            "bts_host": hostname,
            "username": username,
            "password": password,
            "name": "adminlte",
            "remote_host": remote_host,
            "remote_host_username": remote_username,
            "remote_host_password": remote_password,
        }
        return self.admin_lte_kwargs

    def get_active_software(self, rat="nr"):
        admin_context = self.admin_nr_context() if rat.lower() == "nr" else self.admin_lte_context()
        with admin_context as admin_connection:
            active_sw_version = admin_connection.get_sw_version()
        if active_sw_version.split("_")[2] in ["9999", "9990"]:
            active_sw_version = "_".join(["SBTS00", active_sw_version.split("_", 1)[1]])
        return active_sw_version

    def perform_5g_scf_commissioning(self, scf_file_path, timeout=300):
        logger.info(f"Performing NR commissioning with file {scf_file_path}", also_to_console=True)
        self._perform_scf_commissioning(
            scf_file_path=scf_file_path, admin_context=self.admin_nr_context, timeout=timeout
        )

    def perform_lte_scf_commissioning(self, scf_file_path, timeout=300):
        logger.info(f"Performing LTE commissioning with file {scf_file_path}", also_to_console=True)
        self._perform_scf_commissioning(
            scf_file_path=scf_file_path, admin_context=self.admin_lte_context, timeout=timeout
        )

    @staticmethod
    def _perform_scf_commissioning(scf_file_path, admin_context, timeout):
        with admin_context() as admin_connection:
            admin_connection.perform_commissioning(scf_file=scf_file_path, timeout=timeout)

    def commission_bts(self, scf_5g=None, scf_lte=None):
        if scf_5g is not None:
            self.perform_5g_scf_commissioning(scf_5g)
        if scf_lte is not None:
            self.perform_lte_scf_commissioning(scf_lte)

    def save_5g_scf_file(self, local_dir, file_name="backup_5g_scf.xml"):
        logger.info(f"Making 5G scf backup in {local_dir}/{file_name}", also_to_console=True)
        self._save_scf_file(local_dir=local_dir, file_name=file_name, admin_api=self.admin_nr_context)

    def save_lte_scf_file(self, local_dir, file_name="backup_lte_scf.xml"):
        logger.info(f"Making LTE scf backup in {local_dir}/{file_name}", also_to_console=True)
        self._save_scf_file(local_dir=local_dir, file_name=file_name, admin_api=self.admin_lte_context)

    @staticmethod
    def _save_scf_file(local_dir, file_name, admin_api):
        with admin_api() as admin_connection:
            admin_connection.get_current_scf_file(local_dir_path=local_dir, file_name=file_name)

    def backup_scf_files(self, mode="SA", multirat=False, local_dir="/tmp"):
        self.save_5g_scf_file(local_dir=local_dir)
        if mode == "NSA" and multirat is False:
            self.save_lte_scf_file(local_dir=local_dir)

    def wait_for_all_5g_cells_on_air_state(self, timeout=420, interval=10):
        logger.info(f"Waiting for NR cells to be on air (timeout={timeout})", also_to_console=True)
        deco.wait_until_function_succeeds(timeout=timeout, interval=interval)(self._assert_all_cells_on_air_state)(
            self.admin_nr_context, "nr"
        )
        logger.info("NR cells are on air!", also_to_console=True)

    def wait_for_all_lte_cells_on_air_state(self, timeout=420, interval=10):
        logger.info(f"Waiting for LTE cells to be on air (timeout={timeout})", also_to_console=True)
        deco.wait_until_function_succeeds(timeout=timeout, interval=interval)(self._assert_all_cells_on_air_state)(
            self.admin_lte_context, "lte"
        )
        logger.info("LTE cells are on air", also_to_console=True)

    @staticmethod
    def _assert_all_cells_on_air_state(admin_api, cell_type, console=False):
        with admin_api() as admin_connection:
            cells = admin_connection.get_cells_info(cell_type=cell_type)
        assert len(cells), "Cells not detected"
        for cell in cells:
            cell = cell["status"]
            if (
                cell.get("administrativeState") == "Unlocked"
                and cell.get("blockingState") == "Unblocked"
                and cell.get("operationalState") == "enabled"
            ):
                assert cell.get("availabilityStatus") in ["Online", None, "Degraded", "degraded"], logger.info(
                    f"Not all cells are online\n{cell}", also_to_console=console
                )

    def wait_for_testline_cells_on_air(self, mode="SA", multirat=False, timeout=420, interval=10):
        self.wait_for_all_5g_cells_on_air_state(timeout=timeout, interval=interval)
        if mode == "NSA" and multirat is False:
            self.wait_for_all_lte_cells_on_air_state(timeout=timeout, interval=interval)

from taf.rfrl.cbts.devices.vcu.base import vcu_cm_base
from taf.rfrl.cbts.devices.vdu.base import vdu_cm_base
from taf.rfrl.cbts.devices.vdu.business import vdu_cm_business
from taf.rfrl.cbts.devices.vcu.business import vcu_cm_business
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from robot.libraries.BuiltIn import BuiltIn
from time import time

STATE_ONLINE = 'online'
STATE_FAILED = 'failed'
STATE_NOT_INSTALLED = 'not_installed'
TIMEOUT_PODS_RESTART = 120
TIMEOUT_DU_UNREACHABLE = 60
TIMEOUT_CELLS_OFF = 20
TIMEOUT_RADIO_ON = 480
TIMEOUT_RADIO_ON_AIR = 480
DELTA_PATH = 'testsuite/Wroclaw/SyVe/RRM/CB012667/resources/delta/delta_cloud.json'


class Res12667(object):

    def __init__(self):
        self.feature = "CB012667"
        self.testing_env = None
        self.start_time = None
        self.rmod = None
        self.du = None
        self.vdu_connection = vdu_cm_base.vDUCM()
        self.vcu_connection = vcu_cm_base.vCUCM()
        self.restart_times_before_activation = []
        self.restart_times_after_activation = []

    def environment_is_prepared(self):
        self.testing_env = BuiltIn().get_variable_value("${testing_env}")
        self.rmod = self.testing_env.btss[0].rmods[0]
        self.du = self.testing_env.btss[0].dus[0]
        self._allow_alarms_related_to_resetting_rmod()

    def errors_on_bts_are_not_present(self):
        self.testing_env.errors.check()

    def time_improvement_is_checked(self):
        average_restart_time_before_activation = sum(self.restart_times_before_activation) / len(
            self.restart_times_before_activation)
        average_restart_time_after_activation = sum(self.restart_times_after_activation) / len(
            self.restart_times_after_activation)
        Logger.info(f'Average restart time before activation: {average_restart_time_before_activation}')
        Logger.info(f'Average restart time after activation:  {average_restart_time_after_activation}')
        assert 10 < average_restart_time_before_activation - average_restart_time_after_activation < 30, \
            'Time improvement is not between 10-30 seconds'

    def ecpri_delay_measurement_is_activated(self):
        self.vcu_connection.login_rest()
        vcu_cm_business.fast_delta_commissioning_by_delta_json_file(DELTA_PATH)
        self.vcu_connection.logout_rest()
        self.vdu_connection.login_rest()
        vdu_cm_business.fast_delta_commission_with_delta_json_file(DELTA_PATH)
        self.vdu_connection.logout_rest()

    def execution_of_10_rmod_restart_attempts_before_activation_is_performed(self):
        self._measure_10_rmod_restart_attempts()

    def execution_of_10_rmod_restart_attempts_after_activation_is_performed(self):
        self._measure_10_rmod_restart_attempts(measurement_type='after')

    def execution_of_10_vdu_restart_attempts_before_activation_is_performed(self):
        self._measure_10_vdu_restart_attempts()

    def execution_of_10_vdu_restart_attempts_after_activation_is_performed(self):
        self._measure_10_vdu_restart_attempts(measurement_type='after')

    def _restart_vdu(self):
        self.du.reset()
        self.du.check_if_pods_are_restarting(timeout=TIMEOUT_PODS_RESTART)
        self.du.check_if_unreachable(timeout=TIMEOUT_DU_UNREACHABLE)

    def _allow_alarms_related_to_resetting_rmod(self):
        self.rmod.du.allow_alarm(fault_name='No connection to unit', unit_path=self.rmod.config_dist_name)
        self.rmod.du.cu.allow_alarm(fault_name='Matching ServedCell not found over F1-C')

    def _restart_rmod(self):
        self.rmod.reset()

    def _check_if_the_first_cell_is_offline(self):
        self.rmod.cells[0].is_in_state(state=STATE_FAILED)

    def _start_time_measuring(self):
        self.start_time = time()

    def _check_if_all_cells_are_offline(self):
        self.rmod.cells.check_state_on_all(state=STATE_FAILED, timeout=TIMEOUT_CELLS_OFF)
        self.rmod.check_state(state=STATE_NOT_INSTALLED)

    def _check_if_all_cells_are_online(self):
        self.rmod.cells.check_state_on_all(state=STATE_ONLINE, timeout=TIMEOUT_RADIO_ON, interval=5)

    def _check_if_rmod_is_online_after_reset(self):
        self.rmod.check_state(state=STATE_ONLINE, timeout=TIMEOUT_RADIO_ON_AIR)

    def _stop_time_measuring_before_activation(self):
        restart_duration_before_activation = time() - self.start_time
        self.restart_times_before_activation.append(restart_duration_before_activation)
        Logger.info(f'Calculated restart time: {restart_duration_before_activation}')

    def _stop_time_measuring_after_activation(self):
        restart_duration_after_activation = time() - self.start_time
        self.restart_times_after_activation.append(restart_duration_after_activation)
        Logger.info(f'Calculated restart time: {restart_duration_after_activation}')

    def _measure_10_rmod_restart_attempts(self, measurement_type='before'):
        for attempt in range(10):
            self._restart_rmod()
            self._check_if_the_first_cell_is_offline()
            self._start_time_measuring()
            self._check_if_all_cells_are_offline()
            self._check_if_rmod_is_online_after_reset()
            self._check_if_all_cells_are_online()
            if 'before' in measurement_type:
                self._stop_time_measuring_before_activation()
            else:
                self._stop_time_measuring_after_activation()

    def _measure_10_vdu_restart_attempts(self, measurement_type='before'):
        for attempt in range(10):
            self._restart_vdu()
            self._start_time_measuring()
            self._check_if_rmod_is_online_after_reset()
            self._check_if_all_cells_are_online()
            if 'before' in measurement_type:
                self._stop_time_measuring_before_activation()
            else:
                self._stop_time_measuring_after_activation()

import re
from time import sleep

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.averager import Averager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.AdminWrapper import AdminWrapper
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.LogCollector import LogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.TafUe import TafUe
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.meta_test2 import MetaTestInterface
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.teardown import Teardown
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

admin = AdminWrapper(verbose=True)
taf_ue = TafUe(verbose=True)
teardown = Teardown(verbose=True)
collectors = LogCollector()


class CNI88605(MetaTestInterface):
    def __init__(self):
        if self._library_initiation_guard():
            return
        super().__init__()
        self._drb_dn = None
        self._delta_id = "cni88605_delta"
        self._backup_scf = 'cni88605_backup_scf.xml'
        self._tput_direction = 'DL'
        self._tput_protocol = 'tcp'
        self._tput_value = '50M'
        self._iterations = ('false', 'true')
        self._tput_duration = 15
        self._tput_wait_for_stable = 30
        self._additional_tput_buffer_time = 30
        self.allowed_tput_mismatch_factor = 0.005
        self.min_lte_leg_tput_share = 0.1
        self.valid_qci_value = 9
        self._qci_pattern = re.compile(
            r'nrDrbDN\">.*?(MRBTS-\d+/NRBTS-\d+/NRDRB-\d+)</p>\n.*?qciValueList\">\s+<p>{}</p>\s+</list>'.format(
                self.valid_qci_value
            )
        )
        self._nsa_drb_pattern = r'{}.*?list name="nsaDrbParam">\s+<item>(.*?</list>)'
        self._dlAllowMinDelayLinkXxCalib_pattern = r'{}.*?dlAllowMinDelayLinkXxCalib">(.*?)</p>'
        self._tput_pattern = re.compile(r'INF/L2HiCu.*?STATS-DL-PDCP.*?Out:(\d+)\sB/s, OutF1:(\d+)')
        self._default_nsa_drb_param = None
        self._ue_alias = 'UE_1'

    def backup_scf(self):
        admin.save_5g_scf_file(self.suite_dir, self._backup_scf, timeout=20)

    @staticmethod
    def setup_log_collectors():
        collectors.add_verification_collector('BTSLOG_5G')
        collectors.add_test_collector('SNAPSHOT_5G')
        collectors.setup_all_collectors()
        collectors.start_test_collectors()

    def create_scf_reverting_delta(self):
        admin.create_delta(delta_id=self._delta_id)
        self.set_default_nsa_drb_params_and_add_them_to_delta()
        self.add_default_dlAllowMinDelayLinkXxCalib_to_delta()
        teardown.schedule_suite_teardown_function("Revert scf changes", self.revert_scf_changes, tuple())

    def collect_test_logs(self):
        collectors.stop_test_collectors()
        collectors.download_test_logs(log_prefix=f"{self.test_dir}")

    def run_tput_with_logs(self, link_x2_calib_value='true'):
        combined_tput_time = self._tput_duration + self._additional_tput_buffer_time
        taf_ue.start_tput_on_ue(self._ue_alias, direction=self._tput_direction, duration=combined_tput_time,
                                protocol=self._tput_protocol, throughput=self._tput_value)
        collectors.start_verification_collectors()
        sleep(self._tput_duration)
        collectors.stop_verification_collectors()
        log = collectors.download_verification_logs(log_prefix=f"{self.test_dir}/{link_x2_calib_value}")
        taf_ue.stop_tput_on_ue(self._ue_alias, 'DL')
        return log['BTSLOG_5G']

    def determine_relevant_drb_id(self):
        with open(f"{self.suite_dir}/{self._backup_scf}", 'r') as f:
            scf = f.read()
        matches = self._qci_pattern.findall(scf)
        assert matches, f"No QCI objects with value {self.valid_qci_value} found in SCF"
        assert len(matches) == 1, "More than one QCI objects have qciValue == 9"
        self._drb_dn = matches[0]
        logger.info(f"Found DRB '{self._drb_dn}' to be pointed by QCI with value {self.valid_qci_value}",
                    also_to_console=True)

    def set_dlDataSplitBufferBuildUpThreshold_to_zero(self):
        updated = self._default_nsa_drb_param
        updated['dlDataSplitBufferBuildUpThreshold'] = '0'
        updated = [updated]
        status = admin.perform_parameter_recommissioning(dist_name=self._drb_dn, operation='update', value=updated,
                                                         parameter='nsaDrbParam', connection='admin_nr')
        if status['commissioningResult']['isGoingToTriggerReset']:
            admin.wait_until_all_cells_on_air()
        logger.info("dlDataSplitBufferBuildUpThreshold set to 0", also_to_console=True)

    def set_dlAllowMinDelayLinkXxCalib(self, value='false'):
        status = admin.perform_parameter_recommissioning(dist_name=self._drb_dn, operation='update', value=value,
                                                         parameter='dlAllowMinDelayLinkXxCalib', connection='admin_nr')
        if status['commissioningResult']['isGoingToTriggerReset']:
            admin.wait_until_all_cells_on_air()
        logger.info(f"dlAllowMinDelayLinkXxCalib set to {value}", also_to_console=True)

    def attach_with_btslog(self, case):
        collectors.start_verification_collectors()
        taf_ue.attach_ue(self._ue_alias)
        collectors.stop_verification_collectors()
        collectors.download_verification_logs(log_prefix=f"{self.test_dir}/attach_{case}")

    def detach_ue(self):
        taf_ue.detach_ue(self._ue_alias)

    def verify_tput(self, log, feature_enabled='true'):
        avg = self.get_tput_from_btslog(log)
        both, nr, lte = avg['both'], avg['nr'], avg['lte']
        if feature_enabled == 'false':
            assert lte < both * self.allowed_tput_mismatch_factor and int(nr) > 0, \
                f'LTE tput ({lte}) is higher than minimal: allowed = ' \
                f'{self.allowed_tput_mismatch_factor * 100}% of combined tput (nr = {nr}, ' \
                f'combined = {both}) or nr tput is 0 in log {log}'
        else:
            assert lte > both * self.min_lte_leg_tput_share and int(nr) > 0, \
                f'Tput via LTE leg ({lte}) is lower than minimum ' \
                f'{self.min_lte_leg_tput_share * 100}% of combined tput (nr = {nr}, combined = {both}) ' \
                f'or nr tput is 0 in log {log}'

    def get_tput_from_btslog(self, log):
        avg = Averager()
        with open(log, 'r') as f:
            matches = self._tput_pattern.findall(f.read())
            assert matches, f"No tput matching prints in log {log}"
            for match in matches:
                both, nr = int(match[0]), int(match[1])
                lte = abs(both - nr)
                avg.update(both=both * 8 / 1000000, nr=nr * 8 / 1000000, lte=lte * 8 / 1000000)
        logger.info(f"Average combined tput = {avg['both']}, nr tput = {avg['nr']}, lte tput = {avg['lte']}",
                    also_to_console=True)
        return avg

    def set_default_nsa_drb_params_and_add_them_to_delta(self):
        with open(f"{self.suite_dir}/{self._backup_scf}", 'r') as f:
            scf = f.read()
        params = {}
        scf_params = re.findall(self._nsa_drb_pattern.format(self._drb_dn), scf, re.S)
        assert len(scf_params) == 1, f'Could not find default nsaDrbParams in {self._drb_dn}'
        for line in scf_params[0].splitlines():
            if 'p name' in line:
                _, param_name, param_value = line.split('"')
                param_value = param_value.split('<')[0][1:]
                params[param_name] = param_value
        admin.append_complex_item_to_delta(dist_name=self._drb_dn, list_name='nsaDrbParam',
                                           delta_id=self._delta_id, **params)
        self._default_nsa_drb_param = params

    def add_default_dlAllowMinDelayLinkXxCalib_to_delta(self):
        with open(f"{self.suite_dir}/{self._backup_scf}", 'r') as f:
            scf = f.read()
        linkx2calib = re.findall(self._dlAllowMinDelayLinkXxCalib_pattern.format(self._drb_dn), scf, re.S)
        assert len(linkx2calib) == 1, f'Could not find default dlAllowMinDelayLinkXxCalib in {self._drb_dn}'
        admin.append_parameter_update_to_delta(dist_name=self._drb_dn, parameter='dlAllowMinDelayLinkXxCalib',
                                               value=linkx2calib[0], delta_id=self._delta_id)

    def revert_scf_changes(self):
        logger.info("Reverting scf changes", also_to_console=True)
        delta = admin.get_delta(self._delta_id)
        admin.perform_delta_recommissioning(delta_file=delta, connection=admin.nr_connection)

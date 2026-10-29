from time import sleep

import testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.sanity_checks as sanity
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_verification.attach_verification import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.resources.perfcap_test_interface import PerfCapTestInterface
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.averager import Averager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.banner import Banner
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.pm_counters import wait_for_next_pm_interval_and_get_counters
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger
from .cell_edge_config import CellEdgeConfigParser


class CellEdge(PerfCapTestInterface):
    def __init__(self):
        if self._is_instance_locked():
            return
        super().__init__(config_parser=CellEdgeConfigParser)
        self.averager = None
        self.failed_runs = 0
        self.executed_runs = 0
        self._counter_ids = ['M55306C06001', 'M55306C03001']

    def test_setup(self, testname=None):
        super().test_setup(testname)
        self._iterations = range(self.cfg.runs)
        self._attach_wait = self.cfg.attach_wait
        self.averager = Averager()
        self.failed_runs = 0
        self.executed_runs = 0
        self._print_test_setup_banner()

    def run(self):
        if self.cfg.check_counters:
            logger.info("Checking counters before test...", also_to_console=True)
            with self.admin_nr_context() as admin:
                counters_before = wait_for_next_pm_interval_and_get_counters(self._counter_ids, admin)
        try:
            self._execute_log_threads()
        finally:
            self._print_summary_banner()
            if not self.cfg.stop_upon_fail:
                if self.failed_runs > self.cfg.allowed_fails:
                    raise AssertionError(f"Test failed. Number of fails ({self.failed_runs}) "
                                         f"exceeded allowed limit ({self.cfg.allowed_fails})")
            if self.cfg.check_counters:
                logger.info("Checking counters after test...", also_to_console=True)
                with self.admin_nr_context() as admin:
                    counters_after = wait_for_next_pm_interval_and_get_counters(self._counter_ids, admin,
                                                                                counters_before)
                self._check_counters_condition(counters_after)

    def gather_logs(self, run_nr):
        run_nr = run_nr + 1
        self.current_subdir = self._create_subdirectory(f"run_{run_nr}", self.test_dir)
        self.start_verification_collectors()
        self.attach_ue(ue_alias=self._ue_alias)
        self.do_post_attach_test_steps()
        self.detach_ue(ue_alias=self._ue_alias)
        self.stop_verification_collectors()
        files = self.download_verification_logs(log_prefix=f"{self.current_subdir}/{self._get_formatted_log_prefix()}")
        files['run_nr'] = run_nr
        return files

    def do_post_attach_test_steps(self):
        sleep(3)

    def analyze_logs(self, logs):
        run_nr = logs['run_nr']
        logger.info(f"Veryfing attach nr {run_nr}/{self.cfg.runs}", also_to_console=True)

        ue_log_attaches, ue_log_success, bip_attaches, bip_success = self._get_logs_analysis(logs)
        self._update_attach_statistics(run_nr, ue_log_attaches)

        if ue_log_success and 'BIP' in logs:
            matching_bip = CellEdge._get_matching_bip_log_attach(ue_log_attaches[-1], bip_attaches)
            if matching_bip is None:
                logger.info('Attach considered failed due to BIP/UE_LOG mismatch!', also_to_console=True)
                ue_log_attaches[-1].outcome = 'FAIL'
                ue_log_attaches[-1].reason = 'BIP MISMATCH'
                ue_log_success = False
                bip_success = False
        self._print_attaches(run_nr, ue_log_attaches, bip_attaches)
        if self.cfg.ue_app in logs:
            if len(ue_log_attaches):
                self.failed_runs += len(ue_log_attaches) - ue_log_success
                self.executed_runs += len(ue_log_attaches)
            else:
                self.failed_runs += 1
                self.executed_runs += 1
        elif 'BIP' in logs:
            if len(bip_attaches):
                self.failed_runs += len(bip_attaches) - bip_success
                self.executed_runs += len(bip_attaches)
            else:
                self.failed_runs += 1
                self.executed_runs += 1
        logger.info(f"Verified attach {run_nr}/{self.cfg.runs}; Number of fails = {self.failed_runs}",
                    also_to_console=True)
        if self.failed_runs > self.cfg.allowed_fails:
            if self.cfg.stop_upon_fail:
                raise AssertionError(f"On run {run_nr}/{self.cfg.runs}, number of fails ({self.failed_runs}) "
                                     f"exceeded allowed limit ({self.cfg.allowed_fails})")
            else:
                logger.info(f"Test already failed; Number of fails ({self.failed_runs}) exceeds limit"
                            f" ({self.cfg.allowed_fails})", also_to_console=True)

    def _get_logs_analysis(self, logs):
        bip_attaches, bip_success, ue_log_attaches, ue_log_success = (None, False, None, False)
        if self.cfg.ue_app in logs:
            ue_log_attaches, ue_log_success = self._analyze_ue_log(logs[self.cfg.ue_app][0])
        if 'BIP' in logs:
            bip_attaches, bip_success = self._analyze_bip(logs['BIP'])
        return ue_log_attaches, ue_log_success, bip_attaches, bip_success

    def _analyze_bip(self, bip_log):
        attaches = find_attaches_in_bip_pcap(bip_log, self._sw_branch)
        success = False
        for attach in attaches:
            attach.determine_outcome()
            attach.apply_peak_metric_condition(self.cfg.min_peak_metric)
            attach.apply_timing_advance_condition(self.cfg.max_timing_advance)
            if 'SUCCESS' in attach.outcome:
                success = True
        return [attach for attach in attaches if "GHOST" not in attach.outcome], success

    def _analyze_ue_log(self, ue_log):
        if self.cfg.ue_app == 'QXDM':
            # TODO: QXDM support for averager
            return self._analyze_qxdm_log(ue_log[0])
        return self._analyze_elt_log(ue_log)

    def _analyze_qxdm_log(self, qxdm_log):
        up_to_first_success = []
        attaches = find_attaches_in_qxdm_log(qxdm_log)
        for attach in attaches:
            attach.determine_outcome()
            attach.apply_timing_advance_condition(self.cfg.max_timing_advance)
            if attach.outcome != 'GHOST':
                up_to_first_success.append(attach)
                if attach.outcome == 'SUCCESS':
                    return up_to_first_success, True
        return up_to_first_success, False

    def _analyze_elt_log(self, elt_log):
        up_to_first_success = []
        attaches = find_attaches_in_elt_log(elt_log)
        for idx, attach in enumerate(attaches):
            attach.determine_outcome()
            if self.cfg.mode == 'NSA':
                attach.apply_nsa_specific_conditions()
            attach.apply_timing_advance_condition(self.cfg.max_timing_advance)
            if attach.outcome != 'GHOST':
                up_to_first_success.append(attach)
                if attach.outcome == 'SUCCESS':
                    return up_to_first_success, True
        return up_to_first_success, False

    def _update_attach_statistics(self, run, ue_log_attaches):
        for attach in ue_log_attaches:
            self._write_attach_statistics_record(run, attach)
            self.averager.update(rsrp=attach.rsrp, rsrq=attach.rsrq, prach_pathloss=attach.msg1['pathloss'],
                                 prach_mtpl=attach.msg1['mtpl'], msg3_pathloss=attach.msg3['pathloss'],
                                 msg3_mtpl=attach.msg3['mtpl'])

    def _write_attach_statistics_record(self, run, attach):
        with open(self.output_csv, 'a') as output_file:
            row = "{},{},{},{},{},{},{},{},{},{}\n".format(run, attach.num_attempt, attach.outcome, attach.reason,
                                                           attach.rsrp, attach.rsrq, attach.msg1['pathloss'],
                                                           attach.msg1['mtpl'], attach.msg3['pathloss'],
                                                           attach.msg3['mtpl'])
            output_file.write(row)

    @staticmethod
    def _get_matching_bip_log_attach(ue_log_attach, bip_log_attaches):
        for bip_log_attach in bip_log_attaches:
            if ue_log_attach == bip_log_attach:
                return bip_log_attach
        return None

    def _print_attaches(self, run_nb, ue_log_attaches, bip_log_attaches):
        if ue_log_attaches is not None:
            self._print_ue_log_attaches(run_nb, ue_log_attaches)
            if not len(ue_log_attaches):
                logger.info("No attaches found in UE log!", also_to_console=True)
        if bip_log_attaches is not None:
            self._print_bip_log_attach(run_nb, bip_log_attaches)
            if not len(bip_log_attaches):
                logger.info("No no-ghost attaches found in BIP!", also_to_console=True)

    def _print_ue_log_attaches(self, run_nb, ue_log_attaches):
        logger.info(f"UE Log attaches from run {run_nb}:", also_to_console=True)
        for idx, attach in enumerate(ue_log_attaches):
            self._print_attach_banner(f'UE Log attach run {run_nb} try {idx + 1}', attach, True)

    def _print_bip_log_attach(self, run_nb, bip_log_attaches):
        logger.info(f"BIP log attaches from run {run_nb}:", also_to_console=True)
        for idx, attach in enumerate(bip_log_attaches):
            self._print_attach_banner(f'BIP Log attach run {run_nb} try {idx + 1}', attach, False)

    @staticmethod
    def _print_attach_banner(title, attach, is_ue_log_attach=True):
        banner = Banner().with_title(title)\
            .with_row('Outcome', attach.outcome)\
            .with_row('Reason', attach.reason)
        if is_ue_log_attach:
            banner.with_row('Num Attempt', attach.num_attempt)
            banner.with_row('PCI', attach.pci)
            banner.with_row('RSRP', attach.rsrp)
            banner.with_row('RSRQ', attach.rsrq)
        param_dict = {'MSG 1': attach.msg1, 'MSG 2': attach.msg2, 'MSG 3': attach.msg3}
        if is_ue_log_attach:
            param_dict.update({'MSG 4': attach.msg4})
        for msg, param_names in param_dict.items():
            banner.with_divider('=')
            banner.with_row(msg, '')
            for param_name, param_value in param_names.items():
                banner.with_row(param_name, param_value)
        banner.ascii_tag = '\033[92m' if attach.outcome == 'SUCCESS' else '\033[91m'
        logger.info(banner, also_to_console=True)

    def _print_test_setup_banner(self):
        try:
            battery_info = sanity.get_ue_battery_state()
        except AssertionError as e:
            logger.info(e, also_to_console=True)
            battery_info = {}
        logger.info(Banner().with_title(self.testname)
                    .with_row('Mode', self.cfg.mode)
                    .with_row('Multi RAT', self.common_cfg.multirat)
                    .with_row('UE Log app', self.cfg.ue_app)
                    .with_divider()
                    .with_row('Runs', self.cfg.runs)
                    .with_row('Pass ratio', self.cfg.pass_ratio)
                    .with_row('Stop upon fail', self.cfg.stop_upon_fail)
                    .with_row('Logs to collect', self._logs_to_collect_list().__repr__())
                    .with_row('Logs to analyze', self._logs_to_analyze_list().__repr__())
                    .with_row('Attach wait', self.cfg.attach_wait)
                    .with_row('Min peak petric', self.cfg.min_peak_metric)
                    .with_row('Max timing advance', self.cfg.max_timing_advance)
                    .with_divider()
                    .with_row('With commissioning',
                              'YES' if self.cfg.scf_5g is not None or self.cfg.scf_lte is not None else 'NO')
                    .with_divider()
                    .with_row('Battery level', battery_info.get('level', float('nan')))
                    .with_row('Battery temperature', str(float(battery_info.get('temperature', float('nan'))) / 10)),
                    also_to_console=True)

    def _print_summary_banner(self):
        ratio = 100 * (self.executed_runs - self.failed_runs) / float(self.executed_runs) if self.executed_runs > 0 \
            else 0
        highlight_color = '\033[92m' if ratio >= self.cfg.pass_ratio else '\033[91m'
        banner = Banner().with_title('SUMMARY') \
            .with_row('Failed/Total', f"{self.failed_runs}/{self.executed_runs}", highlight_color)\
            .with_row('Success ratio', f"{ratio}%", highlight_color)
        self._add_parameter_statistic_section_to_banner(banner, 'RSRP', 'rsrp')
        self._add_parameter_statistic_section_to_banner(banner, 'RSRQ', 'rsrq')
        self._add_parameter_statistic_section_to_banner(banner, 'PRACH Pathloss', 'prach_pathloss')
        self._add_parameter_statistic_section_to_banner(banner, 'PRACH MTPL', 'prach_mtpl')
        self._add_parameter_statistic_section_to_banner(banner, 'Msg3 Pathloss', 'msg3_pathloss')
        self._add_parameter_statistic_section_to_banner(banner, 'Msg3 MTPL', 'msg3_mtpl')
        banner.ascii_tag = '\033[96m'
        logger.info(banner, also_to_console=True)

    def _add_parameter_statistic_section_to_banner(self, banner, section_title, param_name):
        return banner.with_divider('=').with_row(section_title, '').with_divider() \
            .with_row('Average', self.averager[param_name]) \
            .with_row('Max', self.averager.max(param_name)) \
            .with_row('Min', self.averager.min(param_name))

    def _logs_to_analyze_list(self):
        names = ('BIP', 'UE_LOG', 'TCPDUMP')
        collected = (self.cfg.analyze_bip, self.cfg.analyze_ue_log, self.cfg.analyze_tcpdump)
        return [name for name, is_collected in zip(names, collected) if is_collected]

    def _check_counters_condition(self, counters):
        msg3_sum = sum(sum(value[1] for value in values) for dn, values in counters.items() if 'M55306C06001' in dn)
        msg1_sum = sum(sum(value[1] for value in values) for dn, values in counters.items() if 'M55306C03001' in dn)
        target = float(self.cfg.counters_kpi_target)
        assert msg3_sum >= self.executed_runs, \
            f"MSG3 counter M55306C06001 is less than number of executed runs: {msg3_sum} < {self.executed_runs}"
        assert msg1_sum >= self.executed_runs, \
            f"MSG1 counter M55306C03001 is less than number of executed runs: {msg1_sum} < {self.executed_runs}"
        ratio = msg3_sum * 100 / msg1_sum
        logger.info(f"Calculated counters ratio msg3/msg1 = {ratio}", also_to_console=True)
        assert ratio >= target, \
            f"ratio of MSG3 counter M55306C06001 to MSG1 counter M55306C03001 doesn't meet target: {ratio} < {target}"

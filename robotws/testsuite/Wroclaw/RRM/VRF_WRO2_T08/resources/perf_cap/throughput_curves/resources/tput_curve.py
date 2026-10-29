import os
from time import monotonic, sleep
from typing import Any

import testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.sanity_checks as sanity
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.resources.perfcap_test_interface import (
    PerfCapTestInterface,
)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.resources.fader import Fader
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.averager import Averager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.banner import Banner
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.dialog import dialog
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.exceptions import UeDropped
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.meta_test import AttenuatorInterface
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

from .bip_verification import BipParser
from .elt_verification import EltLogParser
from .qxdm_verification import get_stats_from_qxdm_log
from .tput_curves_config import TputCurvesConfigParser
from .tti_verification import analyze_tti


class TputCurve(PerfCapTestInterface, AttenuatorInterface):
    _stat_types = ("avg", "min", "max", "var")

    def __init__(self) -> None:
        """Initialize throughput curve test instance."""

        if self._is_instance_locked():
            return
        super().__init__(config_parser=TputCurvesConfigParser)
        self._bip_bare_stat_names = []
        self._bip_parser = BipParser()
        self._ue_log_bare_stat_names = []
        self._elt_parser = EltLogParser()
        self._tti_bare_stat_names = []
        self._current_sweep = 1
        self.report_name = "TPUT_CURVE"
        self.report_status = "failed"
        self._tput_start_time = 0

    def suite_setup(self, config: dict[str, Any] | None = None) -> None:
        """Perform suite-level setup.

        :param config: Optional configuration dictionary for the suite.
        """
        super().suite_setup(config)

    def test_setup(self, testname: str | None = None) -> None:
        """Perform test-level setup.

        :param testname: Optional test name used for reporting.
        """
        super().test_setup(testname)
        if not self.cfg.no_attenuator:
            if self.cfg.use_fader:
                self.setup_fader()
            else:
                self.setup_attenuator()
        self._ue_log_bare_stat_names = TputCurve._get_bare_stat_names(self.cfg.analyze_ue_log)
        self._bip_bare_stat_names = TputCurve._get_bare_stat_names(self.cfg.analyze_bip)
        self._tti_bare_stat_names = TputCurve._get_bare_stat_names(self.cfg.analyze_tti)
        self._print_test_setup_banner()
        self._bip_parser.sw_branch = self._sw_branch

    def setup_fader(self) -> None:
        """Initialize and register fader for teardown."""

        self.fader = Fader()
        self.fader.setup(self.cfg.fader['ip'], self.cfg.fader['port'])
        self.schedule_test_teardown_function("teardown fader", self.fader.teardown, [])

    def run(self) -> None:
        """Run the throughput curve test sweeps."""

        reached_attenuation = -1
        init_atten, atten_step, final_atten = self._get_attenuation_settings()
        if self.cfg.no_attenuator:
            dialog("No attenuator mode", "Manually set initial conditions for 1st step")
        else:
            if self.cfg.use_fader:
                self.fader.set_vertex_attenuation(str(init_atten), self.cfg.fader['ch_ports'])
            else:
                self.attenuator.set_attenuation(self.cfg.cell, str(init_atten) + "dB")
        if self.cfg.no_taf_ue:
            dialog("No taf.ue mode", "Manually attach UE, run desired throughput and click 'ok' to proceed")
        else:
            self.attach_ue(self._ue_alias)
            self._start_tput_on_ue()
            self._tput_start_time = monotonic()
        for sweep in range(self.cfg.sweeps):
            self._current_sweep = sweep + 1
            self._set_iterations(reached_attenuation)
            try:
                reached_attenuation = self._execute_log_threads()
            except UeDropped as e:
                logger.info(e, also_to_console=True)
                if atten_step < 0 <= e.attenuation:
                    raise EnvironmentError("UE dropped on reversed sweep")
                if self._current_sweep < self.cfg.sweeps:
                    reached_attenuation = self._regain_attach_and_tput(e.attenuation)

    def _get_attenuation_settings(self):
        return self.cfg.init_atten, self.cfg.atten_step, self.cfg.final_atten

    def _set_iterations(self, reached_attenuation):
        if self._current_sweep % 2:
            self._iterations = range(
                self.cfg.init_atten, self.cfg.final_atten + (1 if self.cfg.atten_step >= 0 else -1), self.cfg.atten_step
            )
        else:
            start = reached_attenuation if reached_attenuation != self.cfg.final_atten else self.cfg.final_atten
            self._iterations = range(
                start, self.cfg.init_atten - (1 if self.cfg.atten_step >= 0 else -1), self.cfg.atten_step
            )

    @staticmethod
    def _reverse_attenuation(init_atten, atten_step, final_atten, drop_point):
        atten_step *= -1
        init_atten, final_atten = (final_atten if drop_point < 0 else drop_point + atten_step, init_atten)
        return init_atten, atten_step, final_atten

    def _start_tput_on_ue(self):
        self.start_tput_on_ue(
            self._ue_alias,
            direction=self.cfg.tput_direction,
            duration=36000,
            protocol=self.cfg.tput_protocol,
            packet_size=self.cfg.packet_size,
            max_segment_size=self.cfg.max_segment_size,
            buffer=self.cfg.buffer_size,
            throughput="max",
        )

    def _regain_attach_and_tput(self, start_point):
        if self.cfg.no_taf_ue:
            dialog(
                "No taf.ue mode",
                "UE probably dropped. Currently multiple sweeps are not supported in"
                " no-taf.ue mode. Press 'ok' to exit...",
            )
            raise EnvironmentError("Multiple sweeps are not yet supported in no-taf.ue mode")
        self.stop_tput_on_ue(self._ue_alias, direction=self.cfg.tput_direction)
        self.detach_ue(self._ue_alias)
        for attenuation in range(start_point, self.cfg.init_atten, abs(self.cfg.atten_step) * -1):
            if self.cfg.no_attenuator:
                dialog("No attenuator mode", "Multiple sweeps are not yet supported in no-attenuator mode")
                raise EnvironmentError("Multiple sweeps are not yet supported in no-taf.ue mode")
            self.attenuator.set_attenuation(self.cfg.cell, str(attenuation) + "dB")
            sleep(5)
            try:
                self.attach_ue(ue_alias=self._ue_alias)
                self._start_tput_on_ue()
                logger.info("Regained attach on attenuation {}dB".format(attenuation), also_to_console=True)
                return attenuation
            except Exception:
                logger.info("Regaining attach failed on attenuation {}dB".format(attenuation), also_to_console=True)
        raise EnvironmentError("Could not reattach")

    def gather_logs(self, attenuation: int) -> dict[str, Any]:
        """Collect verification logs for a given attenuation.

        :param attenuation: Attenuation value in dB.
        :returns: Dictionary with collected log paths and related data.
        """
        current_subdir = self._create_subdirectory(f"{attenuation}dB", self.test_dir)
        if self.cfg.no_attenuator:
            dialog(
                "No attenuator mode",
                f"Set attenuation for the next step and click 'ok' to proceed. "
                f"Expected attenuation: {attenuation}dB",
            )
        else:
            if self.cfg.use_fader:
                self.fader.set_vertex_attenuation(str(attenuation), self.cfg.fader['ch_ports'])
            else:
                self.attenuator.set_attenuation(self.cfg.cell, str(attenuation) + "dB")
        sleep(self.cfg.tput_adjustment_time)
        self.start_verification_collectors()
        omit_time = monotonic() - self._tput_start_time
        sleep(self.cfg.tput_duration)
        self.stop_verification_collectors()
        files = self.download_verification_logs(
            os.path.join(current_subdir, f"sweep{self._current_sweep}_" f"{self._get_formatted_log_prefix()}")
        )
        if not self.cfg.no_taf_ue:
            if "DL" in self.cfg.tput_direction.upper():
                dl_iperf_tput = self.get_average_tput(self._ue_alias, "DL", omit=omit_time)
                files["iperf_dl"] = dl_iperf_tput
            if "UL" in self.cfg.tput_direction.upper():
                ul_iperf_tput = self.get_average_tput(self._ue_alias, "UL", omit=omit_time)
                files["iperf_ul"] = ul_iperf_tput
        files["attenuation"] = attenuation
        print(f"Log files: {files}")
        return files

    def analyze_logs(self, logs: dict[str, Any]) -> int:
        """Analyze collected logs and determine drop condition.

        :param logs: Dictionary with collected log paths and statistics.
        :returns: Attenuation value associated with analyzed logs.
        :raises UeDropped: When UE is considered dropped based on statistics.
        """
        bip_stats = self._get_stats_from_bip(logs["bip"]) if "bip" in logs else Averager()
        ue_log_stats = (
            self._get_stats_from_ue_log(logs[self.cfg.ue_app.lower()][0])
            if self.cfg.ue_app.lower() in logs
            else Averager()
        )
        tti_stats = self._get_stats_from_tti(logs["tti"]) if "tti" in logs else Averager()
        iperf_stats = {}
        if not self.cfg.no_taf_ue:
            if "iperf_dl" in logs:
                iperf_stats["DL"] = logs["iperf_dl"]
            if "iperf_ul" in logs:
                iperf_stats["UL"] = logs["iperf_ul"]
        self._write_csv_record(logs["attenuation"], bip_stats, ue_log_stats, tti_stats, iperf_stats)
        if self._is_dropped(bip_stats, ue_log_stats):
            raise UeDropped(attenuation=logs["attenuation"], rsrp=ue_log_stats["rsrp"])
        return logs["attenuation"]

    def _get_stats_from_ue_log(self, ue_log):
        if isinstance(ue_log, list):
            return self._get_stats_from_qxdm_log(ue_log[0])
        return self._get_stats_from_elt_log(ue_log)

    def _get_stats_from_qxdm_log(self, qxdm_log):
        stats = get_stats_from_qxdm_log(qxdm_log, self._ue_log_bare_stat_names)
        return stats

    def _get_stats_from_elt_log(self, elt_log):
        stats = self._elt_parser.analyze_log(logfile=elt_log)
        self._elt_parser.reset()
        return stats

    def _get_stats_from_bip(self, bip):
        stats = self._bip_parser.analyze_log(logfile=bip, stat_names=self._bip_bare_stat_names)
        self._bip_parser.reset()
        return stats

    def _get_stats_from_tti(self, tti):
        stats = analyze_tti(pcap_path=tti, output_file_path="/tmp/tti", param_names=self._tti_bare_stat_names)
        return stats

    @staticmethod
    def _get_bare_stat_names(names):
        bare_names = []
        for name in names:
            name_splited = name.split("_", maxsplit=1)
            if name_splited[0] in TputCurve._stat_types:
                bare_names.append(name_splited[-1])
            else:
                bare_names.append(name)
        return bare_names

    def _create_output_csv(self):
        init_row = ["attenuation"]
        if not self.cfg.no_taf_ue:
            if "DL" in self.cfg.tput_direction.upper():
                init_row.append("dl_iperf_tput")
            if "UL" in self.cfg.tput_direction.upper():
                init_row.append("ul_iperf_tput")
        header = init_row + self.cfg.analyze_bip + self.cfg.analyze_ue_log + self.cfg.analyze_tti
        with open(self.output_csv, "w") as output_file:
            output_file.write(",".join(header))
            output_file.write("\n")

    def _write_csv_record(self, attenuation, bip_stats, ue_log_stats, tti_stats, iperf_stats):
        init_row = [str(attenuation)]
        if "DL" in iperf_stats:
            init_row.append(str(iperf_stats["DL"]))
        if "UL" in iperf_stats:
            init_row.append(str(iperf_stats["UL"]))
        row = (
            init_row
            + self._get_stats_row(self.cfg.analyze_bip, bip_stats)
            + self._get_stats_row(self.cfg.analyze_ue_log, ue_log_stats)
            + self._get_stats_row(self.cfg.analyze_tti, tti_stats)
        )
        with open(self.output_csv, "a") as output_file:
            joined_row = ",".join(row)
            output_file.write(f"{joined_row}\n")
            logger.info(joined_row, also_to_console=True)

    @staticmethod
    def _get_stats_row(stat_names, log_stats):
        parsed_stats = []
        if not stat_names:
            return parsed_stats
        stat_types = {"avg": log_stats.avg, "max": log_stats.max, "min": log_stats.min, "var": log_stats.var}
        for name in stat_names:
            name_split = name.split("_", maxsplit=1)
            if "$" in name:
                stat = log_stats.count(name.replace("$", ""))
            elif name_split[0] in stat_types:
                stat = stat_types[name_split[0]](name_split[-1])
            else:
                stat = log_stats[name]
            parsed_stats.append("%.3f" % round(stat, 3))
        return parsed_stats

    def _is_dropped(self, bip_stats, ue_log_stats):
        if self.cfg.ue_log:
            return False if ue_log_stats.count("rsrp") else True
        if self.cfg.bip:
            return False if bip_stats.count("dl_mcs") or bip_stats.count("ul_mcs") else True
        return False

    def _print_test_setup_banner(self):
        try:
            battery_info = sanity.get_ue_battery_state()
        except AssertionError as e:
            logger.info(e, also_to_console=True)
            battery_info = {}
        logger.info(
            Banner()
            .with_title(self.testname)
            .with_row("Cell", self.cfg.cell)
            .with_row("Mode", self.cfg.mode)
            .with_row("Multi RAT", self.common_cfg.multirat)
            .with_row("UE Log app", self.cfg.ue_app)
            .with_row("Skip taf.ue and NAA", self.cfg.no_taf_ue)
            .with_divider("=")
            .with_row(
                "Attenuation", "{} - {} - {}".format(self.cfg.init_atten, self.cfg.atten_step, self.cfg.final_atten)
            )
            .with_row(
                "Throughput",
                "{} - {} - {}s/step - {}s for adjustment".format(
                    self.cfg.tput_direction,
                    self.cfg.tput_protocol,
                    self.cfg.tput_duration,
                    self.cfg.tput_adjustment_time,
                ),
            )
            .with_row("Sweeps", self.cfg.sweeps)
            .with_row("Logs to collect", self._logs_to_collect_list().__repr__())
            .with_row("Logs to analyze", self._logs_to_analyze_list().__repr__())
            .with_divider("=")
            .with_row(
                "With commissioning", "YES" if self.cfg.scf_5g is not None or self.cfg.scf_lte is not None else "NO"
            )
            .with_divider()
            .with_row("Battery level", battery_info.get("level", float("nan")))
            .with_row("Battery temperature", str(float(battery_info.get("temperature", float("nan"))) / 10)),
            also_to_console=True,
        )

    def _logs_to_analyze_list(self):
        names = ("BIP", "UE_LOG", "TTI")
        collected = (self.cfg.analyze_bip, self.cfg.analyze_ue_log, self.cfg.analyze_tti)
        return [name for name, is_collected in zip(names, collected) if is_collected]

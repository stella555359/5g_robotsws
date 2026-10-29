from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.resources.perfcap_config_parser import (
    PerfCapConfig, PerfCapConfigParser)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.exceptions import \
    TestConfigError


class TputCurvesConfigParser(PerfCapConfigParser):
    protocol_values = ("tcp", "udp")
    direction_values = ("UL", "DL", "ULDL", "DLUL")

    def __init__(self):
        super().__init__()
        self.default = TputCurveTestConfig()
        self.testcases_section = "ThroughputCurves"

    def parse_testdata(self, testdata):
        config = TputCurveTestConfig()
        self._load_general_params(config, testdata)
        self._load_attenuation_params(config, testdata)
        self._load_tput_params(config, testdata)
        self._load_logs_params(config, testdata)
        self._load_scf_params(config, testdata)
        return config

    def _load_general_params(self, config, testdata):
        super()._load_general_params(config, testdata)
        config.cell = super()._get_param(testdata, "Cell", str, self.default.cell)
        config.pci = config.cell.split("_")[-1]
        config.sweeps = super()._get_param(testdata, "Sweeps", int, self.default.sweeps)
        config.no_taf_ue = super()._get_param(testdata, "NoTafUe", bool, self.default.no_taf_ue)
        config.no_attenuator = super()._get_param(testdata, "NoAttenuator", bool, self.default.no_attenuator)
        config.use_fader = super()._get_param(testdata, "UseFader", bool, self.default.use_fader)
        config.fader = super()._get_param(testdata, "Fader", dict, {})

    def _load_attenuation_params(self, config, testdata):
        attenuation = super()._get_param(testdata, "Attenuation", dict, {})
        config.init_atten = super()._get_param(attenuation, "init", int, self.default.init_atten)
        config.atten_step = super()._get_param(attenuation, "step", int, self.default.atten_step)
        config.final_atten = super()._get_param(attenuation, "final", int, self.default.final_atten)

    def _load_tput_params(self, config, testdata):
        tput = super()._get_param(testdata, "Throughput", dict, {})
        config.tput_direction = super()._get_param(tput, "direction", str, self.default.tput_direction)
        if config.tput_direction not in TputCurvesConfigParser.direction_values:
            raise TestConfigError(
                f"tput direction value ({config.tput_direction}) should be one of "
                f"{TputCurvesConfigParser.direction_values}"
            )
        config.tput_protocol = super()._get_param(tput, "protocol", str, self.default.tput_protocol)
        if config.tput_protocol not in TputCurvesConfigParser.protocol_values:
            raise TestConfigError(
                f"tput protocol value ({config.tput_protocol}) should be one of "
                f"{TputCurvesConfigParser.protocol_values}"
            )
        config.tput_duration = super()._get_param(tput, "duration", float, self.default.tput_duration)
        config.tput_adjustment_time = super()._get_param(
            tput, "adjustment_time", float, self.default.tput_adjustment_time
        )
        config.max_segment_size = super()._get_param(tput, "max_segment_size", int, self.default.max_segment_size)
        config.packet_size = super()._get_param(tput, "packet_size", int, self.default.packet_size)
        config.buffer_size = super()._get_param(tput, "buffer_size", str, self.default.buffer_size)

    def _load_logs_params(self, config, testdata):
        super()._load_logs_params(config, testdata)
        logs = super()._get_param(testdata, "Logs", dict, {})

        bip = super()._get_param(logs, "BIP", dict, {})
        config.analyze_bip = super()._get_param(bip, "Analyze", list, self.default.analyze_bip)
        if not config.bip:
            config.analyze_bip = []

        ue_log = super()._get_param(logs, "UE_LOG", dict, {})
        config.analyze_ue_log = super()._get_param(ue_log, "Analyze", list, self.default.analyze_ue_log)
        if not config.ue_log:
            config.analyze_ue_log = []

        tti = super()._get_param(logs, "TTI", dict, {})
        config.analyze_tti = super()._get_param(tti, "Analyze", list, self.default.analyze_bip)
        if not config.tti:
            config.analyze_tti = []

        config.csv_header = ("attenuation", *config.analyze_bip, *config.analyze_ue_log, *config.analyze_tti)


class TputCurveTestConfig(PerfCapConfig):
    def __init__(self):
        super().__init__()
        self.cell = "random"
        self.pci = None
        self.sweeps = 1
        self.no_taf_ue = False
        self.no_attenuator = False
        self.use_fader = False
        self.fader = {}

        self.init_atten = 30
        self.atten_step = 5
        self.final_atten = 90

        self.tput_direction = "DL"
        self.tput_protocol = "tcp"
        self.tput_duration = 20
        self.max_segment_size = 1200
        self.packet_size = 1400
        self.buffer_size = "7M"
        self.tput_adjustment_time = 10

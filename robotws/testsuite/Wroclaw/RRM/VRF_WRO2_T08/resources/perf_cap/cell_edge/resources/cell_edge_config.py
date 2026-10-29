from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.resources.perfcap_config_parser import PerfCapConfigParser, \
    PerfCapConfig


class CellEdgeConfigParser(PerfCapConfigParser):
    def __init__(self):
        super().__init__()
        self.default = CellEdgeTestConfig()
        self.testcases_section = "CellEdge"

    def parse_testdata(self, testdata):
        config = CellEdgeTestConfig()
        self._load_general_params(config, testdata)
        self._load_logs_params(config, testdata)
        self._load_scf_params(config, testdata)
        return config

    def _load_general_params(self, config, testdata):
        super()._load_general_params(config, testdata)
        config.runs = super()._get_param(testdata, 'Runs', int, self.default.runs)
        config.pass_ratio = super()._get_param(testdata, 'PassRatio', float, self.default.pass_ratio)
        config.stop_upon_fail = super()._get_param(testdata, 'StopUponFail', bool, self.default.stop_upon_fail)
        config.attach_wait = super()._get_param(testdata, 'AttachWait', int, self.default.attach_wait)
        config.min_peak_metric = super()._get_param(testdata, 'MinPeakMetric', int, self.default.min_peak_metric)
        config.max_timing_advance = super()._get_param(testdata, 'MaxTimingAdvance', int,
                                                       self.default.max_timing_advance)
        config.allowed_fails = int(config.runs * (1 - (config.pass_ratio / 100.0)))
        config.check_counters = super()._get_param(testdata, 'CheckCounters', bool, self.default.check_counters)
        config.counters_kpi_target = super()._get_param(testdata, 'CountersKPITarget',
                                                        int, self.default.counters_kpi_target)
        config.imsi = super()._get_param(testdata, 'IMSI', str, self.default.imsi)


class CellEdgeTestConfig(PerfCapConfig):
    def __init__(self):
        super().__init__()
        self.runs = 1
        self.pass_ratio = 0.99
        self.allowed_fails = 0
        self.min_peak_metric = 30000
        self.max_timing_advance = 5
        self.stop_upon_fail = True
        self.attach_wait = 8
        self.check_counters = True
        self.counters_kpi_target = 97
        self.imsi = '0'
        self.csv_header = ('attach_run', 'rach_attempt', 'result', 'reason', 'rsrp', 'rsrq', 'prach_pathloss',
                           'prach_mtpl', 'msg3_pathloss', 'msg3_mtpl')

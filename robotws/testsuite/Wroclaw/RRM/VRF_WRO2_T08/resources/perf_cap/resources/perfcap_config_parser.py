from os.path import exists

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.exceptions import TestConfigError
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.meta_test_parser import MetaConfigParser


class PerfCapConfigParser(MetaConfigParser):
    mode_values = ('NSA', 'SA')
    ue_app_values = ('QXDM', 'ELT')

    def __init__(self):
        super().__init__()
        self.default = PerfCapConfig()
        self.testcases_section = "PerfCap"

    def parse(self, config):
        super().parse(config)
        tests = MetaConfigParser._get_param(self.tests, self.testcases_section, dict, {})
        self.tests = {}
        default_test = tests.get('DEFAULT', None)
        if isinstance(default_test, dict):
            self.default = self.parse_testdata(default_test)
        for testname, testdata in tests.items():
            if testname == 'DEFAULT':
                continue
            if not isinstance(testdata, dict):
                raise TypeError(f"Testcase {testname} should provide an instance of dict")
            self.tests[testname] = self.parse_testdata(testdata)

    def parse_testdata(self, testdata):
        raise NotImplementedError

    def _load_general_params(self, config, testdata):
        config.mode = MetaConfigParser._get_param(testdata, 'Mode', str, self.default.mode).upper()
        if config.mode not in PerfCapConfigParser.mode_values:
            raise TestConfigError(f"Mode value ({config.mode}) should be one of {PerfCapConfigParser.mode_values}")
        config.ue_app = MetaConfigParser._get_param(testdata, 'UeLogApp', str, self.default.ue_app).upper()
        if config.ue_app not in PerfCapConfigParser.ue_app_values:
            raise TestConfigError(f"UeLogApp value ({config.ue_app}) should be one of "
                                  f"{PerfCapConfigParser.ue_app_values}")
        config.log_prefix = MetaConfigParser._get_param(testdata, 'LogPrefix', str, self.default.log_prefix)

    def _load_logs_params(self, config, testdata):
        logs = MetaConfigParser._get_param(testdata, 'Logs', dict, {})
        bip = MetaConfigParser._get_param(logs, 'BIP', dict, {})
        config.bip = MetaConfigParser._get_param(bip, 'Collect', bool, self.default.bip)
        config.analyze_bip = MetaConfigParser._get_param(bip, 'Analyze', bool, self.default.analyze_bip)
        if not config.bip:
            config.analyze_bip = False
        ue_log = MetaConfigParser._get_param(logs, 'UE_LOG', dict, {})
        config.ue_log = MetaConfigParser._get_param(ue_log, 'Collect', bool, self.default.ue_log)
        config.analyze_ue_log = MetaConfigParser._get_param(ue_log, 'Analyze', bool, self.default.analyze_ue_log)
        if not config.ue_log:
            config.analyze_ue_log = False
        tti = MetaConfigParser._get_param(logs, 'TTI', dict, {})
        config.tti = MetaConfigParser._get_param(tti, 'Collect', bool, self.default.tti)
        config.analyze_tti = MetaConfigParser._get_param(tti, 'Analyze', bool, self.default.analyze_tti)
        if not config.tti:
            config.analyze_tti = False
        snapshot = MetaConfigParser._get_param(logs, 'SNAPSHOT', dict, {})
        config.snapshot = MetaConfigParser._get_param(snapshot, 'Collect', bool, self.default.snapshot)
        config.analyze_snapshot = MetaConfigParser._get_param(snapshot, 'Analyze', bool, self.default.analyze_snapshot)
        if not config.snapshot:
            config.analyze_snapshot = False
        btslog = MetaConfigParser._get_param(logs, 'BTSLOG', dict, {})
        config.btslog = MetaConfigParser._get_param(btslog, 'Collect', bool, self.default.btslog)
        config.analyze_btslog = MetaConfigParser._get_param(btslog, 'Analyze', bool, self.default.analyze_btslog)
        if not config.btslog:
            config.analyze_btslog = False
        tcpdump = MetaConfigParser._get_param(logs, 'TCPDUMP', dict, {})
        config.tcpdump = MetaConfigParser._get_param(tcpdump, 'Collect', bool, self.default.tcpdump)
        config.analyze_tcpdump = MetaConfigParser._get_param(tcpdump, 'Analyze', bool, self.default.analyze_tcpdump)
        if not config.tcpdump:
            config.analyze_tcpdump = False

    def _load_scf_params(self, config, testdata):
        config.scf_5g = MetaConfigParser._get_param(testdata, 'SCF_5g', str, self.default.scf_5g)
        config.scf_lte = MetaConfigParser._get_param(testdata, 'SCF_lte', str, self.default.scf_lte)
        if not config.scf_5g or config.scf_5g == 'None':
            config.scf_5g = None
        elif not exists(config.scf_5g):
            raise TestConfigError(f"SCF 5g path ({config.scf_5g}) points to non-existent file")
        if not config.scf_lte or config.scf_lte == 'None':
            config.scf_lte = None
        elif not exists(config.scf_lte):
            raise TestConfigError(f"SCF lte path ({config.scf_lte}) points to non-existent file")


class PerfCapConfig:
    def __init__(self):
        self.mode = 'SA'
        self.ue_app = 'ELT'
        self.csv_header = ('run', 'value')

        self.bip = False
        self.analyze_bip = False
        self.ue_log = False
        self.analyze_ue_log = False
        self.tti = False
        self.analyze_tti = False
        self.snapshot = False
        self.analyze_snapshot = False
        self.btslog = False
        self.analyze_btslog = False
        self.tcpdump = False
        self.analyze_tcpdump = False

        self.scf_5g = None
        self.scf_lte = None
        self.log_prefix = 'tput_curve_{datetime}'

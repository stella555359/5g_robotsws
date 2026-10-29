from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.exceptions import TestConfigError


class MetaConfigParser:
    def __init__(self):
        self.tests = {}
        self.default = {}
        self.common_config = CommonConfig()

    def parse(self, config):
        config = MetaConfigParser._get_param(config, 'TEST_CONFIG', dict, {})
        self._parse_report_section(config)
        self._parse_backup_section(config)
        self.common_config.multirat = MetaConfigParser._get_param(config, 'MultiRAT', bool, False)
        self.tests = MetaConfigParser._get_param(config, 'Testcases', dict, {})

    def _parse_report_section(self, config):
        cfg = MetaConfigParser._get_param(config, 'Report', dict, {})
        self.common_config.make_report = MetaConfigParser._get_param(cfg, 'MakeReport', bool, False)
        self.common_config.hostname = MetaConfigParser._get_param(cfg, 'Hostname', str, "invalid_hostname")
        self.common_config.tl_type = MetaConfigParser._get_param(cfg, 'TestlineType', str, "invalid_tl_type")

    def _parse_backup_section(self, config):
        cfg = MetaConfigParser._get_param(config, 'Backup', dict, {})
        self.common_config.backup_scf_5g = MetaConfigParser._get_param(cfg, 'SCF_5g', bool, True)
        self.common_config.backup_scf_lte = MetaConfigParser._get_param(cfg, 'SCF_lte', bool, False)

    @staticmethod
    def _get_param(config, param_name, param_type, default_value=None):
        try:
            param = config[param_name]
        except KeyError:
            return default_value
        try:
            return param_type(param)
        except (TypeError, ValueError):
            raise TestConfigError(f"Parameter '{param_name}' type ({type(param)}) is wrong. Expected: {param_type}")


class CommonConfig:
    def __init__(self):
        self.make_report = False
        self.hostname = "invalid_hostname"
        self.tl_type = "invalid_tl_type"
        self.backup_scf_5g = True
        self.backup_scf_lte = False
        self.multirat = False

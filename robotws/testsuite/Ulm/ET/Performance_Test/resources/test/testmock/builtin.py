
import logging

logger = logging.getLogger(__name__)


class BuiltInMock():
    """until we set up unit test, this will do
    """

    def __init__(self, variable_values=None):
        variable_values = {} if variable_values is None else variable_values
        default_values = {
            "WORKSPACE": "/tmp",
            "TP": {
                "SET_TRAFFIC_SLEEP": 0,
                "CFG_KPI_TOLERANCE": 0,
                "CFG_TTI_TRACE_QUICK_DURATION": 0,
                "BUILD_ID": 0,
                "CFG_DELAY_SNAPSHOT_CAPTURE": 0,
                "ENABLE_LOG_ARCHIVE_COMPRESSION": "true",
                "ENABLE_LOG_ARCHIVE": "false"
            },
            "SUITE_METADATA": {
                "Duplex Mode Info": "null",
            },
            "TURANDOT_FILES_QUEUE": []
        }
        default_values.update(variable_values)
        self.variable_values = self._cleanup_dict(default_values)

    def get_variable_value(self, *args, **_):
        var = self._clean_var(args[0])
        return self.variable_values.get(var, "")

    def run_keyword(self, *args, **kwargs):
        if args[0] == "performance_log_collection.Wait and collect one measurement cycle":
            return ''
        if args[0] == "pmcounters.Fetch Measurement Period from GNB":
            return 300
        if args[0] == "pmcounters.Fetch Measurement Period from SCF":
            return 300
        return args, kwargs

    def set_test_variable(self, *args, **_):
        return self.variable_values.update({
            args[0]: args[1]
        })

    def log(self, *args, level="INFO"):
        getattr(logger, level.lower())(args)

    def log_to_console(self, *args):
        self.log(*args)

    def _cleanup_dict(self, dictionary):
        new_dictionary = {}
        for key, value in dictionary.items():
            new_dictionary.update({
                self._clean_var(key): value
            })
        return new_dictionary

    def _clean_var(self, var):
        if var.startswith(r'${') and var.endswith(r'}'):
            var = var[:-1][2:]
        return var.replace(" ", "").replace("_", "").lower()

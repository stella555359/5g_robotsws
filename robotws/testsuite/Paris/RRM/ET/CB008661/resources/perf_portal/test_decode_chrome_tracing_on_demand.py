import subprocess
import sys
import unittest
from unittest.mock import patch, call
from importlib.util import spec_from_file_location, module_from_spec
from decode_chrome_tracing_on_demand import TMP_DIR
from decode_chrome_tracing_on_demand import CHROME_TRACING_CONVERTER
from decode_chrome_tracing_on_demand import CHROME_TRACING_2HTML
from decode_chrome_tracing_on_demand import DEST_DIR

SUBPROCESS_RESULT_OK = subprocess.run(
    "/bin/ls -1", shell=True, check=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE
)
SUBPROCESS_RESULT_NOK = subprocess.run(
    "/bin/ls -1 /kk", shell=True, check=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE
)


class Test(unittest.TestCase):
    def setUp(self):
        self.fixture = {
            "args": ["decode_chrome_tracing_on_demand.py", "TimeMarkerSnapshot_file.json.xz"],
            "env": {"PERF_PORTAL_DEV_MODE": "true"},
            "pid": 9999,
            "run_args": {
                "shell": True,
                "check": False,
                "universal_newlines": True,
                "stdout": subprocess.PIPE,
                "stderr": subprocess.PIPE,
            },
        }
        self.fixture["tmp_dir"] = f"{TMP_DIR}/{self.fixture['pid']}_TimeMarkerSnapshot_file.json"

        self.mocker = {
            "stdout": patch("sys.stdout.write", autospec=True).start(),
            "mkdir": patch("os.mkdir", autospec=True).start(),
            "getpid": patch("os.getpid", autospec=True).start(),
            "run": patch("subprocess.run", autospec=True).start(),
            "report": patch("report.Report", autospec=True).start(),
        }

        self.mocker["getpid"].return_value = self.fixture["pid"]
        self.mocker["run"].return_value = SUBPROCESS_RESULT_OK

        self.addCleanup(patch.stopall)

    def launch_decoder(self):
        with patch.object(sys, "argv", self.fixture["args"]):
            with patch.dict("os.environ", values=self.fixture["env"]):
                spec = spec_from_file_location("__main__", "decode_chrome_tracing_on_demand.py")
                module = module_from_spec(spec)
                spec.loader.exec_module(module)

    def test_no_param(self):
        self.fixture["args"] = ["decode_chrome_tracing_on_demand.py"]
        self.assertRaises(SystemExit, self.launch_decoder)

    def test_too_much_param(self):
        self.fixture["args"].append("something_not_requested")
        self.assertRaises(SystemExit, self.launch_decoder)

    def test_run_except(self):
        self.mocker["run"].return_value = EnvironmentError
        self.launch_decoder()
        self.mocker["run"].assert_called_once()
        self.mocker["report"].return_value.error.assert_called_once_with()

    def test_run_return_non_zero(self):
        self.mocker["run"].return_value = SUBPROCESS_RESULT_NOK
        self.launch_decoder()
        self.mocker["run"].assert_called_once()
        self.mocker["report"].return_value.error.assert_called_once_with()

    def test_ok(self):
        self.launch_decoder()
        self.mocker["mkdir"].assert_called_once_with(self.fixture["tmp_dir"])
        run_calls = [
            call(
                f"/bin/xz -cd TimeMarkerSnapshot_file.json.xz > {self.fixture['tmp_dir']}"
                "/TimeMarkerSnapshot_file.json",
                **self.fixture["run_args"],
            ),
            call(
                f"python3 {CHROME_TRACING_CONVERTER} -f {self.fixture['tmp_dir']}"
                "/TimeMarkerSnapshot_file.json"
                f" -o {self.fixture['tmp_dir']}/ChromeTracingSnapshot_file.json",
                **self.fixture["run_args"],
            ),
            call(
                f"{CHROME_TRACING_2HTML} {self.fixture['tmp_dir']}/ChromeTracingSnapshot_file.json",
                **self.fixture["run_args"],
            ),
            call(
                f"mv {self.fixture['tmp_dir']}/ChromeTracingSnapshot_file.html "
                f"{DEST_DIR}/ChromeTracingSnapshot_file.html",
                **self.fixture["run_args"],
            ),
            call(
                f"rm -rf {self.fixture['tmp_dir']}",
                **self.fixture["run_args"],
            ),
        ]
        self.mocker["run"].assert_has_calls(run_calls)
        self.assertEqual(self.mocker["run"].call_count, len(run_calls))
        self.mocker["report"].return_value.error.assert_not_called()

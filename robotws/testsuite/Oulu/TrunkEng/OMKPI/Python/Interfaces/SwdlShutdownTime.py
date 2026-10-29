"""
SWDL shutdown time check: download messages* from /var/log/last.0, run filter_unit_stop_times.py,
log important script output to eventlog (verbose upstream INFO: lines to debug), and fail if any unit exceeded
threshold.
The upstream script writes reports under /tmp; SwdlShutdownTime copies them into shutdown_time in the log dir.
"""
import os
import re
import shutil
import subprocess
import sys
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.OMKPI.Python.Resources.exceptions import SwdlShutdownTimeFailure

REMOTE_LOG_DIR = "/var/log/last.0"
SHUTDOWN_TIME_DIR_NAME = "shutdown_time"
# Upstream filter_unit_stop_times.py writes here; we copy into shutdown_time_dir under the test log.
TMP_LONG_DURATIONS = "/tmp/long_durations.txt"
TMP_UNIT_STOP_DURATIONS = "/tmp/unit_stop_durations.txt"
LONG_DURATIONS_FILE = "long_durations.txt"
UNIT_STOP_DURATIONS_FILE = "unit_stop_durations.txt"


class SwdlShutdownTime(object):
    """Check SWDL shutdown times by running filter_unit_stop_times.py on downloaded messages* logs."""

    def __init__(self):
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.ssh = BuiltIn().get_library_instance("SSH")

    def _get_admin_ip(self):
        ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}", default=None)
        return ip if ip else "192.168.255.129"

    def _get_filter_script_path(self):
        """Return absolute path to filter_unit_stop_times.py in OMKPI Resources."""
        interfaces_dir = os.path.dirname(os.path.abspath(__file__))
        script_path = os.path.join(interfaces_dir, "..", "Resources", "filter_unit_stop_times.py")
        return os.path.normpath(os.path.abspath(script_path))

    def _list_message_files_on_remote(self, ip):
        """List files matching messages* in /var/log/last.0 on the BTS via SSH."""
        output = self.ssh.connection_command_and_output(
            f"ls {REMOTE_LOG_DIR}", ip=ip, use_existing_connection=False
        )
        if not output:
            return []
        # Parse ls output: split on whitespace, keep tokens that contain 'messages'
        tokens = re.split(r"\s+", output.strip())
        message_files = [t for t in tokens if t and "messages" in t]
        return [os.path.join(REMOTE_LOG_DIR, name) for name in message_files]

    def _download_message_files(self, remote_paths, shutdown_time_dir, ip):
        """Download the given remote file paths into shutdown_time_dir."""
        if not remote_paths:
            warning(f"No messages* files found in {REMOTE_LOG_DIR} on BTS.")
            return
        self.ssh.connection_and_download_file(
            remote_paths, shutdown_time_dir, ip=ip, use_existing_connection=False
        )

    def _run_filter_script(self, script_path, shutdown_time_dir):
        """Run filter_unit_stop_times.py with cwd=shutdown_time_dir; return (stdout+stderr, returncode)."""
        result = subprocess.run(
            [sys.executable, script_path],
            cwd=shutdown_time_dir,
            capture_output=True,
            text=True,
            timeout=120,
        )
        stdout = result.stdout or ""
        stderr = result.stderr or ""
        combined = (stdout + "\n" + stderr).strip()
        return combined, result.returncode

    def _copy_tmp_report_files_to_shutdown_dir(self, shutdown_time_dir):
        """
        Copy report files written by filter_unit_stop_times.py under /tmp into shutdown_time_dir.
        Does not modify upstream script paths.
        """
        copies = (
            (TMP_LONG_DURATIONS, LONG_DURATIONS_FILE),
            (TMP_UNIT_STOP_DURATIONS, UNIT_STOP_DURATIONS_FILE),
        )
        for src, dest_name in copies:
            if os.path.isfile(src):
                dest = os.path.join(shutdown_time_dir, dest_name)
                try:
                    shutil.copy2(src, dest)
                    self.logger.debug(f"Copied {src} to {dest}")
                except OSError as exc:
                    warning(f"Could not copy {src} to {dest}: {exc}")

    def _log_output_to_eventlog(self, output):
        """Write script output: upstream INFO: lines to debug; tables and ERROR to eventlog (info)."""
        for line in output.splitlines():
            if line.strip().startswith("INFO:"):
                self.logger.debug(line)
            else:
                info(line)

    @staticmethod
    def _read_failing_units_from_long_durations(shutdown_time_dir):
        """
        Read long_durations.txt in shutdown_time_dir (copy of upstream /tmp/long_durations.txt).
        Returns a string describing failing components, or empty string if file missing/empty.
        """
        path = os.path.join(shutdown_time_dir, LONG_DURATIONS_FILE)
        if not os.path.isfile(path):
            return ""
        try:
            with open(path, encoding="utf-8", errors="replace") as f:
                lines = [line.strip() for line in f if line.strip()]
            if not lines:
                return ""
            return f" Failing units (from {LONG_DURATIONS_FILE}): {'; '.join(lines)}"
        except OSError as exc:
            warning(f"Could not read {path}: {exc}")
            return ""

    def check_swdl_shutdown_times(self):
        """
        Create shutdown_time dir, download messages* from /var/log/last.0 via SSH,
        run local filter_unit_stop_times.py (upstream writes reports under /tmp; copies go to shutdown_time).
        Log important script output to eventlog; verbose upstream INFO: lines go to debug only.
        Fails the test if the script reports any unit(s) over the threshold (3 s, or 4 s for ccs.service).
        """
        shutdown_time_dir = os.path.join(self.logger.log_dir, SHUTDOWN_TIME_DIR_NAME)
        os.makedirs(shutdown_time_dir, exist_ok=True)
        info(f"SWDL shutdown time check: using directory {shutdown_time_dir}")

        ip = self._get_admin_ip()

        # List and download messages* from /var/log/last.0
        remote_paths = self._list_message_files_on_remote(ip)
        self._download_message_files(remote_paths, shutdown_time_dir, ip)

        script_path = self._get_filter_script_path()
        if not os.path.isfile(script_path):
            error(f"Filter script not found: {script_path}")
            raise SwdlShutdownTimeFailure(f"filter_unit_stop_times.py not found at {script_path}")

        output, returncode = self._run_filter_script(script_path, shutdown_time_dir)
        self._copy_tmp_report_files_to_shutdown_dir(shutdown_time_dir)

        self._log_output_to_eventlog(output)

        if "ERROR:" in output:
            detail = self._read_failing_units_from_long_durations(shutdown_time_dir)
            error(f"SWDL shutdown time check failed: one or more units exceeded stop time threshold.{detail}")
            raise SwdlShutdownTimeFailure(
                f"Unit(s) took longer than 3 s (or 4 s for ccs.service) to stop.{detail}"
            )
        if returncode != 0:
            detail = self._read_failing_units_from_long_durations(shutdown_time_dir)
            error(f"filter_unit_stop_times.py exited with code {returncode}.{detail}")
            raise SwdlShutdownTimeFailure(
                f"filter_unit_stop_times.py failed with exit code {returncode}.{detail}"
            )
        info("SWDL shutdown time check passed.")

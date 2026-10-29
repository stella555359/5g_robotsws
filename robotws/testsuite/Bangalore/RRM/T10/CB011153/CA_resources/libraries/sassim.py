import configparser
import os
import subprocess
import time

import psutil
from robot.running.context import EXECUTION_CONTEXTS

import logging


SAS_BIN = "SAS_Sim.py"


def has_stopped(process, timeout):
    """Returns True if process stopped before timeout"""
    max_time = time.time() + timeout
    while time.time() <= max_time and process.poll() is None:
        time.sleep(min(0.1, timeout))
    return process.poll() is not None


def lower_priority():
    """Lowers process priority to its lowest"""
    process = psutil.Process(os.getpid())
    process.nice(19)


class sassim:
    """Wrapper for Spectrum Access System (SAS) Simulator"""

    ROBOT_LIBRARY_DOC_FORMAT = "reST"
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    _process = None

    def __init__(self, src_dir="/tmp/sysadapt"):
        """Gets SAS Simulator from sources.

        You can specify different source directory by providing `src_dir` argument.
        Path will be created, if not existing, and sources will be downloaded into it.
        """
        self.workdir = os.path.join(
            os.path.abspath(src_dir), "uri/test/py/tools/SASSim"
        )

        # do nothing outside of robot context
        ctx = EXECUTION_CONTEXTS.current
        if not ctx:
            return
        if ctx.dry_run:
            return

        if os.path.exists(self.workdir):
            return
        try:
            output = subprocess.check_output(
                [
                    "git",
                    "clone",
                    "ssh://gerrit-essl.int.net.nokia.com:29418/MN/OAM/APIGW/sysadapt",
                    src_dir,
                ],
                stderr=subprocess.STDOUT,
            )
        except subprocess.CalledProcessError as e:
            logging.error(e.output.decode("utf-8"))
            raise
        else:
            logging.info(output.decode("utf-8"))

    def setup_sassim(self, **kwargs):
        """Configures and starts SAS Simulator

        Configuration options can be provided as keyword arguments (type: str).
        Note that `port_number` has to match one provided in CBRSPR object of SCF.

        If some option was not provided, a default value will be assumed.
        """
        if self._process:
            raise RuntimeError(
                "SAS Simulator already set up. You have to tear it down first."
            )

        # update config
        logging.info("Setting up SAS Simulator.")
        config_path = os.path.join(self.workdir, "SAS_Sim.conf")
        config = configparser.ConfigParser()
        config.optionxform = str  # make options names case sensitive
        config.read(config_path)
        kwargs.setdefault("port_number", 4433)  # default port 443 is taken on UTE TLs
        for option, value in kwargs.items():
            config["conf"][option] = str(value)
        with open(config_path, "w") as configfile:
            config.write(configfile)
        logging.debug(config.items("conf"))

        # start service
        self._process = subprocess.Popen(
            ["python3", "-u", os.path.join(self.workdir, SAS_BIN), "-c", config_path],
            cwd=self.workdir,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            preexec_fn=lower_priority,  # sas sim hogs CPU for no good reason
        )
        self.logfile = config["conf"]["log_file_name"]
        if not os.path.isabs(self.logfile):
            self.logfile = os.path.join(self.workdir, self.logfile)
        logging.info(
            "SAS Simulator started. PID: %d. Log will be stored in %s"
            % (self._process.pid, self.logfile)
        )

    def teardown_sassim(self):
        """Stops SAS Simulator and cleanups its configuration"""
        if self._process is None:
            logging.warning(
                "Nothing to tear down. You have to use `setup_sassim` first."
            )
            return
        logging.info("Stopping SAS Simulator.")
        self._process.terminate()
        if not has_stopped(self._process, 30):
            self._process.kill()
            if not has_stopped(self._process, 10):
                raise RuntimeError(
                    "Failed to stop SAS Simulator. Process %d is still running."
                    % self._process.pid
                )
        output = self._process.stdout.read()
        logging.info("SAS Simulator stopped.")
        logging.debug("Output:\n%s" % output.decode("utf-8"))
        self._process = None

        # restore default config (we don't really care if that succeed)
        subprocess.call(["git", "checkout", "SAS_Sim.conf"], cwd=self.workdir)

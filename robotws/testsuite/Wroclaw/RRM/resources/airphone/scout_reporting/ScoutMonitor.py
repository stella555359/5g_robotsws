import os
import subprocess
import time

from taf.sw.scout import scout
from taf.sw.scout.api import ScoutApi
from taf.sw.scout.config import Config
from taf.sw.scout.exceptions import *
from robot.api import logger


class ScoutMonitor(scout):
    def __init__(self):
        super(ScoutMonitor, self).__init__()
        self.agent_scout_path = ""
        self.agent_scout_pythonpath = ""
        if self.set_agent_scout_paths():
            self.api = self.setup_scout_api()

    @property
    def testline_name(self):
        hostname = os.uname()[1]
        return hostname.replace("-", "_")

    def setup_scout_api(self):
        try:
            config = Config('production')
            api = ScoutApi(scout_testline_name=self.testline_name, api_key=None, base_url=config.env_config.BASE_URL,
                           api_version='v1', config=config.config, ute_test_case_id=None, timeout=60)
            api.setup()
            return api
        except Exception as e:
            logger.error("Could not connect to scout API: %s" % e)
            return None

    def is_test_line_monitored(self):
        try:
            status = self.api.get_testline_monitor_status()
            if status["admin_websocket_status_display"] != "running":
                return False
            if status["admin_cli_status_display"] != "running":
                return False
            if status["admin_subscriptions_status_display"] != "running":
                return False
            if status["admin_pm_status_display"] != "running":
                return False
            return True
        except Exception as e:
            logger.error("Could not get testline monitor status from scout: %s" % e)
            return None

    def set_agent_scout_paths(self):
        pyenv_version, pythonpath = "", ""
        if os.path.exists("/home/ute/.pyenv/versions/agent_scout_env/pyvenv.cfg"):
            with open("/home/ute/.pyenv/versions/agent_scout_env/pyvenv.cfg") as pyenv_cfg_file:
                for line in pyenv_cfg_file.readlines():
                    if "home" in line:
                        pythonpath = line.split("=")[1].strip()
                    if "version" in line:
                        pyenv_version = line.split("=")[1].strip()
            if pythonpath:
                self.agent_scout_pythonpath = pythonpath + "/python"
            if pyenv_version:
                subdir = os.listdir("/home/ute/.pyenv/versions/agent_scout_env/lib")[0]
                self.agent_scout_path = "/home/ute/.pyenv/versions/%s/envs/agent_scout_env/lib/%s/site-packages/" \
                                        "agent_scout" % (pyenv_version, subdir)
            else:
                logger.error("Agent scout virtualenv not found.")
            return True
        else:
            return False

    def modify_scout_monitor(self):
        with open(self.agent_scout_path + "/scout.py", "r+") as monitor_file:
            if "testline_init_results" not in monitor_file.read():
                monitor_file.write("\nstart_scout_scanner('/home/ute/testline_init_results/agent_scout/results/"
                                   "config_files/scout.conf')\n")

    def wait_for_monitoring_enabled_status(self, timeout=60):
        counter = 0
        while counter < timeout:
            if self.is_test_line_monitored():
                logger.info("Scout monitoring is working after restart")
                return
            else:
                print(counter)
                logger.debug("Waiting for scout monitor running status...")
                counter += 10
                time.sleep(10)
        logger.error("Scout monitor restart not successful. Problems with config ID reporting may happen. VM reboot"
                     " might be needed.")

    def restart_scout_monitoring_on_test_line_if_needed(self):
        if not self.is_test_line_monitored():
            self.modify_scout_monitor()
            try:
                subprocess.run("bash -cel '. /home/ute/.pyenv/versions/agent_scout_env/bin/activate; python "
                               "%s/scout.py; deactivate'" % self.agent_scout_path, shell=True)
                self.wait_for_monitoring_enabled_status()
            except Exception as e:
                logger.error("Restarting scout monitoring unsuccessful due to exception: %s" % e)
        else:
            logger.info("Scout monitoring is enabled for %s." % self.testline_name)

import logging
import subprocess

from robot.libraries.BuiltIn import BuiltIn

rfrl_branch = BuiltIn().get_variable_value("${RFRL_BRANCH}")
pip_cmd = ["pip", "install", "--upgrade",
           f"git+https://wrgitlab.ext.net.nokia.com/RAN/resource-packages/taf.rfrl.csv4all.git@{rfrl_branch}"]


def rfrl_branch_installer():
    if rfrl_branch:
        try:
            subprocess.check_call(pip_cmd)
        except subprocess.CalledProcessError:
            logging.error(f"RFRL installation from {rfrl_branch} branch failed")
            raise


rfrl_branch_installer()

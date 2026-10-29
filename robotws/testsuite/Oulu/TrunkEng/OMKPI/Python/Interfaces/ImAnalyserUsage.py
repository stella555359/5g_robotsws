import os
from subprocess import check_output, CalledProcessError
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error


class ImAnalyserUsage:

    def __init__(self):
        self.log_collector = BuiltIn().get_library_instance("COLLECTLOGS")
        self.logger = BuiltIn().get_library_instance("LOG")

    @staticmethod
    def _install_pipx():
        info("Installing pipx")
        try:
            output = check_output("python -m pip install pipx", shell=True)
            info(output)
        except CalledProcessError as e:
            info(e)

    @staticmethod
    def _install_im_analyser_on_pipx():
        info("Installing im_analyser on pipx")
        try:
            output = check_output("pipx install taf.sbts.oam.coam.im_analyser", shell=True)
            info(output)
        except CalledProcessError as e:
            info(e)

    @staticmethod
    def _export_pipx_default_path():
        info("Exporting PATH")
        output = check_output('pipx ensurepath', shell=True)
        info(output)

    def _install_im_analyser(self):
        info("Checking if im_analyser is installed")
        try:
            check_output("pipx --version", shell=True)
            info("Pipx is already installed. It is assumed that taf.sbts.oam.coam.im-analyser is installed as well.")
        except CalledProcessError:
            self._install_pipx()
            self._export_pipx_default_path()
            self._install_im_analyser_on_pipx()

    def run_im_analyser(self, path_to_file=""):
        self._install_im_analyser()
        remove_temp_file = False
        try:
            if not path_to_file:
                info("Collecting temp IMS-file for im_analyser")
                path_to_file = self.log_collector.collect_ims(extra_name="im_analyser")
                remove_temp_file = True
            info(f"Is {path_to_file} available: {os.path.exists(path_to_file)}")
            if not os.path.exists(path_to_file):
                error(f"{path_to_file} does not exist. Cannot run im_analyser.")
                raise FileNotFoundError(f"{path_to_file} does not exist.")
            check_output(f"~/.local/bin/im-analyser --hw {path_to_file}", shell=True)
            if remove_temp_file:
                info(f"Removing temp file {path_to_file}")
                os.remove(path_to_file)
            info("im_analyser ran successfully")
        except CalledProcessError as e:
            info(e)

    def check_and_run_im_analyser(self, partial_snapshot_name="snapshot", full_path_to_snapshot=""):
        """
        Check if any file in the log directory contains 'snapshot' in its name and run im_analyser if it does.

        :param partial_snapshot_name: The partial name of the file to look for in the log directory.
        :param full_path_to_snapshot: The full path to the file to run im_analyser on. Default is empty string.
        """
        if full_path_to_snapshot:
            info(f"Running im_analyser on {full_path_to_snapshot}")
            self.run_im_analyser(full_path_to_snapshot)
            info("Running of im_analyser is ready.")
            return
        for root, _, files in os.walk(self.logger.log_dir):
            for file in files:
                if partial_snapshot_name in file.lower():
                    snapshot_path = str(os.path.join(root, file))
                    info(f"{partial_snapshot_name} found in {snapshot_path}. Running im_analyser.")
                    self.run_im_analyser(snapshot_path)
                    return
        info(f"No {partial_snapshot_name} found in {self.logger.log_dir}. Can't run im_analyser.")

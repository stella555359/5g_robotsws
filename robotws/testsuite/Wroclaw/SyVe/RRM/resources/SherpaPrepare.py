from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.SwDownloader import SwDownloader
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import download_file
import re


class SherpaPrepare(object):

    def install_correct_release_version(self):
        sherpa_version_for_stream = Env.SHERPA_VERSION_PER_RELEASE.get(Env.STREAM_SW)
        if sherpa_version_for_stream and self._check_sherpa_version() != sherpa_version_for_stream:
            Logger.info("Install Sherpa version: {}".format(sherpa_version_for_stream))
            file_path = SwDownloader().download_sherpa_correct_version_for_stream(sherpa_version_for_stream)
            output = Os.execute_command(command="sudo dpkg -i {}".format(file_path))
            Logger.debug(output)
            assert self._check_sherpa_version() == sherpa_version_for_stream, \
                "Install sherpa version failed {}".format(file_path)

    # Only temporary walkaround to fix issue with in official sherpa 1.0.96.0 - http sherpa download #
    def install_version_1_0_95_3(self, ssh_ue_pc):
        sherpa_version = "1.0.95.3"
        if sherpa_version not in self._check_sherpa_version():
            download_source = f"/home/wro5gcloud/Sherpa/Sherpa_5G_{sherpa_version}.debian10.deb"
            download_destination = f"/tmp/Sherpa/Sherpa_5G_{sherpa_version}.debian10.deb"
            Os.make_empty_dir("/tmp/Sherpa/")
            download_file(ssh_ue_pc, download_source, download_destination)
            output = Os.execute_command(command="sudo dpkg -i {}".format(download_destination))
            Logger.debug(output)
            assert sherpa_version in self._check_sherpa_version(), \
                "Install sherpa version failed {}".format(download_destination)

    @staticmethod
    def _check_sherpa_version():
        sherpa_version_cmd = "sudo /opt/Nokia/Sherpa_5G_18/Sherpa.run --version"
        sherpa_info = Os.execute_command(command=sherpa_version_cmd)
        sherpa_version = re.search(r':\s(\d+.*)', sherpa_info).group(1)
        Logger.info("Sherpa version: {}".format(sherpa_version))
        return sherpa_version

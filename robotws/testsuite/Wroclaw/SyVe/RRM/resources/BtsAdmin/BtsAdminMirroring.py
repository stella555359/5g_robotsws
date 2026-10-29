from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command, download_file
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from time import sleep


class BtsAdminMirroring(object):

    def __init__(self):
        self.bts_admin_api = BtsAdminApi()
        self.bts_interface_mirroring_pcap_path = "/tmp/CCSPacketCapture/"
        self.bts_ssh = Env.GNB_SSH_CONNECTION_DETAILS

    @staticmethod
    def start_interface_mirroring_l1l2(capturing_time):
        with BtsAdminApi() as web_api:
            web_api.interface_mirroring(operation='Start', interface='L1-L2',
                                        destination='Local',
                                        mirroring_time=0, detailed_output=True)
            sleep(capturing_time)
            web_api.interface_mirroring(operation='Stop', detailed_output=True)

    def download_pcap_file_from_the_bts(self, pcap_name):
        target_interface_mirroring_pcap_dir = Env().test_log_dir
        Logger.debug("Downloading interface mirroring pcap file {}.pcap from the BTS".format(pcap_name))
        pcap_interface_mirroring_path = Os.join_path_elements(target_interface_mirroring_pcap_dir,
                                                              "{}.pcap".format(pcap_name))
        name_pcap_file = self._read_first_pcap_file_from_interface_mirroring()
        download_file(self.bts_ssh, source=self.bts_interface_mirroring_pcap_path + name_pcap_file,
                      target=pcap_interface_mirroring_path)
        return pcap_interface_mirroring_path

    def remove_pcap_interface_mirroring_files_from_bts(self):
        execute_ssh_command(ssh_connection_parameters=self.bts_ssh,
                            command="cd /tmp/CCSPacketCapture/ && rm *.*")

    def _read_first_pcap_file_from_interface_mirroring(self):
        Logger.debug("Executing command cd /tmp/CCSPacketCapture/ && ls | grep Z0")
        capture_files, _ = execute_ssh_command(ssh_connection_parameters=self.bts_ssh,
                                               command="ls -Al /tmp/CCSPacketCapture",
                                               execution_timeout=15)
        Logger.info(f"Capture files are: {capture_files}")
        output, err = execute_ssh_command(ssh_connection_parameters=self.bts_ssh,
                                          command="cd /tmp/CCSPacketCapture/ && ls | grep Z0",
                                          execution_timeout=15)
        assert "Z0" in output, \
            "Something went wrong, check if the file exists on BTS\nError:{}".format(err)
        Logger.debug("Pcap file exists:\n{}\nerror:\n{}".format(output, err))
        return output

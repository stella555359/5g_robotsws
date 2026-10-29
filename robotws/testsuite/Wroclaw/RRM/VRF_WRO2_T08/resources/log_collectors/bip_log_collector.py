"""
Collector of BIP log which utilizes gnbMirroring scripts. Implements common log collector API.

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

import os
import tarfile

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.connections import \
    ConnectionManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.AdminWrapper import \
    AdminWrapper
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import \
    logger

from .log_collector import LogCollector

admin = AdminWrapper()
_cm = ConnectionManager()


class BipLogCollector(LogCollector):
    def __init__(self, alias="bip"):
        super(BipLogCollector, self).__init__(alias=alias)
        self._executor = _cm.nr_smod_connection(autoconnect=False)
        self.capturing_time_seconds = 600
        self._log_extension = ".pcap"
        self._log_postfix = "_bip"
        self._nrcells_dns = None

    def setup(self, with_upload=True):
        pass

    def shutdown(self):
        try:
            self.stop_log_collecting()
        except Exception as e:
            logger.info("Omitting log collection stop due to exception: {}".format(e))
        self._executor.disconnect()

    def start_log_collecting(self):
        self._run_interface_mirroring(operation_type="Start")

    def stop_log_collecting(self):
        self._run_interface_mirroring(operation_type="Stop")

    def download_log(self, filepath):
        filepath = self._prepare_log_name(filepath)
        self._prepare_log_from_interface_mirroring(filepath)
        return filepath

    def set_logging_filter(self, filtering):
        pass

    def _run_interface_mirroring(self, operation_type):
        with admin.nr_context() as admin_connection:
            try:
                admin_connection.interface_mirroring(
                    operation=operation_type,
                    interface="L1-L2",
                    destination="Local",
                    mirroring_time=self.capturing_time_seconds,
                    detailed_output=True,
                    nr_cell_dns=self._nrcells_dns,
                )
            except Exception as e:
                if "ErrorCode: 69" not in e.message:
                    logger.info(f"Unexpected exception:\n{e}\nMessage: {e.message}")
                    raise Exception("Unable to {} interface mirroring!".format(operation_type.lower()))

    def _prepare_log_from_interface_mirroring(self, save_filepath):
        remote_pcap_folder = "/tmp/CCSPacketCapture"
        tar_filepath = "/tmp/interface_mirroring.tar"
        local_tmp_dir = "/tmp"
        with self._executor as ssh:
            ssh.execute_command(cmd="tar -cvf {} {}".format(tar_filepath, remote_pcap_folder))
            ssh.download_file(remote_path=tar_filepath, local_path=tar_filepath)
        with tarfile.open(tar_filepath) as extractor:
            extractor.extractall(local_tmp_dir)
        dir_to_search = local_tmp_dir + remote_pcap_folder
        files_to_merge = [
            os.path.join(dir_to_search, filename)
            for filename in os.listdir(dir_to_search)
            if os.path.isfile(os.path.join(dir_to_search, filename))
        ]
        return self._merge_pcap(output_file=save_filepath, input_files=files_to_merge)

    @staticmethod
    def _merge_pcap(output_file, input_files):
        inputs = '"' + '" "'.join(input_files) + '"'
        os.system('mergecap -w "{}" {}'.format(output_file, inputs))
        os.system("rm -f {}".format(inputs))
        return output_file

    def set_nr_cells(self, nr_cell_dns):
        self._nrcells_dns = nr_cell_dns


class MirroringScriptCollector(LogCollector):
    _mirroring_script_name = "gnbMirroring.sh"
    _mirroring_config_name = "gnbMirroringConfig.sh"
    _remote_script_dir = "/ffs/run/config/scripts"
    _local_script_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "log_servers")

    def __init__(self, alias="gnb_mirroring"):
        super().__init__(alias=alias)
        self._executor = _cm.nr_smod_connection(autoconnect=False)
        self.filter = ""
        self.capturing_time_seconds = 600
        self.syscom_mirroring = "off"
        self.additional_flags = ""
        self._log_extension = ".pcap"
        self._log_postfix = "_bip"

    def setup(self, with_upload=True):
        if with_upload:
            self._upload_gnb_mirroring()

    def shutdown(self):
        try:
            self.stop_log_collecting()
        except Exception as e:
            logger.info("Omitting log collection stop due to exception: {}".format(e))
        self._executor.disconnect()

    def start_log_collecting(self):
        cmd = self._build_gnb_mirroring_command()
        with self._executor:
            self._executor.send_command(cmd=cmd)
            self._executor.read_output_until(match="Output is saved", timeout=30)

    def stop_log_collecting(self):
        self._stop_script_mirroring()

    def download_log(self, filepath):
        filepath = self._prepare_log_name(filepath)
        self._prepare_log_from_script_mirroring(filepath)
        return filepath

    def set_logging_filter(self, filtering="", syscom_mirroring="off"):
        self.filter = filtering
        self.syscom_mirroring = syscom_mirroring

    def _build_gnb_mirroring_command(self):
        if self.filter:
            flags = '--filter="{}" --filtering="on" --capturing_time_seconds="{}" --syscom_mirroring="{}" {}'.format(
                self.filter, self.capturing_time_seconds, self.syscom_mirroring, self.additional_flags
            )
        else:
            flags = '--filtering="off" --capturing_time_seconds="{}" --syscom_mirroring="{}" {}'.format(
                self.capturing_time_seconds, self.syscom_mirroring, self.additional_flags
            )
        cmd = "{} {}".format(os.path.join(self._remote_script_dir, self._mirroring_script_name), flags)
        logger.info("gnbMirroring CMD: " + cmd)
        return cmd

    def _upload_gnb_mirroring(self):
        remote_script = os.path.join(self._remote_script_dir, self._mirroring_script_name)
        local_script = os.path.join(self._local_script_dir, self._mirroring_script_name)
        local_config = os.path.join(self._local_script_dir, self._mirroring_config_name)
        with self._executor as ssh:
            ssh.execute_command(cmd='mkdir "{}"'.format(self._remote_script_dir))
            ssh.upload_file(remote_path=self._remote_script_dir, local_path=[local_script, local_config])
            ssh.execute_command(cmd="chmod +x {}".format(remote_script))

    def _stop_script_mirroring(self):
        with self._executor:
            output = self._executor.execute_command(cmd="ps -aux | grep timeout -s")
            logger.info(f"Stop mirroring - output of 'ps -aux': {output}")
            active_mirroring_pids = [line.split()[1] for line in output.splitlines() if ".pcap" in line]
            assert active_mirroring_pids, "gnbMirroring could not be found as a running process!"
            for pid in active_mirroring_pids:
                self._executor.execute_command(cmd="kill -2 {}".format(pid))
            assert len(active_mirroring_pids) == 1, "More than one ({}) running gnbMirroring found!".format(
                len(active_mirroring_pids)
            )

    def _prepare_log_from_script_mirroring(self, save_filepath):
        remote_filepath = "/tmp/tcpdump_L2L1_bip_filtering_{}.pcap".format("on" if self.filter else "off")
        with self._executor as ssh:
            ssh.assert_file_exists(remote_path=remote_filepath)
            ssh.download_file(remote_path=remote_filepath, local_path=save_filepath)
            logger.info("logs downloaded from {} to {}".format(remote_filepath, save_filepath))
            ssh.execute_command(cmd="rm /tmp/tcpdump_L2L1*")

from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir
import glob
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.vm_ssh_session import VmSshSession, LEFT_SMOD, RIGHT_SMOD
from taf.transport.ssh import ssh
import paramiko
import os
import tarfile
import time

_ssh = ssh()


class l1l2_collector:
    def __init__(self):
        self.output_filepath = None
        self.is_fullrack = len(tl.gnbs) > 1

    def start_l1l2_collection(self, filename, mirroring_time, cell_ids=None, mirroring_filter=None,
                              specific_message_ids=None, wait=True):
        if cell_ids and not isinstance(cell_ids, list):
            cell_ids = cell_ids.split(',')
        nr_cell_dns = [f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}' for cell_id in cell_ids]
        self.output_filepath = os.path.join(get_robot_output_dir(), filename)
        self.__start_interface_mirroring(mirroring_time, nr_cell_dns, mirroring_filter, specific_message_ids)
        if wait:
            time.sleep(int(mirroring_time))

    def stop_l1l2_collection(self):
        self.__stop_interface_mirroring()
        self.__download_pcap()
        return self.output_filepath

    def teardown_gnbmirroring(self):
        self.__stop_interface_mirroring()

    @staticmethod
    def __start_interface_mirroring(mirroring_time, nr_cell_dns, mirroring_filter=None, specific_message_ids=None):
        with AdminSession() as admin:
            try:
                admin.interface_mirroring(operation='Start', interface='L1-L2',
                                          destination='Local',
                                          mirroring_time=int(mirroring_time), detailed_output=True,
                                          nr_cell_dns=nr_cell_dns,
                                          mirroring_filter=mirroring_filter,
                                          specific_message_ids=specific_message_ids)
            except Exception as e:
                logger.error(e)
                if 'ErrorCode: 69' not in e.message:
                    raise RuntimeError('Unable to start interface_mirroring!')

    @staticmethod
    def __stop_interface_mirroring():
        with AdminSession() as admin:
            try:
                admin.interface_mirroring(operation='Stop', detailed_output=True)
            except Exception as e:
                if 'ErrorCode: 69' not in e.message:
                    raise RuntimeError('Unable to stop interface_mirroring!')

    def __download_pcap(self):
        log_directory = "/tmp/bip_capture"
        remote_directory = '/tmp/CCSPacketCapture'
        os.system(f"mkdir -p {log_directory}")
        input_dirs = []

        with VmSshSession(LEFT_SMOD) as vm1:
            capture_exists = vm1.file_exists_on_smod("/tmp/CCSPacketCapture")
            if capture_exists:
                output = vm1.execute_command_on_smod("ls /tmp/CCSPacketCapture")
                file_list = output.split()
                logger.debug(file_list)
                os.system(f"mkdir -p {log_directory}/left_smod")
                left_smod = os.path.join(log_directory, 'left_smod')
                input_dirs.append(left_smod)
                for filename in file_list:
                    vm1.download_file_from_smod(remote_filepath=os.path.join(remote_directory, filename),
                                                local_filepath=os.path.join(left_smod, filename))
        if self.is_fullrack:
            with VmSshSession(RIGHT_SMOD) as vm2:
                capture_exists = vm2.file_exists_on_smod("/tmp/CCSPacketCapture")
                if capture_exists:
                    output = vm2.execute_command_on_smod("ls /tmp/CCSPacketCapture")
                    file_list = output.split()
                    logger.debug(file_list)
                    os.system(f"mkdir -p {log_directory}/right_smod")
                    right_smod = os.path.join(log_directory, 'right_smod')
                    input_dirs.append(right_smod)
                    for filename in file_list:
                        vm2.download_file_from_smod(remote_filepath=os.path.join(remote_directory, filename),
                                                    local_filepath=os.path.join(right_smod, filename))
        downloaded_files = glob.glob(os.path.join(log_directory, '*', "*.pcap"), recursive=True)
        logger.info(f"Downloaded files: {downloaded_files}")

        input_files = " ".join([f"{d}/*" for d in input_dirs])
        self.merge_pcap(self.output_filepath, input_files)
        os.system(f"rm -rf {log_directory}/*")
        self.cleanup_files_on_smod()
        return self.output_filepath

    def merge_pcap(self, output_file, input_files):
        os.system(f'mergecap -w {output_file} {input_files}')
        os.system(f'rm -rf {input_files}')

    def cleanup_files_on_smod(self):
        with VmSshSession(LEFT_SMOD) as vm1:
            vm1.execute_command_on_smod("rm -f /tmp/CCSPacketCapture/*")
        if self.is_fullrack:
            with VmSshSession(RIGHT_SMOD) as vm2:
                vm2.execute_command_on_smod("rm -f /tmp/CCSPacketCapture/*")

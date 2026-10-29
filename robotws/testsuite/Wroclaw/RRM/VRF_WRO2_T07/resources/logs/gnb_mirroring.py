from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi, assign_release_version
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from taf.transport.ssh import ssh
from scp import SCPClient
import paramiko
import os
import tarfile

_ssh = ssh()


class Operation:
    start = 'Start'
    stop = 'Stop'


class LogsInterface:
    l1l2 = 'L1-L2'
    l2hi_l2lo = 'L2Hi-L2Lo'


class Destination:
    local = 'Local'
    remote = 'Remote'


class L1L2:
    def __init__(self):
        self._filter = None
        self.filtering = None
        self.capturing_time_seconds = None
        self.syscom_mirroring = None
        self.additional_flags = None
        self.output_filepath, self.gnb_mirroring_path = None, None
        self.cmd = None
        self.new_l1l2 = None
        self.nr_cell_dns = None

    @logged_keyword
    def setup_variables(self, filename=None, _filter='', filtering='on', capturing_time_seconds='500',
                        syscom_mirroring='off', additional_flags='', nr_cell_dns=None, new_l1l2=True):
        self._filter = _filter
        self.filtering = filtering
        self.capturing_time_seconds = capturing_time_seconds
        self.syscom_mirroring = syscom_mirroring
        self.additional_flags = additional_flags
        self.nr_cell_dns = nr_cell_dns
        self.output_filepath, self.gnb_mirroring_path = self.setup_paths(filename)
        self.cmd = self.build_gnb_mirroring_command()
        self.new_l1l2 = new_l1l2 and assign_release_version() >= 'SBTS22R4'

    @staticmethod
    def setup_paths(filename):
        filename = robot_globals.testname() + '.pcap' if filename is None else filename
        if not filename.endswith('.pcap'):
            filename += '.pcap'
        filename = filename.rsplit('.', 1)[0]
        output_filepath = os.path.join(robot_globals.outputdir(), filename + '_L1L2.pcap')
        gnb_mirroring_path = os.path.join('/ffs/run/config/scripts/gnbMirroring.sh')
        return output_filepath, gnb_mirroring_path

    def build_gnb_mirroring_command(self):
        if self._filter:
            self.filtering = 'on'
            flags = '--filter="{}" --filtering="{}" --capturing_time_seconds="{}" --syscom_mirroring="{}" {}'.format(
                self._filter, self.filtering, self.capturing_time_seconds,
                self.syscom_mirroring, self.additional_flags)
        else:
            flags = '--filtering="{}" --capturing_time_seconds="{}" --syscom_mirroring="{}" {}'.format(
                self.filtering, self.capturing_time_seconds, self.syscom_mirroring, self.additional_flags)

        cmd = '{} {}'.format(self.gnb_mirroring_path, flags)
        blog('gnbMirroring CMD: ' + cmd)
        return cmd

    @logged_keyword
    def start_gnbmirroring(self, filename=None, _filter='', filtering='on', capturing_time_seconds='500',
                           syscom_mirroring='off', additional_flags='', new_l1l2=True, nr_cell_dns=None):

        self.setup_variables(filename, _filter, filtering, capturing_time_seconds,
                             syscom_mirroring, additional_flags, nr_cell_dns, new_l1l2)

        if self.new_l1l2:
            self.start_interface_mirroring()
            blog('L1L2 interface mirroring started!')
        else:
            smod_master_alias = connections.connect_to_smod()
            self.upload_gnb_mirroring_script_to_smod()
            _ssh.send_command(command=self.cmd, connection=smod_master_alias)
            _ssh.read_output_until(match='Output is saved', connection=smod_master_alias)
            blog('gnbMirroring.sh started!')

    @logged_keyword
    def stop_gnbmirroring_and_download_logs(self):
        if self.new_l1l2:
            self.stop_interface_mirroring()
            blog('L1L2 interface mirroring stopped!')
        else:
            smod_master_alias = connections.connect_to_smod()
            pid = self.get_pid_of_gnbmirroring(smod_master_alias)
            _ssh.execute(command='kill -2 {}'.format(pid), connection=smod_master_alias)
            blog('gnbMirroring.sh stopped!')

            remote_filepath = '/tmp/tcpdump_L2L1_bip_filtering_{}.pcap'.format(self.filtering)
            _ssh.assert_file_exists(remote_filepath, connection=smod_master_alias)
            self.download_file_from_smod(remote_filepath=remote_filepath,
                                         local_filepath=self.output_filepath)
            _ssh.execute(command='rm /tmp/tcpdump_L2L1*', connection=smod_master_alias)

        blog('L1L2 logs collection finished successfully!')
        return self.output_filepath

    @logged_keyword
    def teardown_gnbmirroring(self):
        try:
            self.stop_gnbmirroring_and_download_logs()
        except Exception:
            blog('L1L2 traces have already been collected. Teardown will not download L1L2 traces.')

    @logged_keyword
    def get_pid_of_gnbmirroring(self, connection):
        output = _ssh.execute(command='ps -aux | grep timeout -s', connection=connection)
        blog(output)
        for line in output.splitlines():
            if '.pcap' in line:
                return line.split()[1]
            else:
                blog('gnbMirroring could not be found as a running process!')

    @staticmethod
    def upload_gnb_mirroring_script_to_smod():
        smod_master_alias = connections.connect_to_smod()
        local_script_dir = os.path.join(robot_globals.execdir(),
                                        'testsuite/Wroclaw/RRM/resources/gnbMirroring')
        remote_script_dir = '/ffs/run/config/scripts'
        _ssh.execute(command='mkdir "{}"'.format(remote_script_dir), connection=smod_master_alias)
        _ssh.upload_file(local_path=['{}/gnbMirroring.sh'.format(local_script_dir),
                                     '{}/gnbMirroringConfig.sh'.format(local_script_dir)],
                         remote_path=remote_script_dir, connection=smod_master_alias)
        _ssh.execute(command='chmod +x {}/gnbMirroring.sh'.format(remote_script_dir), connection=smod_master_alias)

    def start_interface_mirroring(self):
        with AdminApi() as web_api:
            try:
                web_api.interface_mirroring(operation=Operation.start, interface=LogsInterface.l1l2,
                                            destination=Destination.local,
                                            mirroring_time=int(self.capturing_time_seconds), detailed_output=True,
                                            nr_cell_dns=self.nr_cell_dns)
            except Exception as e:
                blog(e, level='ERROR')
                if 'ErrorCode: 69' not in e.message:
                    raise Exception('Unable to start interface_mirroring!')

    def stop_interface_mirroring(self):
        with AdminApi() as web_api:
            try:
                web_api.interface_mirroring(operation=Operation.stop, interface=LogsInterface.l1l2,
                                            destination=Destination.local,
                                            mirroring_time=int(self.capturing_time_seconds), detailed_output=True)
            except Exception as e:
                if 'ErrorCode: 69' not in e.message:
                    raise Exception('Unable to stop interface_mirroring!')
            finally:
                return self.prepare_pcap()

    def prepare_pcap(self):
        remote_pcap_folder = '/tmp/CCSPacketCapture'
        tarfilepath = '/tmp/my_files.tar'
        local_tmp_dir = '/tmp'
        destination_filepath = self.output_filepath
        smod_alias = connections.connect_to_smod()
        files_list = _ssh.execute(command='ls {}'.format(remote_pcap_folder), connection=smod_alias)
        if not files_list:
            assert False, 'Error: {} directory on SMOD is empty!'.format(remote_pcap_folder)
        _ssh.execute(command='tar -cvf {} {}'.format(tarfilepath, remote_pcap_folder),
                     connection=smod_alias)
        self.download_file_from_smod(remote_filepath=tarfilepath, local_filepath=tarfilepath)
        self.extract_tar_file(tarfilepath, destination=local_tmp_dir)
        return self.merge_pcap(output_file=destination_filepath,
                               inputs=self.__file_list_from_dir(local_tmp_dir + remote_pcap_folder))

    @logged_keyword
    def merge_pcap(self, output_file, inputs, flags='-w'):
        inputs = '"' + '" "'.join(inputs) + '"'
        os.system(self.__log_that('mergecap {} "{}" {}'.format(flags, output_file, inputs)))
        os.system(self.__log_that('rm -f {}'.format(inputs)))
        return output_file

    @staticmethod
    def __file_list_from_dir(directory):
        return [os.path.join(directory, f) for f in os.listdir(directory)
                if os.path.isfile(os.path.join(directory, f))]

    @staticmethod
    def extract_tar_file(tarfilepath, destination):
        my_tar = tarfile.open(tarfilepath)
        my_tar.extractall(destination)
        my_tar.close()

    @staticmethod
    def download_file_from_smod(remote_filepath, local_filepath):
        password = tl.gnbs[0].cu.oam_ssh_connection_details.password
        os.system(f'sshpass -p {password} scp toor4nsn@192.168.255.129:{remote_filepath} {local_filepath}')

    @staticmethod
    def __log_that(obj):
        blog(obj)
        return obj

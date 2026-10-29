from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.resource.admin_api import (
    AdminApi,
    assign_release_version
    )
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.resource.connections as connections
from taf.transport.ssh import ssh
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

    @logged_keyword
    def setup_variables(self, filename=None, _filter='', filtering='on', capturing_time_seconds='500',
                        syscom_mirroring='off', additional_flags=''):
        self._filter = _filter
        self.filtering = filtering
        self.capturing_time_seconds = capturing_time_seconds
        self.syscom_mirroring = syscom_mirroring
        self.additional_flags = additional_flags
        self.output_filepath = self.setup_paths(filename)

    @staticmethod
    def setup_paths(filename):
        filename = robot_globals.testname() + '.pcap' if filename is None else filename
        if not filename.endswith('.pcap'):
            filename += '.pcap'
        filename = filename.rsplit('.', 1)[0]
        output_filepath = os.path.join(robot_globals.outputdir(), filename + '.pcap')
        return output_filepath

    @logged_keyword
    def start_gnbmirroring(self, ip, filename=None, _filter='', filtering='on', capturing_time_seconds='500',
                           syscom_mirroring='off', additional_flags='', new_l1l2=True):

        self.new_l1l2 = new_l1l2
        self.setup_variables(filename, _filter, filtering, capturing_time_seconds, syscom_mirroring, additional_flags)
        blog('filename='+filename)
        self.start_interface_mirroring(ip)
        blog('L1L2 interface mirroring started!')

    @logged_keyword
    def stop_gnbmirroring_and_download_logs(self, ip, filename):
        if self.new_l1l2:
            self.stop_interface_mirroring(ip, filename)
            blog('L1L2 interface mirroring stopped!')

    @logged_keyword
    def teardown_gnbmirroring(self):
        try:
            self.stop_gnbmirroring_and_download_logs()
        except Exception:
            blog('L1L2 traces have already been collected. Teardown will not download L1L2 traces.')

    def start_interface_mirroring(self, ip):
        with AdminApi(ip) as web_api:
            try:
                web_api.interface_mirroring(operation=Operation.start, interface=LogsInterface.l1l2,
                                            destination=Destination.local,
                                            mirroring_time=int(self.capturing_time_seconds), detailed_output=True)
            except Exception as e:
                if 'ErrorCode: 69' not in e.message:
                    raise Exception('Unable to start interface_mirroring!')

    def stop_interface_mirroring(self, ip, filename):
        with AdminApi(ip) as web_api:
            try:
                web_api.interface_mirroring(operation=Operation.stop, interface=LogsInterface.l1l2,
                                            destination=Destination.local,
                                            mirroring_time=int(self.capturing_time_seconds), detailed_output=True)
            except Exception as e:
                if 'ErrorCode: 69' not in e.message:
                    raise Exception('Unable to stop interface_mirroring!')
            finally:
                return self.prepare_pcap(ip, filename)

    def prepare_pcap(self, ip, filename):
        remote_pcap_folder = '/tmp/CCSPacketCapture'
        tarfilepath = '/tmp/my_files.tar'
        local_tmp_dir = '/tmp'
        destination_filepath = filename
        smod_alias = connections.connect_to_smod(ip)
        files_list = _ssh.execute(command='ls {}'.format(remote_pcap_folder), connection=smod_alias)
        if not files_list:
            assert False, 'Error: {} directory on SMOD is empty!'.format(remote_pcap_folder)
        _ssh.execute(command='tar -cvf {} {}'.format(tarfilepath, remote_pcap_folder),
                     connection=smod_alias)
        _ssh.download_file(remote_path=tarfilepath,
                           local_path=tarfilepath,
                           connection=smod_alias)
        self.extract_tar_file(tarfilepath, destination=local_tmp_dir)
        return self.merge_pcap_to_file(output_file=destination_filepath,
                                       inputs=self.__file_list_from_dir(local_tmp_dir + remote_pcap_folder))

    @logged_keyword
    def merge_pcap_to_file(self, output_file, inputs, flags='-w'):
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
    def __log_that(obj):
        blog(obj)
        return obj

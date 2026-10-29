from taf.transport.ssh import ssh
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import os

_ssh = ssh()


class TcpdumpBbmod:
    def __init__(self):
        self.remote_filepath, self.output_filepath = None, None
        self.bbmod_master = None
        self.bbmod_slave = None
        self.bbmod_loner = None
        self.interface_master = None
        self.interface_slave = None
        self.interface_loner = None
        self.filter_master = None
        self.filter_slave = None
        self.filter_loner = None
        self.name_process = None

    @logged_keyword
    def setup_variables(self, filename=None, bbmod_master=True, bbmod_slave=True, bbmod_loner=False,
                        interface_master='any', interface_slave='any', interface_loner='any',
                        filter_master='sctp', filter_slave='sctp', filter_loner='sctp'):
        self.remote_filepath, self.output_filepath = self.setup_paths(filename)
        self.bbmod_master = bbmod_master
        self.bbmod_slave = bbmod_slave
        self.bbmod_loner = bbmod_loner
        self.interface_master = interface_master
        self.interface_slave = interface_slave
        self.interface_loner = interface_loner
        self.filter_master = filter_master
        self.filter_slave = filter_slave
        self.filter_loner = filter_loner

    @staticmethod
    def setup_paths(filename):
        filename = robot_globals.testname() + '.pcap' if filename is None else filename
        if not filename.endswith('.pcap'):
            filename += '.pcap'
        filename = filename.rsplit('.', 1)[0]
        remote_filepath = os.path.join('/tmp', filename + '_tcpdump_BBMOD_{}.pcap')
        output_filepath = os.path.join(robot_globals.outputdir(), filename + '_tcpdump_BBMOD_{}.pcap')

        return remote_filepath, output_filepath

    @logged_keyword
    def start_tcpdump_on_bbmod(self, filename=None, bbmod_master=False, bbmod_slave=False, bbmod_loner=False,
                               interface_master='any', interface_slave='any', interface_loner='any',
                               filter_master='sctp', filter_slave='sctp', filter_loner='sctp'):

        self.setup_variables(filename, bbmod_master, bbmod_slave, bbmod_loner,
                             interface_master, interface_slave, interface_loner,
                             filter_master, filter_slave, filter_loner)

        command_template = 'tcpdump -i {} {} -w "' + self.remote_filepath + '"'
        if self.bbmod_slave:
            bbmod_slave_alias = connections.connect_to_bbmod(container='slave')
            cmd = command_template.format(self.interface_slave, self.filter_slave, 'SLAVE')
            _ssh.send_command(command=cmd, connection=bbmod_slave_alias)
            self.name_process = cmd

        if self.bbmod_master:
            bbmod_master_alias = connections.connect_to_bbmod(container='master')
            cmd = command_template.format(self.interface_master, self.filter_master, 'MASTER')
            _ssh.send_command(command=cmd, connection=bbmod_master_alias)
            self.name_process = cmd

        if self.bbmod_loner:
            bbmod_loner_alias = connections.connect_to_bbmod(container='loner')
            cmd = command_template.format(self.interface_loner, self.filter_loner, 'LONER')
            _ssh.send_command(command=cmd, connection=bbmod_loner_alias)
            self.name_process = cmd

        blog('Tcpdump on BBMOD started!')

    @logged_keyword
    def stop_tcpdump_and_download_logs_from_bbmod(self, teardown=False):
        output_filepath = ''
        if self.bbmod_slave:
            bbmod_slave_alias = connections.connect_to_bbmod(container='slave')
            self.collect_logs_from_bbmod_container('SLAVE', bbmod_slave_alias, teardown)
            output_filepath = self.output_filepath.format('SLAVE')

        if self.bbmod_master:
            bbmod_master_alias = connections.connect_to_bbmod(container='master')
            self.collect_logs_from_bbmod_container('MASTER', bbmod_master_alias, teardown)
            output_filepath = self.output_filepath.format('MASTER')

        if self.bbmod_loner:
            bbmod_loner_alias = connections.connect_to_bbmod(container='loner')
            self.collect_logs_from_bbmod_container('LONER', bbmod_loner_alias, teardown)
            output_filepath = self.output_filepath.format('LONER')

        blog('Tcpdump on BBMOD stopped!')
        return output_filepath

    @logged_keyword
    def collect_logs_from_bbmod_container(self, container, connection_alias, teardown=False):
        remote_log_path = self.remote_filepath.format(container)
        local_log_path = self.output_filepath.format(container)
        if teardown and os.path.exists(local_log_path):
            local_log_path = local_log_path[:-5] + '_TEARDOWN' + local_log_path[-5:]

        _ssh.execute(command="pkill '{}'".format(self.name_process), connection=connection_alias)
        _ssh.execute(command='chmod 777 ' + remote_log_path, connection=connection_alias)
        _ssh.download_file(remote_path=remote_log_path,
                           local_path=local_log_path,
                           connection=connection_alias)
        _ssh.execute(command='rm "{}"'.format(remote_log_path), connection=connection_alias)

    @logged_keyword
    def teardown_tcpdump_on_bbmod(self):
        try:
            self.stop_tcpdump_and_download_logs_from_bbmod(teardown=True)
        except Exception:
            blog('Tcpdump traces have already been collected. Teardown will not download tcpdump traces.')

    @logged_keyword
    def merge_pcap(self, output_file, inputs, flags='-w'):
        inputs = '"' + '" "'.join(inputs) + '"'
        os.system(self.__log_that('mergecap {} "{}" {}'.format(flags, output_file, inputs)))
        os.system(self.__log_that('rm -f {}'.format(inputs)))
        return output_file

    @staticmethod
    def __log_that(obj):
        blog(obj)
        return obj

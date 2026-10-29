from taf.transport.ssh import ssh
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import os


_ssh = ssh()


class TcpdumpSmod:
    def __init__(self):
        self.remote_filepath, self.output_filepath = None, None
        self.smod_master = None
        self.smod_slave = None
        self.interface_master = None
        self.interface_slave = None
        self.filter_master = None
        self.filter_slave = None
        self.name_process = None

    @logged_keyword
    def setup_variables(self, filename=None, smod_master=True, smod_slave=True, interface_master='any',
                        interface_slave='any', filter_master='sctp', filter_slave='sctp'):
        self.remote_filepath, self.output_filepath = self.setup_paths(filename)
        self.smod_master = smod_master
        self.smod_slave = smod_slave
        self.interface_master = interface_master
        self.interface_slave = interface_slave
        self.filter_master = filter_master
        self.filter_slave = filter_slave

    @staticmethod
    def setup_paths(filename):
        filename = robot_globals.testname() + '.pcap' if filename is None else filename
        if not filename.endswith('.pcap'):
            filename += '.pcap'
        filename = filename.rsplit('.', 1)[0]
        remote_filepath = os.path.join('/tmp', filename + '_tcpdump_SMOD_{}.pcap')
        output_filepath = os.path.join(robot_globals.outputdir(), filename + '_tcpdump_SMOD_{}.pcap')

        return remote_filepath, output_filepath

    @logged_keyword
    def start_tcpdump_on_smod(self, filename=None, smod_master=True, smod_slave=False, interface_master='any',
                              interface_slave='any', filter_master='sctp', filter_slave='sctp'):

        self.setup_variables(filename, smod_master, smod_slave, interface_master,
                             interface_slave, filter_master, filter_slave)

        command_template = 'tcpdump -i {} {} -s0 -w "' + self.remote_filepath + '"'
        if self.smod_slave:
            smod_slave_alias = connections.connect_to_smod(container='slave')
            cmd = command_template.format(self.interface_slave, self.filter_slave, 'SLAVE')
            _ssh.send_command(command=cmd, connection=smod_slave_alias)
            self.name_process = cmd

        if self.smod_master:
            smod_master_alias = connections.connect_to_smod(container='master')
            cmd = command_template.format(self.interface_master, self.filter_master, 'MASTER')
            _ssh.send_command(command=cmd, connection=smod_master_alias)
            self.name_process = cmd

        blog('Tcpdump on SMOD started!')

    @logged_keyword
    def stop_tcpdump_and_download_logs_from_smod(self, teardown=False):
        output_filepath = ''
        if self.smod_slave:
            smod_slave_alias = connections.connect_to_smod(container='slave')
            self.collect_logs_from_smod_container('SLAVE', smod_slave_alias, teardown)
            output_filepath = self.output_filepath.format('SLAVE')

        if self.smod_master:
            smod_master_alias = connections.connect_to_smod(container='master')
            self.collect_logs_from_smod_container('MASTER', smod_master_alias, teardown)
            output_filepath = self.output_filepath.format('MASTER')

        if self.smod_slave and self.smod_master:
            slave_output_filepath = self.output_filepath.format('SLAVE')
            master_output_filepath = self.output_filepath.format('MASTER')
            master_and_slave_output_filepath = self.output_filepath.format('ALL')
            self.merge_pcap(master_and_slave_output_filepath, [slave_output_filepath, master_output_filepath])
            output_filepath = master_and_slave_output_filepath

        blog('Tcpdump on SMOD stopped!')
        return output_filepath

    @logged_keyword
    def collect_logs_from_smod_container(self, container, connection_alias, teardown=False):
        remote_log_path = self.remote_filepath.format(container)
        local_log_path = self.output_filepath.format(container)
        if teardown and os.path.exists(local_log_path):
            local_log_path = local_log_path[:-5] + '_TEARDOWN' + local_log_path[-5:]
        _ssh.execute(command="pkill -f tcpdump.*{}".format(remote_log_path), connection=connection_alias)
        _ssh.execute(command='chmod 777 ' + remote_log_path, connection=connection_alias)
        _ssh.download_file(remote_path=remote_log_path,
                           local_path=local_log_path,
                           connection=connection_alias)
        _ssh.execute(command='rm "{}"'.format(remote_log_path), connection=connection_alias)
        _ssh.disconnect(connection=connection_alias)

    @logged_keyword
    def teardown_tcpdump_on_smod(self):
        try:
            self.stop_tcpdump_and_download_logs_from_smod(teardown=True)
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

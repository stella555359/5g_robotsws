from taf.transport.ssh import ssh
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import os

_ssh = ssh()


class TcpdumpLte:
    def __init__(self):
        self.remote_filepath, self.output_filepath = None, None
        self.interface = None
        self._filter = None
        self.name_process = None

    @logged_keyword
    def setup_variables(self, filename=None, interface='any', _filter='sctp'):
        self.remote_filepath, self.output_filepath = self.setup_paths(filename)
        self.interface = interface
        self._filter = _filter

    @staticmethod
    def setup_paths(filename):
        filename = robot_globals.testname() + '.pcap' if filename is None else filename
        if not filename.endswith('.pcap'):
            filename += '.pcap'
        filename = filename.rsplit('.', 1)[0]
        remote_filepath = os.path.join('/tmp', filename + '_tcpdump_LTE.pcap')
        output_filepath = os.path.join(robot_globals.outputdir(), filename + '_tcpdump_LTE.pcap')

        return remote_filepath, output_filepath

    @logged_keyword
    def start_tcpdump_on_lte(self, filename=None, interface='any', _filter='sctp'):
        self.setup_variables(filename, interface, _filter)
        lte_alias = connections.connect_to_enb()

        command_template = 'tcpdump -i {} {} -w "' + self.remote_filepath + '"'
        cmd = command_template.format(self.interface, self._filter)
        _ssh.send_command(command=cmd, connection=lte_alias)
        self.name_process = cmd

        blog('Tcpdump on LTE started!')

    @logged_keyword
    def stop_tcpdump_and_download_logs_from_lte(self):
        lte_alias = connections.connect_to_enb()

        _ssh.execute(command="pkill '{}'".format(self.name_process), connection=lte_alias)
        _ssh.execute(command='chmod 777 ' + self.remote_filepath, connection=lte_alias)
        _ssh.download_file(remote_path=self.remote_filepath,
                           local_path=self.output_filepath,
                           connection=lte_alias)
        _ssh.execute(command='rm "{}"'.format(self.remote_filepath), connection=lte_alias)

        blog('Tcpdump on LTE stopped!')
        return self.output_filepath

    @logged_keyword
    def teardown_tcpdump_on_lte(self):
        try:
            self.stop_tcpdump_and_download_logs_from_lte()
        except Exception:
            blog('Tcpdump traces have already been collected. Teardown will not download tcpdump traces.')

import re
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture


IP_ADDRESS_REGEX = r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'


class IperfCommandAssembler:
    def __init__(self):
        self.ue_ip, self.pgw_ip = self.__get_ue_and_pgw_ip()

        self.__arguments = {'--client': self.ue_ip,
                            '--bind': self.pgw_ip,
                            '--bandwidth': '1M',
                            '--time': '10',
                            '--interval': '1',
                            '--port': '4321'}

    def from_ue_to_pgw(self):
        self.__arguments['--client'] = self.ue_ip
        self.__arguments['--bind'] = self.pgw_ip
        return self

    def from_pgw_to_ue(self):
        self.__arguments['--client'] = self.pgw_ip
        self.__arguments['--bind'] = self.ue_ip
        self.__arguments['--port'] = '5410'
        return self

    def with_custom_ue_ip(self, ip):
        match = re.search(IP_ADDRESS_REGEX, ip)
        assert match, 'IP address not found in line: {}'.format(ip)
        self.ue_ip = match.group()
        return self

    def with_custom_pgw_ip(self, ip):
        match = re.search(IP_ADDRESS_REGEX, ip)
        assert match, 'IP address not found in line: {}'.format(ip)
        self.pgw_ip = match.group()
        return self

    def with_bandwidth(self, bandwidth):
        self.__arguments['--bandwidth'] = bandwidth
        return self

    def with_transmit_time(self, time):
        self.__arguments['--time'] = time
        return self

    def with_buffer_length(self, length):
        self.__arguments.update({'-l': length})
        return self

    def on_client_ip(self, ip):
        self.__arguments['--client'] = ip
        return self

    def on_bind_ip(self, ip):
        self.__arguments['--bind'] = ip
        return self

    def on_port(self, port):
        self.__arguments['--port'] = port
        return self

    def run_in_server_mode(self):
        self.__arguments.update({'--server': ''})
        return self

    def no_bind(self):
        del self.__arguments['--bind']
        return self

    @fixture.logged_keyword
    def build(self):
        args = ''
        for key in self.__arguments:
            args += '{} {} '.format(key, self.__arguments[key])
        iperf = 'iperf -u ' + args
        return iperf

    def __get_ue_and_pgw_ip(self):
        if fixture.get_robot_variable('${tl.core.__class__.__name__}') == 'RealCore5G':
            return None, None
        with open(self.__get_cfg_file_from_epcsim(), 'r') as f:
            config_string = f.readlines()

        ue_ip = self.__get_ip_from_string('set_bearer id=1 ue=1', config_string)
        pgw_ip = self.__get_ip_from_string('PGW_ADDR=', config_string)

        return ue_ip, pgw_ip

    @staticmethod
    def __get_ip_from_string(search_pattern, config_string):
        for line in config_string:
            if search_pattern in line:
                match = re.search(IP_ADDRESS_REGEX, line)
                assert match, 'IP address not found in line: {}'.format(line)
                return match.group()

    @staticmethod
    def __get_cfg_file_from_epcsim():
        epcsim_cfg = '{dir}/{filename}'.format(dir=fixture.get_robot_variable('${tl.core.dir_path}'),
                                               filename=fixture.get_robot_variable('${tl.core.cfg_filename}'))
        local_cfg = '{dir}/{filename}'.format(dir=fixture.get_robot_variable("${LOG_PATH}"),
                                              filename=fixture.get_robot_variable("${tl.core.cfg_filename}"))
        epcsim_alias = fixture.run_robot_keyword('Connect to EPCsim', 'epcsim')
        epcsim_conn = fixture.ssh()
        epcsim_conn.download_file(
            remote_path=epcsim_cfg,
            local_path=local_cfg,
            connection=epcsim_alias)
        return local_cfg

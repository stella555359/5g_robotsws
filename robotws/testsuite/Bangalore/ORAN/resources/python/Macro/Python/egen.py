import os
import datetime
from moler.device import DeviceFactory
from moler.config import load_config
from taf.ul.moler.converter.moler_devices import MolerDevices
from testsuite.Bangalore.ORAN.resources.python.\
    Macro.Python.transfer_files import download_files
from testsuite.Bangalore.ORAN.resources.python.\
    Macro.Python.utilities import load_moler_configuration_from_tl


class Egen(object):
    DEVICE_NAME = 'EGEN'

    __instance = None
    __initialized = None

    def __new__(cls, *args, **kwargs):
        if Egen.__instance is None:
            Egen.__instance = super(Egen, cls).__new__(cls)

        return Egen.__instance

    def __init__(self, host, login, password, root_password=None,
                 egen_path=None):
        """
        Class for collecting and download egen logs.

        :param host: eGen ip address
        :param login: login
        :param password: password
        :param egen_path: path to directory where egen script is located.
        """
        if self.__initialized:
            return

        self.host = host
        self.login = login
        self.password = password
        self.root_password = root_password if root_password else password
        self.egen_path = egen_path
        self._log_path = None
        self._capture_cmd = None

        self._generate_and_load_egen_device()
        self.device = DeviceFactory.get_device(name=Egen.DEVICE_NAME)

        Egen.__initialized = True

    @classmethod
    def get_instance(cls):
        """
        Return instance of of this class.

        :return: Instance of this class.
        """
        return cls.__instance

    def capture_egen_log(self, ports, log_path=None, max_packets=100000,
                         options='', timeout=60,
                         run_in_background=True):
        """
        Generic method for collecting egen logs on eGen PC and return log path.
        :param ports:       PCI address of network interface's port used by
        eGen, eg:
                            '8:00.0' --> single port
                            ['8:00.0', '7:00.0']  --> list of ports
        :param log_path:    path to output log file - if None default will be
         used /tmp/egen_log_<current_date>.pcap
        :param max_packets: Specifies maximal number of packets to capture,
         default is 100 000.
        :param options:     Additional options for collecting - more info under
        :https://alatos.gitlabe1-pages.ext.net.nokia.com/eGen/master/options.html

        :param timeout:     timeout for running command - default 60 second
        :param run_in_background:  True/False.
        :return: path to log
        """
        if not log_path:
            log_path = self._get_default_log_path()

        self._log_path = log_path

        if max_packets:
            options = options + ' --max-packets ' + str(max_packets)

        self.device.goto_state('UNIX_REMOTE')

        egen_capture_cmd = self.device.get_cmd(cmd_name='egen',
                                               cmd_params={
                                                   'egen_path': self.egen_path,
                                                   'port': ports,
                                                   'capture': self._log_path,
                                                   'options': options})
        self._capture_cmd = self.device.get_cmd(
            cmd_name='sudo', cmd_params={'cmd_object': egen_capture_cmd,
                                         'password': self.root_password})

        if run_in_background:
            self._capture_cmd.start(timeout=timeout)
        else:
            self._capture_cmd(timeout=timeout)
        return log_path

    def stop_collecting_egen_logs(self):
        """
        Stop collecting egen logs if still running.
        :return: None
        """
        self._capture_cmd.break_cmd()

    def download_logs(self, download_dir, timeout=180):
        """
        Download collected eGen pcap log to directory on the local machine.

        :param download_dir: path to directory where file will be downloaded.
        :param timeout: timeout for scp.
        """
        download_files(local_dir=download_dir,
                       remote_file=os.path.basename(self._log_path),
                       remote_dir=os.path.dirname(self._log_path),
                       device_name=self.device.name,
                       timeout=timeout
                       )

    def _get_default_log_path(self):
        """
        Get default log path - /tmp/egen_log_<current_time>.pcap
        :return: egen_log_path
        """

        default_log_dir = '/tmp/'
        now = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
        log_path = os.path.join(default_log_dir,
                                'egen_log_{}.pcap'.format(now))
        return log_path

    @load_moler_configuration_from_tl()
    def _generate_and_load_egen_device(self):
        """
        Generate moler device, based on passed credentials in constructor.
        :return: None
        """

        md = MolerDevices()
        md.add_egen_configuration(device_name=Egen.DEVICE_NAME,
                                  host=self.host,
                                  login=self.login,
                                  password=self.password,
                                  root_password=self.root_password)
        load_config(config=md.get_moler_device_config(), config_type='dict')

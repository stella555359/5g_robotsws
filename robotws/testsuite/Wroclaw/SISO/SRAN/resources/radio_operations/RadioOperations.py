"""
:modified:14.03.2025

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""
from RadioInterface import RadioInterface
from FrmonInterface import FrmonInterface
from OldRuInterface import OldRuInterface
from FaultGenerator import FaultGenerator
from FaultAssertion import FaultAssertion
from SmodInterface import SmodInterface
from FileInterface import FileInterface
import radio_variables as variables
from robot.api.deco import keyword
from robot.api import logger

from exceptions import NotSupportedRuFamily, NotSupportedTypeOfRu, NotSupportedRuForDAPD, FaultAssertionError, \
    NotSupportedRadioUnit, AlarmAssertionError

ROBOT_AUTO_KEYWORDS = False

__version__ = '1.27'


class RadioOperations(FrmonInterface, OldRuInterface, FaultGenerator, SmodInterface, FaultAssertion, FileInterface):
    def __init__(self):
        super(RadioOperations, self).__init__()
        self.radio_interface = RadioInterface()
        self.ru_name = None
        self.ru_ip = None
        self.ru_serial_number = None
        self.remote_host = None

    def _setup_radio(self, ru_name, ru_ip, ru_serial_number, remote_host):
        self.ru_name = ru_name
        self.ru_ip = ru_ip
        self.ru_serial_number = ru_serial_number
        self.remote_host = remote_host

    def _setup_connection(self, mplane):
        self.hostname = self._get_hostname_for_mplane(mplane)
        self.dir_for_file = 'ram'
        self.tl_type = 'Classical'

    def _setup_cloud_connection(self):
        self.dir_for_file = 'tmp'
        self.tl_type = 'CloudRAN'

    @staticmethod
    def _get_hostname_for_mplane(mplane):
        if mplane is not None:
            return mplane
        else:
            return variables.hostname

    @keyword(name="Open Connection To Radio Module")
    def open_connection_to_radio_module(self, ru_serial_number, remote_host=None, cloud_server_ip=None,
                                        ru_name=None, via_mplane=None, **kwargs):
        """
        Open Connection To Radio Module

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**

        Establishes a connection to a specified radio module, supporting both local and cloud-based connections.

        This method initiates a connection to a radio module identified by its serial number. It supports connections
        through a local network or via a cloud server, depending on the parameters provided. The connection setup varies
        based on whether the radio module is part of a Cloud RAN (CRAN) or a traditional RAN setup. For CRAN setups,
        a cloud server IP must be specified, which triggers a different connection setup process tailored for cloud
        environments.

        +------------------+------+------------------------------------------------+
        | Argument         | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | The serial number of the radio unit.           |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | The IP address of the remote host.             |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | The MPLANE IP to connect through, if available.|
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | The IP of the Cloud VM, for CRAN setups.       |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Open Connection To Radio Module  ru_serial_number=L1181207093  remote_host=10.42.121.28
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            return self._open_connection_to_radio_module(ru_serial_number, remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            return self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip, **kwargs)

    @keyword(name="Get Carriers Power")
    def get_carriers_power(self, ru_serial_number, direction, cloud_server_ip=None, ru_name=None, remote_host=None,
                           print_table=True, return_antennas=True, via_mplane=None, **kwargs):
        """
        Get Carriers Power

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        .. warning::
        Supported radio types are:
        Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

        | **Full description:**
        KW for get power for all carriers found on radio module.
        Keyword can be used with `direction` parameter: TX or RX.
        At the end, table with power is printed to console,
        it can be disabled by `print_table` parameter.

        Keyword returns dictionary with antenna line as a key
        and nested dictionary with carriers power

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | direction        | Yes  | TX or RX                                       |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | print_table      | No   | Print to console table with power              |
        +------------------+------+------------------------------------------------+
        | return_antennas  | No   | Return dictionary with antenna lines or no     |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${power}  Get Carriers Power  ru_serial_number=K9192014762   direction=TX  remote_host=10.42.53.25
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        if any(ru_name in rus for rus in variables.RADIO_MODULES.values()):
            return self._get_carriers_information_frmon(
                ru_name=ru_name, direction=direction.lower(),
                print_table=print_table, type_of_info='power', return_antennas=return_antennas)
        elif any(ru_name in rus for rus in variables.TELNET_MODULES['GAIA']):
            return self._get_carriers_power_gaia(direction.lower(), print_table)
        elif any(ru_name in rus for rus in variables.TELNET_MODULES['WMP']):
            return self._get_carriers_power_wmp(direction.lower(), print_table)
        elif any(ru_name in rus for rus in variables.TELNET_MODULES['ALU']):
            raise NotSupportedTypeOfRu(ru_type='ALU', ru_name=ru_name)
        else:
            raise NotSupportedRadioUnit(ru_name)

    @keyword(name="Get Carriers Data")
    def get_carriers_data(self, ru_serial_number, direction, ru_name=None, remote_host=None,
                          cloud_server_ip=None, return_antennas=True, via_mplane=None, **kwargs):
        """
        Get Carriers Data

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        .. warning::
        Supported radio types are:
        Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

        | **Full description:**
        KW for get data for all carriers found on radio module.
        Keyword can be used with `direction` parameter: TX or RX.

        Keyword returns dictionary with carriers and information.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | direction        | Yes  | TX or RX                                       |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | return_antennas  | No   | Return dictionary with antenna lines or no     |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${power}  Get Carriers Data  ru_serial_number=K9192014762   direction=TX  remote_host=10.42.53.25
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        if any(ru_name in rus for rus in variables.RADIO_MODULES.values()):
            return self._get_carriers_information_frmon(
                ru_name=ru_name, direction=direction.lower(), type_of_info='data',
                print_table=False, return_antennas=return_antennas)
        elif any(ru_name in rus for rus in variables.TELNET_MODULES['GAIA']):
            return self._get_carriers_data_gaia(direction.lower())
        elif any(ru_name in rus for rus in variables.TELNET_MODULES['WMP']):
            return self._get_carriers_data_wmp(direction.lower())
        elif any(ru_name in rus for rus in variables.TELNET_MODULES['ALU']):
            raise NotSupportedTypeOfRu(ru_type='ALU', ru_name=ru_name)
        else:
            raise NotSupportedRadioUnit(ru_name)

    @keyword(name="Generate Fault")
    def generate_fault(self, fault_id, ru_serial_number, remote_host=None, via_mplane=None, cloud_server_ip=None,
                       ru_name=None, **kwargs):
        """
        Generate Fault

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        .. warning::
        Supported radio types are:
        Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

        | **Full description:**
        Keyword performs alarm trigger on radio modules >=5.1
        A few faults, e.g. 1911, 1936, can get more arguments,
        for more information please go to the README in main directory

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | fault_id         | Yes  | Fault to trigger                               |
        +------------------+------+------------------------------------------------+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+
        | **kwargs         | No   | Additional arguments                           |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Generate Fault  fault_id=1936  ru_serial_number=L1181207093  code_type=Temporary
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        ru_family = self.radio.get_radio_family(ru_name)
        if ru_family == '5.1':
            self._generate_fault_5_1(fault_id, **kwargs)
        elif ru_family == '6.1':
            self._generate_fault_6_1(fault_id, **kwargs)
        elif ru_family == '6.2':
            self._generate_fault_6_2(fault_id, **kwargs)
        elif ru_family == '8':
            self._generate_fault_8(fault_id, **kwargs)
        else:
            raise NotSupportedRuFamily(ru_family, fault_id)

        self.disconnect()

    @keyword(name="Recover Fault")
    def recover_fault(self, fault_id, ru_serial_number, remove_runtime_config=False, cloud_server_ip=None, ru_name=None,
                      remote_host=None, via_mplane=None, **kwargs):
        """
        Recover Fault

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        .. warning::
        Supported radio types are:
        Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

        | **Full description:**
        Keyword performs alarm recovery action on radio modules >=5.1
        A few faults, e.g. 1936, can get more arguments,
        for more information please go to the README.txt in main directory

        **Input Parameters:**

        +-----------------------+------+------------------------------------------------+
        | Input Parameters      | Man. | Description                                    |
        +=======================+======+================================================+
        | fault_id              | Yes  | Fault to trigger                               |
        +-----------------------+------+------------------------------------------------+
        | ru_serial_number      | Yes  | Radio serial number to set upconnection        |
        +-----------------------+------+------------------------------------------------+
        | remote_host           | No   | Remote host IP                                 |
        +-----------------------+------+------------------------------------------------+
        | remove_runtime_config |  No  | Additional runtime config reset, default False |
        +-----------------------+------+------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP       |
        +-----------------------+------+------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN            |
        +-----------------------+------+------------------------------------------------+
        | **kwargs              | No   | Additional arguments                           |
        +-----------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Recover Fault  fault_id=1936  ru_serial_number=L1181207093  code_type=Temporary

        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        ru_family = self.radio.get_radio_family(ru_name)
        if ru_family == '5.1':
            self._recover_fault_5_1(fault_id, **kwargs)
        elif ru_family == '6.1':
            self._recover_fault_6_1(fault_id, **kwargs)
        elif ru_family == '6.2':
            self._recover_fault_6_2(fault_id, **kwargs)
        elif ru_family == '8':
            self._recover_fault_8(fault_id, **kwargs)
        else:
            raise NotSupportedRuFamily(ru_family, fault_id)

        if remove_runtime_config:
            self._remove_runtime_config()
        self.disconnect()

    @keyword(name="Get TCS File")
    def get_tcs_file(self, ru_serial_number, remote_host=None, ru_name=None, cloud_server_ip=None,
                     via_mplane=None, **kwargs):
        """
        Get TCS File

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        .. warning::
        Supported radio types are:
        Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

        | **Full description:**
        Keyword returns TCS file transferred from radio module.
        TCS file contains information like: Thigh, Tdanger, NT_fail etc.

        Keyword returns dictionary.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${dictionary}  Get TCS File  ru_serial_number=L1181207093

        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        tcs_file = self._download_tcs_file()
        self.disconnect()
        return tcs_file

    @keyword(name="Send File Via SCP")
    def send_file_via_scp(self, ru_serial_number, direction, file_path, destination_directory, cloud_server_ip=None,
                          remote_host=None, ru_name=None, via_mplane=None, **kwargs):
        """
        Send File Via SCP

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        Keyword for file transferring between radio module and system module

        Keyword returns dictionary.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | direction        | Yes  | Two options: `to_smod` or `to_rmod`            |
        +------------------+------+------------------------------------------------+
        | file_path        | Yes  | Path to file with filename and extension       |
        +------------------+------+------------------------------------------------+
        | destination_directory | Yes  | Path to directory where file should be put|
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Send File Via SCP
        ...  ru_serial_number=L1181207093
        ...  direction=to_rmod
        ...  file_path=/ffs/new_file.json
        ...  destination_directory=/ram
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        self._send_file_via_scp(direction, file_path, destination_directory, **kwargs)
        self.disconnect()

    @keyword(name="Send Command")
    def send_command(self, command, delay=0):
        """
        Send Command

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        Keyword for sending command on the radio module
        Delay parameter means time after command sent.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | command          | Yes  | Command to send on the RU                      |
        +------------------+------+------------------------------------------------+
        | delay            | No   | Waiting time after sending the command in sec  |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Send Command  command=ls -a  delay=1
        """
        self._send_command(command, delay)

    @keyword(name="Read Output")
    def read_output(self, delay=0):
        """
        Read Output

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        Keyword for reading output from radio module terminal
        Delay parameter means time before output read.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | delay            | No   | Waiting time before reading output in sec      |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Read Output  delay=1
        """
        return self._read_output(delay)

    @keyword(name="Read Until Regexp")
    def read_until_regexp(self, regexp, timeout=5):
        """
        Read Until Regexp

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        Keyword reading output until regular expression.
        Keyword returns all output before finding regexp.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | regexp           | Yes  | Regular expression                             |
        +------------------+------+------------------------------------------------+
        | timeout          | No   | Timeout for regexp                             |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Read Until Regexp  'fingerprint|#|[pP]assword'  timeout=10
        """
        return self._read_until_regexp(regexp, timeout)

    @keyword(name="Read Until Prompt")
    def read_until_prompt(self, prompt, timeout=5):
        """
        Read Until Prompt

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        Keyword reading output until prompt.
        A few prompts can be pass, e.g. '#|>|$'
        Keyword returns all output before finding prompt.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | prompt           | Yes  | Prompt, e.g. #|>|$                             |
        +------------------+------+------------------------------------------------+
        | timeout          | No   | Timeout for prompt                             |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Read Until Prompt  '|#|$|>'  timeout=10
        """
        return self._read_until_prompt(prompt, timeout)

    @keyword(name='Close SSH Connection')
    def close_ssh_connection(self):
        """
        Close SSH Connection

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        Keyword for close all ssh connection with tunnels.

        **Example:**

        .. code-block:: robotframework

        Close SSH Connection
        """
        self.disconnect()

    @keyword(name='Get NR Frequency By NRARFCN')
    def get_nr_frequency_by_nrarfcn(self, nrarfcn):
        """
        Get NR Frequency By NRARFCN

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        KW returns carrier frequency based on NRARFCN value

        **Example:**

        .. code-block:: robotframework

        ${frequency}  Get NR Frequency By NRARFCN
        """

        return self._get_nr_frequency_by_nrarfcn(nrarfcn)

    @keyword(name='Get TX Pipes Power From DAPD')
    def get_tx_pipes_power_from_dapd(self, ru_serial_number, remote_host=None, print_table=True, cloud_server_ip=None,
                                     ru_name=None, via_mplane=None, **kwargs):
        """
        Get TX Pipes Power From DAPD

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        .. warning::
        Supported radio types are:
        Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

        | **Full description:**
        KW for get power for all pipes found on radio module.
        At the end, table with power is printed to console,
        it can be disabled by `print_table` parameter.

        Keyword returns dictionary with virtual antenna line as a key
        and value with power.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | print_table      | No   | Print to console table with power              |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${power}  Get TX Pipes Power From DAPD  ru_serial_number=K9192014762  remote_host=10.42.53.25

        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        if any(ru_name in rus for rus in variables.RADIO_MODULES.values()):
            return self._get_tx_dapd_power(ru_name, print_table)
        else:
            raise NotSupportedRuForDAPD(ru_name)

    @keyword(name="Get Airscale BBMOD Mapping")
    def get_airscale_bbmod_mapping(self, remote_host=None, print_table=True, via_mplane=None):
        """
        Get AirScale BBMOD Mapping

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        KW for getting bbmod mapping for AirScale module
        KW returns dictionary where keys is/are AirScale modules with serial numbers.
        Values are BBMODs with serial numbers.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | print_table      | No   | Print table with IPs to console, default True  |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Get AirScale BBMOD Mapping  remote_host=10.42.121.28  print_table=False
        """
        self._setup_connection(via_mplane)
        return self._get_airscale_bbmod_mapping(remote_host, print_table)

    @keyword(name="Get Active Software Release From ENB")
    def get_active_software_release_from_enb(self, full_build_name=False, remote_host=None, via_mplane=None):
        """
        Get Active Software Release From ENB

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        KW for getting active software release from Enb
        KW returns string with software release.
        If `full_build_name` is set to True, KW returns full name of SBTS build.

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | full_build_name  | No   | If `True`, then return full name of SBTS build |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${release}  Get Active Software Release  full_build_name=True

        """
        self._setup_connection(via_mplane)
        return self._get_active_software_release_from_enb(remote_host, full_build_name)

    @keyword(name="Get Passive Software Release From ENB")
    def get_passive_software_release_from_enb(self, full_build_name=False, remote_host=None, via_mplane=None):
        """
        Get Passive Software Release From ENB

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        KW for getting active software release from Enb
        KW returns string with software release.
        If `full_build_name` is set to True, KW returns full name of SBTS build.

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | full_build_name  | No   | If `True`, then return full name of SBTS build |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${release}  Get Passive Software Release  full_build_name=True

        """
        self._setup_connection(via_mplane)
        return self._get_passive_software_release_from_enb(remote_host, full_build_name)

    @keyword(name="Get IP For All Radio Modules")
    def get_ip_for_all_radio_modules(self, remote_host=None, print_table=True, via_mplane=None, cloud_server_ip=None):
        """
        Get IP For All Radio Modules

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        KW for getting IP addresses for all RU connected to SMOD(s)
        KW returns dictionary with Radio Modules IPs

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | print_table      | No   | Print table with IPs to console, default True  |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+
        **Example:**

        .. code-block:: robotframework

        ${ips_dict}  Get IP For All Radio Modules  print_table=False
        """
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            return self._get_ip_for_all_radio_modules(remote_host, print_table)
        else:
            self.connect_to_cloud_server(cloud_server_ip)
            return self._cloud_get_ip_for_all_radio_modules(print_table)

    @keyword(name='Assert Active Fault In Fault History Log File')
    def assert_active_fault_in_fault_history_log_file(self, ru_serial_number, fault_id, severity=None, fault_name=None,
                                                      cloud_server_ip=None, ru_name=None, remote_host=None,
                                                      via_mplane=None, **kwargs):
        """
        Assert Active Fault In History

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Check if given fault_id, severity and fault_name is active in fault_history_log.txt

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | fault_id         | Yes  | faultId to assert                              |
        +------------------+------+------------------------------------------------+
        | severity         | No   | critical/major/minor                           |
        +------------------+------+------------------------------------------------+
        | fault_name       | No   | fault name to assert                           |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        | **Return value:**
        | Raise exception if conditions not met

        **Example:**

        .. code-block:: robotframework

        Assert Active In Fault History Log File  ru_serial_number=DB38473VkA9  fault_id=1197  severity=major
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            self._open_connection_to_radio_module(ru_serial_number, remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        status = self._assert_active_fault_in_fault_history_log_file(fault_id, severity, fault_name)
        if status is False:
            self.disconnect()
            raise FaultAssertionError(fault_id, severity, 'Active', fault_name)

        self.disconnect()

    @keyword(name='Assert Inactive Fault In Fault History Log File')
    def assert_inactive_fault_in_fault_history_log_file(self, ru_serial_number, fault_id, severity=None,
                                                        fault_name=None, remote_host=None, cloud_server_ip=None,
                                                        ru_name=None, via_mplane=None, **kwargs):
        """
        Assert Inactive Fault In History

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Check if given fault_id with severity is Inactive in fault_history_log.txt

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | fault_id         | Yes  | faultId to assert                              |
        +------------------+------+------------------------------------------------+
        | severity         | No   | critical/major/minor                           |
        +------------------+------+------------------------------------------------+
        | fault_name       | No   | fault name to assert                           |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        | **Return value:**
        | Raise exception if conditions not met

        **Example:**

        .. code-block:: robotframework

        Assert Inactive Fault In Fault History Log File  ru_serial_number=DB38473VkA9  fault_id=1197  severity=major
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            self._open_connection_to_radio_module(ru_serial_number, remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        status = self._assert_inactive_fault_in_fault_history_log_file(fault_id, severity, fault_name)
        if status is False:
            self.disconnect()
            raise FaultAssertionError(fault_id, severity, 'Inactive', fault_name)

        self.disconnect()

    @keyword(name='Assert Inactive Alarm In Fault History Log File')
    def assert_inactive_alarm_fault_in_fault_history_log_file(self, ru_serial_number, alarm_id, alarm_name,
                                                              severity=None, remote_host=None, cloud_server_ip=None,
                                                              ru_name=None, via_mplane=None, **kwargs):
        """
        Assert Inactive Alarm In History

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Check if given alarm_id with severity and alarm_name is Inactive in fault_history_log.txt

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | alarm_id         | Yes  | alarmId to assert                              |
        +------------------+------+------------------------------------------------+
        | alarm_name       | Yes  | alarm name to assert                           |
        +------------------+------+------------------------------------------------+
        | severity         | No   | critical/major/minor                           |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        | **Return value:**
        | Raise exception if conditions not met

        **Example:**

        .. code-block:: robotframework

        Assert Inactive Alarm In Fault History Log File  ru_serial_number=DB38473VkA9  alarm_id=1197  severity=major
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            self._open_connection_to_radio_module(ru_serial_number, remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        status = self._assert_inactive_alarm_in_fault_history_log_file(alarm_id, severity, alarm_name)
        if status is False:
            self.disconnect()
            raise AlarmAssertionError(alarm_id, severity, 'Inactive', alarm_name)

        self.disconnect()

    @keyword(name='Assert Active Alarm In Fault History Log File')
    def assert_active_alarm_fault_in_fault_history_log_file(self, ru_serial_number, alarm_id, alarm_name,
                                                            severity=None, remote_host=None, cloud_server_ip=None,
                                                            ru_name=None, via_mplane=None, **kwargs):
        """
        Assert Active Alarm In History

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Check if given alarm_id with severity and alarm_name is active in fault_history_log.txt

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | alarm_id         | Yes  | alarmId to assert                              |
        +------------------+------+------------------------------------------------+
        | alarm_name       | Yes  | alarm name to assert                           |
        +------------------+------+------------------------------------------------+
        | severity         | No   | critical/major/minor                           |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        | **Return value:**
        | Raise exception if conditions not met

        **Example:**

        .. code-block:: robotframework

        Assert Active Alarm In Fault History Log File  ru_serial_number=DB38473VkA9  alarm_id=1197  severity=major
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            self._open_connection_to_radio_module(ru_serial_number, remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        status = self._assert_active_alarm_in_fault_history_log_file(alarm_id, severity, alarm_name)
        if status is False:
            self.disconnect()
            raise AlarmAssertionError(alarm_id, severity, 'Active', alarm_name)

        self.disconnect()

    @keyword(name='Assert Fault Event In Fault History Log File')
    def assert_fault_event_in_fault_history_log_file(self, ru_serial_number, fault_id, state, severity=None,
                                                     fault_name=None, remote_host=None, via_mplane=None,
                                                     cloud_server_ip=None, ru_name=None, **kwargs):
        """
        Assert Fault Event In History

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Check if given fault_id with severity and event (active or cleared) is found in fault_history_log.txt

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | fault_id         | Yes  | faultId to assert                              |
        +------------------+------+------------------------------------------------+
        | state            | Yes  | 'active' or 'cleared' in Fault Events section  |
        +------------------+------+------------------------------------------------+
        | severity         | No   | critical/major/minor                           |
        +------------------+------+------------------------------------------------+
        | fault_name       | No   | fault_name to assert                           |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        | **Return value:**
        | Raise exception if conditions not met

        **Example:**

        .. code-block:: robotframework

        Assert Fault Event In Fault History Log File
        ...  ru_serial_number=DB38473VkA9
        ...  fault_id=1197  severity=major
        ...  state=cleared
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            self._open_connection_to_radio_module(ru_serial_number, remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        status = self._assert_fault_event_in_fault_history_log_file(fault_id, severity, state, fault_name)
        if status is False:
            self.disconnect()
            raise FaultAssertionError(fault_id, severity, state, fault_name)

        self.disconnect()

    @keyword(name='Assert Alarm Event In Fault History Log File')
    def assert_alarm_event_in_fault_history_log_file(self, ru_serial_number, alarm_id, alarm_name, state,
                                                     severity=None, remote_host=None, via_mplane=None,
                                                     cloud_server_ip=None, ru_name=None, **kwargs):
        """
        Assert Alarm Event In History

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Check if given alarm_id with severity, alarm_name and event (active or cleared)
        | is found in fault_history_log.txt

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | alarm_id         | Yes  | alarmId to assert                              |
        +------------------+------+------------------------------------------------+
        | state            | Yes  | 'active' or 'cleared' in Fault Events section  |
        +------------------+------+------------------------------------------------+
        | alarm_name       | Yes  | alarm_name to assert                           |
        +------------------+------+------------------------------------------------+
        | severity         | No   | critical/major/minor                           |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        | **Return value:**
        | Raise exception if conditions not met

        **Example:**

        .. code-block:: robotframework

        Assert Alarm Event In Fault History Log File
        ...  ru_serial_number=DB38473VkA9
        ...  alarm_id=1197  severity=major
        ...  state=cleared
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            self._open_connection_to_radio_module(ru_serial_number, remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        status = self._assert_alarm_event_in_fault_history_log_file(alarm_id, severity, state, alarm_name)
        if status is False:
            self.disconnect()
            raise AlarmAssertionError(alarm_id, severity, state, alarm_name)

        self.disconnect()

    @keyword(name='Kill Process On Radio Module By Name')
    def kill_process_on_radio_module_by_name(self, ru_serial_number, process_name, remote_host=None,
                                             via_mplane=None, cloud_server_ip=None, ru_name=None, **kwargs):
        """
        Kill Process On Radio Module By Name

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Kill process based on given name of the process

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_serial_number | Yes  | Radio serial number to set upconnection        |
        +------------------+------+------------------------------------------------+
        | process_name     | Yes  | process name to kill                           |
        +------------------+------+------------------------------------------------+
        | remote_host      | No   | Remote host IP                                 |
        +------------------+------+------------------------------------------------+
        | via_mplane       | No   | MPLANE IP to connect instead of local IP       |
        +------------------+------+------------------------------------------------+
        | cloud_server_ip  | No   | Cloud VM IP if radio module in CRAN            |
        +------------------+------+------------------------------------------------+

        | **Return value:**
        | Raise exception if process id for given name not found or found more than one process with given name

        **Example:**

        .. code-block:: robotframework

        Kill Process On Radio Module By Name
        ...    ru_serial_number=${RU_SERIAL}
        ...    process_name=eventcollector
        ...    remote_host=${REMOTE_HOST}
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name = self._open_connection_to_radio_module(ru_serial_number, remote_host, **kwargs)[0]
        else:
            self._setup_cloud_connection()
            ru_name = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)[0]

        ru_family = self.radio.get_radio_family(ru_name)
        self._kill_process_on_radio_module(process_name, ru_family)
        self.disconnect()

    @keyword(name='Override Values In Binary File')
    def override_values_in_binary_file(self, ru_serial_number, filename, values_dict, reset_ru=False,
                                       cloud_server_ip=None, ru_name=None, code_type='Permanent', remote_host=None,
                                       via_mplane=None, **kwargs):
        """
        Override In Decoded Binary File

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Open and replace values for existing keys in decoded binary file.

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to set upconnection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | filename              | Yes  | One of binary files from /run/coma/type on RU                           |
        +-----------------------+------+-------------------------------------------------------------------------+
        | values_dict           | Yes  | Dictionary with key(s) and value(s)                                     |
        +-----------------------+------+-------------------------------------------------------------------------+
        | reset_ru              | No   | Define if reset RU should be perform after override, default is False   |
        +-----------------------+------+-------------------------------------------------------------------------+
        | code_type             | No   | Define type of coding binary file, default is Permanent                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        radio.Override Values In Binary File
        ...    ru_serial_number=${RU_SERIAL}
        ...    filename=sysmon_primary
        ...    values_dict=${dict}
        ...    reset_ru=True
        ...    code_type=Temporary
        ...    remote_host=${REMOTE_HOST}
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        self._override_values_in_binary_file(filename, values_dict, reset_ru, code_type)
        self.disconnect()

    @keyword(name='Get Decoded Binary File')
    def get_decoded_binary_file(self, ru_serial_number, filename, remote_host=None, cloud_server_ip=None, ru_name=None,
                                via_mplane=None, **kwargs):
        """
        Get Decoded Binary File

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for decode binary file and return as dictionary

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | filename              | Yes  | One of binary files from /run/coma/type on RU                           |
        +-----------------------+------+-------------------------------------------------------------------------+
        | remote_host           | No   | Remote host IP                                                          |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${binary_file_dict}  radio.Get Decoded Binary File
        ...    ru_serial_number=${RU_SERIAL}
        ...    filename=sysmon_primary
        ...    remote_host=${REMOTE_HOST}
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        file = self._get_decoded_binary_file(filename)
        self.disconnect()
        return file

    @keyword(name='Reboot Radio Module')
    def reboot_radio_module(self):
        """
        Reboot Radio Module

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for reboot radio module by command

        **Example:**

        .. code-block:: robotframework

        radio.Reboot Radio Module
        ...    ru_serial_number=${RU_SERIAL}
        """
        self._reboot_ru()

    @keyword(name='Override CRC32 Hash In Integrity File')
    def override_crc32_hash_in_integrity_file(self, ru_serial_number, new_value, reset_ru=False, remote_host=None,
                                              cloud_server_ip=None, ru_name=None, via_mplane=None, **kwargs):
        """
        Override CRC32 Hash In Integrity File

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for change CRC32 hash value in SWman integrity slot files.
        | All SWman integrity files have replaced CRC32 hash value.
        | Keyword returns overrided value.

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | new_value             | Yes  | Dictionary with new values for all integrity files                      |
        +-----------------------+------+-------------------------------------------------------------------------+
        | reset_ru              | No   | Define if reset RU should be perform after override, default is False   |
        +-----------------------+------+-------------------------------------------------------------------------+
        | remote_host           | No   | Remote host IP                                                          |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${dict}  Create Dictionary  0=12345qwe  1=67890vv
        radio.Override CRC32 Hash In Integrity File
        ...    ru_serial_number=${RU_SERIAL}
        ...    new_value=${dict}
        ...    remote_host=10.42.178.57
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        overrided_value = self._override_crc32_hash_in_integrity_file(new_value)

        if reset_ru:
            self._reboot_ru()

        self.disconnect()
        return overrided_value

    @keyword(name='Get SFP Info From Radio Module')
    def get_sfp_info_from_radio_module(self, ru_serial_number, sfp_id, remote_host=None, via_mplane=None,
                                       cloud_server_ip=None, ru_name=None, **kwargs):
        """
        Get SFP Info From Radio Module

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for getting information from radio module about SFP
        | Keyword returns dictionary

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | sfp_id                | Yes  | SFP ID to get information                                               |
        +-----------------------+------+-------------------------------------------------------------------------+
        | remote_host           | No   | Remote host IP                                                          |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        radio.Get SFP Info From Radio Module
        ...    ru_serial_number=${RU_SERIAL}
        ...    sfp_id=2
        ...    remote_host=10.42.178.57
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        sfp_info_dict = self._get_sfp_info_from_radio_module(sfp_id)

        self.disconnect()
        return sfp_info_dict

    @keyword(name='Enable Radio Module Fail Safe Mode')
    def enable_radio_module_fail_safe_mode(self, ru_serial_number, radio_reset=True, cloud_server_ip=None, ru_name=None,
                                           remote_host=None, via_mplane=None, **kwargs):
        """
        Enable Radio Module Fail Safe Mode

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for enable fail-safe mode on radio module
        | Keyword performs radio module reboot until radio_reset == True

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | radio_reset           | No   | Force radio reset after fail safe mode change, default: True            |
        +-----------------------+------+-------------------------------------------------------------------------+
        | remote_host           | No   | Remote host IP                                                          |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        radio.Enable Radio Module Fail Safe Mode
        ...    ru_serial_number=${RU_SERIAL}
        ...    remote_host=10.42.178.57
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        self._enable_fail_safe_mode(radio_reset)
        self.disconnect()

    @keyword(name='Disable Radio Module Fail Safe Mode')
    def disable_radio_module_fail_safe_mode(self, ru_serial_number, radio_reset=True, cloud_server_ip=None,
                                            ru_name=None, remote_host=None, via_mplane=None, **kwargs):
        """
        Disable Radio Module Fail Safe Mode

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for disable fail-safe mode on radio module
        | Keyword performs radio module reboot until radio_reset == True

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | radio_reset           | No   | Force radio reset after fail safe mode change, default: True            |
        +-----------------------+------+-------------------------------------------------------------------------+
        | remote_host           | No   | Remote host IP                                                          |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        radio.Disable RU Fail Safe Mode
        ...    ru_serial_number=${RU_SERIAL}
        ...    remote_host=10.42.178.57
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        self._disable_fail_safe_mode(radio_reset)
        self.disconnect()

    @keyword(name='Get Fail Safe Mode Status')
    def get_fail_safe_mode_status(self, ru_serial_number, remote_host=None, via_mplane=None, cloud_server_ip=None,
                                  ru_name=None, **kwargs):
        """
        Get Fail Safe Mode Status

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for getting fail-safe mode status on RU
        | Keyword returns str: Disabled or Enabled

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | remote_host           | No   | Remote host IP                                                          |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        radio.Get Fail Safe Mode Status
        ...    ru_serial_number=${RU_SERIAL}
        ...    remote_host=10.42.178.57
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        status = self._get_fail_safe_mode_status()
        self.disconnect()

        return status

    @keyword(name='Collect Radio Module Snapshot')
    def collect_radio_module_snapshot(self, ru_serial_number, coverage='Full', remote_host=None, cloud_server_ip=None,
                                      ru_name=None, via_mplane=None, **kwargs):
        """
        Collect Radio Module Snapshot

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for getting snapshot logs on radio module
        | Keyword returns str: name of snapshot file

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | coverage              | No   | RF logs coverage, Full or Minor                                         |
        +-----------------------+------+-------------------------------------------------------------------------+
        | remote_host           | No   | Remote host IP                                                          |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        radio.Collect Radio Module Snapshot
        ...    ru_serial_number=${RU_SERIAL}
        ...    coverage=Minor
        ...    remote_host=10.42.178.57
        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        logs_pack_name = self._collect_radio_module_snapshot(coverage)
        self.disconnect()

        return logs_pack_name

    @keyword(name='Compare Radio Module And WebEM Snapshots')
    def compare_radio_module_and_webem_snapshots(self, ru_serial_number, ru_snapshot_path, webem_snapshot_path):
        """
        Compare Radio Module And WebEM Snapshots

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for comparing radio module snapshot and WebEM snapshot
        | The keyword is used to compare the content of a snapshot retrieved directly from the radio
        | using the command log -a -z with the snapshot from WebEM.
        | It checks whether all files from the radio snapshot are included in the snapshot_file_list.txt file.
        | WebEM snapshot must be collected in the "Full" version.

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to extract from WebEM snapshot                      |
        +-----------------------+------+-------------------------------------------------------------------------+
        | ru_snapshot_path      | Yes  | ZIP file with radio module logs                                         |
        +-----------------------+------+-------------------------------------------------------------------------+
        | webem_snapshot_path   | Yes  | ZIP file with WebEM snapshot                                            |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        radio.Compare Radio Module And WebEM Snapshots
        ...    ru_serial_number=${RU_SERIAL}
        ...    ru_snapshot_path=/home/ute/LOGS_BL2244D50Y4_040424_1134.zip
        ...    webem_snapshot_path=/home/ute/Snapshot_MRBTS-1305_SBTS24R3_ENB_9999_240325_000012_20240329-1620.zip
        """

        self._compare_radio_module_and_webem_snapshots(ru_serial_number, ru_snapshot_path, webem_snapshot_path)

    @keyword(name='Check File In ZIP Archive')
    def check_file_in_zip_archive(self, zip_path, regex_pattern):
        """
        Check if a file exists within a ZIP archive based on a regular expression pattern.

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | This keyword checks whether a file matching the given regular expression pattern
        | exists within the specified ZIP archive.

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | zip_path              | Yes  | The path to the ZIP archive.                                            |
        +-----------------------+------+-------------------------------------------------------------------------+
        | regex_pattern         | Yes  | The regex pattern used to match file names within the ZIP archive.      |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Check File In ZIP Archive
        ...    zip_path=/path/to/archive.zip
        ...    regex_pattern='\\d+_BBOX5'
        """

        self._check_file_in_zip_archive(zip_path, regex_pattern)

    @keyword(name="Get Radio Module Hardware Family")
    def get_radio_module_hardware_family(self, ru_name):
        """
        Get Radio Module Hardware Family

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        .. warning::
        Supported radio types are:
        Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

        | **Full description:**
        Keyword returns HW family based on RADIO_MODULES dictionary

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +==================+======+================================================+
        | ru_name          | Yes  | Radio module name e.g. AHEB                    |
        +------------------+------+------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${hw_family}  Get Radio Module Hardware Family  ru_name=AHFII

        """

        ru_family = self.radio.get_radio_family(ru_name)

        return ru_family

    @keyword(name="Enable Root Account On FHS")
    def enable_root_account_on_fhs(self, ru_serial_number, remote_host=None, via_mplane=None):
        """
        Enable Root Account On FHS

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        .. warning::
        Supported radio types are:
        FHS added to RADIO_MODULES

        | **Full description:**
        Keyword for enabling root(toor4nsn) account on FHS modules.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +=======================+======+===========================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection   |
        +-----------------------+------+-------------------------------------------+
        | remote_host           | No   | Remote host IP                            |
        +-----------------------+------+-------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP  |
        +-----------------------+------+-------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN       |
        +-----------------------+------+-------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Enable Root Account On FHS
        ...  ru_serial_number=${RU_SERIAL}

        """
        self._setup_connection(via_mplane)
        ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number, remote_host)
        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        self._enable_root_account_on_fhs()
        self.disconnect()

    @keyword(name="Disable Root Account On FHS")
    def disable_root_account_on_fhs(self, ru_serial_number, remote_host=None, via_mplane=None):
        """
        Disable Root Account On FHS

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        .. warning::
        Supported radio types are:
        FHS added to RADIO_MODULES

        | **Full description:**
        Keyword for disabling root(toor4nsn) account on FHS modules.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +=======================+======+===========================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection   |
        +-----------------------+------+-------------------------------------------+
        | remote_host           | No   | Remote host IP                            |
        +-----------------------+------+-------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP  |
        +-----------------------+------+-------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN       |
        +-----------------------+------+-------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Disable Root Account On FHS
        ...  ru_serial_number=${RU_SERIAL}

        """
        kwargs = {'username': variables.username, 'password': variables.password}
        self._setup_connection(via_mplane)
        ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number, remote_host,
                                                                                   **kwargs)
        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        self._disable_root_account_on_fhs()
        self.disconnect()

    @keyword(name="Remove Radio Module Runtime Configuration")
    def remove_radio_module_runtime_configuration(self, ru_serial_number, remote_host=None, cloud_server_ip=None,
                                                  ru_name=None, via_mplane=None, **kwargs):
        """
        Remove Radio Module Runtime Configuration

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        .. warning::
        Supported radio types are:
        5.1, 6.1 and 6.2

        | **Full description:**
        Keyword for removing runtime configuration on radio module.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +=======================+======+===========================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection   |
        +-----------------------+------+-------------------------------------------+
        | remote_host           | No   | Remote host IP                            |
        +-----------------------+------+-------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP  |
        +-----------------------+------+-------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN       |
        +-----------------------+------+-------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Remove Radio Module Runtime Configuration
        ...  ru_serial_number=${RU_SERIAL}

        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        self._remove_runtime_config()
        self.disconnect()

    @keyword(name="Reboot Radio Module And Wait For Ping")
    def reboot_radio_module_and_wait_for_ping(self, ru_serial_number, reconnect_timeout=120, ping_down_timeout=60,
                                              remote_host=None, cloud_server_ip=None, ru_name=None, via_mplane=None,
                                              **kwargs):
        """
        Reboot Radio Module And Wait For Ping

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainers:** mateusz.kawka@nokia.com

        | **Full description:**
        Keyword for reboot RU and waiting for ping up.

        **Input Parameters:**

        +------------------+------+------------------------------------------------+
        | Input Parameters | Man. | Description                                    |
        +=======================+======+===========================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection   |
        +-----------------------+------+-------------------------------------------+
        | reconnect_timeout     | No   | Timeout for reconnection to radio module  |
        +-----------------------+------+-------------------------------------------+
        | ping_down_timeout     | No   | Timeout for lost ping                     |
        +-----------------------+------+-------------------------------------------+
        | remote_host           | No   | Remote host IP                            |
        +-----------------------+------+-------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP  |
        +-----------------------+------+-------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN       |
        +-----------------------+------+-------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        Remove Radio Module Runtime Configuration
        ...  ru_serial_number=${RU_SERIAL}

        """
        if ru_name:
            logger.warn('"ru_name" argument is not used anymore, please remove it from your test case!')
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        self._reboot_and_wait_for_ping(reconnect_timeout, ping_down_timeout)
        self.disconnect()

    @keyword(name="Get Radio Unit Temperature By Sensor")
    def get_radio_unit_temperature_by_sensor(self, ru_serial_number, sensor_name, remote_host=None,
                                             cloud_server_ip=None, via_mplane=None, **kwargs):
        """
        Get Radio Unit Temperature By Sensor

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for retrieving the temperature from a specified sensor on the radio unit newer or equal 5.1
        | Keyword returns the temperature value from the specified sensor.

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | sensor_name           | Yes  | The name of the sensor to retrieve the temperature from                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | remote_host           | No   | Remote host IP                                                          |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${sensor_temperature}  Get Radio Unit Temperature By Sensor
        ...    ru_serial_number=${RU_SERIAL}
        ...    sensor_name=/rf/nahka1
        ...    remote_host=10.42.178.57
        """
        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        ru_family = self.get_radio_module_hardware_family(ru_name)
        if float(ru_family) < 5.1:
            raise Exception(f"Radio family {ru_family} is not supported for temperature measurements")

        sensor_temperature = self._get_radio_unit_temperature_by_sensor(sensor_name)
        self.disconnect()
        return sensor_temperature

    @keyword(name='Get Radio Unit PSU Measurements')
    def get_radio_unit_psu_measurements(self, ru_serial_number, number_of_measurements=1, interval=0, remote_host=None,
                                        cloud_server_ip=None, via_mplane=None, **kwargs):
        """
        Get Radio Unit PSU Measurements

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for retrieving power, current and voltage measurements from the radio unit newer or equal 5.1
        | Keyword returns a list of dictionaries with the measurements.

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | number_of_measurements| No   | Number of measurements to retrieve, default is 1                        |
        +-----------------------+------+-------------------------------------------------------------------------+
        | interval              | No   | Time interval between measurements in seconds, default is 0             |
        +-----------------------+------+-------------------------------------------------------------------------+
        | remote_host           | No   | Remote host IP                                                          |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${sensor_temperature}  Get Radio Unit PSU Measurements
        ...    ru_serial_number=${RU_SERIAL}
        ...    interval=3
        ...    number_of_measurements=3
        ...    remote_host=10.42.178.57
        """

        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        ru_family = self.get_radio_module_hardware_family(ru_name)
        if float(ru_family) < 5.1:
            raise Exception(f"Radio family {ru_family} is not supported for PSU measurements")

        measurements = self._get_a_few_radio_unit_psu_measurements(number_of_measurements, int(interval))
        self.disconnect()
        return measurements

    @keyword(name='Get Temperature Offset By Sensor Name')
    def get_temperature_offset_by_sensor_name(self, ru_serial_number, sensor_name, remote_host=None,
                                              cloud_server_ip=None, via_mplane=None, **kwargs):
        """
        Get Temperature Offset By Sensor Name

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for retrieving temperature offset from a specified sensor on the radio unit newer or equal 5.1

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | sensor_name           | Yes  | Sensor name for offset                                                  |
        +-----------------------+------+-------------------------------------------------------------------------+
        | remote_host           | No   | Remote host IP                                                          |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${temperature_offset}  Get Temperature Offset By Sensor Name
        ...    ru_serial_number=${RU_SERIAL}
        ...    sensor_name=module:CORE
        ...    remote_host=10.42.178.57
        """

        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        ru_family = self.get_radio_module_hardware_family(ru_name)
        if float(ru_family) < 5.1:
            raise Exception(f"Radio family {ru_family} is not supported for PSU measurements")

        temp_offset = self._get_temperature_offset_for_sensor_name(sensor_name)
        self.disconnect()

        return temp_offset

    @keyword(name='Get Sensors Temperature From RF Logs')
    def get_sensors_temperature_from_rf_logs(self, ru_serial_number, remote_host=None, cloud_server_ip=None,
                                             via_mplane=None, **kwargs):
        """
        Get Sensors Temperature From RF Logs

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Keyword for getting dictionary with sensors temperature from RF logs.

        +-----------------------+------+-------------------------------------------------------------------------+
        | Input Parameters      | Man. | Description                                                             |
        +=======================+======+=========================================================================+
        | ru_serial_number      | Yes  | Radio serial number to setup connection                                 |
        +-----------------------+------+-------------------------------------------------------------------------+
        | remote_host           | No   | Remote host IP                                                          |
        +-----------------------+------+-------------------------------------------------------------------------+
        | via_mplane            | No   | MPLANE IP to connect instead of local IP                                |
        +-----------------------+------+-------------------------------------------------------------------------+
        | cloud_server_ip       | No   | Cloud VM IP if radio module in CRAN                                     |
        +-----------------------+------+-------------------------------------------------------------------------+

        **Example:**

        .. code-block:: robotframework

        ${temperature_offset}  Get Sensors Temperature From RF Logs
        ...    ru_serial_number=${RU_SERIAL}
        ...    remote_host=10.42.178.57
        """

        if cloud_server_ip is None:
            self._setup_connection(via_mplane)
            ru_name, ru_ip, smod_name, smod_ip = self._open_connection_to_radio_module(ru_serial_number,
                                                                                       remote_host, **kwargs)
        else:
            self._setup_cloud_connection()
            ru_name, ru_ip = self._cloud_open_connection_to_radio_module(ru_serial_number, cloud_server_ip)

        self._setup_radio(ru_name, ru_ip, ru_serial_number, remote_host)

        ru_family = self.get_radio_module_hardware_family(ru_name)
        if float(ru_family) < 5.1:
            raise Exception(f"Radio family {ru_family} is not supported for PSU measurements")

        sensors_temperature = self._get_sensors_temperature_from_rf_logs()
        self.disconnect()

        return sensors_temperature

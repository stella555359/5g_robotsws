from robot.libraries.BuiltIn import BuiltIn
from robot.errors import DataError
import robot.api.logger as logging


class UEConfig:
    def __init__(self):
        self._from = ""
        self._capabilities = []
        self._cpc_ip = ""
        self._cpc_username = ""
        self._cpc_password = ""
        self._serial_number = ""
        self._iperf_address = ""
        self._iperf_user = ""
        self._iperf_password = ""
        self._iperf_port = ""
        self._qci = None
        self._ue_type = ""
        self._ui_version = ""
        self._ue_alias = ""
        self._data_transfer = {}
        self._ue_proxy_used = False
        self._com_id = ""

    @property
    def capabilities(self):
        return self._capabilities

    @property
    def cpc_ip(self):
        return self._cpc_ip

    @property
    def cpc_username(self):
        return self._cpc_username

    @property
    def cpc_password(self):
        return self._cpc_password

    @property
    def serial_number(self):
        return self._serial_number

    @property
    def iperf_address(self):
        return self._iperf_address

    @property
    def iperf_user(self):
        return self._iperf_user

    @property
    def iperf_password(self):
        return self._iperf_password

    @property
    def iperf_port(self):
        return self._iperf_port

    @property
    def qci(self):
        return self._qci

    @property
    def ue_type(self):
        return self._ue_type

    @property
    def ui_version(self):
        return self._ui_version

    @property
    def ue_alias(self):
        return self._ue_alias

    @property
    def data_transfer(self):
        return self._data_transfer

    @property
    def ue_proxy_used(self):
        return self._ue_proxy_used

    @property
    def com_id(self):
        return self._com_id

    def parse_yaml(self, ue_type, ue, ue_index):
        self._from = "yaml"
        self._ue_type = ue_type.capitalize()
        self._ue_alias = f"ue_type_{ue_index}"
        self._capabilities = ue['capabilities']
        self._class = ue['class']
        params = ue['constructor_parameters']
        self._serial_number = params['serial_number']
        config = params['configuration']
        self._com_id = config['serial_com']
        self._cpc_ip = config['ue_pc_ip']
        self._cpc_username = config['login']
        self._cpc_password = config['password']
        self._data_transfer = config['data_transfer']
        qci = self._data_transfer['iperf_options'].get('qci', {})
        self._qci = 5 in qci or 6 in qci
        self._ue_proxy_used = "ssh" not in self._data_transfer

        if not self._ue_proxy_used:
            self._iperf_address = self._data_transfer["ssh"]["host"]
            self._iperf_user = self._data_transfer["ssh"]["user"]
            self._iperf_password = self._data_transfer["ssh"]["password"]
            self._iperf_port = self._data_transfer["ssh"].get("port", '5000')

    def parse_obj(self, ue_info, ue_index):
        logging.debug(msg=f'parse_obj starts...')
        self._from = "py"
        logging.debug(msg=f'from: {self._from}')
        self._capabilities = ue_info.capabilities
        logging.debug(msg=f'capabilities: {self._capabilities}')
        self._ue_type = self._capabilities[0].capitalize()
        logging.debug(msg=f'ue_type: {self._ue_type}')
        self._ue_alias = f"{self._capabilities[1]}_{ue_index}"
        logging.debug(msg=f'ue_alias: {self._ue_alias}')
        self._ui_version = self._ue_alias.rsplit('_', 1)[0]
        logging.debug(msg=f'ui_version: {self._ui_version}')
        self._serial_number = ue_info.serial_number
        logging.debug(msg=f'serial_number: {self._serial_number}')
        self._cpc_ip = ue_info.ssh_connection_details.addr
        logging.debug(msg=f'cpc_ip: {self._cpc_ip}')
        self._cpc_username = ue_info.ssh_connection_details.username
        logging.debug(msg=f'cpc_username: {self._cpc_username}')
        self._cpc_password = ue_info.ssh_connection_details.password
        logging.debug(msg=f'cpc_password: {self._cpc_password}')
        self._ue_proxy_used = hasattr(ue_info, 'data_transfer')
        logging.debug(msg=f'ue_proxy_used: {self._ue_proxy_used}')

        if self._ue_proxy_used:
            logging.debug(msg=f'ue_proxy_used is True...')
            self._iperf_address = ue_info.data_transfer[ue_index].app_server.address
            logging.debug(msg=f'iperf_address: {self._iperf_address}')
            self._iperf_user = ue_info.data_transfer[ue_index].app_server.user
            logging.debug(msg=f'iperf_user: {self._iperf_user}')
            self._iperf_password = ue_info.data_transfer[ue_index].app_server.password
            logging.debug(msg=f'iperf_password: {self._iperf_password}')
            self._iperf_port = ue_info.data_transfer[ue_index].app_server.ports or "5000"
            logging.debug(msg=f'iperf_port: {self._iperf_port}')
        else:
            logging.debug(msg=f'ue_proxy_used is False...')
            self._iperf_address = ue_info.iperf_details.ssh_connection_details.addr
            logging.debug(msg=f'iperf_address: {self._iperf_address}')
            self._iperf_user = ue_info.iperf_details.ssh_connection_details.username
            logging.debug(msg=f'iperf_user: {self._iperf_user}')
            self._iperf_password = ue_info.iperf_details.ssh_connection_details.password
            logging.debug(msg=f'iperf_password: {self._iperf_password}')
            self._iperf_port = ue_info.iperf_details.port or "5000"
            logging.debug(msg=f'iperf_port: {self._iperf_port}')

    def __repr__(self):
        return f"<UE CONFIG>: {self.__str__()}>"

    def __str__(self):
        data = {"ue_type": self._ue_type,
                "from": self._from,
                "ue_alias": self._ue_alias,
                "ui_version": self._ui_version,
                "capabilities": self._capabilities,
                "cpc_ip": self._cpc_ip,
                "cpc_username": self._cpc_username,
                "cpc_password": self._cpc_password,
                "serial_number": self._serial_number,
                "iperf_address": self._iperf_address,
                "iperf_user": self._iperf_user,
                "iperf_password": self._iperf_password,
                "iperf_port": self._iperf_port,
                "qci": self._qci,
                "data_transfer": self._data_transfer,
                "ue_proxy_used": self._ue_proxy_used,
                "com_id": self._com_id
                }

        return str(data)


def parse_ue_config(index):
    ue_index = int(index)
    built_in = BuiltIn()
    tl = built_in.get_variable_value("${tl}")

    if tl is None:
        raise DataError('Error: Testline configuration not loaded. Check if variable file was provided to robot.')

    if len(tl.ues) == 0:
        raise DataError('Error: Empty UE list. Check your testline configuration.')

    ue = UEConfig()
    logging.debug(msg=f'Start to parse ue config...')
    logging.debug(msg=f'isinstance: {isinstance(tl.ues[0], dict)}')
    if isinstance(tl.ues[0], dict):
        for uepool in tl.ues[0].values():
            for subpool in uepool.values():
                for inline_config in subpool.values():
                    index = 0
                    for ue_type, config in inline_config.items():
                        if index == ue_index:
                            new_config = dict()
                            for k, v in config.items():
                                new_config[k.lower()] = v
                            ue.parse_yaml(ue_type, new_config, ue_index)
                            return ue
                        index += 1
                    raise DataError(f'invalid ue index: {ue_index}, out of inline_config range. \
Check your UE config yaml.')
    else:
        logging.debug(msg=f'Since isinstance is False, so parse_obj will be called.')
        ue.parse_obj(tl.ues[int(ue_index)], ue_index)
        logging.debug(msg=f'parse_obj completed.')
        logging.debug(msg=f'ue: {ue}')
        return ue


def calculate_average_throughput(tput):
    res = []
    for col in zip(*tput):
        i = [int(x) for x in col]
        res.append(sum(i)/len(i)/1024/1024)

    return res


def calculate_peak_throughput(tput):
    res = []
    for col in zip(*tput):
        i = [int(x) for x in col]
        res.append(max(i)/1024/1024)

    return res


def get_screen_coordinates(ue):
    data = {
                "samsung": {
                    "airplane": "970 365",
                    "close_task": "535 1755",
                    "swipe": "500 2050 500 800",
                    "open_iperf_location": "480 860",
                    "iperf_button": "900 380",
                    },
                "samsung10": {
                    "airplane": "970 380",
                    "close_task": "721 2345",
                    "swipe": "500 2050 500 800",
                    "open_iperf_location": "480 860",
                    "iperf_button": "1133 417"
                },
                "samsung21": {
                    "airplane": "930 362",
                    "close_task": "548 1875",
                    "swipe": "500 2050 500 800",
                    "open_iperf_location": "480 860",
                    "iperf_button": "928 393",
                    "call": "540 1940",
                    "end_call": "540 1940",
                },
                "samsung23": {
                    "airplane": "930 362",
                    "close_task": "548 1875",
                    "swipe": "500 2050 500 800",
                    "open_iperf_location": "480 860",
                    "iperf_button": "928 393",
                    "call": "540 1940",
                    "end_call": "540 1940",
                },
                "huawei": {
                    "airplane": "960 290",
                    "close_task": "538 1979",
                    "swipe": "500 2050 500 800",
                    "open_iperf_location": "500 2050",
                    "iperf_button": "708 308",
                    "end_call": "580 1960"
                },
                "huawei_mate30": {
                    "airplane": "1024 310",
                    "close_task": "586 2140",
                    "swipe": "586 2050 586 800",
                    "iperf_button": "1033 527"
                },
                "huawei_mate40": {
                    "airplane": "1000 380",
                    "close_task": "562 2169",
                    "swipe": "500 2050 500 800",
                    "iperf_button": "708 308",
                    "call": "580 2060",
                    "end_call": "580 1980"
                },
                "xiaomi": {
                    "airplane": "908 1482",
                    "close_task": "535 2165",
                    "swipe": "500 800 500 800",
                    "iperf_button": "730 300"
                },
                "xiaomi12": {
                    "airplane": "550 1647",
                    "close_task": "535 2165",
                    "swipe": "500 800 500 800",
                    "iperf_button": "730 300"
                },
                "oppo": {
                    "airplane": "930 357",
                    "close_task": "540 2156",
                    "swipe": "540 2130 540 1295",
                    "iperf_button": "708 308"
                },
                "MTP845": {
                    "airplane": "1300 1700",
                    "close_task": "700 2000",
                    "swipe": "750 1500 750 1500",
                    "swipe_notification": "600 15 600 2000",
                    "switch": "165 388",
                    "iperf_button": "1255 362"
                    },
                "Qualcomm8350": {
                    "airplane": "800 1400",
                    "close_task": "500 1200",
                    "swipe": "500 1400 500 400",
                    "iperf_button": "820 300"
                },
            }

    if ue.ui_version not in data:
        raise DataError(f"ui version: {ue.ui_version} not found. Please refer the document \
(https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/03.+Module+of+Traffic+UE+Operation) \
to register a new one.")

    return data[ue.ui_version]

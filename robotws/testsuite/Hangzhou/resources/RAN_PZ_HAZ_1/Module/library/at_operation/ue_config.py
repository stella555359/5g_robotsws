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

    def set_com_id(self, value):
        self._com_id = value

    def parse_yaml(self, ue_type, ue, ue_index):
        self._from = "yaml"
        self._ue_type = ue_type.capitalize()
        self._ue_alias = f"ue_type_{ue_index}"
        self._capabilities = ue['CAPABILITIES']
        self._class = ue['CLASS']
        params = ue['CONSTRUCTOR_PARAMETERS']
        self._com_id = params['com_port']
        self._serial_number = params['serial_number']
        config = params['configuration']

        self._cpc_ip = config['ue_pc_address']
        self._cpc_username = config['ue_pc_login']
        self._cpc_password = config['ue_pc_password']
        self._data_transfer = config['data_transfer']
        qci = self._data_transfer['iperf'].get('qci', {})
        self._qci = 5 in qci or 6 in qci
        self._iperf_address = self._data_transfer["iperf"]["app_server"]["address"]
        self._iperf_user = self._data_transfer["iperf"]["app_server"]["user"]
        self._iperf_password = self._data_transfer["iperf"]["app_server"]["password"]
        self._iperf_port = self._data_transfer["iperf"]["app_server"].get("port", '5000')

    def parse_obj(self, ue_info, ue_index):
        logging.debug(msg=f'parse_obj starts...')
        self._from = "py"
        logging.debug(msg=f'from: {self._from}')
        self._capabilities = ue_info.capabilities
        logging.debug(msg=f'capabilities: {self._capabilities}')
        self._ue_type = self._capabilities[0].capitalize()
        self._com_id = ue_info.serial_com
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
        logging.debug(msg=f'ue_proxy_used is True...')
        if hasattr(ue_info, 'data_transfer'):
            self._iperf_address = ue_info.data_transfer[ue_index].app_server.address
            logging.debug(msg=f'iperf_address: {self._iperf_address}')
            self._iperf_user = ue_info.data_transfer[ue_index].app_server.user
            logging.debug(msg=f'iperf_user: {self._iperf_user}')
            self._iperf_password = ue_info.data_transfer[ue_index].app_server.password
            logging.debug(msg=f'iperf_password: {self._iperf_password}')
            self._iperf_port = ue_info.data_transfer[ue_index].app_server.ports or "5000"
            logging.debug(msg=f'iperf_port: {self._iperf_port}')
        else:
            self._iperf_address = ue_info.iperf_details.ssh_connection_details.addr
            self._iperf_user = ue_info.iperf_details.ssh_connection_details.username
            self._iperf_password = ue_info.iperf_details.ssh_connection_details.password
            self._iperf_port = ue_info.iperf_details.port
            self._data_transfer["iperf"] = {"app_server": {"address": self._iperf_address,
                                                           "user": self._iperf_user,
                                                           "password": self._iperf_password,
                                                           "port": self._iperf_port}}

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
        logging.debug(msg=f'tl.ues[ue_index]: {tl.ues[0]}')
        for uepool in tl.ues[0]["UE_POOLS"].values():
            logging.debug(f'subpool: {uepool.values()}')
            for inline_config in uepool.values():
                index = 0
                for ue_type, config in inline_config.items():
                    logging.debug(f'ue_type: {ue_type} config: {config}')
                    if index == ue_index:
                        ue.parse_yaml(ue_type, config, ue_index)
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

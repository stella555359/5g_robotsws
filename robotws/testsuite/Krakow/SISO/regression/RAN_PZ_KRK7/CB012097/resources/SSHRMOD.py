from pprint import pformat
import re
import time
import json
from robot.libraries.BuiltIn import BuiltIn, logger
from SSHLibrary import SSHLibrary
from helpers_12097 import f_log


def crop_line(data: str, line: int = 0):
    logger.trace(f"{f_log()}{data=}", html=True)
    out = data.split('\r\r\n')[line]
    logger.trace(f"{f_log()}{out=}", html=True)
    return out


def create_rmod_list(rmod_definition: str):
    rmod_info_mapping = ["dist_name", "id", "ip_addr", "sn", "rmod_type"]
    rmods = rmod_definition.split('\n')
    rmod_list = []
    logger.debug(f"{f_log()}{rmods=}", html=True)
    for rmod in rmods:
        rmod_dict = {}
        logger.debug(f"{f_log()}{rmod.split(';')=}", html=True)
        for i, cell in enumerate(rmod.split(";")):
            rmod_dict.update({rmod_info_mapping[i]: cell})
        if rmod:
            rmod_list.append(rmod_dict)
    return rmod_list


def _is_comment(input_str: str):
    return input_str.startswith('#')


def _is_rad_param(input_str: str):
    return input_str.startswith('0x')


def _remove_trailing_crlf(input_str: str):
    out = re.sub(pattern=r'[\n\r]+$', repl='', string=input_str)
    logger.debug(f"{f_log()}trimmed {out=}", html=True)
    return out


def _fix_weird_crcrlf(input_str: str):
    logger.trace(f"{f_log()}fix {input_str=}", html=True)
    out = re.sub(pattern=r'\r\r\n', repl=r'\n', string=input_str)
    logger.trace(f"{f_log()}fixed {out=}", html=True)
    return out


def _remove_line_content(input_str: str, line: str):
    return re.sub(pattern=line, repl='', string=input_str)


def _remove_rad_param(input_str: str, rad_param: str):
    line = re.sub(pattern=r'(0x\w+).+', repl=r'\1', string=rad_param)
    return re.sub(pattern=line + r'.+', repl='', string=input_str)


def _edit_rad_param(swconfig: str, rad_param: str, value: str):
    pattern = fr'({rad_param}).+'
    repl = fr'\1 = {value}'
    logger.debug(f'{f_log()}{pattern=}, {repl=}', html=True)
    swconfig = re.sub(pattern, repl, string=swconfig)
    return swconfig


def _json_to_dict(json_in: str):
    logger.trace(f'{f_log()}json_in=\n{json_in}', html=True)
    dict_out = json.loads(json_in)
    return dict_out


def _dict_to_json(dict_in: dict):
    json_out = json.dumps(dict_in, indent=2)
    logger.trace(f'{f_log()}json_out=\n{json_out}', html=True)
    return json_out


def _edit_json(key, value, json_in, key_path=[]):
    # key_path: path of keys in nested dict/json, eg. 'tcs', ['tcs'], '', [], ['tcs', 'tcsAlgorithm']
    dic = _json_to_dict(json_in)
    if key_path == '':
        key_path = []
    if not isinstance(key_path, list):
        key_path = [key_path]
    key_path.append(key)
    logger.trace(f'{f_log()}{key_path=}', html=True)
    curr = dic
    for idx, k in enumerate(key_path):
        if idx == len(key_path) - 1:
            logger.trace(f'{f_log()}{k=}', html=True)
            curr[k] = value
        else:
            logger.trace(f'{f_log()}{k=}', html=True)
            curr = curr[k]
    json_out = _dict_to_json(dic)
    return json_out


class SSHRMOD(SSHLibrary):
    container_name = None
    conn_level_map = None

    def __init__(self, conn_level_map, host=None, username=None, password=None, loglevel='TRACE', **kwargs):
        self.conn_level_map = conn_level_map
        self.host = host
        self.username = username
        self.password = password
        super().__init__(loglevel=loglevel, **kwargs)
        self.connection_level = 'smod'

    def open_host_connection(self, host=None, username=None, password=None):
        logger.debug(f"{f_log()}{self.conn_level_map=}", html=True)
        self.host = host or self.host
        self.username = username or self.username
        self.password = password or self.password
        self.open_connection(host=self.host)
        self.login(username=self.username, password=self.password)

    def get_rmod_ip(self, rmod_type: str, rmod_sn: str = None):
        ip_addr = None
        cmd = "cat /rom/config/FRIps.txt"
        rmod_definition = self.execute_command(cmd)
        rmod_list = create_rmod_list(rmod_definition)
        for rmod in rmod_list:
            if rmod.get("rmod_type") == rmod_type:
                if rmod_sn and rmod.get("sn") == rmod_sn:
                    ip_addr = rmod.get("ip_addr")
                    break
                elif not rmod_sn:
                    ip_addr = rmod.get("ip_addr")
                    break
        logger.debug(f"{f_log()}{rmod_list=}", html=True)
        return ip_addr

    def set_client_prompt(self, level=None):
        if not level:
            level = self.connection_level
        self.set_client_configuration(prompt=self.conn_level_map[level]['prompt'])

    def set_client_timeout(self, timeout=None):
        if not timeout:
            timeout = self.DEFAULT_TIMEOUT
        self.set_client_configuration(timeout=timeout)

    def set_container(self, container_name):
        self.container_name = container_name
        self.conn_level_map['lxc']['enter_cmd'] = str(self.conn_level_map['lxc']['enter_cmd']).format(container_name)

    def attach_to_container(self, container_name='0x1018'):
        self.set_container(container_name)
        prev_level = 'smod'
        next_level = 'lxc'
        logger.trace(f_log() + self.execute_command("hostname"), html=True)
        cmd = self.conn_level_map[next_level]['enter_cmd']
        logger.trace(f"{f_log()}{cmd=}", html=True)
        self.write(cmd)
        time.sleep(1)
        self.write("hostname")
        resp = crop_line(self.read(delay=1))
        logger.debug(f"{f_log()}Hostname: {resp=}", html=True)
        if resp != self.conn_level_map[next_level]['hostname']:
            self.connection_level = prev_level
            raise ConnectionError(f"{f_log(2)}Cannot connect to container {self.container_name}," +
                                  f" Hostname: {resp}, but should be: {self.conn_level_map[next_level]['hostname']}")
        logger.info(f"Attached to container {self.container_name}", also_console=True)
        self.connection_level = next_level
        self.set_client_prompt()

    def _verify_proper_rmod(self, rmod_type):
        rmod_hostname = self.conn_level_map[rmod_type]['hostname']
        flush_buffer = self.read(delay=0.5)
        logger.trace(f'{f_log()}{flush_buffer=}', html=True)
        self.write("hostname")
        resp = crop_line(self.read(delay=0.5))
        logger.trace(f'{f_log(2)}{resp=}', html=True)
        if resp != rmod_hostname:
            for level, conn_params in self.conn_level_map.items():
                if resp == conn_params.get('hostname'):
                    self.connection_level = level
                    logger.debug(f"{f_log(2)}Changed {self.connection_level=}", html=True)
            raise ConnectionError(f"{f_log(2)}Not logged to rmod {rmod_type} (expected hostname: {rmod_hostname}" +
                                  f", got: {resp}), aborting...")

    def _verify_current_conn_level(self, required_level):
        if self.connection_level != required_level:
            raise ValueError(f"{f_log(2)}Current connection level: {self.connection_level}" +
                             f" is different than required: {required_level}, aborting...")

    def _sync_conn_level(self):
        self.write("hostname")
        resp = crop_line(self.read(delay=1))
        for level, conn_params in self.conn_level_map.items():
            if resp == conn_params.get('hostname'):
                self.connection_level = level
                logger.debug(f"{f_log()}Changed {self.connection_level=}", html=True)

    def wait_for_ip_connectivity(self, ip_addr, timeout: int = 300, require_disconnect=False):
        cmd = f'ping {ip_addr} -qc 1 > /dev/null ; echo $?'
        start_time = time.time()
        self.set_client_prompt()
        self.set_client_timeout(15)
        while time.time() - start_time < timeout:
            self.write(cmd)
            out = self.read_until_prompt(strip_prompt=True).rstrip('\r\n')
            if out == '0' and require_disconnect:
                logger.info(f'Waiting for {ip_addr} disconnection...', also_console=True)
            elif out == '1' and require_disconnect:
                require_disconnect = False
                logger.info(f'{ip_addr} disconnected. Waiting for reconnection...', also_console=True)
            elif out == '0' and not require_disconnect:
                logger.info(f'Connection to {ip_addr} possible, ' +
                            f'took {(time.time() - start_time):.1f} sec, continue execution...', also_console=True)
                self.set_client_timeout()
                return
            logger.info(f'Connection to {ip_addr} not possible, waiting... {out=}', also_console=False)
            time.sleep(10)
        self.set_client_timeout()
        raise TimeoutError(
            f'{f_log(2)}ip connectivity with {ip_addr} timeout. Took {(time.time() - start_time):.1f} sec')

    def login_to_rmod(self, ip_addr: str, rmod_type: str):
        next_level = rmod_type
        password = self.conn_level_map[next_level]['password']
        try:
            cmd = str(self.conn_level_map[rmod_type]['enter_cmd']).format(ip_addr)
        except KeyError as ex:
            raise NotImplementedError(f"{f_log(2)}Unknown RMOD/ASIRHUB type, fix rmod mapping. Original exception:" +
                                      f"\n{repr(ex)}")
        resp = ""
        self.write("hostname")
        resp = crop_line(self.read(delay=1))
        if resp != self.conn_level_map['lxc']['hostname']:
            raise ConnectionError(f"{f_log(2)}Not attached to container FHNET00, aborting...")
        self.write(cmd)
        resp = self.read(delay=1)
        logger.debug(f"{f_log()}{resp=}", html=True)
        if f"The authenticity of host '{ip_addr} ({ip_addr})' can't be established." in resp:
            self.write("yes")
            resp = self.read(delay=1)
            logger.debug(f"{f_log()}{resp=}", html=True)
        if not password:
            logger.info(f"{f_log()}Logging into {rmod_type} {ip_addr} without password...", html=True)
            self.write('hostname')
        elif "Password:" in resp:
            logger.info(f"{f_log()}Logging into {rmod_type} {ip_addr} with pass: {password}", html=True)
            self.write(password)
        else:
            raise Exception(f"{f_log(2)}Expected password prompt, got {resp}")
        try:
            self.read_until(expected=self.conn_level_map[next_level]['prompt'])
        except RuntimeError as ex:
            logger.error(f_log() + repr(ex), html=True)
            self._verify_proper_rmod(rmod_type)
        self.connection_level = next_level
        self.set_client_prompt()
        logger.info(f"Logged into {rmod_type} with address {ip_addr}", also_console=True)

    def logout_from_rmod(self, rmod_type: str = ''):
        next_level = 'lxc'
        cmd = 'exit'
        self._sync_conn_level()
        if self.connection_level == next_level:
            logger.info(f"No need to logout from RMOD {rmod_type}, already on Container.", also_console=True)
        else:
            if rmod_type:
                self._verify_current_conn_level(rmod_type)
            self.write(cmd)
            out = self.read_until(expected=self.conn_level_map[next_level]['prompt'])
            logger.debug(f"{f_log()}Command {cmd=} sent,\n{out=}", html=True)
            self._sync_conn_level()
            self._verify_current_conn_level(next_level)
            logger.info(f"Logout from RMOD {rmod_type} successful.", also_console=True)

    def show_rmod_swconfig(self):
        self.write("cat /rom/swconfig.txt")
        resp = self.read_until(expected="\n" + self.conn_level_map[self.connection_level]['prompt'])
        logger.info(fr"read_until /rom/swconfig.txt:\n{resp}", also_console=True)
        self.write("cat /rom/swconfig.txt")
        resp = self.read_until_prompt(strip_prompt=True)
        logger.info(fr"read_until_prompt /rom/swconfig.txt:\n{resp}", also_console=True)

    def get_rmod_file_content(self, filename: str):
        self.write('cat ' + filename)
        content = _fix_weird_crcrlf(self.read_until_prompt(strip_prompt=True))
        logger.debug(f"{f_log(2)}{filename}:\n{content}", html=True)
        return content

    def write_to_rmod_file(self, content: str, filename: str):
        cmd = "echo '{content}' > {filename}".format(content=content, filename=filename)
        self.write(cmd)
        out = self.read_until_prompt(strip_prompt=False)
        logger.debug(f"{f_log(2)}{cmd=}\n{out=}", html=True)

    def get_rmod_swconfig(self, filename="/rom/swconfig.txt"):
        self.write('touch ' + filename)                                         # ensure swconfig exists on RMOD
        time.sleep(0.5)
        return self.get_rmod_file_content(filename)

    def write_rmod_swconfig(self, swconfig, filename="/rom/swconfig.txt"):
        self.write_to_rmod_file(swconfig, filename)

    def reset_rmod_swconfig(self, swconfig_flags: str, rmod_type: str):
        logger.debug(f"{f_log()}{swconfig_flags=}", html=True)
        self._verify_proper_rmod(rmod_type)
        swconfig = self.get_rmod_swconfig()
        logger.debug(f"{f_log()}{swconfig=}", html=True)
        for line in swconfig_flags.splitlines():
            if line != '':
                if _is_comment(line):
                    swconfig = _remove_line_content(swconfig, line)
                elif _is_rad_param(line):
                    swconfig = _remove_rad_param(swconfig, line)
        logger.debug(f"{f_log()}cleaned {swconfig=}", html=True)
        swconfig = _remove_trailing_crlf(swconfig)
        swconfig += ('\n' + swconfig_flags)
        logger.info(f"{f_log()}New {swconfig=}", also_console=False, html=True)
        self.write_rmod_swconfig(swconfig)

    def edit_rmod_rad_params(self, rad_params: list[str], value: str, rmod_type: str):
        self._verify_proper_rmod(rmod_type)
        swconfig = _remove_trailing_crlf(self.get_rmod_swconfig()) + '\n'
        if not isinstance(rad_params, list):
            rad_params = [rad_params]
        for rad_param in rad_params:
            swconfig = _edit_rad_param(swconfig, rad_param, value)
        logger.info(f"{f_log()}Edited {swconfig=}", also_console=False, html=True)
        self.write_rmod_swconfig(swconfig)

    def edit_rmod_json(self, diff: dict, rmod_type: str, filename='/run/tcs.json', key_path='tcs'):
        self._verify_proper_rmod(rmod_type)
        _json = self.get_rmod_file_content(filename)
        for key, value in diff.items():
            _json = _edit_json(key, value, _json, key_path)
        logger.info(f"{f_log()}Edited _json=\n{_json}", also_console=False, html=True)
        self.write_to_rmod_file(_json, filename)

    def reboot_rmod(self, ip_addr: str, rmod_type: str, wait_until_online=False):
        # Actually does reboot and logout from rmod
        cmd = 'reboot; exit'
        self._verify_proper_rmod(rmod_type)
        self.set_client_prompt('lxc')
        self.write(cmd)
        out = self.read_until_prompt(strip_prompt=False)
        logger.info("RMOD rebooted", also_console=True)
        logger.trace(f"{f_log()}{out=}")
        self._sync_conn_level()
        self._verify_current_conn_level('lxc')
        if wait_until_online:
            self.wait_for_ip_connectivity(ip_addr, timeout=240, require_disconnect=True)
            time.sleep(10)

    def run_command_on_rmod(self, cmd: str, rmod_type: str):
        self._verify_proper_rmod(rmod_type)
        self.write(cmd)
        out = self.read_until_prompt(strip_prompt=False)
        logger.debug(f"{f_log(2)}Command {cmd=} sent,\n{out=}", html=True)
        time.sleep(1)

    def run_frmon_command(self, cmd: str, rmod_type: str):
        cmd = f"echo '{cmd}' > /ram/frmon_tmp.sh"
        cmd_exec = 'frmonShellClient 127.0.0.1 2000 /ram/frmon_tmp.sh'
        self.run_command_on_rmod(cmd, rmod_type)
        time.sleep(2)
        self.run_command_on_rmod(cmd_exec, rmod_type)
        time.sleep(1)

# ----------------------------------------------------------------------------------------------------------------------


def create_object(host=None, username=None, password=None, loglevel='TRACE', **kwargs):
    return SSHRMOD(host=host, username=username, password=password, loglevel=loglevel, **kwargs)

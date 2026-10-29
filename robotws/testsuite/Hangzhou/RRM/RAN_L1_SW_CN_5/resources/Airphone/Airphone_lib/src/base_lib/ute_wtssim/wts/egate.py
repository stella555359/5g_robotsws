# -*- coding: utf-8 -*-

import collections
import re
import logging

from .common import WtsSimCommon
from ..client.telnetclient import TelnetClient
from ..exception import ProcessCannotStart, NoRegexpMatch, InvalidTelnetClient, PortIsReserved, WtsSimException
from ute_common_converter.to_bool import to_bool


class Egate(WtsSimCommon):
    def __init__(self, ssh_client, telnet, port, *args, **kwargs):
        super(Egate, self).__init__(*args, **kwargs)
        self.lua_dirs = []
        self._client = ssh_client
        self._telnet = telnet
        self._port = port
        self._edaemons = []
        self._log = logging.getLogger(__name__)

        self._check_client()
        self._check_telnet()

    @property
    def client(self):
        return self._client

    @property
    def is_running(self):
        self._pid = self._client.execute_command("pgrep -f \"./egate --port {}\"".format(self._port))
        return True if self._pid[0] else False

    def add_edaemon(self, edaemon):
        self._edaemons.append(edaemon)

    def setup(self, reconnect=False):
        self._started = True
        if reconnect:
            self._remove_old_logs()
            self.reset()
        else:
            self._kill_egate()
            self._remove_old_logs()
            self._setup_edaemons()
            self._start_egate()

    def configure_egate(self, cfg_file=None, suite_file=None, timeout=None, retry=0):
        timeout = 60 if timeout is None else timeout
        for count in range(retry + 1):
            try:
                if cfg_file is not None:
                    cmd = "cfg file={}".format(cfg_file)
                    self._log.debug(self.execute_telnet_command(cmd, pass_regexp="CHANGE STATE: CONFIGURED",
                                                                timeout=timeout))
                elif suite_file is not None:
                    cmd = "cfg suite={}".format(suite_file)
                    self._log.debug(self.execute_telnet_command(cmd, pass_regexp="CHANGE STATE: CONFIGURED",
                                                                timeout=timeout))
                return
            except WtsSimException as e:
                self._log.debug(str(e))
        else:
            raise ProcessCannotStart('Cannot process egate after {} attempt[s]'.format(count + 1))

    def start_services(self, timeout=None, check_version=True):
        start_command = "start version_check={}".format("on" if check_version else "off")
        timeout = 180 if timeout is None else timeout
        self._log.debug(self.execute_telnet_command(start_command, pass_regexp='CHANGE STATE: ACTIVE',
                                                    timeout=timeout))

    def retry_services(self, timeout=None, retry=None, check_version=True):
        timeout = 180 if timeout is None else timeout
        retry = 2 if retry is 1 else retry
        for _ in range(retry):
            try:
                self._log.info(self.start_services(timeout=timeout, check_version=check_version))
                if self.check_enb_state('ACTIVE'):
                    break
            except NoRegexpMatch as e:
                self._log.info(str(e))
        else:
            raise ProcessCannotStart("Cannot start Egate Services after {} attempt[s]".format(retry))

    def check_enb_state(self, state):
        enb_state = self.execute_telnet_command(cmd='state', pass_regexp='EGATE>', timeout=None,
                                                ignore_prompt_prefix=True)
        status = re.search(state, enb_state, re.M | re.I)
        return True if status else False

    def execute_telnet_command(self, cmd, pass_regexp_L, fail_regexp_L, timeout=None, ignore_prompt_prefix=None,
                               return_output=True, **kwargs):
        timeout = 10 if timeout is None else timeout
        self._open_telnet_connection()
        self._send_telnet_command(cmd)
        p_res, out, p_d_res = self._read_telnet_response(pass_regexp_L, fail_regexp_L, timeout, ignore_prompt_prefix,
                                                         **kwargs)
        out += self._telnet.read()
        self._close_telnet_connection()
        print("[Execute Egate Command] Cmd is '%s'; pass_regexp_L is '%s'; fail_regexp_L is %s; "
              "Check detail result is %s " % (cmd, pass_regexp_L, fail_regexp_L, p_d_res))
        return out if to_bool(return_output) else p_d_res

    def reset(self, timeout=None):
        timeout = 30 if timeout is None else timeout
        self._log.debug(self.execute_telnet_command("reset"))
        self._log.debug(self.execute_telnet_command("state", pass_regexp='The state is INIT', timeout=timeout))

    def teardown(self):
        self._started = False
        self._shutdown_egate()
        self._kill_egate()
        self._teardown_edaemons()

    def _open_telnet_connection(self):
        self._log.debug("WTSSIM opens connection: {}:{}".format(self._telnet.host, self._telnet.port))
        self._telnet.open_connection()

    def _close_telnet_connection(self):
        self._log.debug("WTSSIM closes connection: {}:{}".format(self._telnet.host, self._telnet.port))
        self._telnet.close_connection()

    def _send_telnet_command(self, cmd):
        self._log.info("WTSSIM executes telnet cmd: {}".format(cmd))
        self._telnet.write_bare("{}\r\n".format(cmd))

    def _read_telnet_response(self, pass_regexp_L, fail_regexp_L, timeout, ignore_prefix, **kwargs):
        if len(pass_regexp_L) == 0 and len(fail_regexp_L) == 0:
            return None, self._telnet.read(), None

        p_res, out, p_d_res = self._telnet.read_until_regexp(pass_regexp_L, ignore_prefix, timeout, **kwargs)

        if len(pass_regexp_L) > 0 and p_res is False:
            raise NoRegexpMatch("It was not possible to find all string after {} secs to match "
                                "all regexp ({}) in output\n({}), detail failed regexp is "
                                "{}".format(timeout, pass_regexp_L, out, p_d_res))

        if len(fail_regexp_L) > 0:
            res = collections.OrderedDict()
            fail_res = []
            for fail_regexp in fail_regexp_L:
                res[fail_regexp] = False
                if re.search(fail_regexp, out):
                    res[fail_regexp] = True
                    fail_res.append(fail_regexp)

            if len(fail_res) > 0:
                raise NoRegexpMatch("Fail regexp found ({}) in output\n({})".format(fail_res, out))

        return p_res, out, p_d_res

    def _prepare_searching_regexp(self, pass_regexp, fail_regexp):
        if pass_regexp is not None and fail_regexp is not None:
            return "{}|{}".format(pass_regexp, fail_regexp)
        elif pass_regexp is not None and fail_regexp is None:
            return pass_regexp
        elif pass_regexp is None and fail_regexp is not None:
            return fail_regexp

    def _extend_lua_path(self):
        lua_dirs_string = self._convert_lua_path_to_string()
        cmd = "echo $LUA_PATH; export LUA_PATH='{}{}/?.lua;'; ".format(lua_dirs_string, self._tool_dir)
        return cmd

    def _convert_lua_path_to_string(self):
        if self._is_number_of_lua_dirs_entries(0):
            return ""
        elif self._is_number_of_lua_dirs_entries(1):
            return "{}/?.lua;".format(self.lua_dirs[0])
        else:
            return '/?.lua;'.join(self.lua_dirs) + '/?.lua;'

    def _is_number_of_lua_dirs_entries(self, number):
        if len(self.lua_dirs) == number:
            return True
        return False

    def _kill_egate(self):
        if self._pid is not None:
            self._kill_process()
        else:
            self._kill_unknown_egate()
        self._pid = None

    def _kill_unknown_egate(self):
        self._kill_process(process_cmd=r'egate\s*--port\s*{}'.format(self._port))

    def _remove_old_logs(self):
        self._client.execute_command("cd {}; sudo rm -rf egate*.log.*; sudo rm -rf error*log".format(self._tool_dir))

    def _setup_edaemons(self):
        for each in self._edaemons:
            each.setup()

    def _start_egate(self):
        if not self._is_tcp_port_free(self._port):
            raise PortIsReserved("Egate", self._port)
        cmd = self._extend_lua_path()
        if not self._pid:
            cmd += "cd {}; ./egate --port {}".format(self._tool_dir, self._port)
            out, err, rc = self._client.execute_command(cmd)
            self._pid = self._get_egate_pid(out, err)

    def _get_egate_pid(self, out, err):
        found = re.search(r"EGATE:\s*SERVER\s*PID\s*=\s*(.*)", out)
        if not found:
            raise ProcessCannotStart("Cannot start the egate process and shell output is:", out, err)
        return found.groups()[0].strip()

    def _teardown_edaemons(self):
        for each in self._edaemons:
            each.teardown()

    def _shutdown_egate(self):
        try:
            self.execute_telnet_command("reset")
            self.execute_telnet_command("shutdown")
        except TelnetClient.SOCKET_CONN_ERROR as e:
            self._log.debug(e)
        except EOFError as e:
            self._log.debug(e)

    def _check_telnet(self):
        if not (hasattr(self._telnet, 'open_connection') or hasattr(self._telnet, 'close_connection')):
            raise InvalidTelnetClient("Provided telnet must have a 'open_connection' and 'close_connection' method")

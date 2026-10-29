# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: None
:contact: None
"""
import re
import six
import copy
from abc import abstractmethod, ABCMeta
from .ssh_common import SshCommon
import platform
if platform.python_version().startswith('3'):
    from .telnet_common_python3 import TelnetCommon
    _global_y_or_n_prompt = b"(Y/N|Y/N\\?|\\(Y/N\\)\\s*\\?|\\(Y/N\\)\\s*:?|\\(Y/N/C\\) \\? |\
Y = YES, N = NO \\):\\? |\\(y/n\\)|\\(Y/N\\))\\s*$|\\(y/n.*\\)"
    _global_yes_or_no_prompt = b"(?i)\\(Yes/No/All\\)|\\(yes/no"
else:
    from .telnet_common import TelnetCommon
    _global_y_or_n_prompt = "(Y/N|Y/N\\?|\\(Y/N\\)\\s*\\?|\\(Y/N\\)\\s*:?|\\(Y/N/C\\) \\? |\
Y = YES, N = NO \\)\\:\\? |\\(y/n\\)|\\(Y/N\\))\\s*$|\\(y/n.*\\)"
    _global_yes_or_no_prompt = "(?i)\\(Yes/No/All\\)|\\(yes/no"
__all__ = ["ta_ssh_telnet", "global_connections"]


def log(msg):
    'doc'
    from robot.libraries.BuiltIn import BuiltIn
    BuiltIn().log(msg)


@six.add_metaclass(ABCMeta)
class AbstractConnectionMgr(object):
    """
    basic define
    """

    def __init__(self):
        self._loglevel = None
        self._connections = None

    def set_shell_prompt(self, *new_prompt):
        """This keyword sets the connection prompt to new prompt other than default one.
        """
        old_prompt = self._current._prompt
        self._current.set_prompt(*new_prompt)
        return old_prompt

    def set_shell_loglevel(self, loglevel):
        """Sets the loglevel of the current host connection.

        The log level of the current connection is set. If no connection exists yet, this loglevel is used as default
        for connections created in the future. In both cases the old log level is returned, either the log level of the
        current connection or the previous default loglevel.

        | Input Paramaters | Man. | Description |
        | loglevel         | Yes  | new loglevel, e.g. "WARN", "INFO", "DEBUG", "TRACE" |

        | Return Value | Previous log level as string |
        """
        if self._current is None:
            old = self._loglevel
            self._loglevel = loglevel
            return old
        return self._current.set_loglevel(loglevel)

    def set_shell_timeout(self, timeout="5"):
        """Allows to set a different timeout for long lasting commands.

        | Input Paramaters | Man. | Description |
        | timeout | No | Desired timeout. If this parameter is omitted, the timeout is reset to 30.0 seconds. |

        Example
        | Reset Timeout Test | Set MML Timeout |
        """
        return self._current.set_timeout(timeout)

    def set_shell_pausetime(self, pause="3"):
        """Allows to set a different timeout for long lasting commands.

        | Input Paramaters | Man. | Description |
        | timeout | No | Desired timeout. If this parameter is omitted, the timeout is reset to 30.0 seconds. |

        Example
        | Reset Pause Time Test | Set pause Timeout |
        """
        return self._current.set_pausetime(pause)

    def get_current_connection(self):
        """
        get current host connection.
        """
        return self._current

    @abstractmethod
    def connect_to_host(self):
        """Connect to a host with some kind of method. Should be implemented by
           specifed connection manager.
        """
        raise NotImplementedError("should be implement first")

    @property
    def base_connection(self):
        """Base connection, like TelnetCommon or _global_ssh_connection
        """
        raise NotImplementedError("should be implement first")

    def disconnect_from_host(self, conn=None):
        """disconnect current host
        """
        if conn is not None:
            if conn not in self._connections:
                raise RuntimeError(
                    'Unknow connection :"%s", when disconnect from host.' %
                    conn)
            self._current = conn

        global global_connections
        if not self._current:
            return
        if self._current in global_connections:
            global_connections.remove(self._current)
        self._connections.remove(self._current)
        self._current.close_connection()
        if len(self._connections) == 0:
            self._current = None
        else:
            self._current = global_connections[-1]

    def disconnect_all_hosts(self):
        """disconnect all hosts
        """
        global global_connections
        for conn in self._connections:
            if conn in global_connections:
                global_connections.remove(conn)
            conn.close_connection()
        self._connections = []
        self._current = None

    def switch_host_connection(self, conn):
        """Switch to the connection identified by 'conn'.

        The value of the parameter 'conn' was obtained from keyword 'Connect To Host'
        """
        if not conn:
            raise RuntimeError(
                'The connection you switch to is "%s", is an invalid connection ! ' %
                conn)
        if conn in self._connections:
            global global_connections
            if conn in global_connections:
                global_connections.remove(conn)
            global_connections.append(conn)
            self._current = conn
            log("Switch to connection: %s." % conn)
        else:
            raise RuntimeError(
                'Unknow connection: "%s", when switch host connection.' %
                conn)

    def _handle_error_code(self, expected_errorcode):
        if str(expected_errorcode) in ["0", 0] or expected_errorcode:
            try:
                expected_errorcode = int(expected_errorcode)
            except Exception as e:
                log(e)
                raise Exception(
                    "expected_errorcode should be a integer !")
        else:
            expected_errorcode = None
        return expected_errorcode

    def _execute_cmd(self, newline, command):
        ret = ""
        if newline != "default":
            old_newline = self._current.set_newline(newline)
        self._current.write(command)
        if newline != "default":
            self._current.set_newline(old_newline)
        if self._is_match_prompt(command, self._current._prompt):
            ret = self._current.read_until(command,
                                           self._current._timeout)
        return ret

    def _command_handle(self, username, password, newline,
                        command, timeout_add, expected_errorcode):
        fail_send_ctrl_c = True
        ret = ""
        if self._current.device_type == "Linux" and password != "":
            # use "su" to change user for command execution
            self._current.write("su " + username)
            origprompt = self._current.set_prompt("assword:")
            self._current.read_until_prompt()
            self._current.write(password)
            self._current.set_prompt('$')
            self._current.read_until_prompt()
            ret = self._execute_cmd(newline, command)
            ret = self._current.read_until_prompt(timeout_add=timeout_add)
            if expected_errorcode is not None:
                try:
                    self.check_shell_command_errorcode(
                        int(expected_errorcode))
                except RuntimeError as e:
                    fail_send_ctrl_c = False
                    raise e
            self._current.set_prompt(origprompt)
            self._current.write('exit')
            self._current.read_until_prompt()
        else:
            ret = self._execute_cmd(newline, command)
            ret = self._current.read_until_prompt(timeout_add=timeout_add)
            if re.search(_global_y_or_n_prompt, ret[-20:], re.M):
                self._current.write("y")
                ret += self._current.read_until_prompt(
                    timeout_add=timeout_add)
            if re.search(_global_yes_or_no_prompt, ret[-20:], re.M):
                self._current.write("yes")
                ret += self._current.read_until_prompt(
                    timeout_add=timeout_add)
            if expected_errorcode is not None:
                try:
                    self.check_shell_command_errorcode(
                        int(expected_errorcode))
                except RuntimeError as e:
                    fail_send_ctrl_c = False
                    raise e
        return ret, fail_send_ctrl_c

    def execute_shell_command(self, command, **kwargs):
        """Execute a command on the remote system.

        | Input Parameters  | Man. | Description |
        | command           | Yes  | command to be executed on the remote system |
        | username          | No   | username for execute command on the remote system (Linux only) |
        |                   |      | default is "root". |
        | password          | No   | password for user on the remote system (Linux only) |
                                   | default is "", execute command as current user. |
        | timeout_add       | No   | default is True, if it is a false, will not check if there is already have data
                                   | in the socket, when timeout is reach or one of prompt is reach. |
        | loglevel          | No  | the loglevel of current command execution |
        | newline           | No   | the newline will be added to command, default is same as connect to host |
        | expected_errorcode | No  | the errorcode expected |
        | msg_trip           | No  | the errorcode expected |

        | Return value | command output (String) |

        Example
        | Execute shell command | ${command} |                  | # execute command as current user. |
        | Execute shell command | ${command} | password=${password} | # execute command as root. |
        | Execute shell command | ${command} | expected_errorcode=0 | #execute command and check the errorcode |
        """
        password = kwargs.get("password", "")
        username = kwargs.get("username", "root")
        expected_errorcode = kwargs.get("expected_errorcode", "")
        timeout_add = kwargs.get("timeout_add", True)
        newline = kwargs.get("newline", "default")
        loglevel = kwargs.get("loglevel", "default")
        msg_trip = kwargs.get("msg_trip", "Y")

        expected_errorcode = self._handle_error_code(expected_errorcode)

        log("Current connection: %s" % self._current)
        self._current.read(loglevel="DEBUG")
        if loglevel != "default":
            old_loglevel = self._current.set_loglevel(loglevel)
        fail_send_ctrl_c = False
        try:
            ret, fail_send_ctrl_c = self._command_handle(
                username, password, newline, command, timeout_add, expected_errorcode)
            if isinstance(ret, bytes):
                try:
                    ret = ret.decode('ascii')
                except Exception:
                    ret = ret.decode()
            if msg_trip == 'N':
                return ret

            elif msg_trip == 'Y' and ret.strip().endswith('AaShell>'):
                ret = ret.strip().strip('AaShell>')
                ret = ("\r\n").join(ret.split('\r\n')[1:])
            else:
                ret = ("\r\n").join(ret.split('\r\n')[1:-1])
            return ret
        except Exception as e:
            if fail_send_ctrl_c:
                self._current.write_bare(chr(3))
            # sam added when timeout happens try to read buffer already leave
            # in the socket
            self._current.read()
            raise Exception(
                "command '%s' execution failed, details: '%s'" %
                (command, e))
        finally:
            if loglevel != "default":
                self._current.set_loglevel(old_loglevel)

    def execute_shell_command_bare(self, command, **kwargs):
        """Execute a command on the remote system.

        | Input Parameters  | Man. | Description |
        | command           | Yes  | command to be executed on the remote system |
        | loglevel          | No  | the loglevel of current command execution |
        | Return value | command output (String) |

        Example
        | Execute shell command bare | ${command} |
        """
        log("Current connection: %s" % self._current)
        loglevel = kwargs.get("loglevel", "default")
        try:
            if loglevel != "default":
                old_loglevel = self._current.set_loglevel(loglevel)
            self._current.write_bare(str(command))
        except Exception as e:
            raise Exception(
                "command '%s' execution failed, details: '%s'" %
                (command, e))
        finally:
            if loglevel != "default":
                self._current.set_loglevel(old_loglevel)

    def _get_device_type_from_raw_login_record(self, ret):
        if re.search(
            b".*microsoft.*|^\\w[:\\/\\-a-zA-Z0-9\\s]*[^\\s]>\\s?$",
            ret,
                re.I | re.M):
            device_type = "Windows"
        elif re.search(b".*GNU.*|.*Last login.*|.*linux.*|root@.*", ret, re.I | re.M):
            device_type = "Linux"
        else:
            device_type = "Unknow"
        return device_type

    def _get_shell_errorcode(self):

        errorcode_check_flag = "ERRORCODE is: "
        errorcode_check_cmd = {
            "LINUX": "echo %s$?" %
            errorcode_check_flag,
            "WINDOWS": "echo %s%%ERRORLEVEL%%" %
            errorcode_check_flag,
        }
        errorcode_raw_string = ""
        cmd = errorcode_check_cmd[self._current.device_type.upper()]

        self._current.read(loglevel="DEBUG")
        self._current.write(cmd)
        if self._is_match_prompt(cmd, self._current._prompt):
            errorcode_raw_string += self._current.read_until(
                cmd, self._current._timeout)
        errorcode_raw_string += self._current.read_until_prompt()

        return_code = None
        lines = errorcode_raw_string.splitlines()
        for line in lines:
            if line.startswith(errorcode_check_flag):
                return_code = int(line.lstrip(errorcode_check_flag).strip())
                log("Current errorcode is : %d" % return_code)
                break
        return return_code

    def check_shell_command_errorcode(self, expected_errorcode=0):
        """null"""
        error_code = self._get_shell_errorcode()
        if error_code != int(expected_errorcode):
            raise RuntimeError(
                "Execute failed with return code: %d" %
                error_code)

    def _is_match_prompt(self, orignal_string, *prompt):
        if len(prompt) == 1:
            if isinstance(prompt[0], six.string_types):
                prompt = list(prompt)
            else:
                prompt = prompt[0]
        else:
            prompt = list(prompt)

        for i in range(len(prompt)):
            if isinstance(prompt[i], (six.string_types, bytes)):
                prompt[i] = re.compile(prompt[i], re.MULTILINE)

        for p in prompt:
            try:
                m = p.search(orignal_string)
            except Exception:
                m = p.search(orignal_string.encode('ascii'))

            if m:
                log('"%s" have match one of the prompt: "%s"' % (orignal_string, p.pattern))
                return True
        return False

    def _match_count_is(self, orgnial_string, *prompt):
        """check given string is match prompts of not"""

        if len(prompt) == 1:
            if isinstance(prompt[0], six.string_types):
                prompt = list(prompt)
            else:
                prompt = prompt[0]
        else:
            prompt = list(prompt)

        for i in range(len(prompt)):
            if isinstance(prompt[i], six.string_types):
                prompt[i] = re.compile(prompt[i], re.MULTILINE)
        count = 0
        # use greedy match will not cause problems that match one prompt
        # several times
        temp = ""
        for s in orgnial_string:
            temp += s
            for p in prompt:
                m = p.search(temp)
                if m:
                    log('"%s" have match one of the prompt: "%s"' % (temp, p.pattern))
                    count += 1
                    temp = ""
                    break
        return count
        """
        for p in prompt:
            if temp_string == "":
                break
            m = p.search(temp_string)
            if m:
                temp_string = temp_string[m.end():]
                log('"%s" have match one of the prompt: "%s"' % (temp_string, p.pattern))
                count += 1
        return count
        """


class TelnetCommonMgr(AbstractConnectionMgr):
    """null"""

    def __init__(self):
        self._connections = []
        self._current = None
        self._loglevel = "INFO"

    def __getattr__(self, name):
        if name not in ["write", "write_bare", "read_until_prompt", "read",
                        "read_until"]:
            raise AttributeError("call of '%s' not supported" % name)
        if self._current is None:
            raise AttributeError("Invalid current connection")
        return getattr(self._current, name)

    @property
    def base_connection(self):
        """null"""
        return TelnetCommon

    def connect_to_host(self, host, port=23, user="public",
                        passwd="public", prompt="", timeout="60sec"):
        """This keyword opens a telnet connection to a remote host and logs in.

        | Input Parameters | Man. | Description |
        | host      | Yes | Identifies to host |
        | port      | No  | Allows to change the default telnet port |
        | user      | No  | Authentication information. Default is 'public' |
        | passwd    | No  | Authentication information. Default is 'public' |
        | prompt    | No  | prompt as list of regular expressions. Default is: |
        |           |     | "%s@.*\\$ " % user for Linux |
        |           |     | "\\w:.*>" for Microsoft Windows |
        |           |     | "#" for Cisco Router |
        | timeout   | No  | Timeout for commands issued on this connection. Default is 120 sec |

        | Return value | connection identifier to be used with 'Switch Host Connection' |

        Example
        | Open Test | Connect to Host | zeppo |

        Note
        When log in some device, it don't need input user name, for example ESA,
        you must input uesr by '' to replace it.
        """
        if prompt is None or prompt == "":
            # myprompt = [ "%s@.*\$ " % user, "\w:.*>", "Cisco.*>", "Cisco.*#"
            # ]
            myprompt = ["%s@.*[$>#]\\s{0,1}" % user, "root@.*>$", "^\\w:.*>",
                        ".*[$#]", "assword:",
                        "^.*\\(y/n\\)\\s*"]
        else:
            myprompt = prompt

        conn = self.base_connection(host, port, myprompt, timeout, "CR")

        conn.set_loglevel(self._loglevel)
        if user != "":
            ret = conn.login(user, passwd, ["login: ", "Username: ",
                                            "ENTER USERNAME <", '>'],
                             ["password: ", "Password:\\s{0,1}",
                              "Password for .*: ", "ENTER PASSWORD <"])
        else:
            ret = conn.login(user, passwd, [""], ["password:", "Password:",
                                                  "Password for .*: "])
        conn.device_type = self._get_device_type_from_raw_login_record(ret)

        conn.set_prompt(myprompt)

        self._current = conn
        self._connections.append(conn)
        global global_connections
        if conn not in global_connections:
            global_connections.append(conn)
        return conn


class SshCommonMgr(AbstractConnectionMgr):
    """null"""

    def __init__(self):
        self._connections = []
        self._current = None
        self._loglevel = "INFO"

    def __getattr__(self, name):
        if name not in ["write", "write_bare", "read_until_prompt", "read",
                        "read_until"]:
            raise AttributeError("call of '%s' not supported" % name)
        if self._current is None:
            raise AttributeError("Invalid current connection")
        return getattr(self._current, name)

    @property
    def base_connection(self):
        """null"""
        return SshCommon

    def connect_to_host(self, host, port=22, user="omc", passwd="omc",
                        prompt="", timeout="60sec"):
        """This keyword opens a telnet connection to a remote host and logs in.

        | Input Parameters | Man. | Description |
        | host      | Yes | Identifies to host |
        | port      | No  | Allows to change the default telnet port |
        | user      | No  | Authentication information. Default is 'public' |
        | passwd    | No  | Authentication information. Default is 'public' |
        | prompt    | No  | prompt as list of regular expressions. Default is: |
        |           |     | "%s@.*\\$ " % user for Linux |
        |           |     | "\\w:.*>" for Microsoft Windows |
        |           |     | "#" for Cisco Router |
        | timeout   | No  | Timeout for commands issued on this connection. Default is 120 sec |

        | Return value | connection identifier to be used with 'Switch Host Connection' |

        Example
        | Open Test | Connect To SSH Host | OMS |

        Note
        When log in some device, it don't need input user name, for example ESA,
        you must input uesr by '' to replace it.
        """
        if prompt is None or prompt == "":
            # myprompt = [ "%s@.*[$>#]\s{0,1}" % user, "root@.*>$", "\w:.*>",
            # ".*#"]
            myprompt = ["%s@.*[$>#]\\s{0,1}" % user, "root@.*>$", "^\\w:.*>",
                        ".*[$#]", "assword:",
                        "^.*\\(\\y/n\\)\\s*"]
        else:
            myprompt = prompt

        conn = self.base_connection(host, port, myprompt, timeout, "LF")
        ret = conn.login(user, passwd)
        conn.device_type = self._get_device_type_from_raw_login_record(ret)
        conn.set_prompt(myprompt)

        self._current = conn
        self._connections.append(conn)
        global global_connections
        if conn not in global_connections:
            global_connections.append(conn)
        return conn


class ta_ssh_telnet(object):
    """make sure to use current_mgr to get the lastest connections manager"""

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        global _global_ssh_connection
        global _global_telnet_connection
        self._current_mgr = None
        self._default_mgr = _global_telnet_connection
        self._connmgrdict = {"SSH": _global_ssh_connection,
                             "TELNET": _global_telnet_connection
                             }

    def _get_connection_mgr_before_connect(self, conn_type):
        """null"""
        if conn_type.upper() in self._connmgrdict:
            connmgr = self._connmgrdict[conn_type.upper()]
        else:
            raise RuntimeError(
                "The conn_type you given ('%s') is not supported now !" %
                conn_type)
        # for first connection to change current mgr
        self._current_mgr = connmgr
        return connmgr

    def _get_current_mgr(self):
        """null"""
        global global_connections
        if len(global_connections) != 0:
            self._current_mgr = self._connmgrdict[
                global_connections[-1].conn_type.upper()]
        else:
            self._current_mgr = self._default_mgr
        return self._current_mgr

    def _set_current_mgr(self, conn_mgr):
        """null"""
        if isinstance(conn_mgr, AbstractConnectionMgr):
            self._current_mgr = conn_mgr
        elif isinstance(conn_mgr, six.string_types):
            self._current_mgr = self._connmgrdict[conn_mgr.upper()]
        else:
            self._current_mgr = None

    current_mgr = property(fget=_get_current_mgr, fset=_set_current_mgr)

    def get_current_connection(self, conn_type=None):
        """null"""
        if not conn_type:
            if len(global_connections) != 0:
                return global_connections[-1]
            else:
                return None
        assert conn_type.upper() in self._connmgrdict, \
            "The conn_type you given ('%s') is not supported now !" % conn_type
        return self._connmgrdict[conn_type.upper()].get_current_connection()

    def _set_current_connection(self, conn):
        """null"""
        assert isinstance(conn, TelnetCommon) or isinstance(
            conn, _global_ssh_connection), "The conn_obj you set ('%s') is invalid !" % conn
        global global_connections
        if conn in global_connections:
            global_connections.remove(conn)
        global_connections.append(conn)
    current_conn = property(fget=get_current_connection,
                            fset=_set_current_connection)

    def switch_host_connection(self, conn):
        """Switch to the connection identified by 'conn'.
           The value of the parameter 'conn' was obtained from keyword 'Connect to Host'
        """
        if conn:
            # for witch connection to change current mgr
            self._current_mgr = self._connmgrdict[conn.conn_type.upper()]
            return self._current_mgr.switch_host_connection(conn)
        raise RuntimeError(
            "The connection you switch to ('%s') is not invalid !" %
            conn)

    def disconnect_all_hosts(self, **kwargs):
        """Closes the telnet connections to the currently active remote host.
        @param kwargs: option kwargs
        """
        conn_type = kwargs.get("conn_type", None)

        global global_connections
        if not conn_type:
            for conmgr in self._connmgrdict.values():
                conmgr.disconnect_all_hosts()
            global_connections = []
        else:
            assert conn_type.upper() in self._connmgrdict, \
                "The conn_type you given ('%s') is not supported now !" % conn_type
            conmgr = self._connmgrdict[conn_type.upper()]
            for conn in conmgr._connections:
                if conn in global_connections:
                    global_connections.remove(conn)
            return conmgr.disconnect_all_hosts()

    def disconnect_from_host(self, conn=None):
        """
        @param conn: connection object, return from connect_to_host
        """
        global global_connections
        if conn:
            if conn in global_connections:
                global_connections.remove(conn)
            return self._connmgrdict[conn.conn_type.upper()].\
                disconnect_from_host(conn)
        else:
            return self.current_mgr.disconnect_from_host()

    def execute_shell_command(self, command, **kwargs):
        """Execute a command on current connection.
        @param command: command to be executed
        @kwargs timeout_add, password, expect
        | Example:
        | Execute shell command | ${command} |                      | # execute command as current user. |
        | Execute shell command | ${command} | timeout_add=${false} |
        # execute until command timeout, neither the socket have data or not |
        | Execute shell command | ${command} | password=${password} | # execute command as root. |
        | Execute shell command | ${command} | expected_errorcode=0 | #execute command and check the errorcode |
        """
        return self.current_mgr.execute_shell_command(command, **kwargs)

    def execute_shell_command_bare(self, command, **kwargs):
        """Execute a bare command on current connection. means no newline added.
        @param command: command to be executed
        @kwargs timeout_add, password, expect
        """
        return self.current_mgr.execute_shell_command_bare(command, **kwargs)

    def get_shell_content(self):
        """This keyword get the current content of .
        """
        return self.current_mgr.read()

    def set_shell_prompt(self, *new_prompt):
        """This keyword sets the connection prompt to new prompt other than default one.
        @param new_prompt: New prompt for connection |
        @requires: old prompt
        @rtype: string

        | Example
        | ${old_prompt} = | set_shell_prompt | # |  $ |
        | ${old_prompt} = | set_shell_prompt | [.*$, \\w:.*>] |
        """
        return self.current_mgr.set_shell_prompt(*new_prompt)

    def set_shell_timeout(self, new_timeout):
        """This keyword sets the new connection timeout.
        @param new_timeout: New timeout for connection |
        @requires: old timeout
        @rtype: string

        | Example
        | ${old_timeout} = | set_shell_timeout | 100 |
        """
        return self.current_mgr.set_shell_timeout(new_timeout)

    def set_shell_pausetime(self, pausetime):
        """This keyword sets the new connection pausetime.
        @param pausetime: New pausetime for connection |
        @requires: old pausetime
        @rtype: string

        | Example
        | ${old_timeout} = | set_shell_pausetime | 100 |
        """
        return self.current_mgr.set_shell_pausetime(pausetime)

    def set_shell_loglevel(self, loglevel):
        """This keyword sets the new connection loglevel.
        @param loglevel: New pausetime for connection |
        @requires: old loglevel
        @rtype: string

        | Example
        | ${old_loglevel} = | set_shell_loglevel | DEBUG |
        """
        return self.current_mgr.set_shell_loglevel(loglevel)

    def connect_to_host(self,
                        host,
                        port=23,
                        username="",
                        password="",
                        **kwargs):
        """Used to connect to host, either TELNET or SSH
        @param host: the address of the host you want connect
        @param port: he port you want connect
        @param username: the username
        @param password: the password
        @param username_prompt:
        @param password_prompt:
        @param
        @param
        | Input Parameters  | Man. | Description |
        | host              | Yes  |  |
        |               | No   | t|
        |           | No   | the username    |
        | password          | No   | the password    |
        | username_prompt    | No   | the username prompt |
        |     | No   | the password prompt |
        | conn_type         | No   | the connection type, TELNET or SSH |
        | prompt            | No   | the command prompt of target host |
        | newline           | No   | the newline of target host , can be CRLF or LF for windows or linux |
        | timeout           | No   | the timeout of target host |
        | pausetime         | No   | the pause time before read something from connection |
        | device_type       | No   | the device_type of your target host |

        | Return value | original connection pausetime |

        Example
        | ${connection} = | connect_to_host | 127.0.0.1 | port=23 | username=tdlte-tester | password=btstest |\
        """
        try:
            conn_type = kwargs.get("conn_type", "TELNET")

            username_prompt = copy.copy(
                kwargs.get(
                    "username_prompt",
                    _global_username_prompt))
            password_prompt = copy.copy(
                kwargs.get(
                    "password_prompt",
                    _global_password_prompt))

            prompt = copy.copy(kwargs.get("prompt", _global_default_prompt))
            newline = kwargs.get("newline", "CRLF") if conn_type == "TELNET" or password == 'Nokia123!'\
                else kwargs.get("newline", "LF")
            timeout = kwargs.get("timeout", "30sec")
            pausetime = kwargs.get("pausetime", "0.05sec")
            device_type = kwargs.get("device_type", None)
            key_filename = kwargs.get("key_filename", None)

            connmgr = self._connmgrdict[conn_type.upper()]
        except Exception as e:
            raise Exception(
                """Parameters you input is invalid, please\
             check it! Details reason: " %s" """ % e)

        current = connmgr.base_connection(host, port, prompt, timeout, newline)
        # made method in abstract connection can use self._current
        connmgr._current = current
        loginret = b""

        if key_filename is not None and conn_type.upper() == "SSH":
            loginret += current.login(username, password,
                                      username_prompt, password_prompt, key_filename)
        elif (password != "" or username != "") or conn_type.upper() == "SSH":
            loginret += current.login(username, password,
                                      username_prompt, password_prompt)
        else:
            loginret += current.read_until_prompt(None)
        selected_prompt = current.get_prompt()
        if type(selected_prompt) not in (tuple, list):
            prompt = [selected_prompt]
        else:
            prompt = list(selected_prompt)
        prompt.append(_global_y_or_n_prompt)
        prompt.append(_global_yes_or_no_prompt)
        current.set_prompt(prompt)
        current.set_pausetime(pausetime)
        current.set_timeout(timeout)

        if device_type is None:
            device_type = connmgr._get_device_type_from_raw_login_record(
                loginret)
        current.device_type = device_type
        connmgr._connections.append(current)

        global global_connections
        if current not in global_connections:
            global_connections.append(current)
        # set loginret as current object's attribute
        setattr(current, 'login_info', loginret)
        return current


"""the most common used prompts"""

# need add more usually use
_global_username_prompt = ["ogin:", "sername:"]
_global_password_prompt = ["assword:", "assword for .*: "]

_global_default_prompt = [
                          # for windows
                          r"[CDEFGHcdefgh]:[\\/\-a-zA-Z0-9\s\._~&\(\)]*[^\s]>\s?$",
                          r"[CDEFGHcdefgh]:[\\/\-a-zA-Z0-9\s\._~&\(\)]*[^\s]>\s?",
                          r"^[a-zA-Z0-9@_\-\(\)\.\s]*[$#>]{1}\s{0,1}$",
                          r"[\\;\[\.\-a-zA-Z0-9\s]+@.*[$>#]{1}\s{0,3}$",  # for linux
                          ]

_global_ssh_connection = SshCommonMgr()
_global_telnet_connection = TelnetCommonMgr()
global_connections = []

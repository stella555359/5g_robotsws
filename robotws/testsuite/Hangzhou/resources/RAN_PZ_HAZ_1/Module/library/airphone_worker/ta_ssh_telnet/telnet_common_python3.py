# -*- coding: utf-8 -*-

import re
import six
import time
import telnetlib
import types
import socket
from robot.utils import seq2str
from robot.utils import timestr_to_secs
from robot.utils import secs_to_timestr
from robot.utils import get_time
from select import select

REGEXP = re.compile('|'.join([
    r'\x1b\[\d{1,3}[lhinc]',
    r'\x1b\[\d{1,3};\d{1,3}[lhy]',
    r'\x1b\[\d+[ABCDmgKJPLMincq]',
    r'\x1b\[\d+;\d+[HfmrR]',
    r'\x1b\[[HfmKJic]',
    r'\x1b[DME78=>NOHgZc<ABCDIFGKJ\^_WXV\]]',
    r'\x1b[()][AB012]',
    r'\x1b#\d',
    r'\x1bY\d+',
    r'\x1b\/Z'
]))


class TelnetCommon(telnetlib.Telnet):
    """null"""

    def __init__(self, host, port, prompt, timeout="10sec", newline='CRLF'):
        self.host = host
        self.port = port == '' and 23 or int(port)
        self._timeout = float(timestr_to_secs(timeout))
        telnetlib.Telnet.__init__(self, self.host, self.port)
        self._newline = None
        self.set_newline(
            newline.upper().replace(
                'LF',
                '\n').replace(
                'CR',
                '\r'))
        self._prompt = None
        self.set_prompt(prompt)
        self._loglevel = "INFO"
        self.username = None
        self.password = None

        self._pausetime = 0.05
        self.conn_type = "TELNET"
        self.device_type = None

    def __str__(self):
        return str(self.host) + ":" + str(self.port) + " DeviceType:" + str(self.device_type) + \
            " Timeout:" + secs_to_timestr(self._timeout) + " " + repr(self)

    def __del__(self):
        """Override Telnet.__del__ because it sometimes causes problems"""
        pass

    @property
    def connected(self):
        """null"""
        try:
            self.sock.recv(0)
        except socket.error:
            self._connected = False
        except Exception as _:
            self._connected = False
        else:
            self._connected = True
        return self._connected

    @connected.setter
    def connected(self, value):
        """null"""
        self._connected = value

    def open(self, host, port=0, *args):
        """Override Telnet.open set timeout of create connection!"""
        self.eof = 0
        if not port:
            port = telnetlib.TELNET_PORT
        self.host = host
        self.port = port
        msg = "getaddrinfo returns an empty list"
        for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
            af, socktype, proto, _canonname, sa = res
            try:
                self.sock = socket.socket(af, socktype, proto)
                self.sock.settimeout(self._timeout)
                self.sock.connect(sa)
            except socket.error as msg:
                if self.sock:
                    self.sock.close()
                self.sock = None
                continue
            break
        if not self.sock:
            raise socket.error(msg)
        self.connected = True

    def read_all_avail_data(self, loglevel=None):
        """read all the avail data from socket, don't use self.sock.recv, it may cause problems"""
        time.sleep(self._pausetime)
        loglevel = loglevel is None and self._loglevel or loglevel
        ret = ""
        try:
            self.process_rawq()
            while not self.eof and select(
                    [self.fileno()], [], [], 1) != ([], [], []):
                self.fill_rawq()
                self.process_rawq()
            ret = self.read_very_lazy()
        except Exception as e:
            self._log(str(e), "WARN")
        self._log(b"Get Response: " + ret, loglevel)
        return ret

    def set_pausetime(self, pause):
        """Sets the timeout used in read socket response, e.g. "120 sec".

        The read operations will for this time before starting to read from
        the output. To run operations that take a long time to generate their
        complete output, this timeout must be set accordingly.
        """
        old = secs_to_timestr(self._pausetime)
        self._pausetime = float(timestr_to_secs(pause))
        return old

    def set_timeout(self, timeout):
        """Sets the timeout used in read operations to given value represented as timestr, e.g. "120 sec".

        The read operations will for this time before starting to read from
        the output. To run operations that take a long time to generate their
        complete output, this timeout must be set accordingly.
        """
        old = secs_to_timestr(self._timeout)
        self._timeout = self.timeout = float(timestr_to_secs(timeout))
        return old

    def set_loglevel(self, loglevel):
        """null"""
        old = self._loglevel
        self._loglevel = loglevel
        return old

    def set_newline(self, newline):
        """null"""
        old = self._newline
        self._newline = newline
        return old

    def close_connection(self, loglevel=None):
        """Closes current Telnet connection.

        Logs and returns possible output.
        """
        loglevel = loglevel is None and self._loglevel or loglevel
        telnetlib.Telnet.close(self)
        ret = self.read_all()
        self._log(ret, loglevel)
        self._log("Disconnect from %s" % str(self), self._loglevel)
        self.connected = False
        return ret

    def login(self, username='', password='', login_prompt='ogin: ',
              password_prompt='assword: '):
        """Logs in to Telnet server with given user information.

        The login keyword reads from the connection until login_prompt is
        encountered and then types the username. Then it reads until
        password_prompt is encountered and types the password. The rest of the
        output (if any) is also read and all text that has been read is
        returned as a single string.

        Prompt used in this connection can also be given as optional arguments.
        """
        self.username = username
        self.password = password
        origprompt = self.get_prompt()
        ret = ''
        if username != '':
            self.set_prompt(login_prompt)
            tmp = self.read_until_prompt(None)
            ret += tmp.decode('ascii') + username + '\n'
            self.write(username)
        if password != '':
            self.set_prompt(password_prompt)
            tmp = self.read_until_prompt(None)
            ret += tmp.decode('ascii') + '*' * len(password) + '\n'
            self.write(password)
        self.set_prompt(origprompt)
        if self._prompt is None:
            time.sleep(1)
            ret += self.read(None)
        else:
            if ret.find("openSUSE") == -1:
                self._log("not SUSE system")
            else:
                self._log("SUSE system")
                ret += self.read(None)
                self._log(ret.find("Terminal type?"))
                self.write("vt100")  # add default Terminal type

            time.sleep(self._pausetime)
            ret = self.expect(self._prompt, self._timeout)
            if ret[0] == -1:
                self._log("Get Response: " + ret[2], 'WARN')
                raise AssertionError('No match found for prompt "%s" in %ssec, detail info: "%s"'
                                     % (seq2str([x.pattern for x in self._prompt], lastsep=' or '),
                                        timestr_to_secs(self._timeout), ret[2]))
            else:
                if len(self.get_prompt()) > 1:
                    selected_prompt = self._prompt[ret[0]]
                    self.set_prompt(selected_prompt)
                    self._log("maybe this guy use default prompts, select the most \
similarly to set as default: '%s'" % selected_prompt, "TRACE")
        missbuf = self.read("Trace")
        self._log(ret[2] + missbuf, self._loglevel)
        return ret[2] + missbuf

    def write(self, text):
        """Writes given text over the connection and appends newline"""
        self.write_bare(text.encode('ascii'))
        if self._newline is None:
            nl = b'\r\n'
        else:
            nl = self._newline.encode('ascii')
        self.write_bare(nl)

    def write_bare(self, text):
        """Writes given text over the connection without appending newline"""
        if not isinstance(text, (six.string_types, bytes)):
            msg = 'Only ascii characters are allowed in telnet. Got: %s' % text
            raise ValueError(msg)
        telnetlib.Telnet.write(self, text)

    def read(self, loglevel=None):
        """Reads and returns/logs everything currently available on the output.

        Read message is always returned and logged but log level can be altered
        using optional argument. Available levels are TRACE, DEBUG, INFO and
        WARN.
        """

        ret = self.read_all_avail_data(loglevel)
        return ret

    def read_until_prompt(self, loglevel=None, timeout_add=True):
        """Reads from the current output until prompt is found.

        Expected is a list of regular expressions, and keyword returns the text
        up until and including the first match to any of the regular
        expressions.
        """
        time.sleep(self._pausetime)
        loglevel = loglevel is None and self._loglevel or loglevel

        ret = self.expect(self._prompt, self._timeout)
        if ret[0] == -1:
            self._log(ret[2], 'WARN')
            raise AssertionError('No match found for prompt "%s" in %ssec, detail info: "%s"'
                                 % (seq2str([x.pattern for x in self._prompt], lastsep=' or '),
                                    timestr_to_secs(self._timeout), ret[2]))
        self._log("Get Response: " + ret[2].decode('ascii'), loglevel)

        return ret[2]

    def set_prompt(self, *prompt):
        """Sets the prompt used in this connection to 'prompt'.

        'prompt' can also be a list of regular expressions
        """
        old_prompt = self._prompt
        if len(prompt) == 1:
            if isinstance(prompt[0], six.string_types):
                self._prompt = list(prompt)
            else:
                self._prompt = prompt[0]
        else:
            self._prompt = list(prompt)
        indices = list(range(len(self._prompt)))
        for i in indices:
            if isinstance(self._prompt[i], six.string_types):
                self._prompt[i] = re.compile(self._prompt[i].encode('ascii'), re.MULTILINE)
        return old_prompt

    def get_prompt(self):
        """null"""
        _temp_prompt = []
        if isinstance(self._prompt, bytes):
            return self._prompt
        elif type(self._prompt) in (tuple, list):
            _temp_prompt = list(self._prompt)
        else:
            raise TypeError(self.__str__() +
                            " _prompt should be String or List !")
        _temp_prompt_str = []
        for prompt in _temp_prompt:
            if isinstance(prompt, bytes):
                _temp_prompt_str.append(prompt)
            else:
                _temp_prompt_str.append(getattr(prompt, "pattern"))
        return _temp_prompt_str

    def start_log_buffer(self):
        """ start copying the print outputs of _log into the log buffer """
        self._log_buffer = ""
        self._log_buffering = True

    def write_log_buffer(self, loglevel):
        """ print the log buffer with the specified loglevel and clear the buffer """
        if self._log_buffer:
            self._log_buffering = False
            self._logger.log(self._log_buffer, loglevel)
            self._log_buffer = ""
            self._log_buffering = True

    def stop_log_buffer(self):
        """ stop copying the print output of _log into the log buffer and clear the buffer """
        self._log_buffering = False
        self._log_buffer = ""

    def _log(self, msg, loglevel=None):
        from robot.libraries.BuiltIn import BuiltIn
        BuiltIn().log(msg)

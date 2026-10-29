# -*- coding: utf-8 -*-
import os
import re
import socket
import sys
import telnetlib
import time
from inspect import stack
from select import select
from threading import Lock

from robot.utils import secs_to_timestr
from robot.utils import seq2str
from robot.utils import timestr_to_secs

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


class FileDumper(object):

    def __init__(self, flag="telnet"):
        import sys
        import os
        from datetime import datetime
        now_time = datetime.now()
        now = now_time.strftime("%Y-%m-%d-%H-%M-%S")
        filename = "%s-dump-%s.txt" % (flag, now)
        abs_path = os.path.abspath(filename)
        sys.__stderr__.write("\nTelnet Dump:%s\n" % abs_path)
        self.output = open(filename, 'w')

    def write(self, c):
        self.output.write(c)
        self.output.flush()

    def close(self):
        self.output.close()


class Logger(object):

    def __init__(self, log_level='Info', display_detail=False):
        """ "WARN", "INFO", "DEBUG", "TRACE"
        """
        self._log_level = log_level
        self._display_detail = display_detail
        self._lock = Lock()
        # from tdd_ev_robotws.CommonLib.utils.robot_func import robot_is_running
        # self._robot_is_running = robot_is_running()
        self._robot_is_running = True

    def set_log_level(self, log_level):
        old_level = self._log_level
        self._log_level = log_level
        return old_level

    def log(self, msg, log_level="INFO"):
        with self._lock:
            if self._display_detail:
                src_file, line_num, func_name = stack()[2][1:4]
                msg = '[%s@%d] %s' % (
                    os.path.basename(src_file),
                    line_num,
                    msg)
                return self._log(msg, log_level)
            else:
                return self._log(msg, log_level)

    def _log(self, msg, log_level=None):
        log_level = log_level is None and self._log_level or log_level
        msg = str(msg).strip()
        if msg != '' and log_level is not None:
            if self._robot_is_running:
                print('*%s:%d* %s' % (log_level.upper(), time.time() * 1000, msg))
            else:
                print('*%s* %s' % (log_level.upper(), msg))

    def trace(self, msg):
        self.log(msg, "Trace")

    def debug(self, msg):
        self.log(msg, "Debug")

    def info(self, msg):
        self.log(msg, "Info")

    def warn(self, msg):
        self.log(msg, "Warn")

    def is_trace(self):
        return self._log_level.upper() == 'TRACE'


class FileLogger(Logger):

    def __init__(self, log_level='Info'):
        """ "WARN", "INFO", "DEBUG", "TRACE"
        """
        super(FileLogger, self).__init__()
        from datetime import datetime
        now_time = datetime.now()
        filename = "telnet-dump-%s.txt" % now_time.strftime("%Y%m%d%H%M%S")
        abs_path = os.path.abspath(filename)
        sys.__stderr__.write("\nTelnet Dump:%s\n" % abs_path)
        self.output = open(filename, 'w')
        self.log_level = log_level

    def log(self, msg, level=None):
        self.output.write("[%s]%s\n" % (level, msg))
        self.output.flush()

    def close(self):
        self.output.close()


class TelnetCommon(telnetlib.Telnet):

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
        self._log_level = "INFO"
        self._log_buffering = False
        self._log_buffer = ""
        # self._logger = logger

        self.username = None
        self.password = None

        # self.connected = False
        self._pausetime = 0.05
        self.conn_type = "TELNET"
        self.device_type = None
        # self.connected = False
        # dump_telnet = os.getenv("DUMP_TELNET", "NO") == 'YES'
        # TO DO: dump every connection seesion's baklog to case's log file.
        self._dumper = FileDumper(flag="telnet-%s" % self.host)
        # if os.getenv("TDLTE_DUMP_TELNET", "NO") == 'YES':
        self._logger = FileLogger()

    def __str__(self):
        return str(self.host) + ":" + str(self.port) + " DeviceType:" + str(self.device_type) + \
               " Timeout:" + secs_to_timestr(self._timeout) + " " + repr(self)

    def __del__(self):
        """Override Telnet.__del__ because it sometimes causes problems"""
        pass

    @property
    def connected(self):
        try:
            self.sock.recv(0)
        except socket.error:
            return False
        except Exception as _:
            print(_)
            return False
        else:
            return True

    def open(self, host, port=0, *args):
        """Override Telnet.open set timeout of create connection!"""
        self.eof = 0
        if not port:
            port = telnetlib.TELNET_PORT
        self.host = host
        self.port = port
        msg = "getaddrinfo returns an empty list"
        for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
            af, socktype, proto, canonname, sa = res
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
        # self.connected = True

    def read_all_avail_data(self, log_level=None):
        """read all the avail data from socket, don't use self.sock.recv, it may cause problems"""
        time.sleep(self._pausetime)
        log_level = log_level is None and self._log_level or log_level
        ret = ""
        try:
            self.process_rawq()
            while not self.eof and select(
                    [self.fileno()], [], [], 1) != ([], [], []):
                self.fill_rawq()
                self.process_rawq()
            ret = self.read_very_lazy().decode()
        except Exception as e:
            self._log(str(e), "WARN")
        self._log("Get Response: " + ret, log_level)
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

    def set_log_level(self, log_level):
        old = self._log_level
        self._log_level = log_level
        return old

    def set_newline(self, newline):
        old = self._newline
        self._newline = newline
        return old

    def close_connection(self, log_level=None):
        """Closes current Telnet connection.

        Logs and returns possible output.
        """
        log_level = log_level is None and self._log_level or log_level
        telnetlib.Telnet.close(self)
        ret = self.read_all()
        self._log(ret, log_level)
        self._log("Disconnect from %s" % str(self), self._log_level)
        self._dumper.close()
        # self.connected = False
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
            ret += self.read_until_prompt(None) + username + '\n'
            self.write(username)
        if password != '':
            self.set_prompt(password_prompt)
            ret += self.read_until_prompt(None) + '*' * len(password) + '\n'
            self.write(password)
        self.set_prompt(origprompt)
        if self._prompt is None:
            time.sleep(1)
            ret += self.read(None)
        else:
            if ret.find("openSUSE") == -1:
                self._log("not SUSE system")
                # ret += self.read_until_prompt()
            else:
                self._log("SUSE system")
                ret += self.read(None)
                self._log(ret.find("Terminal type?"))
                self.write("vt100")  # add default Terminal type
                # ret += self.read_until_prompt()
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
        self._log(ret[2].decode() + missbuf, self._log_level)
        # self.connected = True
        return ret[2].decode() + missbuf

    def write(self, text):
        """Writes given text over the connection and appends newline"""
        # self.write_bare(text + r"%s" % ('' if self._newline is None else self._newline))
        self.write_bare(text)
        self.write_bare(
            r"%s" %
            ("" if self._newline is None else self._newline))

    def write_bare(self, text):
        """Writes given text over the connection without appending newline"""
        try:
            text = str(text)
        except UnicodeError:
            msg = 'Only ascii characters are allowed in telnet. Got: %s' % text
            raise ValueError(msg)
        if text not in (self._newline, ""):
            s_dict = {
                chr(3): "Ctrl-C",
                chr(13): "Ctrl-M",
                chr(24): "Ctrl-X",
                chr(25): "Ctrl-Y"}
            self._log(
                "Execute command: " +
                s_dict.get(
                    text,
                    text),
                self._log_level)
        telnetlib.Telnet.write(self, text.encode())
        self._dumper.write("\n<--%s-->\n" % text)

    def read(self, log_level=None):
        """Reads and returns/logs everything currently available on the output.

        Read message is always returned and logged but log level can be altered
        using optional argument. Available levels are TRACE, DEBUG, INFO and
        WARN.
        """

        ret = self.read_all_avail_data(log_level)
        return ret

    def read_until_prompt(self, log_level=None, timeout_add=True):
        """Reads from the current output until prompt is found.

        Expected is a list of regular expressions, and keyword returns the text
        up until and including the first match to any of the regular
        expressions.
        """
        time.sleep(self._pausetime)
        log_level = log_level is None and self._log_level or log_level
        ret = self.expect(self._prompt, self._timeout)
        if ret[0] == -1:
            self._log("Get Response: " + ret[2].decode(), 'WARN')
            raise AssertionError('No match found for prompt "%s" in %ssec, detail info: "%s"'
                                 % (seq2str([x.pattern for x in self._prompt], lastsep=' or '),
                                    timestr_to_secs(self._timeout), ret[2]))
        self._log("Get Response: " + ret[2].decode(), log_level)
        return ret[2].decode()

    def set_prompt(self, *prompt):
        """Sets the prompt used in this connection to 'prompt'.

        'prompt' can also be a list of regular expressions
        """
        import re
        old_prompt = self._prompt
        print(type(prompt[0]))
        if len(prompt) == 1:
            # self._prompt = list(prompt)
            regexp_type = re.compile("").__class__
            if isinstance(prompt[0], str) or isinstance(prompt[0], regexp_type):
                self._prompt = list(prompt)
            else:
                self._prompt = prompt[0]
        else:
            self._prompt = list(prompt)
        indices = list(range(len(self._prompt)))
        for i in indices:
            if isinstance(self._prompt[i], str):
                self._prompt[i] = re.compile(self._prompt[i].encode(), re.MULTILINE)
        return old_prompt

    def get_prompt(self):
        _temp_prompt = []
        if isinstance(self._prompt, str):
            return self._prompt
        elif type(self._prompt) in (tuple, list):
            _temp_prompt = list(self._prompt)
        else:
            raise TypeError(self.__str__() +
                            " _prompt should be String or List !")
        _temp_prompt_str = []
        for prompt in _temp_prompt:
            if isinstance(prompt, str):
                _temp_prompt_str.append(prompt)
            elif isinstance(prompt, bytes):
                _temp_prompt_str.append(prompt.decode())
            else:
                _temp_prompt_str.append(getattr(prompt, "pattern"))
        return _temp_prompt_str

    def start_log_buffer(self):
        """ start copying the print outputs of _log into the log buffer """
        self._log_buffer = ""
        self._log_buffering = True

    def write_log_buffer(self, log_level):
        """ print the log buffer with the specified log_level and clear the buffer """
        if self._log_buffer:
            self._log_buffering = False
            self._logger.log(self._log_buffer, log_level)
            self._log_buffer = ""
            self._log_buffering = True

    def stop_log_buffer(self):
        """ stop copying the print output of _log into the log buffer and clear the buffer """
        self._log_buffering = False
        self._log_buffer = ""

    def _log(self, msg, log_level=None):
        self._logger.log(msg, log_level)
        if self._log_buffering:
            self._log_buffer += msg

    def _handle_iacseq_is_2(self, c):
        cmd = self.iacseq[1]
        self.iacseq = ''
        opt = c
        if opt in [telnetlib.SGA, telnetlib.ECHO]:
            if cmd == telnetlib.DO:
                self.sock.sendall(
                    (telnetlib.IAC + telnetlib.WILL + opt).decode())
            elif cmd == telnetlib.WILL:
                self.sock.sendall(
                    (telnetlib.IAC + telnetlib.DO + opt).decode())
            else:
                pass
        elif cmd in (telnetlib.DO, telnetlib.DONT):
            self.msg(
                'IAC %s %d',
                cmd == telnetlib.DO and 'DO' or 'DONT',
                ord(opt))
            if self.option_callback:
                self.option_callback(self.sock, cmd, opt)
            else:
                self.sock.sendall(
                    (telnetlib.IAC + telnetlib.WONT + opt).decode())
        elif cmd in (telnetlib.WILL, telnetlib.WONT):
            self.msg(
                'IAC %s %d',
                cmd == telnetlib.WILL and 'WILL' or 'WONT',
                ord(opt))
            if self.option_callback:
                self.option_callback(self.sock, cmd, opt)
            else:
                self.sock.sendall(
                    (telnetlib.IAC + telnetlib.DONT + opt).decode())

    # def fill_rawq(self):
    #     """Fill raw queue from exactly one recv() system call.
    #
    #     Block if no data is immediately available.  Set self.eof when
    #     connection is closed.
    #
    #     """
    #     if self.irawq >= len(self.rawq):
    #         self.rawq = b''
    #         self.irawq = 0
    #     # The buffer size should be fairly small so as to avoid quadratic
    #     # behavior in process_rawq() above
    #     buf = self.sock.recv(50).encode()
    #     self.msg("recv %r", buf)
    #     self.eof = (not buf)
    #     self.rawq = self.rawq + buf

    def _rawq_handle(self):
        buf = ['', '']
        while self.rawq:
            c = self.rawq_getchar()
            self._dumper.write(c)
            if not self.iacseq:
                if c == telnetlib.theNULL:
                    continue
                if c == "\021":
                    continue
                if c != telnetlib.IAC:
                    buf[self.sb] = buf[self.sb] + c
                    continue
                else:
                    self.iacseq += c
            elif len(self.iacseq) == 1:
                # 'IAC: IAC CMD [OPTION only for WILL/WONT/DO/DONT]'
                if c in (
                        telnetlib.DO,
                        telnetlib.DONT,
                        telnetlib.WILL,
                        telnetlib.WONT):
                    self.iacseq += c
                    continue

                self.iacseq = ''
                if c == telnetlib.IAC:
                    buf[self.sb] = buf[self.sb] + c
                else:
                    if c == telnetlib.SB:  # SB ... SE start.
                        self.sb = 1
                        self.sbdataq = ''
                    elif c == telnetlib.SE:
                        self.sb = 0
                        self.sbdataq = self.sbdataq + buf[1]
                        buf[1] = ''
                    if self.option_callback:
                        # Callback is supposed to look into
                        # the sbdataq
                        self.option_callback(self.sock, c, telnetlib.NOOPT)
                    else:
                        # We can't offer automatic processing of
                        # suboptions. Alas, we should not get any
                        # unless we did a WILL/DO before.
                        self.msg('IAC %d not recognized' % ord(c))
            elif len(self.iacseq) == 2:
                self._handle_iacseq_is_2(c)
        return buf

    # def process_rawq(self):
    #     """Transfer from raw queue to cooked queue.
    #
    #     Set self.eof when connection is closed.  Don't block unless in
    #     the midst of an IAC sequence.
    #
    #     """
    #     try:
    #         buf = self._rawq_handle()
    #     except EOFError:  # raised by self.rawq_getchar()
    #         self.iacseq = ''  # Reset on EOF
    #         self.sb = 0
    #         pass
    #     i = 0
    #     while i < len(buf[0]):
    #         if buf[0][i] == chr(8):
    #             if i == 0:                        # BS is first element
    #                 # remove it form buffer and the last from the queue if not
    #                 # LF or CR
    #                 buf[0] = buf[0][1:]
    #                 if len(self.cookedq) != 0 and (
    #                         self.cookedq[-1] != chr(10) and self.cookedq[-1] != chr(13)):
    #                     self.cookedq = self.cookedq[:-1]
    #             else:
    #                 if buf[0][i - 1] == chr(10) or buf[0][i - 1] == chr(13):
    #                     # remove only BS from buffer
    #                     buf[0] = buf[0][:i] + buf[0][i + 1:]
    #                 else:
    #                     # remove BS and previous char from buffer
    #                     buf[0] = buf[0][:i - 1] + buf[0][i + 1:]
    #                     i = i - 1
    #         elif buf[0][i] > chr(127):
    #             # remove only this invalid char from buffer
    #             buf[0] = buf[0][:i] + buf[0][i + 1:]
    #         else:
    #             i = i + 1
    #     print("###############################")
    #     print(type(buf[0]))
    #     print("###############################")
    #     self.cookedq = self.cookedq + buf[0]
    #     self.sbdataq = self.sbdataq + buf[1].encode()


if __name__ == "__main__":
    host = "192.168.1.1"
    user = "root"
    password = "Si8a&2vV9"
    conn = None
    try:
        # host = self.ip
        port = 23
        myprompt = ["#", "DM>"]
        conn = TelnetCommon(host, port, myprompt)
        conn.login(user, password,
                   ["gdm7243 login:", "OpenWrt login:"],
                   ["password: ", r"Password:\s{0,1}", "Password for .*: ", "ENTER PASSWORD <"])
    finally:
        if conn:
            conn.close_connection()

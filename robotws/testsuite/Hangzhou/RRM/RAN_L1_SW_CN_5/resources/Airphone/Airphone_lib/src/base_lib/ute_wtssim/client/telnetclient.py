# -*- coding: utf-8 -*-

import re
import time
import select
import socket
import struct
import logging
import telnetlib
import six
import collections

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


class NewTelnet(telnetlib.Telnet):
    def read_very_eager_with_limit(self, limit=5000):
        self.process_rawq()
        while len(self.cookedq) < limit and not self.eof and self.sock_avail():
            self.fill_rawq()
            self.process_rawq()
        buf = self.cookedq
        self.cookedq = b''
        if not buf and self.eof and not self.rawq:
            raise EOFError('telnet connection closed')
        return buf


class TelnetClient(object):
    SOCKET_CONN_ERROR = socket.error
    PADDING_BUFFER = 5000

    def __init__(self, host, port=23, timeout=30, width=200, height=24, prompt=None):
        self._log = logging.getLogger(__name__)
        self._host = host
        self._port = port
        self._timeout = timeout
        self._telnet = None
        self._width = width
        self._height = height
        self._prompt = 'EGATE>' if prompt is None else prompt

    @property
    def host(self):
        return self._host

    @property
    def port(self):
        return self._port

    def open_connection(self):
        self._telnet = NewTelnet(host=self._host, port=self._port, timeout=self._timeout)
        self._telnet.get_socket().sendall(telnetlib.IAC + telnetlib.WILL + telnetlib.NAWS)
        self._telnet.set_option_negotiation_callback(self.set_option_callback)
        self.read_until_regexp(self._prompt)

    def write(self, txt):
        self._telnet.write('{}\r\n'.format(txt).encode('utf-8'))

    def write_bare(self, txt):
        self._telnet.write(txt.encode('utf-8'))

    def read(self):
        out = self._telnet.read_very_eager()
        return out if six.PY2 else str(out, 'cp1252')

    def read_until_regexp(self, regexpL, ignore_prompt_prefix=False, timeout=30, **kwargs):
        transfer_regexpL = []
        if type(regexpL) is list:
            for i in regexpL:
                if isinstance(i, six.string_types):
                    regexp = re.compile(i, re.DOTALL)
                    transfer_regexpL.append(regexp)
        else:
            if isinstance(regexpL, six.string_types):
                regexp = re.compile(regexpL, re.DOTALL)
                transfer_regexpL.append(regexp)
        return self._read_until_regexp(transfer_regexpL, timeout, ignore_prompt_prefix, **kwargs)

    def close_connection(self):
        self._telnet.close()
        self._telnet = None

    def set_option_callback(self, socket, cmd, opt):
        if cmd == telnetlib.DO:
            if opt == telnetlib.NAWS:
                socket.sendall(telnetlib.IAC + telnetlib.WILL + opt)
                socket.sendall(telnetlib.IAC + telnetlib.SB +
                               telnetlib.NAWS +
                               struct.pack('!HH', self._width, self._height) +
                               telnetlib.IAC + telnetlib.SE)
            else:
                socket.sendall(telnetlib.IAC + telnetlib.WONT + opt)
        if cmd == telnetlib.DONT:
            socket.sendall(telnetlib.IAC + telnetlib.WONT + opt)
        if cmd == telnetlib.WILL or cmd == telnetlib.WONT:
            socket.sendall(telnetlib.IAC + telnetlib.DONT + opt)

    def _read_until_regexp(self, regexpL, timeout, ignore_prompt_prefix=False, **kwargs):
        regexpD = collections.OrderedDict()
        for i in regexpL:
            regexpD[i] = False

        output = ''
        start_time = time.time()
        found_index = 1
        while time.time() - start_time <= timeout:
            telnet_read = self._read_and_clean()
            if not telnet_read:
                continue
            output += telnet_read
            if ignore_prompt_prefix:
                output = self._remove_prefix_prompt(output)

            for regexp in regexpD.keys():
                if regexpD[regexp] is False:
                    if regexp.search(output[-(int(kwargs.get('padding_buffer', 5000))+len(telnet_read)-1):]):
                        regexpD[regexp] = "True--%d" % found_index
                        found_index += 1
            if False not in regexpD.values():
                return True, output, regexpD

        return False, output, regexpD

    def _read_and_clean(self):
        buf = self._telnet.read_very_eager_with_limit(limit=self.PADDING_BUFFER)
        if not buf:
            self._wait_for_data()
            return ''
        return self._remove_special_chars(buf.decode('cp1252').encode('utf-8') if six.PY2 else str(buf, 'cp1252'))

    def _wait_for_data(self):
        select.select([self._telnet.fileno()], [], [], 1)

    def _remove_special_chars(self, data):
        data = REGEXP.sub('', data)
        self._log.debug(data)
        return data

    def _remove_prefix_prompt(self, out):
        prompts, data = re.search(r"(\s*{}\s*)*(.*)".format(self._prompt), out, re.DOTALL).groups()
        return data

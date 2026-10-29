# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Pawel Chomicki
:contact: pawel.chomicki@nokia.com
"""

import re
import time
import select
import socket
import struct
import logging
import telnetlib
import six
import collections
import sys

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
        """Read everything that's possible without blocking in I/O (eager) and < limit.

        Raise EOFError if connection closed and no cooked data
        available.  Return '' if no cooked data available otherwise.
        Don't block unless in the midst of an IAC sequence.

        """
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
    """Class to establish, manage and close Telnet connection.

    .. code-block:: python

        client = TelnetClient(host='127.0.0.1', port=2000, timeout=30)
        client.write('ls')
        status, out = client.read_until_regexp('workspace')
    """

    SOCKET_CONN_ERROR = socket.error
    PADDING_BUFFER = 5000

    def __init__(self, host, port=23, timeout=30, width=300, height=24, prompt=None):
        """
        :param string  host:    Destination IP address.
        :param integer port:    Destination port number.
        :param integer timeout: Connection timeout.
        :param integer width:   Telnet window width that will be negotiated with server.
        :param integer height:  Telnet window height that will be negotiated with server.
        :param string prompt:   Telnet prompt available after logging in.
        """
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
        """Returns destination host used for Telnet connection."""
        return self._host

    @property
    def port(self):
        """Returns destination port used for Telnet connection."""
        return self._port

    def open_connection(self):
        """Opens Telnet connection and negotiate window size."""
        self._telnet = NewTelnet(host=self._host, port=self._port, timeout=self._timeout)
        self._request_window_negotiation_protocol(self._telnet.get_socket())
        self._telnet.set_option_negotiation_callback(self.set_option_callback)
        print("[Execute Egate Command] [ute_wtssim/client/telnetclient.py] Open telnet connection to WTS Egate "
              "Start...")
        self.read_until_regexp(regexpD=self._prompt,
                               ignore_prompt_prefix=False,
                               timeout=30,
                               timeout_flag=1)
        print("[Execute Egate Command] [ute_wtssim/client/telnetclient.py] Open telnet connection to WTS Egate "
              "End...")

    def write(self, txt):
        """Writes specify text into telnet connection with EOL char.

        :param string txt: Text to send.
        """
        self._telnet.write('{}\r\n'.format(txt).encode('utf-8'))

    def write_bare(self, txt):
        """Writes specify text into telnet connection without EOL char.

        :param string txt: Text to send.
        """
        self._telnet.write(txt.encode('utf-8'))

    def read(self):
        """Reads available Telnet data.

        :return: Read data.
        :rtype:  string
        """
        out = self._telnet.read_very_eager()
        return out if six.PY2 else str(out, 'cp1252')

    def read_until_regexp(self, regexpD, ignore_prompt_prefix=False, timeout=30, timeout_flag=2, **kwargs):
        transfer_regexpD = collections.OrderedDict()
        if type(regexpD) is str:
            ret = re.search(r":{3}\s*(\d+)\s*", regexpD)
            if ret:
                transfer_regexpD[regexpD.rsplit(":::")[0]] = int(ret.group(1))
            else:
                transfer_regexpD[regexpD] = 1
        elif sys.version_info.major == 2 and type(regexpD) is unicode:
            ret = re.search(r":{3}\s*(\d+)\s*", str(regexpD))
            if ret:
                transfer_regexpD[str(regexpD).rsplit(":::")[0]] = int(ret.group(1))
            else:
                transfer_regexpD[str(regexpD)] = 1
        elif regexpD is None:
            pass
        elif type(regexpD) is list:
            for i in regexpD:
                ret = re.search(r":{3}\s*(\d+)\s*", str(i))
                if ret:
                    transfer_regexpD[str(i).rsplit(":::")[0]] = int(ret.group(1))
                else:
                    transfer_regexpD[str(i)] = 1
        elif type(regexpD) is dict or type(regexpD) is collections.OrderedDict:
            for k, v in regexpD.items():
                transfer_regexpD[k] = v

        detail_res_L = []
        for k, v in transfer_regexpD.items():
            tmpD = collections.OrderedDict()
            tmpD["need_check"] = k
            tmpD["need_check_times"] = v
            tmpD["check_result"] = False
            tmpD["location"] = []
            detail_res_L.append(tmpD)
        output = ""
        if len(detail_res_L) > 0:
            start_time = time.time()
            cycle_time = 0
            checked_all_flag = False
            while time.time() - start_time <= timeout:
                cycle_time += 1
                telnet_read = self._read_and_clean()
                if not telnet_read:
                    continue
                output += telnet_read
                if ignore_prompt_prefix:
                    if not output.strip() == self._prompt:
                        output = self._remove_prefix_prompt(output)
                if not checked_all_flag:
                    for itemD in detail_res_L:
                        if itemD["check_result"] is False:
                            if isinstance(itemD["need_check"], six.string_types):
                                compile_regexp = re.compile(itemD["need_check"], re.DOTALL)
                            ret = compile_regexp.finditer(output)
                            spanL = []
                            for i in ret:
                                spanL.append(i.span())
                            if len(spanL) > 0:
                                itemD["location"] += spanL
                                itemD["location"] = list(set(itemD["location"]))
                                if len(itemD["location"]) >= int(itemD["need_check_times"]):
                                    itemD["check_result"] = True
                    all_p_res = []
                    [all_p_res.append(md["check_result"]) for md in detail_res_L]
                    if False not in all_p_res:
                        checked_all_flag = True
                        if timeout_flag == 1:
                            return True, output, detail_res_L
                else:
                    continue
            print("[Execute Egate Command] [ute_wtssim/client/telnetclient.py] End cycle.")
            flag = True
            for j in detail_res_L:
                if j["check_result"] is False:
                    flag = False
                    break
            if flag:
                return True, output, detail_res_L
            else:
                return False, output, detail_res_L
        else:
            telnet_read = self._read_and_clean()
            output += telnet_read
            return True, output, detail_res_L

    def close_connection(self):
        """Closes telnet connection."""
        self._telnet.close()
        self._telnet = None

    def set_option_callback(self, socket, cmd, opt):
        """Callback for telnetlib.Telnet.set_option_negotiation_callback.

        Callback method was created based on two RFC documents:
            * TELNET PROTOCOL SPECIFICATION - `RFC854 <https://tools.ietf.org/html/rfc854>`_
            * TELNET WINDOW SIZE OPTION - `RFC1073 <https://tools.ietf.org/html/rfc1073>`_

        :param socket socket: Socket used by telnetlib to handle active communication.
        :param char cmd: Telnet negotiation command.
        :param char opt: Telnet negotiation option.
        """
        if cmd == telnetlib.DO:
            if opt == telnetlib.NAWS:
                self._request_window_negotiation_protocol(socket)
                self._request_window_size_from_telnet_server(socket, self._width, self._height)
            else:
                self._opt_wont(socket, opt)
        if cmd == telnetlib.DONT:
            self._opt_wont(socket, opt)
        if cmd == telnetlib.WILL or cmd == telnetlib.WONT:
            self._opt_dont(socket, opt)

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

    def _window_size_negotiation_as_bytes(self, height, width):
        """
        The subnegotiation consists of two values, the width and the height
           of the window in characters.  The values are each sent as two bytes,
           in the Internet standard byte and bit order.
        """
        return struct.pack('!HH', height, width)

    def _request_window_negotiation_protocol(self, socket):
        socket.sendall(telnetlib.IAC + telnetlib.WILL + telnetlib.NAWS)

    def _opt_dont(self, socket, opt):
        socket.sendall(telnetlib.IAC + telnetlib.DONT + opt)

    def _opt_wont(self, socket, opt):
        socket.sendall(telnetlib.IAC + telnetlib.WONT + opt)

    def _request_window_size_from_telnet_server(self, socket, height, width):
        socket.sendall(telnetlib.IAC + telnetlib.SB + telnetlib.NAWS +
                       self._window_size_negotiation_as_bytes(height, width) +
                       telnetlib.IAC + telnetlib.SE)

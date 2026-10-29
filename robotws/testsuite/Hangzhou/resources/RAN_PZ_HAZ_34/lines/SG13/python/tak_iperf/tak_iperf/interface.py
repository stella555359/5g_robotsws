# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import re
import os
import requests
import logging as log
from robot.utils import timestr_to_secs
from tak_core.sshconnection import SshConnection
from .telnetclient import TelnetClient
from .file_common import FileCommon
from ute_common_store import Store


class tak_iperf(object):
    """
    | iperf server and client control pc make sure tak_iperf module exist.
    | 1. linux pc: pip install tak_iperf
    | 2. windows pc: svn checkout library to any folder, such as "d:\\TA_KISS_Lib", remember add the path to pth file
    |   svn co https://svne1.access.nsn.com/isource/svnroot/talibs/tak_iperf/trunk/tak_iperf
    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.store = Store()
        self.seper = "*SEP*"
        tmp = self.seper + "os.path.dirname(tak_iperf.__file__)"
        self.get_lib_path_cmd = '''python -c "import tak_iperf, os;print('%s')"''' % tmp

    def _get_lib_path(self, ret):
        if self.seper not in ret or 'No module named tak_iperf' in ret:
            raise Exception("get lib path failed!")
        else:
            for ln in ret.splitlines()[::-1]:
                if self.seper in ln:
                    self.lib_path = ln.split(self.seper, 3)[-1].strip()
                    return self.lib_path

    def _server_kill_cmd_win(self, port, conn):
        query = "iperf*-s*-p %s" % port
        kill_cmd = 'C:/WINDOWS/System32/Wbem/wmic process where \
"commandline like \'%%%s%%\' and not commandline like \'%%wmic%%\'" delete' % query.replace('*', '%')
        conn.execute(kill_cmd)

    def start_udp_iperf_server(
            self, pc_info, port, log_file, alias='server_default', **variables):
        """This keyword start udp iperf server.
        :param pc_info: list as [ip, user, pwd]
        :param port: The server port for the server to listen on and the client to connect to.
        :param log_file: Redirect output to given file.
        :param conn_num: The number of connections to handle by the server before closing. Default is 0.
        :param report_interval: Sets the interval time in seconds between periodic bandwidth, jitter, and loss reports.
        :param output_format: A letter specifying the format to print bandwidth numbers in. Supported formats are
        :param packet_size: The length of buffers to read or write. It works by writing array of len bytes a number.
        :param buffer_size: Sets the socket buffer sizes to the specified value. For TCP, this sets the TCP window size
        :param bind_host: Bind to host, one of this machine's addresses. For the client this set the outbound interface
        :param client_num: number of client limit to connect
        :param ipv6: Bind to an IPv6 address

        note: output_format

        ::A letter specifying the format to print bandwidth numbers in. Supported formats are
            'b' = bits/sec            'B' = Bytes/sec
            'k' = Kbits/sec           'K' = KBytes/sec
            'm' = Mbits/sec           'M' = MBytes/sec
            'g' = Gbits/sec           'G' = GBytes/sec
            'a' = adaptive bits/sec   'A' = adaptive Bytes/sec

        The adaptive formats choose between kilo- and mega- as appropriate. Fields other than bandwidth print bytes,
        but otherwise follow the requested format. Default is 'a'.
        NOTE: here Kilo = 1024, Mega = 1024^2 and Giga = 1024^3 when dealing with bytes.
        Commonly in networking, Kilo = 1000, Mega = 1000^2, and Giga = 1000^3 so we use this when dealing with bits.
        If this really bothers you, use -f b and do the math.

        ::Example
            ${pc_info}    create list    10.140.160.226    tdlte-tester    btstest    23
            start_udp_iperf_server    ${pc_info}    5005    iperf.log    bind_host=192.168.255.126
        """
        conn_num = variables.get("conn_num", None)
        conn_num = " -P %s" % conn_num if conn_num else ""
        report_interval = variables.get("interval", None)
        output_format = variables.get("output_format", None)
        output_format = " -f %s" % output_format if output_format else ""
        packet_size = variables.get("packet_size", None)
        packet_size = " -l %s" % packet_size if packet_size else ""
        buffer_size = variables.get("buffer_size", None)
        buffer_size = " -w %s" % buffer_size if buffer_size else ""
        bind_host = variables.get("bind_host", None)
        bind_host = " -B %s" % bind_host if bind_host else ""
        client_num = variables.get("client_num", None)
        client_num = " -c %s" % client_num if client_num else ""
        ipv6 = variables.get("ipv6", None)
        ipv6 = " -V" if ipv6 else ""

        iperf_cmd_main = " -s -u -p %s%s%s%s%s%s%s%s%s" % \
            (port,
             " -i %s" % (report_interval if report_interval else "1"),
             conn_num, output_format, packet_size, buffer_size, client_num, bind_host, ipv6)

        if int(pc_info[-1]) == 22 and pc_info[-2] != 'Nokia123!':
            cmd_pre = "/usr/bin/nohup iperf"
            cmd_end = " >%s 2>&1 0</dev/null &" % log_file
            iperf_cmd = cmd_pre + iperf_cmd_main + cmd_end
            self.server_conn = SshConnection(*pc_info)
            self.server_conn._setup()
            self._iperf_server_kill_ssh(port)
            log.info(iperf_cmd)
            self.server_conn.execute(iperf_cmd)
        elif int(pc_info[-1]) == 23:
            self.server_conn = TelnetClient(*pc_info)
            self._server_kill_cmd_win(port, self.server_conn)
            ret = self.server_conn.execute(self.get_lib_path_cmd)
            lib_path = self._get_lib_path(ret)
            cmd_pre = '"%s" -i -d python "%s" "%s"' % (os.path.join(lib_path, "psexec.exe"),
                                                       os.path.join(
                                                           lib_path, "iperf_mgr.py"),
                                                       os.path.join(lib_path, 'iperf.exe'))
            cmd_end = ' -o "%s"' % log_file
            iperf_cmd = cmd_pre + iperf_cmd_main + cmd_end
            self._server_kill_cmd_win(port, self.server_conn)
            log.info(iperf_cmd)
            self.server_conn.execute(iperf_cmd)
        else:
            self.server_conn = SshConnection(*pc_info, prompt='>')
            self.server_conn._setup()
            ret, rc, er = self.server_conn.execute(self.get_lib_path_cmd)
            lib_path = self._get_lib_path(ret)
            cmd_pre = '%s -i 2 -d -u noklab\\%s -p %s python %s %s' % (os.path.join(lib_path, "psexec.exe"),
                                                                       pc_info[1],
                                                                       pc_info[2],
                                                                       os.path.join(lib_path, "iperf_mgr.py"),
                                                                       os.path.join(lib_path, 'iperf.exe'))
            cmd_end = ' -o "%s"' % log_file
            iperf_cmd = cmd_pre + iperf_cmd_main + cmd_end
            self._server_kill_cmd_win(port, self.server_conn)
            log.info(iperf_cmd)
            ret, err, rc = self.server_conn.execute(iperf_cmd)
            log.info(ret)
        self.store.add(self.server_conn, alias=alias)

    def start_tcp_iperf_server(
            self, pc_info, port, log_file, alias='server_default', **variables):
        """This keyword start tcp iperf server.
        :param pc_info: list as [ip, user, pwd]
        :param port: The server port for the server to listen on and the client to connect to.
        :param log_file: Redirect output to given file.
        :param conn_num: The number of connections to handle by the server before closing. Default is 0.
        :param report_interval: Sets the interval time in seconds between periodic bandwidth, jitter, and loss reports.
        :param output_format: A letter specifying the format to print bandwidth numbers in. Supported formats are
        :param buffer_length: The length of buffers to read or write. It works by writing array of len bytes a number.
        :param window_size: Sets the socket buffer sizes to the specified value. For TCP, this set the TCP window size.
        :param bind_host: Bind to host, one of this machine's addresses. For the client this set the outbound interface
        :param client_num: number of client limit to connect
        :param no_delay: Set the TCP no delay option, disabling Nagle's algorithm.
        :param mss: Attempt to set the TCP maximum segment size (MSS) via the TCP_MAXSEG option.
        :param ipv6: Bind to an IPv6 address

        note: output_format see start_udp_iperf_server for reference

        ::Example
            ${pc_info}    create list    10.140.160.226    tdlte-tester    btstest    23
            start_tcp_iperf_server    ${pc_info}    5005   iperf.log    bind_host=192.168.255.126
        """
        conn_num = variables.get("conn_num", None)
        report_interval = variables.get("interval", None)
        output_format = variables.get("output_format", None)
        buffer_length = variables.get("buffer_length", None)
        window_size = variables.get("window_size", None)
        no_delay = variables.get("no_delay", None)
        bind_host = variables.get("bind_host", None)
        client_num = variables.get("client_num", None)
        # max segment size
        mss = variables.get("mss", None)
        ipv6 = variables.get("ipv6", None)

        iperf_cmd_main = ' -s -p %s%s%s%s%s%s%s%s%s%s%s' % \
            (port,
             " -i %s" % (report_interval if report_interval else "1"),
             " -P %s" % (conn_num if conn_num else "0"),
             " -f %s" % (output_format if output_format else "k"),
             " -l %s" % buffer_length if buffer_length else "",
             " -w %s" % window_size if window_size else "",
             " -c %s" % client_num if client_num else "",
             " -M %s" % mss if mss else "",
             " -N" if no_delay else "",
             " -B %s" % bind_host if bind_host else "",
             " -V" if ipv6 else "")
        if int(pc_info[-1]) == 22 and pc_info[-2] != 'Nokia123!':
            self.server_conn = SshConnection(*pc_info)
            self.server_conn._setup()
            iperf_cmd = "/usr/bin/nohup iperf" + iperf_cmd_main + \
                " >%s 2>&1 0</dev/null &" % log_file
            self._iperf_server_kill_ssh(port)
            log.info(iperf_cmd)
            self.server_conn.execute(iperf_cmd)
        elif int(pc_info[-1]) == 23:
            self.server_conn = TelnetClient(*pc_info)
            self._server_kill_cmd_win(port, self.server_conn)
            ret = self.server_conn.execute(self.get_lib_path_cmd)
            lib_path = self._get_lib_path("".join(list(ret)))
            cmd_pre = '"%s" -i -d python "%s" "%s"' % (os.path.join(lib_path, "psexec.exe"),
                                                       os.path.join(lib_path, "iperf_mgr.py"),
                                                       os.path.join(lib_path, 'iperf.exe'))
            cmd_end = ' -o "%s"' % log_file
            iperf_cmd = cmd_pre + iperf_cmd_main + cmd_end
            self._server_kill_cmd_win(port, self.server_conn)
            log.info(iperf_cmd)
            self.server_conn.execute(iperf_cmd)
        else:
            self.server_conn = SshConnection(*pc_info, prompt='>')
            self.server_conn._setup()
            ret, rc, er = self.server_conn.execute(self.get_lib_path_cmd)
            lib_path = self._get_lib_path(ret)
            cmd_pre = '%s -i 2 -d -u noklab\\%s -p %s python %s %s' % (os.path.join(lib_path, "psexec.exe"),
                                                                       pc_info[1],
                                                                       pc_info[2],
                                                                       os.path.join(lib_path, "iperf_mgr.py"),
                                                                       os.path.join(lib_path, 'iperf.exe'))
            cmd_end = ' -o "%s"' % log_file
            iperf_cmd = cmd_pre + iperf_cmd_main + cmd_end
            self._server_kill_cmd_win(port, self.server_conn)
            log.info(iperf_cmd)
            ret, err, rc = self.server_conn.execute(iperf_cmd)
            log.info(ret)
        self.store.add(self.server_conn, alias=alias)

    def start_udp_iperf_client(self,
                               pc_info,
                               server_addr,
                               port,
                               band_width,
                               duration="2h",
                               alias='client_default',
                               **variables):
        """This keyword start udp iperf client.
        :param pc_info: list as [ip, user, pwd]
        :param server_addr: the iperf server ip address
        :param port: The server port for the server to listen on and the client to connect to.
        :param band_width: The UDP bandwidth to send at, in bits/sec. This implies the -u option. Default is 1 Mbit/sec
        :param duration: the total transmit duration or size(need give a size unit)
        :param log_file: Redirect output to given file.
        :param parallel: The number of connections to handle by the server before closing. Default is 0.
        :param report_interval: Sets the interval time in seconds between periodic bandwidth, jitter, and loss reports.
        :param output_format: A letter specifying the format to print bandwidth numbers in. Supported formats are
        :param buffer_size: Sets the socket buffer sizes to the specified value. For TCP, this sets the TCP window size
        :param packet_size: The length of buffers to read/write. It works by writing array of len bytes number of times
        :param bind_host: Bind to host, one of this machine's addresses. For the client this set the outbound interface
        :param dual_test: Run Iperf in dual testing mode. This will cause server to connect to client on port specified
        :param trade_test: Run Iperf in tradeoff mode. This will cause server reconnect to client on port specified
        :param ttl: The time-to-live for outgoing multicast packets. This is the number of router hops to go through,
        :param ipv6: Bind to an IPv6 address

        note: output_format see start_udp_iperf_server for reference

        ::Example
            ${pc_info}    create list    10.140.160.226    tdlte-tester    btstest    23
            start_udp_iperf_client  ${pc_info}    10.69.71.113  5005  20  dual_test=${true}
        """
        parallel = variables.get("parallel", None)
        parallel = " -P %s" % parallel if parallel else ""
        report_interval = variables.get("interval", None)
        output_format = variables.get("output_format", None)
        output_format = " -f %s" % output_format if output_format else ""
        packet_size = variables.get("packet_size", None)
        packet_size = " -l %s" % packet_size if packet_size else ""
        buffer_size = variables.get("buffer_size", None)
        buffer_size = " -w %s" % buffer_size if buffer_size else ""
        bind_host = variables.get("bind_host", None)
        bind_host = " -B %s" % bind_host if bind_host else ""
        dual_test = variables.get("dual_test", None)
        trade_test = variables.get("trade_test", None)
        ttl = variables.get("ttl", None)
        ttl = " -T %s" % ttl if ttl else ""
        ipv6 = variables.get("ipv6", None)
        ipv6 = " -V" if ipv6 else ""

        # add for client log
        log_file = variables.get("log_file", None)
        if (dual_test is not None) or (trade_test is not None):
            dual_port = 58899
            dual_trade = "%s%s -L %s" % (" -d" if dual_test else "",
                                         " -r" if trade_test else "",
                                         dual_port)
        else:
            dual_trade = ""
        transmit_size = variables.get("transmit_size", None)
        if transmit_size is not None:
            transmit = " -n %s" % transmit_size
        else:
            transmit = " -t %s" % timestr_to_secs(duration)
        if band_width is not None:
            band_width_option = " -b %s" % band_width if band_width[-1] \
                in ["K", "M"] else " -b %sM" % float(band_width)
        else:
            band_width_option = " -b 1M"

        iperf_cmd = ' -c %s -u -p %s%s%s%s%s%s%s%s%s%s%s%s' % \
            (server_addr, port, band_width_option, packet_size, buffer_size, transmit,
             " -i %s" % (report_interval if report_interval else "1"),
             parallel, output_format, dual_trade, bind_host, ttl, ipv6
             )
        if int(pc_info[-1]) == 22 and pc_info[-2] != 'Nokia123!':
            self.client_conn = SshConnection(*pc_info)
            self.client_conn._setup()
            self._iperf_client_kill_ssh(pc_info[0], port)
            iperf_cmd = "/usr/bin/nohup iperf" + iperf_cmd + \
                " >%s 2>&1 0</dev/null &" % log_file
            log.info(iperf_cmd)
            self.client_conn.execute(iperf_cmd)
        elif int(pc_info[-1]) == 23:
            self.client_conn = TelnetClient(*pc_info)
            ret = self.client_conn.execute(self.get_lib_path_cmd)
            lib_path = self._get_lib_path(ret)
            cmd_pre = '"%s" -i -d "%s"' % (os.path.join(lib_path, "psexec.exe"),
                                           os.path.join(lib_path, 'iperf.exe'))
            iperf_cmd = cmd_pre + iperf_cmd
            self._iperf_client_kill_telnet(pc_info[0], port)
            log.info(iperf_cmd)
            self.client_conn.execute(iperf_cmd)
        else:
            self.client_conn = SshConnection(*pc_info, prompt='>')
            self.client_conn._setup()
            ret, rc, er = self.server_conn.execute(self.get_lib_path_cmd)
            lib_path = self._get_lib_path(ret)
            cmd_pre = '%s -i 2 -d -u noklab\\%s -p %s  %s' % (os.path.join(lib_path, "psexec.exe"),
                                                              pc_info[1],
                                                              pc_info[2],
                                                              os.path.join(lib_path, 'iperf.exe'),)
            iperf_cmd = cmd_pre + iperf_cmd
            self._iperf_client_kill_telnet(pc_info[0], port)
            log.info(iperf_cmd)
            ret, err, rc = self.client_conn.execute(iperf_cmd)
            log.info(ret)
        self.store.add(self.client_conn, alias=alias)

    def start_udp_iperf_client_on_dynamic_server(self,
                                                 ue_ip_addr,
                                                 band_width,
                                                 port=5005,
                                                 duration="1h",
                                                 packet_size="1024.0B",
                                                 wait_timeout="300s"):
        """This keyword start udp iperf client on dynamic server.
        :param ue_ip_addr: the ue ip address
        :param band_width: The UDP bandwidth to send at, in bits/sec. This implies the -u option. Default is 1 Mbit/sec
        :port: The server port for the server to listen on and the client to connect to.
        :param duration: the total transmit duration
        :param packet_size: The length of buffers to read or write.
        :param wait_timeout: wait dynamic server timeout.
        ::Example
        start_udp_iperf_client_on_dynamic_server    10.69.71.113    100M    5005    2m
        """
        dspatch_server = '10.108.183.53'
        server_port = '8080'
        url1 = "http://{}:{}/task/?ue_ip={}&throughput={}& port = {} & ".format(
               dspatch_server, server_port, ue_ip_addr, band_width, port)
        url = url1 + "duration = {} & protocol = UDP & packet_size = {} & timeout = {}".format(
              duration, packet_size, wait_timeout)
        requests.get(url)

    def start_tcp_iperf_client(self,
                               pc_info,
                               server_addr,
                               port,
                               duration=1800,
                               alias='client_default',
                               **variables):
        """This keyword start tcp iperf client.
        :param server_addr: the iperf server ip address
        :param port: The server port for the server to listen on and the client to connect to.
        :param duration: the total transmit duration or size(need give a size unit)
        :param log_file: Redirect output to given file.
        :param parallel: The number of connections to handle by the server before closing. Default is 0
        :param report_interval: Sets the interval time in seconds between periodic bandwidth, jitter, and loss reports.
        :param output_format: A letter specifying the format to print bandwidth numbers in. Supported formats are
        :param buffer_length: Sets the socket buffer sizes to the specified value. For TCP, sets the TCP window size.
        :param window_size: The length of buff to read/write. It works by writing array of len bytes a number of times.
        :param bind_host: Bind to host, one of this machine's addresses. For the client this set the outbound interface
        :param dual_test: Run Iperf in dual testing mode. This will cause the server to connect back to
        :param trade_test: Run Iperf in tradeoff testing mode. This will cause the server to connect back to the client
        :param ttl: The time-to-live for outgoing multicast packets.
        :param no_delay: Set the TCP no delay option, disabling Nagle's algorithm.
        :param mss: Attempt to set the TCP maximum segment size (MSS) via the TCP_MAXSEG option.
        :param ipv6: Bind to an IPv6 address

        note: output_format see start_udp_iperf_server for reference

        ::Example
            ${pc_info}    create list    10.140.160.226    tdlte-tester    btstest    23
            start_tcp_iperf_client  ${pc_info}    10.69.71.1  5005  dual_test=${true}
        """
        parallel = variables.get("parallel", None)
        report_interval = variables.get("interval", None)
        output_format = variables.get("output_format", None)

        buffer_length = variables.get("buffer_length", None)
        window_size = variables.get("window_size", None)
        mss = variables.get("mss", None)
        print_mss = variables.get("print_mss", None)
        no_delay = variables.get("no_delay", None)

        bind_host = variables.get("bind_host", None)
        dual_test = variables.get("dual_test", None)
        trade_test = variables.get("trade_test", None)
        ttl = variables.get("ttl", None)
        ipv6 = variables.get("ipv6", None)
        # added for client log file
        log_file = variables.get("log_file", None)
        if (dual_test is not None) or (trade_test is not None):
            dual_port = 58899
            dual_trade = "%s%s -L %s" % (" -d" if dual_test else "",
                                         " -r" if trade_test else "",
                                         dual_port)
        else:
            dual_trade = ""
        transmit_size = variables.get("transmit_size", None)
        if transmit_size is not None:
            transmit = " -n %s" % transmit_size
        else:
            transmit = " -t %s" % duration

        iperf_cmd = ' -c %s -p %s%s%s%s%s%s%s%s%s%s%s%s%s%s' % \
            (server_addr,
             port,
             " -l %s" % buffer_length if buffer_length else "",
             " -w %s" % window_size if window_size else "",
             " -M %s" % mss if mss else "",
             " -N" if no_delay else "",
             transmit,
             " -i %s" % (report_interval if report_interval else "1"),
             " -P %s" % (parallel if parallel else "1"),
             " -f %s" % (output_format if output_format else "k"),
             dual_trade,
             " -m" if print_mss else "",
             " -B %s" if bind_host else "",
             " -T %s" % (ttl if ttl else "1"),
             " -V" if ipv6 else "",
             )
        if int(pc_info[-1]) == 22 and pc_info[-2] != 'Nokia123!':
            self.client_conn = SshConnection(*pc_info)
            self.client_conn._setup()
            iperf_cmd = "/usr/bin/nohup iperf" + iperf_cmd + \
                " >%s 2>&1 0</dev/null &" % log_file
            self._iperf_client_kill_ssh(pc_info[0], port)
            log.info(iperf_cmd)
            self.client_conn.execute(iperf_cmd)
        elif int(pc_info[-1]) == 23:
            self.client_conn = TelnetClient(*pc_info)
            ret = self.client_conn.execute(self.get_lib_path_cmd)
            lib_path = self._get_lib_path(ret)
            cmd_pre = '"%s" -i -d "%s"' % (os.path.join(lib_path, "psexec.exe"),
                                           os.path.join(lib_path, 'iperf.exe'))
            iperf_cmd = cmd_pre + iperf_cmd
            self._iperf_client_kill_telnet(pc_info[0], port)
            log.info(iperf_cmd)
            self.client_conn.execute(iperf_cmd)

        else:
            self.client_conn = SshConnection(*pc_info, prompt='>')
            self.client_conn._setup()
            ret, rc, er = self.server_conn.execute(self.get_lib_path_cmd)
            lib_path = self._get_lib_path(ret)
            cmd_pre = '"%s" -i 2 -d -u noklab\\%s -p %s "%s"' % (os.path.join(lib_path, "psexec.exe"),
                                                                 pc_info[1],
                                                                 pc_info[2],
                                                                 os.path.join(lib_path, 'iperf.exe'),)
            iperf_cmd = cmd_pre + iperf_cmd
            self._iperf_client_kill_telnet(pc_info[0], port)
            log.info(iperf_cmd)
            ret, err, rc = self.client_conn.execute(iperf_cmd)
            log.info(ret)
        self.store.add(self.client_conn, alias=alias)

    def _iperf_server_kill_ssh(self, port):
        content = self.server_conn.execute("ps -ef | grep iperf")
        log.info(content)
        if 'is not recognized' in content[1]:
            return False
        for con in content[0].splitlines():
            if re.search("iperf.*-s.*-p %s" % port, con):
                pid = con.split()[1]
                log.info(
                    "find client process pid is %s \nin '%s'\nExecute 'kill -9 %s'" %
                    (pid, con, pid))
                self.server_conn.execute("kill -9 %s" % pid)
                return True

    def stop_iperf_server(self, port, alias='server_default'):
        """This keyword stop iperf server.
        :param port: if port given will stop specfiecd server with this port , else stop all iperf server

        ::Example
            stop_iperf_server  5005
        """
        self.server_conn = self.store.get(alias)
        log.info(self.server_conn)
        if 'ssh' in str(self.server_conn):
            if not self._iperf_server_kill_ssh(port):
                self._server_kill_cmd_win(port, self.server_conn)
        else:
            self._server_kill_cmd_win(port, self.server_conn)
        self.store.remove(alias=alias)

    def _iperf_client_kill_ssh(self, server_ip, port):
        content = self.client_conn.execute("ps -ef | grep iperf")
        log.info(content)
        if 'is not recognized' in content[1]:
            return False
        for con in content[0].splitlines():
            if re.search("iperf.*-c %s.*-p %s" % (server_ip, port), con):
                pid = con.split()[1]
                log.info(
                    "find client process pid is %s \nin '%s'\nExecute 'kill -9 %s'" %
                    (pid, con, pid))
                self.client_conn.execute("kill -9 %s" % pid)
                return True

    def _iperf_client_kill_telnet(self, server_ip, port):
        query = "iperf*-c %s*-p %s" % (server_ip, port)
        kill_cmd = 'C:/WINDOWS/System32/Wbem/wmic process where \
"commandline like \'%%%s%%\' and not commandline like \'%%wmic%%\'" delete' % query.replace('*', '%')
        self.client_conn.execute(kill_cmd)

    def stop_iperf_client(self, server_ip, port, alias="client_default"):
        """This keyword stop iperf client.

        :param server_ip: iperf server ip
        :param port: iperf server port

        ::Example
           stop_iperf_server  10.140.160.226    5005
        """
        self.client_conn = self.store.get(alias)
        if 'ssh' in str(self.client_conn):
            if not self._iperf_client_kill_ssh(server_ip, port):
                self._iperf_client_kill_telnet(server_ip, port)
        else:
            self._iperf_client_kill_telnet(server_ip, port)
        self.store.remove(alias=alias)

    def _handle_raw_data(self, raw_throughput_list):
        throughput_dict = {}
        thread_dict = {}

        for a_throughput_match in raw_throughput_list:
            if a_throughput_match[1] not in throughput_dict.keys():
                throughput_dict[a_throughput_match[1]] = a_throughput_match[2]
                thread_dict[a_throughput_match[1]] = [a_throughput_match[0]]

            elif (a_throughput_match[1] in throughput_dict.keys()) and \
                 (a_throughput_match[0] not in thread_dict[a_throughput_match[1]]):
                throughput_dict[a_throughput_match[1]] += a_throughput_match[2]
                thread_dict[
                    a_throughput_match[1]].append(
                    a_throughput_match[0])

            elif (a_throughput_match[1] in throughput_dict.keys()) and \
                 (a_throughput_match[0] in thread_dict[a_throughput_match[1]]):
                throughput_dict[a_throughput_match[1]] = a_throughput_match[2]
                thread_dict[a_throughput_match[1]] = [a_throughput_match[0]]
        return throughput_dict

    def get_iperf_throughput(self, server_output, allvalue=False):
        """This keyword returns the average throughput.

        | Input Parameters | Man. | Description |
        :param server_output: Iperf Serve output file
        :param allvalue: if False return average value, if True return max/min/avg value
        :return: value

        ::Example
            ${result}   Iperf Get Throughput   C:\\iperf_out.log
            Run Keyword If     0==${result}   Fail  v alue is zero

        Note:
        First 10% and last 5% throughput lines (by timestamp) in input file will NOT be calculated into output.
        """
        lines = FileCommon.read_file(server_output, return_mode="string")

        max_throughput = 0
        min_throughput = 0
        average_throughput = 0
        result_throughput_list = []
        pattern = r'\[\s*(\d+)\]\s+([0-9.]+\s*-\s*[0-9.]+)\s+sec\s+[0-9.]+\s+\w+\s+([0-9.]+)\s+\w+/sec'

        p_single = re.compile(pattern, re.M)

        ret_single = p_single.findall(lines)
        raw_throughput_list = []
        print('*INFO* total throughput lines in file %s : %d' % (server_output, len(ret_single)))
        for match in ret_single:
            second_space = [float(item.strip())
                            for item in match[1].split('-')]
            if second_space[1] - second_space[0] != 1.0:
                continue
            else:
                raw_throughput_list.append((match[0],
                                            second_space[0],
                                            float(match[2])))
        del ret_single

        throughput_dict = self._handle_raw_data(raw_throughput_list)
        tmp_keys = sorted(throughput_dict.keys())
        sum_value = len(tmp_keys)
        if len(tmp_keys) == 1:
            result_throughput_list.append(throughput_dict[tmp_keys[0]])
        else:
            for idx in range(sum_value):
                if idx + 1 < sum_value * 0.1 or idx + 1 > sum_value * 0.95:
                    continue
                else:
                    if throughput_dict[tmp_keys[idx]] == 0:
                        print(tmp_keys[idx], throughput_dict[tmp_keys[idx]])
                    result_throughput_list.append(
                        throughput_dict[tmp_keys[idx]])

        if len(result_throughput_list) > 0:
            max_throughput = '%.2f' % max(result_throughput_list)
            min_throughput = '%.2f' % min(result_throughput_list)
            average_throughput = '%.2f' % float(sum(result_throughput_list) /
                                                len(result_throughput_list))

        print('*DEBUG*AVERAGE_THROUGHPUT = %s' % average_throughput)
        print('*DEBUG*MAXIMUM_THROUGHPUT = %s' % max_throughput)
        print('*DEBUG*MINIMUM_THROUGHPUT = %s' % min_throughput)
        return average_throughput if (not allvalue) else \
            [max_throughput, min_throughput, average_throughput]

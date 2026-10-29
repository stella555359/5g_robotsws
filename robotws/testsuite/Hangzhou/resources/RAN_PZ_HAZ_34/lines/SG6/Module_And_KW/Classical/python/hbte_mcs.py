# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import time
import logging
import telnetlib
import six
import re
import os
import sys
import socket
from robot.api import logger
from robot.api.deco import keyword
# from robot.libraries.BuiltIn import BuiltIn


class Device_HBTE(object):

    def __init__(self, host, port=23) -> None:
        self.host = host
        self.port = port
        self.mcs_conn = None

    def connect(self):
        self.mcs_conn = telnetlib.Telnet(self.host, self.port, 5)

    def execute_mcs_command(self, command='', timeout=1, prompt=b'OK'):
        logger.info('Execute MCS command:  {}'.format(command))
        self.mcs_conn.write(six.b(command + '\r\n'))
        if prompt:
            output = self.mcs_conn.read_until(prompt, timeout).decode()
            # BuiltIn().log_to_console(output)
        else:
            time.sleep(timeout)
            output = self.mcs_conn.read_very_eager().decode()
        if 'fail' in output.lower():
            raise Exception('MCS command failed: {}'.format(output))
        logger.info('MCS command response: {}'.format(output))
        return output

    def login(self, username='USER 1'):
        return self.execute_mcs_command('LOGIN:{}'.format(username))

    def force_free_channel(self):
        return self.execute_mcs_command('forcefree')

    def get_system_info(self):
        return self.execute_mcs_command('query:info')

    def alloc_channel(self, channelid):
        return self.execute_mcs_command(f'set:alloc:channel:{channelid}')

    def read_from_csv(self, csv_filename):
        m_phase = []
        from types import SimpleNamespace
        if os.path.exists(csv_filename):
            lines = open(csv_filename).read().splitlines()[2:]
            for rownum, line in enumerate(lines):
                for colnum, value in enumerate([x for x in line.split(',') if x.strip()]):
                    m_phase.append(SimpleNamespace(col=colnum, row=rownum, value=float(value)))
        return m_phase

    def set_with_matrix(self, mode, m_phase):
        for colnum in range(16):
            points = [x for x in m_phase if x.col == colnum]
            cmd = ''
            for point in points:
                cmd += f'{point.row+1},{point.col+1},{point.value};'
            if mode.lower() == 'phase':
                cmd = 'set:phase:' + cmd
            else:
                cmd = 'set:att:' + cmd
            cmd = cmd[:-1]
            # self.alloc_channel(colnum + 1)
            self.execute_mcs_command(cmd, timeout=10)

    def config_mcs_with_csv_file(self, phase_file='', att_file=''):
        self.force_free_channel()
        self.execute_mcs_command('set:alloc:channel:' + ';'.join([str(x) for x in list(range(1, 17))]))

        if phase_file:
            m_phase = self.read_from_csv(phase_file)
            self.set_with_matrix('phase', m_phase)
        if att_file:
            m_att = self.read_from_csv(att_file)
            self.set_with_matrix('att', m_att)

    def close(self):
        if self.mcs_conn:
            self.mcs_conn.close()


class hbte_mcs(object):

    """
    This library will provide HBTE MCS Operation
    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'

    def __init__(self):
        pass

    @keyword
    def rrm_config_hbte_mcs_from_csv(self, host, phase_file='', att_file=''):
        """
        This keyword will change HBTE MCS phase/att.

        | Parameter | Type | Man. | Default | Description |
        | host | string | Y | None | IP address of MCS |
        | phase_file | string | Y | None | filename of phase csv file |
        | att_file | string | Y | None | filename of att csv file |

        *Examples:*
        | rrm_config_hbte_mcs_from_csv | 10. |
        | Start To Capture Bip Log With Gnb Tool | log_dire=/tmp/mybiplog | password=ute |
        | Start To Capture Bip Log With Gnb Tool | log_dire=/tmp/mybiplog | dest_ip=10.108.231.212 |
        | Start To Capture Bip Log With Gnb Tool | log_dire=/tmp/mybiplog | add_options=-t5 -c 2 |

        *Return:* None
        """
        device = Device_HBTE(host)
        device.connect()
        try:
            device.login()
            device.config_mcs_with_csv_file(phase_file, att_file)
        finally:
            device.close()

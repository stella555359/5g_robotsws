# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: None
:contact: None
"""
import re
import os
from time import sleep
import logging as log
import taf.transport.ssh as csn


class FeatureLog(object):
    """enable bts ssh and rdport"""

    def __init__(self):
        self.ssh = csn.ssh()

    def _execute(self, cmd, connection):
        log.info('>>%s' % cmd)
        ret = self.ssh.execute(cmd, connection=connection)
        log.info(ret)
        return ret

    def _get_side(self):
        ret = self._execute('ls /tftpboot', connection='gnb')
        left_side = ['1', '2', '3']
        right_side = ['5', '6', '7']
        current_slot = list(set([r for r in ret.strip()]))
        side = 5
        tmp_left = [val for val in left_side if left_side in current_slot]
        if len(tmp_left) > 0:
            side = 1
        return side

    def active_l2ps_feature_debug_traces(self, flag_list,
                                         gnb_host='192.168.255.1',
                                         gnb_user='toor4nsn',
                                         gnb_pwd='oZPS0POrRieRtu',
                                         remote_host='127.0.0.1',
                                         remote_user='ute',
                                         remote_pwd='ute'
                                         ):
        """
        :param flag_list: such as ['level=DBG', 'L2.L2_PS.DEBUG=1']
        :param gnb_host: such as '192.168.255.1'
        :param gnb_user: username such as 'toor4nsn'
        :param gnb_pwd: password such as 'oZPS0POrRieRtu'
        :param remote_host: such as '127.0.0.1'
        :param remote_user: such as 'ute'
        :param remote_pwd: such as 'ute'

        Example:
        | ${content}        |     create list   |   level=DBG   |    L2.L2_PS.DEBUG=1   |
        | active_l2ps_feature_debug_traces |     ${content}     |
        """
        flag_list.append('\r\n')
        f_name = 'feature_log_activation.txt'
        local_path = "/tmp/%s" % f_name
        with open(local_path, 'w+') as fobj:
            fobj.writelines(flag_list)

        self.ssh.connect_to(
            hostname=remote_host,
            username=remote_user,
            password=remote_pwd,
            alias='pc')
        self.ssh.connect_to(
            hostname=gnb_host,
            username=gnb_user,
            password=gnb_pwd,
            alias='gnb',
            proxy='pc')
        side = self._get_side()
        tgt_folder = '/ffs/run/swpool/L2RT/addons'
        self._execute('rm %s/*' % tgt_folder, connection='gnb')
        cmd = 'rm /ffs/run/boardcfg/%s/A/mcu-aspd/addons/trace.tgz' % (side)
        self._execute(cmd, connection='gnb')
        self._execute(cmd.replace('.tgz', '.tgz.p7'), connection='gnb')

        ret = self._execute('cd /tmp;mkdir -p var/preserve/', connection='gnb')
        self.ssh.upload_file(
            local_path=local_path,
            remote_path='/tmp/var/preserve/%s' %
            f_name,
            connection='gnb')
        self._execute('ls /tmp/var/preserve/', connection='gnb')
        self._execute('cat /tmp/var/preserve/%s' % f_name, connection='gnb')

        cmd = 'cd /tmp;tar czf trace.tgz var/preserve/feature_log_activation.txt'
        ret = self._execute(cmd, connection='gnb')

        ret = self._execute('mkdir -p %s' % tgt_folder, connection='gnb')
        self._execute('mv /tmp/trace.tgz %s' % tgt_folder, connection='gnb')
        self._execute('crasign %s/trace.tgz' % tgt_folder, connection='gnb')

        cmd = 'ln %s/trace.tgz /ffs/run/boardcfg/%s/A/mcu-aspd/addons/trace.tgz' % (
            tgt_folder, side)
        self._execute(cmd, connection='gnb')
        self._execute(cmd.replace('.tgz', '.tgz.p7'), connection='gnb')
        self.ssh.disconnect(connection="gnb")
        self.ssh.disconnect(connection="pc")

    def _send_and_recv(self, cmd):
        self.channel.send(cmd + '\n')
        log.info("send -> %s" % cmd)
        sleep(0.5)
        ret = self.channel.recv(65535).decode()

        log.info("receive <- %s" % ret)
        return ret

    def check_l2ps_feature_debug_file_exist(self,
                                            gnb_host='192.168.255.1',
                                            gnb_user='toor4nsn',
                                            gnb_pwd='oZPS0POrRieRtu',
                                            remote_host='127.0.0.1',
                                            remote_user='ute',
                                            remote_pwd='ute'):
        """
        :param gnb_host: such as '192.168.255.1'
        :param gnb_user: username such as 'toor4nsn'
        :param gnb_pwd: password such as 'oZPS0POrRieRtu'
        :param remote_host: such as '127.0.0.1'
        :param remote_user: such as 'ute'
        :param remote_pwd: such as 'ute'

        Example:
        | check_l2ps_feature_debug_file_exist |

        """
        self.ssh.connect_to(
            hostname=remote_host,
            username=remote_user,
            password=remote_pwd,
            alias='pc')
        obj = self.ssh.connect_to(
            hostname=gnb_host,
            username=gnb_user,
            password=gnb_pwd,
            alias='gnb',
            proxy='pc')
        self.channel = obj.invoke_shell()
        self._send_and_recv('bsh 1:0')
        self._send_and_recv('lxc-attach -n 0x2730')
        ret = self._send_and_recv('cd /var/preserve/;ls')
        if 'feature_log_activation.txt' not in ret:
            raise Exception(
                'Not find feature_log_activation.txt file in /var/preserve')
        self.ssh.disconnect(connection="gnb")

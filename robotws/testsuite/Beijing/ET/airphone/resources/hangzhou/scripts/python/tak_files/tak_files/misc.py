# -*- coding: utf-8 -*-
"""
:created on: 12-20-2021
:copyright: Nokia
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia-sbell.com
"""
import os
import SSHLibrary


class Misc():
    'kinds of misc kw'

    def __init__(self):
        ''
        pass

    def get_latest_direcotory(self, host, usr, pwd, parent_folder, pattern):
        """This keyword gets latest modified directory in given parent directory.

        :param host: such as '192.168.255.1'
        :param usr: username such as 'toor4nsn'
        :param pwd: password such as 'oZPS0POrRieRtu'
        :param parent_folder: folder in host such as '/tmp/rat'
        :param pattern: key info of target folder 'special'
        :return: latest file path

        """
        ssh = SSHLibrary.SSHLibrary()
        ssh.open_connection(host)
        ret = ssh.login(usr, pwd)
        if 'indows' in ret:
            ret = ssh.execute_command('dir /AD /B /O-D "%s"' % parent_folder)
        else:
            ret = ssh.execute_command('ls -tl "%s"|awk \'{print $9}\'' % parent_folder)
        for i in ret.splitlines():
            if pattern in i:
                if '\\' in parent_folder:
                    return ('\\'.join([parent_folder, i])).replace('\\', '\\\\')
                else:
                    return '/'.join([parent_folder, i])
        raise Exception("Not find '%s', in '%s'" % (pattern, parent_folder))

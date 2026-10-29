#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:author: Pekka Lonnakko
:contact: pekka.lonnakko@nokia.com
"""

import os
import subprocess


class FlameInstallationFailed(Exception):
    pass


class InstallFlame(object):

    def install_flame(self):
        print('Installing Flame')
        log_directory = "/home/ute/"
        self._add_flame_source()
        self._install_flame(log_directory)

    def _add_flame_source(self):
        sources_list = '/etc/apt/sources.list.d/flame_repo.list'
        repository = 'http://iita.emea.nsn-net.net/debian'
        debian_version_name = self._get_debian_version_name()

        # Check if source already exists
        if os.path.isfile(sources_list):
            return

        subprocess.check_call('echo "deb [trusted=yes] {repository} {debian_version_name} main"'
                              ' | sudo tee {sources_list} > /dev/null'.format(
                                repository=repository,
                                debian_version_name=debian_version_name,
                                sources_list=sources_list
                                ), shell=True)

    def _get_debian_version_name(self):
        with open('/etc/debian_version', 'r') as debian_version_file:
            version = debian_version_file.read()
        major_version = int(version.split('.')[0])
        if major_version == 8:
            return 'jessie'
        elif major_version == 9:
            return 'stretch'
        elif major_version == 10:
            return 'buster'
        else:
            print("Could not determine Debian version. Using default value.")
            return 'stretch'

    def _install_flame(self, log_directory):
        # Apt update and install
        try:
            subprocess.check_call('sudo apt-get update >> {log_directory}/flame_install.log'.format(
                log_directory=log_directory
            ), shell=True)
            subprocess.check_call(
                'sudo apt-get install -y --force-yes flame5 >> {log_directory}/flame_install.log'.format(
                    log_directory=log_directory
                ), shell=True)
            subprocess.check_call(
                'sudo apt-get install -y --force-yes localconnectionserver >>'
                ' {log_directory}/flame_install.log'.format(
                    log_directory=log_directory
                ), shell=True)
        except subprocess.CalledProcessError:
            raise FlameInstallationFailed

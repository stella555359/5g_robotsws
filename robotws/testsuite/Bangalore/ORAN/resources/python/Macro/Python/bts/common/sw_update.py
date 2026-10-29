# -*- coding: utf-8 -*-
"""
Generic keywords for BTS software management.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""


import logging
import os
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.generic_bts import GenericBts, login_logout
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    helpers.sw_versions import SwVersionFactory


class GenericSwUpdate(GenericBts):
    """Base keywords software updates"""

    supported_bts_types = 'GNB', 'ENB'

    def __init__(self, bts_type):
        """
        Constructor of SwUpdate class.
        :param bts_type: GNB|ENB
        :return: None
        """
        if bts_type not in self.supported_bts_types:
            raise ValueError('{} is not a supported bts type'.format(bts_type))
        super(GenericSwUpdate, self).__init__(bts_type=bts_type)

    @login_logout
    def update_software(self, sw_package_dir, timeout=600, bts_id=0, du_id=0):
        """
        Updates bts software with given sw package
        :param timeout: timeout given in seconds for sw update operation
        :param sw_package_dir: directory with software package
        :param bts_id:  int
        :param du_id: int
        :return:
        """
        self.admin.update_software(sw_package_dir, timeout=int(timeout),
                                   connection=self.rest_alias.format(
                                       bts_id, du_id))

    def download_sw_package(self, sw_version, target_dir, by_nominal=False):
        """
        Downloads given software package to target_dir
        :param sw_version: software version in str format,
        eg: 'SBTS00_ENB_9999_210318_000011'
        :param target_dir: directory to which build should be downloaded: str
        :param by_nominal: if set to True sw_version is treated like in
        nominal form eg: nominal: 5G21A_11.800.1213
                           raw_sw_string: 5G21A_GNB_0011_000800_001213
        :return: path to software package
        """
        version_creator = SwVersionFactory.create_sw_version_from_nominal\
            if by_nominal else \
            SwVersionFactory.create_sw_version
        sw_version = version_creator(sw_version)
        if sw_version.get_package() in os.listdir(target_dir):
            logging.info('Software package {} already '
                         'in {}'.format(sw_version.get_package(),
                                        target_dir))
        else:
            os.system('wget -P {} {}'.format(target_dir, sw_version.url))
        return os.path.join(target_dir, sw_version.get_package())

    @login_logout
    def reset_configuration(self, bts_id=0, du_id=0):
        """
        Perform configuration reset
        :return:
        """
        self.admin.reset_configuration(
            connection=self.rest_alias.format(bts_id, du_id))

    def download_multiple_builds(self, builds, output_path):
        """
        Download multiple SW packages to output path
        :param sw_version: array with software version in str
        format, eg: 'SBTS00_ENB_9999_210318_000011'
        :param target_dir: directory to which build should be
         downloaded: str
        :return: array with paths to SW
        """
        downloaded_builds = []
        if not os.path.exists(output_path):
            os.makedirs(output_path)
        for build in builds:
            downloaded_builds.append(
                self.download_sw_package(sw_version=build,
                                         target_dir=output_path))
        return downloaded_builds


class EnbSwUpdate(GenericSwUpdate):
    """Class contains SCF keywords for eNB"""

    bts_type = 'ENB'

    def __init__(self):
        """
        Constructor of Enb class.

        """

        super(EnbSwUpdate, self).__init__(bts_type=GnbSwUpdate.bts_type)


class GnbSwUpdate(GenericSwUpdate):
    """Class contains SCF keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.

        """
        super(GnbSwUpdate, self).__init__(bts_type=GnbSwUpdate.bts_type)

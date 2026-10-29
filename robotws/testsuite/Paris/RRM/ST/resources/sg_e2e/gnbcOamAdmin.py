# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
"""

from taf.sbts.oam.coam.admin import admin
from robot.api import logger as logger
import re


class gnbcOamAdmin(object):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    __version__ = '1.0.0'

    def __init__(self):
        self._api = admin()

    def connect_to(self, bts_host='192.168.255.1', bts_port=443,
                   username='Nemuadmin', password='nemuuser'):
        self.connection = self._api.connect_to(
            bts_host=bts_host, bts_port=bts_port,
            username=username, password=password,
        )

    def teardown(self):
        self._api.teardown()

    def lock_cell(self, cell_id, timeout=30):
        cells = self.connection.get_cells_info()
        regex = r"\/{}$".format(cell_id)
        for cell in cells:
            match = re.search(regex, cell['id']['configuration'])
            if bool(match):
                self._api.lock_cell(dist_name=cell['id']['internal'], timeout=timeout)
                break
        else:
            logger.info('cell_id not found  %s' % cell_id)
            logger.info('cells info: %s' % cells)

    def unlock_cell(self, cell_id, timeout=30):
        cells = self.connection.get_cells_info()
        regex = r"\/{}$".format(cell_id)
        for cell in cells:
            match = re.search(regex, cell['id']['configuration'])
            if bool(match):
                self._api.unlock_cell(dist_name=cell['id']['internal'], timeout=timeout)
                break
        else:
            logger.info('cell_id %s not found' % cell_id)
            logger.info('cells info: %s' % cells)

    def load_BSR_file(self, sw_package, timeout=600):
        self.connection.update_software(sw_package=sw_package, timeout=timeout)

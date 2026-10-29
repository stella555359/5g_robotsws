"""
This module contains testline manager library for L2_KRK_1 test suite
:copyright: Nokia Networks
:author: Jakub Drabina  <jakub.drabina@nokia.com>
:maintainer: Jakub Drabina  <jakub.drabina@nokia.com>
"""
from robot.libraries.BuiltIn import BuiltIn
import taf.internal.wireshark.installation as wireshark
from bts_manager import VduAdmin


class testline_manager():
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.tl_config = BuiltIn().get_variable_value('${tl}')

    def install_mcshark_on_rinline(self):
        """Install mcshark plugin on rinline"""
        with VduAdmin(*self._get_vdu_credentials()) as vdu_admin:
            sw_version = vdu_admin.get_vdu_sw_version()
        wireshark.install_mcshark(build=sw_version)

    def _get_vdu_credentials(self):
        host = self.tl_config.gnbs[0].dus[0].oam_http_connection_details.addr
        port = self.tl_config.gnbs[0].dus[0].oam_http_connection_details.port
        username = self.tl_config.gnbs[0].dus[0].oam_http_connection_details.username
        password = self.tl_config.gnbs[0].dus[0].oam_http_connection_details.password
        return host, port, username, password

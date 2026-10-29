"""
vDU admin interface
:copyright: Nokia Networks
:author: Jakub Drabina  <jakub.drabina@nokia.com>
:maintainer: Jakub Drabina  <jakub.drabina@nokia.com>
"""
from taf.gnb.oam.coam.vdu import vdu as vdu_admin


class VduAdmin:
    def __init__(self, host, port, username, password, secure=True):
        self.vdu_instance = vdu_admin()
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.secure = secure

    def __enter__(self):
        self.vdu_connection = self.vdu_instance.connect_to(self.host,
                                                           self.port,
                                                           self.username,
                                                           self.password,
                                                           secure=self.secure)
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.vdu_instance.disconnect()

    def get_vdu_sw_version(self):
        """Get vDU software version from vDU admin"""
        sw_version = self.vdu_connection.get_vdu_state_data().software_version
        return self._convert_vdu_sw_version(sw_version)

    def get_vdu_state_data(self):
        """Get vDU state data from vDU admin"""
        return self.vdu_connection.get_vdu_state_data()

    @staticmethod
    def _convert_vdu_sw_version(sw_version):
        trunk_label = 'vDUCNF00'
        build = sw_version.split('_')[1]
        return f"{trunk_label}_{build}"

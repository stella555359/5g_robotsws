from taf.sbts.oam.coam.admin import admin as du_admin
from coam import *


class du_coam(coam):
    def __init__(self, host, port, username, password, alias='cOAM'):
        super(du_coam, self).__init__(locals())
        self.admin = du_admin()

    def connect(self):
        self.admin.connect_to(bts_host=self.host, bts_port=self.port, username=self.username,
                              password=self.password, name=self.alias)

    def disconnect(self):
        self.admin.teardown(connection=self.alias)

    def get_snapshot(self, path, coverage, timeout=300):
        self.admin.get_snapshot(
            target_file_name=path, coverage=coverage, timeout=timeout, connection=self.alias)

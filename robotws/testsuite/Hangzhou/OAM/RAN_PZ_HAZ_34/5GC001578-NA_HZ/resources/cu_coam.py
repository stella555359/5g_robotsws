from taf.gnb.oam.coam.cu import cu as cu_admin
from coam import *


class cu_coam(coam):
    def __init__(self, host, port, username, password, version='cuoam_19b', ssl=True, alias='cOAM'):
        super(cu_coam, self).__init__(locals())
        self.admin = cu_admin()

    def connect(self):
        self.admin.connect_to(host=self.host, port=self.port, username=self.username, password=self.password,
                              cu_version=self.version, secure=self.ssl, alias=self.alias)

    def disconnect(self):
        self.admin.disconnect(connection=self.alias)

    def get_snapshot(self, path, coverage, timeout=300):
        self.admin.get_local_snapshot(
            directory=path, operation_timeout=timeout, connection=self.alias)

from taf.sbts.oam.coam.admin import admin
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections


retry_timeout_seconds = 600


class AdminApi(admin):
    def __init__(self, **kwargs):
        release = kwargs.get('release', assign_release_version())
        super(AdminApi, self).__init__()
        self.connect_to(release=release, **kwargs)

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.teardown()


def assign_release_version():
    smod_conn = connections.connect_to_smod()
    _ssh = connections.ssh()
    version_file = _ssh.execute(command='ls /ffs/run/TargetBD*.xml', connection=smod_conn)
    return version_file.split()[-1].split('TargetBD_')[-1].split('_')[0]

from taf.sbts.oam.coam.admin import admin
import testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.resource.connections as connections


retry_timeout_seconds = 600


class AdminApi(admin):
    def __init__(self, ip, **kwargs):
        release = kwargs.get('release', assign_release_version(ip))
        super(AdminApi, self).__init__()
        self.connect_to(bts_host=str(ip), release=release, **kwargs)

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.teardown()


def assign_release_version(ip):
    smod_conn = connections.connect_to_smod(ip)
    _ssh = connections.ssh()
    version_file = _ssh.execute(command='ls /ffs/run/TargetBD*.xml', connection=smod_conn)
    return version_file.split()[-1].split('TargetBD_')[-1].split('_')[0]

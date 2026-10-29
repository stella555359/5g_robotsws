from taf.sbts.oam.coam.admin import admin as taf_admin

LOCALHOST = '127.0.0.1'


class AdminSession:
    def __init__(self, remote_host=LOCALHOST, remote_user='ute', remote_pass='ute', bts_ip='192.168.255.129'):
        self.admin = taf_admin()
        self.remote_host = remote_host
        self.user = remote_user
        self.password = remote_pass
        self.bts_ip = bts_ip

    def __enter__(self):
        self.admin.setup_admin(
            bts_host=self.bts_ip,
            remote_host=self.remote_host,
            remote_host_username=self.user,
            remote_host_password=self.password)
        return self.admin

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.admin.teardown_admin()


def get_scf_from_lte(output_dir, target_filename, vm_ip=LOCALHOST):
    with AdminSession(remote_host=vm_ip) as session:
        return session.get_current_scf_file(output_dir, target_filename, timeout=30)


def get_scf_from_nr(output_dir, target_filename, runtime=False):
    with AdminSession(remote_host=LOCALHOST) as session:
        if runtime:
            return session.get_current_scf_file(output_dir, target_filename,
                                                export_type='configurationAndRuntimeObjects', timeout=30)
        return session.get_current_scf_file(output_dir, target_filename, timeout=30)


def validate_scf_with_hw_and_nidd(scf_file):
    with AdminSession(remote_host=LOCALHOST) as session:
        session.validate_scf_online(scf_file)

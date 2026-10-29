from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from taf.config.scf import scf


class ScfManager(scf):
    def __init__(self, **kwargs):
        super(ScfManager, self).__init__()
        self.load_scf_file(**kwargs)

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return self

    def load_scf_file(self, scf_file=None):
        if not scf_file:
            scf_file = self.download_scf_file()
        self.load_scf(scf_file)

    def save_scf_file(self, scf_path='/tmp/new_scf.xml'):
        self.save_scf(scf_path)
        return scf_path

    @staticmethod
    def download_scf_file():
        api = AdminUtils()
        scf_file_path = api.download_current_scf(local_dir_path='/tmp',
                                                 file_name='scf_backup.xml')
        return scf_file_path

    @staticmethod
    def get_parameter_value_from_scf(self, param_to_get, scf_file=None, bts_host=None):
        bts_host = bts_host if bts_host else '192.168.255.1'
        admin_utils = AdminUtils(bts_host=bts_host)
        if not scf_file:
            scf_file = admin_utils.download_current_scf()
        self.load_scf(scf_file)
        if '/' in param_to_get:
            dist_name, param = param_to_get.rsplit('/', 1)
            value = self.get_value_from_scf(dist_name=dist_name, p_name=param)
        else:
            value = self.get_value_from_scf(p_name=param_to_get)
        return value

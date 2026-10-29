from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.resources.log.log import blog
from taf.config.scf import scf

msg = 'Parameter: {param}\nCurrent: {current_value}\nExpected: {expected_value}\n'
scf = scf()


def setup_and_check_preconditions_in_scf(params_to_check=None,
                                         scf_file=None,
                                         skip_parameter_relation_errors=False,
                                         bandwidth=None, bts_host=None):

    bts_host = bts_host if bts_host else '192.168.255.129'
    admin_utils = AdminUtils(bts_host=bts_host)


def check_expected_parameters():
    return False


def setup_expected_parameters(params_to_modify, cell_type):
    au = AdminUtils()
    cell_ids = au.get_all_cell_ids(cell_type='NRCEL')

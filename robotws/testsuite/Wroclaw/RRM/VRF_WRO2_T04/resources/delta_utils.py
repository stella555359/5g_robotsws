import os
from jinja2 import Template
from taf.config.scf import scf
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession, LOCALHOST
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import get_scf_from_nr
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir
from taf.config.scf.exceptions import MultipleMatches
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id


DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'jinja_templates')


def get_parameter_value(distname, parameter, list_name=None, scf_file=None, runtime=False, remove_scf=True):
    """
      Returns parameter value from scf
      :param str distname: object distname like: 'MRBTS-123/NRBTS-123/NRCELL-1
      :param str parameter: parameter to check
      :param str list_name: 'name' attribute in <list> tag, None is default value
      :param str scf_file: scf file to use
      :return: value for parameter
      :rtype: str
      :raises KeyError: if parameter not exists
      """
    target_path = scf_file or os.path.join(get_robot_output_dir(), '{}.xml'.format(parameter))
    if not os.path.exists(target_path):
        get_scf_from_nr(get_robot_output_dir(), '{}.xml'.format(parameter), runtime=runtime)
    s = scf()
    s.load_scf(target_path)
    try:
        value = s.get_value_from_scf(dist_name=distname, p_name=parameter, list_name=list_name)
    except MultipleMatches:
        value = s.get_all_values_from_scf(dist_name=distname, p_name=parameter, list_name=list_name)
    finally:
        if remove_scf and not scf_file:
            os.remove(target_path)
    return value


def update_parameter(parameter, value, distname=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}', remote_host=LOCALHOST):
    with AdminSession(remote_host=remote_host) as admin:
        admin.perform_parameter_recommissioning(parameter=parameter, value=value,
                                                dist_name=distname, operation='update')


def load_delta_template(filepath):
    delta_filepath = os.path.join(filepath)
    with open(delta_filepath) as f:
        return Template(f.read())

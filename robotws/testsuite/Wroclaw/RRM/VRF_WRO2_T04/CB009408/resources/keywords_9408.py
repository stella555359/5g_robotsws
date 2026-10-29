import os
from jinja2 import Template
from taf.config.scf import scf
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession, get_scf_from_nr
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.delta_utils import get_parameter_value, update_parameter
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import wait_until_function_succeeds, logged_keyword

LNADJGNB_DISTNAME_FORMAT = 'MRBTS-{}/NRBTS-{}/LNADJGNB-{}'
DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_templates')


def load_delta_template(filename):
    delta_filepath = os.path.join(DELTA_DIR, filename)
    with open(delta_filepath) as f:
        return Template(f.read())


@logged_keyword
def create_lnadjgnb_object(cplane_ip_addr=None, lnbts_id=None, ln_adj_id=0, gnb_id=mrbts_id, adj_gnb_id_length=22,
                           mcc=310,
                           mnc=260, mnc_length=3, ip_version='v4'):
    if not lnbts_id:
        lnbts_id = get_lnbts_id()

    cplane_ip_addr = cplane_ip_addr or get_cplane_ip_addr(gnb_id, version=ip_version)
    template = load_delta_template('add_lnadjgnb.json')
    delta = template.render(ln_adj_id=ln_adj_id, mrbts_id=mrbts_id, lnbts_id=lnbts_id, gnb_id=gnb_id,
                            adj_gnb_id_length=adj_gnb_id_length,
                            cplane_ip_addr=cplane_ip_addr, mcc=mcc,
                            mnc=mnc,
                            mnc_length=mnc_length)
    __perform_delta(delta)


def modify_gnb_id_in_scf(scf_file, new_gnb_id=51058, ln_adj_id=0):
    new_scf_filepath = os.path.join(get_robot_output_dir(), 'modified_gnb_id.xml')
    lnbts_id = get_lnbts_id()
    new_scf = scf()
    new_scf.load_scf(scf_file)
    new_scf.modify_scf_element(value=new_gnb_id, dist_name=f'MRBTS-{mrbts_id}/LNBTS-{lnbts_id}/LNADJGNB-{ln_adj_id}',
                               p_name='adjGnbId')
    new_scf.modify_scf_element(value='false', dist_name=f'MRBTS-{mrbts_id}/LNBTS-{lnbts_id}',
                               p_name='actEndcAutoX2SetupSbts')
    new_scf.save_scf(new_scf_filepath)
    return new_scf_filepath


def __perform_delta(delta_str):
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta_file=delta_str, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


def get_lnbts_id():
    with AdminSession() as admin:
        distnames = admin.get_ids_for_all('LNBTS')
    return distnames[0].split('-')[-1]


def get_cplane_ip_addr(gnb_id=mrbts_id, version='v4'):
    current_scf = get_scf_from_nr(get_robot_output_dir(), 'cplane_ip_addr_check.xml')
    distname = get_parameter_value(f'MRBTS-{gnb_id}/NRBTS-{gnb_id}', parameter=f'ip{version.upper()}AddressDN1',
                                   list_name='x2Cplane')
    ip = get_parameter_value(distname, parameter='localIpAddr', scf_file=current_scf)
    os.remove(current_scf)
    return ip


@wait_until_function_succeeds(retry_time_in_seconds=10, retry_interval_in_seconds=3)
def get_lnadjgnb_status(adj_gnb_id=0, parameter=None):
    lnbts_id = get_lnbts_id()
    return get_parameter_value(f'MRBTS-{mrbts_id}/LNBTS-{lnbts_id}/LNADJGNB-{adj_gnb_id}',
                               parameter=parameter, runtime=True)


@logged_keyword
def check_if_lnadjgnb_is_available(adj_gnb_id=0):
    assert get_lnadjgnb_status(adj_gnb_id, parameter='x2ToGnbLinkStatus') == 'available'


@logged_keyword
def check_if_lnadjgnb_is_unavailable(adj_gnb_id=0):
    assert get_lnadjgnb_status(adj_gnb_id, parameter='x2ToGnbLinkStatus') == 'unavailable'


@logged_keyword
def check_if_lnadjgnb_has_correct_parameter(parameter, expected_value, adj_gnb_id=0):
    assert get_lnadjgnb_status(adj_gnb_id, parameter=parameter) == expected_value


@logged_keyword
def check_if_lnadjgnb_exists(adj_gnb_id=0):
    current_scf = get_scf_from_nr(get_robot_output_dir(), 'check_lnadjgnb_existence.xml')
    lnbts_id = get_lnbts_id()
    s = scf()
    s.load_scf(current_scf)
    return s.is_object_in_scf(f'MRBTS-{mrbts_id}/LNBTS-{lnbts_id}/LNADJGNB-{adj_gnb_id}')


def check_if_LNRELGNBCELL_is_available(lnrel_id=255, lncel_id=14):
    lnbts_id = get_lnbts_id()
    return get_parameter_value(f'MRBTS-{mrbts_id}/LNBTS-{lnbts_id}/LNCEL-{lncel_id}/LNRELGNBCELL-{lnrel_id}',
                               parameter='nrStatus', runtime=True)


def remove_lnadjgnb_object(adj_gnb_id=0):
    lnbts_id = get_lnbts_id()
    with AdminSession() as admin:
        admin.perform_object_recommissioning(dist_name=f'MRBTS-{mrbts_id}/LNBTS-{lnbts_id}/LNADJGNB-{adj_gnb_id}',
                                             parameter=[],
                                             operation="delete")


def activate_9408_feature(lnbts_id=40896):
    update_parameter(parameter='actEndcAutoX2SetupSbts', value='true', distname=f'MRBTS-{mrbts_id}/LNBTS-{lnbts_id}')


def deactivate_9408_feature(lnbts_id=40896):
    update_parameter(parameter='actEndcAutoX2SetupSbts', value='false', distname=f'MRBTS-{mrbts_id}/LNBTS-{lnbts_id}')


def activate_dualstack_ip_for_s1_x2():
    update_parameter(parameter='actDualStackIpV4V6ForS1X2', value='true',
                     distname=f'MRBTS-{mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1')


def deactivate_dualstack_ip_for_s1_x2():
    update_parameter(parameter='actDualStackIpV4V6ForS1X2', value='false',
                     distname=f'MRBTS-{mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1')

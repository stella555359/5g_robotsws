import os
import socket
import random
import datetime
from zipfile import ZipFile
from robot.api import logger
from robot.running import context
from taf.transport.ssh import ssh
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.resources.rrm_fixture import (
    get_robot_variable, asik_password, asik_username, classical_asik_ip_address
)
from collections import namedtuple
from taf.transport.ssh import ConnectFailedError
from ute_common_admin.exception import AdminApiConnectionClosedException
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_utilities import get_sw_release_vdu
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import mrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl

ssh_lib = ssh()

RMOD = namedtuple('RMOD', ['configuration', 'internal'])
BBMOD = namedtuple('BBMOD', ['configuration', 'internal'])


def get_robot_output_dir():
    return get_robot_variable("${OUTPUT_DIR}")


def get_rel_name(refresh=False):
    if context.EXECUTION_CONTEXTS.current.dry_run:
        logger.debug("DRYRUN mode, keyword exec ignored.")
        return 'SBTS'
    if get_robot_variable('${sw release name}') and not refresh:
        return get_robot_variable('${sw release name}')
    with AdminSession() as admin:
        release_name = admin.get_sw_release_name()
        logger.info('release_name: {}'.format(release_name))
        BuiltIn().set_global_variable('${sw release name}', release_name)
        return release_name


def get_cm_execution_id():
    return os.environ.get("CM_EXECUTION_ID")


def is_it_manual_execution():
    return False if get_cm_execution_id() else True


def get_testline_name():
    short_name = socket.gethostname()[10:]
    full_name = socket.gethostname().replace('-', '_')
    return short_name, full_name


def get_scout_testline_name():
    return '{}_1'.format(get_testline_name()[1])


def get_mplane_address():
    address = get_robot_variable('${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}')
    return address.split('/')[0]


def is_smod_pingable():
    result = os.system('ping -c 1 {} > /dev/null'.format(classical_asik_ip_address))
    if result != 0:
        logger.debug("SMOD is not pingable!")
        return False
    logger.debug("SMOD is pingable")
    return True


def has_ssh_access():
    try:
        ssh_lib.connect_to(classical_asik_ip_address, asik_username, asik_password, alias='ssh_check')
        ssh_lib.disconnect(connection='ssh_check')
    except ConnectFailedError:
        logger.debug('SSH is not accessible!')
        return False
    logger.debug('SSH is working on SMOD!')
    return True


def get_timestamped_filename(logname):
    suffix = datetime.datetime.now().strftime("%d-%m-%Y-%H%M%S")
    return "{}_{}".format(logname, suffix)


def get_hostname():
    hostname = socket.gethostname()
    hostname = hostname.replace('-', '_')
    return hostname


def configure_lss_user(user='ute', password='uteUTE!'):
    with AdminSession() as admin:
        admin.configure_lss_account(lss_username=user, lss_password=password)


def is_release_higher(release):
    try:
        current_release = get_rel_name().replace('SBTS', '')
    except AdminApiConnectionClosedException:
        current_release = get_sw_release_vdu().replace('vDUCNF', '')
    logger.debug(current_release)
    return current_release >= release


def get_all_rmods_with_name(name):
    with AdminSession() as admin:
        return [RMOD(r['id']['configuration'], r['id']['internal'])
                for r in admin.get_detected_hw_info()['radioModules']["rmod"] if r['productName'] == name]


def get_all_rmods_distnames_with_name(name):
    rmods = get_all_rmods_with_name(name)
    return [rmod.configuration for rmod in rmods]


def get_all_cells_on_rmod(rmod_distname, technology):
    def format_cell_distname(distname):
        return f'MRBTS-{mrbts_id}/' + '/'.join(distname.replace('_R', '').split('/')[-2:])

    if technology.lower() == 'nr':
        cell_type = 'NR'
    elif technology.lower() == 'lte':
        cell_type = 'LN'
    else:
        raise RuntimeError("Unknown technology!")

    with AdminSession() as admin:
        return [format_cell_distname(distname) for distname in admin.get_cell_mapping_by_module_id(rmod_distname)
                if cell_type in distname]


def get_iot_cells():
    with AdminSession() as admin:
        return [cell['nbIoTCell']['name'].split()[0] for cell in admin.get_parameters_for_all('LNCEL')
                if cell['nbIoTCell']]


def select_random_cell_on_rmod(rmod_name, technology):
    all_rmods = get_all_rmods_with_name(rmod_name)
    all_rmods_distnames = [rmod.internal for rmod in all_rmods]
    random_rmod = random.choice(all_rmods_distnames)
    all_cells_on_rmod = get_all_cells_on_rmod(random_rmod, technology)
    iot_cells = get_iot_cells()
    filtered_cells = [cell for cell in all_cells_on_rmod if not any(name in cell for name in iot_cells)]
    random_cell_on_rmod = random.choice(filtered_cells)
    logger.info(f"Selected random CELL: {random_cell_on_rmod}", also_console=True)
    return random_cell_on_rmod


def get_all_bbmods_with_name(name):
    with AdminSession() as admin:
        return [BBMOD(distname['id']['configuration'], distname['id']['internal'])
                for distname in admin.get_detected_hw_info()['basebandModules']
                if name.lower() in distname['productName'].lower()]


def select_random_bbmod_with_name(name):
    random_bbmod = random.choice([bbmod.configuration for bbmod in get_all_bbmods_with_name(name)])
    logger.info(f"Selected random BBMOD: {random_bbmod}", also_console=True)
    return random_bbmod


def prepare_rmod_pdu_info_by_name(rmod_name):
    try:
        return [{
            rmod.serial_number: {
                "model": rmod.pdu_port.pdu.model,
                "host": rmod.pdu_port.pdu.addr,
                "port": rmod.pdu_port.port_no,
                "version": rmod.pdu_port.pdu.version
            }
        } for rmod in tl.gnbs[0].dus[0].rus if rmod.radio_type == rmod_name]
    except AttributeError:
        raise RuntimeError("Preparing RMOD-PDU info failed! Missing serial_number attribute for RMOD.")


def get_sn_for_rmods_by_name(name):
    with AdminSession() as admin:
        return [rmod['serialNumber'] for rmod in admin.get_parameters_for_all("RMOD") if rmod['productName'] == name]


def unzip_snapshot(snapshot_path, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    with ZipFile(snapshot_path, 'r') as logs:
        logs.extractall(output_dir)

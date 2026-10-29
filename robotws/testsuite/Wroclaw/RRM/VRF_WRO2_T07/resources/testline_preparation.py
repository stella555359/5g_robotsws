import os
import socket
import time
import subprocess
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
from taf.transport.ssh import ssh
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.exceptions import TimeoutError
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.swconfig import prepare_swconfig as tl_prep_swconfig
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import wait_until_function_succeeds, logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.pretty_printers import print_pretty_alarms, \
    print_pretty_radio_objects, print_pretty_cells, print_pretty_smods, print_pretty_bbmods, print_pretty_pdu
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from taf.sw.reporting_portal import reporting_portal
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.update_helpers import update_sw_using_admin, get_sw_version
from taf.hw.pdu import pdu
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


assert_msg = '\n'.join(["{message}", "Expected: {expected}", "But was: {current}"])
retry_timeout_seconds = 1500
ssh_host = tl.gnbs[0].cu.oam_http_connection_details.addr
sw_version = None


@logged_keyword
def inprint_active_sw_version_into_log_html():
    actual_build_name = assign_sw_version()
    try:
        BuiltIn().set_tags('SBTS_SW: {}'.format(actual_build_name))
    except RobotNotRunningError:
        pass


@logged_keyword
def prepare_cp_runtime_on_smod():
    _ssh = ssh()
    return _ssh.execute(command="echo -e \"[control]\nLoggingSeverity=trace\" > /ffs/run/cp_runtime.ini",
                        connection=connections.connect_to_smod())


@wait_until_function_succeeds(retry_time_in_seconds=retry_timeout_seconds, retry_interval_in_seconds=30)
@logged_keyword
def load_scf(scf_path, skip_relation_errors):
    with AdminApi() as web_api:
        web_api.perform_commissioning(scf_file=scf_path, skip_parameter_relation_errors=skip_relation_errors)


@wait_until_function_succeeds(retry_time_in_seconds=retry_timeout_seconds, retry_interval_in_seconds=10)
@logged_keyword
def wait_for_bbmod():
    with AdminApi() as web_api:
        hw_info = web_api.get_detected_hw_info()
        smods = hw_info['systemModules']
        bbmods = hw_info['basebandModules']
        print_pretty_smods(smods)
        print_pretty_bbmods(bbmods)
        check_for_incompatible_sw_on_radio(web_api)
        for bbmod in bbmods:
            assert bbmod['status'].get('availabilityStatus') in ['Online', None], assert_msg.format(
                message='BBMOD is not operational', expected='availabilityStatus: Online (or None)',
                current=bbmod['status'].get('availabilityStatus'))


@wait_until_function_succeeds(retry_time_in_seconds=retry_timeout_seconds, retry_interval_in_seconds=10)
@logged_keyword
def wait_for_ru():
    with AdminApi() as web_api:
        frm = web_api.get_frm()
        assert len(frm), 'Radio object not detected'
        print_pretty_radio_objects(frm)
        check_for_incompatible_sw_on_radio(web_api)
        for radio in frm:
            assert radio['status'].get('availabilityStatus') in \
                   ['Online', None, 'Degraded', 'degraded'], assert_msg.format(
                message='Not all radios are online', expected='availabilityStatus: Online',
                current=radio['status'].get('availabilityStatus'))


@wait_until_function_succeeds(retry_time_in_seconds=retry_timeout_seconds, retry_interval_in_seconds=10)
@logged_keyword
def wait_for_onair(cell_type='nr'):
    with AdminApi() as web_api:
        cells_info = web_api.get_cells_info(cell_type=cell_type)
        assert len(cells_info), 'Cells not detected'
        print_pretty_cells(cells_info)
        check_for_incompatible_sw_on_radio(web_api)
        for cell in cells_info:
            assert cell['status'].get('availabilityStatus') in \
                ['Online', None, 'Degraded', 'degraded'], assert_msg.format(
                message='Not all cells are online', expected='availabilityStatus: Online (or None)',
                current=cell['status'].get('availabilityStatus'))


@wait_until_function_succeeds(retry_time_in_seconds=retry_timeout_seconds, retry_interval_in_seconds=10)
@logged_keyword
def wait_for_x2_link_availability():
    with AdminApi() as web_api:
        assert len(web_api.get_managed_objects(class_name="LTEENB_R", timeout=30)), 'Object LTEENB_R not ready on BTS'
        for lteenb in web_api.get_managed_objects(class_name="LTEENB_R", timeout=30):
            assert lteenb['parameters']['x2LinkStatus'] == 'available', assert_msg.format(
                message='x2LinkStatus is not available', expected='x2LinkStatus: available',
                current=lteenb['parameters']['x2LinkStatus'])


@logged_keyword
def get_valid_hostname():
    hostname = socket.gethostname().replace('-', '_')
    assert not hostname.endswith('_'), "Hostname {} cannot end with a '-' or a '_'.".format(hostname)
    index = hostname.rfind('_')

    if hostname[index + 1:].isdigit():
        hostname = hostname[:index]
    return hostname


@logged_keyword
def get_config_dir(path=None):
    """Returns path to main dir where dirs with scf files should be,
    if path is provided it searches dir in [repo]/custom-config/[dir],
    else searches dir contains [tl_name] (f.e. [repo]/custom-config/[tl_name], [repo]/custom-config/Wro/[tl_name]"""
    directory = _validate_path("{}/custom-config".format(robot_globals.execdir()))
    if path:
        return _validate_path("{root}/{config}".format(root=directory, config=path))
    else:
        path = [x[0] for x in os.walk(directory) if x[0].endswith(get_valid_hostname())]
        assert len(path), "Can not resolve config dir, check if somewhere in {} is dir with TL name".format(directory)
        return path[0]


@logged_keyword
def resolve_scf_path(config_dir_name=None):
    """Looks for scf in custom-config dir in directory with TL name in dir with branch name,
    scf name is concatenation of tlname, branch and 5G string
    f.e. ...robotws5g/custom-config/Wroclaw/7_16_CLOUDT106/5G20B/7_16_CLOUDT106_5G20B_5G.xml"""
    config_dir = get_config_dir(path=config_dir_name)
    branch = get_sw_release_name()
    rat = ''
    try:
        rat = str(get_bts_id())[0]
    except Exception as e:
        blog("Error {} occured during getting bts id".format(e), level='ERROR')
        pass
    rat = rat if rat in ['4', '5'] else '5'
    file_name = '{}_{}_{}G.xml'.format(get_valid_hostname(), branch, rat)
    return _validate_file("{config}/{branch}/{file}".format(config=config_dir, branch=branch, file=file_name))


@logged_keyword
def get_sw_release_name():
    with AdminApi() as web_api:
        return web_api.get_sw_release_name()


@logged_keyword
def tl_type():
    with AdminApi() as web_api:
        return web_api.get_bts_info()['gNbCuType']


@logged_keyword
def get_rats():
    with AdminApi() as web_api:
        cells = web_api.get_bts_info()['cells']
        return [str(rat) for rat in cells if cells[rat]]


@logged_keyword
def get_bts_id():
    with AdminApi() as web_api:
        return web_api.get_bts_info()['mrbtsID']


@logged_keyword
def _validate_path(path):
    assert os.path.isdir(path), "FileNotFoundError: [Errno 2] No such file or directory: {}".format(path)
    return path


@logged_keyword
def _validate_file(filepath):
    assert os.path.isfile(filepath), "FileNotFoundError: [Errno 2] No such file or directory: {}".format(filepath)
    return filepath


@logged_keyword
def check_for_incompatible_sw_on_radio(webem_connection):
    alarms = webem_connection.get_active_alarms()
    print_pretty_alarms(alarms)
    for alarm in alarms:
        if alarm['alarmId'] == 7111 and alarm['faultId'] == 23:
            blog("Incompatible sw on radio detected, starting update procedure...")
            update_sw_using_admin(sw_version)
            wait_for_bbmod()
            wait_for_ru()
            blog("Update procedure... done")
            break


@logged_keyword
def prepare_attenuator():
    if tl.attenuator:
        attenuator = Attenuator()
        try:
            attenuator.nullify_attenuation_on_all_ports()
        except ValueError:
            blog('Could not nullify attenuation on ports: {}'.format(attenuator.available_ports))
        attenuator.release_attenuator()
    else:
        blog('No attenuator is configured for the testline')


@logged_keyword
def add_lte_build_to_test_results():
    api = reporting_portal()
    with AdminApi(bts_host=tl.enbs[0].x2_link_addr.v4) as web_api:
        api.add_to_test_data(data={"enb_nsa_build": web_api.get_sw_version()})


@logged_keyword
def assign_sw_version():
    global sw_version
    sw_version = get_sw_version()
    return sw_version


@logged_keyword
def prepare_testline(scf_path=None, config_dir_name=None, custom_swconfig_flags=None, skip_relation_errors=False,
                     second_wind=False, timeout_seconds=None):
    if timeout_seconds is not None:
        global retry_timeout_seconds
        retry_timeout_seconds = timeout_seconds
    wake_up_samurai()
    assign_sw_version()
    inprint_active_sw_version_into_log_html()
    scf_path = _validate_file(scf_path) if scf_path else resolve_scf_path(config_dir_name)
    prepare_cp_runtime_on_smod()
    tl_prep_swconfig(custom_swconfig_flags=custom_swconfig_flags, with_site_reset=False)
    load_scf(scf_path=scf_path, skip_relation_errors=skip_relation_errors)
    prepare_attenuator()
    install_mcshark()
    wait_for_online_state(second_wind)
    time.sleep(30)


@logged_keyword
def sleep_well_tl():
    _pdu = pdu()
    blog("Shutting down radio's in 3min", level='WARN')
    time.sleep(120)
    blog("Last call for script stopping, 1min left")
    for i in range(60, -1, -1):
        blog("{}s left to shutdown..".format(i))
        time.sleep(1)
    eco_friendly_tl(switch_state='off')


@logged_keyword
def wake_up_samurai():
    eco_friendly_tl(switch_state='on')


def switch_ports_legacy_init(du, switch_state):
    for ru in du.rus:
        switch_pdu_port(pdu_port=ru.pdu_port, state=switch_state)
    for cu in du.airscale.common_units:
        switch_pdu_port(pdu_port=cu.pdu_port, state=switch_state)


def switch_ports_uteca_init(du, switch_state):
    for cu in du.airscale.common_units:
        switch_pdu_port(pdu_port=cu.pdu_port, state=switch_state)
        for capacity_unit in cu.capacity_units:
            for ru in capacity_unit.rus:
                switch_pdu_port(pdu_port=ru.pdu_port, state=switch_state)


def try_both_init_structures(du, switch_state):
    try:
        switch_ports_legacy_init(du, switch_state)
    except TypeError:
        switch_ports_uteca_init(du, switch_state)


def eco_friendly_tl(switch_state='on'):
    for gnb in tl.gnbs:
        for du in gnb.dus:
            try_both_init_structures(du, switch_state)
    if tl.attenuator and switch_state == 'on':
        switch_pdu_port(pdu_port=tl.attenuator.pdu_port, state='on')


def switch_pdu_port(pdu_port, state='on'):
    if not pdu_port:
        return

    _pdu = pdu()
    try:
        _pdu.setup_pdu(pdu_port.pdu)
        print_pretty_pdu(pdu_port)
        if state == 'on':
            _pdu.power_on(port=pdu_port.port_no)
        if state == 'off':
            _pdu.power_off(port=pdu_port.port_no)
    except Exception as e:
        blog('Failed to switch pdu ports. Reason: {}'.format(str(e)))


def what_is_wrong_with_pdu():
    for gnb in tl.gnbs:
        for du in gnb.dus:
            for ru in du.rus:
                pdu_port_state(pdu_port=ru.pdu_port)
            for cu in du.airscale.common_units:
                pdu_port_state(pdu_port=cu.pdu_port)


def pdu_port_state(pdu_port):
    if not pdu_port:
        return

    _pdu = pdu()
    try:
        _pdu.setup_pdu(pdu_port.pdu)
        blog(pdu_port)
        blog(_pdu.get_port_status(port=pdu_port.port_no))
    except Exception as e:
        blog('Failed to switch pdu ports. Reason: {}'.format(str(e)))


@logged_keyword
def install_mcshark():
    blog(subprocess.Popen('rm /home/ute/.local/lib/wireshark/plugins/*.*/epan/mcshark*', shell=True))
    script = "{}/testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/log_analyzer/install_wslte_plugins.bash".format(
        robot_globals.execdir())
    blog(
        subprocess.Popen([_validate_file(script), '--sbts', sw_version],
                         stdout=subprocess.PIPE).communicate()[0].decode('UTF-8'))


@logged_keyword
def wait_for_online_state(second_wind=False):
    web_api = AdminUtils()
    rats = get_rats()
    try:
        wait_for_bbmod()
        wait_for_ru()
        for rat in rats:
            wait_for_onair(cell_type=rat)
    except TimeoutError as e:
        blog(e, level='ERROR')
        web_api.collect_snapshot()
        if second_wind:
            blog("Resetting testline and checking again...")
            eco_friendly_tl(switch_state='off')
            time.sleep(60)
            wake_up_samurai()
            time.sleep(60)
            wait_for_bbmod()
            wait_for_ru()
            for rat in rats:
                wait_for_onair(cell_type=rat)
        else:
            raise e
    if 'nr' in rats and tl_type() in ['both', 'NSA', 'SA+NSA']:
        wait_for_x2_link_availability()

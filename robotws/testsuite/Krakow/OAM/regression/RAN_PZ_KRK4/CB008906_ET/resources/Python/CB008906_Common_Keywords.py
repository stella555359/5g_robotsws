# -*- coding: utf-8 -*-
"""
Common keywords for CB008906-SR.

:copyright: Nokia Networks
:author: SHI Kun
:contact: I_NJ_SC_SYSTEM_VERF_GMS
:maintainer: I_NJ_SC_SYSTEM_VERF@internal.nsn.com
"""
import datetime
import os
import re
import shutil
import time
from functools import wraps
from pathlib import Path
import xml.etree.ElementTree as ET

from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.support.ui import WebDriverWait as Wait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn

from sbts_oper import SBTSOper
from asir_webem import AsirWebEm, TimeoutException
from testsuite.Krakow.OAM.regression.RAN_PZ_KRK4.CB008906_ET.resources.Python.helper import\
    ENABLED, ALL_ENABLED, NR, RFSW_LINUX, \
    SHUB_LOGIN_USER, SHUB_LOGIN_PASSWORD, OPER_SSH, SSH_LOGIN, SSH_LOGOUT, ATL_XMLNS, ATL_TAG_LOG, \
    SUCCESS, FAILED, BLOCK, UNBLOCK, WRONG_PASSWORD, ACCOUNT_DISABLED, NORMAL_LOGIN, TWO_INSTANCES, \
    NORMAL_LOGOUT, ADDIT_TEXT_PREFIX, OPER_PAM, IF_TYPE_WEBEM, \
    get_file_in_snapshot_file, decompress_tar, decompress_gz_file, decompress_file

# instance to do BBU operation
sbts_oper = SBTSOper()

# instance to do ASiR WebEM operation
virtual_enable = BuiltIn().get_variable_value('${virtual_enable}')
if isinstance(virtual_enable, str):
    virtual_enable = False if virtual_enable.lower() == 'false' else True

# instance to do ASiR WebEM operation
enable_tls = BuiltIn().get_variable_value('${enable_tls}')
if isinstance(enable_tls, str):
    enable_tls = 0 if enable_tls.lower() == 'false' or enable_tls == '0' else 1

asir_webem = AsirWebEm(virtual_enable=virtual_enable)


def asir_web_login_logout(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        if not asir_webem.wd:
            dt_start = time.time()
            while time.time() < dt_start + 120:
                try:
                    asir_webem.login()
                    break
                except Exception as e:
                    MolerTest.warning('Try login ASiR WebEM again after 30s.\n{}'.format(e))
                    time.sleep(30)
            else:
                MolerTest.error('Can not login ASiR WebEM in 120s!', raise_exception=True)
        try:
            out = func(*args, **kwargs)
            return out
        finally:
            if asir_webem.wd:
                asir_webem.logout()
                asir_webem.wd = None
    return wrapper


def coam_web_login_logout(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        if not sbts_oper.oper.gui_coam:
            sbts_oper.oper.login_gui()
        try:
            out = func(*args, **kwargs)
            return out
        finally:
            if sbts_oper.oper.gui_coam:
                sbts_oper.oper.logout_gui()
                sbts_oper.oper.gui_coam = None
    return wrapper


def connect_all_devices():
    sbts_oper.connect_devices()


def login_and_logout_asir_webem():
    try:
        asir_webem.login(timeout=10)
        time.sleep(3)
    except Exception as e:
        MolerTest.error('Login failure', raise_exception=True)
    finally:
        quit_asir_webem()


def login_asir_webem():
    asir_webem.login()


def logout_asir_webem():
    asir_webem.logout()


def check_failure_login_information_in_asir_webem():
    try:
        asir_webem.login(user_password='wrong_password')
    except Exception as e:
        MolerTest.info('Login failure, then check login information in ASiR WebEM login page.')
        _xpath_login_username = "//div[@id='usernameForm']//input"
        _xpath_login_password = "//div[@id='passwordForm']//input"
        _xpath_error_info = "//div[@id='errorAuthLogin']"
        try:
            wd = asir_webem.wd
            obj_error = Wait(wd, 10).until(EC.visibility_of_element_located((By.XPATH, _xpath_error_info)))
            error_info = obj_error.text
            MolerTest.info('Got error informatio: {}'.format(error_info))
            if error_info != 'Account is disabled':
                MolerTest.error('Can not find the text: "Account is disabled"!', raise_exception=True)
            Wait(wd, 10).until(EC.visibility_of_element_located((By.XPATH, _xpath_login_username)))
            Wait(wd, 10).until(EC.visibility_of_element_located((By.XPATH, _xpath_login_password)))
        except TimeoutException as e:
            MolerTest.error('Current Error Login page is not expected.', raise_exception=True)
        finally:
            quit_asir_webem()


def clean_web_instance():
    asir_webem.clean_browser()


def login_asir_webem_with_another_instance(output_dir, raise_exception=False):
    screenshot_dir = Path(output_dir) / 'asir_screenshot' / 'multiple_instances' / \
                     datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    if not screenshot_dir.exists():
        screenshot_dir.mkdir(parents=True)
    asir_webem.screenshot_dir = screenshot_dir
    new_instance = None

    try:
        new_instance = AsirWebEm(virtual_enable=virtual_enable)
        new_instance.login()
    except TimeoutException:
        pass
    except Exception as e:
        MolerTest.error(e, raise_exception=raise_exception)
    finally:
        if new_instance:
            quit_asir_webem(new_instance)


def login_asir_webem_with_wrong_user():
    try:
        asir_webem.login(user_name='wrong_user')
    except TimeoutException:
        MolerTest.info('Found exception during trying wrong user: TimeoutException')
        pass
    except NoSuchElementException:
        MolerTest.info('Found exception during trying wrong user: NoSuchElementException')
        pass
    except Exception as e:
        MolerTest.info('Found exception during trying wrong user: {}'.format(e))
        pass
    finally:
        quit_asir_webem()


def login_asir_webem_with_wrong_password(output_dir):
    screenshot_dir = Path(output_dir) / 'asir_screenshot' / datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    if not screenshot_dir.exists():
        screenshot_dir.mkdir(parents=True)
    asir_webem.screenshot_dir = screenshot_dir

    try:
        asir_webem.login(user_password='wrong_password', timeout=5)
    except TimeoutException:
        MolerTest.info('Found exception during trying wrong password: TimeoutException')
        pass
    except NoSuchElementException:
        MolerTest.info('Found exception during trying wrong password: NoSuchElementException')
        pass
    except Exception as e:
        MolerTest.info('Found exception during trying wrong password: {}'.format(e))
        pass
    finally:
        quit_asir_webem()


def quit_asir_webem(instance=None):
    if not instance:
        instance = asir_webem

    instance.logout()


@asir_web_login_logout
def block_prrh_from_asir_webem(ant_mod_id=1):
    asir_webem.block_ANTMOD(ant_mod_id=ant_mod_id, timeout=10)


@asir_web_login_logout
def unblock_prrh_from_asir_webem(ant_mod_id=1):
    asir_webem.unblock_ANTMOD(ant_mod_id=ant_mod_id, timeout=10)


def get_param_to_check_atl(operation, start_time, end_time, unit_type='ANTMOD', unit_id=1,
                           backoff_time=0):
    """
    For example:
        - For additionalText to check:
            SM-1019;Unit block request for ASI-1/ASI_R-1/ANTMOD_R-1
            or
            SM-1019;Unit unblock request for ASI-1/ASI_R-1/ANTMOD_R-1
    """
    backoff_time = int(backoff_time)
    addit_text_pattern = 'SM-' + sbts_oper.asi_container_id.replace('0x', '') + ','
    description = ''
    error_code = None
    log_status = None
    if operation == BLOCK:
        addit_text_pattern += 'Unit block request for ASI-1/ASI_R-1/{unit_type}_R-{unit_id}'.format(
            unit_type=unit_type, unit_id=unit_id)
        description = ''
        log_status = 'success'
    elif operation == UNBLOCK:
        addit_text_pattern += 'Unit unblock request for ASI-1/ASI_R-1/{unit_type}_R-{unit_id}'.format(
            unit_type=unit_type, unit_id=unit_id)
        description = ''
        log_status = 'success'
    elif operation == NORMAL_LOGIN:
        addit_text_pattern += 'Login attempt succeeded for username <IWF_SCR:Nemuadmin:IWF_SCR>'.format(
            unit_type=unit_type, unit_id=unit_id)
        description = ''
        log_status = 'success'
    elif operation == NORMAL_LOGOUT:
        addit_text_pattern += 'Logout request'.format(
            unit_type=unit_type, unit_id=unit_id)
        description = ''
        log_status = 'success'
    elif operation == WRONG_PASSWORD:
        addit_text_pattern += 'Login attempt failed for username <IWF_SCR:Nemuadmin:IWF_SCR>'
        description = 'Resource owner credentials are invalid.'
        log_status = 'failure'
        error_code = 'unspecified'
    elif operation == ACCOUNT_DISABLED:
        addit_text_pattern += 'Login attempt failed for username <IWF_SCR:Nemuadmin:IWF_SCR>'
        description = 'Account is disabled'
        log_status = 'failure'
        error_code = 'unspecified'
    elif operation == TWO_INSTANCES:
        addit_text_pattern += 'Login attempt failed for username <IWF_SCR:Nemuadmin:IWF_SCR>'
        description = 'Maximum number of sessions is exceeded.'
        log_status = 'failure'
        error_code = 'unspecified'
    return [start_time + datetime.timedelta(seconds=backoff_time), end_time - datetime.timedelta(seconds=backoff_time),
            addit_text_pattern, description, log_status, error_code]


def get_current_time_in_shub():
    return sbts_oper.get_current_time_in_shub()


def ssh_login_and_logout_shub_from_ws(host='192.168.255.129', login=SHUB_LOGIN_USER, password=SHUB_LOGIN_PASSWORD,
                                      expected_prompt='toor4nsn@fzhub.*#', raise_exception=False):
    sbts_oper.ssh_login_shub_from_ws(host, login, password, expected_prompt, raise_exception)


def get_shub_ip_in_bbu():
    return sbts_oper.get_shub_ip_in_bbu()


def ssh_login_and_logout_shub_from_fhnet(shub_ip, login=SHUB_LOGIN_USER, password=SHUB_LOGIN_PASSWORD,
                                         expected_prompt='toor4nsn@fzhub.*#', raise_exception=False):
    sbts_oper.ssh_login_shub_from_fhnet(shub_ip, login, password, expected_prompt, raise_exception)


def ssh_login_shub_from_ws_with_wrong_user():
    sbts_oper.ssh_login_shub_from_ws(login=SHUB_LOGIN_USER[::-1])


def ssh_login_shub_from_ws_with_wrong_password():
    sbts_oper.ssh_login_shub_from_ws(password=SHUB_LOGIN_PASSWORD[::-1])


def verify_all_shubs_enabled():
    sbts_oper.check_shubs_state(state=ENABLED)


def verify_all_rats_enabled():
    sbts_oper.check_rat_state(rat=NR, state=ALL_ENABLED)


def collect_snapshot_in_asir_shub(output_dir):
    sbts_oper.collect_snapshot_in_asir_shub(output_dir)


def check_ssh_session_in_snapshot(snapshot_file, expected_operation=OPER_SSH,
                                  host_type='WS', login_user='toor4nsn',
                                  expected_session_times=3, session_start_time=None, session_end_time=None,
                                  backoff_time=3, login_failure_type=0
                                  ):
    """
    Check the detail of ssh session in the snapshot file

    :param snapshot_file: str, the path of snapshot file
    :param expected_operation: str, to check the type of operation
    :param host_type: str, will determine which client ip will be checked.
                    For sHUB WS of ASiR the IP will be 192.168.255.126.
                    From FHNET the IP will be provided by caller.
    :param login_user: str,
    :param expected_session_times: int, how many times of session should be found
    :param session_start_time: datetime,
    :param session_end_time: datetime
    :param backoff_time: int, skip the seconds to start check to avoid check unavailable session
    :param login_failure_type: int,
        0 - no login failure
        1 - login failure with wrong user
        2 - login failure with wrong password
    """
    # get target file
    snapshot_file = Path(snapshot_file)
    parent_path = snapshot_file.parent
    expected_linux_file = '101D_linux_logs.tar'
    output_path = parent_path / expected_linux_file.replace('.tar', '')
    expected_ruem_file = 'ruem_hub_snapshot.xml.gz'
    target_output_path = output_path / expected_ruem_file.replace('.xml.gz', '')
    target_file = target_output_path/expected_ruem_file.replace('.gz', '')

    if not target_file.exists():
        if not output_path.exists():
            output_path.mkdir(parents=True)

        get_file_in_snapshot_file(snapshot_extracted_path=parent_path, file_type=RFSW_LINUX, output_path=output_path)
        output_path = decompress_tar(tar_file=output_path/expected_linux_file, output_path=output_path)

        if not target_output_path.exists():
            target_output_path.mkdir(parents=True)
        target_file = decompress_gz_file(file_path=output_path/expected_ruem_file, output_path=target_file)

    client_ip = sbts_oper.get_client_ip(host_type)

    if not client_ip:
        MolerTest.error('Can not get right client ip for {}'.format(host_type), raise_exception=True)
    else:
        MolerTest.info('Need check client ip "{}" in session logs.'.format(client_ip))

    MolerTest.info('Parsing {}'.format(target_file))
    # parse target file
    tree = ET.parse(target_file)
    root = tree.getroot()
    found_ssh_sessions = []

    year = session_start_time.strftime('%Y')
    session_start_time = session_start_time + datetime.timedelta(seconds=backoff_time)
    session_end_time = session_end_time - datetime.timedelta(seconds=backoff_time)
    MolerTest.info('Check the session between {} and {}'.format(session_start_time, session_end_time))

    for entry in root:
        if entry.tag.endswith('record'):
            event_time = entry.attrib['eventTime']
            event_time = datetime.datetime.strptime(event_time, '%Y-%m-%d %H:%M:%S GMT')

            if session_start_time > event_time or event_time > session_end_time:
                continue

            MolerTest.info('To check event: {}'.format(event_time))

            session_time = entry.attrib['sessionTime'].strip()
            if not session_time:
                MolerTest.error(dump_abnormal_session(entry), raise_exception=True)

            if re.search(r'\S{3} \d{2} \d{2}:\d{2}:\d{2}', session_time):
                session_time = year + ' ' + session_time
                time_format = '%Y %b %d %H:%M:%S'
            else:
                MolerTest.error(dump_abnormal_session(entry), raise_exception=True)

            session_time = datetime.datetime.strptime(session_time, time_format)

            if session_start_time > session_time or session_time > session_end_time:
                MolerTest.error('session time "{}" is not between "{}" and "{}"'.format(
                    session_time, session_start_time, session_end_time), raise_exception=True)

            session_id = entry.attrib['sessionID'].strip()
            user_name = entry.attrib['userName'].strip()
            addit_text_prefix = ADDIT_TEXT_PREFIX.format(session_id)
            expected_auth_error = '{} Access denied due to auth error'.format(addit_text_prefix)
            expected_attempt_maximum = '{} Access denied due to maximum number of login attempts is exceeded'.format(
                addit_text_prefix
            )
            expected_account_locked = 'Node-Type=sHUB Node-ID=101D Access denied due to account is temporarily locked'

            log_status = ''
            addit_text = ''
            client_ip_to_check = ''
            operation = ''
            logger = ''

            for item in entry:
                # <Element '{http://www.nokia.com}record' at 0x7f06ecbaca98>, tag: {http://www.nokia.com}record
                tag = item.tag.replace('{http://www.nokia.com}', '')
                text = item.text
                MolerTest.info('[{}] {}, {}'.format(event_time, tag, text))
                if tag == 'logger':
                    logger = text
                    if logger != expected_operation and logger != OPER_PAM:
                        break
                if tag == 'clientIPAddress':
                    client_ip_to_check = text
                    if text and text != client_ip:
                        MolerTest.error('[{}] The clientIPAddress {} is not expected!\n{}'.format(
                            session_id, text, dump_abnormal_session(entry)), raise_exception=True)
                if tag == 'operation' and (SSH_LOGIN in text or SSH_LOGOUT in text):
                    operation = text
                if tag == 'logStatus':
                    log_status = text
                if tag == 'additText':
                    addit_text = text

            if operation:
                if login_failure_type == 0:
                    # normal login session
                    if user_name != login_user or log_status != SUCCESS or not session_id:
                        MolerTest.error(
                            'Found unexpected login user : {}. However {} is expected!\n{}'.format(
                                user_name, login_user, dump_abnormal_session(entry)),
                            raise_exception=True
                        )
                        if addit_text != addit_text_prefix:
                            MolerTest.error(
                                'Found unexpected addit_text : {}. "{}" is expected'.format(
                                    addit_text, addit_text_prefix.format(session_id), dump_abnormal_session(entry)),
                                raise_exception=True
                            )
                elif login_failure_type == 1:
                    # wrong user,
                    # by default, wrong user name will be inverted order of 'login_user'
                    # for example, wrong user will be nsn4root for login user toor4nsn
                    expected_user_name = 'illegal user {}'.format(login_user[::-1])
                    if (user_name != expected_user_name or log_status != FAILED or
                            addit_text != expected_auth_error or not session_id):
                        error_msg = '[Auth]Found unexpected login information: {}.'.format(
                            dump_abnormal_session(entry))
                        MolerTest.error(error_msg, raise_exception=True)
                elif login_failure_type == 2:
                    # wrong password
                    if log_status != FAILED:
                        error_msg = '[Attempt]Found unexpected login status: {}.'.format(
                            dump_abnormal_session(entry))
                        MolerTest.error(error_msg, raise_exception=True)

                    if user_name == login_user:
                        if addit_text not in (expected_auth_error, expected_attempt_maximum, expected_account_locked):
                            error_msg = '[Attempt]Found unexpected addit_text "{}" for {}: {}.'.format(
                                addit_text,
                                user_name,
                                dump_abnormal_session(entry))
                            error_msg += '\nadditText should be the one of "{}", "{}", "{}"'.format(
                                expected_auth_error, expected_attempt_maximum, expected_account_locked)
                            MolerTest.error(error_msg, raise_exception=True)

                    if (not session_id or not client_ip_to_check) and logger != OPER_PAM:
                        error_msg = '[Attempt]Found unexpected login information: {}.'.format(
                            dump_abnormal_session(entry))
                        MolerTest.error(error_msg, raise_exception=True)

                found_ssh_sessions.append({
                    'session_id': session_id,
                    'user_name': user_name,
                    'session_time': session_time,
                    'operation': operation,
                    'log_status': log_status,
                    'addit_text': addit_text
                })

    if not login_failure_type:
        # need take the records of login and logout into account
        expected_session_times = expected_session_times * 2
    elif login_failure_type == 1:
        # system will try 3 times if login failure
        expected_session_times = expected_session_times * 3
    elif login_failure_type == 2:
        # check more detail
        count_auth_error = 0
        count_attempt_maximum = 0
        count_account_locked = 0
        for ssh_session in found_ssh_sessions:
            addit_text = ssh_session['addit_text']
            if 'Access denied due to auth error' in addit_text:
                count_auth_error += 1
            elif 'Access denied due to maximum number of login attempts is exceeded' in addit_text:
                count_attempt_maximum += 1
            elif addit_text == expected_account_locked:
                count_account_locked += 1
        # system will try 3 times if login failure
        # will record 5 'auth error', 1 'account locked' and expected_session_times 'attempt max'
        if count_auth_error != 5:
            MolerTest.error(
                'Not found expected session (expected 5 times, {} times found) of auth error: {}'.format(
                    count_auth_error, found_ssh_sessions),
                raise_exception=True)
        if count_attempt_maximum != expected_session_times:
            MolerTest.error(
                'Not found expected session (expected {} times, {} times found) of maximum attempts: {}'.format(
                    expected_session_times, count_attempt_maximum, found_ssh_sessions),
                raise_exception=True)
        if count_account_locked != 1:
            MolerTest.error(
                'Not found expected session (expected once, {} times found) of account locked: {}'.format(
                    count_account_locked, found_ssh_sessions),
                raise_exception=True)

        # total number
        expected_session_times = 6 + expected_session_times

    if len(found_ssh_sessions) != expected_session_times:
        MolerTest.error('Not found expected session (expected {} times): {}'.format(
            expected_session_times, found_ssh_sessions), raise_exception=True)
    else:
        MolerTest.info('Got all expected session: {}'.format(found_ssh_sessions))


def dump_abnormal_session(session):
    """
        <record userName="toor4nsn" sessionID="8676" sessionTime="Dec 06 08:39:30" eventTime="2022-12-06 08:39:30 GMT">
            <clientIPAddress>192.168.255.126</clientIPAddress>
            <logger>SSH</logger>
            <operation>SSH Login operation</operation>
            <logStatus>Success</logStatus>
            <additText></additText>
            <transId></transId>
        </record>
    """
    event_time = session.attrib['eventTime']
    event_time = datetime.datetime.strptime(event_time, '%Y-%m-%d %H:%M:%S GMT')
    output_msg = []
    for item in session:
        tag = item.tag.replace('{http://www.nokia.com}', '')
        text = item.text
        output_msg.append('{}: {}'.format(tag, text))

    return '!!Unexpected session! eventTime: {}\n{}'.format(event_time, '\n'.join(output_msg))


@asir_web_login_logout
def reboot_shub_by_asir_webem():
    asir_webem.reset_HUBMOD(hub_mod_id=1)


def reboot_bbu_via_ssh():
    sbts_oper.reboot_bbu()
    time.sleep(300)


@asir_web_login_logout
def check_if_parameter_has_default_value(managed_object, parameters):
    results = asir_webem.get_value_from_view(managed_object, parameters=list(parameters.keys()))
    MolerTest.info('Got result of {}.{}: {}'.format(managed_object, parameters, results))
    default_value = True
    for key, value in results.items():
        if value != parameters[key]:
            MolerTest.error(
                'The configured value {} of {} is not expected default value {}.'.format(value, key, parameters[key]))
            default_value = False
    return default_value


@asir_web_login_logout
def check_view_of_accounts_in_asir_webem():
    asir_webem.check_view_of_accounts()


@asir_web_login_logout
def change_password_of_admin_in_asir_webem(account='toor4nsn', new_password=None):
    return asir_webem.change_password_of_account(account, new_password)


def ssh_login_shub_with_new_password(account='toor4nsn', new_password='asirET@123'):
    sbts_oper.ssh_login_shub_from_ws(login=account, password=new_password, raise_exception=True)


@asir_web_login_logout
def reset_password_of_admin_in_asir_webem_to_default_password():
    return asir_webem.reset_password_of_account(account='toor4nsn')


@asir_web_login_logout
def check_last_changed_time(last_changed_time):
    asir_webem.check_last_changed_time(last_changed_time)


def check_scenario_of_audit_trail_log(emssim_log_start_time, emssim_log_end_time, atl_report_param,
                                      stats_path=None, test_log_path=None, atl_path=None,
                                      expected_repeat_times=0):
    """

    :param emssim_log_start_time: str
    :param emssim_log_end_time: str
    :param atl_report_param: dict
    :param stats_path: str, the path used by emssim to save configuration file or other file.
                       For example: /home/asir124/UPLOADS
    :param test_log_path: str, the path to save test case log. The log of emssim will be saved here.
    :param atl_path: str, the path of ATL log
    :param expected_repeat_times: int, how many times to find the specified operations in ATL
    """
    # audit trail log
    if not atl_path:
        stats_path = Path(stats_path)
        atl_path = stats_path / 'ATL'
        target_path = Path(test_log_path)
    else:
        atl_path = Path(atl_path)
        target_path = atl_path

    atl_file = ''
    for item in atl_path.iterdir():
        if item.is_file() and item.name.startswith('ne3s_atl') and item.suffix == '.tar':
            MolerTest.info('Found atl log: {}'.format(item))
            atl_file = target_path/item.name
            if not atl_file.exists():
                shutil.copyfile(item, atl_file)
            break
    else:
        MolerTest.error('No available ATL log under: {}'.format(atl_path), raise_exception=True)

    # emssim log
    emssim_log = target_path / 'emssim.tgz'
    if not emssim_log.exists():
        MolerTest.error('No available emssim log: {}'.format(emssim_log), raise_exception=True)

    atl_records = check_atl(atl_packaged_file=atl_file, atl_report_param=atl_report_param,
                            expected_repeat_times=expected_repeat_times, interface_type=IF_TYPE_WEBEM)
    check_ne3s_msg_in_emssim_log(atl_records,
                                 emssim_packaged_log=emssim_log, emssim_log_start_time=emssim_log_start_time,
                                 emssim_log_end_time=emssim_log_end_time)


def check_ne3s_msg_in_emssim_log(atl_records, emssim_packaged_log, emssim_log_start_time, emssim_log_end_time,
                                 notification_type='ne3s_atl_logUploadNotification'):
    """
    Check NE3S message in emssim log

    :param atl_records: list
    :param emssim_packaged_log: str
    :param emssim_log_start_time: str
    :param emssim_log_end_time: str
    :param notification_type: str

    You can refer to the params below:
        atl_records = [
            ('30086',
                [{'addit_text': 'SM-1019,Logout request',
               'description': '',
               'event_time': datetime.datetime(2023, 1, 12, 11, 29, 4),
               'interface_type': 'WebEM',
               'operation': 'logout',
               'session_id': '1',
               'user_name': 'Nemuadmin'}]),
            ('30087',
                [{'addit_text': 'SM-1019,Login attempt succeeded for username <IWF_SCR:Nemuadmin:IWF_SCR>',
                  'description': '',
                  'event_time': datetime.datetime(2023, 1, 12, 11, 29, 4),
                  'interface_type': 'WebEM',
                  'operation': 'login',
                  'session_id': '2',
                  'user_name': 'Nemuadmin'}]),
            ...]
        emssim_packaged_log = '/home/ute/emssim.tgz'
        emssim_log_start_time = '2022-12-16 13:07:09'
        emssim_log_end_time = '2022-12-16 13:09:35'
        notification_type = 'ne3s_atl_logUploadNotification'
    """
    emssim_packaged_log = Path(emssim_packaged_log)
    emssim_log_path = decompress_file(emssim_packaged_log, output_path=emssim_packaged_log.parent) / 'emssim'
    MolerTest.info('Got decompress file path: {}'.format(emssim_log_path))
    try:
        emssim_console_log = ''
        for item in emssim_log_path.iterdir():
            if item.is_file() and item.name.startswith('emssim') and item.suffix == '.log':
                MolerTest.info('Found expected emssim log: {}'.format(item))
                emssim_console_log = item
                break
        else:
            MolerTest.error('No available emssim log.', raise_exception=True)

        all_notification_regx = []
        for sequence_num, session_detail in atl_records:
            all_notification_regx.append(
                r'(?P<TIMESTAMP>\d{2}:\d{2}:\d{2})\s+\|(?P<SOAP_MSG><SOAP-ENV:Envelope.+' +
                notification_type +
                r'.+<ne3scommon:sequenceNumber>(?P<SEQ_NUMBER>{})</ne3scommon:sequenceNumber>'.format(sequence_num) +
                r'.+</SOAP-ENV:Envelope>)'
            )
        MolerTest.info('Regx: {}'.format(all_notification_regx))

        soap_msg = {}
        temps = emssim_log_start_time.split(' ')[-1].split(':')
        start_seconds = int(temps[0]) * 3600 + int(temps[1]) * 60 + int(temps[2])
        temps = emssim_log_end_time.split(' ')[-1].split(':')
        end_seconds = int(temps[0]) * 3600 + int(temps[1]) * 60 + int(temps[2])
        MolerTest.info('To check messages between {} and {}, {} seconds and {} seconds.'.format(
            emssim_log_start_time, emssim_log_end_time, start_seconds, end_seconds))
        with open(emssim_console_log, 'r') as sf:
            for entry in sf:
                if notification_type not in entry:
                    continue
                for notification_regx in all_notification_regx:
                    try:
                        m = re.search(notification_regx, entry)
                        if m:
                            timestamp = m.group('TIMESTAMP')
                            seq_number = m.group('SEQ_NUMBER')
                            temps = timestamp.split(' ')[-1].split(':')
                            seconds = int(temps[0]) * 3600 + int(temps[1]) * 60 + int(temps[2])
                            if start_seconds <= seconds <= end_seconds:
                                soap_msg[timestamp + '_' + seq_number] = (
                                        '<?xml version="1.0" encoding="UTF-8"?>' + m.group('SOAP_MSG'))
                                break
                    except Exception as e:
                        MolerTest.error('Error during checking entry with regx [{}]: \n{}'.format(
                            notification_regx, entry),
                                        raise_exception=True)
        if not soap_msg:
            MolerTest.error('No available SOAP messages.', raise_exception=True)
        elif len(soap_msg) != len(atl_records):
            MolerTest.error('Not all available SOAP messages found. {}'.format(soap_msg), raise_exception=True)

        MolerTest.info('Got all SOAP messages [{}]: {}'.format(len(soap_msg), soap_msg))
        for timestamp, msg in soap_msg.items():
            root = ET.fromstring(msg)
            body = root[0]
            notification = body[0]
            for entry in notification:
                if 'attachmentProperties' in entry.tag:
                    for sub_entry in entry:
                        tag = sub_entry.tag.replace('{http://www.nokiasiemens.com/ne3s/1.0}', '')
                        text = sub_entry.text
                        if tag == 'contentType' and text == 'oats':
                            break
                    else:
                        MolerTest.error(
                            'No expected "contentType":\n{}'.format(dump_abnormal_soap_msg(timestamp, entry)),
                            raise_exception=True)
                    break
            else:
                MolerTest.error(
                    'No expected "attachmentProperties":\n{}'.format(dump_abnormal_soap_msg(timestamp, notification)),
                    raise_exception=True)
    finally:
        # clear temporary files
        shutil.rmtree(emssim_log_path)


def check_atl(atl_packaged_file, atl_report_param=None, **kwargs):
    """
    Check ATL

    :param atl_packaged_file: str, the path of the ne3s ATL packaged files,
                            like ne3s_atl_logUploadNotification.atl_queue.376-1671112247.tar
    :param atl_report_param: dict,
        {
            operation: (start point to report ATL, end point to report ATL)
        }, like:
        atl_report_param = {
            'unitBlock': [
                datetime.datetime(2022, 12, 16, 3, 20, 40),
                datetime.datetime(2022, 12, 16, 3, 21, 48),
                'SM-1019;Unit block request for ASI-1/ASI_R-1/ANTMOD_R-1'
            ],
            'unitUnblock': [
                datetime.datetime(2022, 12, 16, 3, 21, 58),
                datetime.datetime(2022, 12, 16, 3, 23, 5),
                'SM-1019;Unit unblock request for ASI-1/ASI_R-1/ANTMOD_R-1'
            ]
        }
    :param kwargs: more check points ==>
        - client_ip
        - ne_ip_address
        - ne_port
        - expected_repeat_times
    :return: dict
    """
    atl_packaged_file = Path(atl_packaged_file)
    output_path = Path(atl_packaged_file.parent) / 'atl'
    atl_path = decompress_file(atl_packaged_file, output_path=output_path)

    operations = {}
    found_atl_log_num = 0

    client_ip = kwargs.get('client_ip', '192.168.255.126')
    ne_ip_address = kwargs.get('ne_ip_address', '192.168.255.129')
    ne_port = kwargs.get('ne_port', '3601')
    interface_type = kwargs.get('interface_type')

    expected_repeat_times = int(kwargs.get('expected_repeat_times', 0))
    user_name = kwargs.get('user_name', 'Nemuadmin')

    # atl_report_param = {
    #     'login': [datetime.datetime(2023, 3, 7, 2, 51, 12),
    #        datetime.datetime(2023, 3, 7, 2, 55, 15),
    #        'SM-1019,Login attempt succeeded for username <IWF_SCR:Nemuadmin:IWF_SCR>',
    #        '',
    #        'success',
    #        None],
    #     'logout': [datetime.datetime(2023, 3, 7, 2, 51, 12),
    #         datetime.datetime(2023, 3, 7, 2, 55, 15),
    #         'SM-1019,Logout request',
    #         '',
    #         'success',
    #         None]}
    # expected_repeat_times = 12

    try:
        MolerTest.info('To search ATL log under {}'.format(atl_path))
        for item in atl_path.iterdir():
            if item.suffix != '.xml':
                continue
            MolerTest.info('Found ATL log: {}'.format(item))
            # ne3s_atl_logUploadNotification.atl_queue.376.xml
            sequence_num = item.name.split('.')[-2]
            tree = ET.parse(item)
            root = tree.getroot()
            if root.tag == ATL_TAG_LOG:
                log_type = root.attrib['logType']
                if log_type != 'AUDIT':
                    MolerTest.info('{} is not expected ATL.'.format(item))
                    continue
            else:
                MolerTest.info('Tag "{}" in "{}" is not supported.'.format(root.tag, item))
                continue
            MolerTest.info('Search operation information in {}.'.format(item))

            for entry in root:
                entry_tag = entry.tag.strip().replace(ATL_XMLNS, '')
                if entry_tag == 'record':
                    event_time = entry.attrib['eventTime']
                    event_time = datetime.datetime.strptime(event_time, '%Y-%m-%dT%H:%M:%S+00:00')
                    addit_text = ''
                    log_status = ''
                    description = ''
                    client_ip_reported = ''
                    ne_ip_reported = ''
                    error_code_reported = None
                    interface_type_reported = ''
                    for session in entry:
                        session_tag = session.tag.strip().replace(ATL_XMLNS, '')
                        if session_tag == 'operation':
                            operation = session.text
                            operation_param = atl_report_param.get(operation)
                            if operation_param:
                                start_time, end_time, addit_text_ptn, description_ptn, log_status_ptn, error_code_ptn\
                                    = operation_param
                                break
                    else:
                        continue

                    if not (event_time and start_time and end_time and (start_time < event_time < end_time)):
                        continue
                    session_id = entry.attrib.get('sessionID', None)
                    user_name_reported = entry.attrib.get('userName', '')
                    if user_name_reported != user_name:
                        MolerTest.info('[Wrong user name "{}"] Skip Event time of {}: {}'.format(
                            user_name_reported, sequence_num, event_time))
                        continue
                    MolerTest.info('Go to check more information')

                    for session in entry:
                        session_tag = session.tag.strip().replace(ATL_XMLNS, '')
                        if session_tag == 'interfaceType':
                            interface_type_reported = session.text
                        if session_tag == 'logStatus':
                            log_status = session.text
                        elif session_tag == 'additionalText':
                            # to search
                            # <additionalText>SM-1019,Unit unblock request for
                            # ASI-1/ASI_R-1/ANTMOD_R-1</additionalText>
                            addit_text = session.text
                        elif session_tag == 'clientIPAddress':
                            client_ip_reported = session.text
                        elif session_tag == 'NEIPAddress':
                            ne_ip_reported = session.text
                        elif session_tag == 'errorInfo':
                            error_code_reported = session.attrib['errorCode']
                            for info in session:
                                info_tag = info.tag.strip().replace(ATL_XMLNS, '')
                                if info_tag == 'description':
                                    # to search
                                    # |<description>Account is disabled</description>
                                    description = info.text if info.text else ''

                        if addit_text and log_status and client_ip_reported and ne_ip_reported:
                            if (client_ip == client_ip_reported and
                                    (ne_ip_address + ':' + ne_port) == ne_ip_reported and
                                    log_status == log_status_ptn and
                                    description == description_ptn and
                                    addit_text == addit_text_ptn and
                                    interface_type_reported == interface_type and
                                    error_code_reported == error_code_ptn):

                                if log_status == 'failure' and session_id:
                                    # when login failure, there is no sessionID:
                                    MolerTest.error('sessionID is not expected when login failure!\n{}'.format(
                                        locals()), raise_exception=True)

                                if sequence_num not in operations:
                                    operations[sequence_num] = []
                                operations[sequence_num].append({
                                    'session_id': session_id,
                                    'user_name': user_name,
                                    'event_time': event_time,
                                    'operation': operation,
                                    'addit_text': addit_text,
                                    'description': description,
                                    'interface_type': interface_type_reported
                                })
                                found_atl_log_num += 1
                                break
                    else:
                        MolerTest.info('No expected operation found! {}'.format(locals()))

        if operations:
            operations = sorted(operations.items(), key=lambda x: x[0])
            if (not expected_repeat_times and found_atl_log_num == len(atl_report_param)) or \
                    (expected_repeat_times and found_atl_log_num == expected_repeat_times):
                MolerTest.info('Got all operations in ATL: {}'.format(operations))
                return operations
            else:
                MolerTest.error('Not all available operations found! Found: {}, Expected: {}\n{}'.format(
                    found_atl_log_num, expected_repeat_times, operations),
                                raise_exception=True)
        else:
            MolerTest.error('No available operations found!', raise_exception=True)
    finally:
        shutil.rmtree(atl_path)


def dump_abnormal_soap_msg(timestamp, msg):
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ne3scommon="http://www.nokiasiemens.com/ne3s/1.0">
    <SOAP-ENV:Body>
        <ne3scommon:transferNotification><ne3scommon:agentRegistrationId>Esymac</ne3scommon:agentRegistrationId>
        <ne3scommon:agentRegistrationKey>
        Ggf4L8xmIPA4Q1ncfnVPO1a5XuDyzpDlHgaoQPQ1ino0E5OYzhJkMcxK0cVkw1T8r5kzkkhLkU4CFLLVaDCvSA==
        </ne3scommon:agentRegistrationKey>
        <ne3scommon:queueId>atl_queue</ne3scommon:queueId>
        <ne3scommon:notificationType>ne3s_atl_logUploadNotification</ne3scommon:notificationType>
        <ne3scommon:sequenceNumber>330</ne3scommon:sequenceNumber>
        <ne3scommon:attachmentProperties>
          <ne3scommon:compression>gzip</ne3scommon:compression>
          <ne3scommon:contentType>oats</ne3scommon:contentType>
          <ne3scommon:checksum>
            <ne3scommon:algorithm>none</ne3scommon:algorithm>
            <ne3scommon:hash>23</ne3scommon:hash>
          </ne3scommon:checksum>
        <ne3scommon:primaryDocument>rest</ne3scommon:primaryDocument>
        </ne3scommon:attachmentProperties>
        <ne3scommon:notificationContent>cid:notificationContent</ne3scommon:notificationContent>
        </ne3scommon:transferNotification>
    </SOAP-ENV:Body></SOAP-ENV:Envelope>
    """
    output_msg = []
    for item in msg:
        tag = item.tag.replace('{http://www.nokiasiemens.com/ne3s/1.0}', '')
        text = item.text
        output_msg.append('{}: {}'.format(tag, text))

    return '!!Unexpected msg! [{}]\n{}'.format(timestamp, '\n'.join(output_msg))


@asir_web_login_logout
def set_asir_values(values):
    MolerTest.info('Receive values for ASiR: "{}"'.format(values))
    if not values:
        return

    params = {
        'actParallelUserSessions': 'ASI-1/SECPRM-1',
        'webEMSessionLogoutTimer': 'ASI-1/SECPRM-1',
        'maxParallelUserSessions': 'ASI-1/SECPRM-1',
        'actEMAccessPriority': 'ASI-1/SECPRM-1'
    }
    old_values = {}
    para = []
    for param_abbr, new_value in values.items():
        param_mo = params.get(param_abbr)
        if not param_mo:
            MolerTest.error('Need define MO in params firstly for {}.'.format(param_abbr))
        old_value = asir_webem.get_value_from_view(param_mo, [param_abbr])[param_abbr]
        if str(old_value) == str(new_value):
            MolerTest.info('No need change {} to {}'.format(param_abbr, new_value))
            continue
        old_values[param_abbr] = old_value
        para.append({
            'para_mo': param_mo,
            'para_abbr': param_abbr,
            'value': new_value
        })

    MolerTest.info('Got old values from ASiR WebEM: {}'.format(old_values))

    if old_values:
        asir_webem.modify_parameter(para)
        asir_webem.activate_new_plan()

    return old_values


@coam_web_login_logout
def set_values(values):
    MolerTest.info('Receive values: "{}"'.format(values))
    if not values:
        return

    mrbts_id = sbts_oper.get_mrbts_id_by_admin()
    params = {
        'oamTls': (
            'MRBTS-{}/MNL-1/MNLENT-1/MPLANENW-1'.format(mrbts_id),
            'TLS usage towards the operation and maintenance system'
        ),
        'btsMaxFailedLoginAttempts': (
            'MRBTS-{}/MNL-1/AMGR-1/LUAC-1'.format(mrbts_id),
            'BTS maximum failed login attempts'
        )
    }
    old_values = {}
    for param_abbr, new_value in values.items():
        dist_name, filter_param = params[param_abbr]
        current_value = None
        try:
            current_value = sbts_oper.get_parameter_value(dist_name, filter_param, abbr=param_abbr)
            if current_value != new_value:
                MolerTest.info('Change "{}" to new value "{}".'.format(param_abbr, new_value))
                sbts_oper.set_parameter_value(dist_name, filter_param, new_value)
                old_values[param_abbr] = current_value
            else:
                MolerTest.info('No need change "{}" to new value "{}".'.format(param_abbr, new_value))
        except Exception as e:
            MolerTest.error('Can not change "{}" to "{}", old value: "{}": {}'.format(
                param_abbr, new_value, current_value, str(e)),
                        raise_exception=True)
    if old_values:
        active_new_values()

    return old_values


def active_new_values():
    validate_result = sbts_oper.validate_plan()
    if validate_result:
        MolerTest.error('Validate plan fail!\n{}'.format(validate_result), raise_exception=True)
    MolerTest.info('Activate plan.')
    sbts_oper.activate_plan()


def collect_screenshot_of_asir_webem(output_dir):
    output_dir = Path(output_dir) / 'asir_screenshot'
    if not output_dir.exists():
        output_dir.mkdir(parents=True)

    screenshot_dir = Path(asir_webem.screenshot_dir)
    for item in screenshot_dir.iterdir():
        if item.is_file() and item.suffix == '.png':
            shutil.move(os.fspath(item), os.fspath(output_dir))

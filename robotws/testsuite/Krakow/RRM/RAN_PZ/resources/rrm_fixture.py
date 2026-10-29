import time
import os
from shutil import copyfile
from random import choice, randint
from string import ascii_letters, digits
from robot.libraries.BuiltIn import BuiltIn as RobotBuiltIn
import taf.config.testline
from taf.transport.ssh import ssh
import testsuite.Krakow.RRM.RAN_PZ.resources.webUI_operations as webUI
from testsuite.Krakow.RRM.RAN_PZ.resources.decorators import logged_keyword
from taf.ul.config.scf import scf

is_classical_testline = isinstance(RobotBuiltIn().get_variable_value('${tl.gnbs[0]}'),
                                   taf.config.testline.gnb.gnb.ClassicalBts)
classical_asik_ip_address = RobotBuiltIn().get_variable_value('${tl.gnbs[0].cu.oam_ssh_connection_details.addr}')
asik_username = 'toor4nsn'
asik_password = 'oZPS0POrRieRtu'

assert_equal_msg = '\n'.join(["{message}", "{p1_name}: {p1_value}", "{p2_name}: {p2_value}"])
assert_msg = '\n'.join(["{message}", "Expected: {expected}", "But was: {current}"])

bts_id = 0


@logged_keyword
def get_robot_variable(variable_name):
    return RobotBuiltIn().get_variable_value(variable_name)


def log_message(**kwargs):
    return RobotBuiltIn().log(**kwargs)


@logged_keyword
def get_testline_init_result_directory():
    dir_name = 'testline_init_results'
    for root, dirs, files in os.walk('/'):
        if dir_name in dirs:
            return os.path.join(root, dir_name)


def get_default_pcap_filepath():
    return "{path}/{filename}.pcap".format(path=get_robot_variable("${LOG_PATH}"),
                                           filename=get_robot_variable("${test_name}"))


def run_robot_keyword(keyword_name, *args):
    return RobotBuiltIn().run_keyword(keyword_name, *args)


@logged_keyword
def generate_string(min_length, max_length):
    printable = digits + ascii_letters + "()+,-./:=?' "
    return "".join(choice(printable) for _ in range(randint(min_length, max_length)))


def string_to_file(filename, contents):
    with open(filename, 'wb') as f:
        f.write(contents.encode('UTF-8'))


@logged_keyword
def file_to_string(filepath):
    with open(filepath, 'r') as read_file:
        file_content = read_file.read()
    return str(file_content)


def is_file_contains_substring(file_name, substring):
    with open(file_name, 'r') as reader:
        text = reader.read().replace('\n', '')
    return text.count(substring)


def dict_to_pretty_string(dictionary, key_header, value_header):
    output = "{:<15}| {:<15}\n".format(key_header, value_header)
    output += "---------------------------------\n"
    for k, v in dictionary.items():
        output += "{:<15}| {:<15}\n".format(k, v)
    return output


def wait_for_method(method_name, timeout=300, retry_timeout=30, method_args=(), failure_msg=None):
    method_name_with_args = '{}{}'.format(method_name.__name__, method_args)
    error_msg = failure_msg if failure_msg else 'Timeout expired while waiting for {}'.format(method_name_with_args)
    end = time.time() + float(timeout)
    is_ok = __is_method_ready(method_name, method_args)
    while not is_ok and not (end < time.time()):
        RobotBuiltIn().sleep(retry_timeout, 'Waiting for {}'.format(method_name_with_args))
        is_ok = __is_method_ready(method_name, method_args)

    assert is_ok, error_msg


@logged_keyword
def get_oam_type():
    webui = webUI.WebuiInterface()
    return webui.oam_type


@logged_keyword
def get_bts_id():
    global bts_id
    if bts_id == 0:
        with webUI.WebUIOperations() as web:
            bts_id = web.get_bts_info(attribute='id')
    return bts_id


def get_oam_ip():
    return get_robot_variable('${tl.gnbs[0].cu.oam_ssh_connection_details.addr}')


def get_oam_web():
    return 'https://{}/'.format(get_oam_ip())


def get_oam_user():
    return get_robot_variable('${tl.gnbs[0].cu.oam_ssh_connection_details.username}')


def get_oam_pass():
    return get_robot_variable('${tl.gnbs[0].cu.oam_ssh_connection_details.password}')


def connect_to_oam():
    oam_connection = ssh()
    return oam_connection.connect_to(hostname=get_oam_ip(),
                                     username=get_oam_user(),
                                     password=get_oam_pass())


def download_file_from_oam(remote_path, local_path):
    oam_conn = ssh()
    oam_conn.download_file(remote_path=remote_path,
                           local_path=local_path,
                           connection=connect_to_oam())
    oam_conn.disconnect()


@logged_keyword
def recommission_testline(should_contain=None, should_not_contain=None, scf_path=None):
    if not scf_path:
        scf_path = os.path.join(get_testline_init_result_directory(), 'config_files/SCFC.xml')
    assert os.path.isfile(scf_path), 'Configuration file is not exists ({})'.format(scf_path)
    working_copy = '{path}/scf.xml'.format(path=get_robot_variable('${LOG_PATH}'))
    copyfile(scf_path, working_copy)
    scf().prepare_scf_file(scf_path=working_copy,
                           should_contain=should_contain,
                           should_not_contain=should_not_contain)
    webUI.perform_commissioning_and_wait_till_oam_ready(working_copy)


def __is_method_ready(method_name, method_args):
    is_ready = False
    try:
        is_ready = method_name(*method_args) if method_args else method_name()
    except Exception:
        return is_ready
    return is_ready

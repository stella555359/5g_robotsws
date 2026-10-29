import ast
import os
import subprocess
import time

from pexpect import pxssh

from robot.api import logger
from taf.sbts.oam.coam.admin import admin

from audit_trail_logs import TrailLogsParser

coam = admin()

DEFAULT_PUBLIC_KEY_LOCATION = os.path.join(os.getcwd(), "id_rsa.pub")


def get_validation_results(output):
    """
    Get list of messages about definition errors
    :param output:   dictionary with results from oam perform recommissioning api call
    :return:        List of feedbacks strings
    """
    output = output['niddValidationResult']['logs']['definitionErrors']
    return output


def check_definition_error_presence(output, exp_error_msg):
    """
    Verify if definition error occurs
    :param output:          Tuple with results from oam perform recommissioning api call
    :param exp_error_msg:   Expected string with error message
    """
    output = str(output).split("Status reached:")[1]
    output = output.split(". ErrorCode")[0]
    output = output.strip()
    logger.console("\nCleared output: {}".format(output))
    output = ast.literal_eval(output)
    results = get_validation_results(output)
    for result in results:
        if result.get('parameter') == 'sshSessionIdleTimer':
            errors = result.get('error')
            for error in errors:
                if type(error) is dict:
                    error_msg = error.get('key')
                    if exp_error_msg in error_msg:
                        logger.console("Check Passed: exp definition error exists: {}".format(error_msg))
                        assert True
                        return
    assert False, "Check Failed: no definition error found with exp msg: {}".format(exp_error_msg)


def check_definition_error_presence_in_netact_output(output, exp_status, exp_error_msg):
    """
    Verify definition error occurrences in output from ne3s param change operation
    :param output:          Tuple with results from ne3s param change operation
    :param exp_status:      Expected operation status to be included in output
    :param exp_error_msg:   Error message expected to be included in output
    """
    output = str(output)
    assert_msg = "Check Failed: no error found: {} <> output: {}".format(exp_error_msg, output)
    assert ('FAIL' in output) and (exp_status in output) and (exp_error_msg in output), assert_msg


def check_atl_logs(atl_logs_file, exp_operation, exp_mrbts_id, additional_text="", log_status="Success"):
    """
    Verify exp_operation presence in atl logs.
    :param atl_logs_file:       File path to the logs with atl file (exp. cleaned version which are not
                                                                     include other irrelevant log msgs)
    :param exp_operation:       Expected operation string (may be substring also)
    :param exp_mrbts_id:        MRBTS id integer
    :param additional_text:     Expected additional text of operation ((may be substring also)
    """
    parser = TrailLogsParser()
    parser.load(atl_logs_file)
    parser.parse()
    for log_msg in parser.log_msgs:
        for operation in log_msg.operations:
            if exp_operation in str(operation.get('operation', "")) \
                    and str(exp_mrbts_id) in str(log_msg.log_tag.get('id', "")) \
                    and additional_text in str(operation.get('additionalText', "")) \
                    and log_status in str(operation.get('logStatus', "")):
                logger.console("Exp: operation found: {}, additional text: {}, log status: {} <>"
                               "Act: operation found: {}".format(exp_operation, additional_text,
                                                                 log_status, operation))
                assert True
                return
    assert False, "No operation: {} with additional_text: {} and log_status: {} found in atl logs!".format(
        exp_operation, additional_text, log_status)


def check_if_operation_is_not_present_in_atl_logs(atl_logs_file, unwanted_operation, additional_text=""):
    """
    Verify unwanted_operation is not present in atl logs.
    :param atl_logs_file:       File path to the logs with atl file (exp. cleaned version which are not
                                                                     include other irrelevant log msgs)
    :param unwanted_operation: Unwanted operation string (may be substring also)
    """
    parser = TrailLogsParser()
    parser.load(atl_logs_file)
    parser.parse()
    for log_msg in parser.log_msgs:
        for operation in log_msg.operations:
            if unwanted_operation in str(operation.get('operation', "")) \
                    and additional_text in str(operation.get('additionalText', "")):
                assert False, "Unwanted operation: {} with additional_text: {} found in atl logs!".format(
                    unwanted_operation, additional_text)
    logger.console("No operation: {} with additional text: {} found in atl logs!".format(unwanted_operation,
                                                                                         additional_text))
    assert True


def generate_ssh_login_keys(public_key_path=DEFAULT_PUBLIC_KEY_LOCATION):
    """
    Create ssh key pair public + private.
    If public key already exists under public_key_path, then no new keys are generated.
    :param public_key_path:     File path to the public key
    :return:                    File path to the public key
    """
    private_key_path = public_key_path[:-4]
    if os.path.exists(public_key_path):
        logger.console("Public key already exists: {}, remove...".format(public_key_path))
        subprocess.call("rm -f {}".format(public_key_path), shell=True)
    if os.path.exists(private_key_path):
        logger.console("Private key already exists: {}, remove...".format(private_key_path))
        subprocess.call("rm -f {}".format(private_key_path), shell=True)

    cmd = 'ssh-keygen -P "" -t rsa -b 4096 -f {}'.format(private_key_path)
    logger.console("Generate keys with cmd: {}".format(cmd))
    p = subprocess.Popen(cmd, shell=True)
    p.wait()
    return private_key_path


def remove_ssh_keys(key_path):
    """
    Remove ssh key pair (assumes there are in the same directory)
    :param key_path:    File path to the public or private key
    """
    logger.console("Remove ssh keys...")
    if key_path.endswith('.pub'):
        os.system("rm {}".format(key_path))
        os.system("rm {}".format(key_path[:-4]))
    else:
        os.system("rm {}".format(key_path))
        os.system("rm {}".format(key_path + '.pub'))


def set_ssh_public_key_on_bts(connection, value, dist_name):
    """
    Upload ssh public key into BTS.
    :param connection:  OAM admin connection instance
    :param value:       public key value string
    :param dist_name:   DN into Managed object which stores ssh public key (SECADM)
    """
    structure = [{"keyDescription": "", "keyValue": value}]
    coam.perform_parameter_recommissioning(dist_name=dist_name, parameter="serviceUserPublicKeys", operation="update",
                                           value=structure, skip_parameter_relation_errors=False,
                                           connection=connection)
    coam.perform_parameter_recommissioning(dist_name=dist_name, parameter="keyContinuation", operation="update",
                                           value="true", skip_parameter_relation_errors=False,
                                           connection=connection)


def get_public_key_value(public_key_path):
    """
    Read public key value from public key file
    :param public_key_path: File path to the public SSH key
    :return: Public key value
    """
    lines = []
    with open(public_key_path, 'r') as f:
        for line in f.readlines():
            lines.append(line)
        key_value = "".join(lines)
    if key_value.endswith('\n'):
        key_value = key_value[:-1]
    logger.console("SSH key value: {}".format(key_value))
    return key_value


def perform_ssh_event(hostname, username, event, password=None, ssh_key=None, auto_logout=False, idle_time=None,
                      close_conn=True, log_output=True):
    """
    Execute command by ssh using pxssh library.
    :param hostname:        ip host address, i.e. 192.168.255.129
    :param username:        i.e. toor4nsn
    :param event:           string with command to execute
    :param password:        i.e. oZPS0POrRieRtu
    :param ssh_key:         File path of ssh private key
    :param auto_logout:     Boolean indicates if auto logout is expected
    :param idle_time:       Int stores seconds needed for reach auto logout (applicable only when auto logout is set)
    :param close_conn:      Boolean indicates if connection will be closed or not
    :param log_output:      Boolean indicates if cmd output should be logged or not
    :return:                ssh connection if close_conn is False, None otherwise
    """
    assert ssh_key or password, "At least password or path to private ssh key must be provided!"
    s = pxssh.pxssh()
    if password:
        logger.console("SSH login with hostname={}, username={}, password={}".format(hostname, username, password))
        s.login(hostname, username, password, auto_prompt_reset=False, original_prompt=r" >")
    else:
        logger.console("SSH login with hostname={}, username={}, ssh_key={}".format(hostname, username, ssh_key))
        s.login(hostname, username, ssh_key=ssh_key, auto_prompt_reset=False, original_prompt=r" >")
    s.sendline(event)
    if log_output:
        s.prompt()
        logger.console("Executed event output: {}".format(s.before))
    if auto_logout:
        logger.console("Wait for auto logout for {}s inactivity...".format(idle_time))
        time.sleep(int(idle_time))
    else:
        logger.console("SSH logout")
        s.logout()
    if not close_conn:
        return s
    s.close()


def perform_login_with_wrong_password(hostname, username, password):
    """
    Try to login with wrong password intentionally. Error is expected.
    :param hostname:        ip host address, i.e. 192.168.255.129
    :param username:        i.e. toor4nsn
    :param password:        i.e. wrongpassword
    """
    s = pxssh.pxssh()
    try:
        logger.console("SSH login with hostname={}, username={}, password={}".format(hostname, username, password))
        s.login(hostname, username, password, auto_prompt_reset=False, original_prompt=r" >")
    except pxssh.ExceptionPxssh as e:
        logger.console("pxssh login failed (it is expected)")
    s.close()


def close_ssh_connection(ssh_conn):
    """
    :param ssh_conn: instance from pxssh.pxssh()
    """
    ssh_conn.close()

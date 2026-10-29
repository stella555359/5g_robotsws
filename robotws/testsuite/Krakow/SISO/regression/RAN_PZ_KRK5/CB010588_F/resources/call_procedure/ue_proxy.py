import os
import yaml
import paramiko
from moler.util.moler_test import MolerTest
import taf.rfrl.utilities.logger.custom_logger as logger


def get_ue_config():
    ue_config_path = os.environ["ABSTRACT_LIB_CONFIG"]
    with open(ue_config_path, 'r') as ue_config_file:
        ue_yaml = yaml.safe_load(ue_config_file)
        ue_config = \
            ue_yaml['UE_POOLS']['TafUeAndroidPool']['inline_config']['ANDROID_UE_1']['CONSTRUCTOR_PARAMETERS'][
                'configuration']
        host = ue_config['ue_pc_address']
        username = ue_config['ue_pc_login']
        password = ue_config['ue_pc_password']
        return host, username, password


def restart_ue_proxy_on_ue_pc():
    logger.log_info_to_console("Performing UE Proxy Reset", log_hierarchy=2)
    stop_ue_proxy_on_ue_pc()
    start_ue_proxy_on_ue_pc()


def start_ue_proxy_on_ue_pc():
    """Starts Windows service 'UE PROXY RUNNER' used for communicating with UE."""
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        MolerTest.info("Creating connection.")
        host, username, password = get_ue_config()
        ssh.connect(host, username=username, password=password)
        stdin, stdout, stderr = ssh.exec_command('/cygdrive/c/Windows/System32/net.exe start "UE PROXY RUNNER"')
        output = [stdout.read(), stderr.read()]
        MolerTest.info("SSH output:", dump=output)
        MolerTest.sleep(30)
    except Exception as e:
        MolerTest.info("Cannot start ue proxy.", dump=e)
    finally:
        MolerTest.info("Closing connection.")
        ssh.close()
        MolerTest.info("Connection closed.")


def stop_ue_proxy_on_ue_pc():
    """Stops Windows service 'UE PROXY RUNNER' used for communicating with UE."""
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        MolerTest.info("Creating connection.")
        host, username, password = get_ue_config()
        ssh.connect(host, username=username, password=password)
        stdin, stdout, stderr = ssh.exec_command('/cygdrive/c/Windows/System32/net.exe stop "UE PROXY RUNNER"')
        output = [stdout.read(), stderr.read()]
        MolerTest.info("SSH output:", dump=output)
    except Exception as e:
        MolerTest.info("Cannot stop ue proxy.", dump=e)
    finally:
        MolerTest.info("Closing connection.")
        ssh.close()
        MolerTest.info("Connection closed.")

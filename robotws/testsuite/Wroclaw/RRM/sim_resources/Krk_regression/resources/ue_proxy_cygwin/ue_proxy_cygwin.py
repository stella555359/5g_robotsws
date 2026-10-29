from moler.util.moler_test import MolerTest
import paramiko
from robot.libraries.BuiltIn import BuiltIn, logger


ue = BuiltIn().get_variable_value('${tl.ues[0]}')
ue_conf = ue['UE_POOLS']['TafUeAndroidPool']['inline_config']['ANDROID_UE']['CONSTRUCTOR_PARAMETERS']['configuration']

host = ue_conf['ue_pc_address']
username = ue_conf['ue_pc_login']
password = ue_conf['ue_pc_password']


def start_ue_proxy_on_ue_pc():
    """Starts Windows service 'UE PROXY RUNNER' used for communicating with UE."""
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        MolerTest.info("Creating connection.")
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

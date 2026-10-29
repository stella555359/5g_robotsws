import os
import yaml
import paramiko
from moler.util.moler_test import MolerTest
import taf.rfrl.utilities.logger.custom_logger as logger


def get_ue_config():
    """
    Retrieves the UE configuration from the environment and configuration file.

    Returns:
    tuple: A tuple containing the host, username, and password for the UE PC.
    """
    ue_config_path = os.environ["ABSTRACT_LIB_CONFIG"]
    with open(ue_config_path, 'r') as ue_config_file:
        ue_config = yaml.safe_load(ue_config_file)
        try:
            ue_proxy_path = os.environ.get("UE_PROXY_PATH")
            ue_proxy_path = ue_proxy_path.replace(" ", "")
            for key in ue_proxy_path.split(','):
                ue_config = ue_config[key]
            host = ue_config['ue_pc_address']
            username = ue_config['ue_pc_login']
            password = ue_config['ue_pc_password']
            return host, username, password
        except KeyError:
            logger.log_warn_to_console(
                "Compare correctness of variable UE_PROXY_PATH in common_variables.py with ue_config.yaml")
        except Exception as e:
            logger.log_warn_to_console("An error occurred: {}".format(str(e)))


def restart_ue_proxy_on_ue_pc(log_hierarchy=2):
    """
    Restarts the UE Proxy service on the UE PC.

    This method stops and then starts the 'UE PROXY RUNNER' Windows service used for communicating with the UE.
    It logs the process at the specified log hierarchy level.

    Parameters:
    log_hierarchy (int, optional): The hierarchy level for logging. Defaults to 2.

    Returns:
    None
    """
    logger.log_info_to_console("Performing UE Proxy Reset", log_hierarchy=log_hierarchy)
    stop_ue_proxy_on_ue_pc()
    start_ue_proxy_on_ue_pc()


def start_ue_proxy_on_ue_pc():
    """
    Starts the 'UE PROXY RUNNER' Windows service used for communicating with the UE.

    This method establishes an SSH connection to the UE PC using the configuration retrieved from the environment
    and configuration file. It then executes the command to start the 'UE PROXY RUNNER' service and logs the output.
    The connection is closed after the command execution.

    Returns:
    None
    """
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
    """
    Stops the 'UE PROXY RUNNER' Windows service used for communicating with the UE.

    This method establishes an SSH connection to the UE PC using the configuration retrieved from the environment
    and configuration file. It then executes the command to stop the 'UE PROXY RUNNER' service and logs the output.
    The connection is closed after the command execution.

    Returns:
    None
    """
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

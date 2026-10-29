from ta_emss import ta_emss
from robot.api import logger
import time


def close_connection_with_emssim(bts_id, connection):
    """
    Close connection between EMSSIM and BTS.
    :param bts_id: the ID of MRBTS
    :param connection: the connection with EMSSIM that should be closed
    :return: None (the KW only close connection)
    """
    logger.console('Close connection with EMSSIM')
    connection.teardown_emss(bts_id=bts_id)


def integrate_emssim_with_bts(bts_id, host, user, cert_type, cert, key, cacert, tls=1):
    """
    Create connection between EMSSIM and BTS.
    :param bts_id: the ID of MRBTS
    :param host: address of VM (in tests it is address for EMSSIM)
    :param user: flexi user (to create flexi user use: Add EMSSIM User on VM)
    :param tls: enabling or disabling TLS (default is 1 - enabled)
    :return: None (the KW only open connection)
    """
    ems = ta_emss()
    time.sleep(30)
    ems.setup_emss(bts_id=bts_id, host=host, port=int(bts_id)+4000, user=user, ne3s=True,
                   req_user='wsuser', req_password='A0zY~rP#8Mx@', tls=True,
                   wait_discovered=False, wait_connected=False)
    if cert_type in ['RSA', 'ECDSA']:
        ems.emss_proxy_ssl_cert(cert=cert, key=key, cacert=cacert)
    ems.run_emssim_command('ne3s_activate -password A0zY~rP#8Mx@ -user wsuser -tls {}'.format(tls))
    return ems


def execute_command_on_emssim(command, connection):
    """
    Execute command on EMSsim.
    :param command: command with parameters, to check which are available use 'help' command on EMSsim
    :param connection: the connection with EMSSIM
    :return: None
    """
    logger.console('Execute command on EMSSIM: {}'.format(command))
    try:
        connection.run_emssim_command(command)
        logger.console('Command executed')
    except Exception as e:
        logger.console('Error msg: {}'.format(e))
        raise


def execute_command_on_emssim_and_return_output(command, connection):
    logger.console('Execute command on EMSSIM: {}'.format(command))
    try:
        result = connection.run_emssim_command(command=command, get_full_data=True)
        logger.console('Command executed')
    except Exception as e:
        logger.console('Error msg: {}'.format(e))
        raise
    finally:
        return result

from ta_emss import ta_emss
from robot.api import logger
import time


def close_connection_with_emssim(bts_id, connection):
    logger.console('Close connection with EMSSIM')
    connection.stop_emss(bts_id=bts_id, force=True)


def execute_command_on_emssim(command, connection):
    logger.console('Execute command on EMSSIM: {}'.format(command))
    try:
        connection.run_emssim_command(command)
        logger.console('Command executed')
    except Exception as e:
        logger.console('Error msg: {}'.format(e))
        raise


def integrate_emssim_with_bts(bts_id, host, user, cert, cert_type, key, cacert, tls=1):
    ems = ta_emss()
    time.sleep(30)
    ems.setup_emss(bts_id=bts_id, host=host, port=int(bts_id)+4000, user=user, ne3s=True,
                   req_user='wsuser', req_password='A0zY~rP#8Mx@', tls=True,
                   wait_discovered=False, wait_connected=False)
    if cert_type in ['RSA', 'ECDSA']:
        ems.emss_proxy_ssl_cert(cert=cert, key=key, cacert=cacert)
    ems.run_emssim_command('ne3s_activate -password A0zY~rP#8Mx@ -user wsuser -tls {}'.format(tls))
    return ems


def update_sw_using_emssim(target, bts_id):
    ems = ta_emss()
    ems.perform_software_update(target, bts_id=bts_id)


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

from ta_emss import ta_emss
from robot.api import logger


def close_connection_with_emssim(bts_id, connection):
    logger.console('Close connection with EMSSIM')
    connection.teardown_emss(bts_id=bts_id)


def execute_command_on_emssim(command, connection):
    logger.console('Execute command on EMSSIM: {}'.format(command))
    try:
        connection.run_emssim_command(command)
        logger.console('Command executed')
    except Exception as e:
        logger.console('Error msg: {}'.format(e))
        raise


def integrate_emmsim_with_bts(bts_id, host, user):
    logger.console('Start integrate BTS with EMSSIm')
    ems = ta_emss()
    ems.setup_emss(bts_id=bts_id, host=host, port=int(bts_id)+4000, user=user, ne3s=True,
                   req_user='Nemuadmin', req_password='nemuuser', tls=True,
                   wait_discovered=False, wait_connected=False)
    ems.run_emssim_command('ne3s_activate -password nemuuser -user Nemuadmin -tls 1')
    logger.console('Integration finished')
    return ems

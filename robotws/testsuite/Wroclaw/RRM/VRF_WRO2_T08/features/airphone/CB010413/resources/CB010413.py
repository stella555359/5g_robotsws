import os
import signal
from robot.api import logger
from ta5g_iphy import ta5g_iphy
from ta5g_admin_operations import ta5g_admin_operations


def get_scfc_file_du_aic(path, filename_prefix='initial_commissioning'):
    number_of_vdu = ta5g_admin_operations().get_number_of_vdu()
    for vdus in range(number_of_vdu):
        filename = filename_prefix+'_vdu_{0}.xml'.format(vdus)
        host = ta5g_iphy().get_vdu_master_ip(vdu=vdus)
        with ta5g_admin_operations().connect_to_vdu_aic(host=host) as vdu_connection:
            vdu_connection.get_current_plan_file(path, filename)


def stop_tcpdump_log_collection(process):
    os.killpg(os.getpgid(process.pid), signal.SIGTERM)
    logger.console("tcpdump process: {} has been terminated".format(process))


def replace_spaces_in_prefix_name(input_string):
    output_string = input_string.replace(' ', '_')
    return output_string

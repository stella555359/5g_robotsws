import time
import os

from ta5g_iphy import ta5g_iphy
from ta5g_commissioning import ta5g_commissioning
from ta5g_admin_operations import ta5g_admin_operations
from ta5g_admin_operations import ta_admin_common_operations
from ta5g_enb import ta5g_enb
from robot.api import logger


def get_scfc_file_du_aic(path, filename_prefix='initial_commissioning'):
    number_of_vdu = ta5g_admin_operations().get_number_of_vdu()
    for vdus in range(number_of_vdu):
        filename = filename_prefix+'_vdu_{0}.xml'.format(vdus)
        host = ta5g_iphy().get_vdu_master_ip(vdu=vdus)
        with ta5g_admin_operations().connect_to_vdu_aic(host=host) as vdu_connection:
            vdu_connection.get_current_plan_file(path, filename)


def find_scfc_aic(scfc_filename):
    found_scfc_filepath = ta5g_commissioning().get_commissioning_file_for_enb_release_name(input_filename=scfc_filename)
    return found_scfc_filepath


def send_eth_down_to_active_subcomponent(subcomponent='cpcl'):
    logger.console("Starting recovery action for active Cplane subcomponent")
    namespace = ta5g_enb().get_namespace_for_vcu()
    host = ta5g_enb().get_ip_vcu_master()
    active_subcomponent_id = get_active_subcomponent(subcomponent=subcomponent)

    with ta_admin_common_operations.create_shell_session_vcu(host) as connection:
        connection.send_shell_command("oc exec -it ute-{}-{}-{} -c ctr-{}-nwmgmt -n {} -- bash"
                                      .format(namespace, subcomponent, active_subcomponent_id, namespace, namespace))
        connection.send_shell_command("ip link set dev eth0 down")
        time.sleep(60)  # waiting for subcomponent recovery


def get_active_subcomponent(subcomponent='cpcl'):
    with ta5g_admin_operations().connect_to_vcu_aic() as vcu_connection:
        vnfcs_states = vcu_connection.get_vnfcs_states()
        logger.info(vnfcs_states)
    for vnfcs in vnfcs_states:
        if subcomponent+'-' in vnfcs['name'] and vnfcs['role'] == 'active':
            subcomponent_name = vnfcs['name']
            active_subcomponent_id = subcomponent_name.split("-")[-1]
            logger.info("Active {} subcomponent= {}".format(subcomponent, subcomponent_name))
            return active_subcomponent_id
        elif subcomponent in vnfcs['name'] and vnfcs['role'] == 'disabled':
            logger.error("No redundant subcomponent deployment on the TL")
            return False


def run_os_command(cmd):
    os.system(str(cmd))
    time.sleep(10)

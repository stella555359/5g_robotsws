import subprocess
import re
import time
from robot.libraries.BuiltIn import BuiltIn

from ta5g_admin_operations import ta_admin_common_operations
from ta5g_enb import ta5g_enb
from robot.api import logger


ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def add_xn_interface_address(ipaddress, inet4prefix, device):
    cmd = "sudo ip a a {}/{} dev {}".format(ipaddress, inet4prefix, device)
    result = subprocess.Popen(cmd.split())
    print(result)


def assert_traffic_on_every_scell(ue_id, scells_amount, traffic=True, traffic_stabilization=True):
    for scell in range(1, int(scells_amount)+1):
        scell_tput = get_scell_avg_dl_data_traffic(ue_id=ue_id,
                                                   scell=scell,
                                                   traffic_stabilization=traffic_stabilization)
        if int(scell_tput) == 0 and traffic is True:
            raise Exception("Scell_{} t-put is 0".format(scell))
        elif int(scell_tput) != 0 and traffic is False:
            raise Exception("Scell_{} t-put: {} is higher than 0".format(scell, float(scell_tput)))
        else:
            print("Scell_{} t-put different than expected one".format(scell))


def get_scell_avg_dl_data_traffic(ue_id, scell, unit='Mbps', traffic_stabilization=True):
    if traffic_stabilization:
        time.sleep(10)
    avg_tput = 0
    pdsch_ue_stats = _get_pdsch_ue_stats_for_given_cc(ue_id, scell)
    pattern = re.compile(r'(\d*\.\d) ({}) '.format(unit))
    try:
        avg_tput = pattern.findall(pdsch_ue_stats)[-1][0]
    finally:
        return float(avg_tput)


def _get_pdsch_ue_stats_for_given_cc(ue_id, scell):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type=pdsch scell={}'
                                                                       .format(ue_id, scell),
                                                                       pass_regexp='UE-{}: NR PDSCH Throughput'
                                                                       .format(ue_id))


def send_eth_down_to_cplane_subcomponent(subcomponent='cpcl'):
    logger.console("Starting recovery action for active Cplane subcomponent")
    namespace = ta5g_enb().get_namespace_for_vcu()
    host = ta5g_enb().get_ip_vcu_master()
    active_subcomponent_id = 0

    with ta_admin_common_operations.create_shell_session_vcu(host) as connection:
        connection.send_shell_command("oc exec -it ute-{}-{}-{} -c ctr-{}-nwmgmt -n {} -- bash"
                                      .format(namespace, subcomponent, active_subcomponent_id, namespace, namespace))
        connection.send_shell_command("ip link set dev eth0 down")
        time.sleep(20)  # waiting for subcomponent recovery


def send_eth_up_to_cplane_subcomponent(subcomponent='cpcl'):
    logger.console("Starting recovery action for active Cplane subcomponent")
    namespace = ta5g_enb().get_namespace_for_vcu()
    host = ta5g_enb().get_ip_vcu_master()
    active_subcomponent_id = 0

    with ta_admin_common_operations.create_shell_session_vcu(host) as connection:
        connection.send_shell_command("oc exec -it ute-{}-{}-{} -c ctr-{}-nwmgmt -n {} -- bash"
                                      .format(namespace, subcomponent, active_subcomponent_id, namespace, namespace))
        connection.send_shell_command("ip link set dev eth0 up")
        time.sleep(10)  # waiting for subcomponent recovery

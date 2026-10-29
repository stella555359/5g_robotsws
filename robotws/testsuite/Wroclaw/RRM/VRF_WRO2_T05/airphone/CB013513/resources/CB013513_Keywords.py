import subprocess
import re
import time
from robot.libraries.BuiltIn import BuiltIn

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def check_traffic_on_every_scell(ue_id, scells_amount, traffic=True, traffic_stabilization=True):
    for scell in range(1, int(scells_amount)+1):
        scell_tput = get_scell_avg_dl_data_traffic(ue_id=ue_id,
                                                   scell=scell,
                                                   traffic_stabilization=traffic_stabilization)
        if int(scell_tput) == 0 and traffic is True:
            raise Exception("Scell_{} t-put is 0 Mbps".format(scell))
        elif int(scell_tput) != 0 and traffic is False:
            raise Exception("Scell_{} t-put: {} is higher than 0Mbps, should be 0Mbps".format(scell, float(scell_tput)))
        else:
            print("Scell_{} t-put: {} is higher than 0 Mbps".format(scell, float(scell_tput)))


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

from robot.libraries.BuiltIn import BuiltIn
import re

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def get_pdsch_ue_stats_for_given_cc(ue_id, cc):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type=pdsch scell={}'
                                                                       .format(ue_id, cc),
                                                                       pass_regexp='UE-{}: NR PDSCH Throughput'
                                                                       .format(ue_id))


def get_avg_dl_data_traffic_for_given_cc(ue_id, cc, unit):
    pdsch_ue_stats = get_pdsch_ue_stats_for_given_cc(ue_id, cc)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(pdsch_ue_stats)[-1][0]
    return float(avg_tput)


def verify_there_is_no_tput_on_scell(ue_id):
    pdsch_ue_stats = get_pdsch_ue_stats_for_given_cc(ue_id, cc='1')
    pattern = re.compile(r'\d')
    scell_tput = pattern.findall(pdsch_ue_stats)[-1][0]
    if int(scell_tput) == 0:
        print("Check passed, there is no data transmission on Scell")
    else:
        raise Exception("Scell tput {} is higher than 0".format(float(scell_tput)))

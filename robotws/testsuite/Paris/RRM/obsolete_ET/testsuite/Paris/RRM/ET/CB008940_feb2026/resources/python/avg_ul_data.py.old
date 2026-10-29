import re


def get_avg_ul_data_traffic(pusch_ue_stats, unit):
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(pusch_ue_stats)[-1][0]
    return float(avg_tput)


def verify_there_is_no_tput_on_scell(pusch_ue_stats):
    pattern = re.compile(r'\d')
    scell_tput = pattern.findall(pusch_ue_stats)[-1][0]
    if int(scell_tput) == 0:
        print("Check passed, there is no data transmission on Scell")
    else:
        raise Exception("Scell tput {} is higher than 0".format(float(scell_tput)))
    return scell_tput

import re


def get_avg_dl_data_traffic(pdsch_ue_stats, unit):
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(pdsch_ue_stats)[-1][0]
    return float(avg_tput)


def get_avg_ul_data_traffic(pusch_ue_stats, unit):
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(pusch_ue_stats)[-1][0]
    return float(avg_tput)

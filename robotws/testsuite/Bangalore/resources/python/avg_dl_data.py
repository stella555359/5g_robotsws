import re


def get_avg_dl_data_traffic(pdsch_ue_stats, unit):
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(pdsch_ue_stats)[-1][0]
    return float(avg_tput)


def verify_there_is_no_tput_on_scell(pdsch_ue_stats):
    pattern = re.compile(r'\d')
    scell_tput = pattern.findall(pdsch_ue_stats)[-1][0]
    if int(scell_tput) == 0:
        print("Check passed, there is no data transmission on Scell")
    else:
        raise Exception("Scell tput {} is higher than 0".format(float(scell_tput)))
    return scell_tput


def extract_average_throughput(pdsch_ue_stats, cellindex=None):
    def convert_to_mbps(value_with_unit):
        """Converts a string like '214.5 Mbps' or '1200 Kbps' to Mbps as float."""
        value, unit = value_with_unit.strip().split()
        value = float(value)
        if unit.lower() == 'kbps':
            return round(value / 1000, 3)
        return round(value, 3)

    # Regex for CellIndex row with optional specific index
    if cellindex is not None:
        pattern_cell = re.compile(
            rf'^CellIndex-{cellindex}\s+'                            # Match user-defined CellIndex
            r'(?:\d+(?:\.\d+)?\s+(?:[mMkK]bps)\s+){3}'          # Skip 3 columns
            r'(\d+(?:\.\d+)?\s+(?:[mMkK]bps))',                 # Capture Average value
            re.MULTILINE
        )
    else:
        pattern_cell = re.compile(
            r'^CellIndex-\d+\s+'                                # Match any CellIndex
            r'(?:\d+(?:\.\d+)?\s+(?:[mMkK]bps)\s+){3}'        # Skip 3 columns
            r'(\d+(?:\.\d+)?\s+(?:[mMkK]bps))',               # Capture Average value
            re.MULTILINE
        )

    # Regex for Total row (e.g., '0 cell' or '1 cell')
    pattern_total = re.compile(
        r'^\d+\s+cell\s+'                                      # Start with '<num> cell'
        r'(?:\d+(?:\.\d+)?\s+(?:[mMkK]bps)\s+){3}'           # Skip 3 columns
        r'(\d+(?:\.\d+)?\s+(?:[mMkK]bps))',                  # Capture Average value
        re.MULTILINE
    )

    match = pattern_cell.search(pdsch_ue_stats)
    if match:
        return convert_to_mbps(match.group(1))

    match = pattern_total.search(pdsch_ue_stats)
    if match:
        return convert_to_mbps(match.group(1))

    return None


def compare_pre_post_avg_data(pre_data, post_data):
    """
    :param pre_data: dictionary with per UE data before sgnb modification
    :param post_data: dictionary with per UE data after sgnb modification
    There will be degradation of tput post measurement gap setup. Maximum
    degradation will be 25%
    """
    for ue in pre_data.keys():
        total_avg_data_pre = sum(pre_data[ue])
        total_avg_data_post = sum(post_data[ue])
        print("total_avg_data_pre", total_avg_data_pre, "total_avg_data_post", total_avg_data_post)
        ratio_post_pre = total_avg_data_post/total_avg_data_pre
        print("ratio_post_pre", ratio_post_pre)
        if ratio_post_pre < 0.75:
            return 'Fail'
    return 'Pass'

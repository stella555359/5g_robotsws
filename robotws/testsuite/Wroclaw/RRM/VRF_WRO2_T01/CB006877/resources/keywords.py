from robot.api.deco import keyword


@keyword
def compare_tput_avg(feature_off_tput: str, feature_on_tput: str):
    if not float(feature_off_tput) <= float(feature_on_tput):
        raise Exception('No tput gain when feature is activated.')


@keyword
def compare_tput_avg_perc(feature_off_tput: str, feature_on_tput: str):
    max_perc_diff = 90
    current_perc_diff = float(feature_on_tput) / float(feature_on_tput) * 100

    if not current_perc_diff >= max_perc_diff:
        raise Exception("UL data should be less (to 7%) compared to actDynUlResAlloc=true.")

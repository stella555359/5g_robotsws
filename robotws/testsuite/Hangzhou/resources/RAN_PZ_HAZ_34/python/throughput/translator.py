def transfer_aasyslog_tput_format(origin_tput):
    translated = {}
    for data in origin_tput:
        translated[data["cellid"]] = data
    return translated


def translate_percentage(origin_percent):
    percent = str(origin_percent)
    if "%" in percent:
        target_percent = float(percent.replace("%", "")) / 100.0
    else:
        target_percent = float(percent)
    return target_percent

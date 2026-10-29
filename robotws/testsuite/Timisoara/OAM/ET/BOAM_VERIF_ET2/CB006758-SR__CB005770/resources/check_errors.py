def get_errors(error_msg, beamset, bts_id, msg):
    beamset_number = beamset.split('_')[1]
    error_list = error_msg["MRBTS-" + bts_id]
    length = len(error_list)
    i = 0
    for i in range(length):
        if "BeamSet-" + beamset_number not in error_list[i]:
            i = i + 1
        else:
            break
    print(error_list[i])
    if msg in error_list[i]:
        return True


def get_errors_common(error_msg, module, msg):
    try:
        error_list = error_msg[module]
        for item in error_list:
            if msg in item:
                return True
        return False
    except(Exception):
        return False


def get_path(str1):
    str2 = str1.rstrip('/Resources')
    return str2

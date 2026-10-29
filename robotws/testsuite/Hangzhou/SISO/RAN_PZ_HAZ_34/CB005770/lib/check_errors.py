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
    if not error_msg:
        return False
    error_list = error_msg[module]
    for error in error_list:
        if type(msg) == list:
            for item in msg:
                if item.lower() in error.lower():
                    return True
        else:
            if msg.lower() in error.lower():
                return True
    return False


def get_path(str1):
    str2 = str1.rstrip('/Resources')
    return str2

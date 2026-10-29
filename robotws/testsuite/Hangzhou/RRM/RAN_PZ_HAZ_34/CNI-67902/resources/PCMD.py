import math


def get_pcmd_list(log_path='${pcmd_log_path}/pcmd'):
    with open(log_path) as f:
        file_details = f.read()
    pcmd_list = file_details.split()
    return pcmd_list


def get_pcmd_line_nu(all_length='${all_length}'):
    all_length = math.ceil(all_length/16)
    return all_length


def get_pcmd_str_hex(pcmd_hex='${pcmd_data}'):
    s = ""
    return s.join(pcmd_hex)


def hex_to_dec(hex='${pcmd_hex}'):
    pcmd_dec = str(int(hex.upper(), 16))
    return pcmd_dec

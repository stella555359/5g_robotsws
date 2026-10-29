# msg_type -> string, value -> list
def is_value_existed(dic, msg_type, value):
    if not isinstance(dic, dict) or msg_type not in dic or not \
            isinstance(dic[msg_type], list) or not isinstance(value, list):
        return False

    return True if not len(list(filter(lambda x: x not in dic[msg_type], value))) else False


def convert_to_hex_code_for_9193(ec):
    strerror = str(hex(ec))
    cuterrorcode = strerror[2:]
    fillerrorcode = cuterrorcode.zfill(4)
    code = '0x23E9' + fillerrorcode
    return int(code, 16)

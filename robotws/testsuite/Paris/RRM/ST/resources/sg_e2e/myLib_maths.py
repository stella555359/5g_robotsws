import string


def is_value_equal(var1, var2):
    if var1 == var2:
        return True
    else:
        return False


def hex_addition(var1, var2):
    return (hex(int(var1, 16) + int(var2, 16)))


def hex_multiplication(var1, var2):
    return (hex(int(var1) * int(var2)))


def comparison(value, threshold, comparison_type):
    if comparison_type == '>=':
        if value >= threshold:
            return True
        else:
            return False
    if comparison_type == '>':
        if value > threshold:
            return True
        else:
            return False
    if comparison_type == '<=':
        if value <= threshold:
            return True
        else:
            return False
    if comparison_type == '<':
        if value < threshold:
            return True
        else:
            return False


def formated_hex_string(var):
    '''For Wireshark version <= 2.6'''
    dec_v = int(var, 16)
    v1 = dec_v % 256
    v2 = (dec_v-v1)/256
    str = '{:02x}:{:02x}'.format(v1, v2)
    return str


def formated_hex_string_v2(var):
    '''For Wireshark version <= 3.0'''
    dec_v = int(var, 16)
    v1 = dec_v % 256
    v2 = (dec_v-v1)/256
    str = '{:02x}{:02x}'.format(v1, v2)
    return str

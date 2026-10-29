import re


def get_pmtu(output_str):
    pattern = re.compile(r'Resume: pmtu (\w+)')
    result = re.search(pattern, output_str)
    return result.group(1)


def swith_number_to_16(list):
    for i in range(0, len(list)):
        list[i] = str(int(list[i], 16))
    return list

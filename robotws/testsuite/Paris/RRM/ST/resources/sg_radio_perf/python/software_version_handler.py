import string
import re


def prepare_software_version(str_to_parse):
    list_str_to_parse = str_to_parse.split("_")
    parsed_str = ""
    for index, i in enumerate(list_str_to_parse):
        if index != 0:
            parsed_str += "."
        if re.match('^[0]+$', i):
            parsed_str += "0"
        else:
            parsed_str += i.lstrip("0")
    return parsed_str

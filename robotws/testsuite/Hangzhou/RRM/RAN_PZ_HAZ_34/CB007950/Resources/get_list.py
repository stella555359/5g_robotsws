from robot.libraries.BuiltIn import BuiltIn
import re
from get_list import *


def get_numOfBits_list(return_value):
    for i in range(0, len(return_value)):
        if return_value[i] > 1:
            return_value[i] = 1
        else:
            return_value[i] = 0
    return return_value


def get_modulationType_list(return_list):
    list_Information = []
    for i in range(len(return_list)):
        if len(return_list[i]) == 1:
            list_Information.append(return_list[i])
        else:
            list_Information.append(return_list[i][0])
    return list_Information

import math
from robot.libraries.BuiltIn import BuiltIn
import re
import random
import time

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def create_ues_list(ue_start, ue_stop):
    ue_list = []
    for item in range(ue_start, ue_stop+1):
        ue_list.append(item)
    return ue_list


def create_list_of_reestablished_ues(ue, ue_list):
    ue_list.append(ue)
    return ue_list

# contact: sebastian.mikos@nokia.com

import re
import os


def get_counter_value(counters_list, cell_id, counter_id):
    for counter in counters_list:
        if counter_id in counter.keys():
            temp = counter.get(counter_id)
            value = temp.get(cell_id)
            print(value)
    return value

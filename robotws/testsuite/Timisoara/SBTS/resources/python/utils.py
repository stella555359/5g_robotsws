import csv
import sys
import re
import os
import ast
import time
import json
from taf.transport.ssh import ssh


def find_existing_counters(data, counter_list):
    found = set()
    if isinstance(data, dict):
        for k, v in data.items():
            if k in counter_list:
                found.add(k)
            found.update(find_existing_counters(v, counter_list))
    elif isinstance(data, list):
        for item in data:
            found.update(find_existing_counters(item, counter_list))
    return found


def check_all_counter_exist(counter_details, counter_ids):
    counter_list = counter_ids.split(",")
    existing_counters = find_existing_counters(counter_details, counter_list)

    print("Found counters:", existing_counters)
    print("Missing counters:", set(counter_list) - existing_counters)

    counter_exist = set(counter_list).issubset(existing_counters)

    return counter_exist

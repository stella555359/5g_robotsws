import os
import logging
import json
import re
from itertools import islice
from taf.converters.tshark import TsharkConverterFactory


def get_last_item(input_string, starting_item):
    global json_str
    # starting_string = '{"' + starting_item + '":'
    starting_string = starting_item + '":'
    start_idx = input_string.find(starting_string)
    match_found = False
    while start_idx != -1 and not match_found:
        end_idx_match, end_idx = find_matching_brace(input_string, start_idx)
        if end_idx == -1 and end_idx_match == -1:
            break

        json_str = input_string[start_idx:end_idx_match + 1]
        start_idx = input_string.find(starting_string, end_idx_match + 1)
        if start_idx > 0:
            match_found = True

    # print(json_str)
    last_item = find_last_occurrence('\"(.*?)\":', json_str)
    return last_item


def find_matching_brace(s, start):
    count = 1
    for i in range(start + 1, len(s)):
        if s[i] == '{':
            count += 1
        elif s[i] == '}':
            count -= 1
            if count == 0:
                return i, -1
    return -1, -1


def find_last_occurrence(pattern, input_string):
    matches = re.findall(pattern, input_string)
    if matches:
        return matches[-1]
    else:
        return None


class ConverterFactory(TsharkConverterFactory):
    def _create_builtin(self):
        raise AssertionError


def decode_events_using_tskark_decoder(file_name, num_of_events=None):
    filtered_events = []
    factory = ConverterFactory()
    base_name, _ = os.path.splitext(file_name)
    directory_path = os.path.dirname(file_name)
    help(factory)
    converter = factory.create(
        configuration=dict(
            file_path_pattern=file_name,
            output_directory=directory_path,
            options="-Y dldata_csirssendreq -T json",
            output_extension=".json"),
        existing_arguments={})
    converter.convert()

    # factory.create_tshark_converter(name="tshark",
    #                                 file_path_pattern=file_name,
    #                                 output_directory="/home/ute/csamson/TRACES",
    #                                 options="-T json",
    #                                 output_extension=".json")
    # factory.setup("tshark")
    # factory.convert("tshark")
    # factory.teardown("tshark")

    with open(base_name + ".json", 'r') as file_obj:
        dict_read = file_obj.read()
        # Convert string to Python dict
        data = json.loads(dict_read, object_pairs_hook=array_on_duplicate_keys)
        for item in islice(data, num_of_events):
            filtered_events.append(item['_source']['layers']['icom_5g'])
        # for item in data:
        #     # print(item)
        #    filtered_events.append(item['_source']['layers']['icom_5g'])

    return filtered_events


def pcapeventextractor(file_name, num_of_events=None):
    return decode_events_using_tskark_decoder(file_name, num_of_events=num_of_events)


def array_on_duplicate_keys(ordered_pairs):
    """Convert duplicate keys to arrays."""
    d = {}
    for k, v in ordered_pairs:
        if k in d:
            if type(d[k]) is list:
                d[k].append(v)
            else:
                d[k] = [d[k], v]
        else:
            d[k] = v
    return d


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    file = "/home/ute/csamson/TRACES/TRY.json"
    with open(file, 'r') as file_obj:
        dict_read_ = file_obj.read()
        # data_file = json.load(file_obj)
    data_ = json.loads(dict_read_, object_pairs_hook=array_on_duplicate_keys)
    filtered_events = []
    num_of_events = 10
    for item in islice(data_, num_of_events):
        filtered_events.append(item['_source']['layers']['icom_5g'])

    file = "/home/ute/csamson/TRACES/L1L2Bip.wDLTput.CB009936_TC01_UL_.2024-03-18-16_58_16.105.pcap"
    filtered_events = pcapeventextractor(file_name=file, num_of_events=10)

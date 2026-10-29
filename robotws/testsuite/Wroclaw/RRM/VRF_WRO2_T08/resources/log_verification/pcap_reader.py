import json
import subprocess


def load_pcap(input_pcap, tshark_fields=tuple(), output_json_file="/tmp/tshark_output.json"):
    filter_argument = _create_tshark_filter_argument(tshark_fields=tshark_fields)
    with open(output_json_file, 'w+') as output_file:
        subprocess.call(('tshark', '-V', '-T', 'json', *filter_argument, '-r', input_pcap), stdout=output_file)
    with open(output_json_file, 'r') as json_to_load:
        loaded = json.load(json_to_load)
    return loaded


def _create_tshark_filter_argument(tshark_fields):
    filter_argument = []
    for field in tshark_fields:
        filter_argument.append('-e')
        filter_argument.append(field)
    return filter_argument

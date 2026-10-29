import json


def load_json_delta(delta_filepath):
    with open(delta_filepath) as f:
        return json.load(f)


def save_delta_to_json_file(delta, delta_filepath):
    with open(delta_filepath, 'w') as f:
        json.dump(delta, f)
    return delta_filepath


def merge_delta(delta1: list, delta2: list):
    return delta1 + delta2

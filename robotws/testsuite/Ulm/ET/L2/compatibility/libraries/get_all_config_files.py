import json
import logging
import re
from pathlib import Path


python_file_pattern = re.compile(r'.*\.py$')


def is_json_config(json_path):
    with open(json_path, 'r') as json_file:
        try:
            json_object = json.load(json_file)
        except json.decoder.JSONDecodeError:
            return False
        try:
            if "test_description" in json_object.keys():
                return True
        except AttributeError:
            logging.info("%s is not a teal file", json_file)
            return False


def is_python_config(python_path):
    try:
        with open(python_path, 'r') as python_file:
            for index, line in enumerate(python_file.readlines()):
                if 'testsuite.Ulm.ET.L2.libraries.config_file_helper' in line:
                    return True
                if index > 5:
                    return False
    except UnicodeDecodeError:
        print(f'This file does not conform to utf-8: {python_path}')
    return False


def get_json_file_paths(directory):
    teal_files = []
    for path in walk(Path(directory)):
        if '.json' in path.name:
            if is_json_config(path):
                teal_files.append(path)
    return teal_files


def get_python_config_file_paths(directory):
    teal_files = []
    for path in walk(Path(directory)):
        if re.match(python_file_pattern, path.name):
            if is_python_config(path):
                teal_files.append(path)
    return teal_files


def get_config_files(directory):
    config_files = get_json_file_paths(directory)
    config_files.extend(get_python_config_file_paths(directory))
    return config_files


def walk(path):
    for p in Path(path).iterdir():
        if p.is_dir():
            yield from walk(p)
            continue
        yield p.resolve()


if __name__ == "__main__":
    directory_to_search = 'robotws/testsuite/Ulm/ET'
    teal_files = get_teal_json_file_paths(directory_to_search)

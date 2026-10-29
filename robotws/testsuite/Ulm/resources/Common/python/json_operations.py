import json
import pathlib
import os


def write_dictionary_to_json(var, file_path):
    os.makedirs(pathlib.Path(file_path).parent, exist_ok=True)
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(var, f, indent=4)

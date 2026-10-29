import json


def update_key_value_in_json_file(json_file, key, value):
    with open(json_file, "r") as fr:
        my_json = json.loads(fr.read())
        my_json[key] = float(value)
    with open(json_file, "w") as fw:
        fw.write(json.dumps(my_json, indent=4))

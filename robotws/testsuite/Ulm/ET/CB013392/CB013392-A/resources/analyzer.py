# before running this script, run the commissioning with:

# python /testsuite/Ulm/ET/CB013392/CB013392-A/libraries/CB013392_A_B1_commissioning.py" >
# ~/logs/CB013392_A_B1/commissioning/admin_output.txt

# from within:
# /home/ute/DEVELOPMENT/robotws

# Then run: python testsuite/Ulm/ET/CB013392/CB013392-A/resources/analyzer.py

import json
import os


def read_file(path):
    with open(path, 'r') as f:
        file_content = f.read()
    return file_content


def write_file(path, content):
    with open(path, 'w') as f:
        f.write(content)


def get_after_status_reached(data):
    return data[data.find('Status reached'):]


def strip_data(data: str):
    first_curly = data.find('{')
    last_curly = data.rfind('}')
    return data[first_curly:last_curly] + '}'


if __name__ == '__main__':
    file_path = r'/home/ute/logs/CB013392_A_B1/commissioning/'
    file_content = read_file(os.path.join(file_path, 'admin_output.txt'))
    response = get_after_status_reached(file_content)
    write_file(os.path.join(file_path, 'result.py'), strip_data(response))
    result_dict = eval(strip_data(response))
    with open(os.path.join(file_path, 'result.json'), 'w', encoding='utf-8') as json_file:
        json.dump(result_dict, json_file, indent=4)

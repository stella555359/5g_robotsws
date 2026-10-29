import argparse
import json
import re

CONST_NO_TIMESTAMP_STR = '[ERROR] no timestamps found!'


def generate_csv(filepath='emperf_traffic.txt', target='emperf_eorun.csv', container=''):
    csv_lines = _convert_timestamp_blocks_to_eorun_arr(
        _get_all_timestamp_blocks(filepath),
        container)
    with open(target, "w") as csv_filestream:
        for csv_line in csv_lines:
            csv_filestream.write(f"{csv_line}\r\n")
    return target


def compute_data_from_csv(csv, target, container=''):
    with open(csv, 'r') as csv_stream:
        CONST_HEADER = csv_stream.readline()
        data = _create_data_dict(1, container)
        del data['disp_0']['sum']  # they don't want this data
        if CONST_NO_TIMESTAMP_STR in CONST_HEADER:
            data['error'] = CONST_NO_TIMESTAMP_STR
        else:
            CONST_DISPS_COUNT = len(CONST_HEADER.split(',')) - 1
            data = _read_all_data_from_csv(csv_stream, CONST_DISPS_COUNT, container)
    with open(target, 'w') as json_target:
        json_target.write(json.dumps(data, indent=4))
    return data


# private
def _get_all_timestamp_blocks(filepath):
    timestamp_blocks = []
    with open(filepath, 'r') as emperf_filestream:
        while True:  # read until eof
            cur_line = emperf_filestream.readline()
            if not cur_line:
                break
            if 'timestamp' in cur_line.lower():
                timestamp_blocks.extend(
                    _read_from_eo_headers(emperf_filestream, cur_line))
    return timestamp_blocks


def _convert_timestamp_blocks_to_eorun_arr(timestamp_blocks, container):
    if len(timestamp_blocks) <= 0:
        return [CONST_NO_TIMESTAMP_STR]
    CONST_NUM_LINES_TILL_FIRST_DISP = 1
    CONST_EORUN_COLUMN_INDEX = 6
    CONST_NUMBER_OF_DISPS = len(
        timestamp_blocks[0]) - CONST_NUM_LINES_TILL_FIRST_DISP
    rows = []
    # Set the Headers
    header = 'Timestamp'
    for count in range(0, CONST_NUMBER_OF_DISPS):
        header = f"{header}, disp_{count} ({get_component_name(container, f'disp_{count}')})"
    rows.append(f"{header}")
    cur_row = ''
    for block in timestamp_blocks:
        cur_row = block[0].split(' ')[1].translate(
            {ord(i): '' for i in ' ,\n<>'})
        for line in range(CONST_NUM_LINES_TILL_FIRST_DISP, (CONST_NUMBER_OF_DISPS+CONST_NUM_LINES_TILL_FIRST_DISP)):
            cur_row = f"{cur_row},{block[line].split(',')[CONST_EORUN_COLUMN_INDEX].replace(' ', '')}"
        rows.append(f"{cur_row.replace('%', '')}")
    return rows


def _read_from_eo_headers(emperf_filestream, timestamp):
    timestamp_blocks = []
    event_row_pattern = re.compile(
        r"^Event receive stats on SNF.*Total events.[0-9]+")
    disp_header_pattern = re.compile(r"^\s*Disp,.*EOrun.,.*")
    while True:  # read until we find the eorun headers
        event_row_tmp = emperf_filestream.readline()
        disp_header_tmp = emperf_filestream.readline()
        if event_row_pattern.match(event_row_tmp) and disp_header_pattern.match(disp_header_tmp):
            timestamp_blocks.append(
                _read_all_disps_value(emperf_filestream, timestamp))
            break
        if not disp_header_tmp:
            break
    return timestamp_blocks


def _read_all_disps_value(emperf_filestream, timestamp):
    # read until all disps are stored
    disp_row_pattern = re.compile(r"^\s*[0-9]+,")
    disps_values = []
    disps_values.append(timestamp)
    cur_line = emperf_filestream.readline()
    while disp_row_pattern.match(cur_line):
        disps_values.append(cur_line)
        cur_line = emperf_filestream.readline()
    return disps_values


def _read_all_data_from_csv(csv_stream, disps_count, container):
    data = _create_data_dict(disps_count, container)
    while True:  # read all data from csv
        cur_line = csv_stream.readline()
        if not cur_line:
            break
        data['total_row'] = data['total_row']+1
        columns = cur_line.split(',')
        del columns[0]  # remove timestamp column
        for i, column in enumerate(columns):
            disp = f'disp_{i}'
            f_column = float(column)

            data[disp]['sum'] = round(data[disp]['sum']+f_column, 2)
            # find min and max
            if data[disp]['minimum'] > f_column:
                data[disp]['minimum'] = f_column
            if data[disp]['maximum'] < f_column:
                data[disp]['maximum'] = f_column
    # compute for average
    for disp in data:
        if 'disp' not in disp:
            continue
        data[disp]['average'] = round(
            data[disp]['sum'] / data['total_row'], 2)
        del data[disp]['sum']  # they don't want this data
    return data


def get_component_name(container, disp):
    return {
        "0x1730": {
            "disp_0": "L2-LO",
            "disp_1": "L2-LO",
            "disp_2": "L2-PS",
            "disp_3": "L2-PS",
            "disp_4": "L2-PS",
            "disp_5": "L2-PS",
            "disp_6": "L2-PS",
            "disp_7": "L2-PS",
            "disp_8": "L2-PS"
        },
        "0x1731": {
            "disp_1": "L2-HI",
            "disp_2": "L2-HI"
        },
        "0x1732": {
            "disp_0": "L2-LO",
            "disp_1": "L2-LO",
            "disp_2": "L2-PS",
            "disp_3": "L2-PS",
            "disp_4": "L2-PS",
            "disp_5": "L2-PS",
            "disp_6": "L2-PS",
            "disp_7": "L2-PS",
            "disp_8": "L2-PS"
        },
        "0x1733": {
            "disp_1": "L2-HI",
            "disp_2": "L2-HI"
        },
    }.get(container, {}).get(disp, 'unknown')


def _create_data_dict(disps_count, container):
    data = {
        'total_row': 0,
        'error': 'none'
    }
    for i in range(disps_count):
        component = get_component_name(container, f'disp_{i}')
        data[f'disp_{i}'] = {
            'average': 0,
            'sum': 0,
            'minimum': 999,  # possible max is 100 percent;
            'maximum': -1,
            'component': component
        }
    return data


if __name__ == "__main__":
    print('start emperf_eorun_to_csv.py')
    parser = argparse.ArgumentParser(description='emperf_eorun_to_csv.py')
    parser.add_argument('--emperf_file', default='emperf.txt')
    parser.add_argument('--target_csv_dir', default='emperf_eorun.csv')
    parser.add_argument('--target_average_dir',
                        default='emperf_eorun_average.json')
    parser.add_argument('--container',
                        default='')
    args = parser.parse_args()

    csv = generate_csv(filepath=args.emperf_file,
                       target=args.target_csv_dir, container=args.container)
    compute_data_from_csv(csv, args.target_average_dir,
                          container=args.container)
    print('end emperf_eorun_to_csv.py')

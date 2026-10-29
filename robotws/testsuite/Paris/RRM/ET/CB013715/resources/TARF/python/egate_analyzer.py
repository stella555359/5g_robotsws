
import logging
import json
import re


def get_message(line_start, content):
    message_lines = []
    for line_no, line in enumerate(content[line_start+1:]):
        if line != '\n':
            message_lines.append(line.strip())
        if '}' in line:
            break
    without_brackets = message_lines[1:-1]
    message_dict = {}
    pattern_value = re.compile(r"(\w+),?$")
    for line in without_brackets:
        value = re.findall(pattern_value, line)[0]
        key = line.replace(value, '').replace(':', '').replace(',', '').strip()
        message_dict.update({key: value})
    return message_dict


def analyze_egate_output(egate_output, target_file_path, ue_id, regex_search=[r'eventId event[A,B]\d']):
    with open('/tmp/egate_output.txt', 'w') as write_to_file:
        write_to_file.write(egate_output)
    with open('/tmp/egate_output.txt', 'r') as read_from_file:
        egate_output = read_from_file.readlines()
    patterns = [re.compile(regex) for regex in regex_search]
    events = {}
    for line_no, line in enumerate(egate_output):
        event = None
        for pattern in patterns:
            event = re.search(pattern, line)
            if event:
                events.update({event.group(): {
                    'line_start': line_no}})
    for event_data in events.values():
        event_data.update({'message': get_message(event_data['line_start'], egate_output)})
    update_target_file(target_file_path, {ue_id: events})
    logging.info('Found events: %s', events)
    return events


def update_target_file(target_file_path, events):
    try:
        with open(target_file_path, 'r', encoding='utf-8') as input_file:
            current_content = json.load(input_file)
    except FileNotFoundError:
        logging.info('target file for ue_attach events not yet existing, creating now.')
        current_content = {}
    current_content.update(events)
    with open(target_file_path, 'w', encoding='utf-8') as output_file:
        json.dump(current_content, output_file, indent=4)

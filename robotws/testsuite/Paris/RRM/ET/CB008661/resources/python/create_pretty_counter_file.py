import os
import sys
from taf.analyzer.pmcounter import PMCounterLogReader


def read_counter_definitions(counter_def_file_name):
    counter_descriptions = {}
    with open(counter_def_file_name, "r") as counter_definitions:
        for line in counter_definitions.readlines():
            if line.startswith("#"):
                continue
            line_split = line.split(";")
            counter_id = line_split[0].strip()
            counter_descriptions[counter_id] = line_split[1].strip()
    return counter_descriptions


def get_counter_description(counter_id, counter_descriptions):
    counter_description = "UNKNOWN"
    counter_nidd = counter_id.split('@')[-1]
    # print(counter_nidd)
    if counter_nidd in counter_descriptions:
        counter_description = counter_descriptions[counter_nidd]
    return counter_description


def parse_counters(log_entry, readable_file, counter_descriptions):
    pm_setup = log_entry.pm_setup
    print(f"PM interval start timestamp: {log_entry.timestamp}")
    for path in pm_setup.paths():
        counter_values = pm_setup.xpath(path)
        counter_value = counter_values[0]
        counter_description = get_counter_description(path, counter_descriptions)
        readable_file.write(f"{path};{counter_value};{counter_description}\n")


def create_pretty_counter_file(counter_file_name_with_path, destination_path, counter_def_file_name):
    os.makedirs(destination_path, exist_ok=True)
    counter_descriptions = read_counter_definitions(counter_def_file_name)
    counter_file_name = counter_file_name_with_path.split('/')[-1]
    pretty_file_name = counter_file_name.replace(".xml", ".csv")
    counter_file = open(counter_file_name_with_path, "rb")
    pretty_file = open(destination_path + "/" + pretty_file_name, "w")
    last_log_entry = None
    for log_entry in PMCounterLogReader(file_obj_iterator=[counter_file]):
        last_log_entry = log_entry
    if last_log_entry is not None:
        parse_counters(last_log_entry, pretty_file, counter_descriptions)
    counter_file.close()
    pretty_file.close()
    return pretty_file_name.replace(".csv", "")


if __name__ == '__main__':
    create_pretty_counter_file(sys.argv[1], sys.argv[2], sys.argv[3])

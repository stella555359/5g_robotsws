from testsuite.Krakow.resources.from_wroclaw.resources.log.log import blog
import os
import fnmatch
import itertools
import re


from testsuite.Krakow.resources.from_wroclaw.resources.tti_verification.process_msg_func import \
    strip_and_zip_at, \
    skip_body, \
    return_unprocessed, \
    default_process_csv_message, \
    process_dlTdSchedSubcellData, \
    process_array_message

default_process_func = {
    'default': default_process_csv_message,
    'return_unprocessed': return_unprocessed,
    'skip_body': skip_body,
    'strip_and_zip_at': strip_and_zip_at,
}

uncommon_process_func = {'dlTdSchedSubcellData': process_dlTdSchedSubcellData,
                         'dlLaDeltaCqiArray': process_array_message,
                         'dlHarqRxDataArray': process_array_message}

process_func = dict(default_process_func, **uncommon_process_func)


def yield_lines_from_file(in_path):
    """
    open file and yields non empty lines

    :param in_path: string
    :return: generator returning string
    """
    line_count = 0
    with open(in_path) as f:
        for line in (line.strip() for line in f):
            if line:
                line_count += 1
                yield line, line_count


def create_processes_dict_for_needed_messages(message_names):
    processes = {}
    for message in message_names:
        if message in uncommon_process_func.keys():
            processes[message] = uncommon_process_func[message]
        else:
            processes[message] = default_process_csv_message
    return processes


def get_messages_from_ul_dl_csv_file(
        in_path,
        patterns_process_functions,
        message_name_to_body_separator=': ',
        regex_match=fnmatch.fnmatch,
):
    """
    returns generator of [ {message_dict}, {message_dict}, ... ] while
    filtering message names by pattern using fnmatch by default
    expects patterns_process_functions to be like:
    { 'message_name_pattern': process_function, ... }
    process_function is expected to take message_body as parameter
    and return dictionary while regex_match is expected
    to take string and pattern as parameter and return bool
    returned list has  one dictionary per message that
    always have field 'message_name' containing message name and field 'line_number' containing
    number of line in csv file of message

    :param in_path: path to csv file
    :param patterns_process_functions: dict {message_name_pattern: process_function, ...}
    :param message_name_to_body_separator: string
    :param regex_match: function matching regex, must returning bool
    :return: generator of message dictionaries
    """
    return list(get_messages_from_ul_dl_csv_file_as_generator(
        in_path=in_path, patterns_process_functions=patterns_process_functions,
        message_name_to_body_separator=message_name_to_body_separator, regex_match=regex_match))


def process_needed_messages(filepath, message_names):
    """
    processes the needed messages from csv files into list of dictionaries with data of those messages
    :param filepath: string with path to file(s)
    :param message_names: a list of strings containing names of messages we want to process
    :return: list of dictionaries of arguments and values of each message we found that was in the message_names list
    """
    return list(process_needed_messages_as_generator(filepath=filepath, message_names=message_names))


def get_messages_from_ul_dl_csv_file_as_generator(
        in_path,
        patterns_process_functions,
        message_name_to_body_separator=': ',
        regex_match=fnmatch.fnmatch,
):
    """
    lookup get_messages_from_ul_dl_csv_file - works same but as a generator
    """
    def _get_process_function():
        for pattern in patterns_process_functions.keys():
            if regex_match(message_name, pattern):
                return patterns_process_functions[pattern]
        return None

    for line, ind in yield_lines_from_file(in_path):
        message_name, message_body = line.split(message_name_to_body_separator, 1)
        process = _get_process_function()
        if process:
            message = {'message_name': message_name, 'line_number': ind}
            message_body = process(message_body)
            if isinstance(message_body, list):
                for msg in message_body:
                    message.update(msg)
                    yield message
                    message = {'message_name': message_name, 'line_number': ind}
            else:
                message.update(message_body)
                yield message


def process_needed_messages_as_generator(filepath, message_names):
    """
    lookup 'processes the needed messages' - works same but as a generator
    """
    processes = create_processes_dict_for_needed_messages(message_names)
    return get_messages_from_ul_dl_csv_file_as_generator(in_path=filepath, patterns_process_functions=processes)


def get_csv_messages_from_dir(path, patterns_process_functions):
    """
    gets all messages from all csv files in path

    :param path:
    :param patterns_process_functions: look at get_messages_from_ul_dl_csv_file function
    :return: list of message dictionaries
    """
    files_paths = get_files_filepaths_in(path, with_pattern='*.csv')
    list_of_file_message_sublists = [
        get_messages_from_ul_dl_csv_file(file_path, patterns_process_functions)
        for file_path
        in files_paths
    ]
    all_messages = list(itertools.chain(*list_of_file_message_sublists))
    blog('processed {} messages'.format(len(all_messages)))
    return all_messages


def get_files_filepaths_in(path, with_pattern='*'):
    """
    gets all paths to files that match with_pattern

    :param path: str to dir
    :param with_pattern: str, fnmatch filename pattern
    :return: [ 'path/to/file/one.xyz', 'path/to/file/two.xyz' ... ]
    """
    return [
        path + name
        for name in os.listdir(path)
        if fnmatch.fnmatch(name, with_pattern)
    ]


def filter_list_of_dicts(key, val, array):
    """
    :param key: key
    :param val: val
    :param array: list of dicts
    :return: returns list of dicts that have key == val
    """
    return list(filter_list_of_dicts_as_generator(key=key, val=val, array=array))


def filter_list_of_dicts_as_generator(key, val, array):
    """
    lookup 'filter_list_of_dicts' - this function does the same only as a generator
    """
    for msg in array:
        if (key, val) in msg.items():
            yield msg


def combine_csv_files_in(path, output_file='combined_tti.csv', with_pattern='*.dlAndUl.csv'):
    """
    combines all csv files in path and saves new file to save_to_path
    output file saves file path which it is run from

    :param path: str
    :param output_file: str
    :param with_pattern: input either '*.ul.csv', '*.dl.csv', '*.dlAndUl.csv'
    """

    def natural_sort(lst):
        def convert(text): return int(text) if text.isdigit() else text.lower()

        def alphanum_key(key): return [convert(c) for c in re.split('([0-9]+)', key)]
        return sorted(lst, key=alphanum_key)

    all_files = os.listdir(path)
    needed_files = []
    for file in all_files:
        if fnmatch.fnmatch(file, with_pattern):
            needed_files.append((str(path) + '/' + str(file)).replace(' ', ''))
    files_paths = natural_sort(needed_files)
    with open(output_file, 'w') as combined_file_csv:
        for file_path in files_paths:
            for line, _ in yield_lines_from_file(file_path):
                combined_file_csv.write(line + '\n')
    blog('combined {} into {}'.format(files_paths, output_file))


def get_list_of_dlandul_tti_csvs(cmd_output):
    """
    finds all ...dlAndUl.csv files from ABIL

    :param cmd_output: directory on ABIL where tti trace logs are stored
    :return: list of filename strings that matched the pattern
    """
    files = []
    lines = cmd_output.splitlines()
    for line in lines:
        if 'dlAndUl' in line:
            files.append(line)
    return files


def modify_events_collector_file(events_collector_file, max_files):
    with open(events_collector_file, 'r+') as f:
        contents = f.readlines()
        relevant_line_idx = find_delete_after_line(contents)
        contents[relevant_line_idx] = 'DELETE_AFTER=' + max_files
        f.seek(0)
        f.writelines(contents)


def find_delete_after_line(contents):
    for idx, line in enumerate(contents):
        if fnmatch.fnmatch(line, 'DELETE_AFTER=*'):
            return idx

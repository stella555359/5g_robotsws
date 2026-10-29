import io
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.tti_body_process_func import \
    process_TdSchedSubcellData, \
    process_array_message, \
    strip_and_zip_at, \
    default_tti_process_message, \
    return_unprocessed, \
    skip_body

default_process_func = {
    'default': default_tti_process_message,
    'return_unprocessed': return_unprocessed,
    'skip_body': skip_body,
    'strip_and_zip_at': strip_and_zip_at,
}

uncommon_process_func = {'dlTdSchedSubcellData': process_TdSchedSubcellData,
                         'ulTdSchedSubcellData': process_TdSchedSubcellData,
                         'dlLaDeltaCqiArray': process_array_message,
                         'dlHarqRxDataArray': process_array_message}

process_func = dict(default_process_func, **uncommon_process_func)


def get_process_function_for_specific_message(message_name):
    if message_name in uncommon_process_func.keys():
        return uncommon_process_func[message_name]
    else:
        return default_tti_process_message


def process_needed_messages(filepath, relevant_messages=None):
    """
    Process the needed messages from csv files into list of events in the form of dictionaries.
    Special keys of the dictionaries:
        message_name: name of the TTI event.
        line_number: line index in TTI file.
    """
    return list(process_needed_messages_as_generator(filepath=filepath, relevant_messages=relevant_messages))


def process_needed_messages_as_generator(filepath, relevant_messages):
    return get_messages_from_ul_dl_csv_file_as_generator(in_path=filepath, relevant_messages=relevant_messages)


def get_messages_from_ul_dl_csv_file_as_generator(in_path, relevant_messages):
    for line, ind in yield_lines_from_file(in_path):
        message_name, message_body = line.split(': ', 1)
        if relevant_messages is None or message_name in relevant_messages:
            process = get_process_function_for_specific_message(message_name)

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


def yield_lines_from_file(in_path):
    """Open file and yield non empty lines."""
    line_count = 0
    with io.open(in_path, errors='ignore') as f:
        for line in (line.strip() for line in f):
            if line:
                line_count += 1
                yield line, line_count

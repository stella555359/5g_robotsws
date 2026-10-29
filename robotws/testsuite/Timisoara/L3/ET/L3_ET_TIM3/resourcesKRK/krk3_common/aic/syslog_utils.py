from datetime import datetime
import re


def sort_syslogs_in_file(filepath):
    with open(filepath, 'r+') as log_file:
        syslog_lines = log_file.readlines()
        sorted_syslog = sort_syslogs_list(syslog_lines)
        log_file.seek(0)
        log_file.truncate()
        log_file.writelines(sorted_syslog)


def sort_syslogs_list(syslogs_list):
    datetime_pattern = r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+'
    return sorted(
        syslogs_list, key=lambda line: datetime.strptime(
            re.findall(datetime_pattern, line)[0], '%Y-%m-%dT%H:%M:%S.%f'
        )
    )

import re
import os
import argparse
import shutil
import gzip
from datetime import datetime


def parse_log(log_file, pattern_include_file, pattern_exclude_file, output_file):
    # read patterns from file patternInclude
    pattern = r"(?P<PATH>.+)\/(?P<file_name>[^\/]+).(?P<current_date>\d{8}_\d{2}h\d{2})\.INCLUDE\.log"
    match = re.match(pattern, output_file)
    if match:
        PATH = match.group('PATH')
        file_name = match.group('file_name')
        current_date = match.group('current_date')

        print(f"PATH: {PATH}")
        print(f"file_name: {file_name}")
        print(f"current_date: {current_date}")
    else:
        print("unexpected output_file format name")
        return
    compressed_file = os.path.join(PATH, file_name + "_" + current_date + ".log.gz")
    syslog_firstandlastLine = os.path.join(PATH, file_name + "_firstandlast_line.log")
    print(f"syslog file to analyse = {log_file}")
    print(f"output file with matching signature if any = {output_file}")
    print(f"file with pattern include = {pattern_include_file}")
    with open(pattern_include_file, 'r') as f:
        pattern_include = [line.strip() for line in f.readlines()]

    # read patterns from file patternExclude
    print(f"file with pattern exclude = {pattern_exclude_file}")
    with open(pattern_exclude_file, 'r') as f:
        pattern_exclude = [line.strip() for line in f.readlines()]

    # compile regex patterns
    include_patterns = [re.compile(p) for p in pattern_include]
    exclude_patterns = [re.compile(p) for p in pattern_exclude]

    # list to keep the line with matching pattern
    matched_lines = []

    with open(log_file, 'r') as log, open(output_file, 'w') as output:
        print(f"parsing file = {log_file}")
        first_line = None
        last_line = None
        for i, line in enumerate(log):
            if i == 0:
                first_line = line
            last_line = line
            if any(p.search(line) for p in include_patterns):
                if not any(p.search(line) for p in exclude_patterns):
                    print(f"pattern found! = {line}")
                    output.write(line)
                    matched_lines.append(line.strip())  # add the line to the list with matching pattern
    if matched_lines:
        print(f"Error found! ...saving current syslog under = {compressed_file}")
        with open(log_file, 'rb') as f_in, gzip.open(compressed_file, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)

    with open(syslog_firstandlastLine, 'a') as file:
        if first_line:
            print(f"First line of {file_name} at {current_date}: {first_line}")
            file.write(f"First line of {file_name} at {current_date}: {first_line}")
        if last_line:
            print(f"Last line of {file_name} at {current_date}: {last_line}")
            file.write(f" Last line of {file_name} at {current_date}: {last_line}")
    return matched_lines


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Parse a log file based on include and exclude patterns.')
    parser.add_argument(
        '--log', default='/home/taupin4/Downloads/SYSLOG.log',
        help='Path to the pattern include file (default: )'
    )

    # BHR 19/02/2026 : redirect CB008661 --> transversal_robustness
    default_pattern_include = (
         '/ebs/taupin4/my_virtual_env/robotws/testsuite/Paris/RRM/ET/transversal_robustness/config/syslog/'
         'exclusion/patternInclude.csv'
    )
    parser.add_argument(
        '--patternInclude', default=default_pattern_include,
        help='Path to the pattern include file (default: {default_pattern_include})'
    )

    default_pattern_exclude = (
         '/ebs/taupin4/my_virtual_env/robotws/testsuite/Paris/RRM/ET/transversal_robustness/config/syslog/'
         'exclusion/patternExclude.csv'
    )
    parser.add_argument(
        '--patternExclude', default=default_pattern_exclude,
        help='Path to the pattern exclude file (default: {default_pattern_exclude})'
    )
    parser.add_argument(
        '--output', default='/home/taupin4/Downloads/output.txt',
        help='Path to the output file (default: output.txt)'
    )

    args = parser.parse_args()

    parse_log(args.log, args.patternInclude, args.patternExclude, args.output)

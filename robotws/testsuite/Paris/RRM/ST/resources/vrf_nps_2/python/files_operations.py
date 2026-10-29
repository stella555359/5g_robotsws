import re
import csv
import subprocess
from robot.api import logger
import os


def tgs_syslog_filter(tgz_file_path, grep_prog='zgrep', option='-a', grep_patterns=[]):
    if not isinstance(grep_patterns, list):
        grep_patterns = [grep_patterns]
    if not tgz_file_path:
        return []
    if not grep_patterns:
        return []

    ts = []
    cmd = grep_prog + ' ' + option + ' "' + grep_patterns[0] + '" ' + tgz_file_path
    # cmd = compressed_grep + ' -a "' + pattern + '" ' + tgz_syslog_path
    for grep_patterns in grep_patterns[1:]:
        cmd += ' | grep "' + grep_patterns + '"'
    logger.debug('cmd: %s' % cmd)
    try:
        output = subprocess.check_output(
            cmd,
            shell=True,
        )
        if isinstance(output, (bytes, bytearray)):
            output = output.decode("utf-8")
            # logger.debug('output: %s' % output)
        for line in output.splitlines():
            ts.append(line)
    except Exception as e:
        # catch all exceptions
        pass
    return ts


def extract_poolid_data_to_csv(tgz_file_path, grep_patterns=['PRB_POOLING.BASIC', 'poolId: ']):
    # Regular expression to match the required data

    content = tgs_syslog_filter(tgz_file_path, grep_patterns=grep_patterns)
    if not content:
        logger.error(f"No matches found in {tgz_file_path} for {grep_patterns}")
        return
    content = '\n'.join(content)
    pattern = re.compile(
        r'poolId: (\d+) CellElementList: \{\[NrCellIdentity, allocatedBbrmPrb, hasZabPrivilege, absoluteCellLoad\]('
        r'.*?)\}')
    matches = pattern.findall(content)
    if not matches:
        logger.error(f"No matches found in {tgz_file_path} for {pattern}")
        return
    output_file = os.path.join(os.path.dirname(tgz_file_path), "pool_infos.csv")
    with open(output_file, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        # Write the header
        csvwriter.writerow(['poolId', 'NrCellIdentity', 'allocatedBbrmPrb', 'hasZabPrivilege', 'absoluteCellLoad'])

        for match in matches:
            pool_id = match[0]
            cell_elements = match[1].strip().split('] [')
            for element in cell_elements:
                element = element.strip('[]')
                values = element.split(',')
                csvwriter.writerow([pool_id] + values)
    return output_file


def get_unique_counts(csv_file, columns):
    unique_counts = {column: set() for column in columns}

    with open(csv_file, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            for column in columns:
                if column in row:
                    unique_counts[column].add(row[column])

    # Convert sets to counts
    unique_counts = {column: len(values) for column, values in unique_counts.items()}
    return unique_counts

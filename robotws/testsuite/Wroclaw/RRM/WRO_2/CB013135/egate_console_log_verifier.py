import re
from robot.api import logger


def find_structure(filename, patterns):
    results = {}

    with open(filename, 'r', encoding='utf-8') as file:
        content = file.read()

    for key, pattern in patterns.items():
        matches = list(re.finditer(pattern, content, re.DOTALL | re.VERBOSE))
        match_info = []
        for match in matches:
            start_line = content.count('\n', 0, match.start()) + 1
            end_line = content.count('\n', 0, match.end()) + 1
            match_info.append((start_line, end_line))
        results[key] = match_info

    logger.console(results)

    return results

import re
import logging


def verify_sequence_in_log(contents, *patternList):
    if len(patternList) == 0:
        raise AssertionError("Empty patternlist")
    notFoundList = list(patternList)
    contents = contents.split('\n')
    for line in contents:
        if len(notFoundList) != 0:
            pattern = notFoundList[0]
            result = find_match(line, pattern)
            if result:
                logging.info("Pattern '{}' found in line {}".format(
                    pattern, str(contents.index(line) + 1)))
                notFoundList.pop(0)
        else:
            break
    if len(notFoundList) != 0:
        raise AssertionError("Following pattern was not found '{}', Number {}".
                             format(notFoundList[0], len(patternList)-len(notFoundList)+1))


def find_match(line, pattern):
    p = re.search(pattern, line, re.IGNORECASE)
    if p:
        return p.group()
    return None

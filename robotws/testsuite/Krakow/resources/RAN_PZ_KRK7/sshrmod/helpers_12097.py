import inspect
from robot.libraries.BuiltIn import logger


def f_log(depth=1):
    log = '<b>sshrmod_keywords</b> '
    for level in range(1, depth + 1):
        try:
            log += f'{level}. <b>{inspect.stack()[level][3]}</b> line={inspect.stack()[level][2]}' +\
                   f' from {inspect.stack()[level][1]}\n'
        except IndexError:
            log += f'{level}.Function log level too deep. Aborting.\n'
            break
    return log


def convert_str_to_list(in_str: str):
    li = [num for part in in_str.split(',') for num in (
        range(int(part.split('-')[0]), int(part.split('-')[1]) + 1) if '-' in part else [int(part)])]
    logger.trace(f'convert_str_to_list list={li}')
    return li

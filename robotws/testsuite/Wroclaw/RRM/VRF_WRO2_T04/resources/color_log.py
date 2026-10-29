from robot.api import logger

COLORS = {
    'end': "\033[0m",
    'red': "\033[1;31m",
    'green': "\033[1;32m",
    'blue_bg': "\033[44m"   # background
}


def write_line(line, color='green'):
    line = COLORS[color] + line + COLORS['end']
    logger.console(line + "\n")


def write_mixed_line(first_part, colored_part, end_part='', color='green'):
    line = first_part + COLORS[color] + colored_part + COLORS['end'] + end_part
    logger.console(line + "\n")

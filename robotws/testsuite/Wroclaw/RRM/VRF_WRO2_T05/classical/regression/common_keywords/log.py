from __future__ import print_function
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError

"""
Usage:       blog [both log :-)] should be imported from this module.
Description: blog is assigned depending on execution context, so that it can be used both
             when using robot framework and pure python.
"""


def get_fg_color_code(color):
    fg_colors = {
        'white': '\033[30m',
        'red': '\033[31m',
        'green': '\033[32m',
        'yellow': '\033[33m',
        'blue': '\033[34m',
        'magenta': '\033[35m',
        'cyan': '\033[36m',
        'black': '\033[37m',
        'default': '\033[39m',
    }
    return fg_colors.get(color, fg_colors['default'])


def get_bg_color_code(color):
    bg_colors = {
        'white': '\033[40m',
        'red': '\033[41m',
        'green': '\033[42m',
        'yellow': '\033[43m',
        'blue': '\033[44m',
        'magenta': '\033[45m',
        'cyan': '\033[46m',
        'black': '\033[47m',
        'default': '\033[49m',
    }
    return bg_colors.get(color, bg_colors['default'])


def get_default_level_color(level):
    level2color = {
        'TRACE': 'default',
        'DEBUG': 'default',
        'INFO':  'default',
        'WARN':  'yellow',
        'ERROR': 'red',
    }
    return level2color.get(level, get_fg_color_code('default'))


def log_console(*args, **kwargs):
    """
    Wrapper for python print().
    :Arguments: Contents of the log.
    :Keyword Arguments:
        * level (str): Denotes the severity level of the log.
        * fg_color (ForegroundColor): Color of characters in console.
        * bg_color (BackgroundColor): Color of console's background.
    """
    level = kwargs.pop('level', 'INFO')
    kwargs.pop('console', True)
    kwargs.pop('repr', False)
    kwargs.pop('html', True)

    default_color = get_default_level_color(level)
    fg_color = kwargs.pop('fg_color', default_color)
    bg_color = kwargs.pop('bg_color', 'default')

    fg_color_code = get_fg_color_code(fg_color)
    bg_color_code = get_bg_color_code(bg_color)

    bold_mode = '\033[22m'
    reset_all = '\033[0m'

    content = ['{}: '.format(level)] + list(args) + list(kwargs.values())
    content = ['\n'] + [bold_mode, fg_color_code, bg_color_code] + content + [reset_all]

    print(*content)


def log_robot(*args, **kwargs):
    """Wrapper for robot Builtin log."""
    l_ = kwargs.pop('level', 'INFO')
    c = kwargs.pop('console', True)
    r = kwargs.pop('repr', False)
    h = kwargs.pop('html', True)
    content = list(args) + list(kwargs.values())

    content = str(content)[1:-1]
    BuiltIn().log(message='<b>{}</b>'.format(content), level=l_, html=h, console=False, repr=r)

    if c and l_ in ['TRACE', 'DEBUG', 'INFO']:
        BuiltIn().log_to_console(message=content)


def assign_logging_method():
    try:
        BuiltIn().get_variable_value("${xxx}")  # check if robot is running
        return log_robot
    except RobotNotRunningError:
        return log_console


blog = assign_logging_method()

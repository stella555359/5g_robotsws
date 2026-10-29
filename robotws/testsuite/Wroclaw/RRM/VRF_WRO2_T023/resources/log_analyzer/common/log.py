from __future__ import print_function
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError

"""
Usage:       blog [both log :-)] should be imported from this module.
Description: blog is assigned depending on execution context, so that it can be used both
             when using robot framework and pure python.
"""


def log_console(*args, **kargs):
    """
    Wrapper for python print().
    usage:
        log({'slotTypeReq': {'sfn': '0x02', 'rnti': '0x003d'}},
            'rnti list', ['0x003a', '0x002d'],
            foo=object)
    result:
        INFO : {'slotTypeReq': {'sfn': '0x02', 'rnti': '0x003d'}} rnti list ['0x003a', '0x002d'] <type 'object'>
    """
    kargs.pop('console', None)
    kargs.pop('html', None)
    kargs.pop('repr', None)
    level = {
        'TRACE': 'TRACE:',
        'DEBUG': 'DEBUG:',
        'INFO':  'INFO :',
        'HTML':  'HTML :',
        'WARN':  'WARN :',
        'ERROR': 'ERROR:',
    }[kargs.pop('level', 'INFO')]
    content = list(args) + list(kargs.values())
    print(level, *content)


def log_robot(*args, **kargs):
    """
    Wrapper for robot Builtin log.
    usage:
        log(
            {'slotTypeReq': {'sfn': '0x02', 'rnti': '0x003d'}},
            'rnti list', ['0x003a', '0x002d'],
            foo=object)
    result:
        {'slotTypeReq': {'sfn': '0x02', 'rnti': '0x003d'}}, 'rnti list', ['0x003a', '0x002d'], <type 'object'>
    """
    l_ = kargs.pop('level', 'INFO')
    c = kargs.pop('console', True)
    r = kargs.pop('repr', False)
    h = kargs.pop('html', True)
    content = list(args) + list(kargs.values())
    # str([arg, ... , arg_x]) then '[arg, ... , arg_x]' -> 'arg, ... , arg_x'
    content = str(content)[1:-1]
    BuiltIn().log(message='<b>{}</b>'.format(content), level=l_, html=h, console=False, repr=r)

    if c:
        BuiltIn().log_to_console(message=content)


try:
    BuiltIn().get_variable_value("${xxx}")  # check if robot is running
    blog = log_robot
except RobotNotRunningError:
    blog = log_console

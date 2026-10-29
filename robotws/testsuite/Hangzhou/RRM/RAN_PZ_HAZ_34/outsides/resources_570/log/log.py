
from __future__ import print_function
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError

"""
blog [both log :-)] shoud be imported from this module
"""


def log_console(*args, **kargs):
    """
    call signature arguments: console, html, repr
    are unnecessary for console logging therefore deleted
    preserves default log level of 'INFO'
    example:
    log(
        {'slotTypeReq': {'sfn': '0x02', 'rnti': '0x003d'}},
        'rnti list', ['0x003a', '0x002d'],
        foo=object,
    )
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
    content = list(args) + list(kargs.values())  # for pure readability
    print(level, *content)


def log_robot(*args, **kargs):
    """
    wrapper for robot Builtin log having similar call signature
    made so it kind of imitates simple print so it is more flexible
    than single argument message for BuiltIn log preserving its defaults
    example:
    log(
        {'slotTypeReq': {'sfn': '0x02', 'rnti': '0x003d'}},
        'rnti list', ['0x003a', '0x002d'],
        foo=object,
    )
    result:
    {'slotTypeReq': {'sfn': '0x02', 'rnti': '0x003d'}}, 'rnti list', ['0x003a', '0x002d'], <type 'object'>
    """
    l_ = kargs.pop('level', 'INFO')
    c = kargs.pop('console', False)
    r = kargs.pop('repr', False)
    h = kargs.pop('html', True)
    content = list(args) + list(kargs.values())
    # str([arg, ... , arg_x]) then '[arg, ... , arg_x]' -> 'arg, ... , arg_x'
    content = str(content)[1:-1]
    BuiltIn().log(message='<b>{}</b>'.format(content), level=l_, html=h, console=c, repr=r)


#
# blog is assigned depending of robot running
# so that it can be used as both logging function
# when using robot or pure python using robot logging
#
try:
    BuiltIn().get_variable_value("${xxx}")  # check if robot is running
    blog = log_robot
except RobotNotRunningError:
    blog = log_console

from __future__ import division
from __future__ import print_function
from builtins import str
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


def robot_get_variable(var_name, default=None):
    """
    Get Robot variable.

    :param var_name:
    :param default:
    :return:
    """
    var_name = "${" + str(var_name) + "}"
    if default is None:
        return BuiltIn().get_variable_value(var_name)
    else:
        return BuiltIn().get_variable_value(var_name, default)


def robot_run_keyword(keyword_string, *args):
    """
    Run Robot keyword

    :param keyword_string:
    :param args:
    :return:
    """
    return BuiltIn().run_keyword(keyword_string, *args)


def robot_get_library_instance(library_full_name):
    """
    Get library instance.

    :param library_full_name:
    :return:
    """
    return BuiltIn().get_library_instance(name=library_full_name)


def robot_import_library(library_name):
    """
    Import library.

    :param library_name:
    :return:
    """
    try:
        BuiltIn().import_library(library_name)
    except RobotNotRunningError:
        print('Robot not running but trying to import {}'.format(library_name))


def robot_is_dry_run():
    """
    Check if dryrun is executed.

    :return:
    """
    dry_run = False
    try:
        from robot.running.context import EXECUTION_CONTEXTS
        curr_ctx = EXECUTION_CONTEXTS.current
        if curr_ctx:
            dry_run = curr_ctx.dry_run
    except RobotNotRunningError:
        pass
    return dry_run

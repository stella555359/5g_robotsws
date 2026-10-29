from robot.libraries.BuiltIn import BuiltIn
import logging


def robot_is_running():
    """check if robot is running or not."""
    try:
        BuiltIn().get_library_instance("BuiltIn")
        return True
    except Exception as _:
        return False


def get_robot_runtime_variable(varname):
    """get robot runtime variable use Builtin libraries replace_variables"""
    try:
        if not varname.startswith("${"):
            varname = "${%s}" % varname
        return BuiltIn().replace_variables(varname)
    except Exception as error:
        raise Exception('not find variable %s' % varname)
        logging.info("Can't get variable '%s' ! details: '%s'" % (varname, error))

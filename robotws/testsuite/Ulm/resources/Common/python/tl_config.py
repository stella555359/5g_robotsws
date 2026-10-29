from robot.libraries import BuiltIn
from robot.libraries.BuiltIn import RobotNotRunningError
import logging
from connect import get_test_pc_for_nodeb


logger = logging.getLogger()
TL_CONFIG = None


def get_robot_variable(variable_name):
    """
    Returns the content of the given robot variable name.
    If robot is not running, an AssertionError will be thrown.

    :param variable_name: the robot variable name, i.e. '${tl}'
    """
    robot_builtin = BuiltIn.BuiltIn()
    try:
        return robot_builtin.get_variable_value(variable_name)
    except RobotNotRunningError:
        raise AssertionError("robot variable not found. Reason might be that robot was no called")


def get_testline_configuration():
    """
    Returns the testline configuration from the current running robot context.
    If robot is not running, None will be returned.
    This library is to be expected to be used from robot keywords.
    Hence it will throw an Error, if used without a robot run.

    TODO: Give a descriptive error message, if the variable was not found!
    """
    global TL_CONFIG
    if TL_CONFIG is None:
        TL_CONFIG = get_robot_variable('${tl}')
        assert TL_CONFIG is not None, "The test should be run with a testline configuration!"
    return TL_CONFIG


def get_test_pcs_by_connection_objects(tl, nodeb):
    test_pcs = []
    nodeb_common_units = [common_unit for du in nodeb.dus for common_unit in du.airscale.common_units]
    for test_pc in tl.test_pcs:
        for connection in test_pc.connections:
            if hasattr(connection, 'device') and connection.device in nodeb_common_units:
                test_pcs.append(test_pc)
    test_pcs = list(set(test_pcs))
    return test_pcs


def get_test_pc(node_id=0, node_type='gnb'):
    """
    This function determines the test pc in the testline configuration, depening on the given
    node_type and node_id

    :parm tl: The testline configuration
    :param node_id: The node_id which corresponds to the index in the testline config of tl.gnbs or tl.enbs
    :param node_type: The type of nodeB, can be 'enb' or 'gnb'
    """
    tl = get_testline_configuration()
    if node_type == 'gnb':
        return get_test_pc_for_nodeb(tl, tl.gnbs[node_id])
    elif node_type == 'enb':
        return get_test_pc_for_nodeb(tl, tl.enbs[node_id])

    raise AssertionError("Error in getting node: invalid node type {}".format(node_type))

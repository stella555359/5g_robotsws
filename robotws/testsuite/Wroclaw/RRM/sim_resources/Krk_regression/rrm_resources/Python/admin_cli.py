"""
:copyright: Nokia Networks
:author: Paulina Jedras <paulina.jedras@nokia.com>
:maintainer: Paulina Jedras <paulina.jedras@nokia.com>
"""


from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from robot.api.deco import keyword
from ta5g_admin_operations import ta5g_admin_operations
from functools import wraps
from taf.sbts.oam.coam.admin.facade import admin_interface_context
from robot.api import logger
# import traceback

api = admin()
ADMIN_CONNECTION = 'admin_connection'

CELL_INFORMATION = {'energySavingState': ['notEnergySaving', 'energySaving', 'reducedEnergySaving', 'switchingOff',
                                          'switchingOffRTX', 'switchingOnTX']}
CELL_STATUS_INFORMATION = {'administrativeState': ['Locked', 'Shutting Down', 'Unlocked'],
                           'operationalState': ['disabled', 'enabled'],
                           'usageState': ['Idle', 'Active'],
                           'blockingState': ['Blocked', 'Unblocked', 'Blocking', 'Unblocking'],
                           'proceduralStatus': ['not initialized', 'initialization' 'required', 'initializing',
                                                'validated', 'configured'],
                           'availabilityStatus': ['in test', 'failed', 'power off', 'off line', 'off duty',
                                                  'dependency', 'degraded', 'not installed', 'log full', '-'],
                           'barringStatus': ['barred', 'unbarred']}


def setup_connection_to_admin(connection_name=ADMIN_CONNECTION):
    """Creates connection to admin and sets suite variable ${ADMIN_CONNECTION} which can be used in keywords
       without parametrized connection, or directly eg. in taf.sbts.oam.coam.admin keywords.
       Purpose of this keyword is to create connection which will be alive during test/suite execution
       Connection name should not be set to 'default', as this name is usually used in other libraries keywords which
       creates and remove connection to admin after execution.
    """
    BuiltIn().set_suite_variable('${ADMIN_CONNECTION}', connection_name)
    return api.connect_to(name=connection_name)


def teardown_connection_to_admin(connection_name=ADMIN_CONNECTION):
    api.teardown_admin(connection=connection_name)


def setup_and_teardown_admin_connection_if_needed(func):
    """Wrapper function handling setting up and teardown of admin connection. Meant to be used as a decorator.

    Usage:
    - When it decorates function with parameter 'connection': It checks if connection is alive.
      If not, new temporary connection is created and removed
    - When it decorates function without parameter 'connection': It checks if connection with name based on variable
      ${ADMIN_CONNECTION} or 'default' connection is alive, or. If not, new temporary connection is created and removed.

    """
    @wraps(func)
    def _wrapper(*args, **kwargs):
        try:
            if "connection" in kwargs:
                connection_name = kwargs.pop('connection')
            else:
                connection_name = BuiltIn().get_variable_value("${ADMIN_CONNECTION}", '')
            api.check_link_status(connection=connection_name)
            kwargs['connection'] = connection_name
            logger.info("Existing connection to admin:\'{}\' will be used".format(connection_name))
        except Exception as e:
            # print(e)
            # traceback.print_exc()
            with admin_interface_context() as connection:
                kwargs['connection'] = connection
                logger.info('Create temporary connection to Admin\n'
                            'To speed up keyword execution setup connection to admin, eg. in suite/test setup')
                return func(*args, **kwargs)
        return func(*args, **kwargs)
    return _wrapper


@keyword('Check for cells [${cell_ids}] if ${parameter} equals [${expected_states}]')
@setup_and_teardown_admin_connection_if_needed
@api.lookup_handler.implicit_lookup
def verify_cells_information(cell_ids, parameter, expected_states, connection=None):
    """
    Example Robot usage:
    Check for cells [1, 2] if energySavingState equals [notEnergySaving, reducedEnergySaving]
    Check for cells [1, 2, 3, 4] if availabilityStatus equals [degraded, degraded, off line, off line]
    Keyword can be extended with verification of additional parameters
    """
    cells_list = [x.strip() for x in cell_ids.split(',')]
    expected_states_list = [x.strip() for x in expected_states.split(',')]

    allowed_cell_parameters = CELL_INFORMATION.copy()
    allowed_cell_parameters.update(CELL_STATUS_INFORMATION)
    for state in expected_states_list:
        assert state in allowed_cell_parameters[parameter], "State {} is not allowed for parameter {}\n" \
            "Allowed states: {}".format(state, parameter, allowed_cell_parameters[parameter])
    actual_states_list = []
    cells_info = connection.get_cells_info()

    # print(cells_info)
    for cell_id in cells_list:
        cell_info = next((c for c in cells_info if str(c['globalCellId']) == cell_id), False)
        assert cell_info, "Cell {} is not present in gNB configuration".format(cell_id)

        if parameter in CELL_INFORMATION:
            actual_states_list.append(cell_info[parameter])
        elif parameter in CELL_STATUS_INFORMATION:
            try:
                actual_states_list.append(cell_info['status'][parameter])
            except KeyError:
                if parameter == 'availabilityStatus' and cell_info['status']:
                    # if parameter is not present it means that cell is online
                    actual_states_list.append('-')
    ta5g_admin_operations().assert_equal(expected=expected_states_list, actual=actual_states_list)

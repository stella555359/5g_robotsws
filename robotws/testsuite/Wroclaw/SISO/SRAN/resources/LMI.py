"""
:modified:  24.03.2025 - initial creation
            13.06.2025 - adapting to library taf.hw.rf_diagnostic_card
            14.07.2025 - added common_setup_lmi_path yaml file to the process
:author: Patryk Niewiejski
:maintainer: Szymon Przybylak
:contact: szymon.przybylak@nokia.com
"""
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword, library
from contextlib import contextmanager
from functools import wraps
from taf.hw.rmod_serial_interface.clients.pyro.pyro_server.exceptions import UnknownRMODTypeError
from taf.sbts.oam.coam.admin import admin
from taf.hw.rf_diagnostic_card import rf_diagnostic_card
from taf.config.testline import RU

import re
import os

ROBOT_AUTO_KEYWORDS = False

__version__ = '1.1'
"""Global variable"""
common_setup_LMI_path = os.getenv(
    'COMMON_SETUP_LMI_PATH',
    "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/resources/common_setup_LMI.yaml"
)


@contextmanager
def lmi_connection(ru_obj, ru_alias=None, logs_path=None):
    """
    Establishes a connection to a Radio Unit (RU) using LMI (Lightweight Management Interface) and manages the
    connection context.
    Args:
        ru_obj: An object representing the Radio Unit (RU) configuration. Obtained from init file.
        ru_alias (str, optional): An alias for the RU. If not provided, it will be generated based on the RU's radio
            type and serial number.
        logs_path (str, optional): The path where logs will be saved. If not provided, it will be generated based on the
            iteration and default log path.
    Yields:
        tuple: A tuple containing the LMI connection object and the RU alias.
    Example:
        with lmi_connection(ru_obj) as (lmi, alias):
            # Use the lmi connection here
            pass
    Notes:
        - The connection is automatically disconnected when the context is exited.
        - Logs are saved in the specified or generated logs path.
    """
    logger.debug(f"Created new LMI's context manager for ru_obj {ru_obj}")

    if ru_alias is None:
        ru_alias = f"{ru_obj.radio_type}_{ru_obj.serial_number[-3:]}"
    logger.debug(f"For ru_obj {ru_obj} connection, ru_alias {ru_alias} will be used")

    if logs_path is None:
        logs_path = BuiltIn().get_variable_value("$CFG.test_logs_path", f".") + f"/lmi_logs_{ru_alias}"
    logger.debug(f"Logs for ru_alias {ru_alias} will be saved in {logs_path}")
    lmi = rf_diagnostic_card()
    # lmi = LMILight(main_log_directory=logs_path)
    lmi.prepare_log_directory_and_connection_setup(
        main_log_directory=logs_path,
        connection_setup=common_setup_LMI_path
    )
    lmi.setup_connections(ru_config=ru_obj, alias=ru_alias)
    # lmi.setup_new_rmod_connection(ru_config=ru_obj, alias=ru_alias)
    logger.debug(f"Established connection to ru_obj {ru_obj} with alias {ru_alias} and logs dictionary {logs_path}")
    try:
        yield lmi, ru_alias
    finally:
        lmi.disconnect(alias=ru_alias)
        logger.debug(f"Disconnected from ru_obj {ru_obj} with alias {ru_alias} and logs dictionary {logs_path}")


def handle_unknown_rmod_type_error(func):
    """
    Decorator to handle unknown RMOD type errors.

    This decorator wraps a function and catches `ValueError` and `UnknownRMODTypeError` exceptions.
    If such an exception is caught, it logs an error message indicating that the RM type is not supported
    by the library `taf.hw.rmod_serial_interface` and that the LMI flow will not be executed for this RM.
    It also logs the exception details at the debug level.

    Args:
        func (callable): The function to be wrapped by the decorator.

    Returns:
        callable: The wrapped function with error handling for unknown RMOD type errors.
    """
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        try:
            return func(self, *args, **kwargs)
        except (ValueError, UnknownRMODTypeError) as e:
            rm_sn = kwargs.get("rm_sn", None) or args[0]
            rm_type = self.rm_obj_dict[rm_sn].radio_type
            logger.error(f"RM type {rm_type} is not supported by library taf.hw.rmod_serial_interface! LMI flow" +
                         f" will not be executed for this RM")
            logger.debug(f"{e}")
            return
    return wrapper


def run_method_and_handle_exception(func):
    """
    Decorator that wraps a method to handle exceptions and log method execution details.
    This decorator logs the start and end of the method execution, including the method name,
    arguments, keyword arguments, and the returned value. If an exception occurs during the
    method execution, it logs the exception details.
    Args:
        func (callable): The method to be wrapped by the decorator.
    Returns:
        callable: The wrapped method with exception handling and logging.
    Usage:
        @run_method_and_handle_exception
        def some_method(self, arg1, arg2):
            # method implementation
    """
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        try:
            logger.debug(f"===============\nMETHOD STARTED: {func.__name__}\nARGS: {args}\nKWARGS: {kwargs}")
            returned_value = func(self, *args, **kwargs)
            logger.debug(f"METHOD FINNISHED: {func.__name__}\nRETURNED VALUE: {returned_value}\n===============")
            return returned_value
        except Exception as e:
            logger.error(f"An unexpected error appeared during LMI flow running!\nMethod name: {func.__name__}\n" +
                         f"More about exception: {e}")
            return

    return wrapper


@library
class LMI:
    """
    The LMI class provides methods to set up and manage the Local Management Interface (LMI) flow for Radio Modules
    (RMs) in a network. The class includes methods to configure the LMI flow, start the flow on all nodes, and handle
    various aspects of the LMI process, such as taking snapshots and analyzing alarms.
    Attributes:
        ROBOT_AUTO_KEYWORDS (bool): Indicates whether Robot Framework auto keywords are enabled.
        enabled (bool): Indicates whether the LMI flow is enabled.
        configured (bool): Indicates whether the LMI flow is configured.
        rm_obj_dict (dict): Dictionary to store RM objects.
        allowed_alarms_list (list): List of allowed alarms.
        enabled_by_default (bool): Indicates if LMI should be enabled by default.
        allow_post_mortem_action (bool): Indicates if post-mortem actions are allowed.
    Methods:
        setup_lmi_flow():
            Sets up the LMI flow based on user-defined flags and configuration variables.
        start_lmi_flow_on_all_nodes():
            Starts the LMI flow on all nodes.
        start_lmi_flow_on_node(node):
            Starts the LMI flow for a specific node.
        _execute_post_moterm_action(rm_sn):
            Executes post-mortem action for a specific RM (not implemented).
        _get_rm_object_from_init(rm_sn):
            Retrieves the RM object from the initialization file based on the serial number.
        _take_snapshot_via_lmi(rm_sn, node="unknown_node", rescue_action=False):
            Takes a snapshot via LMI for a specific RM.
        _analyze_rm_alarms_on_node(node):
            Analyzes RM alarms on a specific node.
        _refresh_allowed_alarms_list():
            Refreshes the list of allowed alarms.
        _refresh_cfg_variable():
            Refreshes the CFG variable.
    """
    ROBOT_AUTO_KEYWORDS = False

    def __init__(self):
        self.enabled = False
        self.configured = False
        self.rm_obj_dict = dict()
        self.allowed_alarms_list = list()
        self.enabled_by_default = False  # True if LMI should be enabled by default, False otherwise
        self.allow_post_mortem_action = True

    @run_method_and_handle_exception
    @keyword("Setup LMI Flow")
    def setup_lmi_flow(self):
        """
        Sets up the LMI (Local Management Interface) flow based on user-defined flags and configuration variables.
        IMPORTANT! Run this keyword before starting LMI flow on all nodes.
        This method performs the following steps:
        1. Checks if LMI should be enabled based on a user-defined flag.
        2. Loads required variables (`tl` and `cfg`).
        3. Retrieves the list of available RMs (Radio Modules) from the configuration variable.
        4. Loads the user's list of excluded RMs and creates a list of RMs that are not excluded by the user.
        5. Loads the user's allowed alarms list.
        6. Checks if the RU (Radio Unit) object is available in the init file and adds it to the LMI configuration
        dictionary.
        7. Performs a safety check to ensure there is at least one LMI configuration available.
        8. Loads the user's flag to disable Post Mortem action.
        9. Logs the successful completion of the LMI flow setup.
        Returns:
            None
        """
        # Check user's flag if LMI should be enabled
        self.enabled = BuiltIn().get_variable_value("$CUSTOM_LMI_ENABLE_FLAG", self.enabled_by_default) is not False
        if not self.enabled:
            if self.enabled_by_default:
                logger.warn("LMI support is disabled by user!")
            return

        # Load required variables
        self.tl = BuiltIn().get_variable_value("$tl", None)
        logger.debug(f"Loaded TL variable:\n{self.tl}")
        self.cfg = self._refresh_cfg_variable()
        if self.tl is None or self.cfg is None:
            logger.error("Variable TL or CFG is not found. LMI flow will not be configured!")
            return

        # Get list of available RMs from CFG variable
        cfg_rm_sn_list = self.cfg.RF_INFO.keys()
        logger.debug(f"List of RMs from CFG variable:\n{cfg_rm_sn_list}")

        # Load user's list of excluded RMs and create list of RMs that are not excluded by user
        user_exclude_rm_sn_list = BuiltIn().get_variable_value("$CUSTOM_LMI_EXCLUDE_RM_LIST", None)
        if user_exclude_rm_sn_list is not None:
            user_exclude_rm_sn_list = list(user_exclude_rm_sn_list)  # Just for get rid of 'odict_keys()' in logs
        logger.debug(f"Loaded user's list of excluded RMs:\n{user_exclude_rm_sn_list}")
        if user_exclude_rm_sn_list is not None:
            logger.warn(f"User excluded RMs from LMI support: {user_exclude_rm_sn_list}")
            delta_rm_sn_list = [rm_sn for rm_sn in cfg_rm_sn_list if rm_sn not in user_exclude_rm_sn_list]
            logger.debug(f"List of RMs that are not excluded by user:\n{delta_rm_sn_list}")
        else:
            delta_rm_sn_list = cfg_rm_sn_list
            logger.debug(f"User did not exclude any RM. List of RMs used in LMI flow:\n{delta_rm_sn_list}")

        # Load user's allowed alarms list. Excluded method as it may change during TC execution
        self.allowed_alarms_list = self._refresh_allowed_alarms_list()

        # Check if RU object is available in init file and add to LMI configuration dictionary
        for rm_sn in delta_rm_sn_list:
            rm_obj = self._get_rm_object_from_init(rm_sn)
            if rm_obj is None:
                logger.error(f"Can not find RM {rm_sn} in init file!")
                continue
            if rm_obj.lmi is None:
                logger.warn(f"LMI for RM {rm_sn} is not configured!")
                continue
            self.rm_obj_dict[rm_sn] = rm_obj

        # Safety check if there is at least one LMI configuration available
        lmi_configurations = {rm_sn: rm_obj.lmi for rm_sn, rm_obj in self.rm_obj_dict.items()}
        if len(lmi_configurations) == 0:
            logger.warn("LMI flow configuration skipped! There is no single RM with LMI configuration in init file" +
                        " that is not excluded by user!")
            return

        # Load user's flag to disable Post Mortem action
        self.allow_post_mortem_action = BuiltIn().get_variable_value("$CUSTOM_LMI_ALLOW_POST_MORTEM_ACTION", True)

        logger.info(f"Successfully finnished LMI flow setup:\n{lmi_configurations}")
        self.configured = True

    @keyword("Start LMI Flow On All Nodes")
    @run_method_and_handle_exception
    def start_lmi_flow_on_all_nodes(self):
        """
        Starts the LMI (Local Management Interface) flow on all nodes.

        This method checks if the LMI flow is enabled and configured before attempting to start the flow on each node
        listed in the active BTS list. If the flow is not enabled or configured, it logs the status and
        skips the execution. For each node, it attempts to start the LMI flow and logs an error if it fails.

        Returns:
            None
        """
        if not self.enabled or not self.configured:
            logger.info(f"Skipped LMI flow execution:\nEnabled: {self.enabled}\nConfigured: {self.configured}")
            return
        # Start LMI Flow on each node based on $CFG variable
        for node in self.cfg.active_bts_list:
            try:
                self.start_lmi_flow_on_node(node)
            except Exception as e:
                logger.error(f"Failed to start LMI flow on node {node}! Read info logs for more details")
                logger.info(e)

    @keyword("Start LMI Flow On Node")
    @run_method_and_handle_exception
    def start_lmi_flow_on_node(self, node):
        if not self.enabled or not self.configured:
            logger.info(f"Skipped LMI flow execution:\nEnabled: {self.enabled}\nConfigured: {self.configured}")
            return
        logger.info(f"Started LMI flow for node {node}")
        rm_sn_except_fid10_list, rm_sn_fid_10_list = self._analyze_rm_alarms_on_node(node)
        if rm_sn_except_fid10_list is None and rm_sn_fid_10_list is None:
            logger.info(f"No RMs affected by any alarm on node {node}")
            return
        for rm_sn in list(set(rm_sn_except_fid10_list + rm_sn_fid_10_list)):  # Removed duplicates
            if rm_sn not in self.rm_obj_dict:
                logger.info(f"Fault found on RM {rm_sn} but RM is not configured for LMI flow!")
                continue

            logger.info(f"Starting LMI flow for RM {rm_sn}:\n{self.rm_obj_dict[rm_sn]}")

            # Default LMI flow (via LMILight library)
            if rm_sn in rm_sn_except_fid10_list:
                snap_taken_successcully = self._take_snapshot_via_lmi(rm_sn, node=node)
                if snap_taken_successcully is None:
                    continue  # Decorator handle_unknown_rmod_type_error returns None if RM not supported

            # LMI flow with rescue action (rmod reset and LMILight library)
            if rm_sn in rm_sn_fid_10_list or not snap_taken_successcully:
                snap_taken_successcully = self._take_snapshot_via_lmi(rm_sn, node=node, rescue_action=True)
                if snap_taken_successcully is None:
                    continue  # Decorator handle_unknown_rmod_type_error returns None if RM not supported

            # Last chance option. Save RM logs via Post Mortem action
            if not snap_taken_successcully:
                if self.allow_post_mortem_action:
                    self._execute_post_moterm_action(rm_sn)  # TODO: Not Implemented! Read comment within method
                else:
                    logger.error(f"Post Mortem action for RM {rm_sn} should be executed but is disabled by user!")

        logger.debug(f"Finnished LMI flow for node {node}")

    @run_method_and_handle_exception
    def _execute_post_moterm_action(self, rm_sn):
        # TODO: Post Mortem Action is not yet implemented due to doubts about its usefulness.
        # If you want to implement it in the future, please use this hints:
        # 1. You should disable RM based on its serial number. You may use taf.hw.pdu library with __init__.py directly,
        # or search for fitting KW in testsuite/Wroclaw/SISO/SRAN/REAL_HW/Resources/Robot/PDU.robot
        # 2. Do not forget to raise Fatal Error (BuiltIn().fatal_error()) to stop TC execution
        # 3. Kindly inform user about this action and ask for manual log download and analysis
        # 4. Bare in mind there may be more RM affected. Do not raise Fatal Error now. Maybe on end of
        # start_lmi_flow_on_all_nodes method?
        logger.error(f"Post mortem action for RM {rm_sn} will not be executed as it is not implemented yet!")

    @run_method_and_handle_exception
    def _get_rm_object_from_init(self, rm_sn):
        return next((rm for enb in self.tl.enbs for rm in enb.rms if rm.serial_number == rm_sn), None)

    @run_method_and_handle_exception
    @handle_unknown_rmod_type_error
    def _take_snapshot_via_lmi(self, rm_sn, node="unknown_node", rescue_action=False):
        base_logs_path = BuiltIn().get_variable_value("$CFG.test_logs_path", f".")
        iteration = BuiltIn().get_variable_value("$ITERATION", 0)
        iteration_path = f"/Loop_{iteration}" if iteration != 0 else ""
        logs_path = base_logs_path + f"{iteration_path}/BTSFiles/{node}/LMI_logs/{rm_sn}"
        with lmi_connection(self.rm_obj_dict[rm_sn], logs_path=logs_path) as (lmi, ru_alias):
            logger.console(f"Saving snapshot via LMI for RM {rm_sn} to {logs_path}. Recovery Action: {rescue_action}")
            try:
                take_snap_status = lmi.take_snapshot(
                    alias=ru_alias,
                    target_path_on_vm=logs_path,
                    # reset_rmod=rescue_action
                )
                if not take_snap_status:
                    logger.warn(f"Failed to take snapshot for RM {rm_sn}")
                    return False
                logger.warn(f"Snapshot taken for RM {rm_sn} and saved in {logs_path}")
                return True
                # take_snap_status = lmi.take_snapshot(
                #     alias=ru_alias,
                #     target_path_on_vm=logs_path,
                #     reset_rmod=rescue_action
                # )
                # if not take_snap_status:
                #     logger.warn(f"Failed to take snapshot for RM {rm_sn}")
                #     return False
                # logger.warn(f"Snapshot taken for RM {rm_sn} and saved in {logs_path}")
                # return True
            except Exception as e:
                logger.error(f"Failed to take snapshot for RM {rm_sn}! Read info logs for more details")
                logger.info(e)
                return False

    @run_method_and_handle_exception
    def _analyze_rm_alarms_on_node(self, node):
        # Refresh allowed alarms list before each node analysis. As it may change during TC execution
        self._refresh_allowed_alarms_list()

        # Get all active alarms on node
        active_alarms = admin().get_active_alarms(connection=node)
        logger.debug(f"Active alarms on node {node}: {active_alarms}")

        # Get all RMOD alarms
        active_rm_alarms = [alarm for alarm in active_alarms if "RMOD" in alarm.alarmingObjectIds[0]["internal"]]
        logger.debug(f"Active RM alarms on node {node}: {active_rm_alarms}")

        # Remove allowed alarms from list
        if self.allowed_alarms_list is not None:
            active_rm_alarms = [alarm for alarm in active_rm_alarms if alarm.faultId not in self.allowed_alarms_list]
            logger.debug(f"Allowed alarms (${self.allowed_alarms_list}) removed from active RM alarms:" +
                         f" {active_rm_alarms}")

        # Do not continue if there is no RM alarms
        if len(active_rm_alarms) == 0:
            logger.debug(f"No RM alarms on node {node}")
            return None, None
        logger.debug(f"Active RM alarms on node : {active_rm_alarms}")

        # Get list of RM serial numbers affected by alarms
        sn_of_rm_alarms = [alarm.serialNo for alarm in active_rm_alarms]
        logger.debug(f"SN of RM affected by any alarm on node {node}: {sn_of_rm_alarms}")

        # Build list of RM serial numbers affected by alarm 10
        active_fid10_alarms = [alarm for alarm in active_alarms if alarm.faultId == 10]
        if len(active_fid10_alarms) == 0:
            logger.debug(f"No active FID 10 alarms on node {node}")
            sn_of_rm_fid10 = list()
        else:
            logger.debug(f"Active FID 10 alarms on node {node}: {active_fid10_alarms}")
            sn_of_rm_fid10 = [alarm.serialNo for alarm in active_rm_alarms]
            logger.debug(f"SN of RM affected by FID 10 alarm on node {node}: {sn_of_rm_fid10}")

        # Build list of RM serial numbers affected by alarm other than 10
        sn_of_rm_except_fid10 = [sn for sn in sn_of_rm_alarms if sn not in sn_of_rm_fid10]
        logger.debug(f"SN of RM affected by any alarm except FID 10 on node {node}: {sn_of_rm_except_fid10}")

        return sn_of_rm_except_fid10, sn_of_rm_fid10

    @run_method_and_handle_exception
    def _refresh_allowed_alarms_list(self):
        # Load CUSTOM_LMI_ALLOWED_ALARMS variable safely
        # This variable is used to allow only alarms in LMI flow. Does not apply to other parts of the TC. May results
        # in unexpected behavior as alarm may trigger TC Fail in other parts of TC.
        try:
            allowed_user_alarms_list = BuiltIn().get_variable_value("$CUSTOM_LMI_ALLOWED_ALARMS", list())
            logger.debug(f"User provided allowed alarms via $CUSTOM_LMI_ALLOWED_ALARMS variable:\n" +
                         f"{allowed_user_alarms_list}")
            allowed_user_alarms_list = [
                int(re.search(r'faultId=(\d+)', fid).group(1)) for fid in allowed_user_alarms_list
                ]
            logger.debug(f"Parsed CUSTOM_LMI_ALLOWED_ALARMS list:\n{allowed_user_alarms_list}")
        except Exception as e:
            allowed_user_alarms_list = list()
            logger.warn(f"Failed to load $CUSTOM_LMI_ALLOWED_ALARMS list!")
            logger.debug(e)

        # Load GLO_ADMIN_ALLOWED_ALARMS variable safely
        # This variable is used in many parts of TC
        try:
            allowed_glo_admin_alarms_list = BuiltIn().get_variable_value("$GLO_ADMIN_ALLOWED_ALARMS", list())
            logger.debug(f"List of allowed alarms from $GLO_ADMIN_ALLOWED_ALARMS variable:\n" +
                         f"{allowed_glo_admin_alarms_list}")
            allowed_glo_admin_alarms_list = [
                int(re.search(r'faultId=(\d+)', fid).group(1)) for fid in allowed_glo_admin_alarms_list
                ]
            logger.debug(f"Pased $GLO_ADMIN_ALLOWED_ALARMS list:\n{allowed_glo_admin_alarms_list}")
        except Exception as e:
            allowed_glo_admin_alarms_list = list()
            logger.warn(f"Failed to load $GLO_ADMIN_ALLOWED_ALARMS list!")
            logger.debug(e)

        # Load CUSTOM_LMI_FORCE_CHECK_ALARMS variable safely
        # This variable allows to force check alarms even if they are in allowed alarms list. You may wany to allow
        # alarm in GLO_ADMIN_ALLOWED_ALARMS to pass through TC Setup and trigger LMI Flow.
        try:
            force_check_alarms_list = BuiltIn().get_variable_value("$CUSTOM_LMI_FORCE_CHECK_ALARMS", list())
            logger.debug(f"List of allowed alarms from $CUSTOM_LMI_FORCE_CHECK_ALARMS variable:\n" +
                         f"{force_check_alarms_list}")
            force_check_alarms_list = [
                int(re.search(r'faultId=(\d+)', fid).group(1)) for fid in force_check_alarms_list
                ]
            logger.debug(f"Pased $CUSTOM_LMI_FORCE_CHECK_ALARMS list:\n{force_check_alarms_list}")
        except Exception as e:
            force_check_alarms_list = list()
            logger.warn(f"Failed to load $CUSTOM_LMI_FORCE_CHECK_ALARMS list!")
            logger.debug(e)

        # Result of combined CUSTOM_LMI_ALLOWED_ALARMS and GLO_ADMIN_ALLOWED_ALARMS lists and removed
        # CUSTOM_LMI_FORCE_CHECK_ALARMS from it
        self.allowed_alarms_list = sorted(list({
            fid for fid in allowed_user_alarms_list+allowed_glo_admin_alarms_list if fid not in force_check_alarms_list
            }))

        logger.debug(f"Loaded allowed alarms list:\n{self.allowed_alarms_list}")
        return self.allowed_alarms_list

    @run_method_and_handle_exception
    def _refresh_cfg_variable(self):
        # As CFG dictionary may vary, its loading should be repeated each time before reading attempt
        self.cfg = BuiltIn().get_variable_value("$CFG", None)
        logger.debug(f"Loaded CFG variable:\n{self.cfg}")
        return self.cfg

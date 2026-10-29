import json
import re
from functools import wraps
from typing import List

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh

DEFAULT_ALARM_LIST = [
    {'faultNumber': 2,    'triggerType': 'onFaultDetection',    'snapshotCoverageLevel': 'MinorWithoutRFLogs'},
    {'faultNumber': 1996, 'triggerType': 'onFaultDetection',    'snapshotCoverageLevel': 'L1Files'},
    {'faultNumber': 4076, 'triggerType': 'onFaultDetection',    'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4546, 'triggerType': 'onFaultDetection',    'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4548, 'triggerType': 'onFaultDetection',    'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4599, 'triggerType': 'onFaultDetection',    'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4600, 'triggerType': 'onFaultDetection',    'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4601, 'triggerType': 'onFaultDetection',    'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4694, 'triggerType': 'onFaultDetection',    'snapshotCoverageLevel': 'L1Files'},
    {'faultNumber': 4707, 'triggerType': 'onFaultDetection',    'snapshotCoverageLevel': 'L1Files'},
    {'faultNumber': 6253, 'triggerType': 'onFaultDetection',    'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 1815, 'triggerType': 'onAlarmSend',         'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 1868, 'triggerType': 'onAlarmSend',         'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 3030, 'triggerType': 'onAlarmSend',         'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4090, 'triggerType': 'onAlarmSend',         'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4261, 'triggerType': 'onAlarmSend',         'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4463, 'triggerType': 'onAlarmSend',         'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4547, 'triggerType': 'onAlarmSend',         'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4708, 'triggerType': 'onAlarmSend',         'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4709, 'triggerType': 'onAlarmSend',         'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 10,   'triggerType': 'onAlarmCancellation', 'snapshotCoverageLevel': 'Full'},
    {'faultNumber': 4352, 'triggerType': 'onAlarmCancellation', 'snapshotCoverageLevel': 'Full'},
]


class ParameterException(Exception):
    """Exception class for problem with parameter value"""


class AlarmNotVisible(Exception):
    """Alarm is not visible"""


class AlarmVisible(Exception):
    """Alarm is visible but it should not be"""


def admin_connect(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        try:
            self.conn.connect_to(bts_host=self.hostname, username=self.username, password=self.password)
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            self.conn.teardown_admin()

    return wrapper


class GnbApiWeb:
    def __init__(self):
        self.tl = BuiltIn().get_variable_value("${{{}}}".format("tl"), None)
        self.username = self.tl.gnbs[0].cu.oam_http_connection_details.username
        self.hostname = self.tl.gnbs[0].cu.backhaul_site_oam_ip.v4.split("/")[0]
        self.password = self.tl.gnbs[0].cu.oam_http_connection_details.password
        self.mrbts_id = self.tl.gnbs[0].instance_id
        self.conn = admin()

    @admin_connect
    def configure_lss_account(self, lss_username, lss_password):
        param = self.conn.configure_lss_account(lss_username=lss_username, lss_password=lss_password)

    @admin_connect
    def get_parameters(self, dist_name, pattern=None, parameter=None):
        if parameter:
            param = self.conn.get_parameters(dist_name=dist_name)
            return param[parameter]
        else:
            param = self.conn.get_parameters(dist_name=dist_name, pattern=pattern)
            return param[pattern]

    @admin_connect
    def get_bts_info(self):
        bts_info = self.conn.get_bts_info()
        return bts_info

    @admin_connect
    def get_managed_objects(self, class_name, parameter, timeout=30):
        output = self.conn.get_managed_objects(class_name=class_name, timeout=timeout)
        return output[0]['parameters'][parameter]

    @admin_connect
    def prepare_dist_name_with_autoloaded_mrbts_id(self, object_dist_name):
        bts_info = self.conn.get_bts_info()
        bts_id = bts_info['id']['internal']
        dist_name = '{bts_id}/{object_dist_name}'.format(bts_id=bts_id, object_dist_name=object_dist_name)
        return dist_name

    @admin_connect
    def perform_parameter_recommissioning(self,
                                          dist_name,
                                          parameter,
                                          operation,
                                          value,
                                          skip_parameter_relation_errors=True,
                                          should_activate=True):
        """
        Perform parameter recommissioning
        :param dist_name: (str) object dist name
        :param parameter: (str) parameter name
        :param operation: (str) update or delete
        :param value: (str/list) value
        :param skip_parameter_relation_errors: skip parameter relation errors
        :param should_activate : should automatically activate plan
        """
        logger.debug("{} {}".format(operation.upper(), value))
        status = self.conn.perform_parameter_recommissioning(
            dist_name=dist_name,
            parameter=parameter,
            operation=operation,
            value=value,
            skip_parameter_relation_errors=skip_parameter_relation_errors,
            should_activate=should_activate)
        self.check_commissioning_results(status)

    @admin_connect
    def perform_object_recommissioning(self,
                                       dist_name,
                                       parameter,
                                       operation,
                                       skip_parameter_relation_errors=True,
                                       should_activate=True):
        status = self.conn.perform_object_recommissioning(
                    dist_name=dist_name,
                    parameter=parameter,
                    operation=operation,
                    skip_parameter_relation_errors=skip_parameter_relation_errors,
                    should_activate=should_activate)
        self.check_commissioning_results(status)

    @admin_connect
    def reset_site(self):
        self.conn.reset_site()

    def check_if_fault_snapshot_triggers_is_activated(self):
        dist_name = self.prepare_dist_name_with_autoloaded_mrbts_id(
                        BuiltIn().get_variable_value("${SNAP_TRIG_DIST_NAME}"))
        param = self.get_parameters(dist_name=dist_name,
                                    pattern='actDefaultFaultSnapTriggers')
        if param is False:
            raise ValueError('actDefaultFaultSnapTriggers is not activated')

    def disable_actDefaultFaultSnapTriggers(self):
        self.perform_parameter_recommissioning(
            dist_name='MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1'.format(self.mrbts_id),
            parameter='actDefaultFaultSnapTriggers',
            operation="update",
            value='false'
        )

    def enable_actDefaultFaultSnapTriggers(self):
        self.perform_parameter_recommissioning(
            dist_name='MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1'.format(self.mrbts_id),
            parameter='actDefaultFaultSnapTriggers',
            operation="update",
            value='true'
        )

    def set_diagnostic_snap_destination(self,
                                        location="externalHTTPSServer",
                                        skip_parameter_relation_errors=True,
                                        should_activate=True):
        """
        Parameter defines the operator's selection of the default diagnostic snapshot upload destination server.
        :param location: (str) location where the snapshot will be sent ("netact", "lss", "externalHTTPSServer")
        :param skip_parameter_relation_errors: (bool)
        :param should_activate: (bool)
        """
        destinations = ["netact", "lss", "externalHTTPSServer"]
        if location in destinations:
            dist_name = self.prepare_dist_name_with_autoloaded_mrbts_id(
                            BuiltIn().get_variable_value("${SNAP_TRIG_DIST_NAME}"))
            snap_location = self.get_parameters(dist_name=dist_name, pattern="diagSnapDestination")
            if snap_location == location:
                logger.debug("Parameter {} was already set.".format(location))
                return
            else:
                logger.debug("Change parameter on {}".format(location))
                parameters = [
                    {
                        "parameterName": "diagSnapDestination",
                        "operation": "update",
                        "value": "{}".format(location),
                    }
                ]
                self.perform_object_recommissioning(
                    dist_name="MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1".format(self.mrbts_id),
                    parameter=parameters,
                    operation="update",
                    skip_parameter_relation_errors=skip_parameter_relation_errors,
                    should_activate=should_activate)
        else:
            raise ParameterException("Parameter {} is not availabe in list {}".format(location, destinations))

    def set_diagnostic_snap_destination_for_fault_6450(self,
                                                       location="disabled",
                                                       skip_parameter_relation_errors=True,
                                                       should_activate=True,):
        """
        Parameter defines the operator's selection of the default diagnostic snapshot upload destination server.
        :param location: (str) location where the snapshot will be sent ("netact", "lss", "externalHTTPSServer")
        :param skip_parameter_relation_errors: (bool)
        :param should_activate: (bool)
        """
        destinations = ["netact", "lss", "disabled"]
        if location in destinations:
            dist_name = self.prepare_dist_name_with_autoloaded_mrbts_id(
                            BuiltIn().get_variable_value("${SNAP_TRIG_DIST_NAME}"))
            param = self.get_parameters(dist_name=dist_name, pattern="snapshotUploadDestinationForFault6450")
            if param == location:
                logger.debug("Parameter {} was already set.".format(location))
                return
            else:
                logger.debug("Change parameter on {}".format(location))
                parameters = [
                    {
                        "parameterName": "snapshotUploadDestinationForFault6450",
                        "operation": "update",
                        "value": "{}".format(location),
                    }
                ]
                self.perform_object_recommissioning(
                    dist_name="MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1".format(self.mrbts_id),
                    parameter=parameters,
                    operation="update",
                    skip_parameter_relation_errors=skip_parameter_relation_errors,
                    should_activate=should_activate)
        else:
            raise ParameterException("Parameter {} is not availabe in list {}".format(location, destinations))

    def set_ip_port_directory_for_lss(self, ip_addr, port, directory):
        dist_name = self.prepare_dist_name_with_autoloaded_mrbts_id(
                        BuiltIn().get_variable_value("${SNAP_TRIG_DIST_NAME}"))
        param = self.get_parameters(dist_name=dist_name, parameter='lssConfig')
        if param:
            operation = "update"
            logger.debug("LSS was set to {}".format(param))
        else:
            operation = "create"
            logger.debug("LSS was not set")
        parameters = [
            {
                "parameterName": "lssConfig",
                "operation": operation,
                "value": [
                    {
                        "directory": directory,
                        "lssIPaddress": ip_addr,
                        "lssPortNo": port
                    }
                ]
            }
        ]
        logger.debug("Change LSS ip to  {}".format(ip_addr))
        logger.debug("Change LSS port to  {}".format(port))
        self.perform_object_recommissioning(
            dist_name="MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1".format(self.mrbts_id),
            parameter=parameters,
            operation="update")

    def get_list_of_faults(self, sanitize: bool = True) -> List[dict]:
        """Fetches list of currently active faults

        :param bool sanitize: should list of faults have only `faultNumber` & `triggerType` properties, defaults to True
        :return List of dicts: _description_
        """
        dist_name = self.prepare_dist_name_with_autoloaded_mrbts_id(
                        BuiltIn().get_variable_value("${SNAP_TRIG_DIST_NAME}"))
        trigger_list = self.get_parameters(
                    dist_name=dist_name,
                    pattern='faultSnapshotTriggers')
        if sanitize:
            for trigger in trigger_list:
                trigger.pop('snapshotCoverageLevel', None)
                trigger.pop('snapshotFilterKeywords', None)
        return trigger_list

    def restore_default_fault_snapshot_triggers(self):
        self.perform_parameter_recommissioning(
            dist_name="MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1".format(self.mrbts_id),
            parameter="faultSnapshotTriggers",
            operation="update",
            value=DEFAULT_ALARM_LIST,
        )

    def set_fault_snapshot_trigger(self, fault_number, trigger_type):
        """
        Defines a list of BTS Faults that trigger automatic symptom data collection
        :param fault_number:
        :param trigger_type:
        """
        available_trigger = ["onFaultDetection", "onAlarmSend", "onFaultCancellation", "onAlarmCancellation"]
        if trigger_type in available_trigger:
            default_alarm_list = self.get_current_fault_list()
            if default_alarm_list:
                visible_fault = [fault for fault in default_alarm_list if fault['faultNumber'] == int(fault_number)
                                 and fault['triggerType'] == trigger_type]
                if not visible_fault:
                    param = {"faultNumber": int(fault_number), "triggerType": trigger_type}
                    default_alarm_list.append(param)
                    self.perform_parameter_recommissioning(
                        dist_name="MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1".format(self.mrbts_id),
                        parameter="faultSnapshotTriggers",
                        operation="update",
                        value=default_alarm_list,
                    )
                else:
                    logger.console("Fault snapshot trigger {} {} already set".format(fault_number, trigger_type))
            else:
                raise ParameterException("Default list of alarms is not set")

        else:
            raise ParameterException("Parameter {} is not available in list {}".
                                     format(trigger_type, available_trigger))

    def verify_parameter_appear_in_fault_snapshot_trigger(self, parameter, result):
        for fault in result:
            return bool(parameter in fault)

    def refactor_none_object_on_string_in_ouput(self, result):
        string_data = json.dumps(result)
        refactor = string_data.replace('null', '""')
        new_data = json.loads(refactor)
        return new_data

    def delete_fault_snapshot_trigger(self, fault_number=None, trigger_type=None):
        """
        Delete selected fault number and trigger type. If not set delete all faults.
        :param fault_number: str
        :param trigger_type: str
        """
        actual_param = self.get_current_fault_list()
        if actual_param:
            visible_fault = [fault for fault in actual_param if fault['faultNumber'] == int(fault_number)
                             and fault['triggerType'] == trigger_type]
            if visible_fault:
                actual_param.remove(visible_fault[0])
                self.perform_parameter_recommissioning(
                    dist_name="MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1".format(self.mrbts_id),
                    parameter="faultSnapshotTriggers",
                    operation="update",
                    value=actual_param)
            else:
                logger.console('There is not such {} and {}'.format(fault_number, trigger_type))
        else:
            logger.console("There is not set fault snapshot triggers")

    @staticmethod
    def are_faults_equal(fault_1, fault_2):
        return (fault_1['faultNumber'] == fault_2['faultNumber']) and\
               (fault_1['triggerType'] == fault_2['triggerType'])

    @staticmethod
    def is_fault_in_default_faults_list(fault: dict):
        for trigger in DEFAULT_ALARM_LIST:
            if fault['faultNumber'] == trigger['faultNumber'] and fault['triggerType'] == trigger['triggerType']:
                return True
        return False

    @staticmethod
    def create_parameter_change_list(faults_list):
        """
        Create list of dict with parameters and value
        :param faults_list: (list) fault value
        :return list of dict
        """
        parameters = []
        for faults in faults_list:
            fault_number, trigger_type = faults
            parameter_change_list = {
                "faultNumber": fault_number,
                "triggerType": trigger_type,
            }
            parameters.append(parameter_change_list)
        logger.info(parameters)
        return parameters

    @staticmethod
    def check_commissioning_results(result):
        nidd_result = result["validationResult"]["niddValidationResult"]["status"]
        status = result["commissioningResult"]["activationResult"]["resultNode"][
            "parameters"
        ]["result"]
        if nidd_result != "OK" and status != "Success":
            raise Exception(
                "Recommission failed. Result {}, {}".format(nidd_result, status)
            )

    @admin_connect
    def check_if_alarm_is_visible(self, faultid, severity, timeout):
        if severity:
            parameters = "faultId={}, severity={}".format(str(faultid), severity)
        else:
            parameters = "faultId={}".format(str(faultid))

        try:
            self.conn.assert_alarm_active(parameters=parameters, timeout=timeout)
        except Exception:
            raise AlarmNotVisible("Alarm {} with severity {} is not visible".format(faultid, severity))

    @admin_connect
    def check_if_alarm_is_not_visible(self, faultid, severity, timeout):
        parameters = "faultId={}, severity={}".format(str(faultid), severity)
        try:
            self.conn.assert_alarm_inactive(parameters=parameters, timeout=timeout)
        except Exception:
            raise AlarmVisible("Alarm {} with severity {} is visible but is should not be".format(faultid, severity))

    @admin_connect
    def get_timestamp_for_given_fault(self, fault_id):
        alarms = self.conn.get_active_alarms(timeout=30)
        for alarm in alarms:
            if str(alarm['faultId']) == fault_id:
                return alarm['btsObservationTime'][0:12]
        raise Exception('There is not visible fault {} on BTS'.format(fault_id))

    @admin_connect
    def get_timestamp_of_clearing_fault(self, fault_id):
        """
        Get time when given alaram was cleared.
        :param fault_id: Fault ID
        :return: timestamp example -
        """
        alarms = self.conn.get_historic_alarms(timeout=120, load_history=True)
        timestamps = []
        for alarm in alarms:
            if str(alarm['faultId']) == fault_id:
                timestamps.append(alarm['clearedTime'][0:12])
        if timestamps:
            return max(timestamps)
        raise Exception('There is no following fault {} in history alarm list'.format(fault_id))

    def get_current_fault_list(self):
        dist_name = self.prepare_dist_name_with_autoloaded_mrbts_id(
                        BuiltIn().get_variable_value("${SNAP_TRIG_DIST_NAME}"))
        actual_alarm_list = self.get_parameters(dist_name=dist_name,
                                                pattern="faultSnapshotTriggers")
        refactor_actual_alarm_list = self.refactor_none_object_on_string_in_ouput(actual_alarm_list)
        return refactor_actual_alarm_list

    def set_snapshotUploadDelayForFault6450(self, delay=0, skip_parameter_relation_errors=True, should_activate=True):
        """
        This parameter defines the delay after which BTS shall automatically collect and upload snapshot files on
        fault 6450 detection.
        :param delay: (str) delay in hours from 0 to 24
        :param skip_parameter_relation_errors: (bool)
        :param should_activate: (bool)
        """
        logger.console("Change value of parameter snapshotUploadDelayForFault6450 to: {}".format(delay))
        parameters = [
            {
                "parameterName": "snapshotUploadDelayForFault6450",
                "operation": "update",
                "value": "{}".format(delay),
            }
        ]
        self.perform_object_recommissioning(
            dist_name="MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1".format(self.mrbts_id),
            parameter=parameters,
            operation="update",
            skip_parameter_relation_errors=skip_parameter_relation_errors,
            should_activate=should_activate)

    def set_maxNumSnapByFaultTrigPerDay(self, max_num, skip_parameter_relation_errors=True, should_activate=True):
        """
        This parameter defines  max number of snapshots triggered by predefined fault triggers for last 24 hours.
        :param max_num: (str) max number of snapshot per day from 1 to 200
        :param skip_parameter_relation_errors: (bool)
        :param should_activate: (bool)
        """
        logger.console("Change value of parameter maxNumSnapByFaultTrigPerDay to: {}".format(max_num))
        parameters = [
            {
                "parameterName": "maxNumSnapByFaultTrigPerDay",
                "operation": "update",
                "value": "{}".format(max_num),
            }
        ]
        self.perform_object_recommissioning(
            dist_name="MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1".format(self.mrbts_id),
            parameter=parameters,
            operation="update",
            skip_parameter_relation_errors=skip_parameter_relation_errors,
            should_activate=should_activate)

    def set_actCli(self, actcli_value, skip_parameter_relation_errors=True, should_activate=True):
        dist_name = self.prepare_dist_name_with_autoloaded_mrbts_id(
                        BuiltIn().get_variable_value("${ACTCLI_DIST_NAME}"))
        actcli_current_value = self.get_parameters(dist_name=dist_name,
                                                   parameter="actCli")
        if str(actcli_current_value) == str(actcli_value):
            logger.console("ActCli parameter already set on {}".format(actcli_value))
            return
        else:
            self.perform_parameter_recommissioning(
                dist_name='MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1'.format(self.mrbts_id),
                parameter="actCli",
                operation="update",
                value=actcli_value,
            )

    def x2c_link_lock_unlock(self, status):
        x2c_link_status = self.get_managed_objects(class_name='LTEENB_A', parameter='x2LinkLock')
        if x2c_link_status == status:
            logger.info('x2LinkLock already {}'.format(status))
        else:
            self.perform_parameter_recommissioning(
                dist_name='MRBTS-{0}/NRBTS-{0}/LTEENB-0'.format(self.mrbts_id),
                parameter="x2LinkLock",
                operation="update",
                value=status,
            )


class GnbSsh:
    def __init__(self):
        self.tl = BuiltIn().get_variable_value("${{{}}}".format("tl"), None)
        self.ssh_user = self.tl.gnbs[0].cu.oam_ssh_connection_details.username
        self.ssh_hostname = self.tl.gnbs[0].cu.oam_ssh_connection_details.addr
        self.ssh_password = self.tl.gnbs[0].cu.oam_ssh_connection_details.password
        self.ssh = ssh()
        self.alias = "sshgnb"
        self.already_connected = False

    def connect(self):
        if self.already_connected:
            return
        self.ssh.connect_to(hostname=self.ssh_hostname,
                            username=self.ssh_user,
                            password=self.ssh_password,
                            alias=self.alias)
        self.already_connected = True

    def disconnect(self):
        if not self.already_connected:
            return
        self.ssh.disconnect(self.alias)
        self.already_connected = False

    def kill_sigsegv(self):
        self.connect()
        KILL_COMMAND = "kill -s SIGSEGV $$"
        self.ssh.send_command(KILL_COMMAND, connection=self.alias)
        self.disconnect()

    def kill_ccs_daemon(self):
        self.connect()
        PS_COMMAND = "ps -ef | grep -E 'CCSDaemonExe.*15007' | grep -v 'grep' | awk '{print $2}' |  xargs -r kill -6"
        self.ssh.execute(PS_COMMAND, connection=self.alias)
        self.disconnect()

    def verify_if_bts_gather_core_dumps_logs(self):
        CORE_DUMPS_LOGS_FILENAME = r'.*_bt-coreinfo.txt'
        FIND_COMMAND = f"find / -regex {CORE_DUMPS_LOGS_FILENAME} 2>/dev/null"
        NODE_COMMAND = "ownnid"

        self.connect()
        found_core_dumps_logs_filepaths = self.ssh.execute(FIND_COMMAND, connection=self.alias)

        if not found_core_dumps_logs_filepaths:
            raise FileNotFoundError(f"Command '{FIND_COMMAND}' does not found any matching files!")

        found_core_dumps_logs_filepaths = found_core_dumps_logs_filepaths.splitlines()  # in case find found more than 1
        node_id = self.ssh.execute(NODE_COMMAND, connection=self.alias).strip()
        CORE_DUMPS_FILENAME_EXACT_REGEX = fr'/ffs/.*/A/dumps/node_{node_id}/{node_id}_bt-coreinfo.txt'

        matching_files = filter(lambda path: path if re.match(CORE_DUMPS_FILENAME_EXACT_REGEX, path) else None,
                                found_core_dumps_logs_filepaths)
        matching_files = list(matching_files)

        if not matching_files:
            raise FileNotFoundError(f"Command '{FIND_COMMAND}' does not found any matching files!")

        logger.debug(f"Command '{FIND_COMMAND}' found core dumps file(s): {matching_files}")

from pprint import pformat
from robot.libraries.BuiltIn import logger
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification, login_logout
from helpers_12097 import f_log


class Fault_verifier(GnbAlarmVerification):
    def __init__(self):
        super().__init__()

    @login_logout
    def get_alarms(self, bts_id=0, du_id=0, active=True, timeout=30, detailed_output=False):
        if not active:
            alarms = self.admin.get_alarms(connection=self.rest_alias.format(bts_id, du_id),
                                           timeout=timeout, detailed_output=detailed_output)
            logger.trace(f'{f_log(2)}alarms:\n{pformat(alarms)}', html=True)
            return alarms
        else:
            active_alarms = self.admin.get_active_alarms(connection=self.rest_alias.format(bts_id, du_id),
                                                         timeout=timeout, detailed_output=detailed_output)
            logger.trace(f'{f_log(2)}active_alarms:\n{pformat(active_alarms)}', html=True)
            return active_alarms

    def log_alarms(self, active=True, alarms=None, timeout=30, also_console=False):
        alarms = alarms or self.get_alarms(active=active, timeout=timeout)
        if not active:
            logger.info("Alarm brief", also_console=also_console)
            for alarm in alarms:
                logger.info(f"*AlarmId: {alarm['alarmId']}; alarmName: {alarm['alarmName']}\n"
                            + f" |-FaultId: {alarm['faultId']}; faultName: {alarm['alarmInformation']['alarmDetail']}"
                            + f"; faultSeverity: {alarm['faultSeverity']}\n"
                            + f" |-Object configuration: {alarm['alarmingObjectIds'][0].get('configuration')}\n"
                            + f" |-Object runtime: {alarm['alarmingObjectIds'][0].get('runtime')}",
                            also_console=also_console)
        else:
            logger.info("Active alarm brief", also_console=also_console)
            for alarm in alarms:
                logger.info(f"*AlarmId: {alarm['alarmId']}; alarmName: {alarm['alarmName']}\n"
                            + f" |-FaultId: {alarm['additionalFaultID']}; faultName: {alarm['faultName']}"
                            + f"; faultSeverity: {alarm['faultSeverity']}\n"
                            + f" |-Object configuration: {alarm['alarmingObjectIds'][0].get('configuration')}\n"
                            + f" |-Object runtime: {alarm['alarmingObjectIds'][0].get('runtime')}",
                            also_console=also_console)

    def verify_fault_present_for_exact_objects(self, fault_id=None, fault_name=None,
                                               objects=[], object_type='runtime',
                                               timeout=30):
        if not (fault_id or fault_name):
            raise AttributeError('Provide at least one fault designator - id or name')
        objects = set(objects)
        fault_id = int(fault_id) if fault_id else None
        alarming_objects = []
        active_alarms = self.get_alarms(timeout=timeout)
        self.log_alarms(alarms=active_alarms)
        for alarm in active_alarms:
            if fault_id == alarm['additionalFaultID'] or fault_name == alarm['faultName']:
                logger.trace(f'{f_log()}{fault_id=}; {fault_name=}; ' +
                             f"object={alarm['alarmingObjectIds'][0].get(object_type)}", html=True)
                alarming_objects.append(alarm['alarmingObjectIds'][0].get(object_type))
        logger.info(f'{f_log()}{objects=}\n{alarming_objects=}', html=True)
        if len(objects) != len(alarming_objects) or objects != set(alarming_objects):
            raise AssertionError(f'For fault: {fault_id or fault_name} ' +
                                 f'{alarming_objects=} wasn\'t as expected: {objects=}')

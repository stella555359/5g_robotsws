from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.NetWorking import NetWorking

INCOMPATIBLE_SW_ON_RADIOS_FAULT_ID = 23
CELL_BLOCKED_FAULT_ID = 49
SSH_ENABLED_FAULT_ID = 61524
LMP_ACCESS_FAULT_ID = 61649
ETH_PORT_SECURITY_DISABLED_FAULT_ID = 4654
ROOT_ACCESS_ENABLED_FAULT_ID = 4655
RND_PORT_ENABLED_FAULT_ID = 61652
SANITY_CHECK_FAULT_ID = 4681
BTS_RESET_CAUSE_FAULT_ID = 4592
ALLOWED_FAULTS = [SSH_ENABLED_FAULT_ID, LMP_ACCESS_FAULT_ID,  ROOT_ACCESS_ENABLED_FAULT_ID,
                  ETH_PORT_SECURITY_DISABLED_FAULT_ID, RND_PORT_ENABLED_FAULT_ID, SANITY_CHECK_FAULT_ID]

ALLOWED_HISTORICAL_FAULTS = ALLOWED_FAULTS + [BTS_RESET_CAUSE_FAULT_ID, CELL_BLOCKED_FAULT_ID,
                                              INCOMPATIBLE_SW_ON_RADIOS_FAULT_ID]

NO_CONNECTION_TO_UNIT = 10
COMMUNICATION_FAILURE = 1806
FSP_SUBUNIT_LOST_LINK = 4341
NO_CONNECTION_BETWEEN_PRIMARY_AND_BTS_EXTENSION_SYSTEM_MODULE = 4352
VIRTUAL_NODE_NOT_RESPONDING = 4383
FORBIDDEN_TASK_FORCE_FAULTS = [NO_CONNECTION_TO_UNIT, COMMUNICATION_FAILURE, FSP_SUBUNIT_LOST_LINK,
                               NO_CONNECTION_BETWEEN_PRIMARY_AND_BTS_EXTENSION_SYSTEM_MODULE,
                               VIRTUAL_NODE_NOT_RESPONDING]


class BtsFaults(object):

    def __init__(self):
        self.ips = NetWorking()

    def log_active_faults(self, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.info(f"Logging active faults on GNB_{gnb_id}")
        msg = 'Active GNB_{} {} fault ({}) - {}'
        for fault in self._get_raw_faults_list(gnb_id, lmp_ip_if_gnb0):
            self._log_found_fault_warn_if_unexpected(gnb_id, fault, msg, ALLOWED_FAULTS)

    def log_historical_faults(self, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.info(f"Logging historical faults on GNB_{gnb_id}")
        msg = 'Historical GNB_{} {} fault: ({}) - {}'
        for fault in self._get_raw_historical_faults_list(gnb_id, lmp_ip_if_gnb0):
            self._log_found_fault_warn_if_unexpected(gnb_id, fault, msg, ALLOWED_HISTORICAL_FAULTS)

    @staticmethod
    def add_active_fault_to_allowed_list(fault_id):
        Logger.info(f"Adding active FaultId:{fault_id} to the allowed list")
        ALLOWED_FAULTS.append(fault_id)

    @staticmethod
    def remove_active_fault_from_allowed_list(fault_id):
        try:
            ALLOWED_FAULTS.remove(fault_id)
            Logger.info(f"Removing active FaultId:{fault_id} from the allowed list")
        except ValueError:
            Logger.debug(f"FaultId:{fault_id} was not on allowed list, nothing to remove")

    def is_fault_active(self, fault_id, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.info("Checking if fault {} is active".format(fault_id))
        for fault in self._get_raw_faults_list(gnb_id, lmp_ip_if_gnb0):
            if fault_id == int(fault['faultId']):
                return True
        return False

    def is_fault_activated_with_suppl_alarm_info(self, fault_id, suppl_alarm_info, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.info(f"Checking if fault: {fault_id} is active with supplAlarmInfo: {suppl_alarm_info}")
        for fault in self._get_raw_faults_list(gnb_id, lmp_ip_if_gnb0):
            if fault_id == int(fault['faultId']):
                if suppl_alarm_info in fault['supplAlarmInfo']:
                    return True
        return False

    def was_fault_active(self, fault_id, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.info("Checking if fault {} is visible in history".format(fault_id))
        for fault in self._get_raw_historical_faults_list(gnb_id, lmp_ip_if_gnb0):
            if fault_id == int(fault['faultId']):
                return True
        return False

    def is_forbidden_task_force_fault_raised(self, gnb_id=0, lmp_ip_if_gnb0=True, skip_fault10_checking=False):
        if skip_fault10_checking and NO_CONNECTION_TO_UNIT in FORBIDDEN_TASK_FORCE_FAULTS:
            Logger.warning("NO_CONNECTION_TO_UNIT fault is not checked in active faults")
            FORBIDDEN_TASK_FORCE_FAULTS.remove(NO_CONNECTION_TO_UNIT)
        for faultId in self._get_raw_faults_list(gnb_id, lmp_ip_if_gnb0):
            if int(faultId['faultId']) in FORBIDDEN_TASK_FORCE_FAULTS:
                Logger.warning(f"Forbidden fault {faultId['faultId']} is raised")
                return True
        return False

    def was_forbidden_task_force_fault_raised(self, gnb_id=0, lmp_ip_if_gnb0=True, skip_fault10_checking=False):
        # TODO: workaround - remove when PR717473 is RFT
        from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
        if Env.testline_name() == "7_16_UTE5GCLASSTL37" and Env.STREAM_SW == "SBTS00"\
                and COMMUNICATION_FAILURE in FORBIDDEN_TASK_FORCE_FAULTS:
            Logger.warning(f"{Env.testline_name()} is workarounding PR717473!")
            FORBIDDEN_TASK_FORCE_FAULTS.remove(COMMUNICATION_FAILURE)
        # end of Workaround
        if skip_fault10_checking and NO_CONNECTION_TO_UNIT in FORBIDDEN_TASK_FORCE_FAULTS:
            Logger.warning("NO_CONNECTION_TO_UNIT fault is not checked in the history faults")
            FORBIDDEN_TASK_FORCE_FAULTS.remove(NO_CONNECTION_TO_UNIT)
        for faultId in self._get_raw_historical_faults_list(gnb_id, lmp_ip_if_gnb0):
            if int(faultId['faultId']) in FORBIDDEN_TASK_FORCE_FAULTS:
                Logger.warning(f"Forbidden fault {faultId['faultId']} was raised in the BTS fault history")
                return True
        return False

    @staticmethod
    def _log_found_fault_warn_if_unexpected(gnb_id, fault, msg, expected_faults_list):
        if int(fault['faultId']) in expected_faults_list:
            Logger.debug(msg.format(gnb_id, fault['severity'], fault['faultId'], fault['faultName']))
        else:
            Logger.warning(msg.format(gnb_id, fault['severity'], fault['faultId'], fault['faultName']))

    def _get_raw_faults_list(self, gnb_id, lmp_ip_if_gnb0):
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            return api.get_active_alarms()

    def _get_raw_historical_faults_list(self, gnb_id, lmp_ip_if_gnb0):
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            return api.get_historic_alarms(load_history=True, timeout=60)

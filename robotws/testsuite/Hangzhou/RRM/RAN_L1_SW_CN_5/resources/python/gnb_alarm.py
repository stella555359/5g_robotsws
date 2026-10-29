# -*- coding:utf-8 -*-
"""
:copyright: Nokia Networks
:author: Civen Chen
:contact: civen.chen@nokia-sbell.com
"""
import logging

__all__ = [
    "GnbAlarmAnalyzer",
    "CASE_SPECIFIC_ALLOWED_ALARMS",
    "ALLOWED_ACTIVE_ALARMS",
    "ALLOWED_HISTORY_ALARMS",
]


CASE_SPECIFIC_ALLOWED_ALARMS = {
    # "TA case name": [fault_id],
    "5GC001576-AA_5GC000158_006_Multiple_QSFP_CABLINKs_And_Check_Rate": [4340],
    "5GC002361_A_AZNA_General_SiSo_RF_alarms_without_recovery": [6450],
    "5GC002361_A_AZNA_General_SiSo_RF_alarms_with_recovery": [6450],
    "5GC000430-A_01_05_Kylin_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise": [6450],
    "5GC000430-B_01_05_Amber_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise": [6450],
    "CB006081-5G-BB_AEQY_Auto_Automatic_RAT_SW_upgrade": [6450],
    "5GC001752_007_Startup_View_is_Auto-opening_by_the_BTS_EM_Application": [7300],
}

ALLOWED_ACTIVE_ALARMS = [
    61652,
    61524,
    61649,
    9000,
    4592,
    4527,
    1932,
    4334,
    61074,
    61618,
    4654,
    4687,
    4655,
]

ALLOWED_HISTORY_ALARMS = [
    61652,
    61524,
    61649,
    9000,
    4592,
    4527,
    1932,
    4334,
    61074,
    61618,
    7319,
    7300,
]


class GnbAlarmAnalyzer(object):
    def __init__(self):
        self.allowed_alarms = []
        self.case_specific_allowed = []
        self.unexpected_alarms = []

    def analysis_active_alarms(self, alarms, case_name):
        logging.info("Analyze Alarms from case: {}".format(case_name))
        for alarm in alarms:
            alarm_id = alarm["faultId"]
            if alarm_id in ALLOWED_ACTIVE_ALARMS:
                self.allowed_alarms.append(alarm_id)
                logging.info("Add alarm {} into allowed alarms list.".format(alarm_id))
            elif case_name.split(r"]")[-1] in CASE_SPECIFIC_ALLOWED_ALARMS:
                if alarm_id in CASE_SPECIFIC_ALLOWED_ALARMS[case_name]:
                    self.case_specific_allowed.append(alarm_id)
                    logging.info("Add alarm {} into case allowed alarms list.".format(alarm_id))
                else:
                    self.unexpected_alarms.append(alarm_id)
                    logging.info("Add alarm {} into unexpected alarms list.".format(alarm_id))
            else:
                self.unexpected_alarms.append(alarm_id)
                logging.info("Add alarm {} into unexpected alarms list.".format(alarm_id))
        return self.allowed_alarms, self.case_specific_allowed, self.unexpected_alarms

    def analysis_history_alarms(self, alarms, case_name):
        logging.info("Analyze History Alarms from case: {}".format(case_name))
        for alarm in alarms:
            alarm_id = alarm["faultId"]
            if alarm_id in ALLOWED_HISTORY_ALARMS:
                self.allowed_alarms.append(alarm_id)
                logging.info("Add alarm {} into allowed alarms list.".format(alarm_id))
            elif case_name.split(r"]")[-1] in CASE_SPECIFIC_ALLOWED_ALARMS:
                if alarm_id in CASE_SPECIFIC_ALLOWED_ALARMS[case_name]:
                    self.case_specific_allowed.append(alarm_id)
                    logging.info("Add alarm {} into case allowed alarms list.".format(alarm_id))
                else:
                    self.unexpected_alarms.append(alarm_id)
                    logging.info("Add alarm {} into unexpected alarms list.".format(alarm_id))
            else:
                self.unexpected_alarms.append(alarm_id)
                logging.info("Add alarm {} into unexpected alarms list.".format(alarm_id))
        return self.allowed_alarms, self.case_specific_allowed, self.unexpected_alarms

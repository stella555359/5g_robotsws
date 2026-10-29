# -*- coding: utf-8 -*-
"""
File providing lists of temporary ignored and critical alarms for classical BTS (SBTS) and cloud BTS (CBTS).
The alarms lists from this file are useful to be added to existing ignored and critical alarms lists from each
automated scenario alarm definition file. It is the responsibility of tester to fill them accordingly to known
issues to be skipped until official fix delivery.

These temporary ignored and critical alarm lists should be filled with corresponding info for each technology as below:

-  SBTS alarms: [alarmId=1111, faultId=2222], [alarmId=3333, faultId=4444, faultName='Alarm message'] (faultName its
optional)
ex: SBTS_TEMP_IGNORED_ALARMS = [{'alarmId': '1111', 'faultId': '2222'},
                                {'alarmId': '3333', 'faultId': '4444', 'faultName': 'Alarm message'}]

-  NR alarms: [alarmId=1111, faultId=2222], [alarmId=3333, faultId=4444, faultName='Alarm message'] (faultName its
optional)
ex: SBTS_TEMP_IGNORED_ALARMS = [{'alarmId': '1111', 'faultId': '2222'},
                              {'alarmId': '3333', 'faultId': '4444', 'faultName': 'Alarm message'}]

- LTE alarms: [alarmId=1111, faultId=2222], [alarmId=3333, faultId=4444, faultName='Alarm message'] (faultName its
optional)
ex: SBTS_TEMP_IGNORED_ALARMS = [{'alarmId': '1111', 'faultId': '2222'},
                               {'alarmId': '3333', 'faultId': '4444', 'faultName': 'Alarm message'}]

- CBTS CU alarms: [alarm_id=1111, fault_id=2222], [alarm_id=3333, fault_id=4444]
ex: CBTS_CU_TEMP_IGNORED_ALARMS = [{'alarm_id': '1111', 'fault_id': '2222'}, {'alarm_id': '3333', 'fault_id': '4444'}]

- CBTS VDU alarms: [alarm_id=1111, fault_id=2222], [alarm_id=3333, fault_id=4444]
ex: CBTS_VDU_TEMP_IGNORED_ALARMS = [{'alarm_id': '1111', 'fault_id': '2222'}, {'alarm_id': '3333', 'fault_id': '4444'}]

By default all these lists empty:

SBTS_TEMP_IGNORED_ALARMS = []
CBTS_CU_TEMP_IGNORED_ALARMS = []
CBTS_VDU_TEMP_IGNORED_ALARMS = []

SBTS_TEMP_CRITICAL_ALARMS = []
CBTS_CU_TEMP_CRITICAL_ALARMS = []
CBTS_VDU_TEMP_CRITICAL_ALARMS = []
"""

ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210 = [
    {"alarmId": "7111", "faultId": "4681"},
    {"alarmId": "7115", "faultId": "4681"},
]

ADMIN_COMMON_IGNORED_ALARMS = [
    {"alarmId": "7220", "faultId": "4654"},
    {"alarmId": "7220", "faultId": "4655"},
    {"alarmId": "7220", "faultId": "61649"},
    {"alarmId": "7220", "faultId": "61524"},
    {"alarmId": "7220", "faultId": "61652"},
    {"alarmId": "7109", "faultId": "61649"},
    {"alarmId": "7109", "faultId": "61524"},
    {"alarmId": "7109", "faultId": "61652"},
    {"alarmId": "7115", "faultId": "4681"},
    {"alarmId": "7220", "faultId": "4459"},
]

ADMIN_HISTORICAL_CRITICAL_ALARMS = [
    {"faultId": "52"},
    {"faultId": "4590"},
    {"faultId": "4341"},
    {"faultId": "6709"},
    {"faultId": "1806"},
]

ADMIN_COMMON_CRITICAL_ALARMS = []

SBTS_TEMP_IGNORED_ALARMS = [] + ADMIN_COMMON_IGNORED_ALARMS

SBTS_TEMP_CRITICAL_ALARMS = [] + ADMIN_COMMON_CRITICAL_ALARMS

CBTS_CU_COMMON_IGNORED_ALARMS = []

CBTS_CU_COMMON_CRITICAL_ALARMS = []

CBTS_VDU_COMMON_IGNORED_ALARMS = []

CBTS_VDU_COMMON_CRITICAL_ALARMS = []

CBTS_CU_TEMP_IGNORED_ALARMS = []

CBTS_VDU_TEMP_IGNORED_ALARMS = []

CBTS_CU_TEMP_CRITICAL_ALARMS = []

CBTS_VDU_TEMP_CRITICAL_ALARMS = []

CBTS_CU_HISTORICAL_CRITICAL_ALARMS = []

CBTS_VDU_HISTORICAL_CRITICAL_ALARMS = []

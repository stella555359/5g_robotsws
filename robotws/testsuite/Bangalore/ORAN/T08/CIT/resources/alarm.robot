*** Settings ***
Documentation
...    Resources for CB007814 & CB008957
Library    OperatingSystem

*** Keywords ***
Expected_alarm
    ${allowed_alarm_1}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61524
    ...                    fault_name=SSH enabled

    ${allowed_alarm_2}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4654
    ...                    fault_name=Ethernet port security is disabled

    ${allowed_alarm_3}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61649
    ...                    fault_name=LMP access via port 443

    ${allowed_alarm_4}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4655
    ...                    fault_name=Service account root access is enabled

    ${allowed_alarm_5}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61652
    ...                    fault_name=R&D Service Port enabled

    ${allowed_alarm_6}=    Create alarm
    ...                    alarm_id=7240
    ...                    fault_id=1261
    ...                    fault_name=RX out of order

    ${allowed_alarm_7}=    Create alarm
    ...                    alarm_id=7240
    ...                    fault_id=1262
    ...                    fault_name=RX out of order

    ${allowed_alarm_8}=    Create alarm
    ...                    alarm_id=7240
    ...                    fault_id=1263
    ...                    fault_name=RX out of order

    ${allowed_alarm_9}=    Create alarm
    ...                    alarm_id=7240
    ...                    fault_id=1264
    ...                    fault_name=RX out of order

    ${allowed_alarm_10}=    Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=7313
    ...                    fault_name=NgGnbInitPartialReset

    ${allowed_alarm_11}=    Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=4592
    ...                    fault_name=BTS Reset Cause

    ${allowed_alarm_12}=    Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=4681
    ...                    fault_name=Diagnostic Check Error

    ${allowed_alarms}=     Create list
    ...    ${allowed_alarm_1}
    ...    ${allowed_alarm_2}
    ...    ${allowed_alarm_3}
    ...    ${allowed_alarm_4}
    ...    ${allowed_alarm_5}
    ...    ${allowed_alarm_6}
    ...    ${allowed_alarm_7}
    ...    ${allowed_alarm_8}
    ...    ${allowed_alarm_9}
    ...    ${allowed_alarm_10}
	...    ${allowed_alarm_11}
    ...    ${allowed_alarm_12}

    [Return]    ${allowed_alarms}
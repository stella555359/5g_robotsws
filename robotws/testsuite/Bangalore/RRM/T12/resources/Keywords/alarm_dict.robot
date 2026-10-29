*** Settings ***
Documentation     This file contains a dictionary of the allowed alarms. This should be called post
...         cell setup and X2 setup in a simulated environment
...         author: Amitha Kadambi
...         contact: amitha.kadambi@nokia.com

Library    OperatingSystem
#Library    taf.sbts.oam.coam.admin
#Library    taf.gnb.oam.coam.admin    WITH NAME    coam
Library    taf.ul.alarms_watchdog

*** Keywords ***
Accepted_alarm
    ${allowed_alarm_1}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4655
    ...                    fault_name=Service account root access is enabled
    ${allowed_alarm_2}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4654
    ...                    fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61524
    ...                    fault_name=SSH enabled
    ${allowed_alarm_4}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61652
    ...                    fault_name=R&D Service Port enabled
    ${allowed_alarm_5}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4459
    ...                    fault_name=User Account has Default Password
    ${allowed_alarm_6}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61510
    ...                    fault_name=Automatic BTS Operator Certificate retrieval unsuccessful
    ${allowed_alarm_7}=    Create alarm
    ...                    alarm_id=7115
    ...                    fault_id=8000
    ...                    fault_name=Failure in connection between BTS and 3rd party tool
    ${allowed_alarm_8}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61649
    ...                    fault_name=LMP access via port 443
    ${allowed_alarms}=     Create list
    ...                    ${allowed_alarm_1}
    ...                    ${allowed_alarm_2}
    ...                    ${allowed_alarm_3}
    ...                    ${allowed_alarm_4}
    ...                    ${allowed_alarm_5}
    ...                    ${allowed_alarm_6}
    ...                    ${allowed_alarm_7}
    ...                    ${allowed_alarm_8}
    [Return]    ${allowed_alarms}

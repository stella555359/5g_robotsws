*** Settings ***
Documentation
...   author: Dubey Rahul Kumar
...   contact: rahul.kumar_dubey@nokia.com
...   Description: keywords for CB008796
Library    OperatingSystem
Library    taf.transport.ssh
Library    taf.sbts.oam.coam.admin
Library    taf.selenium.sbts
Library    taf.gnb.oam.coam.admin    WITH NAME    coam
Library    taf.ul.alarms_watchdog

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


    ${allowed_alarms}=     Create list
    ...                    ${allowed_alarm_1}
    ...                    ${allowed_alarm_2}
    ...                    ${allowed_alarm_3}
    ...                    ${allowed_alarm_4}
    ...                    ${allowed_alarm_5}

    [Return]    ${allowed_alarms}

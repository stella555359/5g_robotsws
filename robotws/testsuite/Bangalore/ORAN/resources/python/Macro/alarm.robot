*** Settings ***
Library           taf.gnb.oam.coam.admin             WITH NAME      coam
Library           Python/alarm.py

*** Keywords ***
Is Alarm Active in Admin
   [Arguments]   ${fault_id}   ${alias}=OAM
   ${active_alarms}=   coam.get_active_alarms   connection=${alias}
   ${is_alarm_present}=   alarm.check_fault_in_alarm_list   ${active_alarms}   ${fault_id}
   [Return]   ${is_alarm_present}

Alarm Should be Active In BTS
   [Arguments]   ${fault_id}   ${alias}=OAM
   ${is_alarm_present}=   Is Alarm Active In Admin   ${fault_id}   ${alias}
   Should be True   ${is_alarm_present}   msg=Alarm with Fault Id ${fault_id} not present in gnb.

Alarm Should Not Be Active in BTS
   [Arguments]   ${fault_id}   ${alias}=OAM
   ${is_alarm_present}=   Is Alarm Active In Admin   ${fault_id}   ${alias}
   Should Not be True   ${is_alarm_present}   msg=Alarm with Fault Id ${fault_id} present in gnb.

Is Alarm Present in Historical Alarms
   [Arguments]   ${fault_id}   ${alias}=OAM
   ${historical_alarms}=   coam.get_historical_alarms   connection=${alias}
   ${is_alarm_present}=   alarm.check_fault_in_alarm_list   ${historical_alarms}   ${fault_id}
   [Return]   ${is_alarm_present}

Alarm Should be Present in Historial Alarms
   [Arguments]   ${fault_id}   ${alias}=OAM
   ${is_alarm_present}=   Is Alarm Present in Historical Alarms   ${fault_id}   ${alias}
   Should be True   ${is_alarm_present}   msg=Alarm with Fault ID ${fault_id} not present in historical_alarms.

Get Critical Alarm List From Admin
    [Documentation]  	 This Keyword helps in getting the list of Critical Alarms present in the system
    ...                  Creation Date: 13-11-2019
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    ...                  The Keyword takes only the admin connection alias as input and returns the Critical alarms
    ...                  present in the system
    ...                  | ${alias} | Admin Connection alias used to get the list of alarms |
    ...                  | ${critical_alarm_list} | Returned variable that has list of critical alarms |
    [Arguments]   ${alias}=OAM
    ${alarm_list}    coam.get_active_alarms    connection=${alias}
    ${critical_alarm_list}    Get Critical Alarms List    ${alarm_list}
    [Return]    ${critical_alarm_list}

Get List of New Alarms Raised
    [Documentation]  	 This Keyword helps in getting the alarms that are not present in the first list of alarms
    ...                  Creation Date: 13-11-2019
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    ...                  The Keyword 2 arguments and returns list of alarms that are not present in the first argument
    ...                  | ${alarm_list} | The first list is base list which ideally has the alarms before test |
    ...                  | ${new_alarm_list} | The second list is the one that we have to determine how many new alarms
    ...                                        are raised. Ideally this is the collected after the test is completed |
    ...                  | ${alarm_diff} | Returned Variable which has the list of new alarms which is not present in
    ...                                    ${alarm_list} |
    [Arguments]    ${alarm_list}    ${new_alarm_list}
    ${alarm_diff}    Get New Alarms Raised    ${alarm_list}    ${new_alarm_list}
    [Return]    ${alarm_diff}

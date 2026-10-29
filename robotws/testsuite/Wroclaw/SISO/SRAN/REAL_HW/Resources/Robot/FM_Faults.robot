*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Prepare 'GLOBAL_ALLOWED_FAULTS' dictionary as shown in pattern:
...
...  \@{global_common_fault_list}   faultId=xxx
...  ...                            faultId=xxx, configObjectName=xxx
...  ...                            faultId=xxx, severity=Critical
...
...  \@{global_<node_id>_fault_list}   faultId=xxx
...  ...                               faultId=xxx, configObjectName=xxx
...  ...                               faultId=xxx, severity=Critical
...
...  \&{GLOBAL_ALLOWED_FAULTS}  common=\@{global_common_fault_list}  node_id=\@{global_<node_id>_fault_list}
...
...  GLOBAL_ALLOWED_FAULTS as dictionary can cover global allowed faults for each node separately if 'node_id' keys are defined.
...  When 'common' key is defined it means that contained faults are allowed on every node.
...  When 'node_id' key is defined it means that contained faults are allowed only on particular node.
...  Prepare 'CUSTOM_ADDITIONAL_ALLOWED_FAULTS' dictionary as shown in pattern:
...
...  \@{additional_common_fault_list}   faultId=xxx
...  ...                                faultId=xxx, configObjectName=xxx
...  ...                                faultId=xxx, severity=Critical
...
...  \@{additional_<node_id>_fault_list}   faultId=xxx
...  ...                                   faultId=xxx, configObjectName=xxx
...  ...                                   faultId=xxx, severity=Critical
...
...  \&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  common=\@{additional_common_fault_list}  node_id=\@{additional_<node_id>_fault_list}
...
...  Example of GLOBAL_ALLOWED_FAULTS dictionary:
...
...  {"common": ["faultId=1806", "faultId=10, severity=Critical"],
...   "1411": ["faultId=4003, configObjectName=regex'.*?RMOD'", "faultId=4655, alarmId=7220", "faultId=49"]}

Library           OperatingSystem
Library           Collections
Library           String
Library           taf.sbts.oam.coam.admin  WITH NAME  admin
Library           taf.ul.alarms_watchdog.interface.alarms_watchdog                     WITH NAME    awd
Library           taf.rfrl.common_resources.python.ims2_alarms.IMS2AlarmVerifier       WITH NAME    iav

*** Keywords ***
FM Await For Fault
    [Arguments]  ${fault_attr}  ${node_id}  ${alarm_resource}  ${timeout}=30
    [Documentation]  Purpose is to verify if desired fault appeard in active faults list. Mandatory is to define always unique expected fault.
    ...  Never define common fault pattern like: "Await For Alarm  faultId=10", this will lead to fault leakage and inconsistance detection.
    ...  When defining "fault_attr" please refer to KW "Assert" in taf.sbts.oam.coam.admin
    ...  KW also checks if alarm attributes (alarmId and alarmName) are found in variable "alarm_resource".
    ...  "alarm_resource" list contains possible <alarmId alarmName> values based on Faults NIDD documentation
    ...  example of alarm_resource for fault 6450: ['7115 BASE STATION INFORMATION', '7652 BASE STATION NOTIFICATION']
    ...  NOTE. - 'fault_attr' can contain regexp values
    ...        - if value of key in 'fault_attr' have space need to use ""   e.g. faultName="SoC autonomous reset as recovery action"
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | fault_attr         | Yes   | Attribute for expected fault, ex. faultId=49, alarmAttribute[0].attributeValue=LTE:35413      |
    ...    |                    |       | regex example. faultId=regexp"^49$", alarmAttribute[0].attributeValue=regexp"LTE:\\d+"        |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | node_id            | Yes   | node_id used as alias                                                                         |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | alarm_resource     | Yes   | list contains possible <alarmId alarmName> values based on Faults NIDD documentation          |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | timeout            | No    | time to wait for fault active                                                                 |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+
    ...    | Return Value       | Description                                                                                           |
    ...    +====================+=======================================================================================================+
    ...    | unique_attr        | Unique attribute for expected fault for further usage with added timestamp                            |
    ...    +--------------------+-------------------------------------------------------------------------------------------------------+

    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...  message=Waiting for fault with attributes: ${fault_attr}
    ...  logs_dir=${CFG.suite_logs_path}
    ${fault_status}  ${faults_list}=  Run Keyword And Ignore Error  admin.Assert Alarm Active
    ...  parameters=${fault_attr}
    ...  timeout=${timeout}
    ...  connection=${node_id}
    Run Keyword If  "${fault_status}"=="FAIL"  Run Keywords  Logging With Timestamp
    ...  message=Expected fault with attributes: ${fault_attr} not found within ${timeout}s, test failed
    ...  logs_dir=${CFG.suite_logs_path}
    ...  style=FAIL
    ...  AND
    ...  Fail  Expected fault with attributes: ${fault_attr} not found within ${timeout}s, test failed
    ${fault_attr_list}=  Split String  ${fault_attr}  ,${SPACE}
    FOR  ${fault_dict}  IN  @{faults_list}
      ${kw_status}=  _Find Fault  fault_attr_list=${fault_attr_list}  fault_dict=${fault_dict}
      Exit For Loop If  ${kw_status}
    END
    _Check Alarming Resource  ${alarm_resource}  ${fault_dict}
    ${fault_appear_time}=  Get From Dictionary  ${fault_dict}  btsObservationTime
    ${unique_attr}=  Catenate  ${FAULT_ATTR_TMP}  btsObservationTime=${fault_appear_time}
    ${unique_attr}=  Strip String  ${unique_attr}
    admin.Add Allowed Alarm  ${unique_attr}  connection=${node_id}
    Logging With Timestamp
    ...  message=Expected fault is active
    ...  logs_dir=${CFG.suite_logs_path}
    [Return]  ${unique_attr}

_Check Alarming Resource
    [Arguments]  ${alarm_resource}  ${fault_dict}
    [Documentation]  Helper KW for verify if alarming resources are as expected in NIDD

    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${admin_alarming_resource}=  Set Variable  ${fault_dict['alarmId']} ${fault_dict['alarmName']}
    ${alarm_status}=  Run Keyword And Ignore Error  List Should Contain Value  ${alarm_resource}  ${admin_alarming_resource}
    ${allowed_alarms}=  Evaluate  pprint.pformat(${alarm_resource}, indent=4)  modules=pprint
    Run Keyword If  "${alarm_status[0]}"=="PASS"  Logging With Timestamp
    ...  message="${admin_alarming_resource}" is as expected under fault ${fault_dict['faultId']}
    ...  logs_dir=${CFG.suite_logs_path}
    ...  ELSE  Run Keywords  Logging With Timestamp
    ...  message="${admin_alarming_resource}" differs from allowed NIDD values for fault ${fault_dict['faultId']}: ${\n}${allowed_alarms}
    ...  logs_dir=${CFG.suite_logs_path}
    ...  style=FAIL
    ...  AND  Fail  "${admin_alarming_resource}" differs from allowed NIDD values for fault ${fault_dict['faultId']}: ${\n}${allowed_alarms}

_Find Fault
    [Arguments]  ${fault_attr_list}  ${fault_dict}
    [Documentation]    Helper for finding faults
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${fault_attr_tmp}=  Set Variable  ${EMPTY}
    FOR  ${attr}  IN  @{fault_attr_list}
      ${attr_key}  ${attr_value}=  Split String  ${attr}  =  1
      ${match}=  Get Regexp Matches  ${attr_key}  ([^\\.].*?)(?=\\[|\\.|$)
      ${key}=  _Create Dictionary Key  ${match}
      ${is_regex}=  Run Keyword If  'regex' in '${attr_value}'
      ...  Set Variable  ${TRUE}
      ...  ELSE
      ...  Set Variable  ${FALSE}
      Run Keyword If  not ${is_regex}  Return From Keyword If  '${fault_dict${key}}' not in '${attr_value}'  ${FALSE}
      ${is_match}=  Run Keyword If  ${is_regex}  _Find Pattern
      ...  attr_value=${attr_value}
      ...  fault_dict=${fault_dict}
      ...  key=${key}
      Run Keyword If  ${is_regex}  Return From Keyword If  not ${is_match}  ${is_match}
      ${fault_attr_tmp}=  Catenate  ${fault_attr_tmp}  ${attr_key}="${fault_dict${key}}",
    END
    Set Test Variable  ${FAULT_ATTR_TMP}  ${fault_attr_tmp}
    Return From Keyword  ${TRUE}

_Find Pattern
    [Arguments]  ${attr_value}  ${fault_dict}  ${key}
    [Documentation]    Helper for finding faults
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${pattern}=  Split String  string=${attr_value}  separator="
    ${value}=  Convert To String  ${fault_dict${key}}
    ${match}=  Get Regexp Matches  string=${value}  pattern=${pattern[1]}
    ${is_match}=  Set Variable If  "${match}"=="[]"  ${FALSE}  ${TRUE}
    [Return]  ${is_match}

_Create Dictionary Key
    [Arguments]  ${match}
    ${key}=  Set Variable  ${EMPTY}
    FOR  ${element}  IN  @{match}
      ${key}=  Run Keyword If  '[' in '${element}'  Catenate  ${key}  ${element}  ELSE  Catenate  ${key}  ['${element}']
    END
    [Return]  ${key}

FM Await For Fault Cleared
    [Arguments]  ${fault_attr}  ${node_id}  ${timeout}=30
    [Documentation]  KW waits defined time for fault to be cleared.
    ...  Use 'unique_attr' from KW 'FM Await For Fault' as 'fault_attr'
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | fault_attr         | Yes   | Unique attribute for expected fault                                                           |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | node_id            | Yes   | node_id used as alias                                                                          |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | timeout            | No    | timeout for awaiting if fault cleared                                                         |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+

    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...  message=Waiting for clearing fault with attributes: ${fault_attr}
    ...  logs_dir=${CFG.suite_logs_path}
    ${fault_status}=  Run Keyword And Ignore Error  admin.Assert Alarm Inactive
    ...  parameters=${fault_attr}
    ...  timeout=${timeout}
    ...  connection=${node_id}
    Run Keyword If  "${fault_status[0]}"=="FAIL"  Run Keywords  Logging With Timestamp
    ...  message=Fault with attributes: ${fault_attr} not cleared after ${timeout}s, test failed
    ...  logs_dir=${CFG.suite_logs_path}
    ...  style=FAIL
    ...  AND
    ...  Fail  Fault with attributes: ${fault_attr} not cleared after ${timeout}s, test failed
    Logging With Timestamp
    ...  message=Expected fault is cleared
    ...  logs_dir=${CFG.suite_logs_path}

FM Check Unexpected And Historical Faults
    [Arguments]  ${node_id}  ${delay}=5
    [Documentation]  Checks Faults and prints unexpected.
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | node_id            | Yes   | BTS_ID used as alias                                                                          |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | delay              | No    | User can set delay time for BTS stabilization befor faults check                              |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+

    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...  message=Stabilizing BTS before faults check -> ${delay}s
    ...  logs_dir=${CFG.suite_logs_path}
    Sleep  ${delay}s  Waiting for BTS stabilize
    lmi.Start LMI Flow On Node  ${node_id}
    ${fault_unexpected_status}  ${msg_current}=  Run Keyword And Ignore Error  admin.Assert No Unexpected Active Alarms  connection=${node_id}
    ${pretty_active_faults}=  Evaluate  pprint.pformat("""${msg_current}""", indent=4)  modules=pprint
    Run Keyword If  "${fault_unexpected_status}"=="FAIL"  Run Keywords  Logging With Timestamp
    ...  message=${\n}List of unexpected faults detected:${\n}${pretty_active_faults}
    ...  logs_dir=${CFG.suite_logs_path}
    ...  style=FAIL
    ...  AND  Fail  Unexpected faults found, please check logs for details
    ...  ELSE  Logging With Timestamp
    ...  message=No unexpected faults detected
    ...  logs_dir=${CFG.suite_logs_path}
    ${historical_faults_status}  ${msg_history}=  Run Keyword And Ignore Error  admin.Assert No Unexpected Historical Alarms
    ...  connection=${node_id}
    ...  load_history=False
    ${pretty_active_faults}=  Evaluate  pprint.pformat("""${msg_history}""", indent=4)  modules=pprint
    Run Keyword If  "${historical_faults_status}"=="FAIL"  Run Keywords  Logging With Timestamp
    ...  message=List of unexpected historical faults detected:${\n}${pretty_active_faults}
    ...  logs_dir=${CFG.suite_logs_path}
    ...  style=FAIL
    ...  AND  Fail  Unexpected historical faults found, please check logs for details
    ...  ELSE  Logging With Timestamp
    ...  message=No unexpected historical faults detected
    ...  logs_dir=${CFG.suite_logs_path}

FM Add Global Faults To Allowed
    [Arguments]  ${node_id}  ${fault_dictionary}
    [Documentation]  KW adds provided faults to allowed. Dictionary with faults should be prepared as described in resource documentation
    ...    +---------------------------+-------+--------------------------------------------------------------------------------------------+
    ...    | Argument                  | Man.  | Description                                                                                |
    ...    +===========================+=======+============================================================================================+
    ...    | node_id                   | Yes   | node_id used as alias                                                                      |
    ...    +---------------------------+-------+--------------------------------------------------------------------------------------------+
    ...    | global_allowed_fault_dict | Yes   | dictionary with allowed faults                                                             |
    ...    +---------------------------+-------+--------------------------------------------------------------------------------------------+

    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${keys}=  Get Dictionary Keys    ${fault_dictionary}
    FOR  ${key}  IN  @{keys}
      Run Keyword If  "${key}"=="common"  _Add Fault  ${node_id}  ${fault_dictionary['${key}']}
      ...  ELSE IF    "${key}"=="${node_id}"  _Add Fault  ${node_id}  ${fault_dictionary['${key}']}
    END

FM Add Custom Global Faults To Allowed
    [Arguments]  ${node_id}
    [Documentation]  KW adds created in CUSTOM_ADDITIONAL_ALLOWED_FAULTS faults to allowed.
    ...  Dictionary with faults should be prepared as described in resource documentation
    ...  +------------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument               | Man.  | Description                                                                                   |
    ...  +========================+=======+===============================================================================================+
    ...  | node_id                | Yes   | node_id used as alias                                                                         |
    ...  +------------------------+-------+-----------------------------------------------------------------------------------------------+

    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${additional_fault_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}
    Return From Keyword If  ${additional_fault_exist}==${FALSE}
    FOR  ${key}  IN  @{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}
      Run Keyword If  "${key}"=="common"  _Add Fault  ${node_id}  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS['${key}']}
      ...  ELSE IF  "${key}"=="${node_id}"  _Add Fault  ${node_id}  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS['${key}']}
      Append To List    ${GLO_ADMIN_ALLOWED_ALARMS}    @{CUSTOM_ADDITIONAL_ALLOWED_FAULTS['${key}']}
    END
#    Append To List    ${GLO_ADMIN_ALLOWED_ALARMS}    @{CUSTOM_ADDITIONAL_ALLOWED_FAULTS['common']}
    ${GLO_ADMIN_ALLOWED_ALARMS}=  Remove Duplicates    ${GLO_ADMIN_ALLOWED_ALARMS}


_Add Fault
    [Documentation]  Helper KW for adding faults to allowed
    [Arguments]  ${node_id}  ${fault_patterns_list}
    FOR  ${pattern}  IN  @{fault_patterns_list}
      admin.Add Allowed Alarm  parameters=${pattern}  connection=${node_id}
    END

FM Add Global Faults To Allowed For All Nodes
    [Documentation]  KW adding global faults to allowed for all nodes
    [Arguments]    ${fault_dict}
    FOR  ${bts_id}  IN  @{CFG['active_bts_list']}
      FM Add Global Faults To Allowed  node_id=${bts_id}  fault_dictionary=${fault_dict}
    END
    Append To List    ${GLO_ADMIN_ALLOWED_ALARMS}    @{fault_dict['common']}
    ${GLO_ADMIN_ALLOWED_ALARMS}=  Remove Duplicates    ${GLO_ADMIN_ALLOWED_ALARMS}


FM Add Custom Global Faults To Allowed For All Nodes
    [Documentation]  KW adding custom user faults to allowed for all nodes
    FOR  ${bts_id}  IN  @{CFG['active_bts_list']}
      FM Add Custom Global Faults To Allowed  node_id=${bts_id}
    END

FM Check Unexpected And Historical Faults For All Nodes
    [Documentation]  KW for checking current and history faults for all nodes
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | delay                  | No   | timeout for stabilizing BTS before faults check                    |
    ...  +------------------------+------+--------------------------------------------------------------------+

    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    [Arguments]  ${delay}=5
    FOR  ${bts_id}  IN  @{CFG['active_bts_list']}
      FM Check Unexpected And Historical Faults  node_id=${bts_id}  delay=${delay}
    END

FM Clear Allowed Alarms For All Nodes
    [Documentation]  KW clears alowed faults list for all nodes
    ...  Author: piotr.korczynski@nokia.com
    ...  Maintainer: piotr.korczynski@nokia.com
    ${GLO_ADMIN_ALLOWED_ALARMS}=  Create List    @{EMPTY}
    Remove Environment Variable
    Set Test Variable    ${GLO_ADMIN_ALLOWED_ALARMS}
    FOR  ${bts_id}  IN  @{CFG['active_bts_list']}
      admin.Clear Allowed Alarms List    connection=${bts_id}
    END

FM Get Unique Fault Attributes
    [Arguments]  ${fault_attr}  ${faults_list}  ${cutoff_timestamp}=0
    [Documentation]  KW finds Fault by prvided attributes. Further KW gets contained btsObservationTime as a timestamp
    ...  to make fault unique dutng TC execution. User need to provide specific attributes to find desired fault.
    ...  KW returns string with unique attributes ready to use.
    ...  User can set custom time range for attribute search by using 'cutoff_timestamp'. When 'cutoff_timestamp' is set then all
    ...  faults before provided timestamp are ignored. Default value cutoff_timestamp=0 makes no time limits.
    ...  Helper KW for getting current timestamp from BTS is available in SSH resource.
    ...  If expected fault not found in "faults_list" empty string is returned.
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument           | Man.  | Description                                                                                   |
    ...  +====================+=======+===============================================================================================+
    ...  | fault_attr         | Yes   | Attributes for expected fault, ex. faultId=49, alarmAttribute[0].attributeValue=LTE:35413     |
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | faults_list        | Yes   | List of faults to serch unique attributes                                                     |
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | cutoff_timestamp   | No    | Used to search fault attributes from custom time range of 'faults_list'. Default value: 0     |
    ...  |                    |       | example value: 20240704142146 (date + time)                                                   |
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...  +--------------------+-------------------------------------------------------------------------------------------------------+
    ...  | Return Value       | Description                                                                                           |
    ...  +====================+=======================================================================================================+
    ...  | unique_attr        | Unique attribute for expected fault for further usage with added timestamp.                           |
    ...  +--------------------+-------------------------------------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${fault_attr_list}=  Split String  ${fault_attr}  ,${SPACE}
    FOR  ${fault_dict}  IN  @{faults_list}
      ${kw_status}=  _Find Fault  fault_attr_list=${fault_attr_list}  fault_dict=${fault_dict}
      ${observation_time}=  Evaluate  int('${fault_dict['btsObservationTime']}'.split('.')[0])
      Exit For Loop If  ${kw_status} and ${cutoff_timestamp}<${observation_time}
    END
    Return From Keyword If  not (${kw_status} and ${cutoff_timestamp}<${observation_time})  ${EMPTY}
    ${fault_appear_time}=  Get From Dictionary  ${fault_dict}  btsObservationTime
    ${unique_attr}=  Set Variable  ${fault_attr}, btsObservationTime=${fault_appear_time}
    [Return]  ${unique_attr}

FM Check Unexpected Active Faults For All Nodes
    FOR  ${bts_id}  IN  @{CFG['active_bts_list']}
      FM Check Unexpected Active Faults  node_id=${bts_id}
    END

FM Check Unexpected Active Faults
    [Arguments]  ${node_id}
    [Documentation]  Checks active Faults and prints unexpected.
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | node_id            | Yes   | BTS_ID used as alias                                                                          |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Logging With Timestamp
    ...  message=Active faults check started
    ${fault_unexpected_status}  ${msg_current}=  Run Keyword And Ignore Error  admin.Assert No Unexpected Active Alarms  connection=${node_id}
    ${pretty_active_faults}=  Evaluate  pprint.pformat("""${msg_current}""", indent=4)  modules=pprint
    Run Keyword If  "${fault_unexpected_status}"=="FAIL"  Run Keywords  Logging With Timestamp
    ...  message=${\n}List of unexpected faults detected:${\n}${pretty_active_faults}
    ...  style=FAIL
    ...  AND  Fail  Unexpected active faults found, please check logs for details
    ...  ELSE  Logging With Timestamp
    ...  message=No unexpected active faults detected
    ...  style=DONE

FM Check Unexpected History Faults For All Nodes
    FOR  ${bts_id}  IN  @{CFG['active_bts_list']}
      FM Check Unexpected History Faults  node_id=${bts_id}
    END

FM Check Unexpected History Faults
    [Arguments]  ${node_id}
    [Documentation]  Checks History Faults and prints unexpected.
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | node_id            | Yes   | BTS_ID used as alias                                                                          |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Logging With Timestamp
    ...  message=Historical faults check started
    ${historical_faults_status}  ${msg_history}=  Run Keyword And Ignore Error  admin.Assert No Unexpected Historical Alarms
    ...  connection=${node_id}
    ...  load_history=False
    ${pretty_active_faults}=  Evaluate  pprint.pformat("""${msg_history}""", indent=4)  modules=pprint
    Run Keyword If  "${historical_faults_status}"=="FAIL"  Run Keywords  Logging With Timestamp
    ...  message=List of unexpected historical faults detected:${\n}${pretty_active_faults}
    ...  style=FAIL
    ...  AND  Fail  Unexpected historical faults found, please check logs for details
    ...  ELSE  Logging With Timestamp
    ...  message=No unexpected historical faults detected
    ...  style=DONE

FM Find History Fault And Add To Allowed
    [Arguments]  ${history_fault_list}  ${timeslot_start}  ${bts_id}  ${should_fail}=${FALSE}
    [Documentation]  Purpose is to find faults from 'history_fault_list' and add it to allowed with datastamp.
    ...  KW can be used when TC scenario expects several faults check at the same time with short cancellation timeout
    ...  or user waits for some action finished and simultanous quick fault appears or on multtinode configs.
    ...  'history_fault_list' contains fault attributes (can be regexp), last attribute is always bts_ids where fault should appear.
    ...  'history_fault_list' can contain several faults defined.
    ...  'timeslot_start' argument should contain timeslot (start time) from when desired fault appears.
    ...  For gathering start time use KW 'SSH Get BTS timestamp'.
    ...
    ...  +----------------------------+-------+---------------------------------------------------------------------------------------+
    ...  | Argument                   | Man.  | Description                                                                           |
    ...  +============================+=======+=======================================================================================+
    ...  | history_fault_list         | Yes   | Expected fault attributes (can be regexp)                                             |
    ...  |                            |       | ex. faultId=49, alarmAttribute[0].attributeValue=LTE:35413, 1315_1022_1509            |
    ...  |                            |       | Note. Last attribute is always bts_ids where fault should appear                      |
    ...  +----------------------------+-------+---------------------------------------------------------------------------------------+
    ...  | bts_id                     | Yes   | bts_id used as alias                                                                  |
    ...  +----------------------------+-------+---------------------------------------------------------------------------------------+
    ...  | timeslot_start             | Yes   | Arg should contain timeslot (start time) from when desired fault can appear.          |
    ...  |                            |       | Format is '20241202103154'                                                            |
    ...  +----------------------------+-------+---------------------------------------------------------------------------------------+
    ...  | should_fail                | No    | Set if you wish to fail when expected fault not found in history time slot            |
    ...  +----------------------------+-------+---------------------------------------------------------------------------------------+
    ...
    ...  example of history_fault_list
    ...  ['faultId=49, severity=Minor, 1509', 'faultId=4468, severity=regexp"(?i)Minor", 1312_1500_1555']
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...  message=Finding impacting faults in history on ${bts_id} and adding to allowed with additional timestamp
    ${exp_history_faults_on_current_bts}=  Get Matches  list=${history_fault_list}  pattern=regexp=.* ${bts_id}.*|.*_${bts_id}.*
    Return From Keyword If  not len(${exp_history_faults_on_current_bts})
    ${fault_history_list}=  admin.Get Historic Alarms  connection=${bts_id}
    FOR  ${exp_fault}  IN  @{exp_history_faults_on_current_bts}
      ${exp_fault}=  Remove String Using Regexp  ${exp_fault}  , ${bts_id}.*|, \\d+.*_${bts_id}.*
      ${exp_fault_attr_list}=  Split String  ${exp_fault}  ,${SPACE}
      FOR  ${fault_dict}  IN  @{fault_history_list}
        ${fault_found}=  _Find Fault  fault_attr_list=${exp_fault_attr_list}  fault_dict=${fault_dict}
        ${fault_time}=  Split String  string=${fault_dict['btsObservationTime']}  separator=.
        ${correct_timeslot}=  Set Variable If
        ...  ${fault_found} and ${timeslot_start}<${fault_time[0]}
        ...  ${TRUE}
        ...  ${FALSE}
        Exit For Loop If  ${fault_found} and ${correct_timeslot}
      END
      Run Keyword If  ${should_fail}  Run Keyword If  not (${fault_found} and ${correct_timeslot})  Run Keywords
      ...  Logging With Timestamp
      ...  message=${exp_fault_attr_list} was not found on BTS-${bts_id} in timeslot after ${timeslot_start}
      ...  style=FAIL
      ...  AND
      ...  Fail  ${exp_fault_attr_list} was not found on BTS-${bts_id} in timeslot after ${timeslot_start}
      Continue For Loop If  not (${fault_found} and ${correct_timeslot})
      ${fault_appear_time}=  Get From Dictionary  ${fault_dict}  btsObservationTime
      ${history_unique_attr}=  Catenate  ${FAULT_ATTR_TMP}  btsObservationTime=${fault_appear_time}
      ${history_unique_attr}=  Strip String  ${history_unique_attr}
      admin.Add Allowed Alarm  ${history_unique_attr}  connection=${bts_id}
      Logging With Timestamp
      ...  message=Expected fault ${history_unique_attr} added to allowed
    END

FM Preconditions For CNI-127210
    [Documentation]
    ...  KW checks if SW build has proper release and package number according to CNI-127210.
    ...  KW checks value parameter act_category_alarms in SCF.
    ...  KW sets as a result global variable 'PRECOND_FOR_CNI' for further usage.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    Set Test Variable    ${bts_id}    ${CFG['primary_node_bts_id']}
    admin.Get Current Scf File  local_dir_path=${CFG['test_logs_path']}/  file_name=scf_alias_${bts_id}.xml  timeout=30  connection=${bts_id}
    ${parameter}  Evaluate Xpath  ${CFG['test_logs_path']}/scf_alias_${bts_id}.xml
    ...  string(.//managedObject[contains(@distName, "FMCADM")]/p[@name="actCategoryAlarms"])
    Remove File  ${cfg.test_logs_path}//scf_alias_${bts_id}.xml
    ${release}  admin.Get Sw Release Name  connection=${bts_id}
    ${proper_sw}  IF  "${release}"=="SBTS24R3"
    ...  SITE Check If 24R3 Build Is Proper For CNI-127210  SBTS24R3_ENB_0000_000241_000000  alias=${bts_id}
    ...  ELSE  SWM Check If Current SW Build Is Newer Than  SBTS25R1_ENB_9999_240926_000004  bts_id=${bts_id}
    ${act_category_alarms}  Set Variable If  "${parameter}"=="true" or "${parameter}"==""  True  False
    ${precond_for_cni}  Set Variable If  ${proper_sw} and ${act_category_alarms}  True  False
    Set Test Variable  ${PRECOND_FOR_CNI}

FM Set Start Timestamp In IMS For RD Fault
    [Arguments]  ${find_rd_fault}=${PRECOND_FOR_CNI}
    [Documentation]
    ...  KW Set Start Timestamp In IMS. KW Prepared for checking ALARMS/FAULT_NOTIF object in FRI when R&D fault
    ...  need to be verified. KW introduced after CNI-127210 implementation. Variable 'PRECOND_FOR_CNI' is created in
    ...  KW 'FM Preconditions For CNI-127210'. When using this keyword as standalone then 'find_rd_fault' should be ${TRUE}/${FALSE}
    ...  KW moved from robotlte_legacy: "Set Start Timestamp In IMS For CNI-127210
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    IF  ${find_rd_fault}  iav.Set Start Timestamp

FM Check Active Fault In IMS For RD Fault
    [Arguments]  ${bts_id}  ${fault_id}  ${severity}  ${find_rd_fault}=${PRECOND_FOR_CNI}
    [Documentation]
    ...  KW checks if fault is active in IMS. KW Prepared for checking ALARMS/FAULT_NOTIF object in FRI when R&D fault
    ...  need to be verified. KW introduced after CNI-127210 implementation. Variable 'PRECOND_FOR_CNI' is created in
    ...  KW 'FM Preconditions For CNI-127210'. When using this keyword as standalone then 'find_rd_fault' should be ${TRUE}/${FALSE}
    ...  KW moved from robotlte_legacy: "Check Active Fault In IMS For CNI-127210"
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | bts id                                                             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | fault_id               | Yes  | fault id                                                           |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | severity               | Yes  | if not aplicable use ${NONE}                                       |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | find_rd_fault          | No   | True/False if kw used as standalone                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    IF  ${find_rd_fault}  iav.Set End Timestamp
    ${wanted_alarm}  IF  ${find_rd_fault}
    ...  awd.create_alarm  fault_id=${fault_id}  severity=${severity}
    IF  ${find_rd_fault}  admin.Collect Im Snapshot
    ...  target_file_name=${CFG['test_logs_path']}/IMS_1.ims2
    ...  connection=${bts_id}
    ${alarm_dist_name}  IF  ${find_rd_fault}  Run Keyword And Continue On Failure
    ...  iav.Verify Alarm Was Set
    ...  alarm=${wanted_alarm}
    ...  ims_file_path=${CFG['test_logs_path']}/IMS_1.ims2
    ...  include_fault_notif=${TRUE}
    IF  ${find_rd_fault}  Remove File  ${CFG['test_logs_path']}/IMS_1.ims2
    IF  ${find_rd_fault}  Set Test Variable  ${ALARM_DISTNAME}  ${alarm_dist_name}

FM Check Removed Active Fault In IMS For RD Fault
    [Arguments]  ${bts_id}  ${find_rd_fault}=${PRECOND_FOR_CNI}
    [Documentation]
    ...  KW checks if active fault was removed in IMS. KW Prepared for checking ALARMS/FAULT_NOTIF object in FRI when R&D fault
    ...  need to be verified. KW introduced after CNI-127210 implementation. Variable 'PRECOND_FOR_CNI' is created in
    ...  KW 'FM Preconditions For CNI-127210'. When using this keyword as standalone then 'find_rd_fault' should be ${TRUE}/${FALSE}
    ...  KW moved from robotlte_legacy: "Check Removed Active Fault In IMS For CNI-127210"
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | bts id                                                             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | find_rd_fault          | No   | True/False if kw used as standalone                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    IF  ${find_rd_fault}  iav.Set End Timestamp
    IF  ${find_rd_fault}  admin.Collect Im Snapshot
    ...  target_file_name=${CFG['test_logs_path']}/IMS_2.ims2
    ...  connection=${bts_id}
    IF  ${find_rd_fault}  Run Keyword And Continue On Failure
    ...  iav.Verify Alarm Was Removed
    ...  alarm_dist_name=${ALARM_DISTNAME['dist_name']}
    ...  ims_file_path=${CFG['test_logs_path']}/IMS_2.ims2
    ...  include_fault_notif=${TRUE}
    IF  ${find_rd_fault}  Remove File  ${CFG['test_logs_path']}/IMS_2.ims2

FM Check for Alarm 4589
    [Arguments]  ${ru_bts_id}  ${ru_sn}  ${unexpected_historical_alarms_list}
    [Documentation]  The keyword will check if proper HW has the fault. The time of disapperances can differ in webem
    ...  in case of bigger configurations. Minimum time is 30 seconds.
    ...  Arguments:
    ...  +====================================+======+====================================================================+
    ...  | Argument                           | Man. | Description                                                        |
    ...  +====================================+======+====================================================================+
    ...  | ru_bts_id                          | Yes  | bts_id                                                             |
    ...  +------------------------------------+------+--------------------------------------------------------------------+
    ...  | ru_sn                              | Yes  | Serial number of RU                                                |
    ...  +------------------------------------+------+--------------------------------------------------------------------+
    ...  | unexpected_historical_alarms_list  | Yes  | historical faults list                                             |
    ...  +------------------------------------+------+--------------------------------------------------------------------+
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    FOR  ${alarm}  IN  @{unexpected_historical_alarms_list}
      ${hw_release_bool}=  Run Keyword And Return Status
      ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${ru_sn}']['scf_release_code']}').group(0)  re
      ${hw_release}=  IF  ${hw_release_bool}==True
      ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${ru_sn}']['scf_release_code']}').group(0)  re
      IF  ${hw_release_bool} == True and ${hw_release} < 5.1
        ${is_other}  Set Variable  ${cfg.RF_INFO['${ru_sn}']['scf_release_code']}
        IF  '${is_other}' == '5GRU5.0'
          Set Test Variable  ${hw_release_bool}  False
        END
      END
      IF  ${hw_release_bool}==True  Exit For Loop If  ${hw_release}<5.1
      ${hw_release_string}=  Set Variable If  ${hw_release_bool}==False  ${cfg.RF_INFO['${ru_sn}']['scf_release_code']}
      Continue For Loop If  '${hw_release_string}' in $FID4589_RELEASE_LESS_THAN_5_1_STRING_LIST
      IF  ${hw_release_bool}==False and '${hw_release_string}' not in $FID4589_RELEASE_STRING_LIST
        Logging With Timestamp
        ...  message=Check HW release code if not implemented in KW or synchronization (check if time skip exists in IMS when fault 4589 is active).
        ...  style=FAIL
        Run Keyword And Continue On Failure  Fail
        ...  Check HW release code if not implemented in KW or synchronization (check if time skip exists in IMS when fault 4589 is active).
      END
      ${faultId}=  Get From Dictionary  dictionary=${alarm}  key=faultId
      Continue For Loop If  ${faultId}!=4589
      ${fid_4589_severity}=  Set Variable  False
      ${hw_correct}=  Set Variable  False
      Logging With Timestamp
      ...  message=FID4589: Checking severity
      ${severity}=  Get From Dictionary  dictionary=${alarm}  key=severity
      ${fid_4589_severity}=  IF  ${alarm['severity']}==Warning
      ...  Set Variable  ${True}
      ...  ELSE  Set Variable  ${False}
      Continue For Loop If  ${fid_4589_severity}==${False}
      ${hw_correct}=  IF  '${alarm['serialNo']}'=='${ru_sn}'
      ...  Set Variable  ${True}
      ...  ELSE  Set Variable  ${False}
      Continue For Loop If  ${hw_correct}==${False}
      ${disappear_alarm_time}=  Get From Dictionary  dictionary=${alarm}  key=disappearTime
      ${disappear_alarm_time_str}=  Convert To String  ${disappear_alarm_time}
      ${disappear_alarm_time_split}=  Get Substring  string=${disappear_alarm_time_str}  start=6  end= -3
      ${disappear_alarm_time_split_int}=  Convert To Integer  ${disappear_alarm_time_split}
      ${event_date_alarm}=  Get From Dictionary  dictionary=${alarm}  key=eventTime
      ${event_date_alarm_str}=  Convert To String  ${event_date_alarm}
      ${event_date_alarm_split}=  Get Substring  string=${event_date_alarm_str}  start=6  end= -3
      ${event_date_alarm_split_int}=  Convert To Integer  ${event_date_alarm_split}
      ${diff}=  Run Keyword And Continue On Failure
      ...  Evaluate  ${disappear_alarm_time_split_int} - ${event_date_alarm_split_int} <= ${FID_4589_DISAPPEAR_TIMEOUT}
      IF  ${fid_4589_severity}==True and ${hw_correct}==True and ${diff}==True
      ...  admin.Add Allowed Alarm  faultId=4589, distName=${alarm}[distName]  connection=${ru_bts_id}
    END

FM Check For Alarm 4589 On All Nodes
    [Arguments]  ${ru_sn}
    [Documentation]  Keyword checks fault 4589. Supports configs with rfsharing where 4589 appears on both btses after power off.
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_sn                  | Yes  | Serial number of RU                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${ru_bts_ids}=  Create List
    ...  ${CFG['RF_INFO']['${ru_sn}']['scf_btsid_primary']}
    ...  @{CFG['RF_INFO']['${ru_sn}']['scf_btsid_secondary']}
    FOR  ${ru_bts_id}  IN  @{ru_bts_ids}
       ${unexpected_historical_faults_list}=  admin.Get Unexpected Historical Alarms  connection=${ru_bts_id}
       Continue For Loop If  ${unexpected_historical_faults_list} is None
       FM Check for Alarm 4589
       ...  ru_bts_id=${ru_bts_id}
       ...  ru_sn=${ru_sn}
       ...  unexpected_historical_alarms_list=${unexpected_historical_faults_list}
    END

FM Check For Fault 1815
    [Arguments]  ${ru_bts_id}
    [Documentation]
    ...  Gets list of unexpected historical alarms from BTS.
    ...  If there is FID1815 on the list further reasoning is triggered.
    ...
    ...  |  **Author:**  dawid.bak@nokia.com
    ...  |  **Maintainer:**  dawid.bak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter  | Man. | Description  |
    ...  +==============+======+==================================================+
    ...  | ru_bts_id  | Yes  | BTS ID used for infomodel connection  |
    ...  +--------------+------+--------------------------------------------------+

    ${unexpected_historical_alarms_list}=  admin.Get Unexpected Historical Alarms  connection=${ru_bts_id}
    IF  $unexpected_historical_alarms_list is not None
    ...  FM Analyze Unexpected Historical Alarms  unexpected_historical_alarms_list=${unexpected_historical_alarms_list}
    ...  ru_bts_id=${ru_bts_id}

FM Analyze Unexpected Historical Alarms
    [Arguments]  ${unexpected_historical_alarms_list}  ${ru_bts_id}
    [Documentation]
    ...  Analyzes unexpected historical alarms list to determine based on FID if given alarm should undergo
    ...  further analysis and potentially become allowed occurence
    ...
    ...  |  **Author:**  dawid.bak@nokia.com
    ...  |  **Maintainer:**  dawid.bak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +-----------------------------------+------+--------------------------------------+
    ...  | Parameter  | Man. | Description  |
    ...  +===================================+======+======================================+
    ...  | unexpected_historical_alarms_list | Yes  | list of unexpected historical alarms |
    ...  +-----------------------------------+------+--------------------------------------+
    ...  | ru_bts_id  | Yes  | BTS ID used for infomodel connection |
    ...  +-----------------------------------+------+--------------------------------------+

    ${bts_info}=  admin.Get Bts Info  connection=${ru_bts_id}
    FOR  ${alarm}  IN  @{unexpected_historical_alarms_list}
      ${fid_1815_is_expected}=  Set Variable  ${TRUE}
      ${faultId}=  Get From Dictionary  dictionary=${alarm}
      ...  key=faultId
      ${fid_1815_is_expected}=  IF  ${faultId}!=1815
      ...  Set Variable  ${FALSE}
      ...  ELSE  FM Check If FID1815 Is Expected  alarm=${alarm}
      ...  ru_bts_id=${ru_bts_id}
      ...  bts_info=${bts_info}
      ...  fid_1815_is_expected=${fid_1815_is_expected}
      IF  ${fid_1815_is_expected} == ${TRUE}
      ...  admin.Add Allowed Alarm  distName=${alarm}[distName]  connection=${ru_bts_id}
    END

FM Check If FID1815 Is Expected
    [Arguments]  ${alarm}  ${ru_bts_id}  ${bts_info}  ${fid_1815_is_expected}
    [Documentation]
    ...  Analyzes given FID1815 entry from unexpected historical alarm list to determined if it should be
    ...  expected under given circumstances
    ...
    ...  |  **Author:**  dawid.bak@nokia.com
    ...  |  **Maintainer:**  dawid.bak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+------------------------------------------------------+
    ...  | Parameter  | Man. | Description  |
    ...  +======================+======+======================================================+
    ...  | alarm  | Yes  | single unexpected historical alarm list entry  |
    ...  +----------------------+------+------------------------------------------------------+
    ...  | ru_bts_id  | Yes  | BTS ID used for infomodel connection  |
    ...  +----------------------+------+------------------------------------------------------+
    ...  | bts_info  | Yes  | dictionary containing infomodel objects informations |
    ...  +----------------------+------+------------------------------------------------------+
    ...  | fid_1815_is_expected | Yes  | variable for storing analysis verdict  |
    ...  +----------------------+------+------------------------------------------------------+
    ...
    ...  **Return parameters**
    ...
    ...  +----------------------+-------------------------------------------+
    ...  | Parameter  | Description  |
    ...  +======================+===========================================+
    ...  | fid_1815_is_expected | variable for storing analysis verdict  |
    ...  +----------------------+-------------------------------------------+

    Logging With Timestamp
    ...  message=FID1815: Checking severity
    ${severity}=  Get From Dictionary  dictionary=${alarm}  key=severity
    ${fid_1815_is_expected}=  IF  $severity not in $FID1815_ALLOWED_SEVERITY_LIST
    ...  Set Variable  ${FALSE}
    ...  ELSE  Set Variable  ${fid_1815_is_expected}
    Logging With Timestamp
    ...  message=FID1815: Checking cablink protocol type
    ${notifier}=  Get From Dictionary  dictionary=${alarm}  key=notifier
    ${notifier}=  Fetch From Right  string=${notifier}  marker=]${SPACE}
    ${cables_info}=  Get From Dictionary  dictionary=${bts_info}  key=cables
    FOR  ${cable}  IN  @{cables_info}
      ${alarming_resource}=  Set Variable If  "${cable['id']['runtime']}" == "${notifier}"
      ...  ${cable['id']['internal']}
      Exit For Loop If  "${cable['id']['internal']}" == "${alarming_resource}"
    END
    ${cablink_parameters}=  admin.Get Parameters For  class_name=CABLINK
    ...  id_num=${alarming_resource}
    ...  alias=${ru_bts_id}
    ${fid_1815_is_expected}=  IF  '${cablink_parameters}[cablinkType]'!='CPRILink'
    ...  Set Variable  ${FALSE}
    ...  ELSE  Set Variable  ${fid_1815_is_expected}
    Logging With Timestamp
    ...  message=FID1815: Checking HW model
    ${first_endpoint_class_name}=  Fetch From Right  string=${cablink_parameters}[firstEndpointDN]  marker=/
    ${first_endpoint_class_name}=  Fetch From Left  string=${first_endpoint_class_name}  marker=_
    ${first_endpoint_parameters}=  admin.Get Parameters For  ${first_endpoint_class_name}
    ...  ${cablink_parameters}[firstEndpointDN]
    ...  connection=${ru_bts_id}
    ${fid_1815_is_expected}=  IF  $first_endpoint_parameters['productName'] not in $FID1815_ALLOWED_HW_LIST
    ...  Set Variable  ${FALSE}
    ...  ELSE  Set Variable  ${fid_1815_is_expected}
    ${second_endpoint_class_name}=  Fetch From Right  string=${cablink_parameters}[secondEndpointDN]  marker=/
    ${second_endpoint_class_name}=  Fetch From Left  string=${second_endpoint_class_name}  marker=_
    ${second_endpoint_parameters}=  admin.Get Parameters For  ${second_endpoint_class_name}
    ...  ${cablink_parameters}[secondEndpointDN]
    ...  alias=${ru_bts_id}
    ${fid_1815_is_expected}=  IF  $second_endpoint_parameters['productName'] not in $FID1815_ALLOWED_HW_LIST
    ...  Set Variable  ${FALSE}
    ...  ELSE  Set Variable  ${fid_1815_is_expected}
    Logging With Timestamp
    ...  message=FID1815: Checking expected linkbreak events
    ${observation_time_in_epoch}=  SITE Format Timestamp To Epoch  timestamp_to_format=${alarm}[btsObservationTime]
    @{affected_hw_list}=  Create List  ${cablink_parameters}[firstEndpointDN]
    ...  ${cablink_parameters}[secondEndpointDN]
    ${is_expected_linkbreak_event}=  Set Variable  ${FALSE}
    FOR  ${link_brake_event}  IN  @{EXPECTED_LINK_BREAK_LIST}
      ${event_in_timewindow}=  Evaluate
      ...  ${link_brake_event}[timestamp] <= ${observation_time_in_epoch} <= (${link_brake_event}[timestamp] + ${FID1815_TIMEOUT})
      ${event_HW_matches_expected}=  Run Keyword And Return Status
      ...  List Should Contain Value  ${affected_hw_list}
      ...  ${link_brake_event}[ru_dist_name]
      ${is_expected_linkbreak_event}=  Set Variable If  ${event_in_timewindow} and ${event_HW_matches_expected}  ${TRUE}
    END
    ${fid_1815_is_expected}=  Run Keyword If  ${is_expected_linkbreak_event} == ${FALSE}
    ...  Set Variable  ${FALSE}
    ...  ELSE  Set Variable  ${fid_1815_is_expected}
    [Return]  ${fid_1815_is_expected}

FM Check For Fault 1815 On All Nodes
    [Arguments]  ${ru_sn}
    [Documentation]  Keyword checks fault 1815. Supports configs with rfsharing where 1815 appears on both btses after power off.
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_sn                  | Yes  | Serial number of RU                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${ru_bts_ids}=  Create List
    ...  ${CFG['RF_INFO']['${ru_sn}']['scf_btsid_primary']}
    ...  @{CFG['RF_INFO']['${ru_sn}']['scf_btsid_secondary']}
    FOR  ${ru_bts_id}  IN  @{ru_bts_ids}
       FM Check For Fault 1815
       ...  ru_bts_id=${ru_bts_id}
    END

FM Check Mandatory Alarm Active List
    [Arguments]  ${prim_bts_id}  ${prim_fault_list}  ${timeout}  ${sec_bts_id}=${EMPTY}  ${sec_fault_list}=@{EMPTY}
    [Documentation]  Keyword is cooperating with "FM Check Mandatory Alarm InActive List", so don't use it as standalone KW.
    ...  Keyword checks if faults provided by user are active. Keyword supports rfsharing. Keyword creates
    ...  global arguments 'PRIMARY_UNIQUE_FAULT_LIST' and 'SECONDARY_UNIQUE_FAULT_LIST' for further usage.
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | prim_bts_id            | Yes  | Primary bts_id                                                     |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | prim_fault_list        | Yes  | list of faults attributes to verify on primary                     |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | timeout                | Yes  | timeout for operations                                             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | sec_bts_id             | No   | Secondary bts_id                                                   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | sec_fault_list         | No   | list of faults attributes to verify on secondary                   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${prim_unique_fault_list}=  Create List
    ${sec_unique_fault_list}=  Create List
    FOR  ${fault}  IN  @{prim_fault_list}
      ${id}=  Get Regexp Matches  ${fault}  faultId=(\\d+)  1
      ${output}=  Run Keyword And Ignore Error  FM Await For Fault
      ...  fault_attr=${fault}
      ...  node_id=${prim_bts_id}
      ...  alarm_resource=${FAULT_${id[0]}}
      ...  timeout=${timeout}
      Append To List  ${prim_unique_fault_list}  ${output[1]}
    END
    Set Test Variable  ${PRIMARY_UNIQUE_FAULT_LIST}  ${prim_unique_fault_list}
    FOR  ${fault}  IN  @{sec_fault_list}
      ${id}=  Get Regexp Matches  ${fault}  faultId=(\\d+)  1
      ${output}=  Run Keyword And Ignore Error  FM Await For Fault
      ...  fault_attr=${fault}
      ...  node_id=${sec_bts_id}
      ...  alarm_resource=${FAULT_${id[0]}}
      ...  timeout=${timeout}
      Append To List  ${sec_unique_fault_list}  ${output[1]}
    END
    Set Test Variable  ${SECONDARY_UNIQUE_FAULT_LIST}  ${sec_unique_fault_list}

FM Check Mandatory Alarm InActive List
    [Arguments]  ${prim_bts_id}  ${timeout}  ${sec_bts_id}=${EMPTY}
    [Documentation]  Keyword is cooperating with "FM Check Mandatory Alarm Active List", so don't use it as standalone KW.
    ...  Keyword checks if faults verified in "FM Check Mandatory Alarm Active List" are inactive. Keyword supports rfsharing.
    ...  Global arguments 'PRIMARY_UNIQUE_FAULT_LIST' and 'SECONDARY_UNIQUE_FAULT_LIST' should exist before keyword execution.
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | prim_bts_id            | Yes  | Primary bts_id                                                     |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | timeout                | Yes  | timeout for operations                                             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | sec_bts_id             | No   | Secondary bts_id - use it 'SECONDARY_UNIQUE_FAULT_LIST' exists     |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    FOR  ${fault}  IN  @{PRIMARY_UNIQUE_FAULT_LIST}
      Run Keyword And Continue On Failure  FM Await For Fault Cleared
      ...  fault_attr=${fault}
      ...  node_id=${prim_bts_id}
      ...  timeout=${timeout}
    END
    FOR  ${fault}  IN  @{SECONDARY_UNIQUE_FAULT_LIST}
      Run Keyword And Continue On Failure  FM Await For Fault Cleared
      ...  fault_attr=${fault}
      ...  node_id=${sec_bts_id}
      ...  timeout=${timeout}
    END

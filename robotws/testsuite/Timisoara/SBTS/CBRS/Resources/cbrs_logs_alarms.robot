*** Settings ***
Documentation  CBRS Library for handling BTS faults

Resource  cbrs_common_keywords.robot

Library  taf.ul.alarms_watchdog   WITH NAME    watchdog_RAT_1ST
Library  taf.ul.alarms_watchdog   WITH NAME    watchdog_RAT_2ND


## lista KW do usuniecia ##
#Add To Faults List - nieuzywany
#Add Allowed Alarm To List -  - nieuzywany
#No Alarm Except Allowed Should Appear On EnB - jest w użyciu - trzeba zastapic
#Check if alarm active - return true/false
*** Variables ***
@{CRITICAL_FAULTS}  10  1806  4341  4352  4383


*** Keywords ***
Start Watchdog Alarm Detection
    [Documentation]  Description:           Setup watchdog alarm, before calling this function make sure that 'Import Variables __init__.py' is ${\n}
    ...                                     present. After setup KW checks if no unwanted faults visible on BTS                                 ${\n}
    ...                                     For 2nd node additional variable needed in init:                                                   ${\n}
    ...                                     from taf.config.testline import RoutingInformation                                                  ${\n}
    ...                                     _enb_sbts_.oam_ip = NetworkAddress(v6="IPv6/mask", v4="IPv4/mask", vlan_id=vlan)                    ${\n}
    ...              Return:                None                                                                                                ${\n}
    ...              Output:                {}                                                                                                  ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com
    [Arguments]  ${alias}=RAT_1ST                      # Admin connection alias
    ...          ${expected_faults}=@{EMPTY}           # List of expected FID i.e 10, 6832, 2002
    ...          ${expected_alarms}=@{EMPTY}           # List of expected alarm objects
    ...          ${check_faults}=${True}               # enable/disable checking faults after setup
    ...          ${logs_dir}=${SUITE_LOGS_DIR_PATH}    # dir to logs folder

    @{ignored_faults}  Create List
    ${is_list}  Evaluate  isinstance(${expected_faults}, list)
    IF  ${is_list}
        @{expected_faults_list}  Set Variable  ${expected_faults}
    ELSE
        @{expected_faults_list}  Create List  ${expected_faults}
    END

    IF  ${expected_faults}!=@{EMPTY}
        @{ignored_faults}   Combine Lists  ${enb_allowed_faults}  ${expected_faults_list}
    ELSE
        @{ignored_faults}  Set Variable  ${enb_allowed_faults}
    END
    FOR  ${fault}  IN  @{ignored_faults}
        Run Keyword  watchdog_${alias}.allow alarm  fault_id=${fault}
    END

    ${cfg}  Set Variable If  '${alias}'=='RAT_1ST'  ${tl.enbs[0]}  ${tl.enbs[1]}
    Run Keyword  watchdog_${alias}.watch_alarms  interval=2  bts_config=${cfg}  log_dir=${logs_dir}/watchdog_${alias}/
    ...  allowed_alarms=${expected_alarms}

    IF  ${check_faults}  Run Keyword  watchdog_${alias}.check_detected_alarms


Stop Watchdog Alarm Detection And Check For Failures
    [Documentation]  Description:           Teardown for alarm watchdog - close connection and check if no unexpected faults visible on BTS.    ${\n}
    ...              Return:                None                                                                                                ${\n}
    ...              Output:                {}                                                                                                  ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                                                       ${\n}
    [Arguments]  ${alias}=RAT_1ST       # admin connection alias

    Run Keyword And Continue On Failure  watchdog_${alias}.check_detected_alarms

    [Teardown]  Run Keyword  watchdog_${alias}.stop_watching_alarms


Watchdog Check For Failures
    [Documentation]  Description:           Check if no unexpected faults visible on BTS,                                                       ${\n}
    ...                                     faults defined in 'Add Faults To Watchdog Ignored List' are skipped even if present.                ${\n}
    ...              Return:                None                                                                                                ${\n}
    ...              Output:                {}                                                                                                  ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                                                  ${\n}
    [Arguments]  ${alias}=RAT_1ST       # admin connection alias

    Run Keyword  watchdog_${alias}.check_detected_alarms


Add Fault To Watchdog Ignored List
    [Documentation]  Description:           Add faults to skip list when performing 'Watchdog Check For Failures'.                              ${\n}
    ...              Return:                None                                                                                                ${\n}
    ...              Output:                {}                                                                                                  ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                                                       ${\n}
    [Arguments]  ${alias}=RAT_1ST       # admin connection alias
    ...          ${alarm_id}=None       # alarm id e.g. =7653
    ...          ${fault_id}=None       # fault id e.g. =10
    ...          ${fault_name}=None     # fault name e.g. =SAS Server Communication Failure
    ...          ${severity}=None       # fault severity Critical, Major, Minor
    ...          ${reason}=None         # supplementary alarm information

    Run Keyword  watchdog_${alias}.allow alarm  alarm_id=${alarm_id}  fault_id=${fault_id}  fault_name=${fault_name}  severity=${severity}
    ...  reason=${reason}


Remove Fault From Watchdog Ignored List
    [Documentation]  Description:           Remove faults from skip list when performing 'Watchdog Check For Failures'.                         ${\n}
    ...              Return:                None                                                                                                ${\n}
    ...              Output:                {}                                                                                                  ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com
    [Arguments]  ${alias}=RAT_1ST       # admin connection alias
    ...          ${alarm_id}=None       # alarm id e.g. =7653
    ...          ${fault_id}=None       # fault id e.g. =10
    ...          ${fault_name}=None     # fault name e.g. =SAS Server Communication Failure
    ...          ${severity}=None       # fault severity Critical, Major, Minor
    ...          ${reason}=None         # supplementary alarm information

    Run Keyword  watchdog_${alias}.disallow alarm  alarm_id=${alarm_id}  fault_id=${fault_id}  fault_name=${fault_name}  severity=${severity}
    ...  reason=${reason}


Wait For Watchdog Alarm Activation
    [Documentation]  Description:           Wait ${timeout} [sec] for given alarm activation on BTS.                                            ${\n}
    ...              Return:                None                                                                                                ${\n}
    ...              Output:                {}                                                                                                  ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com
    [Arguments]  ${alias}=RAT_1ST       # admin connection alias
    ...          ${alarm_id}=None       # alarm id e.g. =7653
    ...          ${fault_id}=None       # fault id e.g. =10
    ...          ${fault_name}=None     # fault name e.g. =SAS Server Communication Failure
    ...          ${severity}=None       # fault severity Critical, Major, Minor
    ...          ${reason}=None         # supplementary alarm information
    ...          ${timeout}=30          # waiting time default 30 seconds

    Run Keyword  watchdog_${alias}.wait for active alarm  timeout=${timeout}  alarm_id=${alarm_id}  fault_id=${fault_id}  fault_name=${fault_name}
    ...  severity=${severity}  reason=${reason}


Wait For Watchdog Alarm Deactivation
        [Documentation]  Description:       Wait ${timeout} [sec] for given alarm de-activation on BTS.                                         ${\n}
    ...              Return:                None                                                                                                ${\n}
    ...              Output:                {}                                                                                                  ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com
    [Arguments]  ${alias}=RAT_1ST       # admin connection alias
    ...          ${alarm_id}=None       # alarm id e.g. =7653
    ...          ${fault_id}=None       # fault id e.g. =10
    ...          ${fault_name}=None     # fault name e.g. =SAS Server Communication Failure
    ...          ${severity}=None       # fault severity Critical, Major, Minor
    ...          ${reason}=None         # supplementary alarm information
    ...          ${timeout}=30          # waiting time default 30 seconds

    Run Keyword  watchdog_${alias}.wait for inactive alarm  timeout=${timeout}  alarm_id=${alarm_id}  fault_id=${fault_id}  fault_name=${fault_name}
    ...  severity=${severity}  reason=${reason}

Create Watchdog Alarm List
    [Documentation]  Description:           Create alarm object based on given arguments - kw usefull for creating expected alarms variable in  ${\n}
    ...                                     'Start Watchdog Alarm Detection'. To create new object you need to pass one or more arguments:      ${\n}
    ...                                     alarm_id, fault_id, fault_name, severity, reason converted into dictionary where keys are args names${\n}
    ...                                     and values are alarm values e.g. {fault_id:10, severity:Critical}. If you have more than one alarm  ${\n}
    ...                                     add their dictionaries into list and pass it as {alarm}.
    ...              Return:                List of watchdog alarm objects                                                                      ${\n}
    ...              Output:                { Alarm() }                                                                                         ${\n}
    ...              Author:                karol.sadowski@nokia.com                                                                            ${\n}
    [Arguments]  ${alarm}              # dictionary with arguments {alarm_id:val, fault_id:val, fault_name:val, severity:val, reason:val}
                                           # or list of dictionares created in the same way, minimum one argument is mandatory, rest optional

    ${is_dict}  Evaluate  isinstance(${alarm}, dict)
    IF  ${is_dict}
        ${alarm_list}  Create List  ${alarm}
    ELSE
        ${alarm_list}  Set Variable  ${alarm}
    END
    @{alarms_list}  Create List

    FOR  ${item}  IN  @{alarm_list}
        ${alarm_id}  Evaluate  ${item}.get("alarm_id", None)
        ${fault_id}  Evaluate  ${item}.get("fault_id", None)
        ${fault_name}  Evaluate  ${item}.get("fault_name", None)
        ${severity}  Evaluate  ${item}.get("severity", None)
        ${reason}  Evaluate  ${item}.get("reason", None)

        ${alarm_object}  watchdog_RAT_1ST.Create Alarm  alarm_id=${alarm_id}  fault_id=${fault_id}  fault_name=${fault_name}  severity=${severity}
        ...  reason=${reason}
        Append To List  ${alarms_list}  ${alarm_object}
    END

    RETURN  ${alarms_list}

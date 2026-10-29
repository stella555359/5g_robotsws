*** Settings ***
Documentation
...  maintainer:  Dawid Chuchnowski, dawid.chuchnowski@nokia.com
...  author:      Andrzej Pencak, andrzej.pencak@nokia.com
...  team:        KRK6

Library     OperatingSystem
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta5g_syslog
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ./resources/suite_specific_keywords.robot
Suite Setup    Suite Setup

*** Test Cases ***
CNI131004_14_Repetive_alarms_suppresion_setup_robustness_scenario
    [Documentation]    Test verifies SMOD and BBMODs internal temperature RD counters
    [Setup]  Common Preconditions
    Set alarm suppression flag    value=disabled
    Decrease cooling fan speed
    Wait until keyword succeeds  7 min   30s   Check fault 4079 is reported
    Set alarm suppression flag    value=suppressAlarms
    Sleep    10s   reason=Time for fault 4079 to disappear
    Check fault 4079 is not reported
    Repeat alarm suppression and allowance 5 times
    [Teardown]    Test teardown

*** Keywords ***
Change Parameter On DU
    [Arguments]    ${value}  ${internal_dist_name}  ${name}  ${operation}=update
    [Documentation]     This keyword change selected parameter on gNB
    ...     :param value: value for parameter which will be set
    ...     :param internal_dist_name: distinguisive name for parameter which will be change
    ...     :param parameter name: name of parameter which will be change
    ...     :param operation: type of operation, "update" by default
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=${internal_dist_name}
    ...  param_name=${name}  param_value=${value}  skip_parameter_relation_errors=true  operation=${operation}
    ...  timeout=300
    Wait Until Keyword Succeeds    7min    10s    gnb_cells.Verify All Cells Are OnAir

Set alarm suppression flag
    [Arguments]    ${value}
    [Documentation]     This keyword sets alarm suppression flag to requested value
    ...     :param value:  flag value, disabled/suppressAlarms

    Change Parameter On DU
    ...    name=actAlarmsSuppression
    ...    value=${value}
    ...    internal_dist_name=MRBTS-77122/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1

Add fault 4079 to suppression list
    [Documentation]     This keyword sets alarm suppression flag to requested value
    &{suppr_list}=    Create Dictionary
    ...    faultId=4079
    ...    alarmSeverity=MINOR_AND_WARNING
    &{suppr_list_2}=    Create Dictionary
    ...    parameterName=suppressedFaultList
    ...    operation=create
    ...    value=&{suppr_list}
    Change Parameter On DU
    ...    name=suppressedFaultList
    ...    operation=create
    ...    value=&{suppr_list}
    ...    internal_dist_name=MRBTS-77122/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1

Deconfigure thermal state monitoring counter parameter
    [Arguments]    ${parameter}
    [Documentation]     This keyword deconfigures CB008967 counter activation parameters
    ...     :param parameter: one of CB008967 Thermal state monitoring counters' parameter
    Change Parameter On DU
    ...    name=${parameter}
    ...    internal_dist_name=MRBTS-77122/MNL-1/MNLENT-1/PMMNL-1
    ...    value=disabled
    ...    operation=update


Repeat alarm suppression and allowance 5 times
    logger.Log Info to Console  Repeat alarm suppression and allowance 5 times
    FOR    ${i}    IN RANGE    5
        logger.Log Info to Console    ${i+1} iteration - Set alarm suppression flag to disabled
        Set alarm suppression flag    value=disabled
        Sleep    10s   reason=Time for fault 4079 to reoccur
        Check fault 4079 is reported
        logger.Log Info to Console    Set alarm suppression flag to suppressAlarms
        Set alarm suppression flag    value=suppressAlarms
        Sleep    10s   reason=Time for fault 4079 to disappear
        Check fault 4079 is not reported
    END

Test teardown
    logger.Log Banner to console  Test teardown started
    Restore normal cooling fan speed
    logger.Log Info to console  Common Postconditions
    Common Postconditions
    logger.Log Banner to console  Test teardown finished

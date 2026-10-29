*** Settings ***
Documentation
...  maintainer:  Dawid Chuchnowski, dawid.chuchnowski@nokia.com
...  authors:  Andrzej Pencak, andrzej.pencak@nokia.com
...            Dawid Chuchnowski, dawid.chuchnowski@nokia.com
...  team:        KRK6

Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta5g_syslog
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    Alarms
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   taf/rfrl/bts/alarms/classical_alarms_definition.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ./resources/suite_specific_keywords.robot


Suite Setup    Suite Setup

*** Test Cases ***
CNI131003-A_7_Robustness_scenario_with_online_FAF_change_from_false_to_true
    [Documentation]    Test verifies visibility of fault 4079 under online change of actDUFanFailureEarlyNotif
    [Setup]  Run keywords
    ...    Common Preconditions
    ...    AND    Set actDUFanFailureEarlyNotif    value=false
    ...    AND    Set alarm suppression flag    value=disabled
    Decrease cooling fan speed
    Sleep     240s    reason=Wait for triggering time period for FID4079
    Alarms.Verify Alarm Is Not Active     &{CLASSICAL_FAULT_4079}
    Set actDUFanFailureEarlyNotif    value=true
    Sleep     240s    reason=Wait for triggering time period for FID4079
    Alarms.Verify Alarm Is Active     &{CLASSICAL_FAULT_4079}
    [Teardown]    Run keywords
    ...    Restore cooling fan speed
    ...    AND    Common Postconditions

Robustness_EDA_scenario_with_fans_stopped_after_startup
    [Documentation]    The test case adds simulated fan speed fluctuations during startup procedure after site reset.
    ...                Main FID under test 4078: EFaultId_FanBrokenA. This is EDA action task for 05097273
    ...                https://jiradc.ext.net.nokia.com/browse/RDI-32478
    [Setup]    Run keywords
    ...    Common preconditions
    ...    AND    Set actDUFanFailureEarlyNotif    value=true
    ...    AND    Set alarm suppression flag    value=disabled
    Perform site reset in the background
    Wait until connection to BTS is restored
    Decrease cooling fan speed to zero
    Wait Until Keyword Succeeds    5min    20s
     ...    Alarms.Verify Alarm Is Active     &{CLASSICAL_FAULT_4078}
    Check if background process finished
    Restore cooling fan speed
    Wait Until Keyword Succeeds    5min    20s
    ...    Alarms.Verify Alarm Is Not Active     &{CLASSICAL_FAULT_4078}
    [Teardown]   Run keywords
    ...    Set actDUFanFailureEarlyNotif    value=false
    ...    AND    Common postconditions

Robustness_EDA_scenario_with_fans_speed_fluctuation_after_startup
    [Documentation]    The test case adds simulated fan speed fluctuations during startup procedure after site reset.
    ...                Main FID under test Fault 4079: Cooling fan speed decreased. This is EDA action task for 05097273
    ...                https://jiradc.ext.net.nokia.com/browse/RDI-32477
    [Setup]    Run keywords
    ...    Common preconditions
    ...    AND    Set actDUFanFailureEarlyNotif    value=true
    ...    AND    Set alarm suppression flag    value=disabled
    Perform site reset in the background
    Wait until connection to BTS is restored
    Decrease cooling fan speed
    Wait Until Keyword Succeeds    5min    20s
    ...    Alarms.Verify Alarm Is Active     &{CLASSICAL_FAULT_4079}
    Check if background process finished
    Restore cooling fan speed
    Wait Until Keyword Succeeds    5min    20s
    ...    Alarms.Verify Alarm Is Not Active     &{CLASSICAL_FAULT_4079}
    [Teardown]   Run keywords
    ...    Set actDUFanFailureEarlyNotif    value=false
    ...    AND    Common postconditions

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
    ...    internal_dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1

Set actDUFanFailureEarlyNotif
    [Arguments]    ${value}
    [Documentation]     This keyword sets alarm actDUFanFailureEarlyNotif flag to requested value
    ...     :param value:  flag value, true/false

    Change Parameter On DU
    ...    name=actDUFanFailureEarlyNotif
    ...    value=${value}
    ...    internal_dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1



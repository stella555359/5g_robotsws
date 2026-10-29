*** Settings ***
Documentation
...    author: Li Ying
...    contact: ying.15.li@nokia-sbell.com
...    Description: This scenario addresses fault and alarm reporting when cell can provide only SA or only NSA service
...   basing on link status for SA+NSA cell.

Suite Setup    CB007582.Common Suite Setup
Suite Teardown    CB007582.Common Suite Teardown

Resource          ./Resources/CB007582_Common_Keywords_Classical.robot

Test Timeout      12 hour



*** Test Cases ***
[1]CB007582-C_1_Fault_and_alarm_reporting_for_SA+NSA_type_basing_on_link_status
    [Tags]    HAZ3_T03
    [Setup]    CB007582.Case Setup
    Configure ngInducedCellDeactDelayTimer to 10
    Perform NG link update   value=Locked
    Perform NG-U link update   value=Locked
    Check Fault and cell State    severity=major    operational=enabled    availability=degraded    cell_idx=${1}
    Perform NG-U link update   value=Unlocked
    Perform NG link update    value=Unlocked
    wait until keyword succeeds    3min    1min    Check fault clear
	Perform X2 link update   value=locked
	Check Fault and cell State    severity=major    operational=enabled    availability=degraded    cell_idx=${1}
	Perform X2 link update   value=unlocked
	wait until keyword succeeds    5min    1min    Check fault clear
    ${weekday}    Get Current Date    result_format=%A
    Run Keyword If   "${weekday}"=="Friday"      Fail    Today is ${weekday} and fail this case

    [Teardown]    CB007582.case teardown    cell_idx=1

[1]CB007582-C_5_alarm_severity_change for_link_status_based_cell_activation_for_SA+NSA_type_cell
    [Setup]    CB007582.Case Setup
    [Tags]    HAZ3_T03
    Configure ngInducedCellDeactDelayTimer to 10
    Perform NG link update   value=Locked
    Check Fault and cell State    severity=major    operational=enabled    availability=degraded    cell_idx=${1}
	Perform X2 link update   value=locked
	Check Fault and cell State    severity=critical    operational=disabled    availability=failed    cell_idx=${1}
	Perform X2 link update   value=unlocked
	Perform NG link update    value=Unlocked
    wait until keyword succeeds    3min    10s    Check fault clear
    Check No Other Fault Raise
    [Teardown]    CB007582.case teardown    cell_idx=1


[1]CB007582-D_4_Cell_activation_for_SA+NSA_mixed_type_cell_with_unavailable_Ng_link_after_available_X2_link
    [Setup]    CB007582.Case Setup
    [Tags]    HAZ3_T03
    Configure nsaCellActivationAlarmTimer to 60
    Configure saCellActivationAlarmTimer to 60
    lock cell    cell_idx=${1}
    sleep    2min
    Check cell state    operational=disabled    availability=off line    cell_idx=${1}
	Perform NG link update   value=Locked
	Check No Other Fault Raise
	unlock cell    cell_idx=${1}
	sleep    100s
	wait until keyword succeeds    1min    10s    Check Fault and cell State    severity=major
	...     operational=enabled    availability=degraded    cell_idx=${1}
	Perform NG link update    value=Unlocked
    [Teardown]    CB007582.case teardown    cell_idx=1



[1]CB007582-D_6_Cell_activation_for_SA+NSA_mixed_type_cell_with_unavailable_Ng_link_before_available_X2
    [Setup]    CB007582.Case Setup
    [Tags]    HAZ3_T03
    Configure nsaCellActivationAlarmTimer to 50
    Configure saCellActivationAlarmTimer to 360
    lock cell    cell_idx=${1}
    sleep    2min
    Check cell state    operational=disabled    availability=off line    cell_idx=${1}
	Perform NG link update   value=Locked
	Perform X2 link update   value=locked
	Check No Other Fault Raise
	unlock cell    cell_idx=${1}
	wait until keyword succeeds    6min    1min    Check Fault and cell State    severity=major
    ...     operational=disabled    availability=off line    cell_idx=${1}
    wait until keyword succeeds    6min    1min    Check Fault and cell State    severity=critical
    ...     operational=disabled    availability=failed    cell_idx=${1}
    Perform X2 link update   value=unlocked
	Perform NG link update    value=Unlocked
    TL926.CB007582_IWK_with_energySaving_loop
    [Teardown]    CB007582.case teardown    cell_idx=1

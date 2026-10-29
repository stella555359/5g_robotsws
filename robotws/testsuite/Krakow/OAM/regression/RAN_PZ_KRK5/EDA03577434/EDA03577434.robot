*** Settings ***
Documentation
...   author: Jakub Bialon,
...   contact: jakub.bialon@nokia.com
...   EDA03577434

Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library   ./resources/keywords.py

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup   Common Suite Setup With OnAir Test Line Preparation
...           should_LTE_neighbour_be_changed=${False}
...           should_5G_neighbour_be_changed=${False}
...           increase_time_for_checking_bbmod=600
...           increase_timeout_for_update_sw=1800
...           increase_time_for_checking_radios=2100
...           increase_time_for_checking_cells=700
...           increase_time_for_checking_X2link=1800
...           swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown   Common Suite Teardown

Test Setup   Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
@{additional_allowed_alarms}=    Create List    Critical alarm for SMOD object

*** Test Cases ***
Multiple_Site_Resets_while_critical_alarm_on_SMOD
    Change Alarm Trigger Flag   value=true
    Check Critical Alarm   faul_id=${1410}   fault_name=Critical alarm for SMOD object
    Perform Multiple Rest And Check Critical Alarm   amount=${4}
    ...                                              faul_id=${1410}
    ...                                              fault_name=Critical alarm for SMOD object
    Change Alarm Trigger Flag   value=false
    Run Keyword And Expect Error   There is no "Critical alarm for SMOD object" alarm
    ...   Check Critical Alarm   faul_id=${1410}   fault_name=Critical alarm for SMOD object

    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report

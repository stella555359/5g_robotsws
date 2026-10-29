*** Settings ***
Documentation
...    Author: Arkadiusz Gurgul,  arkadiusz.gurgul@nokia.com
...    Maintainer: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com
...    CB012204


Resource          ./resources/keywords.robot

Suite Setup      Run Keywords
...              Set Allowed Alarms For ASiR Suite Setup    AND
...              Common Suite Setup With OnAir Test Line Preparation
...              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...              increase_time_for_checking_cells=600
...              increase_timeout_for_update_sw=1800
...              prefix_tag=CB012204
...              list_of_additional_allowed_alarms=User Account has Default Password
Suite Teardown   Common Suite Teardown
Test Setup       Run Keywords
...              Set Allowed Alarms For ASiR
...              Common Preconditions
Test Teardown    Custom Postconditions

*** Test Cases ***
[1][1.0] CB012204-SR-B_06 Mandatory update of local user accounts default password with incorrect and correct regex - Exploratory
    Sleep    60s    Wait for ASiR WebEM to be available
    Change value of allowAsiDefaultPassword   value=${False}
    Sleep    60s    Wait for ASiR WebEM to be available
    Prepare ASiR WebEM Browser Incorrect Regex
    Reset ASiR WebEM Password

[1][1.0] CB012204-SR-B_01 Enforcing the mandatory update of local user accounts default password (ASIR SC BTS)
    Sleep    60s    Wait for ASiR WebEM to be available
    Prepare ASiR WebEM Browser Correct Regex
    Logout ASiR WebEM
    Prepare ASiR WebEM Browser
    Reset ASiR WebEM Password

[1][1.0] CB012204-SR-B_02 Check fault 4459 using MantaRay Monitor
    Sleep    60s    Wait for ASiR WebEM to be available
    Add Node And Web Url    service_name=fmwas
    Prepare ASiR WebEM Browser Correct Regex
    Reset ASiR WebEM Password
    Integrate ASI With NetAct    mr=MRC-ASIR/MR-ASIR
    Close ASiR WebEM Browser
    Alarm Upload For ASI    user_alarm_active=${True}    length=2
    Sleep    60s    Wait for ASiR WebEM to be available
    Prepare ASiR WebEM Browser Correct Regex
    Change ASiR WebEM Password
    Integrate ASI With NetAct    mr=MRC-ASIRDIFFPASS/MR-ASIRDIFFPASS
    Close ASiR WebEM Browser
    Alarm Upload For ASI    user_alarm_active=${False}    length=1
    Sleep    60s    Wait for ASiR WebEM to be available
    Prepare ASiR WebEM Browser
    Reset ASiR WebEM Password
    Deintegrate ASI With NetAct
    Delete Node And Clean    service_name=fmwas

[1][2.0] CB012204-SR-B_03 Suppressing the mandatory update of local user accounts default password (ASIR SC BTS)
    Sleep    60s    Wait for ASiR WebEM to be available
    Change value of allowAsiDefaultPassword   value=${True}
    Sleep    60s    Wait for ASiR WebEM to be available
    Prepare ASiR WebEM Browser
    Reset ASiR WebEM Password

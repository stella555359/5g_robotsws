*** Settings ***
Documentation  File contains Robot keywords to assist in performing common tests
...            author: Mateusz Jaskot, mateusz.jaskot@nokia.com
...            maintainer: Mateusz Jaskot, mateusz.jaskot@nokia.com

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/common/gnb_ru.robot
Library     taf.sw.scout    WITH NAME    scout
Library     ../automated_reporter.py

*** Variables ***
${USE_SCOUT_INTERNAL_ID}              False

*** Keywords ***
Common Test Teardown
    [Documentation]    This keyword runs common postconditions after test and restore gnb if the test failed
     ...
     ...       **Example:**
     ...       | Common Test Teardown

    Common Postconditions With Watching Alarms
    Run Keyword If Test Failed    Restore gNB Configuration After Test

Common Test Teardown EP
    [Documentation]    This keyword runs common postconditions after test, enable beams on Main RU nad restore gnb if the test failed
     ...
     ...       **Example:**
     ...       | Common Test Teardown EP

    Common Postconditions With Watching Alarms
    Enable Beams on Main RU
    Run Keyword If Test Failed    Restore gNB Configuration After Test



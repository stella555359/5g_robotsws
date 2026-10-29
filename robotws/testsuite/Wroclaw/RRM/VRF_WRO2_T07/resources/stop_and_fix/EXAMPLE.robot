*** Settings ***
Documentation
...   author: Karol Pichurski
...   contact: karol.pichurski@nokia.com
...   This is the example how to use stop_and_fix tool.

Library     taf.ue
Library     EXAMPLE.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/stop_and_fix/stop_and_fix.py

Suite Setup     prepare_testline

*** Variables ***
@{alarms_ids}    49  # Here you should create list with alarams_ids which should stop testline
                     # 49 - block cell

*** Test Cases ***
Test
    [Setup]   stop_and_fix     alarms_ids=${alarms_ids}  # In setup you should run stop_and_fix in every test
    test
    [Teardown]   stop_watchdog   # In teardown you should stop watchdog

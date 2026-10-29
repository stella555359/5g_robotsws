*** Settings ***
Documentation
...   Keywords for regression testing of CNI-124674
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     testsuite.Krakow.SISO.resources.sassim.SASSim    WITH NAME   sas
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
Suite Setup
    Perform Full Commissioning On Classical gnb     update_timeout=1200
    Perform Full Commissioning on gNB ASIR hub
    Common Suite Setup
    sas.Prepare Sas Sim    port_number=4431    reset_iptables=${True}

Test Setup
    Set Suite Variable    $IS_ASIR_CONFIGURATION     ${False}
    Common Preconditions With Watching Alarms

Test Teardown
    Common Postconditions With Watching Alarms

Suite Teardown
    sas.Stop Sas Sim Server
    Common Suite Teardown

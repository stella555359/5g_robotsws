*** Settings ***
Documentation
...   Keywords for regression testing of CNI-142598
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     testsuite.Krakow.SISO.resources.sassim.SASSim    WITH NAME   sas
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification        WITH NAME    Alarms
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
@{additional_allowed_alarms} =  FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
...		TDD-5G SyncE-Assisted Holdover period shorter than Adaptive Holdover period

*** Keywords ***
Suite Setup
    Perform Full Commissioning On Classical gnb     update_timeout=1200
    Perform Full Commissioning on gNB ASIR hub
    Common Suite Setup
    sas.Prepare Sas Sim    port_number=4431    reset_iptables=${True}

Test Setup
    Common Preconditions With Watching Alarms

Test Teardown
    Common Postconditions With Watching Alarms

Suite Teardown
    sas.Stop Sas Sim Server
    Common Suite Teardown

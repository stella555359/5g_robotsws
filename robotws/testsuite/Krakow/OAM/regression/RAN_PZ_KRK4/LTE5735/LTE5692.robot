*** Settings ***
Documentation
...   Test suite for regression testing of feature LTE5692 CRT
...   author: Tomasz Reczek, Marcin Bereznicki
...   contact: tomasz.reczek@nokia.com, marcin.bereznicki@nokia.com

Library           Collections
Library           taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnbcomm
Library           taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations
Library           ./resources/snapshot_keywords.py
Library           ./resources/bts_operation.py
Library           ./resources/CustomAsirKeywords.py
Resource          taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables         taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Run Keywords
...               Reset Configuration
...               AND
...               Common Suite Setup With Commissioning    asir_hub=${True}
...               AND
...               gnbalarm.wait_for_alarm_deactivation  fault_id=7300  awaiting_time=1200
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Test Cases ***
LTE5692_CfgMgmt_7_Configuration_Management_Configuration_reset
    [Setup]     Run Keywords
    ...         Common Preconditions With Watching Alarms
    ...         AND
    ...         Check Number of HUB IDs

    gnb_asir.Reset Configuration
    Wait Untill All Hubs are Enabled
    Verify All Hubs are Enabled and not Commissioned

    [Teardown]  Run Keywords
    ...         Restore ASIR Configuration and Wait for onAir
    ...         AND
    ...         Common Postconditions With Watching Alarms

LTE5692_HW_View_11_Display_software_information
    Verify Software version is visible

*** Keywords ***
Reset Configuration
    Log To Console                  Perform Configuration Reset
    Run Keyword And Ignore Error    gnbcomm.reset_configuration

Restore ASIR Configuration and Wait for onAir
     gnb_asir.Perform ASIR Commissioning                     scf_path=${ASIR_SCF_LOCAL_PATH}
     gnb_asir.Wait for ASIR to be OnAir
     Wait Until Keyword Succeeds     120 sec     15 sec      gnb_cell.Verify All Cell Status
     Wait Until Keyword Succeeds     120 sec     15 sec      gnb_asir.Verify Status Of All Asir Cells Is Operational

Wait Untill All Hubs are Enabled
    ${expected_statuses}    Create Dictionary  operationalState=enabled
    Wait Until Keyword Succeeds     500sec    20sec    gnb_asir.Verify HubMod Status
    ...                                                                         hub_ids=${all_hub_ids}
    ...                                                                         expected_statuses=${expected_statuses}

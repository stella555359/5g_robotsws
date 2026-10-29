*** Settings ***
Documentation
...   Test suite for regression testing of feature LTE5735 CRT
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
LTE5735_get_snapshot
    ${snapshot_path}                gnblog.Collect Snapshot
    Extract File From Snapshot      file_name_to_extract=UWEM_Events
    ...                             snapshot_path=${snapshot_path}

LTE5735_HWServiceStatus_5_HW_and_Service_Status-Events_history-Reset_pRRH
    gnbalarm.Allow Alarm            alarm=Failure detected on assigned antennas
    Perform pRRh Reset
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_Events
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=hwState changed to resetting
    ...                             second_keyword=ANTMOD
    gnbalarm.Disallow Alarm         alarm=Failure detected on assigned antennas

LTE5735_HWServiceStatus_11_HW_and_Service_Status-Events_history-block-unblock
    gnbalarm.Allow Alarm            alarm=Failure detected on assigned antennas
    Perform pRRh Block Unblock
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_Events
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=localState changed to blocked
    ...                             second_keyword=ANTMOD
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=localState changed to unblocked
    ...                             second_keyword=ANTMOD
    gnbalarm.Disallow Alarm         alarm=Failure detected on assigned antennas

LTE5735_HWServiceStatus_6_HW_and_Service_Status-Events_history-Reset_sHUB
    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Failure detected on assigned antennas
    Perform Hub Reset
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_Events
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=hwState changed to resetting
    ...                             second_keyword=HUBMOD

LTE5735_HWServiceStatus_10_HW_and_Service_Status-Events_history-unit_state_change
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_Events
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=hwState changed
    ...                             second_keyword=ANTMOD_R
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=localState changed
    ...                             second_keyword=ANTMOD_R
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=operationalState
    ...                             second_keyword=ANTMOD_R
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=swState changed
    ...                             second_keyword=ANTMOD_R
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=swState changed
    ...                             second_keyword=ANTMOD_R

LTE5735_HWServiceStatus_3_HW_and_Service_Status-Events_history-sHUB_pRRH_Detection
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_Events
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=swState changed to detected
    ...                             second_keyword=HUBMOD
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=swState changed to detected
    ...                             second_keyword=ANTMOD

LTE5735_HWServiceStatus_4_HW_and_Service_Status-Events_history-Reset_AsiSystem
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_Events
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=Site reset

LTE5735_HWServiceStatus_8_HW_and_Service_Status-Events_history-Commissioning
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_Events
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=ASiR commissioning started
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=ASiR commissioning completed

LTE5735_HWServiceStatus_9_HW_and_Service_Status-Events_history-Fault_Activation_Clearing
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_Events
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=fault
    ...                             second_keyword=active
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=fault
    ...                             second_keyword=cleared

LTE5735_Snapshot_2_Snapshot-Snapshot_Collection_SCF
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_CommissioningFile
    ...                                             snapshot_path=${snapshot_path}
    Check if File Exist     file_name_to_find=UWEM_CommissioningFile
    ...                     snapshot_path=${snapshot_path}

LTE5735_HWServiceStatus_1_HW_and_Service_Status-Site_Information-Runtime_Parameter_Viewer
    Validate RunTime Parameter Viewer

LTE5735_HWServiceStatus_2_HW_and_Service_Status-Site_Information-Configuration_Parameter_Viewer
    Validate Configuration Parameter Viewer

#Only 23R1_MP

LTE5735_UserAccountMgmt_1_User_Account_Mgmt-Audit_Trial_Logs-operations-pRRH_Block_Unblock
    gnbalarm.Allow Alarm            alarm=Failure detected on assigned antennas
    Perform pRRh Block Unblock
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_ATL
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=Unit block
    ...                             second_keyword=ANTMOD
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=Unit unblock
    ...                             second_keyword=ANTMOD
    gnbalarm.Disallow Alarm         alarm=Failure detected on assigned antennas

LTE5735_UserAccountMgmt_2_User_Account_Mgmt-Audit_Trial_Logs-operations-pRRH_Reset
    gnbalarm.Allow Alarm            alarm=Failure detected on assigned antennas
    Perform pRRh Reset
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_ATL
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=reset
    ...                             second_keyword=ANTMOD
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=Nemuadmin
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=eventTime
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=clientIPAddress
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=NEIPAddress
    gnbalarm.Disallow Alarm         alarm=Failure detected on assigned antennas

LTE5735_UserAccountMgmt_4_User_Account_Mgmt-Audit_Trial_Logs-operations-sHUB_Reset
    gnbalarm.Allow Alarm            alarm=Failure detected on assigned antennas
    Perform Hub Reset
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_ATL
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=reset
    ...                             second_keyword=HUBMOD
    gnbalarm.Disallow Alarm         alarm=Failure detected on assigned antennas

LTE5735_UserAccountMgmt_5_User_Account_Mgmt-Audit_Trial_Logs-operations-Configuration_Reset
    [Setup]     Common Preconditions With Watching Alarms
    Perform Reset ASiR Configuration
    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_ATL
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=Configuration reset
    [Teardown]  Run Keywords
    ...         Restore ASIR Configuration and Wait for onAir
    ...         AND
    ...         Common Postconditions With Watching Alarms

LTE5735_UserAccountMgmt_7_User_Account_Mgmt-Audit_Trial_Logs-Commission_from_file
    ${snapshot_path}              gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_ATL
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=Reconfiguration request

LTE5735_UserAccountMgmt_9_User_Account_Mgmt-Audit_Trial_Logs-login_logout_successful__attempts
    ${snapshot_path}                 gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_ATL
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=Login attempt succeeded
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=Logout request

LTE5735_Snapshot_1_Snapshot-Snapshot_Collection_Fault
    gnbalarm.Allow Alarm            alarm=Failure detected on assigned antennas

    gnb_asir.block_antenna
    Wait Until Keyword Succeeds  10x  5 sec  gnb_asir.verify_alarm_is_active         fault_id=${4348}

    Sleep    10s    reason=Wait till Unblock operation will be available
    gnb_asir.unblock_antenna
    Wait Until Keyword Succeeds  10x  5 sec  gnb_asir.verify_alarm_is_not_active     fault_id=${4348}
    Wait Until Keyword Succeeds  10x  5 sec  gnb_asir.verify_alarm_is_not_active     fault_id=${4518}

    Sleep    10s    reason=Wait till block operation will be available
    gnb_asir.block_antenna
    Wait Until Keyword Succeeds  10x  5 sec  gnb_asir.verify_alarm_is_active         fault_id=${4348}

    ${snapshot_path}                gnblog.Collect Snapshot
    ${found_file}=    Extract File From Snapshot    file_name_to_extract=UWEM_Alarms
    ...                                             snapshot_path=${snapshot_path}
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=faultState
    ...                             second_keyword=active
    Check if Entry Exist in File    file_path=${found_file}
    ...                             first_keyword=faultState
    ...                             second_keyword=cleared

    gnb_asir.unblock_antenna
    Wait Until Keyword Succeeds  10x  5 sec  gnb_asir.verify_alarm_is_not_active     fault_id=${4348}
    Wait Until Keyword Succeeds  10x  5 sec  gnb_asir.verify_alarm_is_not_active     fault_id=${4518}
    Wait Until Keyword Succeeds  30x  5 sec  Verify Setup Of All Cells

    gnbalarm.Disallow Alarm         alarm=Failure detected on assigned antennas

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

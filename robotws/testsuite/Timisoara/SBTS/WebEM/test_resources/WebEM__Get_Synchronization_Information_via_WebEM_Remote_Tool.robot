*** Settings ***
Documentation
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case gets synchronization information.
    ...  Verify if syncMode exists and gets the value.
    ...  Verify if tuningMode exists and gets the value.
    ...  Verify if syncSourceInfo exists and gets the value.
    ...  Verify if status exists and gets the value.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Get_Synchronization_Information_via_WebEM_Remote_Tool
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24258
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24258 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Get Synchronization Information


Step1: Get Synchronization Information
    Log  \nStep1: Get synchronization information  console=true
    ${sync_info}  coam.Get Synchronization Information  60s
    Dictionary Should Contain Key  ${sync_info}  syncMode
    ${value_sync_mode}  Get From Dictionary  ${sync_info}  syncMode
    Log  Value for syncMode is ${value_sync_mode}!  console=true
    Dictionary Should Contain Key  ${sync_info}  tuningMode
    ${value_tuning_mode}  Get From Dictionary  ${sync_info}  tuningMode
    Log  Value for tuningMode is ${value_tuning_mode}!  console=true
    Dictionary Should Contain Key  ${sync_info}  syncSourceInfo
    ${sync_source_info}  Get From Dictionary  ${sync_info}  syncSourceInfo
    Dictionary Should Contain Key  ${sync_source_info[0]}  status
    ${status}  Get From Dictionary  ${sync_source_info[0]}  status
    Log  Values for status are ${status}!  console=true


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown

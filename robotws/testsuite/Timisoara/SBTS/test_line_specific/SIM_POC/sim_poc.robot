*** Settings ***
Resource  ../../WebEM/test_resources/WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI.robot
Resource  ../../WebEM/test_resources/WebEM__Admin_CLI_getActiveAlarms.robot
Resource  ../../WebEM/test_resources/WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user.robot
Resource  ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Web.robot
Resource  ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Mobile.robot

Documentation    Test suite to check Airphone and CUS simulators for GUI testing.


*** Variables ***
${GUI_VERSION}  new


*** Test Cases ***
WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI
    [Setup]  WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI.TC Setup
    TC__WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI
    [Teardown]  WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI.TC Teardown


WebEM__Admin_CLI_getActiveAlarms
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_getActiveAlarms
    [Teardown]  TC Teardown


WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user
    [Setup]  WebEM__Admin_CLI_getActiveAlarms.TC Setup
    TC__WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user
    [Teardown]  WebEM__Admin_CLI_getActiveAlarms.TC Teardown


WebEM__Duration_of_loading_WebEM_application_Web
    [Setup]  WebEM__Duration_of_loading_WebEM_application_Web.TC Setup
    TC__WebEM__Duration_of_loading_WebEM_application_Web
    [Teardown]  WebEM__Duration_of_loading_WebEM_application_Web.TC Teardown


WebEM__Duration_of_loading_WebEM_application_Mobile
    [Setup]  WebEM__Duration_of_loading_WebEM_application_Mobile.TC Setup
    TC__WebEM__Duration_of_loading_WebEM_application_Mobile
    [Teardown]  WebEM__Duration_of_loading_WebEM_application_Mobile.TC Teardown

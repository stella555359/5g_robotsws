*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF
Documentation  This suite contains WebEM__5G_cells_graceful_shutdown TC

Resource  ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Web.robot
Resource  ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Mobile.robot
Resource  ../../WebEM/test_resources/WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI.robot
Resource  ../../WebEM/test_resources/WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user.robot
Resource  ../../WebEM/test_resources/WebEM__Admin_CLI_getActiveAlarms.robot

*** Variables ***
${COLLECT_SNAPSHOT_FLAG}  never


*** Test Cases ***
WebEM__Duration_of_loading_WebEM_application_Web
    [Tags]    QC_70569
    [Setup]  Run Keywords  Log  ${TEST TAGS}
    ...  AND  Modify Resource Search Order  WebEM__Duration_of_loading_WebEM_application_Web
    ...  AND  Common Test Setup Simulators
    TC__WebEM__Duration_of_loading_WebEM_application_Web
    [Teardown]  Run Keywords  WebEM Teardown
    ...  AND  Common Test Teardown Simulators
    ...  AND  Restore Resource Search Order


WebEM__Duration_of_loading_WebEM_application_Mobile
    [Tags]    QC_70571
    [Setup]  Run Keywords  Modify Resource Search Order  WebEM__Duration_of_loading_WebEM_application_Mobile
    ...  AND  Common Test Setup Simulators
    TC__WebEM__Duration_of_loading_WebEM_application_Mobile
    [Teardown]   Run Keywords  WebEM Teardown
    ...  AND  Common Test Teardown Simulators
    ...  AND  Restore Resource Search Order


WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI
    [Tags]    QC_70566
    [Setup]  Run Keywords  Modify Resource Search Order  WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI
    ...  AND  Common Test Setup Simulators
    TC__WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI
    [Teardown]   Run Keywords  Common Test Teardown Simulators
    ...  AND  Restore Resource Search Order


WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user
    [Tags]    QC_70566
    [Setup]  Run Keywords  Modify Resource Search Order  WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user
    ...  AND  Common Test Setup Simulators
    TC__WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user
    [Teardown]   Run Keywords  Common Test Teardown Simulators
    ...  AND  Restore Resource Search Order


WebEM__Admin_CLI_getActiveAlarms
    [Tags]    QC_70564
    [Setup]  Run Keywords  Modify Resource Search Order  WebEM__Admin_CLI_getActiveAlarms
    ...  AND  Common Test Setup Simulators
    ...  AND  WebEM Setup
    TC__WebEM__Admin_CLI_getActiveAlarms
    [Teardown]   Run Keywords  WebEM Teardown
    ...  AND  Common Test Teardown Simulators
    ...  AND  Restore Resource Search Order


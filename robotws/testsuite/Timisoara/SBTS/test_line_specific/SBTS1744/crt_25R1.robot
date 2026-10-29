*** Settings ***
Documentation  This suite is for 25R1 SBTS-10744
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R1  SRAN  CLOUD_SRAN_NLWG_10744_ASIB_ABIA_ABIN_ABIO_FXDB_AHEGA_AHFIA  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  ca_CIT_general

Resource    ../../WebEM/test_resources/WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.robot
Resource    ../../WebEM/test_resources/WebEM__BTS_Startup_view_show_resources.robot
Resource    ../../WebEM/test_resources/WebEM__UAM_Update_alias_and_password_for_local_users.robot
Resource    ../../WebEM/test_resources/WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.robot
Resource    ../../WebEM/test_resources/WebEM__SFP_Monitoring_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__Change_of_MPlane_address_and_commissioning_report.robot
Resource    ../../WebEM/test_resources/WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI.robot
Resource    ../../WebEM/test_resources/WebEM__System_Critical_Log_contents_via_MPlane.robot
Resource    ../../WebEM/test_resources/WebEM__Filtering_active_historical_BTS_alarm_list.robot
Resource    ../../FM/test_resources/FM__FHNET_reset_counter_exceeded.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1744
${COLLECT_SNAPSHOT_FLAG}    always

*** Test Cases ***
[1]WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Tags]  QC_90592
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${DISABLED_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${MODULE_RECOVERY_TIMEOUT_AFTER_UNLOCK}    1200

    ...    AND    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    TC__WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Teardown]    Run Keywords    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__BTS_Startup_view_show_resources
    [Tags]  QC_90591
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SCF_NR_LTE_NA}    SCF_NR_LTE_NA_25R1.xml
    ...    AND    Set Test Variable    ${SCF_WCDMA_GSM_NA}    SCF_WCDMA_GSM_NA.xml

    ...    AND    WebEM__BTS_Startup_view_show_resources.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__BTS_Startup_view_show_resources
    TC__WebEM__BTS_Startup_view_show_resources
    [Teardown]    Run Keywords    WebEM__BTS_Startup_view_show_resources.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__UAM_Update_alias_and_password_for_local_users
    [Tags]  QC_90588
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS_RESCUE_CONSOLE_TIMEOUT}    700

    ...    AND    WebEM__UAM_Update_alias_and_password_for_local_users.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__UAM_Update_alias_and_password_for_local_users
    TC__WebEM__UAM_Update_alias_and_password_for_local_users
    [Teardown]    Run Keywords    WebEM__UAM_Update_alias_and_password_for_local_users.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Tags]  QC_90596
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    TC__WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Teardown]    Run Keywords    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__SFP_Monitoring_Mobile
    [Tags]  QC_90590
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__SFP_Monitoring_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__SFP_Monitoring_Mobile
    TC__WebEM__SFP_Monitoring_Mobile
    [Teardown]    Run Keywords    WebEM__SFP_Monitoring_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Change_of_MPlane_address_and_commissioning_report
    [Tags]	QC_90594
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TEMPORARY_MPLANE_IP}    10.15.236.143

    ...    AND    WebEM__Change_of_MPlane_address_and_commissioning_report.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Change_of_MPlane_address_and_commissioning_report
    TC__WebEM__Change_of_MPlane_address_and_commissioning_report
    [Teardown]    Run Keywords    WebEM__Change_of_MPlane_address_and_commissioning_report.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI
    [Tags]  QC_90602
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI
    TC__WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI
    [Teardown]    Run Keywords    WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI.TC Teardown
    ...    AND    Restore Resource Search Order

[1]WebEM__System_Critical_Log_contents_via_MPlane
    [Tags]  QC_90603
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__System_Critical_Log_contents_via_MPlane.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__System_Critical_Log_contents_via_MPlane
    TC__WebEM__System_Critical_Log_contents_via_MPlane
    [Teardown]    Run Keywords    WebEM__System_Critical_Log_contents_via_MPlane.TC Teardown
    ...    AND    Restore Resource Search Order

[1]WebEM__Filtering_active_historical_BTS_alarm_list
    [Tags]  QC_115015
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Filtering_active_historical_BTS_alarm_list.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Filtering_active_historical_BTS_alarm_list
    TC__WebEM__Filtering_active_historical_BTS_alarm_list
    [Teardown]    Run Keywords    WebEM__Filtering_active_historical_BTS_alarm_list.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM__FHNET_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}     1200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}      1200

    ...    AND    FM__FHNET_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FHNET_reset_counter_exceeded
    TC__FM__FHNET_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FHNET_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a

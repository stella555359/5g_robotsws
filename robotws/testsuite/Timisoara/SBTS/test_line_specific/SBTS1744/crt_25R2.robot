*** Settings ***
Documentation  This suite is for Branch 25R2 SBTS-10744
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R2  SRAN  CLOUD_SRAN_NLWG_10744_ASIB_ABIA_ABIN_ABIO_FXDB_AHEGA_AHFIA  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  ca_CIT_general

Resource    ../../WebEM/test_resources/WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.robot
Resource    ../../WebEM/test_resources/WebEM__BTS_Startup_view_show_resources.robot
Resource    ../../WebEM/test_resources/WebEM__UAM_Update_alias_and_password_for_local_users.robot
Resource    ../../WebEM/test_resources/WebEM__Automatically_log_off_and_Session_Lock.robot
Resource    ../../WebEM/test_resources/WebEM__Password_change_for_toor4nsn_serviceuser.robot
Resource    ../../WebEM/test_resources/WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.robot
Resource    ../../WebEM/test_resources/WebEM__Check_appLoginBannerText.robot
Resource    ../../WebEM/test_resources/WebEM__Check_login_banner_text_file_permission.robot
Resource    ../../WebEM/test_resources/WebEM__Check_platLoginBannerText.robot
Resource    ../../WebEM/test_resources/WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.robot
Resource    ../../WebEM/test_resources/WebEM__SFP_Monitoring_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__BTS_Startup_view_show_resources_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__Change_of_MPlane_address_and_commissioning_report.robot
Resource    ../../WebEM/test_resources/WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI.robot
Resource    ../../WebEM/test_resources/WebEM__System_Critical_Log_contents_via_MPlane.robot
Resource    ../../WebEM/test_resources/WebEM__Filtering_active_alarms.robot
Resource    ../../WebEM/test_resources/WebEM__Wizard_Deleting_WCDMA_RAT.robot
Resource    ../../WebEM/test_resources/WebEM__Show_BTS_Start-up_view_automatically.robot
Resource    ../../WebEM/test_resources/WebEM__Filtering_active_historical_BTS_alarm_list.robot
Resource    ../../WebEM/test_resources/WebEM__Activation_of_Energy_Consumption_Measurement_collection.robot
Resource    ../../WebEM/test_resources/WebEM__Simplified_Site_View_Master_Mode_visualization.robot
Resource    ../../WebEM/test_resources/WebEM__Configuration_reset_platLoginBannerText_BTS_log_level.robot
Resource    ../../WebEM/test_resources/WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome.robot
Resource    ../../WebEM/test_resources/WebEM__5G_Test_Models_Running_5G_Downlink_Test.robot
Resource    ../../FM/test_resources/FM__FHNET_reset_counter_exceeded.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1744
${COLLECT_SNAPSHOT_FLAG}    always

*** Test Cases ***
[1]WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Tags]  QC_152371
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
    [Tags]  QC_152370
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SCF_NR_LTE_NA}    SCF_NR_LTE_NA.xml
    ...    AND    Set Test Variable    ${SCF_WCDMA_GSM_NA}    SCF_WCDMA_GSM_NA.xml

    ...    AND    WebEM__BTS_Startup_view_show_resources.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__BTS_Startup_view_show_resources
    TC__WebEM__BTS_Startup_view_show_resources
    [Teardown]    Run Keywords    WebEM__BTS_Startup_view_show_resources.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__UAM_Update_alias_and_password_for_local_users
    [Tags]  QC_152369
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS_RESCUE_CONSOLE_TIMEOUT}    700

    ...    AND    WebEM__UAM_Update_alias_and_password_for_local_users.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__UAM_Update_alias_and_password_for_local_users
    TC__WebEM__UAM_Update_alias_and_password_for_local_users
    [Teardown]    Run Keywords    WebEM__UAM_Update_alias_and_password_for_local_users.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Automatically_log_off_and_Session_Lock
    [Tags]  QC_152374
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Automatically_log_off_and_Session_Lock.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Automatically_log_off_and_Session_Lock
    TC__WebEM__Automatically_log_off_and_Session_Lock
    [Teardown]    Run Keywords    WebEM__Automatically_log_off_and_Session_Lock.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Password_change_for_toor4nsn_serviceuser
    [Tags]  QC_152387
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Password_change_for_toor4nsn_serviceuser.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Password_change_for_toor4nsn_serviceuser
    TC__WebEM__Password_change_for_toor4nsn_serviceuser
    [Teardown]    Run Keywords    WebEM__Password_change_for_toor4nsn_serviceuser.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Tags]  QC_152386
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    @{LIST_RMODS_WITH_EPM}    AHEGA    AHFIA

    ...    AND    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    TC__WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Teardown]    Run Keywords    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Check_appLoginBannerText
    [Tags]  QC_152383
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Check_appLoginBannerText.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Check_appLoginBannerText
    TC__WebEM__Check_appLoginBannerText
    [Teardown]    Run Keywords    WebEM__Check_appLoginBannerText.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Check_login_banner_text_file_permission
    [Tags]  QC_152385
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Check_login_banner_text_file_permission.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Check_login_banner_text_file_permission
    TC__WebEM__Check_login_banner_text_file_permission
    [Teardown]    Run Keywords    WebEM__Check_login_banner_text_file_permission.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Check_platLoginBannerText
    [Tags]  QC_152384
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Check_platLoginBannerText.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Check_platLoginBannerText
    TC__WebEM__Check_platLoginBannerText
    [Teardown]    Run Keywords    WebEM__Check_platLoginBannerText.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Tags]  QC_152372
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    TC__WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Teardown]    Run Keywords    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__SFP_Monitoring_Mobile
    [Tags]  QC_152380
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__SFP_Monitoring_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__SFP_Monitoring_Mobile
    TC__WebEM__SFP_Monitoring_Mobile
    [Teardown]    Run Keywords    WebEM__SFP_Monitoring_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__BTS_Startup_view_show_resources_Mobile
    [Tags]  QC_152376
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SCF_NR_LTE_NA}    SCF_NR_LTE_NA.xml
    ...    AND    Set Test Variable    ${SCF_WCDMA_GSM_NA}    SCF_WCDMA_GSM_NA.xml

    ...    AND    WebEM__BTS_Startup_view_show_resources_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__BTS_Startup_view_show_resources_Mobile
    TC__WebEM__BTS_Startup_view_show_resources_Mobile
    [Teardown]    Run Keywords    WebEM__BTS_Startup_view_show_resources_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Change_of_MPlane_address_and_commissioning_report
    [Tags]	QC_152382
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
    [Tags]  QC_152375
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI
    TC__WebEM__Check_login_banner_text_file_permission
    [Teardown]    Run Keywords    WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI.TC Teardown
    ...    AND    Restore Resource Search Order

[1]WebEM__System_Critical_Log_contents_via_MPlane
    [Tags]  QC_152381
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__System_Critical_Log_contents_via_MPlane.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__System_Critical_Log_contents_via_MPlane
    TC__WebEM__System_Critical_Log_contents_via_MPlane
    [Teardown]    Run Keywords    WebEM__System_Critical_Log_contents_via_MPlane.TC Teardown
    ...    AND    Restore Resource Search Order

[1]WebEM__Filtering_active_alarms
    [Tags]  QC_152389
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Filtering_active_alarms.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Filtering_active_alarms
    TC__WebEM__Filtering_active_alarms
    [Teardown]    Run Keywords    WebEM__Filtering_active_alarms.TC Teardown
    ...    AND    Restore Resource Search Order

[1]WebEM__Wizard_Deleting_WCDMA_RAT
    [Tags]  QC_152390
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    [['faultId', '4592', 'alarmId', '7115']]

    ...    AND    WebEM__Wizard_Deleting_WCDMA_RAT.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Wizard_Deleting_WCDMA_RAT
    TC__WebEM__Wizard_Deleting_WCDMA_RAT
    [Teardown]    Run Keywords    WebEM__Wizard_Deleting_WCDMA_RAT.TC Teardown
    ...    AND    Restore Resource Search Order

[1]WebEM__Show_BTS_Start-up_view_automatically
    [Tags]  QC_152388
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Show_BTS_Start-up_view_automatically.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Show_BTS_Start-up_view_automatically
    TC__WebEM__Show_BTS_Start-up_view_automatically
    [Teardown]    Run Keywords    WebEM__Show_BTS_Start-up_view_automatically.TC Teardown
    ...    AND    Restore Resource Search Order

[1]WebEM__Filtering_active_historical_BTS_alarm_list
    [Tags]  QC_152373
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Filtering_active_historical_BTS_alarm_list.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Filtering_active_historical_BTS_alarm_list
    TC__WebEM__Filtering_active_historical_BTS_alarm_list
    [Teardown]    Run Keywords    WebEM__Filtering_active_historical_BTS_alarm_list.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Activation_of_Energy_Consumption_Measurement_collection
    [Tags]  QC_152377
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{LIST_RMODS_WITH_EPM}  AHEGA  AHFIA
    ...    AND    Set Test Variable    @{LIST_RMODS_WITHOUT_EPM}  FXDB
    ...    AND    WebEM__Activation_of_Energy_Consumption_Measurement_collection.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Activation_of_Energy_Consumption_Measurement_collection
    TC__WebEM__Activation_of_Energy_Consumption_Measurement_collection
    [Teardown]    Run Keywords    WebEM__Activation_of_Energy_Consumption_Measurement_collection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Simplified_Site_View_Master_Mode_visualization
    [Tags]  QC_152379
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Simplified_Site_View_Master_Mode_visualization.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Simplified_Site_View_Master_Mode_visualization
    TC__WebEM__Simplified_Site_View_Master_Mode_visualization
    [Teardown]    Run Keywords    WebEM__Simplified_Site_View_Master_Mode_visualization.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Configuration_reset_platLoginBannerText_BTS_log_level
    [Tags]  QC_152378
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Configuration_reset_platLoginBannerText_BTS_log_level.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Configuration_reset_platLoginBannerText_BTS_log_level
    TC__WebEM__Configuration_reset_platLoginBannerText_BTS_log_level
    [Teardown]    Run Keywords    WebEM__Configuration_reset_platLoginBannerText_BTS_log_level.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome
    [Tags]  QC_159742
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome
    TC__WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome
    [Teardown]    Run Keywords    WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__5G_Test_Models_Running_5G_Downlink_Test
    [Tags]  QC_159743
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__5G_Test_Models_Running_5G_Downlink_Test.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__5G_Test_Models_Running_5G_Downlink_Test
    TC__WebEM__5G_Test_Models_Running_5G_Downlink_Test
    [Teardown]    Run Keywords    WebEM__5G_Test_Models_Running_5G_Downlink_Test.TC Teardown
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
*** Settings ***
Documentation  This is a suite for Branch 25R2 SBTS10745
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R2  SRAN  CLOUD_SRAN_NLWG_10745_ASIB_ABIA_ABIN_ABIO_AZNB_AEHC_FXDB  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01

Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getActiveAlarms.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getRmodMeasurementsById.robot
Resource    ../../WebEM/test_resources/WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode.robot
Resource    ../../WebEM/test_resources/WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode.robot
Resource    ../../WebEM/test_resources/WebEM__Compare_Managed_Objects.robot
Resource    ../../WebEM/test_resources/WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.robot
Resource    ../../WebEM/test_resources/WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells.robot
Resource    ../../WebEM/test_resources/WebEM__Loading_duration_until_runtime_view.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters.robot
Resource    ../../WebEM/test_resources/WebEM__script_launch_failed_due_to_script_already_ongoing.robot
Resource    ../../WebEM/test_resources/WebEM__launches_script_with_CELL_list_only.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_ims2ToSCF.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_availability_of_downloadSwConfig.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Web.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_login_in_WebEM_application_BTS_DU.robot
Resource    ../../WebEM/test_resources/WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.robot
Resource    ../../WebEM/test_resources/WebEM__BTS_Startup_view_show_resources.robot
Resource    ../../WebEM/test_resources/WebEM__Filtering_active_historical_BTS_alarm_list.robot
Resource    ../../FM/test_resources/FM__FHNET_reset_counter_exceeded.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1745
${COLLECT_SNAPSHOT_FLAG}    always
${SCF_LWG}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1745/node1/SCF_LWG.xml
${SCF_with_LANE}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1745/node1/SCF_LANE.xml
${SCF_with_fault}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1745/node1/SCF_Fault_25.xml
${JSON_with_parameter_true}  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1745/json/CB006590.json


*** Test Cases ***
[1]WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Tags]  QC_152410
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200

    ...    AND    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    TC__WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Teardown]    Run Keywords    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Tags]  QC_170658
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
    [Tags]  QC_170657
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


[1]WebEM_Admin_CLI_getActiveAlarms
    [Tags]  QC_152416
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_getActiveAlarms.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getActiveAlarms
    TC__WebEM__Admin_CLI_getActiveAlarms
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getActiveAlarms.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getRmodMeasurementsById
    [Tags]  QC_152406
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_getRmodMeasurementsById.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getRmodMeasurementsById
    TC__WebEM__Admin_CLI_getRmodMeasurementsById
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getRmodMeasurementsById.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    [Tags]  QC_152422
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    TC__WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    [Teardown]    Run Keywords    WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode
    [Tags]  QC_152408
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode.TC Setup
    ...    AND    Modify Resource Search Order
    ...    WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode
    TC__WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode
    [Teardown]    Run Keywords
    ...    WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Compare_Managed_Objects
    [Tags]  QC_152407
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Compare_Managed_Objects.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Compare_Managed_Objects
    TC__WebEM__Compare_Managed_Objects
    [Teardown]    Run Keywords    WebEM__Compare_Managed_Objects.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells
    [Tags]  QC_152419
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells
    TC__WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells
    [Teardown]    Run Keywords    WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Loading_duration_until_runtime_view
    [Tags]  QC_152417
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TIMEOUT}    30s

    ...    AND    WebEM__Loading_duration_until_runtime_view.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Loading_duration_until_runtime_view
    TC__WebEM__Loading_duration_until_runtime_view
    [Teardown]    Run Keywords    WebEM__Loading_duration_until_runtime_view.TC Teardown
    ...    AND    Restore Resource Search Order

 
[1]WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters
    [Tags]  QC_152413
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SCRIPT}    RU_Common_capture_register_dump

    ...    AND    WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters
    TC__WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters
    [Teardown]    Run Keywords    WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__script_launch_failed_due_to_script_already_ongoing
    [Tags]  QC_152414
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__script_launch_failed_due_to_script_already_ongoing.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__script_launch_failed_due_to_script_already_ongoing
    TC__WebEM__script_launch_failed_due_to_script_already_ongoing
    [Teardown]    Run Keywords    WebEM__script_launch_failed_due_to_script_already_ongoing.TC Teardown
    ...    AND    Restore Resource Search Order

 
[1]WebEM__launches_script_with_CELL_list_only
    [Tags]  QC_152411
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COLLECTING_FILES_TIMEOUT}    800

    ...    AND    WebEM__launches_script_with_CELL_list_only.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__launches_script_with_CELL_list_only
    TC__WebEM__launches_script_with_CELL_list_only
    [Teardown]    Run Keywords    WebEM__launches_script_with_CELL_list_only.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    [Tags]  QC_152412
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    TC__WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    [Tags]  QC_152418
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    TC__WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_ims2ToSCF
    [Tags]  QC_152420
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_ims2ToSCF.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_ims2ToSCF
    TC__WebEM__Admin_CLI_ims2ToSCF
    [Teardown]    Run Keywords    WebEM__Admin_CLI_ims2ToSCF.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_availability_of_downloadSwConfig
    [Tags]  QC_152421
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_availability_of_downloadSwConfig.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_availability_of_downloadSwConfig
    TC__WebEM__Admin_CLI_availability_of_downloadSwConfig
    [Teardown]    Run Keywords    WebEM__Admin_CLI_availability_of_downloadSwConfig.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM_WebEM__Duration_of_loading_WebEM_application_Mobile
    [Tags]  QC_159413
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_application_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_application_Mobile
    TC__WebEM__Duration_of_loading_WebEM_application_Mobile
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_application_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_loading_WebEM_application_Web
    [Tags]  QC_159409
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_application_Web.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_application_Web
    TC__WebEM__Duration_of_loading_WebEM_application_Web
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_application_Web.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    [Tags]  QC_159415
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    TC__WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    [Tags]  QC_159414
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_login_in_WebEM_application_BTS_DU.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    TC__WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    [Teardown]    Run Keywords    WebEM__Duration_of_login_in_WebEM_application_BTS_DU.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Filtering_active_historical_BTS_alarm_list
    [Tags]  QC_170659
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Filtering_active_historical_BTS_alarm_list.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Filtering_active_historical_BTS_alarm_list
    TC__WebEM__Filtering_active_historical_BTS_alarm_list
    [Teardown]    Run Keywords    WebEM__Filtering_active_historical_BTS_alarm_list.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FHNET_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}     1200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}      1200

    ...    AND    FM__FHNET_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FHNET_reset_counter_exceeded
    TC__FM__FHNET_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FHNET_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a

*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R3  SRAN  CLOUD_SRAN_NLWG_10745_ASIB_ABIA_ABIN_ABIO_AZNB_AEHC_FXDB  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01   

Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getActiveAlarms.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getRmodMeasurementsById.robot
Resource    ../../WebEM/test_resources/WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.robot
Resource    ../../WebEM/test_resources/WebEM__Command_Specific_Error_Codes_Verification.robot
Resource    ../../WebEM/test_resources/WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission.robot
Resource    ../../WebEM/test_resources/WebEM__Loading_duration_until_runtime_view.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters.robot
Resource    ../../WebEM/test_resources/WebEM__script_launch_failed_due_to_script_already_ongoing.robot
Resource    ../../WebEM/test_resources/WebEM__Monitor_Synchronization_overall_status.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_ims2ToSCF.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_availability_of_downloadSwConfig.robot
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
${GUI_VERSION}  old


*** Test Cases ***
[1]WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Tags]  QC_854921
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    
    ...    AND    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    TC__WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Teardown]    Run Keywords    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM_Admin_CLI_getActiveAlarms
    [Tags]  QC_854935
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__Admin_CLI_getActiveAlarms.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getActiveAlarms
    TC__WebEM__Admin_CLI_getActiveAlarms
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getActiveAlarms.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getRmodMeasurementsById
    [Tags]  QC_854920
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__Admin_CLI_getRmodMeasurementsById.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getRmodMeasurementsById
    TC__WebEM__Admin_CLI_getRmodMeasurementsById
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getRmodMeasurementsById.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Command_Specific_Error_Codes_Verification
    [Tags]  QC_854932
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    
    ...    AND    WebEM__Command_Specific_Error_Codes_Verification.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Command_Specific_Error_Codes_Verification
    TC__WebEM__Command_Specific_Error_Codes_Verification
    [Teardown]    Run Keywords    WebEM__Command_Specific_Error_Codes_Verification.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission
    [Tags]  QC_854922
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission
    TC__WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission
    [Teardown]    Run Keywords    WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Loading_duration_until_runtime_view
    [Tags]  QC_854934
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
    [Tags]  QC_854927
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
    [Tags]  QC_854931
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__script_launch_failed_due_to_script_already_ongoing.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__script_launch_failed_due_to_script_already_ongoing
    TC__WebEM__script_launch_failed_due_to_script_already_ongoing
    [Teardown]    Run Keywords    WebEM__script_launch_failed_due_to_script_already_ongoing.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Monitor_Synchronization_overall_status
    [Tags]  QC_854925
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SYNCHRONIZATION_MODE}    Phase synchronization

    ...    AND    WebEM__Monitor_Synchronization_overall_status.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Monitor_Synchronization_overall_status
    TC__WebEM__Monitor_Synchronization_overall_status
    [Teardown]    Run Keywords    WebEM__Monitor_Synchronization_overall_status.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    [Tags]  QC_854936
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    TC__WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    [Tags]  QC_854937
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    TC__WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_ims2ToSCF
    [Tags]  QC_854939
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_ims2ToSCF.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_ims2ToSCF
    TC__WebEM__Admin_CLI_ims2ToSCF
    [Teardown]    Run Keywords    WebEM__Admin_CLI_ims2ToSCF.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_availability_of_downloadSwConfig
    [Tags]  QC_854938
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_availability_of_downloadSwConfig.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_availability_of_downloadSwConfig
    TC__WebEM__Admin_CLI_availability_of_downloadSwConfig
    [Teardown]    Run Keywords    WebEM__Admin_CLI_availability_of_downloadSwConfig.TC Teardown
    ...    AND    Restore Resource Search Order


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

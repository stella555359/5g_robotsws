*** Settings ***
Documentation  This suite is for crt 26R1 SBTS-10658
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS26R1  SRAN  BTS_CLOUD_SRAN_N_10658_1ASIL_3ABIL_1ASIL_1ABIO_3AEHC_3AHFIG_3AHLOA  STATE_SKIP_AGENT
Library    XML  use_lxml=True
Suite Setup    Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01


Resource    ../../WebEM/test_resources/WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot.robot
Resource    ../../WebEM/test_resources/WebEM__Viewing_BTS_Performance_Counter_for_5G.robot
Resource    ../../WebEM/test_resources/WebEM__5G_cells_graceful_shutdown.robot
Resource    ../../WebEM/test_resources/WebEM__5G_Delta_plan_activation_for_parameters.robot
Resource    ../../WebEM/test_resources/WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI.robot
Resource    ../../WebEM/test_resources/WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_checkHw.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Web.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_login_in_WebEM_application_BTS_DU.robot
Resource    ../../WebEM/test_resources/WebEM__CP_WebEM_usability_for_large_configurations_WebEM.robot
Resource    ../../WebEM/test_resources/WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS.robot
Resource    ../../WebEM/test_resources/WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS.robot
Resource    ../../WebEM/test_resources/WebEM__CP_WebEM_usability_for_large_configurations_Mobile.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1658
${COLLECT_SNAPSHOT_FLAG}    always


*** Test Cases ***
[1]WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    [Tags]  QC_256544
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    TC__WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    [Teardown]    Run Keywords    WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Viewing_BTS_Performance_Counter_for_5G
    [Tags]  QC_256541
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Viewing_BTS_Performance_Counter_for_5G.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Viewing_BTS_Performance_Counter_for_5G
    TC__WebEM__Viewing_BTS_Performance_Counter_for_5G
    [Teardown]    Run Keywords    WebEM__Viewing_BTS_Performance_Counter_for_5G.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__5G_cells_graceful_shutdown
    [Tags]  QC_256534
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__5G_cells_graceful_shutdown.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__5G_cells_graceful_shutdown
    TC__WebEM__5G_cells_graceful_shutdown
    [Teardown]    Run Keywords   WebEM__5G_cells_graceful_shutdown.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__5G_Delta_plan_activation_for_parameters
    [Tags]  QC_256535
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__5G_Delta_plan_activation_for_parameters.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__5G_Delta_plan_activation_for_parameters
    TC__WebEM__5G_Delta_plan_activation_for_parameters
    [Teardown]    Run Keywords    WebEM__5G_Delta_plan_activation_for_parameters.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    [Tags]  QC_256538
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    TC__WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    [Teardown]    Run Keywords    WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    [Tags]  QC_256537
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...  AND  Set Test Variable  ${SUPPRESSED_ALARM_ID}  7220

    ...    AND    WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    TC__WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    [Teardown]    Run Keywords    WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms
    [Tags]  QC_256532
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms
    TC__WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms
    [Teardown]    Run Keywords    WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_checkHw
    [Tags]  QC_256533
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_ID_FOR_FAULT_1868}    4
    ...    AND    Set Test Variable    ${NEW_BBMODBOARDCONFIGTYPE_VALUE}    NRFDD

    ...    AND    WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_checkHw.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_checkHw
    TC__WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_checkHw
    [Teardown]    Run Keywords    WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_checkHw.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM_WebEM__Duration_of_loading_WebEM_application_Mobile
    [Tags]  QC_263140
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_application_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_application_Mobile
    TC__WebEM__Duration_of_loading_WebEM_application_Mobile
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_application_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_loading_WebEM_application_Web
    [Tags]  QC_263143
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_application_Web.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_application_Web
    TC__WebEM__Duration_of_loading_WebEM_application_Web
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_application_Web.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    [Tags]  QC_263142
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    TC__WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    [Tags]  QC_263141
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_login_in_WebEM_application_BTS_DU.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    TC__WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    [Teardown]    Run Keywords    WebEM__Duration_of_login_in_WebEM_application_BTS_DU.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CP_WebEM_usability_for_large_configurations_WebEM
    [Tags]  QC_263145
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...  AND  Set Test Variable  ${PATH_AVERAGE_SCF}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1658/node1/26R1_branch_BigScf_average_CP.xml
    ...  AND  Set Test Variable  ${PATH_BIG_SCF}  /media/share1-mnt/users/ivanescu/Big_SCF/26R1_branch_BigScf_high_CP.xml
    ...    AND    WebEM__CP_WebEM_usability_for_large_configurations_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CP_WebEM_usability_for_large_configurations_WebEM
    TC__WebEM__CP_WebEM_usability_for_large_configurations_WebEM
    [Teardown]    Run Keywords    WebEM__CP_WebEM_usability_for_large_configurations_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS
    [Tags]  QC_263146
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS
    TC__WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS
    [Teardown]    Run Keywords    WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS
    [Tags]  QC_263147
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS
    TC__WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS
    [Teardown]    Run Keywords    WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CP_WebEM_usability_for_large_configurations_Mobile
    [Tags]  QC_274019
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...  AND  Set Test Variable  ${PATH_AVERAGE_SCF}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1658/node1/26R1_branch_BigScf_average_CP.xml
    ...  AND  Set Test Variable  ${PATH_BIG_SCF}  /media/share1-mnt/users/ivanescu/Big_SCF/26R1_branch_BigScf_high_CP.xml
    ...    AND    WebEM__CP_WebEM_usability_for_large_configurations_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CP_WebEM_usability_for_large_configurations_Mobile
    TC__WebEM__CP_WebEM_usability_for_large_configurations_Mobile
    [Teardown]    Run Keywords    WebEM__CP_WebEM_usability_for_large_configurations_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a
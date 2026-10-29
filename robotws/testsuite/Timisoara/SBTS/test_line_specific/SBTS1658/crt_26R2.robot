*** Settings ***
Documentation  This suite is for crt 26R2 SBTS-10658
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS26R2  SRAN  BTS_CLOUD_SRAN_N_10658_1ASIL_3ABIL_1ASIL_1ABIO_3AEHC_3AHFIG_3AHLOA  STATE_SKIP_AGENT
Library    XML  use_lxml=True
Suite Setup    Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01


Resource    ../../WebEM/test_resources/WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot.robot
Resource    ../../WebEM/test_resources/WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active.robot
Resource    ../../WebEM/test_resources/WebEM__5G_cells_graceful_shutdown.robot
Resource    ../../WebEM/test_resources/WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI.robot
Resource    ../../WebEM/test_resources/WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Web.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_login_in_WebEM_application_BTS_DU.robot
Resource    ../../WebEM/test_resources/WebEM__CP_WebEM_usability_for_large_configurations_WebEM.robot
Resource    ../../WebEM/test_resources/WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS.robot
Resource    ../../WebEM/test_resources/WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS.robot
Resource    ../../WebEM/test_resources/WebEM__CP_WebEM_usability_for_large_configurations_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__CP_WebEM_usability_under_low_bandwidth_conditions.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1658
${COLLECT_SNAPSHOT_FLAG}    always


*** Test Cases ***
[1]WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    [Tags]  QC_300332
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    TC__WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    [Teardown]    Run Keywords    WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active
    [Tags]  QC_300334
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active
    TC__WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active
    [Teardown]    Run Keywords    WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__5G_cells_graceful_shutdown
    [Tags]  QC_300339
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__5G_cells_graceful_shutdown.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__5G_cells_graceful_shutdown
    TC__WebEM__5G_cells_graceful_shutdown
    [Teardown]    Run Keywords   WebEM__5G_cells_graceful_shutdown.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    [Tags]  QC_300341
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    TC__WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    [Teardown]    Run Keywords    WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    [Tags]  QC_300340
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
    [Tags]  QC_300337
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms
    TC__WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms
    [Teardown]    Run Keywords    WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM_WebEM__Duration_of_loading_WebEM_application_Mobile
    [Tags]  QC_311587
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_application_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_application_Mobile
    TC__WebEM__Duration_of_loading_WebEM_application_Mobile
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_application_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_loading_WebEM_application_Web
    [Tags]  QC_311601
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_application_Web.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_application_Web
    TC__WebEM__Duration_of_loading_WebEM_application_Web
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_application_Web.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    [Tags]  QC_311586
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    TC__WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    [Tags]  QC_311588
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_login_in_WebEM_application_BTS_DU.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    TC__WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    [Teardown]    Run Keywords    WebEM__Duration_of_login_in_WebEM_application_BTS_DU.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CP_WebEM_usability_for_large_configurations_WebEM
    [Tags]  QC_311600
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...  AND  Set Test Variable  ${PATH_AVERAGE_SCF}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1658/node1/26R2_BigScf_average_CP.xml
    ...  AND  Set Test Variable  ${PATH_BIG_SCF}  /media/share1-mnt/users/ivanescu/Big_SCF/26R2_branch_BigScf_high_CP.xml
    ...    AND    WebEM__CP_WebEM_usability_for_large_configurations_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CP_WebEM_usability_for_large_configurations_WebEM
    TC__WebEM__CP_WebEM_usability_for_large_configurations_WebEM
    [Teardown]    Run Keywords    WebEM__CP_WebEM_usability_for_large_configurations_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS
    [Tags]  QC_311599
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS
    TC__WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS
    [Teardown]    Run Keywords    WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS
    [Tags]  QC_311598
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS
    TC__WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS
    [Teardown]    Run Keywords    WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CP_WebEM_usability_for_large_configurations_Mobile
    [Tags]  QC_311585
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...  AND  Set Test Variable  ${PATH_AVERAGE_SCF}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1658/node1/26R2_BigScf_average_CP.xml
    ...  AND  Set Test Variable  ${PATH_BIG_SCF}  /media/share1-mnt/users/ivanescu/Big_SCF/26R2_branch_BigScf_high_CP.xml
    ...    AND    WebEM__CP_WebEM_usability_for_large_configurations_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CP_WebEM_usability_for_large_configurations_Mobile
    TC__WebEM__CP_WebEM_usability_for_large_configurations_Mobile
    [Teardown]    Run Keywords    WebEM__CP_WebEM_usability_for_large_configurations_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CP_WebEM_usability_under_low_bandwidth_conditions
    [Tags]  QC_311602
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CP_WebEM_usability_under_low_bandwidth_conditions.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CP_WebEM_usability_under_low_bandwidth_conditions
    TC__WebEM__CP_WebEM_usability_under_low_bandwidth_conditions
    [Teardown]    Run Keywords    WebEM__CP_WebEM_usability_under_low_bandwidth_conditions.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a
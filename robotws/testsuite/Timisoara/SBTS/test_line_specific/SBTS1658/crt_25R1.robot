*** Settings ***
Documentation  This suite is for crt 25R1 SBTS-10658
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R1  SRAN  BTS_CLOUD_SRAN_N_10658_1ASIL_3ABIL_1ASIL_1ABIO_3AEHC_3AHFIG_3AHLOA  STATE_SKIP_AGENT
Library    XML  use_lxml=True
Suite Setup    Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01


Resource    ../../WebEM/test_resources/WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot.robot
Resource    ../../WebEM/test_resources/WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active.robot
Resource    ../../WebEM/test_resources/WebEM__User_access_control_permission_for_BBMOD_power_reset.robot
Resource    ../../WebEM/test_resources/WebEM__Browser_refresh_not_lead_to_frozen_mode.robot
Resource    ../../WebEM/test_resources/WebEM__SFP_Monitoring_via_Diagnostic_tab.robot
Resource    ../../WebEM/test_resources/WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS.robot
Resource    ../../WebEM/test_resources/WebEM__Viewing_BTS_Performance_Counter_for_5G.robot
Resource    ../../WebEM/test_resources/WebEM__5G_cells_graceful_shutdown.robot
Resource    ../../WebEM/test_resources/WebEM__5G_Delta_plan_activation_for_parameters.robot



*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1658
${COLLECT_SNAPSHOT_FLAG}    always


*** Test Cases ***
[1]WebEM__Browser_refresh_not_lead_to_frozen_mode
    [Tags]  QC_114105
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Browser_refresh_not_lead_to_frozen_mode.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Browser_refresh_not_lead_to_frozen_mode
    TC__WebEM__Browser_refresh_not_lead_to_frozen_mode
    [Teardown]    Run Keywords    WebEM__Browser_refresh_not_lead_to_frozen_mode.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    [Tags]  QC_114103
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    TC__WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    [Teardown]    Run Keywords    WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active
    [Tags]  QC_114102
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active
    TC__WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active
    [Teardown]    Run Keywords    WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__User_access_control_permission_for_BBMOD_power_reset
    [Tags]  QC_114104
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__User_access_control_permission_for_BBMOD_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__User_access_control_permission_for_BBMOD_power_reset
    TC__WebEM__User_access_control_permission_for_BBMOD_power_reset
    [Teardown]    Run Keywords    WebEM__User_access_control_permission_for_BBMOD_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS.robot
    [Tags]  QC_114106
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS
    TC__WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS
    [Teardown]    Run Keywords    WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__SFP_Monitoring_via_Diagnostic_tab
    [Tags]  QC_114092
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__SFP_Monitoring_via_Diagnostic_tab.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__SFP_Monitoring_via_Diagnostic_tab
    TC__WebEM__SFP_Monitoring_via_Diagnostic_tab
    [Teardown]    Run Keywords    WebEM__SFP_Monitoring_via_Diagnostic_tab.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Viewing_BTS_Performance_Counter_for_5G
    [Tags]  QC_114094
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Viewing_BTS_Performance_Counter_for_5G.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Viewing_BTS_Performance_Counter_for_5G
    TC__WebEM__Viewing_BTS_Performance_Counter_for_5G
    [Teardown]    Run Keywords    WebEM__Viewing_BTS_Performance_Counter_for_5G.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__5G_cells_graceful_shutdown
    [Tags]  QC_114100
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__5G_cells_graceful_shutdown.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__5G_cells_graceful_shutdown
    TC__WebEM__5G_cells_graceful_shutdown
    [Teardown]    Run Keywords   WebEM__5G_cells_graceful_shutdown.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__5G_Delta_plan_activation_for_parameters
    [Tags]  QC_160224
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__5G_Delta_plan_activation_for_parameters.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__5G_Delta_plan_activation_for_parameters
    TC__WebEM__5G_Delta_plan_activation_for_parameters
    [Teardown]    Run Keywords    WebEM__5G_Delta_plan_activation_for_parameters.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a

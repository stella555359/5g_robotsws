*** Settings ***
Documentation  This suite is for crt Trunk SBTS-10658
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R3  SRAN  BTS_CLOUD_SRAN_N_10658_1ASIL_3ABIL_1ASIL_1ABIO_3AEHC_3AHFIG_3AHLOA  STATE_SKIP_AGENT
Library    XML  use_lxml=True
Suite Setup    Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01





Resource    ../../WebEM/test_resources/WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS.robot
Resource    ../../WebEM/test_resources/WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI.robot
Resource    ../../WebEM/test_resources/WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.robot
Resource    ../../WebEM/test_resources/WebEM__Disable_suppression_of_minor_warning_alarms.robot
Resource    ../../WebEM/test_resources/WebEM__BTS_Recovery_Reset_by_WebEM_CLI.robot




*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1658
${COLLECT_SNAPSHOT_FLAG}    always


*** Test Cases ***
[1]WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS
    [Tags]  QC_210204
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS
    TC__WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS
    [Teardown]    Run Keywords    WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    [Tags]  QC_210205
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...  AND  Set Test Variable  ${SCF_SUPPRESSED_FAULT_LIST}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1658/node1/Suppress_fault_list.xml
    ...  AND  Set Test Variable  ${SCF_SUPPRESSED_ALARM_LIST}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1658/node1/Suppress_alarm_list.xml
    ...  AND  Set Test Variable  ${SCF_ALLOWED_FAULT_LIST}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1658/node1/Allowed_alarm_fault_list.xml

    ...    AND    WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    TC__WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    [Teardown]    Run Keywords    WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    [Tags]  QC_210206
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...  AND  Set Test Variable  ${SUPPRESSED_ALARM_ID}  7220

    ...    AND    WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    TC__WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    [Teardown]    Run Keywords    WebEM__Case2_Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Disable_suppression_of_minor_warning_alarms
    [Tags]  QC_210207
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...  AND  Set Test Variable  ${SCF_SUPPRESSED_FAULT_LIST}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1658/node1/Suppress_fault_list.xml

    ...    AND    WebEM__Disable_suppression_of_minor_warning_alarms.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Disable_suppression_of_minor_warning_alarms
    TC__WebEM__Disable_suppression_of_minor_warning_alarms
    [Teardown]    Run Keywords    WebEM__Disable_suppression_of_minor_warning_alarms.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__BTS_Recovery_Reset_by_WebEM_CLI
    [Tags]  QC_210192
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__BTS_Recovery_Reset_by_WebEM_CLI.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__BTS_Recovery_Reset_by_WebEM_CLI
    TC__WebEM__BTS_Recovery_Reset_by_WebEM_CLI
    [Teardown]    Run Keywords    WebEM__BTS_Recovery_Reset_by_WebEM_CLI.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a

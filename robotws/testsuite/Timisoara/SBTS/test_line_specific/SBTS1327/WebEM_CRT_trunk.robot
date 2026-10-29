*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NLWG_1327_1ASIL_2ABIO_1ABIA_1AZQJ_1FXDB_1AEHC  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Map BuildShareTimi01   

Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_Remote_Tool_getLoglinkList.robot
Resource    ../../WebEM/test_resources/WebEM__SFP_Monitoring_via_Diagnostic_tab.robot
Resource    ../../FM/test_resources/FM__FHNET_reset_counter_exceeded.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1327
${COLLECT_SNAPSHOT_FLAG}    always


*** Test Cases ***
[1]WebEM Remote Tool - getLoglinkList
    [Tags]  QC_37871
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    
    ...    AND    WebEM__Admin_CLI_Remote_Tool_getLoglinkList.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_Remote_Tool_getLoglinkList
    TC__WebEM__Admin_CLI_Remote_Tool_getLoglinkList
    [Teardown]    Run Keywords    WebEM__Admin_CLI_Remote_Tool_getLoglinkList.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SFP_Monitoring_via_Diagnostic_tab
    [Tags]  QC_37872
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    WebEM__SFP_Monitoring_via_Diagnostic_tab.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__SFP_Monitoring_via_Diagnostic_tab
    TC__WebEM__SFP_Monitoring_via_Diagnostic_tab
    [Teardown]    Run Keywords    WebEM__SFP_Monitoring_via_Diagnostic_tab.TC Teardown
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

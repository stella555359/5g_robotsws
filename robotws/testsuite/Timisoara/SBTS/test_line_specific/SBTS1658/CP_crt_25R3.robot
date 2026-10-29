*** Settings ***
Documentation  This is a suite for Branch 25R3 SBTS10658
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R3  SRAN  CLOUD_SRAN_N_10658_1ASIL_3ABIL_1ASIL_1ABIO_3AEHC_3AHFIG_3AHLOA  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01

Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_application_Web.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.robot
Resource    ../../WebEM/test_resources/WebEM__Duration_of_login_in_WebEM_application_BTS_DU.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1658
${COLLECT_SNAPSHOT_FLAG}    always


*** Test Cases ***
[1]WebEM_WebEM__Duration_of_loading_WebEM_application_Mobile
    [Tags]  QC_216522
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_application_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_application_Mobile
    TC__WebEM__Duration_of_loading_WebEM_application_Mobile
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_application_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_loading_WebEM_application_Web
    [Tags]  QC_216521
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_application_Web.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_application_Web
    TC__WebEM__Duration_of_loading_WebEM_application_Web
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_application_Web.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    [Tags]  QC_216524
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    TC__WebEM__Duration_of_loading_WebEM_runtime_view_Mobile
    [Teardown]    Run Keywords    WebEM__Duration_of_loading_WebEM_runtime_view_Mobile.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    [Tags]  QC_216523
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Duration_of_login_in_WebEM_application_BTS_DU.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    TC__WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    [Teardown]    Run Keywords    WebEM__Duration_of_login_in_WebEM_application_BTS_DU.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a

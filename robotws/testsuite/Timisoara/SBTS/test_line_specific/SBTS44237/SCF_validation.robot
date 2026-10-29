*** Settings ***
Force Tags  QCD_MN_SRAN  QCP_SRAN_SBTS  SRAN  CLOUD_SRAN_L_44237_1AASIA_3ABIA_1ExtASIK_3UHBA_3UHIE_3UHFA_3AHCA  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot

Suite Setup   Run keywords    Map BuildShareTimi01


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara


*** Test Cases ***

[1]Automated__SWM__SCF_validation_errors_check
    [Timeout]    14401
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD44237 /home/ute/

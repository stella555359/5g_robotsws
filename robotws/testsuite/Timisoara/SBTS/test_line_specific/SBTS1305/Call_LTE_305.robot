*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_L_10305_1ASIB_3ABIA_2AREA_2ARGA_3AHPMDA  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../UE/test_resources/UE__NR_PS_call.robot
Resource    ../../UE/test_resources/UE__LTE_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_Voice_call.robot


Suite Setup   Run keywords    Map BuildShareTimi01


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}     ${TRUE}
${SCOUT_TL_NAME}         10_18_UTESRANCLOUD1305
${TESTLINE_NAME}         10_18_UTESRANCLOUD1305

*** Test Cases ***
[1]UE LTE PS call
    [Setup]    Run Keywords    Set Test Variable    ${MIN_LTE_THROUGHPUT}   30 Mbits/sec
    ...    AND    Set Test Variable    ${PS_DURATION}   69s
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220'], ['faultId', '6283', 'alarmId', '7111']]
    ...    AND    Modify Resource Search Order    UE__LTE_PS_call
    ...    AND    UE__LTE_PS_call.TC Setup

    [Timeout]    99 minutes
    TC__UE__LTE_PS_call
    [Teardown]    Run Keywords    UE__LTE_PS_call.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1305 /home/ute/


*** Settings ***
Documentation
...  SBTS10339 PM TC trunk sutie

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_LWG_10339_1ASIA_2ABIA_2FXDB_1FHEL_2FRGY  STATE_COMMISSIONED
Library           XML  use_lxml=True



Resource    ../../PM/test_resources/PM__LTE_DL_UL_Throughput_Check.robot


Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1339
${SKIP_RU_POWER_CHECK}    ${TRUE}


*** Test Cases ***


[1]PM__LTE_DL_UL_Throughput_Check
    [Tags]     QC_133166
    [Setup]    Run Keywords    Set Test Variable    ${MIN_LTE_THROUGHPUT_UPLINK}    120 Mbits/sec
    ...    AND    Set Test Variable    ${MIN_LTE_THROUGHPUT_DOWNLINK}    120 Mbits/sec
    ...    AND    PM__LTE_DL_UL_Throughput_Check.TC Setup
    ...    AND    Modify Resource Search Order    PM__LTE_DL_UL_Throughput_Check
    ...    AND    Set Library Search Order    PM__LTE_DL_UL_Throughput_Check
    [Timeout]    14400
    TC__PM__LTE_DL_UL_Throughput_Check
    [Teardown]    Run Keywords    PM__LTE_DL_UL_Throughput_Check.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...  cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a

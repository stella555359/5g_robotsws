*** Settings ***
Force Tags QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_NLWG_10423_2ASIL_2ABIA_1ABIO_1ABIQ_1ABIN_1ABIP_2FXDB_1FRGU_1FRME_2FXED_3AHEGB  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot


Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1423
${SKIP_RU_POWER_CHECK}    ${TRUE}

*** Test Cases ***
[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Ping stable timeout}    409
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip -P ${Target SW dir}
    [Timeout]    60 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order

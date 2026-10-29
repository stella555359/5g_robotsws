*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_N_10767_1ASIK_3ABIL_1ExtASIA_3AAHF  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot


Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1767
${SKIP_RU_POWER_CHECK}    ${TRUE}

*** Test Cases ***
[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL  QC_37054
    [Timeout]    14400
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
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__STATE__Radio_module_reset_from_Admin
    [Tags]  QC_753856
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_753857
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__STATE__Site_reset
    [Tags]  QC_753861
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]5G RAT reset via ADMIN
    [Tags]  QC_753855
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]FM__5G RAT reset executed as autonomous recovery action
    [Tags]  QC_753871
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API



[1]Automated__SWM__SW_update_for_RMOD_with_fault_23
    [Tags]  QC_753854
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API



[1]Automated__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Tags]  QC_753853
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1][UUF4ALL]SW upgrade in loop
    [Tags]  QC_753851
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


*** Settings ***
Documentation  This suite contains the FM test cases of SBTS10618 for Trunk regression.

Force Tags  QCD_MN_SRAN  QCP_SRAN_SBTS  SBTS00  SRAN  STATE_COMMISSIONED
...  BTS_CLOUD_SRAN_NLG_1618_2ASIM_1ABIA_1ABIO_3ABIP_1ABIQ_1FRGU_1AEHC_3AHFII_3AHLOB_3AVHA_1AVQL

Library           XML  use_lxml=True
Resource    ../../common_resources/ca_SBTS_general.robot
Resource    ../../common_resources/ca_FM_general.robot
Resource    ../../CIT/test_resources/STATE__Site_reset.robot
Resource    ../../FM/test_resources/FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1618
${SKIP_RU_POWER_CHECK}    ${TRUE}

*** Test Cases ***
[1]FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956
    [Tags]  QC_221517
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AHFII
    ...    AND    Set Test Variable    ${RMOD_USERNAME}  rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD}  0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}  900
    ...    AND    FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956.TC Setup
    ...    AND    Modify Resource Search Order    FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956
    TC__FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956
    [Teardown]    Run Keywords    FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956.TC Teardown
    ...    AND    Restore Resource Search Order

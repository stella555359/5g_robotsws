*** Settings ***
Documentation
...  Test Suite Author: Anna Plecha
...  Test Suite Owner: Anna Plecha

Resource          ../../../test_resources/BS-RF/SiSo_REC_RU_Deep_Sleep_Mode_Power_State.robot



*** Variables ***
${HW_LOCATION_CODE}      Wroclaw
${COMMISSIONING_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO129/node1/SBTS24R3/scf.xml
${TESTLINE_NAME}  10_16_UTESRANSISO129

*** Test Cases ***

[DS-AHEGHA][2.0] SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Setup]  Run Keywords  Set Test Variable  ${RMOD_SN}   BL2351H69VK
    ...  AND  Set Test Variable  ${REPETITIONS_AMOUNT}  1
    ...  AND  SiSo_REC_RU_Deep_Sleep_Mode_Power_State.TC Setup
    ...  AND  Set Library Search Order  admin  SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Timeout]   14400
    TC__SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Teardown]   SiSo_REC_RU_Deep_Sleep_Mode_Power_State.TC Teardown

[DS-AHFII][2.0] SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Setup]  Run Keywords  Set Test Variable  ${RMOD_SN}   BL2339N49U8
    ...  AND  Set Test Variable  ${REPETITIONS_AMOUNT}  1
    ...  AND  SiSo_REC_RU_Deep_Sleep_Mode_Power_State.TC Setup
    ...  AND  Set Library Search Order  admin  SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Timeout]   14400
    TC__SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Teardown]   SiSo_REC_RU_Deep_Sleep_Mode_Power_State.TC Teardown

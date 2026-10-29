*** Settings ***
Documentation

Resource          ../../../test_resources/BS-RF/SiSo_REC_RU_Deep_Sleep_Mode_Power_State.robot

*** Variables ***
${COMMISSIONING_PATH}  SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/
...  hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/SBTS_1464_UTESRANSISO907/commissioning/SCF_01_TRUNK.xml
${COLLECT_SNAPSHOT_FLAG}  Never
${TESTLINE_NAME}  10_16_UTESRANSISO907
#${RMOD_SN}
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=
...         faultId=2002, severity=Minor
...         faultId=4681, severity=Minor
${ENABLE_TRUCK_ROLL_FLAG}    ${False}


*** Test Cases ***
SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Setup]  Run Keywords  Set Test Variable  ${RMOD_SN}   BL1909V001Y,EA200262091
    ...  AND  Set Test Variable  ${REPETITIONS_AMOUNT}  2
    ...  AND  Set Test Variable  ${SISO_L3_CALL}  True
    ...  AND  Set Test Variable  ${CELLS_YAML_PATH}  /home/ute/testline_configuration/10_16_UTESRANSISO117/ue_config.yaml
    ...  AND  SiSo_REC_RU_Deep_Sleep_Mode_Power_State.TC Setup
    ...  AND  Set Library Search Order  SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Timeout]   14400
    TC__SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Teardown]   SiSo_REC_RU_Deep_Sleep_Mode_Power_State.TC Teardown



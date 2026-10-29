*** Settings ***
Documentation
...  Test Suite Author: Dominika Wojcik
...  Test Suite Owner: Dominika Wojcik
...  Team: T01


Resource          ../../../../../resources/ca_4G_RRM_carrier_aggregation.robot
Resource          ../../../test_resources/BS-RF/SiSo_REC_RU_Deep_Sleep_Mode_Power_State.robot



*** Variables ***

${CELLS_YAML_PATH}  SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/
...  SBTS_1321_UTESRANSISO079/device/dominika_cells.yaml
${ABSTRACT_LIB_CONFIG}  SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/
...  SBTS_1321_UTESRANSISO079/device/dominika_cells.yaml
${ABSTRACT_LIB_CONFIG2}  SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/
...  SBTS_1344_UTESRANSISO074/device/dominika_slim.yaml
${HW_LOCATION_CODE}      Wroclaw
${COMMISSIONING_PATH}  SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/
...  SBTS_1321_UTESRANSISO079/commissioning/SCF_01_SBTS25R2.xml
${TESTLINE_NAME}  10_16_UTESRANSISO079
${YAML_PATH_WITHOUT_FILTERS}  SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS/test_line_specific/
...  Wroclaw/SBTS_1321_UTESRANSISO079/device/dominika_cells.yaml
${YAML_PATH_WITH_FILTERS}    SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS/
...  test_line_specific/Wroclaw/SBTS_1321_UTESRANSISO079/device/dominika_slim.yaml
${ADDITIONAL_IGNORED_ALARMS}   181
*** Test Cases ***


[DS-ARDB][1.0] Automated_SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Setup]  Run Keywords  Set Test Variable  ${RMOD_SN}   L1194707349
    ...  AND  Set Test Variable  ${REPETITIONS_AMOUNT}  5
    ...  AND  Set Test Variable  ${SISO_L3_CALL}  False
    ...  AND  Set Test Variable  ${CELLS_YAML_PATH}
    ...  AND  SiSo_REC_RU_Deep_Sleep_Mode_Power_State.TC Setup
    ...  AND  Set Library Search Order  admin  SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Timeout]   28800
    TC__SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Teardown]   SiSo_REC_RU_Deep_Sleep_Mode_Power_State.TC Teardown


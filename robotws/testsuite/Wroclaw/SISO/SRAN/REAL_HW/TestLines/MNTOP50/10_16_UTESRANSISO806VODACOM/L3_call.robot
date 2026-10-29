*** Settings ***
Documentation    Suite description
...    Maintainer:    konrad.koziol@nokia.com

Resource    ../../../Resources/SiSo_L3_call.robot
#Resource     /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/Resources/SiSo_L3_call.robot

*** Variables ***
&{CONF_VODACOM_E2E}=                HW_ID=CONF_VODACOM_E2E
${KEY_PERFORM_SNAPSHOT}=            None
${KEY_PERFORM_HW_SETUP}=            False
${CELLS_CONFIG}=                    /home/ute/testline_configuration/10_16_UTESRANSISO806VODACOM/cells_vodacomE2E.yaml
${CELLS_YAML_PATH}=                 /home/ute/testline_configuration/10_16_UTESRANSISO806VODACOM/cells_vodacomE2E.yaml
*** Test Cases ***
L3_call
    [Setup]  Run Keywords  Set Test Variable  ${CELLS_YAML_PATH}    ${CELLS_CONFIG}
    ...  AND  Set Test Variable  ${LOGS_DIR}    /home/ute/test_results
    ...  AND  Set Test Variable  @{SELECTED_CELLS}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1239/LNCEL_R-22902
    #...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1239/LNCEL_R-22905
    #...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1239/LNCEL_R-22908
    #...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1239/LNCEL_R-22911
    #...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1239/LNCEL_R-22918
    #...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1239/NRCELL_R-22924
    #...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1239/NRCELL_R-22927
    SiSo L3 Call
    [Teardown]    No Operation


*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_LWG_10338_1ASIB_2ABIA_1ASIB_3ABIA_3AHEGC_3AHDB  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/CIT__BBMOD_reset_during_cell_establishing.robot
Resource    ../../CIT/test_resources/CIT__Lock_Unlock_BBMOD.robot
Resource    ../../CIT/test_resources/CIT__Recommissioning_cell_addition_cell_deletion.robot
Resource    ../../CIT/test_resources/CIT__Recommissioning_with_NR_rat_reset.robot
Resource    ../../CIT/test_resources/CIT__RF_sharing_with_radio_reset.robot
Resource    ../../CIT/test_resources/CIT__TDS.robot
Resource    ../../CIT/test_resources/CIT__useFullCapacity_parameter_change.robot

Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_230802_000007
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1338
${COMMISSIONING_PATH}
...  /home/ute/testline_configuration/10_18_UTESRANCLOUD1338/node1/BTS_CLOUD_SRAN_LWG_10338_1ASIB_2ABIA_1ASIB_3ABIA_3AHEGC_3AHDB_SBTS00.xml



*** Test Cases ***
[1]CIT__BBMOD_reset_during_cell_establishing
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1173606427
    ...    AND    Set Test Variable    ${SCF_FILE}  ${COMMISSIONING_PATH}

    ...    AND    Modify Resource Search Order    CIT__BBMOD_reset_during_cell_establishing
    ...    AND    CIT__BBMOD_reset_during_cell_establishing.TC Setup
    TC__CIT__BBMOD_reset_during_cell_establishing
    [Teardown]    Run Keywords    CIT__BBMOD_reset_during_cell_establishing.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]CIT__Lock_Unlock_BBMOD
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_DIST_NAME}  MRBTS-10338/EQM-1/APEQM-1/CABINET-1/BBMOD-1

    ...    AND    Modify Resource Search Order    CIT__Lock_Unlock_BBMOD
    ...    AND    CIT__Lock_Unlock_BBMOD.TC Setup
    TC__CIT__Lock_Unlock_BBMOD
    [Teardown]    Run Keywords    CIT__Lock_Unlock_BBMOD.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]CIT__Recommissioning_cell_addition_cell_deletion
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SCF_FILE}  ${COMMISSIONING_PATH}
    ...    AND    Set Test Variable    ${SCF_FILE_CELL_ADDED}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1338/node1/SCF_cell_deletion.xml

    ...    AND    Modify Resource Search Order    CIT__Recommissioning_cell_addition_cell_deletion
    ...    AND    CIT__Recommissioning_cell_addition_cell_deletion.TC Setup
    TC__CIT__Recommissioning_cell_addition_cell_deletion
    [Teardown]    Run Keywords    CIT__Recommissioning_cell_addition_cell_deletion.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]CIT__RF_sharing_with_radio_reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    EA192877401

    ...    AND    Modify Resource Search Order    CIT__RF_sharing_with_radio_reset
    ...    AND    CIT__RF_sharing_with_radio_reset.TC Setup
    TC__CIT__RF_sharing_with_radio_reset
    [Teardown]    Run Keywords    CIT__RF_sharing_with_radio_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]CIT__TDS
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${COMMISSIONING_TIMEOUT}    1200

    ...    AND    Modify Resource Search Order    CIT__TDS
    ...    AND    CIT__TDS.TC Setup
    TC__CIT__TDS
    [Teardown]    Run Keywords    CIT__TDS.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]CIT__useFullCapacity_parameter_change
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SERIAL_NUMBER}    L1171221156

    ...    AND    Modify Resource Search Order    CIT__useFullCapacity_parameter_change
    ...    AND    CIT__useFullCapacity_parameter_change.TC Setup
    TC__CIT__useFullCapacity_parameter_change
    [Teardown]    Run Keywords    CIT__useFullCapacity_parameter_change.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset

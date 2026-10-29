*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LW_1FSMF_2FBBC_1FRGU
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/STATE__RF_Module_lock_unlock.robot


*** Variables ***
${SCF_ID}    01


*** Test Cases ***
[1][1.0] Automated__STATE__RF_Module_lock_unlock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    10m
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    False
    
    ...    AND    STATE__RF_Module_lock_unlock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__RF_Module_lock_unlock
    TC__RF_Module_lock_unlock
    [Teardown]    Run Keywords    STATE__RF_Module_lock_unlock.TC Teardown
    ...    AND    Restore Resource Search Order

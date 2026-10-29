*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LW_1FSMF_2FBBC_1FRGU
Library           XML  use_lxml=True
Suite Setup      Set Library Search Order  ute_admin   taf.gnb.oam.coam.admin
Resource    ../../CIT/test_resources/STATE__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__LTE_cell_lock_unlock_from_ADMIN.robot
Resource    ../../CIT/test_resources/STATE__RF_Module_block_unblock.robot
Resource    ../../CIT/test_resources/STATE__Site_reset.robot
Resource    ../../CIT/test_resources/STATE__sbts_block_unblock.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara


*** Test Cases ***
[1]Automated__STATE__Site_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    STATE__Site_reset
    TC__STATE__Site_reset
    [Teardown]    Run Keywords    STATE__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order

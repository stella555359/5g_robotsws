*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC  STATE_SKIP_AGENT
Library           XML  use_lxml=True
Suite Setup      Set Library Search Order  ute_admin   taf.gnb.oam.coam.admin
Resource    ../../../test_resources/STATE/STATE__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../../test_resources/STATE/STATE__LTE_cell_lock_unlock_from_ADMIN.robot
Resource    ../../../test_resources/STATE/STATE__RF_Module_block_unblock.robot
Resource    ../../../test_resources/STATE/STATE__Site_reset.robot
Resource    ../../../test_resources/STATE/STATE__sbts_block_unblock.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1158


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
	Scout Request SCF
        Log  Starting request SCF from Scout.  console=true
        ${tl_name}  Fetch From Right  ${CONFIGURATION}  .
        ${sbts_id}  Get Substring  ${tl_name}  -3
        ${scout_name_exists}  Run Keyword And Return Status  Variable should exist
	${SCOUT_TL_NAME}
        Run keyword if  ${scout_name_exists}  Setup Scout  ${SCOUT_TL_NAME}
        ...  ELSE  Setup Scout  MRBTS-10${sbts_id}
        Request SCF  use_scout_internal_id=True
        Teardown Scout API
    ...    AND    Restore Resource Search Order


[2]Automated__STATE__Site_reset
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


[3]Automated__STATE__Site_reset
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


[4]Automated__STATE__Site_reset
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


[5]Automated__STATE__Site_reset
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


[6]Automated__STATE__Site_reset
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


[7]Automated__STATE__Site_reset
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


[8]Automated__STATE__Site_reset
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


[9]Automated__STATE__Site_reset
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


[10]Automated__STATE__Site_reset
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


[1]Automated__STATE__RF_Module_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    True
    
    ...    AND    STATE__RF_Module_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__RF_Module_block_unblock
    TC__RF_Module_block_unblock
    [Teardown]    Run Keywords    STATE__RF_Module_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[2]Automated__STATE__RF_Module_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    True
    
    ...    AND    STATE__RF_Module_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__RF_Module_block_unblock
    TC__RF_Module_block_unblock
    [Teardown]    Run Keywords    STATE__RF_Module_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[3]Automated__STATE__RF_Module_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    True
    
    ...    AND    STATE__RF_Module_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__RF_Module_block_unblock
    TC__RF_Module_block_unblock
    [Teardown]    Run Keywords    STATE__RF_Module_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[4]Automated__STATE__RF_Module_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    True
    
    ...    AND    STATE__RF_Module_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__RF_Module_block_unblock
    TC__RF_Module_block_unblock
    [Teardown]    Run Keywords    STATE__RF_Module_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[5]Automated__STATE__RF_Module_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    True
    
    ...    AND    STATE__RF_Module_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__RF_Module_block_unblock
    TC__RF_Module_block_unblock
    [Teardown]    Run Keywords    STATE__RF_Module_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[6]Automated__STATE__RF_Module_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    True
    
    ...    AND    STATE__RF_Module_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__RF_Module_block_unblock
    TC__RF_Module_block_unblock
    [Teardown]    Run Keywords    STATE__RF_Module_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[7]Automated__STATE__RF_Module_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    True
    
    ...    AND    STATE__RF_Module_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__RF_Module_block_unblock
    TC__RF_Module_block_unblock
    [Teardown]    Run Keywords    STATE__RF_Module_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[8]Automated__STATE__RF_Module_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    True
    
    ...    AND    STATE__RF_Module_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__RF_Module_block_unblock
    TC__RF_Module_block_unblock
    [Teardown]    Run Keywords    STATE__RF_Module_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[9]Automated__STATE__RF_Module_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    True
    
    ...    AND    STATE__RF_Module_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__RF_Module_block_unblock
    TC__RF_Module_block_unblock
    [Teardown]    Run Keywords    STATE__RF_Module_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[10]Automated__STATE__RF_Module_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Test Variable    ${LOG_TX_POWER}    True
    
    ...    AND    STATE__RF_Module_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__RF_Module_block_unblock
    TC__RF_Module_block_unblock
    [Teardown]    Run Keywords    STATE__RF_Module_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[2]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[3]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[4]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[5]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[6]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[7]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[8]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[9]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[10]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200
    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__sbts_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[2]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200
    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__sbts_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[3]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200
    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__sbts_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[4]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200
    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__sbts_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[5]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200
    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__sbts_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[6]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200
    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__sbts_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[7]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200
    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__sbts_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[8]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200
    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__sbts_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[9]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200
    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__sbts_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[10]Automated__STATE__SBTS_block_unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CUSTOM_BLOCKED_BTS_DISTNAME}    
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_BEFORE_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_BLOCK}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT_AFTER_UNBLOCK}    1200
    ...    AND    Set Test Variable    ${bts_host}    192.168.255.129
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__sbts_block_unblock.TC Setup
    ...    AND    Modify Resource Search Order    STATE__sbts_block_unblock
    TC__STATE__SBTS_block_unblock
    [Teardown]    Run Keywords    STATE__sbts_block_unblock.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[2]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[3]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[4]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[5]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[6]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[7]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[8]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[9]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[10]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order

	
[1]Automated__STATE__Cell_block_unblock_F
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[2]Automated__STATE__Cell_block_unblock_F
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[3]Automated__STATE__Cell_block_unblock_F
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[4]Automated__STATE__Cell_block_unblock_F
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[5]Automated__STATE__Cell_block_unblock_F
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[6]Automated__STATE__Cell_block_unblock_F
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[7]Automated__STATE__Cell_block_unblock_F
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[8]Automated__STATE__Cell_block_unblock_F
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[9]Automated__STATE__Cell_block_unblock_F
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[10]Automated__STATE__Cell_block_unblock_F
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order
	
	
[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[2]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[3]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[4]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[5]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[6]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[7]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[8]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[9]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


[10]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Timeout]    60 minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELL_ID}    45541
    
    ...    AND    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_cell_lock_unlock_from_ADMIN
    TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_cell_lock_unlock_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

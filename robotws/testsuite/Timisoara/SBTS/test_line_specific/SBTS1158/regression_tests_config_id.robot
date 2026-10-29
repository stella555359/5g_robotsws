 *** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC  STATE_SKIP_AGENT
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
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD10158


*** Test Cases ***
[1]Automated__STATE__Site_reset
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[2]Automated__STATE__Site_reset
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[3]Automated__STATE__Site_reset
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[4]Automated__STATE__Site_reset
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[5]Automated__STATE__Site_reset
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[6]Automated__STATE__Site_reset
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[7]Automated__STATE__Site_reset
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[8]Automated__STATE__Site_reset
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[9]Automated__STATE__Site_reset
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[10]Automated__STATE__Site_reset
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__STATE__RF_Module_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[2]Automated__STATE__RF_Module_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[3]Automated__STATE__RF_Module_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[4]Automated__STATE__RF_Module_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[5]Automated__STATE__RF_Module_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[6]Automated__STATE__RF_Module_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[7]Automated__STATE__RF_Module_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[8]Automated__STATE__RF_Module_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[9]Automated__STATE__RF_Module_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[10]Automated__STATE__RF_Module_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[2]Automated__STATE__LTE_RAT_reset_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[3]Automated__STATE__LTE_RAT_reset_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[4]Automated__STATE__LTE_RAT_reset_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[5]Automated__STATE__LTE_RAT_reset_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[6]Automated__STATE__LTE_RAT_reset_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[7]Automated__STATE__LTE_RAT_reset_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[8]Automated__STATE__LTE_RAT_reset_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__LTE_RAT_reset_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[10]Automated__STATE__LTE_RAT_reset_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__STATE__SBTS_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[2]Automated__STATE__SBTS_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[3]Automated__STATE__SBTS_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[4]Automated__STATE__SBTS_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[5]Automated__STATE__SBTS_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__SBTS_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[7]Automated__STATE__SBTS_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[8]Automated__STATE__SBTS_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[9]Automated__STATE__SBTS_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[10]Automated__STATE__SBTS_block_unblock
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[2]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[3]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[4]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[5]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[7]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[8]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[9]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[10]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    Setup Scout  10_18_UTESRANCLOUD1158
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API



*** Keywords ***

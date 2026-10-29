*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LG_1FSMF_1FBBC_2FXDB_2FRMA_1FRHC  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

Resource    ../../../test_resources/CIT/STATE__Site_reset.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara

*** Test Cases ***
[1]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69357
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69358
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69359
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69360
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69361
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69362
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69363
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69365
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69364
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69367
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69368
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Tags]  QC_69366
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69371
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69370
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69369
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69372
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69374
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69377
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69373
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69376
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_69375
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69380
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69381
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69382
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69383
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69378
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69386
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69384
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69385
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__Cell_block_unblock_F
    [Tags]  QC_69379
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69392
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69389
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69396
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69394
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69398
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69387
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69388
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69391
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69403
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69406
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69401
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69399
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69393
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69397
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69395
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69404
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Tags]  QC_69390
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69407
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69402
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69413
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_69422
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69400
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Tags]  QC_69405
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69408
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[2]Automated__STATE__Site_reset
    [Tags]  QC_69418
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69410
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[3]Automated__STATE__Site_reset
    [Tags]  QC_69423
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69414
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[4]Automated__STATE__Site_reset
    [Tags]  QC_69419
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69409
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[5]Automated__STATE__Site_reset
    [Tags]  QC_69424
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69411
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69415
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[6]Automated__STATE__Site_reset
    [Tags]  QC_69420
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[7]Automated__STATE__Site_reset
    [Tags]  QC_69425
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69412
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__RF_Module_block_unblock
    [Tags]  QC_69416
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[8]Automated__STATE__Site_reset
    [Tags]  QC_69421
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[9]Automated__STATE__Site_reset
    [Tags]  QC_69426
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[10]Automated__STATE__Site_reset
    [Tags]  QC_69417
    Setup Scout  10_18_UTESRANCLOUD1554
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
*** Keywords ***
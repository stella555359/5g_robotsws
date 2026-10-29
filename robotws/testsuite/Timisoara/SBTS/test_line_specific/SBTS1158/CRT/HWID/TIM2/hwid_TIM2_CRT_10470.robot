*** Settings ***
Documentation
...    Author: mihai.rusu@nokia.com
...    Description: CSV

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_L_10470_1ASIA_3ABIA_2FXED_1FXED_3FRGU_2FXDB_1FRMF  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

Resource    ../../../test_resources/CIT/STATE__Site_reset.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara

*** Test Cases ***
[1]E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]  QC_46695
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Tags]  QC_222371
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]  QC_37385
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required_5
    [Tags]  QC_37386
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI_5
    [Tags]  QC_37383
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI_5
    [Tags]  QC_37388
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_RU_Reset_with_OAM_KPI_4
    [Tags]  QC_37387
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset_4
    [Tags]  QC_37390
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call_4
    [Tags]  QC_37391
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI_4
    [Tags]  QC_37389
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_long_3
    [Tags]  QC_37392
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_short_3
    [Tags]  QC_37370
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__link_break_GTPU
    [Tags]  QC_37371
    Setup Scout  10_18_UTESRANCLOUD1470_3
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI_3
    [Tags]  QC_37372
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_long_2
    [Tags]  QC_37377
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_short_2
    [Tags]  QC_37374
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__link_break_GTPU_2
    [Tags]  QC_37378
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI_2
    [Tags]  QC_37379
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_long_1
    [Tags]  QC_37381
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_short_1
    [Tags]  QC_37380
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__link_break_GTPU_1
    [Tags]  QC_37382
    Setup Scout  10_18_UTESRANCLOUD1470_1
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI_1
    [Tags]  QC_37384
    Setup Scout  10_18_UTESRANCLOUD1470
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

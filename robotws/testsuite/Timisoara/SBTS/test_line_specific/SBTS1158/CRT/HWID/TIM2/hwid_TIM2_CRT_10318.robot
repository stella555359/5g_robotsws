*** Settings ***
Documentation
...    Author: mihai.rusu@nokia.com
...    Description: CSV

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
[1]E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]  QC_37342
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Tags]  QC_46702
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]  QC_37352
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]  QC_37340
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Tags]  QC_37346
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]  QC_37352
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]  QC_37345
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Tags]  QC_37341
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]  QC_37352
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Tags]  QC_37343
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_long
    [Tags]  QC_37349
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__FM__link_break_S1_short
    [Tags]  QC_37350
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__link_break_GTPU
    [Tags]  QC_37348
    Setup Scout  10_18_UTESRANCLOUD1318
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

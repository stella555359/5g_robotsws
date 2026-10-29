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
[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]  QC_647547
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Tags]  QC_647546
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Tags]  QC_647549
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]  QC_647548
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Tags]  QC_647551
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]  QC_647553
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]  QC_647554
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Tags]  QC_647555
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    [Tags]  QC_647557
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]  QC_647559
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]  QC_647560
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Tags]  QC_647561
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__FM__link_break_Abis_long
    [Tags]  QC_648963
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__FM__link_break_Abis_short
    [Tags]  QC_648964
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__FM__link_break_Abis_startup
    [Tags]  QC_648966
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]Automated__FM__link_break_SBTS_short
    [Tags]  QC_648965
    Setup Scout  10_18_UTESRANCLOUD1344
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


*** Keywords ***
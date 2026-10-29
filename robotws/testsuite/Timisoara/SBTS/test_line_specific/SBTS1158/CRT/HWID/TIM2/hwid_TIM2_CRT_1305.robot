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
[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Tags]  QC_647738
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]  QC_647739
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]  QC_647740
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Tags]  QC_647743
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]  QC_647745
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]  QC_647746
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Tags]  QC_647747
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]  QC_647751
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]  QC_647752
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Tags]  QC_647753
    Setup Scout  10_18_UTESRANCLOUD1305
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API	

*** Keywords ***
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
    [Tags]  QC_647774
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]  QC_647776
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]  QC_647775
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]  QC_647781
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]  QC_647780
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]  QC_647782
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]  QC_647787
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Tags]  QC_647784
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]  QC_647788
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]  QC_647790
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__link_break_X2_long
    [Tags]  QC_650226
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__link_break_X2_short
    [Tags]  QC_650227
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

*** Keywords ***
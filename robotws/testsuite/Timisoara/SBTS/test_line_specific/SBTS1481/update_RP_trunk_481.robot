*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_N_10481_1ASIB_1ABIO_3AEHC  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara

*** Test Cases ***

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Tags]  QC_37447
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]  QC_37447
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]  QC_37453
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]  QC_37449
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]  QC_37451
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]  QC_37450
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Tags]  QC_37456
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]  QC_37448
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]  QC_37452
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]  QC_37454
    Setup Scout  10_18_UTESRANCLOUD1481
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

*** Keywords ***

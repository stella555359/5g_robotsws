*** Settings ***
Documentation
...    Author: mihai.rusu@nokia.com
...    Description: CSV

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_N_10649_1ASIL_2ABIO_1ABIP_3AHLOA_3AHFIG_3AEHC_1ExtASIB_NOVMREINSTALL  STATE_SKIP_AGENT
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
    [Tags]  QC_180508
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Tags]  QC_180514
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]  QC_180515
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required_5
    [Tags]  QC_180516
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI_5
    [Tags]  QC_180517
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI_5
    [Tags]  QC_180519
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_RU_Reset_with_OAM_KPI_4
    [Tags]  QC_180520
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset_4
    [Tags]  QC_180521
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call_4
    [Tags]  QC_180522
    Setup Scout  10_18_UTESRANCLOUD1649
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
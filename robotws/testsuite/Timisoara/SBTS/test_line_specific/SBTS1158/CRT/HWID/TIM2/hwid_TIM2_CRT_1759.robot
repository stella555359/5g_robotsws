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
[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]  QC_753911
    Setup Scout  10_18_UTESRANCLOUD1759
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__SWM__SCF_validation_errors_check
    [Tags]  QC_753915
    Setup Scout  10_18_UTESRANCLOUD1759
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Site_reset
    [Tags]  QC_753906
    Setup Scout  10_18_UTESRANCLOUD1759
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning_planned_commissioning
    [Tags]  QC_753907
    Setup Scout  10_18_UTESRANCLOUD1759
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Commissioning__Configuration_reset
    [Tags]  QC_753910
    Setup Scout  10_18_UTESRANCLOUD1759
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_with_BTS_reset
    [Tags]  QC_753917
    Setup Scout  10_18_UTESRANCLOUD1759
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_with_reset
    [Tags]  QC_753920
    Setup Scout  10_18_UTESRANCLOUD1759
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__Radio_module_reset_from_Admin
    [Tags]  QC_753921
    Setup Scout  10_18_UTESRANCLOUD1759
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__CM__Recommissioning_delta_commissioning_without_reset
    [Tags]  QC_753919
    Setup Scout  10_18_UTESRANCLOUD1759
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__STATE__SBTS_block_unblock
    [Tags]  QC_753922
    Setup Scout  10_18_UTESRANCLOUD1759
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]Automated__LOGS__Snapshot_content__postmortem_files_creation_for_SMOD
    [Tags]  QC_753924
    Setup Scout  10_18_UTESRANCLOUD1759
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API
	
*** Keywords ***
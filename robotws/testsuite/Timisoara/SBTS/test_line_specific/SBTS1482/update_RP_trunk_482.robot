*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_NL_10482_1ASIB_2ABIL_3AEQE  STATE_SKIP_AGENT
Library  XML  use_lxml=True
Library  taf.sw.scout
Library  String
Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

Documentation  Test suite for CSV4ALL Tests in loop.

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara

*** Test Cases ***
[1]FM__link_break_X2_long
    [Tags]  QC_222257
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

[1]FM__link_break_X2_short
    [Tags]  QC_222259
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API


[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]  QC_222255
    Setup Scout  10_18_UTESRANCLOUD1482
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1482 /home/ute/

